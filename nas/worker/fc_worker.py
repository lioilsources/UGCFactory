"""ugc-fc worker: poll -> ComfyUI nebo Blender -> vysledek zpet do API.

Stejny vzor jako worker.py (soubory po sdilenem /data, API predava jen popis
kroku), jen fronta je krokova: /worker/fc/claim vraci jeden krok pipeline a
/worker/fc/result/{step_id} ho uzavre. Stateless - zabij ho kdykoli, prerusen
krok zustane 'running' a znovu ho zaradi retry z appky.

Kroky na Sparku (preprocess, mesh, rig) jedou pres ComfyUI /prompt; kroky na
JODA (clean, animate, export, packy) pres headless Blender.
"""
import json
import mimetypes
import os
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid

API = os.environ.get("UGC_API", "http://ugc-api:8095")
DATA = os.environ.get("UGC_DATA", "/data")
SCRIPTS = os.environ.get("UGC_SCRIPTS", "/app/blender_scripts")
COMFY = os.environ.get("FC_COMFY_URL", "")
WORKFLOW_DIR = os.environ.get("FC_WORKFLOW_DIR", "/app/workflows")
POLL_SECONDS = int(os.environ.get("UGC_POLL_SECONDS", "10"))
BLENDER_TIMEOUT = int(os.environ.get("UGC_BLENDER_TIMEOUT", "1800"))
COMFY_TIMEOUT = int(os.environ.get("FC_COMFY_TIMEOUT", "1800"))
# thumb | full | none. Vychozi 'thumb': cely turntable trval na JODA 15 minut
# na 48 snimku (Cycles CPU, GPU tu neni), takze by drzel workera kvuli videu,
# ktere je jen pohodli. Na 'full' prepnout, az bude render na Sparku.
PREVIEW_MODE = os.environ.get("FC_PREVIEW", "thumb")
# template | comfy. Vychozi je sablona v Blenderu na JODA, protoze ani UniRig,
# ani MIA na GB10 nerozbehneme (viz FANTASYCHARACTER_PLAN.md 12). Na 'comfy'
# se prepne, az nekdo z tech upstreamu Blackwell doplni.
RIG_MODE = os.environ.get("FC_RIG", "template")

# Kazdy ComfyUI krok ma vlastni workflow; fc_pipeline.json je fallback pro
# pripad, ze fáze 1 skonci s jednim velkym grafem misto tri.
WORKFLOWS = {
    "char.preprocess": ("fc_preprocess.json", "fc_pipeline.json"),
    "char.mesh": ("fc_mesh.json", "fc_pipeline.json"),
    "char.rig": ("fc_rig.json", "fc_pipeline.json"),
}

# Kontrakt s workflow: nody se oznacuji titulkem v ComfyUI (Properties ->
# Title). Worker pak nemusi znat cisla nodu, ktera se pri kazde editaci meni.
TITLE_INPUT_IMAGE = "FC_INPUT_IMAGE"
TITLE_SEED = "FC_SEED"


def api(path, payload=None, method=None):
    req = urllib.request.Request(API + path, method=method or ("POST" if payload is not None else "GET"))
    body = None
    if payload is not None:
        body = json.dumps(payload).encode()
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, body, timeout=60) as resp:
        if resp.status == 204:
            return None
        return json.load(resp)


# --- Blender -------------------------------------------------------------

def run_blender(script, job):
    """Napise job JSON a pusti skript. Blender pise stav na stdout, chybu na
    stderr - do reportu bereme posledni radky, cely log je v journalu."""
    job_file = os.path.join(DATA, "jobs", f"{job['id']}-{script}.json")
    os.makedirs(os.path.dirname(job_file), exist_ok=True)
    with open(job_file, "w") as f:
        json.dump(job, f)
    cmd = ["blender", "-b", "--factory-startup", "-noaudio",
           "-P", os.path.join(SCRIPTS, script), "--", "--job", job_file]
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=BLENDER_TIMEOUT)
    if proc.returncode != 0:
        tail = (proc.stderr or proc.stdout).strip().splitlines()[-5:]
        raise RuntimeError(f"{script}: " + " | ".join(tail))
    for line in reversed(proc.stdout.splitlines()):
        if "_OK " in line:
            return json.loads(line.split("_OK ", 1)[1])
    return {}


# --- ComfyUI -------------------------------------------------------------

def load_workflow(step):
    names = WORKFLOWS.get(step, ())
    for name in names:
        path = os.path.join(WORKFLOW_DIR, name)
        if os.path.exists(path):
            with open(path) as f:
                return json.load(f), name
    raise RuntimeError(
        f"{step}: chybi workflow ({' nebo '.join(names)}) v {WORKFLOW_DIR} - "
        "to je vystup faze 1, viz docs/FANTASYCHARACTER_PLAN.md 4.2")


def set_titled_input(workflow, title, key, value):
    """Najde nod podle titulku a prepise mu jeden vstup. Vraci, kolik nodu
    sedlo - nula znamena, ze workflow kontrakt nedodrzuje."""
    hits = 0
    for node in workflow.values():
        if not isinstance(node, dict):
            continue
        if node.get("_meta", {}).get("title") == title:
            node.setdefault("inputs", {})[key] = value
            hits += 1
    return hits


def comfy_post(path, payload):
    req = urllib.request.Request(COMFY + path, data=json.dumps(payload).encode(),
                                 headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.load(resp)


def comfy_get(path):
    with urllib.request.urlopen(COMFY + path, timeout=60) as resp:
        return json.load(resp)


def comfy_upload(path):
    """Nahraje soubor do input slozky ComfyUI a vrati jmeno, kterym se na nej
    workflow odkaze.

    ComfyUI bezi na Sparku, ale soubory kroku lezi na /data JODA a mezi stroji
    zadny sdileny mount neni - predat nodu absolutni cestu tedy nemuze vyjit.
    Stejnou cestou jde uz ugc-pipeline (Comfy.UploadImage v spark/internal/ugc).

    Jmeno je unikatni: ComfyUI si input slozku sdili se vsemi behy, takze
    'source.png' by si dva soubehy jobu prepsaly pod rukama."""
    name = "fc_%s_%s" % (uuid.uuid4().hex[:12], os.path.basename(path))
    boundary = "----fcworker%s" % uuid.uuid4().hex
    ctype = mimetypes.guess_type(path)[0] or "application/octet-stream"
    with open(path, "rb") as f:
        payload = f.read()
    body = b"".join([
        ("--%s\r\n" % boundary).encode(),
        ('Content-Disposition: form-data; name="image"; filename="%s"\r\n' % name).encode(),
        ("Content-Type: %s\r\n\r\n" % ctype).encode(),
        payload, b"\r\n",
        ("--%s\r\n" % boundary).encode(),
        b'Content-Disposition: form-data; name="overwrite"\r\n\r\ntrue\r\n',
        ("--%s--\r\n" % boundary).encode(),
    ])
    req = urllib.request.Request(
        COMFY + "/upload/image", data=body,
        headers={"Content-Type": "multipart/form-data; boundary=%s" % boundary})
    with urllib.request.urlopen(req, timeout=300) as resp:
        out = json.load(resp)
    sub = out.get("subfolder") or ""
    return "%s/%s" % (sub, out["name"]) if sub else out["name"]


def comfy_run(step, image_path):
    """Posle workflow a pocka na vysledek. Vraci seznam (filename, subfolder,
    type) vsech vystupu, ktere ComfyUI zapsal."""
    if not COMFY:
        raise RuntimeError(f"{step}: FC_COMFY_URL neni nastavene")
    workflow, name = load_workflow(step)
    if image_path:
        uploaded = comfy_upload(image_path)
        if not set_titled_input(workflow, TITLE_INPUT_IMAGE, "image", uploaded):
            raise RuntimeError(f"{name}: zadny nod s titulkem {TITLE_INPUT_IMAGE}")

    prompt_id = comfy_post("/prompt", {"prompt": workflow})["prompt_id"]
    deadline = time.time() + COMFY_TIMEOUT
    while time.time() < deadline:
        history = comfy_get(f"/history/{prompt_id}")
        entry = history.get(prompt_id)
        if entry:
            status = entry.get("status", {})
            if status.get("status_str") == "error":
                raise RuntimeError(f"{step}: ComfyUI hlasi chybu, prompt {prompt_id}")
            if status.get("completed") or entry.get("outputs"):
                return collect_outputs(entry.get("outputs", {})) + prefix_candidates(workflow)
        time.sleep(3)
    raise RuntimeError(f"{step}: ComfyUI nedobehl do {COMFY_TIMEOUT}s (prompt {prompt_id})")


def prefix_candidates(workflow):
    """Cesty odhadnute z filename_prefix, pro nody, ktere o sobe nedaji vedet.

    Do history/outputs zapise ComfyUI jen to, co nod vrati pod klicem "ui".
    Trellis2ExportMesh vraci prostou dvojici cest, takze po nem v outputs
    nezustane nic a krok by spadl na "nevratil zadny soubor". Stejnou past uz
    obchazi ugc-pipeline (meshFile v spark/internal/ugc/pipeline.go).

    Pouziva se az jako doplnek za skutecne vystupy, takze kdyz nod hlasi
    soubor sam, ma prednost."""
    out = []
    for node in workflow.values():
        if not isinstance(node, dict):
            continue
        prefix = (node.get("inputs") or {}).get("filename_prefix")
        if not isinstance(prefix, str) or not prefix:
            continue
        subfolder, _, base = prefix.rpartition("/")
        fmt = (node.get("inputs") or {}).get("file_format")
        exts = [fmt] if isinstance(fmt, str) and fmt else ["glb", "fbx", "png"]
        for ext in exts:
            out.append((f"{base}_00001_.{ext}", subfolder, "output"))
    return out


def collect_outputs(outputs):
    files = []
    for node_out in outputs.values():
        for key in ("images", "gltf", "files", "result"):
            for item in node_out.get(key, []) or []:
                if isinstance(item, dict) and item.get("filename"):
                    files.append((item["filename"], item.get("subfolder", ""),
                                  item.get("type", "output")))
    return files


def comfy_fetch(entry, dst):
    filename, subfolder, ftype = entry
    q = urllib.parse.urlencode({"filename": filename, "subfolder": subfolder, "type": ftype})
    with urllib.request.urlopen(f"{COMFY}/view?{q}", timeout=300) as resp, open(dst, "wb") as f:
        shutil.copyfileobj(resp, f)
    return dst


def pick_output(files, *extensions):
    for entry in files:
        if entry[0].lower().endswith(extensions):
            return entry
    raise RuntimeError(f"ComfyUI nevratil zadny soubor {extensions}, dostal jsem {[f[0] for f in files]}")


# --- kroky ---------------------------------------------------------------

def step_preprocess(claim):
    c, d, files = claim["character"], claim["dir"], claim["files"]
    src = os.path.join(d, files["source_image"])
    if not c.get("auto_apose", True):
        # bez kanonizace jde do meshe rovnou zdroj; plan 3.3 to ma jako flag
        return {"artifacts": {}}
    out = comfy_fetch(pick_output(comfy_run("char.preprocess", src), ".png", ".jpg"),
                      os.path.join(d, files["apose_image"]))
    return {"artifacts": {"apose_image": out}}


def step_mesh(claim):
    c, d, files = claim["character"], claim["dir"], claim["files"]
    src = os.path.join(d, files["apose_image"])
    if not os.path.exists(src):
        src = os.path.join(d, files["source_image"])
    out = comfy_fetch(pick_output(comfy_run("char.mesh", src), ".glb"),
                      os.path.join(d, files["mesh_glb"]))
    return {"artifacts": {"mesh_glb": out}}


def step_clean(claim):
    d, files = claim["dir"], claim["files"]
    report = run_blender("fc_cleanup.py", {
        "id": claim["character"]["id"],
        "glb": os.path.join(d, files["mesh_glb"]),
        "out_dir": d,
        "target": "user",
    })
    return {"artifacts": {"clean_glb": os.path.join(d, files["clean_glb"]),
                          "tri_count": report.get("tri_count", 0)}}


def step_rig(claim):
    d, files = claim["dir"], claim["files"]
    if RIG_MODE == "comfy":
        out = comfy_fetch(pick_output(comfy_run("char.rig", os.path.join(d, files["clean_glb"])), ".fbx"),
                          os.path.join(d, files["rigged_fbx"]))
        return {"artifacts": {"rigged_fbx": out}}

    report = run_blender("fc_rig_template.py", {
        "id": claim["character"]["id"],
        "glb": os.path.join(d, files["clean_glb"]),
        "out_dir": d,
    })
    # Sablona predpoklada humanoida; kdyz mesh nesedi, rig vznikne, ale bude
    # divny. Varovani patri do logu, at se to pozna driv nez na modelu.
    for w in report.get("fit_warnings", []):
        print(f"  rig varovani: {w}", flush=True)
    if report.get("unweighted_verts") and report.get("vert_count"):
        pct = 100.0 * report["unweighted_verts"] / report["vert_count"]
        if pct > 25:
            print(f"  rig varovani: {pct:.0f} % vrcholu bez vahy", flush=True)
    return {"artifacts": {"rigged_fbx": os.path.join(d, files["rigged_fbx"])}}


def step_animate(claim):
    d, files = claim["dir"], claim["files"]
    clips = [{"id": c["id"], "fbx_path": c["fbx_path"]} for c in claim.get("clips", [])]
    if not clips:
        raise RuntimeError("krok animate bez klipu")
    report = run_blender("fc_retarget.py", {
        "id": claim["character"]["id"],
        "rigged_fbx": os.path.join(d, files["rigged_fbx"]),
        "out_dir": d,
        "clips": clips,
    })
    return {"frame_ranges": report.get("ranges", {})}


def step_export_user(claim):
    d, files = claim["dir"], claim["files"]
    report = run_blender("fc_export.py", {
        "id": claim["character"]["id"],
        "blend": os.path.join(d, "animated.blend"),
        "out_dir": d,
        "preview": PREVIEW_MODE,
    })
    artifacts = {
        "final_glb": os.path.join(d, files["final_glb"]),
        "final_fbx": os.path.join(d, files["final_fbx"]),
        "tri_count": report.get("tri_count", 0),
    }
    for key, artifact in (("preview", "preview_mp4"), ("thumb", "thumb_png")):
        if report.get(key):
            artifacts[artifact] = os.path.join(d, report[key])
    return {"artifacts": artifacts}


def step_export_roblox(claim):
    d = claim["dir"]
    name = safe_slug(claim["character"])
    out_dir = os.path.join(d, "roblox")
    report = run_blender("fc_roblox_pack.py", {
        "id": claim["character"]["id"], "blend": os.path.join(d, "animated.blend"),
        "out_dir": out_dir, "name": name,
    })
    # Open Cloud upload je samostatny krok (plan 6.1) - bez klice zustava
    # balicek na disku a export se uzavre s cestou, ne s assetId.
    return {"artifact_path": os.path.join(out_dir, report.get("fbx", ""))}


def step_export_luanti(claim):
    d = claim["dir"]
    name = safe_slug(claim["character"])
    out_dir = os.path.join(d, "luanti")
    ranges = load_ranges(d)
    report = run_blender("fc_luanti_pack.py", {
        "id": claim["character"]["id"], "blend": os.path.join(d, "animated.blend"),
        "out_dir": out_dir, "name": name, "ranges": ranges,
    })
    return {"artifact_path": os.path.join(out_dir, report.get("glb", ""))}


def load_ranges(d):
    path = os.path.join(d, "retarget_ranges.json")
    if not os.path.exists(path):
        return {}
    with open(path) as f:
        return json.load(f).get("ranges", {})


def safe_slug(character):
    out = "".join(ch if ch.isalnum() else "_" for ch in character.get("name", "").lower())
    out = "_".join(p for p in out.split("_") if p)
    return out or character["id"]


HANDLERS = {
    "char.preprocess": step_preprocess,
    "char.mesh": step_mesh,
    "char.clean": step_clean,
    "char.rig": step_rig,
    "char.animate": step_animate,
    "char.export.user": step_export_user,
    "char.export.roblox": step_export_roblox,
    "char.export.luanti": step_export_luanti,
}


def main():
    print(f"ugc-fc worker: api={API} comfy={COMFY or '-'} poll={POLL_SECONDS}s", flush=True)
    while True:
        try:
            claim = api("/worker/fc/claim", payload={})
        except (urllib.error.URLError, OSError) as e:
            print(f"api nedostupne: {e}", flush=True)
            time.sleep(POLL_SECONDS)
            continue
        if claim is None:
            time.sleep(POLL_SECONDS)
            continue

        step, step_id = claim["step"], claim["step_id"]
        char_id = claim["character"]["id"]
        handler = HANDLERS.get(step)
        print(f"{step} {char_id} (pokus {claim.get('attempt', 1)})", flush=True)
        started = time.time()
        try:
            if handler is None:
                raise RuntimeError(f"neznamy krok {step}")
            result = handler(claim)
            api(f"/worker/fc/result/{step_id}", result)
            print(f"done {step} {char_id} za {time.time()-started:.0f}s", flush=True)
        except Exception as e:
            print(f"FAIL {step} {char_id}: {e}", flush=True)
            try:
                api(f"/worker/fc/result/{step_id}", {"error": str(e)})
            except Exception as e2:
                print(f"report failed too: {e2}", flush=True)


if __name__ == "__main__":
    main()
