"""animated.blend -> model.glb + model.fbx + preview.mp4 + thumb.png.

    blender -b -P fc_export.py -- --job /data/jobs/<id>.json

Job JSON: {"id", "blend", "out_dir"}

Poradi je zamerne: nejdriv exporty, teprve pak turntable. Kamera a svetla
pridana kvuli renderu by se jinak vezla ve FBX (ten exportuje celou scenu,
ne jen mesh) a v Studiu by z toho byl objekt navic.

Turntable ma NLA tracky ztlumene, takze se toci klidova poza. Kdyby hraly,
kazdy preview by chytil postavu v jine nahodne fazi klipu a nesly by mezi
sebou porovnat.

Renderuje CYCLES na CPU, ne Eevee. Zmereno v ugc-blender kontejneru na JODA:
Eevee tam spadne na "EGL Error (0x3009): EGL_BAD_MATCH" - stroj nema GPU a
kontejner nema EGL surface. Horsi je, ze Blender u toho skonci s navratovym
kodem 0 a nechá po sobe 48bajtovy mp4, takze bez kontroly velikosti by krok
hlasil uspech s rozbitym souborem. Cycles CPU zadny GL kontext nepotrebuje
(stejne jako bake v convert.py).

Preview je navic nepovinny: kdyz render selze, GLB a FBX se stejne odevzdaji
a v reportu je preview prazdne. Model je to, co uzivatel potrebuje; video je
pohodli.

Rezim se ridi job["preview"]:
  "thumb" (vychozi) - jeden snimek, ~20 s
  "full"            - cely turntable; na JODA zmereno 15 MINUT na 48 snimku
                      u fixture o 12 trojuhelnicich, takze na realne postave
                      to bude horsi. Zapinat, az bude render na Sparku.
  "none"            - jen GLB a FBX
"""
import argparse
import json
import math
import os
import sys

import bpy

TURNTABLE_SECONDS = 4
FPS = 12                 # 48 snimku misto 96: path tracing na CPU stoji cas a
                         # turntable pri 12 fps vypada porad plynule
CYCLES_SAMPLES = 16      # rovnomerne nasvicena postava, vic sumu nezbyde
RENDER_SIZE = 512
THUMB_SIZE = 512


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--job", required=True)
    return ap.parse_args(argv)


def call_with_fallback(op, **kwargs):
    """Blender meni jmena exportnich parametru mezi verzemi (export_animation_mode
    pribylo v 3.6). Nechceme, aby cely krok spadl kvuli jednomu klici -
    zkousime znovu bez toho, ktery si operator nevzal."""
    kw = dict(kwargs)
    while True:
        try:
            return op(**kw)
        except TypeError as e:
            bad = None
            for key in list(kw):
                if key in str(e):
                    bad = key
                    break
            if bad is None:
                raise
            print(f"blender nezna {bad}, zkousim bez nej", flush=True)
            kw.pop(bad)


def export_glb(path):
    """NLA_TRACKS: kazdy track = jeden pojmenovany klip v glTF, takze
    viewer umi playAnimation('walk_forward')."""
    call_with_fallback(
        bpy.ops.export_scene.gltf,
        filepath=path,
        export_format="GLB",
        export_skins=True,
        export_animations=True,
        export_animation_mode="NLA_TRACKS",
        export_materials="EXPORT",
        export_apply=False,          # apply by rozbil skinning
    )


def export_fbx(path):
    call_with_fallback(
        bpy.ops.export_scene.fbx,
        filepath=path,
        use_selection=False,
        path_mode="COPY",            # textury vedle souboru, plan 3.3
        embed_textures=False,
        add_leaf_bones=False,        # Mixamo leaf kosti mate Roblox importer
        bake_anim=True,
        bake_anim_use_nla_strips=True,
        bake_anim_use_all_actions=False,
        axis_up="Y",                 # FBX konvence, Blender do ni prevede
        axis_forward="-Z",
    )


def scene_bounds():
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    if not meshes:
        raise RuntimeError("scena neobsahuje mesh")
    zs, radius = [], 0.0
    for o in meshes:
        for corner in o.bound_box:
            wc = o.matrix_world @ __import__("mathutils").Vector(corner)
            zs.append(wc.z)
            radius = max(radius, math.hypot(wc.x, wc.y))
    return min(zs), max(zs), max(radius, 0.1)


def mute_animation(muted):
    for o in bpy.context.scene.objects:
        if o.animation_data:
            for tr in o.animation_data.nla_tracks:
                tr.mute = muted


def looks_rendered(path, min_bytes):
    """Blender po nepovedenem renderu nechá prazdny kontejner a skonci s nulou -
    velikost souboru je jediny signal, ze v nem opravdu neco je."""
    return os.path.exists(path) and os.path.getsize(path) >= min_bytes


def build_turntable():
    """Kamera na prazdnem objektu ve stredu postavy; otoceni empty o 360 stupnu
    je cely turntable - kamera si drzi vzdalenost i uhel sama."""
    zmin, zmax, radius = scene_bounds()
    center_z = (zmin + zmax) / 2
    height = max(zmax - zmin, 0.1)

    pivot = bpy.data.objects.new("Turntable", None)
    bpy.context.scene.collection.objects.link(pivot)
    pivot.location = (0, 0, center_z)

    cam_data = bpy.data.cameras.new("PreviewCam")
    cam = bpy.data.objects.new("PreviewCam", cam_data)
    bpy.context.scene.collection.objects.link(cam)
    cam.parent = pivot
    dist = max(radius * 3.2, height * 1.6)
    cam.location = (0, -dist, height * 0.15)
    cam.rotation_euler = (math.radians(85), 0, 0)
    bpy.context.scene.camera = cam

    sun = bpy.data.objects.new("Sun", bpy.data.lights.new("Sun", "SUN"))
    sun.data.energy = 4.0
    sun.rotation_euler = (math.radians(55), 0, math.radians(35))
    bpy.context.scene.collection.objects.link(sun)
    world = bpy.data.worlds.new("PreviewWorld")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.05, 0.05, 0.06, 1)
    bpy.context.scene.world = world

    frames = TURNTABLE_SECONDS * FPS
    pivot.rotation_euler = (0, 0, 0)
    pivot.keyframe_insert("rotation_euler", frame=1)
    pivot.rotation_euler = (0, 0, math.radians(360))
    pivot.keyframe_insert("rotation_euler", frame=frames)
    for fc in pivot.animation_data.action.fcurves:
        for kp in fc.keyframe_points:
            kp.interpolation = "LINEAR"   # jinak turntable na zacatku a konci zpomali
    return frames


def render_preview(out_mp4, out_thumb, frames, mode):
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = CYCLES_SAMPLES
    scene.render.resolution_x = RENDER_SIZE
    scene.render.resolution_y = RENDER_SIZE
    scene.render.resolution_percentage = 100
    scene.render.fps = FPS
    scene.frame_start = 1
    scene.frame_end = frames

    if mode == "full":
        scene.render.image_settings.file_format = "FFMPEG"
        scene.render.ffmpeg.format = "MPEG4"
        scene.render.ffmpeg.codec = "H264"
        scene.render.ffmpeg.constant_rate_factor = "MEDIUM"
        scene.render.filepath = out_mp4
        bpy.ops.render.render(animation=True)

    # thumb z ctvrtiny otacky: cistsi 3/4 pohled nez cely predek
    scene.frame_set(max(frames // 8, 1))
    scene.render.image_settings.file_format = "PNG"
    scene.render.resolution_x = THUMB_SIZE
    scene.render.resolution_y = THUMB_SIZE
    scene.render.filepath = out_thumb
    bpy.ops.render.render(write_still=True)


def main():
    args = parse_args()
    with open(args.job) as f:
        job = json.load(f)
    out_dir = job["out_dir"]
    os.makedirs(out_dir, exist_ok=True)

    bpy.ops.wm.open_mainfile(filepath=job["blend"])

    glb = os.path.join(out_dir, "model.glb")
    fbx = os.path.join(out_dir, "model.fbx")
    export_glb(glb)
    export_fbx(fbx)

    mute_animation(True)
    frames = build_turntable()
    mp4 = os.path.join(out_dir, "preview.mp4")
    thumb = os.path.join(out_dir, "thumb.png")
    mode = job.get("preview", "thumb")
    preview_error = ""
    try:
        if mode not in ("none", "thumb", "full"):
            raise RuntimeError(f"neznamy rezim preview {mode!r}")
        if mode != "none":
            render_preview(mp4, thumb, frames, mode)
    except Exception as e:      # model uz je hotovy, kvuli videu ho nezahodime
        preview_error = str(e)
        print(f"preview render selhal: {e}", file=sys.stderr)
    mute_animation(False)

    # Blender pripoji k FFMPEG vystupu rozsah snimku, kdyz cesta nekonci prponou
    if not os.path.exists(mp4):
        produced = [f for f in os.listdir(out_dir) if f.startswith("preview") and f.endswith(".mp4")]
        if produced:
            os.rename(os.path.join(out_dir, produced[0]), mp4)
    # prazdny kontejner radsi smazat, at ho appka nenabidne ke stazeni
    if os.path.exists(mp4) and not looks_rendered(mp4, 1024):
        os.remove(mp4)

    tris = 0
    for o in bpy.context.scene.objects:
        if o.type == "MESH":
            o.data.calc_loop_triangles()
            tris += len(o.data.loop_triangles)

    report = {
        "glb": os.path.basename(glb),
        "fbx": os.path.basename(fbx),
        "preview": os.path.basename(mp4) if looks_rendered(mp4, 1024) else "",
        "thumb": os.path.basename(thumb) if looks_rendered(thumb, 512) else "",
        "preview_error": preview_error,
        "tri_count": tris,
        "turntable_frames": frames if mode == "full" else 0,
        "preview_mode": mode,
        "engine": bpy.context.scene.render.engine,
    }
    with open(os.path.join(out_dir, "export_report.json"), "w") as f:
        json.dump(report, f, indent=2)
    print("FC_EXPORT_OK", json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"FC_EXPORT_FAIL {e}", file=sys.stderr)
        sys.exit(1)
