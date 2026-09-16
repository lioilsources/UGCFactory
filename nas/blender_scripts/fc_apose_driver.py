"""Blender: vyrenderuje Mixamo Y-bota (mesh z animlib FBX) v A-poze. Pazi se
natoci z T-pozy dolu na ARM_DEG od svisle osy, stehna mirne od sebe. Osa
rotace se hleda empiricky (u kazde kosti vyzkousi X/Y/Z +-, vezme tu, ktera
da paze v celni rovine).

Je to prvni krok receptu na worker/assets/apose_driver.png (ridici fotka
pro Wan Animate, fc_pose.repose_graph): samotna figurina jako driver
nefunguje - ViTPose ji prohazuje nohy (plan sekce 15) - takze se z jeji
DWPose kostry (bbox_detector "None") pres FLUX dev + ControlNet Union Pro 2
(strength 0.7, end 0.6, 768x1344, seed 11) udela fotka cloveka ve stejne
poze. Spoustet v kontejneru ugc-fc, kde je animlib:

  blender -b --factory-startup -noaudio -P fc_apose_driver.py -- \
      --fbx "/data/animlib/Zombie Walk.fbx" --out /tmp/ybot_apose.png
"""
import math
import sys

import bpy
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:]
FBX = argv[argv.index("--fbx") + 1]
OUT = argv[argv.index("--out") + 1]
ARM_DEG = float(argv[argv.index("--arm") + 1]) if "--arm" in argv else 45.0
LEG_DEG = float(argv[argv.index("--leg") + 1]) if "--leg" in argv else 8.0
W, H = 480, 832

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=FBX)
for o in list(bpy.data.objects):
    if o.type == "MESH" and o.name.startswith("Cube"):
        bpy.data.objects.remove(o)
arm = next(o for o in bpy.data.objects if o.type == "ARMATURE")
arm.animation_data_clear()
for pb in arm.pose.bones:
    pb.rotation_mode = "XYZ"
    pb.rotation_euler = (0, 0, 0)
    pb.location = (0, 0, 0)
bpy.context.view_layer.update()


def bone_dir(name):
    pb = arm.pose.bones[name]
    return (arm.matrix_world @ pb.tail - arm.matrix_world @ pb.head).normalized()


def angle_from_down(d):
    return math.degrees(math.acos(max(-1.0, min(1.0, d.dot(Vector((0, 0, -1)))))))


def aim(name, target_deg, side_sign):
    """Najde osu a znamenko, ktere kost otoci v celni rovine (XZ) k target_deg
    od svisle osy smerem ven (side_sign = znamenko X strany tela)."""
    pb = arm.pose.bones[name]
    best = None
    for axis in range(3):
        for sign in (1, -1):
            for deg in range(0, 181, 5):
                rot = [0, 0, 0]
                rot[axis] = math.radians(sign * deg)
                pb.rotation_euler = rot
                bpy.context.view_layer.update()
                d = bone_dir(name)
                err = abs(angle_from_down(d) - target_deg) + 2 * abs(d.y) * 90 + (0 if d.x * side_sign >= 0 else 90)
                if best is None or err < best[0]:
                    best = (err, tuple(rot), round(angle_from_down(d), 1), round(d.y, 2))
    pb.rotation_euler = best[1]
    bpy.context.view_layer.update()
    print(f"AIM {name}: angle={best[2]} y={best[3]} rot={[round(math.degrees(r)) for r in best[1]]}")


pref = "mixamorig:" if "mixamorig:LeftArm" in arm.pose.bones else ""
# strany: v celnim pohledu (kamera z -Y) je leva ruka postavy na +X
lx = (arm.matrix_world @ arm.pose.bones[pref + "LeftArm"].head).x
sx = 1 if lx >= 0 else -1
aim(pref + "LeftArm", ARM_DEG, sx)
aim(pref + "RightArm", ARM_DEG, -sx)
aim(pref + "LeftUpLeg", LEG_DEG, sx)
aim(pref + "RightUpLeg", LEG_DEG, -sx)
# predlokti a ruce rovne (identita = pokracuji ve smeru pazi)

# --- kamera a render ---------------------------------------------------------
depsgraph = bpy.context.evaluated_depsgraph_get()
lo = Vector((1e9,) * 3)
hi = Vector((-1e9,) * 3)
for o in bpy.data.objects:
    if o.type != "MESH":
        continue
    ev = o.evaluated_get(depsgraph)
    for v in ev.data.vertices:
        p = ev.matrix_world @ v.co
        lo = Vector(map(min, lo, p))
        hi = Vector(map(max, hi, p))
center = (lo + hi) / 2
height = hi.z - lo.z
scene = bpy.context.scene
scene.render.resolution_x, scene.render.resolution_y = W, H
scene.render.engine = "BLENDER_WORKBENCH"
scene.display.shading.light = "STUDIO"
scene.display.shading.color_type = "SINGLE"
scene.display.shading.single_color = (0.55, 0.45, 0.4)
scene.display.shading.background_type = "VIEWPORT"
scene.display.shading.background_color = (0.75, 0.75, 0.75)
scene.render.film_transparent = False
scene.view_settings.view_transform = "Standard"
cam_data = bpy.data.cameras.new("cam")
cam_data.type = "ORTHO"
cam_data.ortho_scale = height * 1.12 * (H / W) if (H / W) < 1 else height * 1.12
cam = bpy.data.objects.new("cam", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
# Mixamo postava po importu FBX kouka do -Y (Blender konvence)
cam.location = (center.x, center.y - 10, center.z)
cam.rotation_euler = (math.radians(90), 0, 0)
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = OUT
bpy.ops.render.render(write_still=True)
print("DRIVER_OK", OUT, "height", round(height, 3))
