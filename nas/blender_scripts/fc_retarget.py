"""Rigovane FBX + N Mixamo klipu -> jedna armatura s pojmenovanymi klipy.

    blender -b -P fc_retarget.py -- --job /data/jobs/<id>.json

Job JSON: {"id", "rigged_fbx", "out_dir", "clips": [{"id","fbx_path"}, ...]}

Retarget addon netreba: MIA i UniRig davaji Mixamo kostru, takze nazvy kosti
sedi a staci prekopirovat Action.

Translace se ZAMERNE neprepocitava. Merenim na fixture s klipem ve 100x
meritku (testdata/gen_fc_fixture.py) vyslo, ze FBX import translacni kanaly
uz normalizuje sam - automaticka korekce podle vysky kostry je zkorigovala
podruhe a klip skoncil presne 100x mimo. Pomer vysek se proto jen mericky
hlasi v reportu jako height_ratio; kdyz nekdy narazime na klip, ktery ho
opravdu potrebuje, da se zapnout per-klip pres "location_scale" v jobu.

Klipy jdou za sebou na jedne timeline s 5-frame mezerou (Luanti umi jen jednu
timeline + frame ranges) a zaroven kazdy dostane vlastni NLA track
pojmenovany podle animation_id, protoze
glTF exporter v rezimu NLA_TRACKS dela z kazdeho tracku samostatny klip -
to je to, co pak `playAnimation("walk_forward")` ve viewru najde.

Vysledek: {"ranges": {clip_id: [start, end]}} do retarget_ranges.json.
"""
import argparse
import json
import os
import sys

import bpy

GAP_FRAMES = 5          # mezera mezi klipy, at posledni snimek nepretece do dalsiho
MIXAMO_PREFIX = "mixamorig"


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--job", required=True)
    return ap.parse_args(argv)


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def armatures():
    return [o for o in bpy.context.scene.objects if o.type == "ARMATURE"]


def import_fbx(path):
    """Vraci objekty, ktere import pridal - jinak se v scene neda poznat,
    ktera armatura je ta nova."""
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.fbx(filepath=path, automatic_bone_orientation=True)
    return [o for o in bpy.context.scene.objects if o not in before]


def armature_height(arm):
    """Vyska kostry v jejich vlastnich jednotkach. Mixamo exportuje 'Without
    Skin' v centimetrech, rigovana postava z pipeline je v metrech - kdyby
    se translace bokou kopirovala 1:1, postava by pri chuzi odletela."""
    zs = [(arm.matrix_world @ b.head_local).z for b in arm.data.bones]
    zs += [(arm.matrix_world @ b.tail_local).z for b in arm.data.bones]
    return max(zs) - min(zs) if zs else 0.0


def scale_location_curves(action, factor):
    """Pouzije se jen na vyslovnou zadost pres job["clips"][i]["location_scale"] -
    viz poznamka v docstringu, proc to neni automaticke."""
    if abs(factor - 1.0) < 1e-6:
        return
    for fc in action.fcurves:
        if not fc.data_path.endswith(".location"):
            continue
        for kp in fc.keyframe_points:
            kp.co.y *= factor
            kp.handle_left.y *= factor
            kp.handle_right.y *= factor


def take_action(objs, clip_id, scale):
    """Vytahne Action z importovaneho klipu a uklidi po sobe importovane
    objekty. scale je 1.0, dokud si klip vyslovne nerekne o jine."""
    src = next((o for o in objs if o.type == "ARMATURE"), None)
    if src is None:
        raise RuntimeError(f"klip {clip_id}: FBX neobsahuje armaturu")
    if not (src.animation_data and src.animation_data.action):
        raise RuntimeError(f"klip {clip_id}: FBX neobsahuje animaci")
    action = src.animation_data.action
    action.name = clip_id
    action.use_fake_user = True          # aby ji uklid objektu nesmazal
    scale_location_curves(action, scale)
    src.animation_data.action = None
    for o in objs:
        bpy.data.objects.remove(o, do_unlink=True)
    return action


def bones_in_action(action):
    """Nazvy kosti, na ktere action sahá - pro kontrolu, ze kostra sedi."""
    names = set()
    for fc in action.fcurves:
        if fc.data_path.startswith('pose.bones["'):
            names.add(fc.data_path.split('"')[1])
    return names


def main():
    args = parse_args()
    with open(args.job) as f:
        job = json.load(f)
    out_dir = job["out_dir"]
    os.makedirs(out_dir, exist_ok=True)

    reset_scene()
    import_fbx(job["rigged_fbx"])
    targets = armatures()
    if len(targets) != 1:
        raise RuntimeError(f"rigovane FBX ma {len(targets)} armatur, cekam 1")
    target = targets[0]
    target_bones = {b.name for b in target.data.bones}
    mixamo_bones = {b for b in target_bones if b.startswith(MIXAMO_PREFIX)}
    if not mixamo_bones:
        raise RuntimeError("cilova kostra nema mixamorig: kosti - auto-rig selhal")
    target_h = armature_height(target)

    if target.animation_data is None:
        target.animation_data_create()
    # Stare tracky pryc: /animations muze prijit znovu s jinym vyberem klipu
    for tr in list(target.animation_data.nla_tracks):
        target.animation_data.nla_tracks.remove(tr)

    ranges, missing, ratios = {}, {}, {}
    cursor = 1
    for clip in job["clips"]:
        clip_id = clip["id"]
        objs = import_fbx(clip["fbx_path"])
        src = next((o for o in objs if o.type == "ARMATURE"), None)
        src_h = armature_height(src) if src else 0.0
        ratio = round(target_h / src_h, 4) if src_h > 0 else 0.0
        ratios[clip_id] = ratio
        action = take_action(objs, clip_id, float(clip.get("location_scale", 1.0)))

        gap = bones_in_action(action) - target_bones
        if gap:
            missing[clip_id] = sorted(gap)[:8]

        start, end = action.frame_range
        length = max(int(round(end - start)), 1)
        track = target.animation_data.nla_tracks.new()
        track.name = clip_id
        track.strips.new(clip_id, cursor, action)
        ranges[clip_id] = [cursor, cursor + length]
        cursor += length + GAP_FRAMES

    if not ranges:
        raise RuntimeError("zadny klip se nepodarilo nacist")

    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = max(r[1] for r in ranges.values())

    blend_path = os.path.join(out_dir, "animated.blend")
    bpy.ops.wm.save_as_mainfile(filepath=blend_path)

    report = {
        "ranges": ranges,
        "clip_count": len(ranges),
        "timeline_end": scene.frame_end,
        "gap_frames": GAP_FRAMES,
        "target_bones": len(target_bones),
        "mixamo_bones": len(mixamo_bones),
        "bones_missing_in_target": missing,
        "height_ratio": ratios,
        "blend": os.path.basename(blend_path),
    }
    with open(os.path.join(out_dir, "retarget_ranges.json"), "w") as f:
        json.dump(report, f, indent=2)
    print("FC_RETARGET_OK", json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"FC_RETARGET_FAIL {e}", file=sys.stderr)
        sys.exit(1)
