"""animated.blend -> Luanti balicek: GLB 2k tris, 512 PNG, anim_ranges.lua.

    blender -b -P fc_luanti_pack.py -- --job /data/jobs/<id>.json

Job JSON: {"id", "blend", "out_dir", "name", "ranges": {clip: [start, end]}}

Luanti (>= 5.10) umi GLB se skeletalni animaci nativne, ale prepina klipy jen
frame rozsahem pres set_animation({x=,y=}) - zadna jmena. Proto se vedle
modelu generuje Lua tabulka s rozsahy, ktere spocital fc_retarget.py.
Rozpocet je mobilni: 2k tris a 512 textura.
"""
import argparse
import json
import os
import sys

import bpy

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fc_ranges import write_ranges_lua  # noqa: E402  (bez bpy, testovatelne v CI)

MAX_TRIS = 2000
TEXTURE_SIZE = 512


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
    tris = tri_count()
    if tris <= max_tris:
        return tris
    for o in meshes():
        bpy.context.view_layer.objects.active = o
        mod = o.modifiers.new("Decimate", "DECIMATE")
        mod.ratio = (max_tris * 0.95) / tris
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return tri_count()


def save_texture(out_png, size):
    """Luanti chce texturu jako samostatny soubor v textures/, ne zapecenou
    v GLB - jinak ji nenajde a mob je bily."""
    imgs = [i for i in bpy.data.images if i.has_data and i.size[0] > 0]
    if not imgs:
        return ""
    img = max(imgs, key=lambda i: i.size[0] * i.size[1])
    if img.size[0] > size or img.size[1] > size:
        img.scale(size, size)
    img.filepath_raw = out_png
    img.file_format = "PNG"
    img.save()
    return os.path.basename(out_png)


def export_glb(path):
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format="GLB",
        export_skins=True,
        export_animations=True,
        export_apply=False,
    )


def main():
    args = parse_args()
    with open(args.job) as f:
        job = json.load(f)
    out_dir = job["out_dir"]
    os.makedirs(out_dir, exist_ok=True)
    slug = job.get("name") or job["id"]
    ranges = job.get("ranges") or {}

    bpy.ops.wm.open_mainfile(filepath=job["blend"])
    tris_in = tri_count()
    tris = decimate_to(MAX_TRIS)
    glb = os.path.join(out_dir, f"fc_{slug}.glb")
    export_glb(glb)
    tex = save_texture(os.path.join(out_dir, f"fc_{slug}.png"), TEXTURE_SIZE)
    lua = os.path.join(out_dir, "anim_ranges.lua")
    write_ranges_lua(lua, slug, ranges)

    report = {
        "glb": os.path.basename(glb), "texture": tex,
        "anim_ranges": os.path.basename(lua), "clips": len(ranges),
        "tri_count_in": tris_in, "tri_count": tris, "max_tris": MAX_TRIS,
        "texture_size": TEXTURE_SIZE,
    }
    with open(os.path.join(out_dir, "luanti_report.json"), "w") as f:
        json.dump(report, f, indent=2)
    print("FC_LUANTI_OK", json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"FC_LUANTI_FAIL {e}", file=sys.stderr)
        sys.exit(1)
