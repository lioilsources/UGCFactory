"""TRELLIS GLB -> uklizeny GLB pripraveny na rig. Bezi headless:

    blender -b -P fc_cleanup.py -- --job /data/jobs/<id>.json

Job JSON: {"id", "glb": in, "out_dir": out, "target": user|roblox|luanti}
Kroky dle FANTASYCHARACTER_PLAN.md 3.3: import, join, cleanup, remesh kdyz
neni manifold, decimate na tri budget, UV, bake do jednoho atlasu, vyska
1.8 m, pivot na spodek bboxu, export GLB.

Pivot patri na spodek, ne do stredu: rig i obe hry stavi postavu na zem a
origin ve stredu objemu znamena, ze se pri spawnu zaboril do pulky do terenu.
"""
import argparse
import json
import os
import sys

import bpy

# Tri budget a atlas per cil (plan 3.3). user = "Blender-ready", zbytek jsou
# limity enginu: Roblox 10k/MeshPart, Luanti bezi na mobilech.
TARGETS = {
    "user":   {"max_tris": 8000, "bake_size": 1024},
    "roblox": {"max_tris": 5000, "bake_size": 1024},
    "luanti": {"max_tris": 2000, "bake_size": 512},
}
TARGET_HEIGHT_M = 1.8
DECIMATE_TARGET_FRACTION = 0.9   # rezerva na triangulaci, stejne jako convert.py
VOXEL_ADAPTIVE_FRACTION = 0.008


# Bake projekci zdroj -> cil. Kratsi paprsek nez u convert.py: postava ma
# vrstvy blizko sebe (plast pres brneni), a kdyz paprsek dolete dal nez je
# tloustka vrstvy, prolete plastem a vezme barvu tela za nim - v plasti pak
# jsou bile smouhy z brneni (zmereno 2026-08-31: pri 15 % vysky smouhy, pri
# 1,5 % ciste). Zvetsovani klece s tim nepohnulo, protoze slo o dolet.
CAGE_EXTRUSION_FRACTION = 0.004
RAY_DISTANCE_FRACTION = 0.015


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
    bpy.ops.object.select_all(action="DESELECT")
    for o in meshes:
        o.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    if len(meshes) > 1:
        bpy.ops.object.join()
    obj = bpy.context.view_layer.objects.active
    obj.name = "Character"
    return obj


def activate(obj):
    """Jediny vybrany a aktivni objekt - bpy.ops se na to spolehaji."""
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def duplicate(obj, name):
    dup = obj.copy()
    dup.data = obj.data.copy()
    dup.name = name
    bpy.context.scene.collection.objects.link(dup)
    return dup


def cleanup(obj):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.remove_doubles(threshold=0.0001)
    bpy.ops.mesh.delete_loose()
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode="OBJECT")


def open_edges(obj):
    import bmesh
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    n = sum(1 for e in bm.edges if len(e.link_faces) < 2)
    bm.free()
    return n


def tri_count(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def remesh_if_open(obj):
    """Auto-rig (MIA i UniRig) chce uzavrenou skorapku - diry v meshi delaji
    vahy, ktere pri animaci trhaji koncetiny. Remeshujeme jen kdyz je mesh
    opravdu deravy, protoze voxel remesh zahodi UV i ostre hrany."""
    if open_edges(obj) == 0:
        return False
    dims = obj.dimensions
    mod = obj.modifiers.new("Remesh", "REMESH")
    mod.mode = "VOXEL"
    mod.voxel_size = max(max(dims) * VOXEL_ADAPTIVE_FRACTION, 0.0005)
    bpy.ops.object.modifier_apply(modifier=mod.name)
    return True


def decimate_to(obj, max_tris):
    """Decimate pocita FACES, budget je v TROJUHELNICICH - proto nejdriv
    triangulace a pak smycka, presne jako v convert.py."""
    mod = obj.modifiers.new("Tri", "TRIANGULATE")
    bpy.ops.object.modifier_apply(modifier=mod.name)
    target = int(max_tris * DECIMATE_TARGET_FRACTION)
    for _ in range(4):
        tris = tri_count(obj)
        if tris <= target:
            break
        mod = obj.modifiers.new("Decimate", "DECIMATE")
        mod.ratio = target / tris
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return tri_count(obj)


def ensure_uv(obj):
    """Decimate i voxel remesh UV rozbijou (remesh je zahodi uplne), takze cil
    dostane cerstvy smart_project. Zdrojovy atlas se pres nej necte - textura
    se projektuje z originalu (bake_atlas)."""
    if obj.data.uv_layers:
        return True
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    # island_margin je v UV jednotkach, ne v procentech ostrůvku: 0.02 znamena
    # 2 % atlasu kolem KAZDEHO ostrova. Voxel remesh vyrobi mesh bez souvislych
    # ploch, takze smart_project nareze tisice ostrůvku - pri 0.02 pak margin
    # sezral skoro cely atlas a z postavy zbyly tecky na cerne (2026-08-31).
    bpy.ops.uv.smart_project(angle_limit=1.15, island_margin=0.001)
    bpy.ops.object.mode_set(mode="OBJECT")
    return bool(obj.data.uv_layers)


def bake_atlas(source, target, out_png, size):
    """Vsechny materialy do jedne textury projekci zdroj -> cil (EMIT bake,
    Selected-to-Active) - Roblox chce 1 material na MeshPart a Luanti jednu
    texturu.

    Drive se peklo primo na decimovanem meshi pres jeho vlastni UV. Decimace
    z 30k na par tisic trojuhelniku ale UV ostrovy rozlame (a remesh je zahodi
    uplne), takze bake cetl puvodni TRELLIS atlas pres cizi souradnice a z
    rytire vysly konfety - overeno 2026-08-31 srovnanim mesh.glb (cisty) a
    clean.glb (rozsypany). Stejna past a stejna oprava jako v convert.py."""
    img = bpy.data.images.new("fc_atlas", size, size, alpha=True)

    for mat in source.data.materials:
        if mat is None or not mat.use_nodes:
            continue
        nt = mat.node_tree
        bsdf = next((n for n in nt.nodes if n.type == "BSDF_PRINCIPLED"), None)
        out = next(n for n in nt.nodes if n.type == "OUTPUT_MATERIAL")
        emit = nt.nodes.new("ShaderNodeEmission")
        if bsdf:
            base = bsdf.inputs["Base Color"]
            if base.links:
                nt.links.new(base.links[0].from_socket, emit.inputs["Color"])
            else:
                emit.inputs["Color"].default_value = base.default_value
        nt.links.new(emit.outputs["Emission"], out.inputs["Surface"])

    mat = bpy.data.materials.new("Character")
    mat.use_nodes = True
    nt = mat.node_tree
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    nt.nodes.active = tex
    bsdf = next((n for n in nt.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf:
        nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    target.data.materials.clear()
    target.data.materials.append(mat)

    size_m = max(source.dimensions)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 4
    # Drobne ostrovy potrebuji siroky prelev, jinak mezi nimi prosvita cerna.
    scene.render.bake.margin = 8
    activate(target)
    source.select_set(True)
    bpy.ops.object.bake(
        type="EMIT", use_selected_to_active=True, use_cage=False,
        cage_extrusion=size_m * CAGE_EXTRUSION_FRACTION,
        max_ray_distance=size_m * RAY_DISTANCE_FRACTION)
    img.filepath_raw = out_png
    img.file_format = "PNG"
    img.save()
    return img


def scale_and_ground(obj, height_m):
    """Vyska na height_m a pivot na spodek bboxu, oboje applied - rig i
    spawner pak pracuji s predvidatelnym meritkem."""
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    dims = obj.dimensions
    if dims.z <= 0:
        raise RuntimeError("degenerovany mesh (nulova vyska)")
    obj.scale = (height_m / dims.z,) * 3
    bpy.ops.object.transform_apply(scale=True)

    # spodek bboxu ve world space -> posunout na z=0 a zapect
    zs = [(obj.matrix_world @ v.co).z for v in obj.data.vertices]
    obj.location.z -= min(zs)
    obj.location.x, obj.location.y = 0.0, 0.0
    bpy.ops.object.transform_apply(location=True)
    bpy.ops.object.origin_set(type="ORIGIN_CURSOR")  # 3D kurzor je v (0,0,0)


def export_glb(path):
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format="GLB",
        export_materials="EXPORT",
        export_apply=True,
    )


def main():
    args = parse_args()
    with open(args.job) as f:
        job = json.load(f)
    target = job.get("target", "user")
    if target not in TARGETS:
        raise RuntimeError(f"neznamy target {target!r}")
    budget = TARGETS[target]

    out_dir = job["out_dir"]
    os.makedirs(out_dir, exist_ok=True)

    reset_scene()
    source = import_glb(job["glb"])
    tris_in = tri_count(source)
    cleanup(source)
    source.name = "CharacterSource"
    obj = duplicate(source, "Character")
    # remesh i decimate jedou pres modifier_apply, ktery bere AKTIVNI objekt -
    # bez tohohle by se pouzily na zdroj a cil zustal neztenceny.
    activate(obj)
    remeshed = remesh_if_open(obj)
    tris = decimate_to(obj, budget["max_tris"])
    uv_ok = ensure_uv(obj)
    atlas_path = os.path.join(out_dir, "clean_tex.png")
    bake_atlas(source, obj, atlas_path, budget["bake_size"])
    # Zdroj do GLB nesmi - export bere celou scenu.
    bpy.data.objects.remove(source, do_unlink=True)
    activate(obj)
    scale_and_ground(obj, TARGET_HEIGHT_M)
    glb_path = os.path.join(out_dir, "clean.glb")
    export_glb(glb_path)

    report = {
        "tri_count_in": tris_in,
        "tri_count": tris,
        "max_tris": budget["max_tris"],
        "remeshed": remeshed,
        "uv_ok": uv_ok,
        "texture_size": budget["bake_size"],
        "open_edges": open_edges(obj),
        "height_m": round(obj.dimensions.z, 4),
        "material_count": len(obj.data.materials),
        "glb": os.path.basename(glb_path),
        "texture": os.path.basename(atlas_path),
    }
    with open(os.path.join(out_dir, "cleanup_report.json"), "w") as f:
        json.dump(report, f, indent=2)
    print("FC_CLEANUP_OK", json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"FC_CLEANUP_FAIL {e}", file=sys.stderr)
        sys.exit(1)
