#!/bin/bash
# Golden test konverzni pipeline - bezi v ugc-blender containeru (x86_64, CI-friendly):
#   docker build -f worker/Dockerfile -t ugc-blender:latest .
#   ./golden_test.sh
set -e
cd "$(dirname "$0")"
WORK=$(mktemp -d)
trap "rm -rf $WORK" EXIT
mkdir -p "$WORK/incoming/golden" "$WORK/jobs"

docker run --rm -v "$WORK:/data" -v "$PWD/testdata:/testdata:ro" ugc-blender:latest \
  blender -b --factory-startup -noaudio -P /testdata/gen_reference.py -- /data/incoming/golden/model.glb

cat > "$WORK/jobs/golden.json" <<JSON
{"id":"golden","category":"hat","backend":"","glb":"/data/incoming/golden/model.glb",
 "out_dir":"/data/converted/golden","spec":"/app/spec/roblox_spec.json"}
JSON

docker run --rm -v "$WORK:/data" ugc-blender:latest \
  blender -b --factory-startup -noaudio -P /app/blender_scripts/convert.py -- --job /data/jobs/golden.json

docker run --rm -v "$WORK:/data" ugc-blender:latest \
  python3 /app/blender_scripts/validate.py /data/converted/golden/report.json

test -s "$WORK/converted/golden/model.fbx" || { echo "FBX chybi"; exit 1; }
test -s "$WORK/converted/golden/model_tex.png" || { echo "textura chybi"; exit 1; }
python3 - "$WORK/converted/golden/report.json" <<'PY'
import json, sys
r = json.load(open(sys.argv[1]))
assert r["tri_count"] <= r["max_tris"], f"tris {r['tri_count']}"
assert r["uv_ok"], "UV se nevytvorily"
print("GOLDEN OK:", r["tri_count"], "tris, uv_ok, texture", r["texture_size"])
PY
