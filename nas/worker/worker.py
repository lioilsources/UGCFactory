"""ugc-blender worker: poll -> blender convert -> validate -> report.

Files travel on the shared /data volume; the API only hands out job rows and
receives the verdict. Stateless - kill it any time, an interrupted job stays
'converting' and the requeue cron (or manual approve) revives it.
"""
import json
import os
import subprocess
import sys
import time
import urllib.request
import urllib.error

API = os.environ.get("UGC_API", "http://ugc-api:8095")
DATA = os.environ.get("UGC_DATA", "/data")
SPEC = os.environ.get("UGC_SPEC", "/app/spec/roblox_spec.json")
SCRIPTS = os.environ.get("UGC_SCRIPTS", "/app/blender_scripts")
POLL_SECONDS = int(os.environ.get("UGC_POLL_SECONDS", "10"))
BLENDER_TIMEOUT = int(os.environ.get("UGC_BLENDER_TIMEOUT", "900"))

sys.path.insert(0, SCRIPTS)
from validate import verdict as validate_verdict  # noqa: E402


def api(path, payload=None, method=None):
    req = urllib.request.Request(API + path, method=method or ("POST" if payload is not None else "GET"))
    body = None
    if payload is not None:
        body = json.dumps(payload).encode()
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, body, timeout=30) as resp:
        if resp.status == 204:
            return None
        return json.load(resp)


def convert(job):
    job_id = job["id"]
    out_dir = os.path.join(DATA, "converted", job_id)
    job_file = os.path.join(DATA, "jobs", f"{job_id}.json")
    os.makedirs(os.path.dirname(job_file), exist_ok=True)
    with open(job_file, "w") as f:
        json.dump({
            "id": job_id,
            "category": job.get("category", "hat"),
            "backend": job.get("backend", ""),
            "symmetry": job.get("symmetry", ""),
            "glb": os.path.join(DATA, "incoming", job_id, "model.glb"),
            "out_dir": out_dir,
            "spec": SPEC,
        }, f)

    cmd = ["blender", "-b", "--factory-startup", "-noaudio",
           "-P", os.path.join(SCRIPTS, "convert.py"), "--", "--job", job_file]
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=BLENDER_TIMEOUT)
    if proc.returncode != 0:
        tail = (proc.stderr or proc.stdout).strip().splitlines()[-5:]
        raise RuntimeError("blender: " + " | ".join(tail))

    with open(os.path.join(out_dir, "report.json")) as f:
        report = json.load(f)
    v, reasons = validate_verdict(report)
    report["verdict_reasons"] = [r for _, r in reasons]
    return v, report


def main():
    print(f"ugc-blender worker: api={API} poll={POLL_SECONDS}s", flush=True)
    while True:
        try:
            job = api("/worker/claim", payload={})
        except (urllib.error.URLError, OSError) as e:
            print(f"api nedostupne: {e}", flush=True)
            time.sleep(POLL_SECONDS)
            continue
        if job is None:
            time.sleep(POLL_SECONDS)
            continue

        job_id = job["id"]
        print(f"converting {job_id} ({job.get('category')})", flush=True)
        started = time.time()
        try:
            v, report = convert(job)
            api(f"/worker/result/{job_id}", {"verdict": v, "report": report})
            print(f"done {job_id}: {v} in {time.time()-started:.0f}s", flush=True)
        except Exception as e:
            print(f"FAIL {job_id}: {e}", flush=True)
            try:
                api(f"/worker/result/{job_id}", {"verdict": "FAIL", "error": str(e), "report": {}})
            except Exception as e2:
                print(f"report failed too: {e2}", flush=True)


if __name__ == "__main__":
    main()
