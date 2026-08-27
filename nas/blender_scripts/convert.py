"""GLB -> Roblox-ready FBX. Bezi headless v ugc-blender containeru:

    blender -b -P convert.py -- --job /data/jobs/<id>.json

Job JSON: {"id", "category", "backend", "glb": in, "out_dir": out, "spec": path,
"symmetry": "" | "radial"}
Kroky dle UGC_FORGE_PLAN.md: import, cleanup, retopo/decimate, UV, CPU bake
(EMIT s prepojenym base color - zadna svetla), orientace+scale do bbox
kategorie, attachment empty, FBX export + validate report JSON.
"""
import argparse
import json
import math
import os
import sys

import bpy

VOXEL_ADAPTIVE_FRACTION = 0.008   # voxel size ~ 0.8 % nejdelsi hrany bboxu
DECIMATE_TARGET_FRACTION = 0.9    # cil = 0.9 x max_tris (rezerva na triangulaci)
BAKE_SIZE = 1024
RADIAL_SECTORS = 3                # dort/korunka: 120 stupnu dokola

# Predni smer po importu GLB. glTF se diva na scenu po +Z; Blender ji pri
# importu prevede na Z-up, cimz se z +Z stane -Y - a s -Y jako "forward"
# pocita i export_fbx nize.
FRONT_ANGLE = -math.pi / 2


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--job", required=True)
    return ap.parse_args(argv)


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def import_glb(path):
    bpy.ops.import_scene.gltf(filepath=path)
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    if not meshes:
        raise RuntimeError("GLB obsahuje 0 meshu")
    # vic objektu -> join do jednoho (Roblox accessory = 1 MeshPart)
    bpy.ops.object.select_all(action="DESELECT")
    for o in meshes:
        o.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    if len(meshes) > 1:
        bpy.ops.object.join()
    obj = bpy.context.view_layer.objects.active
    obj.name = "Handle"
    return obj


def cleanup(obj):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.remove_doubles(threshold=0.0001)
    bpy.ops.mesh.delete_loose()
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode="OBJECT")


# Nad timto poctem komponent uz nejde o detaily, ale o roztristeny mesh,
# ktery se bez cisteni nedostane pod limit trojuhelniku.
FRAGMENT_THRESHOLD = 40


def count_components(obj):
    """Spocita odpojene casti bez toho, aby cokoli menila."""
    import bmesh
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.faces.ensure_lookup_table()
    seen = set()
    n = 0
    for f in bm.faces:
        if f.index in seen:
            continue
        n += 1
        stack = [f]
        seen.add(f.index)
        while stack:
            face = stack.pop()
            for e in face.edges:
                for nb in e.link_faces:
                    if nb.index not in seen:
                        seen.add(nb.index)
                        stack.append(nb)
    bm.free()
    return n


def remove_floaters(obj, keep_fraction=0.02, max_components=None):
    """Smaze odpojene komponenty mensi nez keep_fraction celkovych faces;
    s max_components navic nechá jen N nejvetsich.

    Collapse decimate ma topologicke dno ~3 tris na komponentu, takze mesh
    roztristeny na stovky kusu se pod limit nedostane bez ohledu na ratio
    (zmereno: helma 762 komponent -> 5184 tris pri cili 3600, plat 718 ->
    4248). Roblox accessory stejne chce jednu skorapku, ne konfety."""
    import bmesh
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.faces.ensure_lookup_table()
    seen = set()
    components = []
    for f in bm.faces:
        if f.index in seen:
            continue
        stack, comp = [f], []
        seen.add(f.index)
        while stack:
            face = stack.pop()
            comp.append(face)
            for e in face.edges:
                for nb in e.link_faces:
                    if nb.index not in seen:
                        seen.add(nb.index)
                        stack.append(nb)
        components.append(comp)
    total = len(bm.faces)
    threshold = max(int(total * keep_fraction), 8)
    keep = [c for c in components if len(c) >= threshold]
    if max_components is not None and len(keep) > max_components:
        keep.sort(key=len, reverse=True)
        keep = keep[:max_components]
    keep_ids = {id(c) for c in keep}
    doomed = [f for comp in components if id(comp) not in keep_ids for f in comp]
    if doomed:
        bmesh.ops.delete(bm, geom=doomed, context="FACES")
        bm.to_mesh(obj.data)
    n_removed = len(doomed)
    n_comp = len(components)
    bm.free()
    return n_comp, n_removed


def tri_count(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def has_uv(obj):
    return bool(obj.data.uv_layers)


def decimate_to(obj, target):
    """Collapse decimate ve smycce, dokud mesh neni pod cilem - jeden
    pruchod ho mine, viz poznamka u retopo()."""
    for _ in range(4):
        tris = tri_count(obj)
        if tris <= target:
            break
        mod = obj.modifiers.new("Decimate", "DECIMATE")
        mod.ratio = target / tris
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return tri_count(obj)


def retopo(obj, backend, max_tris):
    """Vraci (tri_count, components, removed_floater_faces).

    SF3D uz je low-poly s UV -> jen pripadny decimate. Jinak voxel remesh
    (zavre diry, sjednoti skorapky - stejna lekce jako blackwell_fix na
    Sparku) a decimate na cil.

    Decimate modifikator pocita FACES, limit Robloxu jsou TROJUHELNIKY -
    a voxel remesh vraci quady (2 tris/face). Proto se mesh nejdriv
    triangulizuje a decimate bezi ve smycce, dokud neni pod cilem
    (prakticky 1-2 pruchody). Bez toho front plate vysel na 6398 tris
    pri "3600" faces."""
    target = int(max_tris * DECIMATE_TARGET_FRACTION)
    if backend != "sf3d":
        dims = obj.dimensions
        voxel = max(max(dims) * VOXEL_ADAPTIVE_FRACTION, 0.0005)
        mod = obj.modifiers.new("Remesh", "REMESH")
        mod.mode = "VOXEL"
        mod.voxel_size = voxel
        bpy.ops.object.modifier_apply(modifier=mod.name)

    # Mazat odpojene casti az kdyz je to nutne. U sperku jsou drobne
    # oddelene kusy legitimni obsah - perly, kameny, visici pridavky - a
    # slepe mazani "floateru" ubralo koruně 1414 trojuhelniku vcetne perel.
    # Fragmentovany mesh (stovky komponent) se resi az v eskalaci nize.
    components = count_components(obj)
    removed = 0
    if components > FRAGMENT_THRESHOLD:
        components, removed = remove_floaters(obj)
    print(f"components: {components}, floater faces removed: {removed}", flush=True)

    mod = obj.modifiers.new("Tri", "TRIANGULATE")
    bpy.ops.object.modifier_apply(modifier=mod.name)

    decimate_to(obj, target)

    # Eskalace: collapse decimate ma dno - u roztristeneho meshe se zastavi
    # (zmereno: 5188 -> 5184 a dal ne, protoze 762 komponent nejde slucovat).
    # Voxel remesh postavi topologii znovu jako jednu skorapku, takze hrubsi
    # voxel poly count spolehlive srazi. Radeji hrubsi helma nez FAIL.
    for attempt in range(1, 4):
        if tri_count(obj) <= max_tris:
            break
        dims = obj.dimensions
        voxel = max(max(dims) * VOXEL_ADAPTIVE_FRACTION * (2 ** attempt), 0.001)
        mod = obj.modifiers.new("Remesh%d" % attempt, "REMESH")
        mod.mode = "VOXEL"
        mod.voxel_size = voxel
        bpy.ops.object.modifier_apply(modifier=mod.name)

        mod = obj.modifiers.new("Tri%d" % attempt, "TRIANGULATE")
        bpy.ops.object.modifier_apply(modifier=mod.name)

        tris = tri_count(obj)
        if tris > target:
            mod = obj.modifiers.new("Dec%d" % attempt, "DECIMATE")
            mod.ratio = target / tris
            bpy.ops.object.modifier_apply(modifier=mod.name)
        print("remesh escalation %d: voxel=%.5f -> %d tris" % (attempt, voxel, tri_count(obj)), flush=True)

    return tri_count(obj), components, removed


def radial_symmetrize(obj, sectors=RADIAL_SECTORS):
    """Ponecha predni vysec kolem osy Z a otoci ji dokola.

    Model z jednoho obrazku ma zdobenou jen prednu stranu; zadni si TRELLIS
    domysli a vyjde plocha. U predmetu, ktere radialne symetricke opravdu
    jsou - dort, korunka - je levnejsi prednu vysec zkopirovat nez zadni
    stranu dogenerovat (pokus o "rear view" prompt 2026-08-27 selhal, SDXL
    pokyn o kamere u predmetu ignoruje).

    Kopie nesou UV originalu, takze zdobeni dokola obstara uz stavajici
    EMIT bake - zadny zvlastni krok pro texturu.

    Vraci (pocet vrcholu svarenych na svu, tri_count po operaci).
    """
    import bmesh
    from mathutils import Matrix, Vector

    if sectors < 2:
        return 0, tri_count(obj)

    bm = bmesh.new()
    bm.from_mesh(obj.data)
    if not bm.verts:
        bm.free()
        raise RuntimeError("prazdny mesh pred symetrizaci")

    # Osa jde stredem bboxu v XY - origin je v tuhle chvili jeste tam, kam
    # ho polozil import (fit_and_orient ho sroubuje az na konci).
    xs = [v.co.x for v in bm.verts]
    ys = [v.co.y for v in bm.verts]
    center = Vector(((min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2, 0.0))
    span = max(max(xs) - min(xs), max(ys) - min(ys), 1e-6)

    # Dva rezy pres osu vymezi vysec 360/sectors stupnu kolem predniho smeru.
    # Normala roviny miri vzdy po smeru rostouciho uhlu, takze u dolniho rezu
    # padne zaporna strana a u horniho kladna; pro sectors >= 3 je vysec uzsi
    # nez 180 stupnu, takze prunik obou polorovin je presne ona.
    half = math.pi / sectors
    for angle, keep_positive in ((FRONT_ANGLE - half, True), (FRONT_ANGLE + half, False)):
        bmesh.ops.bisect_plane(
            bm, geom=list(bm.verts) + list(bm.edges) + list(bm.faces),
            dist=span * 1e-4, plane_co=center,
            plane_no=Vector((-math.sin(angle), math.cos(angle), 0.0)),
            clear_inner=keep_positive, clear_outer=not keep_positive)
    loose = [v for v in bm.verts if not v.link_faces]
    if loose:
        bmesh.ops.delete(bm, geom=loose, context="VERTS")
    if not bm.faces:
        bm.free()
        raise RuntimeError("symetrizace odrizla cely mesh (spatna osa?)")

    wedge = list(bm.verts) + list(bm.edges) + list(bm.faces)
    for i in range(1, sectors):
        dup = bmesh.ops.duplicate(bm, geom=wedge)["geom"]
        bmesh.ops.rotate(
            bm, cent=center, verts=[e for e in dup if isinstance(e, bmesh.types.BMVert)],
            matrix=Matrix.Rotation(2 * math.pi * i / sectors, 3, "Z"))

    # Svarit sev. Rez v uhlu -150 stupnu a rez v -30 stupnu jsou dva ruzne
    # prurezy meshem, takze se po otoceni nekryji uplne - prah proto musi
    # byt stedry (zlomek velikosti modelu, ne absolutni cislo; GLB z TRELLISu
    # a ze SF3D nemaji stejne meritko). Aby stedrost neslepila detail, jde
    # svar jen pres vrcholy na okraji: uvnitr vysece se nic nehne.
    before = len(bm.verts)
    boundary = [v for v in bm.verts if any(len(e.link_faces) < 2 for e in v.link_edges)]
    if boundary:
        bmesh.ops.remove_doubles(bm, verts=boundary, dist=span * 0.02)
    welded = before - len(bm.verts)

    # Co po svaru zbylo, je uzka trhlina podel svu - zaplnit, at model
    # zustane watertight (jinak kazdy symetricky kus konci na WARN a v
    # renderu je videt prasklina).
    holes = [e for e in bm.edges if len(e.link_faces) < 2]
    if holes:
        bmesh.ops.holes_fill(bm, edges=holes, sides=0)

    bm.to_mesh(obj.data)
    obj.data.update()
    bm.free()
    return welded, tri_count(obj)


def ensure_uv(obj):
    if has_uv(obj):
        return True
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(island_margin=0.02)
    bpy.ops.object.mode_set(mode="OBJECT")
    return has_uv(obj)


def bake_texture(obj, out_png):
    """Diffuse bake pres EMIT: base color kazdeho materialu se prepoji na
    emission, takze bake nepocita svetla - na CPU bezi rychle."""
    img = bpy.data.images.new("bake", BAKE_SIZE, BAKE_SIZE, alpha=False)
    if not obj.data.materials:
        mat = bpy.data.materials.new("Material")
        mat.use_nodes = True
        obj.data.materials.append(mat)
    for mat in obj.data.materials:
        if mat is None or not mat.use_nodes:
            continue
        nt = mat.node_tree
        bsdf = next((n for n in nt.nodes if n.type == "BSDF_PRINCIPLED"), None)
        emit = nt.nodes.new("ShaderNodeEmission")
        out = next(n for n in nt.nodes if n.type == "OUTPUT_MATERIAL")
        if bsdf:
            base = bsdf.inputs["Base Color"]
            if base.links:
                nt.links.new(base.links[0].from_socket, emit.inputs["Color"])
            else:
                emit.inputs["Color"].default_value = base.default_value
        nt.links.new(emit.outputs["Emission"], out.inputs["Surface"])
        tex = nt.nodes.new("ShaderNodeTexImage")
        tex.image = img
        nt.nodes.active = tex

    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 4      # EMIT bake nema sum, staci minimum
    scene.render.bake.margin = 4
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.bake(type="EMIT")
    img.filepath_raw = out_png
    img.file_format = "PNG"
    img.save()


def fit_and_orient(obj, bbox_studs):
    """Scale do bbox kategorie a origin do stredu. Roblox pri FBX importu
    cte +Z up / -Y forward konvenci exporteru (axis overeno testovacim
    meshem ve Studiu - viz README)."""
    bpy.ops.object.origin_set(type="ORIGIN_CENTER_OF_VOLUME", center="MEDIAN")
    obj.location = (0, 0, 0)
    dims = obj.dimensions
    if max(dims) == 0:
        raise RuntimeError("degenerovany mesh (nulove rozmery)")
    # bbox_studs je [X, Y(up), Z]; Blender ma Z up -> preusporadat
    limits = (bbox_studs[0], bbox_studs[2], bbox_studs[1])
    scale = min(l / d for l, d in zip(limits, dims) if d > 0)
    obj.scale = (scale, scale, scale)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)


def add_attachment(obj, name):
    att = bpy.data.objects.new(name + "_Att", None)
    att.empty_display_type = "PLAIN_AXES"
    att.empty_display_size = 0.1
    att.parent = obj
    bpy.context.scene.collection.objects.link(att)
    return att


def export_fbx(path):
    bpy.ops.export_scene.fbx(
        filepath=path,
        use_selection=False,
        apply_scale_options="FBX_SCALE_ALL",
        axis_up="Z",
        axis_forward="-Y",
        path_mode="STRIP",   # textura zvlast, embed OFF
        embed_textures=False,
    )


def open_edge_count(obj):
    """Hrany bez druhe steny. Nula = watertight; male cislo u symetrickeho
    kusu znamena zbytkovou trhlinu na svu, ne rozpadly mesh."""
    import bmesh
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    n = sum(1 for e in bm.edges if len(e.link_faces) < 2)
    bm.free()
    return n


def main():
    args = parse_args()
    with open(args.job) as f:
        job = json.load(f)
    with open(job["spec"]) as f:
        spec_all = json.load(f)
    category = job["category"]
    spec = spec_all["categories"].get(category)
    if spec is None:
        raise RuntimeError(f"neznama kategorie {category!r}")

    out_dir = job["out_dir"]
    os.makedirs(out_dir, exist_ok=True)

    reset_scene()
    obj = import_glb(job["glb"])
    cleanup(obj)
    tris, components, floaters_removed = retopo(obj, job.get("backend", ""), spec["max_tris"])
    symmetry = job.get("symmetry") or ""
    seam_verts = 0
    if symmetry == "radial":
        seam_verts, tris = radial_symmetrize(obj)
        # Rezy pridaji hrany, takze trojice vyseci cil o kus prestreli.
        if tris > spec["max_tris"]:
            tris = decimate_to(obj, int(spec["max_tris"] * DECIMATE_TARGET_FRACTION))
        print("radial symmetry: %d sectors, %d verts welded, %d tris"
              % (RADIAL_SECTORS, seam_verts, tris), flush=True)
    uv_ok = ensure_uv(obj)
    tex_path = os.path.join(out_dir, "model_tex.png")
    bake_texture(obj, tex_path)
    # bbox_studs je strop, ne cil - skaluje se na target_studs (viz _notes2
    # ve spec/roblox_spec.json). Job smi poslat vlastni a prebit kategorii.
    target = job.get("target_studs") or spec.get("target_studs") or spec["bbox_studs"]
    fit_and_orient(obj, target)
    add_attachment(obj, spec["attachment"])
    fbx_path = os.path.join(out_dir, "model.fbx")
    export_fbx(fbx_path)

    open_edges = open_edge_count(obj)
    report = {
        "tri_count": tris,
        "max_tris": spec["max_tris"],
        "uv_ok": uv_ok,
        "texture_size": BAKE_SIZE,
        "bbox": [round(d, 4) for d in obj.dimensions],
        "bbox_limit_studs": spec["bbox_studs"],
        "bbox_target_studs": target,
        "bbox_within_limit": all(
            d <= l + 1e-3 for d, l in zip(obj.dimensions, (spec["bbox_studs"][0], spec["bbox_studs"][2], spec["bbox_studs"][1]))
        ),
        "watertight": open_edges == 0,
        "open_edges": open_edges,
        "components": components,
        "floater_faces_removed": floaters_removed,
        "symmetry": symmetry,
        "symmetry_seam_verts": seam_verts,
        "material_count": len(obj.data.materials),
        "attachment": spec["attachment"],
        "fbx": os.path.basename(fbx_path),
        "texture": os.path.basename(tex_path),
    }
    with open(os.path.join(out_dir, "report.json"), "w") as f:
        json.dump(report, f, indent=2)
    print("CONVERT_OK", json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:  # worker cte stderr, nenechat blender spolknout
        print(f"CONVERT_FAIL {e}", file=sys.stderr)
        sys.exit(1)
