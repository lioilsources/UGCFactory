"""Zaregistruje FBX klipy z /data/animlib do knihovny animaci.

    python3 seed_animlib.py --dir /data/animlib --source mixamo \
        --license mixamo-embedded [--api http://joda:8095] [--key <FC_API_KEY>]

Samotne stazeni je rucni krok (plan 4.3): Mixamo nema API a automatizovane
stahovani je proti ToS Adobe. Tohle jen popise, co uz na disku lezi.

Kategorie se hada z nazvu souboru, protoze Mixamo exportuje 'Walking.fbx' a
prejmenovavat 50 souboru rucne je horsi nez jeden slovnik. Co se netrefi,
spadne do 'misc' a da se opravit pres PUT /v1/fc/animations/{id}.

Licence neni volitelna: export pro platici uzivatele filtruje prave podle ni,
takze Mixamo klipy se nesmi zamichat s CC0 sadou.
"""
import argparse
import json
import os
import re
import sys
import urllib.request

# Kmeny, ne cela slova: Mixamo jmenuje klipy prubehove ("Dancing", "Walking"),
# takze vzor "dance" by "Hip Hop Dancing" minul.
CATEGORY_HINTS = [
    ("idle", ("idle", "breathing", "standing")),
    ("locomotion", ("walk", "run", "jog", "jump", "crouch", "climb", "strafe", "sprint")),
    ("combat", ("attack", "punch", "kick", "slash", "stab", "hit", "death", "dying",
                "block", "fall", "impact", "damage", "stun")),
    ("emote", ("danc", "wav", "sit", "clap", "cheer", "salut", "taunt", "bow_", "point")),
]
# Loop se pozna z kmene, ne z kategorie: skok je taky locomotion, ale
# zacyklit ho znamena postavu, ktera skace porad dokola.
LOOPING = ("idle", "walk", "run", "jog", "sprint", "breathing", "strafe", "crouch")


def slugify(name):
    slug = re.sub(r"[^a-z0-9]+", "_", os.path.splitext(name)[0].lower()).strip("_")
    return slug or "clip"


def categorize(slug):
    for category, hints in CATEGORY_HINTS:
        if any(h in slug for h in hints):
            return category
    return "misc"


def put(api, key, animation):
    req = urllib.request.Request(
        f"{api}/v1/fc/animations/{animation['id']}",
        data=json.dumps(animation).encode(), method="PUT",
        headers={"Content-Type": "application/json"})
    if key:
        req.add_header("X-API-Key", key)
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.load(resp)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default="/data/animlib")
    ap.add_argument("--api", default=os.environ.get("UGC_API", "http://localhost:8095"))
    ap.add_argument("--key", default=os.environ.get("FC_API_KEY", ""))
    ap.add_argument("--source", default="mixamo")
    ap.add_argument("--license", required=True,
                    help="napr. mixamo-embedded nebo cc0 - podle nej filtruje export")
    ap.add_argument("--fps", type=int, default=30)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    fbx = sorted(f for f in os.listdir(args.dir) if f.lower().endswith(".fbx"))
    if not fbx:
        sys.exit(f"v {args.dir} nejsou zadne .fbx klipy")

    for name in fbx:
        slug = slugify(name)
        category = categorize(slug)
        # sidecar JSON prebiji hadani: {"name","category","frames","loop","tags"}
        sidecar = os.path.join(args.dir, os.path.splitext(name)[0] + ".json")
        extra = {}
        if os.path.exists(sidecar):
            with open(sidecar) as f:
                extra = json.load(f)
        animation = {
            "id": slug,
            "name": extra.get("name") or os.path.splitext(name)[0],
            "category": extra.get("category") or category,
            "source": args.source,
            "license": args.license,
            "fbx_path": os.path.join(args.dir, name),
            "preview_gif": extra.get("preview_gif", ""),
            "frames": int(extra.get("frames", 0)),
            "fps": int(extra.get("fps", args.fps)),
            "loop": bool(extra.get("loop", any(stem in slug for stem in LOOPING))),
            "tags": extra.get("tags", []),
        }
        if args.dry_run:
            print(json.dumps(animation, ensure_ascii=False))
            continue
        put(args.api, args.key, animation)
        print(f"{slug:<24} {animation['category']:<12} {name}")

    print(f"{len(fbx)} klipu v knihovne")


if __name__ == "__main__":
    main()
