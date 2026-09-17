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

import fc_pose

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
# auto | template | comfy. 'comfy' = MIA v ComfyUI na Sparku (bezi od 2026-09-15,
# viz FANTASYCHARACTER_PLAN.md 13), 'template' = sablona v Blenderu na JODA.
# Ani jedna nevyhrava vzdy - MIA u fotek cele postavy, sablona u brneni s
# plastem a orezanych postav - takze 'auto' udela obe a vybere podle skore.
RIG_MODE = os.environ.get("FC_RIG", "auto")
# Nad kolik stupnu odchylky klidove pozy od Mixamo kostry (boky a nohy, viz
# fc_retarget.CORE_BONES) se rig v auto rezimu nebere. Zmereno 2026-09-16 na
# peti postavach: sablona vzdy 3.9, MIA 14.9-26.7 - a prave u dvou postav,
# kde MIA vyhral na natazeni, byl vysledek v predklonu.
REST_OFFSET_MAX = float(os.environ.get("FC_RIG_REST_OFFSET_MAX", "10"))
# Jak dlouho cekat, nez se restartujici ComfyUI zvedne, nez krok vzdame:
# 30 pokusu po 20 s = 10 minut (start s nactenim modelu trva pres minutu).
COMFY_RETRIES = int(os.environ.get("FC_COMFY_RETRIES", "30"))
COMFY_RETRY_DELAY = int(os.environ.get("FC_COMFY_RETRY_DELAY", "20"))
# Ridici A-pose fotka pro Wan Animate (fc_pose.repose_graph) - jak vznikla,
# viz blender_scripts/fc_apose_driver.py a docs/FANTASYCHARACTER_PLAN.md 14.
APOSE_DRIVER = os.environ.get("FC_APOSE_DRIVER", "/app/assets/apose_driver.png")
# V rezimu auto je MIA jen jedna z moznosti; kdyz ComfyUI ceka na cizi ulohy,
# nema smysl drzet pipeline pul hodiny - sablona je hotova za par sekund.
RIG_MIA_TIMEOUT = int(os.environ.get("FC_RIG_MIA_TIMEOUT", "300"))

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

# Jak se jmenuje vstupni parametr, zavisi na nodu: LoadImage ma "image",
# UniRigLoadMesh "file_path". Titulek proto rika, KTERY nod dostane vstup, a
# parametr se vybere ten, ktery uz v nodu je. U rig kroku je vstupem mesh,
# takze natvrdo psane "image" tam nikdy nesedelo.
INPUT_KEYS = ("image", "file_path", "glb_path", "mesh", "model_file", "path")


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


def set_titled_source(workflow, title, value):
    """Preda vstup nodu podle titulku, do parametru, ktery ten nod ma.
    Vraci pocet nodu, ktere sedly."""
    hits = 0
    for node in workflow.values():
        if not isinstance(node, dict):
            continue
        if node.get("_meta", {}).get("title") != title:
            continue
        inputs = node.setdefault("inputs", {})
        key = next((k for k in INPUT_KEYS if k in inputs), INPUT_KEYS[0])
        inputs[key] = value
        hits += 1
    return hits


def comfy_wait_until_up(attempts=COMFY_RETRIES, delay=COMFY_RETRY_DELAY):
    """Pocka, nez se ComfyUI zvedne. Bezi na Sparku, ktery si delime s
    dalsimi klienty a obcas se restartuje - behem restartu odpovida
    "Connection refused" a bez cekani by se za par minut sesypala cela
    fronta (zmereno 2026-09-17: jeden vypadek shodil 13 postav v rade,
    kazdou po treti neuspesne zkousce)."""
    last = None
    for attempt in range(attempts):
        try:
            with urllib.request.urlopen(COMFY + "/queue", timeout=30):
                return True
        except urllib.error.HTTPError:
            return True                  # odpovida, jen jinak - to nam staci
        except Exception as e:           # URLError, socket timeout, reset
            last = e
            if attempt + 1 < attempts:
                print(f"  ComfyUI nedostupne ({e}), zkousim za {delay}s "
                      f"({attempt + 1}/{attempts})", flush=True)
                time.sleep(delay)
    raise RuntimeError(f"ComfyUI nedostupne ani po {attempts} pokusech: {last}")


def comfy_open(req, timeout):
    """urlopen, ktery prezije restart ComfyUI. HTTP chyby (400, 404) jdou
    dal beze zmeny - to je odpoved serveru, ne vypadek."""
    try:
        return urllib.request.urlopen(req, timeout=timeout)
    except urllib.error.HTTPError:
        raise
    except Exception:
        comfy_wait_until_up()
        return urllib.request.urlopen(req, timeout=timeout)


def comfy_post(path, payload):
    """ComfyUI vraci duvod odmitnuti (chybejici vstup, neznamy soubor, graf
    bez vystupu) v tele 400 - bez nej v chybe kroku zbyde jen "Bad Request"."""
    req = urllib.request.Request(COMFY + path, data=json.dumps(payload).encode(),
                                 headers={"Content-Type": "application/json"})
    try:
        with comfy_open(req, 60) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", "replace")[:800]
        raise RuntimeError(f"ComfyUI {path} {e.code}: {body}") from None


def comfy_get(path):
    with comfy_open(COMFY + path, 60) as resp:
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
    with comfy_open(req, 300) as resp:
        out = json.load(resp)
    sub = out.get("subfolder") or ""
    return "%s/%s" % (sub, out["name"]) if sub else out["name"]


def comfy_run(step, image_path, timeout=None):
    """Nacte staticky workflow ze souboru (nas/workflows/), napoji obrazek
    pres titulek FC_INPUT_IMAGE a posle."""
    workflow, name = load_workflow(step)
    if image_path:
        uploaded = comfy_upload(image_path)
        if not set_titled_source(workflow, TITLE_INPUT_IMAGE, uploaded):
            raise RuntimeError(f"{name}: zadny nod s titulkem {TITLE_INPUT_IMAGE}")
    return comfy_submit(workflow, name, timeout)


def comfy_submit(workflow, label, timeout=None):
    """Posle uz hotovy graf (staveny primo v Pythonu - fc_pose.py, nebo
    nacteny ze souboru pres comfy_run) a pocka na vysledek. Vraci seznam
    (filename, subfolder, type) vsech vystupu, ktere ComfyUI zapsal.

    Kdyz nedobehne vcas, prompt se z fronty smaze: ComfyUI na Sparku sdili
    frontu s jinymi klienty a opusteny prompt by tam jinak cekal a pak zbytecne
    bezel."""
    timeout = COMFY_TIMEOUT if timeout is None else timeout
    if not COMFY:
        raise RuntimeError(f"{label}: FC_COMFY_URL neni nastavene")
    unique_outputs(workflow, uuid.uuid4().hex[:12])
    prompt_id = comfy_post("/prompt", {"prompt": workflow})["prompt_id"]
    deadline = time.time() + timeout
    while time.time() < deadline:
        history = comfy_get(f"/history/{prompt_id}")
        entry = history.get(prompt_id)
        if entry:
            status = entry.get("status", {})
            if status.get("status_str") == "error":
                raise RuntimeError(f"{label}: ComfyUI hlasi chybu, prompt {prompt_id}")
            if status.get("completed") or entry.get("outputs"):
                return collect_outputs(entry.get("outputs", {})) + prefix_candidates(workflow)
        time.sleep(3)
    try:
        comfy_post("/queue", {"delete": [prompt_id]})
    except (RuntimeError, urllib.error.URLError, OSError):
        pass
    raise RuntimeError(f"{label}: ComfyUI nedobehl do {timeout}s (prompt {prompt_id})")


def unique_outputs(workflow, token):
    """Da vystupum tohoto behu vlastni jmeno.

    ComfyUI cisluje soubory pod jednim prefixem postupne (_00001_, _00002_,
    ...), ale prefix_candidates umi odhadnout jen _00001_. Se sdilenym
    "3D/fc_mesh" tak kazda dalsi postava stahla mesh prvni - druha fotka
    dostala zase Test Knighta, ackoliv TRELLIS jeji mesh vyrobil spravne
    jako fc_mesh_00002_.glb (2026-09-11). S unikatnim prefixem je _00001_
    vzdy soubor tohoto behu, stejne jako u ugc-pipeline, ktera prefix
    odvozuje z id jobu."""
    for node in workflow.values():
        if not isinstance(node, dict):
            continue
        inputs = node.get("inputs") or {}
        for key in ("filename_prefix", "fbx_name"):
            value = inputs.get(key)
            if isinstance(value, str) and value:
                inputs[key] = f"{value}_{token}"


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
        if node.get("class_type") == "SavePoseKpsAsJsonFile":
            # Vlastni save_pose_kps() nejmenuje soubor jako ostatni savery
            # (zadne podtrzitko pred priponou): "{filename}_{counter:05}.json"
            # - overeno ve zdrojaku node_wrappers/pose_keypoint_postprocess.py,
            # ne za behu (viz fc_pose.py, ComfyUI na Sparku bylo vypnute).
            out.append((f"{base}_00001.json", subfolder, "output"))
            continue
        fmt = (node.get("inputs") or {}).get("file_format")
        exts = [fmt] if isinstance(fmt, str) and fmt else ["glb", "fbx", "png"]
        for ext in exts:
            out.append((f"{base}_00001_.{ext}", subfolder, "output"))
    for node in workflow.values():
        if not isinstance(node, dict):
            continue
        # MIAAutoRig si FBX pojmenuje sam podle vzoru "<fbx_name>_mia.fbx"
        # a neni output node, takze v history po nem taky nic nezustane.
        name = (node.get("inputs") or {}).get("fbx_name")
        if isinstance(name, str) and name:
            out.append((f"{name}_mia.fbx", "", "output"))
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
    with comfy_open(f"{COMFY}/view?{q}", 300) as resp, open(dst, "wb") as f:
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

    report = {}
    try:
        report = fix_pose(d, src)
    except Exception as e:
        # Oprava pozy je vylepseni pred RMBG, ne nutnost - kdyz selze (na
        # fotce neni videt clovek, ComfyUI nema DWPose/Fill/Kontext), krok
        # pokracuje se zdrojem rovnou na RMBG jako pred plan 14.
        report = {"error": str(e)[:300]}
        print(f"  preprocess: oprava pozy preskocena ({report['error']})", flush=True)
    current = report.get("current", src)

    out = comfy_fetch(pick_output(comfy_run("char.preprocess", current), ".png", ".jpg"),
                      os.path.join(d, files["apose_image"]))
    with open(os.path.join(d, "preprocess_report.json"), "w") as f:
        json.dump({k: v for k, v in report.items() if k != "current"}, f, indent=2)
    return {"artifacts": {"apose_image": out}}


def fix_pose(out_dir, image_path):
    """DWPose zmeri, jestli jsou paze srostle s telem nebo chybi nohy pod
    kotniky, a podle toho pred RMBG pusti FLUX Fill (domysli nohy) a/nebo
    FLUX Kontext (A-poze) - viz fc_pose.py a docs/FANTASYCHARACTER_PLAN.md
    sekce 14. Vraci {"metrics", "stages", "current"}; "current" je posledni
    obrazek (== image_path, kdyz se nic neaplikovalo)."""
    stages = []
    image_path, trim = trim_bars(out_dir, image_path)
    if trim:
        stages.append(trim)
    kps, w, h = detect_pose(out_dir, image_path)
    if kps is None:
        return {"metrics": {"error": "DWPose nikoho nenasel"}, "stages": stages, "current": image_path}
    metrics = fc_pose.pose_metrics(kps)
    current = image_path

    margins = fc_pose.outpaint_margins(metrics, w, h)
    if any(margins.values()):
        uploaded = comfy_upload(current)
        graph = fc_pose.outpaint_graph(uploaded, margins, fc_pose.OUTPAINT_PROMPT,
                                       fc_pose.POSE_FIX_SEED, "fc/outpaint")
        outs = comfy_submit(graph, "outpaint " + json.dumps(margins))
        current = comfy_fetch(pick_output(outs, ".png"), os.path.join(out_dir, "pose_outpaint.png"))
        stages.append({"stage": "outpaint", **margins})

    if fc_pose.needs_arm_reshape(metrics):
        current, stage = reshape_arms(out_dir, current, metrics)
        stages.append(stage)

    return {"metrics": metrics, "stages": stages, "current": current}


def trim_bars(out_dir, image_path):
    """Odrizne jednobarevne pruhy nahore/dole (screenshot z telefonu) -
    blender_scripts/fc_trim_bars.py, rozhoduje fc_pose.bar_bounds. Vraci
    (obrazek, zaznam do reportu nebo None); kdyz neni co riznout, vraci
    puvodni cestu."""
    out = os.path.join(out_dir, "source_trim.png")
    report = run_blender("fc_trim_bars.py", {"id": os.path.basename(out_dir) + "-trim",
                                             "image": image_path, "out": out})
    if not report.get("written"):
        return image_path, None
    print(f"  preprocess: pruhy odriznuty {report}", flush=True)
    return out, {"stage": "trim_bars", "top": report["top"], "bottom": report["bottom"]}


def reshape_arms(out_dir, image_path, source_metrics):
    """Odtahne paze od tela: Wan Animate prepozovani (pose_repose.png), a
    protoze zadny generator neposlechne vzdy, vystup se znovu zmeri DWPose.
    Kontext (pose_apose.png) uz jen jako zaloha, kdyz Wan neprojde - sam
    o sobe uspel u 4 z 12 postav (plan sekce 14). Vraci (obrazek, zaznam do
    reportu); obrazek je puvodni, kdyz zadny kandidat neni lepsi nez zdroj."""
    candidates, files = [], {}

    def measure(name, path):
        kps, _, _ = detect_pose(out_dir, path, f"pose_kps_{name}.json")
        m = fc_pose.pose_metrics(kps) if kps is not None else {"error": "DWPose nikoho nenasel"}
        candidates.append((name, m))
        files[name] = path
        print(f"  preprocess: {name} -> {m}", flush=True)

    try:
        uploaded, driver = comfy_upload(image_path), comfy_upload(APOSE_DRIVER)
        graph = fc_pose.repose_graph(uploaded, driver, fc_pose.POSE_FIX_SEED, "fc/repose")
        outs = comfy_submit(graph, "A-pose (Wan Animate)")
        last = max((o for o in outs if o[0].lower().endswith(".png")), key=lambda o: o[0])
        measure("wan_repose", comfy_fetch(last, os.path.join(out_dir, "pose_repose.png")))
    except Exception as e:
        candidates.append(("wan_repose", {"error": str(e)[:300]}))
        print(f"  preprocess: Wan Animate selhal ({candidates[-1][1]['error']})", flush=True)

    if not any(fc_pose.apose_accepted(m) for _, m in candidates):
        try:
            uploaded = comfy_upload(image_path)
            graph = fc_pose.kontext_graph(uploaded, fc_pose.KONTEXT_APOSE_PROMPT,
                                          fc_pose.POSE_FIX_SEED, "fc/apose")
            outs = comfy_submit(graph, "A-pose (Kontext)")
            measure("kontext_apose", comfy_fetch(pick_output(outs, ".png"), os.path.join(out_dir, "pose_apose.png")))
        except Exception as e:
            candidates.append(("kontext_apose", {"error": str(e)[:300]}))
            print(f"  preprocess: Kontext selhal ({candidates[-1][1]['error']})", flush=True)

    choice = fc_pose.pick_reshape(source_metrics, candidates)
    stage = {"stage": "arm_reshape", "choice": choice,
             "candidates": [{"name": n, **m} for n, m in candidates]}
    return (files[choice] if choice else image_path), stage


def detect_pose(out_dir, image_path, kps_name="pose_kps.json"):
    """DWPose na lokalnim souboru; bez bbox detektoru je pomalejsi, ale
    najde i postavy, ktere yolox mine (stejna zachrana jako tools/drive.py
    ve video-stacku). Vraci (klouby, sirka, vyska) nebo (None, sirka, vyska),
    kdyz DWPose nikoho nenasel ani na druhy pokus."""
    w, h = fc_pose.image_size(image_path)
    for bbox in ("yolox_l.onnx", "None"):
        uploaded = comfy_upload(image_path)
        graph = fc_pose.pose_graph(uploaded, "fc/pose", bbox)
        outs = comfy_submit(graph, f"pose detect ({bbox})")
        path = comfy_fetch(pick_output(outs, ".json"), os.path.join(out_dir, kps_name))
        with open(path) as f:
            kps = fc_pose.parse_pose_keypoints(json.load(f), w, h)
        if kps is not None:
            return kps, w, h
    return None, w, h


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


def rig_template(claim, out_dir):
    d, files = claim["dir"], claim["files"]
    report = run_blender("fc_rig_template.py", {
        "id": claim["character"]["id"],
        "glb": os.path.join(d, files["clean_glb"]),
        "out_dir": out_dir,
    })
    # Sablona predpoklada humanoida; kdyz mesh nesedi, rig vznikne, ale bude
    # divny. Varovani patri do logu, at se to pozna driv nez na modelu.
    if report.get("unweighted_verts") and report.get("vert_count"):
        pct = 100.0 * report["unweighted_verts"] / report["vert_count"]
        if pct > 25:
            report.setdefault("fit_warnings", []).append(f"{pct:.0f} % vrcholu bez vahy")
    return report


def rig_mia(claim, out_dir, timeout=None):
    """MIA vraci mesh ve svem normalizovanem meritku a cast vrcholu bez vahy;
    fc_rig_mia.py z toho udela rigged.fbx stejneho tvaru jako sablona."""
    d, files = claim["dir"], claim["files"]
    os.makedirs(out_dir, exist_ok=True)
    raw = comfy_fetch(pick_output(comfy_run("char.rig", os.path.join(d, files["clean_glb"]), timeout),
                                  ".fbx"),
                      os.path.join(out_dir, "rigged_mia_raw.fbx"))
    return run_blender("fc_rig_mia.py", {
        "id": claim["character"]["id"],
        "fbx": raw,
        "clean_glb": os.path.join(d, files["clean_glb"]),
        "out_dir": out_dir,
    })


def score_rig(claim, rig_dir, clip):
    """Nasadi na rig klip a zmeri, jak se mesh trha (fc_rig_score.py) a jak
    daleko je klidova poza rigu od Mixamo kostry (rest_offset_deg z
    retargetu) - obe cisla rozhoduji v choose_rig."""
    atlas = os.path.join(claim["dir"], "clean_tex.png")
    if os.path.exists(atlas):
        shutil.copy(atlas, os.path.join(rig_dir, "clean_tex.png"))
    retarget = run_blender("fc_retarget.py", {
        "id": claim["character"]["id"],
        "rigged_fbx": os.path.join(rig_dir, "rigged.fbx"),
        "out_dir": rig_dir,
        "clips": [{"id": clip["id"], "fbx_path": clip["fbx_path"]}],
    })
    blend = os.path.join(rig_dir, "animated.blend")
    try:
        score = run_blender("fc_rig_score.py", {"id": claim["character"]["id"], "blend": blend})
        score["rest_offset_deg"] = retarget.get("rest_offset_deg")
        return score
    finally:
        for name in ("animated.blend", "animated.blend1"):
            path = os.path.join(rig_dir, name)
            if os.path.exists(path):
                os.remove(path)            # 5 MB na kandidata, ke dni nepotreba


def choose_rig(candidates):
    """Vybere rig, ktery klip reprodukuje - a teprve mezi takovymi ten s
    nejmensim natazenim hran.

    Natazeni samo nestaci: retarget miri kosti tam, kam miri ve zdroji, takze
    kdyz ma rig klidovou pozu jinde nez Mixamo kostra (rest_offset_deg), mesh
    se o ten rozdil natoci navic v kazdem snimku - postava se hrbi a kolena
    krci vic nez mannequin, a hrany se pritom netrhaji, takze stretch to
    nevidi. Zmereno 2026-09-16 na tancici figurce: MIA rig 27 stupnu na
    stehnech (stretch 1.108) proti sablone 4 stupne (1.133) - vyhral MIA a
    vysledek byl viditelne v predklonu (plan sekce 16).

    candidates: {jmeno: {"report", "score", "error"}}. Rig bez skore (selhal
    klip nebo mereni) prohrava s kazdym, ktery skore ma; kdyz nema skore
    nikdo, vyhrava sablona - je deterministicka a nezavisi na Sparku.
    Vraci jmeno, nebo None, kdyz se nepovedl zadny rig."""
    built = {n: c for n, c in candidates.items() if not c.get("error")}
    if not built:
        return None
    scored = {n: c["score"]["stretch_mean"] for n, c in built.items()
              if c.get("score") and c["score"].get("stretch_mean") is not None}
    if not scored:
        return "template" if "template" in built else sorted(built)[0]

    def aligned(name):
        off = (built[name].get("score") or {}).get("rest_offset_deg")
        return off is None or off <= REST_OFFSET_MAX   # bez mereni se rig nediskvalifikuje

    ok = [n for n in scored if aligned(n)]
    pool = ok or list(scored)          # kdyz neprojde nikdo, rozhoduje jako driv natazeni
    return min(pool, key=lambda n: (scored[n], n != "template"))


def install_rig(claim, rig_dir, extra):
    """Zvoleny rig na misto, kde ho ceka animate: rigged.fbx (+ .fbm s
    texturami) a rig_report.json s informaci, proc vyhral."""
    d, files = claim["dir"], claim["files"]
    shutil.copy(os.path.join(rig_dir, "rigged.fbx"), os.path.join(d, files["rigged_fbx"]))
    fbm = os.path.join(rig_dir, "rigged.fbm")
    if os.path.isdir(fbm):
        shutil.rmtree(os.path.join(d, "rigged.fbm"), ignore_errors=True)
        shutil.copytree(fbm, os.path.join(d, "rigged.fbm"))
    report_path = os.path.join(rig_dir, "rig_report.json")
    report = {}
    if os.path.exists(report_path):
        with open(report_path) as f:
            report = json.load(f)
    report.update(extra)
    with open(os.path.join(d, "rig_report.json"), "w") as f:
        json.dump(report, f, indent=2)
    return report


def step_rig(claim):
    d, files = claim["dir"], claim["files"]
    if RIG_MODE in ("template", "comfy"):
        report = rig_template(claim, d) if RIG_MODE == "template" else rig_mia(claim, d)
        for w in report.get("fit_warnings", []):
            print(f"  rig varovani: {w}", flush=True)
        return {"artifacts": {"rigged_fbx": os.path.join(d, files["rigged_fbx"])}}

    clips = claim.get("clips") or []
    candidates = {}
    for name, build in (("template", lambda out: rig_template(claim, out)),
                        ("mia", lambda out: rig_mia(claim, out, RIG_MIA_TIMEOUT))):
        out = os.path.join(d, f"rig_{name}")
        os.makedirs(out, exist_ok=True)
        entry = {}
        try:
            entry["report"] = build(out)
        except Exception as e:           # MIA muze chybet, sablona na meshi selhat
            entry["error"] = str(e)[:300]
            print(f"  rig {name} selhal: {entry['error']}", flush=True)
        if "error" not in entry and clips:
            try:
                entry["score"] = score_rig(claim, out, clips[0])
            except Exception as e:
                entry["score_error"] = str(e)[:300]
                print(f"  skore {name} selhalo: {entry['score_error']}", flush=True)
        candidates[name] = entry

    choice = choose_rig(candidates)
    if choice is None:
        raise RuntimeError("zadny rig se nepovedl: " + "; ".join(
            f"{n}: {c.get('error')}" for n, c in candidates.items()))
    summary = {n: (c.get("score") or {"error": c.get("error") or c.get("score_error")})
               for n, c in candidates.items()}
    print(f"  rig: vybran {choice} {json.dumps(summary)}", flush=True)
    report = install_rig(claim, os.path.join(d, f"rig_{choice}"), {
        "rig_mode": "auto", "rig_choice": choice,
        "rig_clip": clips[0]["id"] if clips else None, "rig_scores": summary,
    })
    for w in report.get("fit_warnings", []):
        print(f"  rig varovani: {w}", flush=True)
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
