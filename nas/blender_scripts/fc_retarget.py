"""Rigovane FBX + N Mixamo klipu -> jedna armatura s pojmenovanymi klipy.

    blender -b -P fc_retarget.py -- --job /data/jobs/<id>.json

Job JSON: {"id", "rigged_fbx", "out_dir", "clips": [{"id","fbx_path"}, ...]}

Retarget addon netreba, kosti se paruji podle Mixamo jmen. Action se ale
NEkopiruje: sablona ma kosti natocene jinak nez Mixamo, takze se klip
prepeca pres svetove osy kosti - proc, je v docstringu bake_clip.

Translace boku se bere ve svete, ne z krivek: tam je uz v metrech (matrix_world
zdroje nese meritko 0.01), takze staci pomer vysek koster. Z krivek to
nejde - FBX import translacni kanaly normalizuje sam a korekce podle vysky
je na fixture ve 100x meritku (testdata/gen_fc_fixture.py) zkorigovala
podruhe. "location_scale" v jobu posun jeste vynasobi, vychozi 1.0.

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
import numpy as np
from mathutils import Matrix, Vector

GAP_FRAMES = 5          # mezera mezi klipy, at posledni snimek nepretece do dalsiho
MIXAMO_PREFIX = "mixamorig"
HIPS_BONE = "mixamorig:Hips"   # kost, na ktere Mixamo veze root motion


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


def relink_texture(out_dir):
    """Napoji obrazky bez dat na atlas z cleanupu.

    MIA zapise do rigged.fbx odkaz na texturu, ktery miri na adresar
    rigged.fbm/, ne na soubor v nem. Obrazek pak prijde prazdny, pack_all nema
    co zabalit a glTF export material vypise bez textury - clean.glb texturu
    mel, model.glb uz ne (2026-09-01). Atlas z fc_cleanup lezi vedle, tak ho
    pouzijeme."""
    atlas = os.path.join(out_dir, "clean_tex.png")
    if not os.path.exists(atlas):
        return []
    fixed = []
    for img in bpy.data.images:
        if img.packed_file is not None:
            continue
        resolved = bpy.path.abspath(img.filepath) if img.filepath else ""
        if resolved and os.path.isfile(resolved):
            continue
        img.filepath = atlas
        img.source = "FILE"
        try:
            img.reload()
        except RuntimeError:
            continue
        fixed.append(img.name)
    return fixed


def armature_height(arm):
    """Vyska kostry v jejich vlastnich jednotkach. Mixamo exportuje 'Without
    Skin' v centimetrech, rigovana postava z pipeline je v metrech - kdyby
    se translace bokou kopirovala 1:1, postava by pri chuzi odletela."""
    zs = [(arm.matrix_world @ b.head_local).z for b in arm.data.bones]
    zs += [(arm.matrix_world @ b.tail_local).z for b in arm.data.bones]
    return max(zs) - min(zs) if zs else 0.0


def rotation_of(matrix):
    """Rotace bez meritka - zdrojova armatura ma v matrix_world scale 0.01."""
    return matrix.to_3x3().normalized().to_quaternion()


def hierarchy_order(arm):
    """Rodice pred detmi: pozu ditete jde spocitat jen z hotove pozy rodice."""
    return sorted(arm.data.bones, key=lambda b: len(b.parent_recursive))


def bake_clip(target, src, clip_id, translation_scale, in_place):
    """Prenese klip ze zdrojove armatury na cilovou pres svetove osy kosti.

    Kopirovat Action 1:1 jde jen mezi kostrami se stejne natocenymi kostmi.
    Sablona (fc_rig_template.py) ma jen Mixamo jmena: nohy a klicni kosti
    ma otocene o 180 stupnu kolem vlastni osy a paze v klidu miri dolu, ne
    do T-pozy. Stejny lokalni kvaternion pak toci kost kolem jine osy -
    zmereno na Zombie Walk 2026-09-15: stehno v prumeru 66 stupnu mimo
    zdroj, nejvic 116, postava se v pase prelozila a nohy sly vodorovne.

    Proto se pro kazdou kost jednou spocita korekce C = S_rest^-1 * A *
    T_rest (A srovna smer cilove kosti v klidu se zdrojovou) a v kazdem
    snimku ma cilova kost svetovou rotaci S(f) * C. Kost pak miri tam, kam
    ve zdroji, at je jeji klidova poza nebo natoceni jakekoli.

    Boky nesou i vysku, a ta se dopocita z chodidel (viz smycka nize), ne z
    pohybu boku zdroje. S in_place se zahodi vodorovna slozka. Vraci (action,
    rozsah zdvihu boku v m, pomer delek nohou)."""
    bones = hierarchy_order(target)
    src_bones = {pb.name: pb for pb in src.pose.bones}
    src_rot_w = rotation_of(src.matrix_world)
    tgt_rot_w = rotation_of(target.matrix_world)
    tgt_rot_w_inv = tgt_rot_w.inverted()

    correction = {}
    for b in bones:
        sb = src.data.bones.get(b.name)
        if sb is None:
            continue
        s_rest = src_rot_w @ rotation_of(sb.matrix_local)
        t_rest = tgt_rot_w @ rotation_of(b.matrix_local)
        align = (t_rest @ Vector((0, 1, 0))).rotation_difference(s_rest @ Vector((0, 1, 0)))
        correction[b.name] = s_rest.inverted() @ align @ t_rest

    hips_rest_w = src.matrix_world @ src.data.bones[HIPS_BONE].head_local
    src_feet, tgt_feet = foot_bones(src), foot_bones(target)
    src_floor = rest_lowest(src, src_feet)
    tgt_floor = rest_lowest(target, tgt_feet)
    src_leg, tgt_leg = leg_length(src), leg_length(target)
    leg_ratio = tgt_leg / src_leg if src_leg > 0 and tgt_leg > 0 else 1.0

    action = bpy.data.actions.new(clip_id)
    action.use_fake_user = True
    start, end = (int(round(x)) for x in src.animation_data.action.frame_range)
    scene = bpy.context.scene
    keys = {b.name: [] for b in bones}
    hips_keys, previous, bob = [], {}, []

    def pose(lift):
        """Armaturni matice vsech kosti cile v aktualnim snimku; boky navic
        posunute o `lift` metru nahoru."""
        posed = {}
        for b in bones:
            if b.parent is None:
                base = b.matrix_local.copy()
            else:
                base = posed[b.parent.name] @ (b.parent.matrix_local.inverted() @ b.matrix_local)
            if b.name in correction:
                world = src_rot_w @ rotation_of(src_bones[b.name].matrix) @ correction[b.name]
                rot = tgt_rot_w_inv @ world
            else:
                rot = rotation_of(base)          # kost bez protejsku drzi klid
            loc = base.translation.copy()
            if b.name == HIPS_BONE:
                delta_w = (src.matrix_world @ src_bones[HIPS_BONE].head) - hips_rest_w
                delta_w *= translation_scale
                delta_w.z = lift
                if in_place:
                    delta_w.x = delta_w.y = 0.0
                loc += tgt_rot_w_inv @ delta_w
            posed[b.name] = Matrix.LocRotScale(loc, rot, None)
            posed["__base__" + b.name] = base
        return posed

    for frame in range(start, end + 1):
        scene.frame_set(frame)
        # Vyska boku: nejdriv poza s boky v klidove vysce, pak se boky zvednou
        # tak, aby nejnizsi bod chodidel byl nad zemi tolik, co ve zdroji
        # (prepocteno delkou nohou). Vsechno pod boky se posune s nimi, takze
        # jeden posun je presny pro jakoukoli kostru - na rozdil od pomeru
        # vysek koster, se kterym MIA postavy zajizdely 9-13 cm pod zem.
        probe = pose(0.0)
        src_low = min((src.matrix_world @ getattr(src_bones[n], end_)).z
                      for n in src_feet for end_ in ("head", "tail"))
        tgt_low = posed_lowest(target, probe, tgt_feet)
        lift = tgt_floor + (src_low - src_floor) * leg_ratio - tgt_low
        posed = pose(lift)
        bob.append(lift)
        for b in bones:
            basis = posed["__base__" + b.name].inverted() @ posed[b.name]
            q = basis.to_quaternion()
            if b.name in previous:
                q.make_compatible(previous[b.name])  # bez skoku znamenka mezi snimky
            previous[b.name] = q
            keys[b.name].append((frame, q))
            if b.name == HIPS_BONE:
                hips_keys.append((frame, basis.translation.copy()))

    for name, frames in keys.items():
        write_curves(action, name, "rotation_quaternion", frames, 4)
    write_curves(action, HIPS_BONE, "location", hips_keys, 3)
    for b in target.pose.bones:
        b.rotation_mode = "QUATERNION"
    floor_fix = keep_mesh_above_floor(target, action, start, end)
    return (action, (round(max(bob) - min(bob), 3) if bob else 0.0), round(leg_ratio, 4),
            floor_fix)


def keep_mesh_above_floor(target, action, start, end):
    """Zvedne boky ve snimcich, kde mesh zajede pod klidovou uroven zeme.

    Vyska boku podle kosti chodidel (bake_clip) nestaci: podrazka lezi pod
    kostmi, a kdyz se spicka pri kroku odvali, otoci se podrazka pod ne.
    U MIA rigu foto 1 tak mesh zajizdel 8,7 cm pod zem i s presnou vyskou
    kosti (drive 13,6 cm). Zvedani je jen nahoru: skok ma dal od zeme
    odlepit. Boky nesou vse, takze posun o dz zvedne cely mesh presne o dz.
    Vraci nejvetsi pouzity zdvih v metrech."""
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"
              and any(m.type == "ARMATURE" and m.object == target for m in o.modifiers)]
    if not meshes:
        return 0.0

    def world_z(obj, mesh):
        n = len(mesh.vertices)
        co = np.empty(n * 3, dtype=np.float64)
        mesh.vertices.foreach_get("co", co)
        m = np.array(obj.matrix_world)
        return co.reshape(n, 3) @ m[2, :3] + m[2, 3]

    floor = min(float(world_z(o, o.data).min()) for o in meshes)
    if target.animation_data is None:
        target.animation_data_create()
    previous = target.animation_data.action
    target.animation_data.action = action
    scene = bpy.context.scene
    lifts = {}
    for frame in range(start, end + 1):
        scene.frame_set(frame)
        dg = bpy.context.evaluated_depsgraph_get()
        low = None
        for o in meshes:
            ev = o.evaluated_get(dg)
            me = ev.to_mesh()
            z = float(world_z(ev, me).min())
            ev.to_mesh_clear()
            low = z if low is None else min(low, z)
        if low is not None and low < floor:
            lifts[frame] = floor - low
    target.animation_data.action = previous
    if not lifts:
        return 0.0

    # zdvih ve svete -> posun v lokalnich osach boku (klidova matice korene)
    hips = target.data.bones[HIPS_BONE]
    to_local = hips.matrix_local.to_3x3().inverted() @ target.matrix_world.to_3x3().inverted()
    path = f'pose.bones["{HIPS_BONE}"].location'
    curves = {fc.array_index: fc for fc in action.fcurves if fc.data_path == path}
    for frame, dz in lifts.items():
        delta = to_local @ Vector((0.0, 0.0, dz))
        for axis, fc in curves.items():
            for kp in fc.keyframe_points:
                if int(round(kp.co.x)) == frame:
                    kp.co.y += delta[axis]
                    kp.handle_left.y += delta[axis]
                    kp.handle_right.y += delta[axis]
    for fc in curves.values():
        fc.update()
    return round(max(lifts.values()), 3)


def foot_bones(arm):
    """Kosti, podle kterych se meri vyska chodidel: Foot a ToeBase obou stran,
    kde chybi (fixture), aspon konec Leg."""
    names = []
    for side in ("Left", "Right"):
        found = [f"{MIXAMO_PREFIX}:{side}{part}" for part in ("Foot", "ToeBase")
                 if f"{MIXAMO_PREFIX}:{side}{part}" in arm.data.bones]
        if not found and f"{MIXAMO_PREFIX}:{side}Leg" in arm.data.bones:
            found = [f"{MIXAMO_PREFIX}:{side}Leg"]
        names += found
    if not names:
        raise RuntimeError(f"kostra {arm.name} nema nohy - nejde urcit vysku boku")
    return names


def rest_lowest(arm, names):
    mw = arm.matrix_world
    return min(min((mw @ arm.data.bones[n].head_local).z, (mw @ arm.data.bones[n].tail_local).z)
               for n in names)


def posed_lowest(arm, posed, names):
    """Nejnizsi hlava nebo konec kosti v poze spocitane v bake_clip."""
    mw = arm.matrix_world
    low = None
    for n in names:
        m = posed[n]
        for p in (m.translation, m @ Vector((0.0, arm.data.bones[n].length, 0.0))):
            z = (mw @ p).z
            low = z if low is None else min(low, z)
    return low


def leg_length(arm):
    """Prumerna delka stehna a holene ve svete - meritko pro vysku kroku."""
    mw = arm.matrix_world
    lengths = []
    for side in ("Left", "Right"):
        up = arm.data.bones.get(f"{MIXAMO_PREFIX}:{side}UpLeg")
        low = arm.data.bones.get(f"{MIXAMO_PREFIX}:{side}Leg")
        if up is None or low is None:
            continue
        lengths.append((mw @ up.tail_local - mw @ up.head_local).length
                       + (mw @ low.tail_local - mw @ low.head_local).length)
    return sum(lengths) / len(lengths) if lengths else 0.0


def write_curves(action, bone, prop, frames, width):
    path = f'pose.bones["{bone}"].{prop}'
    for i in range(width):
        fc = action.fcurves.new(path, index=i, action_group=bone)
        fc.keyframe_points.add(len(frames))
        co = [c for frame, value in frames for c in (frame, value[i])]
        fc.keyframe_points.foreach_set("co", co)
        fc.update()


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

    # Obe cilove hry si pohyb postavy ridi samy, takze klip ma animovat na
    # miste. Vypnout jde per job pro pripad, ze by nekdo root motion chtel.
    in_place = job.get("in_place", True)
    ranges, missing, ratios, bobs, leg_ratios, floor_fixes = {}, {}, {}, {}, {}, {}
    cursor = 1
    for clip in job["clips"]:
        clip_id = clip["id"]
        objs = import_fbx(clip["fbx_path"])
        src = next((o for o in objs if o.type == "ARMATURE"), None)
        if src is None:
            raise RuntimeError(f"klip {clip_id}: FBX neobsahuje armaturu")
        if not (src.animation_data and src.animation_data.action):
            raise RuntimeError(f"klip {clip_id}: FBX neobsahuje animaci")
        # POZOR: MIXAMO_PREFIX je bez dvojtecky (slouzi na startswith),
        # takze se kost boku nesklada z nej - je to "mixamorig:Hips".
        if HIPS_BONE not in src.data.bones:
            raise RuntimeError(f"klip {clip_id}: zdrojova kostra nema {HIPS_BONE}")
        src_h = armature_height(src)
        ratio = round(target_h / src_h, 4) if src_h > 0 else 0.0
        ratios[clip_id] = ratio

        src_action = src.animation_data.action
        gap = bones_in_action(src_action) - target_bones
        if gap:
            missing[clip_id] = sorted(gap)[:8]
        action, bobs[clip_id], leg_ratios[clip_id], floor_fixes[clip_id] = bake_clip(
            target, src, clip_id, ratio * float(clip.get("location_scale", 1.0)), in_place)

        for o in objs:
            bpy.data.objects.remove(o, do_unlink=True)
        bpy.data.actions.remove(src_action)

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

    # Zabalit texturu do blendu: fc_export otevira soubor samostatne a na
    # relativni cesty uz nespoleha.
    relinked = relink_texture(out_dir)
    if relinked:
        print("textura napojena na clean_tex.png: %s" % relinked, flush=True)
    bpy.ops.file.pack_all()

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
        "in_place": in_place,
        "retarget": "world_axes",
        "hips_bob_m": bobs,
        "leg_ratio": leg_ratios,
        "floor_fix_m": floor_fixes,
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
