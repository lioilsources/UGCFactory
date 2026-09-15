"""FBX z MIA (ComfyUI na Sparku) -> rigged.fbx ve stejnem tvaru jako ze sablony.

    blender -b -P fc_rig_mia.py -- --job /data/jobs/<id>.json

Job JSON: {"id", "fbx": surovy vystup MIA, "clean_glb": clean.glb, "out_dir"}

MIA ma naucene vahy, a proto deformuje lip nez sablona s heat map: na
foto postave (bea877, Zombie Walk) prumerne natazeni hran 1,19 proti 1,33 a
paze jdou dopredu jako v referenci, misto aby odletaly do stran
(zmereno 2026-09-15). Jeji vystup ale neni primo pouzitelny:

- Mesh si normalizuje: vyska 2 jednotky, stred v pocatku. Cleanup, Luanti
  i Roblox pocitaji s 1.8 m a chodidly na zemi, takze se rig vrati do
  rozmeru clean.glb, ze ktereho vznikl.
- Cast vrcholu zustane bez vahy - u bea877 1453 z 21598, v rukou u boku a
  ve vlasovych drdolech. Nezavazany vrchol pri animaci stoji na miste a
  mesh se k nemu natahuje (nejhorsi hrana 75x). Dostanou vahy nejblizsiho
  vazeneho vrcholu (pak 18,7x).
- Vah na vrchol je az 8, Roblox bere 4 - omezi se tady, stejne jako u sablony.
- Material je pruhledny; bere se nepruhledny z clean.glb (import_reference).
"""
import argparse
import json
import os
import sys

import bpy
from mathutils import Matrix, Vector, kdtree

MAX_WEIGHTS = 4
WEIGHT_EPS = 0.0001
# Kdyz je bez vahy vic nez tolik vrcholu, MIA nejspis tise sklouzla na
# geometricky fallback (chybejici checkpointy, viz README) - ma to byt videt.
UNWEIGHTED_WARN = 0.25


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--job", required=True)
    return ap.parse_args(argv)


def world_bbox(objs):
    pts = [o.matrix_world @ v.co for o in objs for v in o.data.vertices]
    if not pts:
        raise RuntimeError("mesh nema vrcholy")
    lo = Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
    hi = Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    return lo, hi


def import_reference(glb):
    """Rozmery a material z clean.glb. Objekty se hned smazou, material zustane.

    Material z MIA FBX nese pruhlednost: postava v renderu i v model.glb vysla
    napul pruhledna (2026-09-15). glTF import clean.glb dava nepruhledny
    material se stejnou texturou a UV se v MIA meshi zachovavaji, takze se
    prevezme tenhle."""
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=glb)
    added = [o for o in bpy.context.scene.objects if o not in before]
    meshes = [o for o in added if o.type == "MESH"]
    if not meshes:
        raise RuntimeError("clean.glb neobsahuje mesh")
    lo, hi = world_bbox(meshes)
    materials = [slot.material for slot in meshes[0].material_slots if slot.material]
    for mat in materials:
        mat.use_fake_user = True
    for o in added:
        bpy.data.objects.remove(o, do_unlink=True)
    return lo, hi, materials


def use_materials(meshes, materials):
    for mesh in meshes:
        mesh.data.materials.clear()
        for mat in materials:
            mesh.data.materials.append(mat)
        for poly in mesh.data.polygons:
            poly.material_index = 0


def fit_to(arm, meshes, ref_lo, ref_hi):
    """Srovna rig na rozmery clean.glb: stejna vyska, stred v x/y, chodidla na
    stejne vysce. Transformace se aplikuje, at FBX nese jednotkove matice
    jako rig ze sablony."""
    lo, hi = world_bbox(meshes)
    height = hi.z - lo.z
    if height <= 0:
        raise RuntimeError("MIA mesh ma nulovou vysku")
    scale = (ref_hi.z - ref_lo.z) / height
    ref_center = Vector(((ref_lo.x + ref_hi.x) / 2, (ref_lo.y + ref_hi.y) / 2, ref_lo.z))
    center = Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
    fit = Matrix.Translation(ref_center) @ Matrix.Scale(scale, 4) @ Matrix.Translation(-center)

    roots = {o for o in [arm] + meshes if o.parent is None}
    for o in roots:
        o.matrix_world = fit @ o.matrix_world
    bpy.ops.object.select_all(action="DESELECT")
    for o in [arm] + meshes:
        o.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return scale


def fill_weights(mesh):
    """Vrcholy bez vahy dostanou vahy nejblizsiho vazeneho vrcholu."""
    verts = mesh.data.vertices
    weighted = [v.index for v in verts if any(g.weight > WEIGHT_EPS for g in v.groups)]
    have = set(weighted)
    empty = [v.index for v in verts if v.index not in have]
    if not weighted or not empty:
        return len(empty)
    tree = kdtree.KDTree(len(weighted))
    for n, i in enumerate(weighted):
        tree.insert(verts[i].co, n)
    tree.balance()
    for i in empty:
        _co, n, _dist = tree.find(verts[i].co)
        for g in verts[weighted[n]].groups:
            if g.weight > WEIGHT_EPS:
                mesh.vertex_groups[g.group].add([i], g.weight, "REPLACE")
    return len(empty)


def limit_weights(mesh):
    # Limit Total pracuje jen na vybranem objektu; bez vyberu tise nic neudela
    # (stejna past jako v fc_roblox_pack.py).
    bpy.ops.object.select_all(action="DESELECT")
    mesh.select_set(True)
    bpy.context.view_layer.objects.active = mesh
    bpy.ops.object.vertex_group_limit_total(limit=MAX_WEIGHTS)
    bpy.ops.object.vertex_group_normalize_all(lock_active=False)


def count_unweighted(mesh):
    return sum(1 for v in mesh.data.vertices if not any(g.weight > WEIGHT_EPS for g in v.groups))


def max_influences(mesh):
    return max((sum(1 for g in v.groups if g.weight > WEIGHT_EPS) for v in mesh.data.vertices),
               default=0)


def main():
    args = parse_args()
    with open(args.job) as f:
        job = json.load(f)
    out_dir = job["out_dir"]
    os.makedirs(out_dir, exist_ok=True)

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=job["fbx"])
    arms = [o for o in bpy.context.scene.objects if o.type == "ARMATURE"]
    if len(arms) != 1:
        raise RuntimeError(f"MIA FBX ma {len(arms)} armatur, cekam 1")
    arm = arms[0]
    meshes = [o for o in bpy.context.scene.objects
              if o.type == "MESH" and any(m.type == "ARMATURE" for m in o.modifiers)]
    if not meshes:
        raise RuntimeError("MIA FBX nema mesh navazany na kostru")
    if not any(b.name.startswith("mixamorig:") for b in arm.data.bones):
        raise RuntimeError("MIA kostra nema mixamorig: kosti")

    ref_lo, ref_hi, materials = import_reference(job["clean_glb"])
    if materials:
        use_materials(meshes, materials)
    scale = fit_to(arm, meshes, ref_lo, ref_hi)
    verts = sum(len(m.data.vertices) for m in meshes)
    unweighted_before = sum(count_unweighted(m) for m in meshes)
    filled = sum(fill_weights(m) for m in meshes)
    for m in meshes:
        limit_weights(m)

    warnings = []
    if verts and unweighted_before / verts > UNWEIGHTED_WARN:
        warnings.append(f"{unweighted_before} z {verts} vrcholu bez vahy - MIA fallback?")

    fbx = os.path.join(out_dir, "rigged.fbx")
    bpy.ops.export_scene.fbx(filepath=fbx, use_selection=False, add_leaf_bones=False,
                             bake_anim=False, path_mode="COPY", embed_textures=False)
    lo, hi = world_bbox(meshes)
    report = {
        "fbx": os.path.basename(fbx),
        "bones": len(arm.data.bones),
        "weights": "mia",
        "vert_count": verts,
        "unweighted_before_fill": unweighted_before,
        "weights_filled": filled,
        "unweighted_verts": sum(count_unweighted(m) for m in meshes),
        "max_influences": max(max_influences(m) for m in meshes),
        "mia_scale": round(scale, 4),
        "height_m": round(hi.z - lo.z, 4),
        "floor_z": round(lo.z, 4),
        "fit_warnings": warnings,
    }
    with open(os.path.join(out_dir, "rig_report.json"), "w") as f:
        json.dump(report, f, indent=2)
    print("FC_RIG_OK", json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"FC_RIG_FAIL {e}", file=sys.stderr)
        sys.exit(1)
