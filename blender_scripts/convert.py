"""GLB -> Roblox-ready FBX. Bezi headless v ugc-blender containeru:

    blender -b -P convert.py -- --job /data/jobs/<id>.json

Job JSON: {"id", "category", "backend", "glb": in, "out_dir": out, "spec": path}
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


def tri_count(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def has_uv(obj):
    return bool(obj.data.uv_layers)


def retopo(obj, backend, max_tris):
    """SF3D uz je low-poly s UV -> jen pripadny decimate. Jinak voxel remesh
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

    mod = obj.modifiers.new("Tri", "TRIANGULATE")
    bpy.ops.object.modifier_apply(modifier=mod.name)

    for _ in range(4):
        tris = tri_count(obj)
        if tris <= target:
            break
        mod = obj.modifiers.new("Decimate", "DECIMATE")
        mod.ratio = target / tris
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return tri_count(obj)


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


def watertight(obj):
    import bmesh
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    open_edges = sum(1 for e in bm.edges if len(e.link_faces) < 2)
    bm.free()
    return open_edges == 0


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
    tris = retopo(obj, job.get("backend", ""), spec["max_tris"])
    uv_ok = ensure_uv(obj)
    tex_path = os.path.join(out_dir, "model_tex.png")
    bake_texture(obj, tex_path)
    fit_and_orient(obj, spec["bbox_studs"])
    add_attachment(obj, spec["attachment"])
    fbx_path = os.path.join(out_dir, "model.fbx")
    export_fbx(fbx_path)

    report = {
        "tri_count": tris,
        "max_tris": spec["max_tris"],
        "uv_ok": uv_ok,
        "texture_size": BAKE_SIZE,
        "bbox": [round(d, 4) for d in obj.dimensions],
        "bbox_limit_studs": spec["bbox_studs"],
        "watertight": watertight(obj),
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
