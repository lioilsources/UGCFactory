"""Vygeneruje jednoduchou humanoidni postavu jako GLB pro test sablonoveho rigu.

    blender -b --factory-startup -P gen_humanoid.py -- /w/humanoid.glb

Neni to model z pipeline, ale ma to, na cem sablona stoji: hlavu, trup, dve
ruce podel tela a dve nohy s mezerou mezi nimi. Vysoke presne 1.8 m, spodek
na z=0 - stejne, jak to nechava fc_cleanup.py.
"""
import sys

import bpy

out = sys.argv[sys.argv.index("--") + 1]
bpy.ops.wm.read_factory_settings(use_empty=True)

H = 1.8
parts = [
    # (jmeno, rozmery xyz, stred)
    ("torso", (0.34, 0.20, 0.52), (0, 0, H * 0.66)),
    ("head", (0.20, 0.20, 0.24), (0, 0, H * 0.91)),
    ("neck", (0.09, 0.09, 0.06), (0, 0, H * 0.80)),
    ("arm_l", (0.10, 0.10, 0.60), (0.24, 0, H * 0.62)),
    ("arm_r", (0.10, 0.10, 0.60), (-0.24, 0, H * 0.62)),
    ("leg_l", (0.14, 0.14, 0.92), (0.11, 0, H * 0.26)),
    ("leg_r", (0.14, 0.14, 0.92), (-0.11, 0, H * 0.26)),
    ("foot_l", (0.14, 0.26, 0.08), (0.11, -0.05, 0.04)),
    ("foot_r", (0.14, 0.26, 0.08), (-0.11, -0.05, 0.04)),
]
objs = []
for name, size, center in parts:
    bpy.ops.mesh.primitive_cube_add(size=1, location=center)
    o = bpy.context.object
    o.name = name
    o.scale = (size[0], size[1], size[2])
    bpy.ops.object.transform_apply(scale=True)
    objs.append(o)

bpy.ops.object.select_all(action="DESELECT")
for o in objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = objs[0]
bpy.ops.object.join()
body = bpy.context.object
body.name = "Character"

# Zhustit sit: mereni po vyskovych rezech potrebuje vrcholy i mimo rohy, a
# skutecny mesh z TRELLIS jich ma tisice. Bez toho test proveri jen fallbacky.
mod = body.modifiers.new("Subd", "SUBSURF")
mod.subdivision_type = "SIMPLE"
mod.levels = mod.render_levels = 3
bpy.ops.object.modifier_apply(modifier=mod.name)

mat = bpy.data.materials.new("Skin")
mat.use_nodes = True
body.data.materials.append(mat)

# posadit spodek presne na z=0, jako to dela cleanup
zs = [(body.matrix_world @ v.co).z for v in body.data.vertices]
body.location.z -= min(zs)
bpy.ops.object.transform_apply(location=True)

bpy.ops.export_scene.gltf(filepath=out, export_format="GLB")
print("HUMANOID_OK", out, "vyska", round(body.dimensions.z, 3))
