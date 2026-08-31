"""Vygeneruje fixture pro FC pipeline: rigovane FBX s mixamorig: kostrou a
dva klipy. Bezi v ugc-blender containeru:

    blender -b --factory-startup -P gen_fc_fixture.py -- /w/fixture

Klip 'walk_cm' je schvalne ve 100x meritku, aby otestoval prepocet translaci -
Mixamo exportuje 'Without Skin' v centimetrech, zatimco rig z pipeline je v
metrech, a bez prepoctu by postava pri chuzi odletela pryc.
"""
import os
import sys

import bpy
from mathutils import Vector

out_dir = sys.argv[sys.argv.index("--") + 1]
os.makedirs(out_dir, exist_ok=True)

# (jmeno, head, tail, rodic) - zjednodusena Mixamo kostra
BONES = [
    ("mixamorig:Hips", (0, 0, 1.0), (0, 0, 1.2), None),
    ("mixamorig:Spine", (0, 0, 1.2), (0, 0, 1.5), "mixamorig:Hips"),
    ("mixamorig:Head", (0, 0, 1.5), (0, 0, 1.75), "mixamorig:Spine"),
    ("mixamorig:LeftUpLeg", (0.1, 0, 1.0), (0.1, 0, 0.5), "mixamorig:Hips"),
    ("mixamorig:LeftLeg", (0.1, 0, 0.5), (0.1, 0, 0.05), "mixamorig:LeftUpLeg"),
    ("mixamorig:RightUpLeg", (-0.1, 0, 1.0), (-0.1, 0, 0.5), "mixamorig:Hips"),
    ("mixamorig:RightLeg", (-0.1, 0, 0.5), (-0.1, 0, 0.05), "mixamorig:RightUpLeg"),
]


def build_armature():
    bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
    arm = bpy.context.object
    arm.name = "Armature"
    eb = arm.data.edit_bones
    for b in list(eb):
        eb.remove(b)
    for name, head, tail, parent in BONES:
        bone = eb.new(name)
        bone.head, bone.tail = Vector(head), Vector(tail)
        if parent:
            bone.parent = eb[parent]
            bone.use_connect = False
    bpy.ops.object.mode_set(mode="OBJECT")
    return arm


def build_body(arm):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.9))
    body = bpy.context.object
    body.name = "Body"
    body.scale = (0.25, 0.15, 0.9)
    bpy.ops.object.transform_apply(scale=True)
    mat = bpy.data.materials.new("Body")
    mat.use_nodes = True
    body.data.materials.append(mat)
    bpy.ops.object.select_all(action="DESELECT")
    body.select_set(True)
    arm.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.parent_set(type="ARMATURE_AUTO")
    return body


def keyframe_clip(arm, name, frames, amplitude):
    """Jednoducha animace: rotace nohou + posun boku, aby mel klip co
    prenaset (a aby bylo videt, kdyz se translace neprepocita)."""
    arm.animation_data_create()
    action = bpy.data.actions.new(name)
    arm.animation_data.action = action
    hips = arm.pose.bones["mixamorig:Hips"]
    left = arm.pose.bones["mixamorig:LeftUpLeg"]
    right = arm.pose.bones["mixamorig:RightUpLeg"]
    for f in range(1, frames + 1):
        phase = (f - 1) / max(frames - 1, 1)
        left.rotation_mode = right.rotation_mode = "XYZ"
        left.rotation_euler = (amplitude * phase, 0, 0)
        right.rotation_euler = (-amplitude * phase, 0, 0)
        hips.location = (0, 0, 0.05 * phase)
        for pb in (hips, left, right):
            pb.keyframe_insert("location", frame=f)
            pb.keyframe_insert("rotation_euler", frame=f)
    return action


def export_fbx(path, scale=1.0):
    if scale != 1.0:
        for o in bpy.context.scene.objects:
            o.scale = (scale, scale, scale)
        bpy.ops.object.select_all(action="SELECT")
        bpy.ops.object.transform_apply(scale=True)
    bpy.ops.export_scene.fbx(filepath=path, use_selection=False,
                             add_leaf_bones=False, bake_anim=True)


def fresh():
    bpy.ops.wm.read_factory_settings(use_empty=True)


# 1) rigovana postava (bez animace) - vystup 'char.rig'
fresh()
arm = build_armature()
build_body(arm)
export_fbx(os.path.join(out_dir, "rigged.fbx"))

# 2) klip v metrech
fresh()
arm = build_armature()
keyframe_clip(arm, "idle_01", 20, 0.2)
export_fbx(os.path.join(out_dir, "idle_01.fbx"))

# 3) klip v centimetrech (jako Mixamo)
fresh()
arm = build_armature()
keyframe_clip(arm, "walk_cm", 30, 0.6)
export_fbx(os.path.join(out_dir, "walk_cm.fbx"), scale=100.0)

print("FIXTURE_OK", out_dir)
