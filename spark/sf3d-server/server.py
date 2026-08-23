"""SF3D jako HTTP sluzba.

SF3D neni ComfyUI node, ale samostatny python balicek - a nacteni modelu
trva desitky sekund, takze ho nechceme spoustet na kazdy job znovu. Tenhle
wrapper drzi model v pameti a vystavuje ho stejne, jako ComfyUI vystavuje
TRELLIS: jednoduche HTTP.

    POST /generate   telo = PNG (s alfou), vraci GLB
    GET  /health

Bezi na hostu Sparku (potrebuje CUDA), ne v containeru:
    cd ~/Code/stable-fast-3d && source .venv/bin/activate
    HF_TOKEN=... python sf3d-server/server.py
"""
import io
import json
import os
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import torch
from PIL import Image

sys.path.insert(0, os.path.expanduser("~/Code/stable-fast-3d"))
from sf3d.system import SF3D  # noqa: E402
from sf3d.utils import remove_background, resize_foreground  # noqa: E402
import rembg  # noqa: E402

ADDR = ("0.0.0.0", int(os.environ.get("SF3D_PORT", "8093")))
TEXTURE = int(os.environ.get("SF3D_TEXTURE", "1024"))

print("nacitam SF3D model...", flush=True)
_model = SF3D.from_pretrained(
    "stabilityai/stable-fast-3d", config_name="config.yaml", weight_name="model.safetensors"
)
_model.eval().cuda()
_rembg = rembg.new_session()
# Jeden zamek: GPU je sdilene s ComfyUI/TRELLIS a soubezne davky na GB10
# jsou znamy power-spike pad.
_lock = threading.Lock()
print(f"SF3D pripraven na {ADDR[0]}:{ADDR[1]}", flush=True)


def generate(png_bytes: bytes) -> bytes:
    image = Image.open(io.BytesIO(png_bytes))
    if image.mode != "RGBA" or image.getchannel("A").getextrema()[0] == 255:
        image = remove_background(image.convert("RGB"), _rembg)
    image = resize_foreground(image, 0.85)

    with _lock, torch.no_grad():
        with torch.autocast(device_type="cuda", dtype=torch.bfloat16):
            mesh, _ = _model.run_image(
                [image], bake_resolution=TEXTURE, remesh="none", vertex_count=-1
            )
    if isinstance(mesh, list):
        mesh = mesh[0]
    buf = io.BytesIO()
    mesh.export(buf, file_type="glb", include_normals=True)
    return buf.getvalue()


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):
        print(f"{self.address_string()} {fmt % args}", flush=True)

    def do_GET(self):
        if self.path != "/health":
            self.send_error(404)
            return
        body = json.dumps({"status": "ok", "service": "sf3d"}).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if self.path != "/generate":
            self.send_error(404)
            return
        n = int(self.headers.get("Content-Length", 0))
        if n <= 0:
            self.send_error(400, "empty body")
            return
        png = self.rfile.read(n)
        start = time.time()
        try:
            glb = generate(png)
        except Exception as e:  # klient dostane duvod, ne jen 500
            msg = json.dumps({"error": f"{type(e).__name__}: {e}"}).encode()
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(msg)))
            self.end_headers()
            self.wfile.write(msg)
            print(f"CHYBA: {e}", flush=True)
            return
        print(f"vygenerovano {len(glb)} B za {time.time()-start:.1f}s", flush=True)
        self.send_response(200)
        self.send_header("Content-Type", "model/gltf-binary")
        self.send_header("Content-Length", str(len(glb)))
        self.end_headers()
        self.wfile.write(glb)


if __name__ == "__main__":
    ThreadingHTTPServer(ADDR, Handler).serve_forever()
