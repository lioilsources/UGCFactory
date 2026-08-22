"""Vygeneruje referencni GLB pro golden test - texturovana ico-sphere
(~1280 tris, bez UV schvalne: convert musi UV doplnit). Bezi v containeru:
    blender -b --factory-startup -P gen_reference.py -- /data/ref.glb
"""
import sys

import bpy

out = sys.argv[sys.argv.index("--") + 1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=1)
obj = bpy.context.active_object
mat = bpy.data.materials.new("RefMat")
mat.use_nodes = True
bsdf = next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
bsdf.inputs["Base Color"].default_value = (0.8, 0.2, 0.1, 1)
obj.data.materials.append(mat)
# UV vrstvu odstranit, at golden test overi Smart UV Project vetev
for uv in list(obj.data.uv_layers):
    obj.data.uv_layers.remove(uv)
bpy.ops.export_scene.gltf(filepath=out, export_format="GLB")
print("REF_OK", out)
