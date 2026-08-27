"""Nahledy zkonvertovaneho kusu z orbity - kontrola zadni strany.

    blender -b -P render_views.py -- --dir /data/converted/<id> [--angles 0,180]

Konverze konci FBX + PNG texturou, ktere zadny prohlizec v appce neukaze
(triage vidi jen vstupni GLB). Bez tohohle skriptu tedy nejde overit prave
to, kvuli cemu symetrie vznikla: jak vypada model zezadu.

Sviti se EMIT z bake textury - stejny model osvetleni jako bake, takze
render ukazuje zdobeni, ne stiny.
"""
import argparse
import math
import os
import sys

import bpy
from mathutils import Matrix, Vector

RESOLUTION = 720
SAMPLES = 16


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True, help="slozka s model.fbx + model_tex.png")
    ap.add_argument("--angles", default="0,180", help="stupne kolem osy Z (0 = zepredu)")
    ap.add_argument("--elevation", type=float, default=15.0)
    ap.add_argument("--out-prefix", default="view")
    return ap.parse_args(argv)


def load(fbx_path, tex_path):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=fbx_path)
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    if not meshes:
        raise RuntimeError("FBX neobsahuje mesh")
    obj = meshes[0]
    mat = bpy.data.materials.new("preview")
    mat.use_nodes = True
    nt = mat.node_tree
    nt.nodes.clear()
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    emit = nt.nodes.new("ShaderNodeEmission")
    nt.links.new(emit.outputs["Emission"], out.inputs["Surface"])
    if os.path.exists(tex_path):
        tex = nt.nodes.new("ShaderNodeTexImage")
        tex.image = bpy.data.images.load(tex_path)
        nt.links.new(tex.outputs["Color"], emit.inputs["Color"])
    else:
        emit.inputs["Color"].default_value = (0.8, 0.8, 0.8, 1.0)
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    return obj


def setup_scene():
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = SAMPLES
    scene.render.resolution_x = scene.render.resolution_y = RESOLUTION
    scene.render.image_settings.file_format = "PNG"
    world = bpy.data.worlds.new("bg")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs[0].default_value = (0.12, 0.12, 0.14, 1)
    scene.world = world
    cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam"))
    scene.collection.objects.link(cam)
    scene.camera = cam
    return scene, cam


def main():
    args = parse_args()
    obj = load(os.path.join(args.dir, "model.fbx"),
               os.path.join(args.dir, "model_tex.png"))
    scene, cam = setup_scene()

    corners = [obj.matrix_world @ Vector(c) for c in obj.bound_box]
    center = sum(corners, Vector()) / 8.0
    radius = max(obj.dimensions) * 2.4

    for deg in [float(a) for a in args.angles.split(",")]:
        # 0 stupnu = pohled zepredu, tedy z +Y - to je strana, kterou model
        # videl (viz FRONT_ANGLE v convert.py). 180 je domyslena zada.
        offset = Matrix.Rotation(math.radians(deg), 4, "Z") @ Vector(
            (0.0, radius, radius * math.tan(math.radians(args.elevation))))
        cam.location = center + offset
        cam.rotation_euler = (center - cam.location).to_track_quat("-Z", "Y").to_euler()
        path = os.path.join(args.dir, "%s_%03d.png" % (args.out_prefix, int(deg)))
        scene.render.filepath = path
        bpy.ops.render.render(write_still=True)
        print("RENDER_OK " + path, flush=True)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("RENDER_FAIL %s" % e, file=sys.stderr)
        sys.exit(1)
