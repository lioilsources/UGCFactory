"""animated.blend -> Roblox balicek: FBX <= 10k tris, 4 vahy/vertex, 1024 tex.

    blender -b -P fc_roblox_pack.py -- --job /data/jobs/<id>.json

Job JSON: {"id", "blend", "out_dir", "name"}

Limity hlida Roblox pri importu a odmitne cely model, ne jen preteklou cast -
proto se tady overuji jeste pred exportem a krok radsi selze s cislem v
reportu, nez aby uzivatel dostal zamitnuti ze Studia.
"""
import argparse
import json
import os
import sys

import bpy

MAX_TRIS = 10000
MAX_INFLUENCES = 4
MAX_BONES = 256
TEXTURE_SIZE = 1024


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--job", required=True)
    return ap.parse_args(argv)


def meshes():
    return [o for o in bpy.context.scene.objects if o.type == "MESH"]


def tri_count():
    n = 0
    for o in meshes():
        o.data.calc_loop_triangles()
        n += len(o.data.loop_triangles)
    return n


def decimate_to(max_tris):
    """Decimate az po rigu: vahy prezijou (collapse je prenasi), ale kvalita
    deformace klesa - proto se sahá jen kdyz je opravdu potreba."""
    tris = tri_count()
    if tris <= max_tris:
        return tris
    for o in meshes():
        bpy.context.view_layer.objects.active = o
        mod = o.modifiers.new("Decimate", "DECIMATE")
        mod.ratio = (max_tris * 0.95) / tris
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return tri_count()


def limit_influences(limit):
    """Roblox bere max 4 vahy na vertex; paty a dalsi tise zahodí, cimz se
    mesh pri animaci roztrhne. Limit Total to udela ted a normalizovane."""
    for o in meshes():
        if not o.vertex_groups:
            continue
        bpy.context.view_layer.objects.active = o
        bpy.ops.object.vertex_group_limit_total(limit=limit)
        bpy.ops.object.vertex_group_normalize_all(lock_active=False)


def max_influences():
    worst = 0
    for o in meshes():
        for v in o.data.vertices:
            worst = max(worst, sum(1 for g in v.groups if g.weight > 0.0001))
    return worst


def bone_count():
    return sum(len(o.data.bones) for o in bpy.context.scene.objects if o.type == "ARMATURE")


def resize_textures(size):
    resized = []
    for img in bpy.data.images:
        if img.size[0] > size or img.size[1] > size:
            img.scale(size, size)
            resized.append(img.name)
    return resized


def export_fbx(path):
    bpy.ops.export_scene.fbx(
        filepath=path,
        use_selection=False,
        path_mode="COPY",
        embed_textures=False,
        add_leaf_bones=False,
        bake_anim=True,
        bake_anim_use_nla_strips=True,
        axis_up="Y",
        axis_forward="-Z",
    )


def main():
    args = parse_args()
    with open(args.job) as f:
        job = json.load(f)
    out_dir = job["out_dir"]
    os.makedirs(out_dir, exist_ok=True)
    name = job.get("name") or job["id"]

    bpy.ops.wm.open_mainfile(filepath=job["blend"])
    tris_in = tri_count()
    tris = decimate_to(MAX_TRIS)
    limit_influences(MAX_INFLUENCES)
    resized = resize_textures(TEXTURE_SIZE)

    bones = bone_count()
    influences = max_influences()
    if tris > MAX_TRIS:
        raise RuntimeError(f"tri_count {tris} > {MAX_TRIS} i po decimate")
    if bones > MAX_BONES:
        raise RuntimeError(f"kostra ma {bones} kosti, Roblox bere {MAX_BONES}")
    if influences > MAX_INFLUENCES:
        raise RuntimeError(f"{influences} vah na vertex, limit je {MAX_INFLUENCES}")

    fbx = os.path.join(out_dir, f"{name}.fbx")
    export_fbx(fbx)

    report = {
        "fbx": os.path.basename(fbx), "tri_count_in": tris_in, "tri_count": tris,
        "max_tris": MAX_TRIS, "bones": bones, "max_influences": influences,
        "texture_size": TEXTURE_SIZE, "textures_resized": resized,
    }
    with open(os.path.join(out_dir, "roblox_report.json"), "w") as f:
        json.dump(report, f, indent=2)
    print("FC_ROBLOX_OK", json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"FC_ROBLOX_FAIL {e}", file=sys.stderr)
        sys.exit(1)
