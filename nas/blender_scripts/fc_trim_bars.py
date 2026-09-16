"""Odrizne jednobarevne pruhy na hornim a spodnim okraji fotky (cerny pas
prehravace, stavova lista screenshotu) - FLUX Fill by jinak domyslel nohy
pod pruh (plan sekce 15). Rozhoduje fc_pose.bar_bounds (ciste, testovane);
tady je jen nacteni pixelu, std radku a zapis oriznuteho PNG.

  blender -b --factory-startup -noaudio -P fc_trim_bars.py -- --job job.json
  job = {"image": vstup, "out": vystupni PNG}

Na stdout: TRIM_OK {"top": N, "bottom": N, "height": H, "written": bool} -
soubor se zapise jen kdyz se neco odrizlo (worker pak pokracuje s nim).
Blender se pouziva proto, ze worker kontejner nema Pillow ani cv2, ale
Blender uz tam kvuli cleanupu je (i s numpy).
"""
import json
import os
import sys

import bpy
import numpy as np

for cand in (os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
             os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "worker")):
    if os.path.exists(os.path.join(cand, "fc_pose.py")):
        sys.path.insert(0, cand)
import fc_pose  # noqa: E402

argv = sys.argv[sys.argv.index("--") + 1:]
with open(argv[argv.index("--job") + 1]) as f:
    job = json.load(f)

img = bpy.data.images.load(job["image"])
w, h = img.size
px = np.empty(w * h * img.channels, dtype=np.float32)
img.pixels.foreach_get(px)
px = px.reshape(h, w, img.channels)[:, :, :3] * 255.0   # bpy ma radky odspodu
rows = px.reshape(h, -1).std(axis=1)[::-1]              # -> shora dolu jako fotka
top, bottom = fc_pose.bar_bounds(rows.tolist(), h)

written = False
if top or bottom:
    keep = px[::-1][top:h - bottom][::-1]                 # zpet do poradi bpy
    nh = keep.shape[0]
    out = bpy.data.images.new("trimmed", w, nh, alpha=False)
    buf = np.ones((nh, w, 4), dtype=np.float32)
    buf[:, :, :3] = keep / 255.0
    out.pixels.foreach_set(buf.ravel())
    out.filepath_raw = job["out"]
    out.file_format = "PNG"
    out.save()
    written = True
print("TRIM_OK " + json.dumps({"top": int(top), "bottom": int(bottom), "height": int(h), "written": written}))
