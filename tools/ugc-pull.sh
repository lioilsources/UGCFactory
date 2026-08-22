#!/bin/bash
# Stahne zabalene itemy z ugc-api do ~/UGC/inbox/<id>/ pro import do Studia.
#
#   ./tools/ugc-pull.sh              # vse ve stavu packed
#   ./tools/ugc-pull.sh <job-id>     # jeden konkretni
#   UGC_API=https://ugc.ol1n.com ./tools/ugc-pull.sh   # pres tunel
#
# Pres tunel je potreba Access service token (stejny jako v app/.cf-token):
#   export CF_CLIENT_ID=... CF_CLIENT_SECRET=...
set -euo pipefail

API="${UGC_API:-http://joda.tailde0de8.ts.net:8095}"
DEST="${UGC_INBOX:-$HOME/UGC/inbox}"

# Pozor: macOS ma bash 3.2, kde "${AUTH[@]}" na prazdnem poli pod set -u
# spadne na "unbound variable" - proto vsude zapis ${AUTH[@]+"${AUTH[@]}"}.
AUTH=()
if [ -n "${CF_CLIENT_ID:-}" ]; then
	AUTH=(-H "CF-Access-Client-Id: $CF_CLIENT_ID"
	      -H "CF-Access-Client-Secret: ${CF_CLIENT_SECRET:-}")
fi

mkdir -p "$DEST"

if [ $# -gt 0 ]; then
	IDS="$*"
else
	IDS=$(curl -fsS ${AUTH[@]+"${AUTH[@]}"} "$API/jobs?status=packed" |
		python3 -c 'import json,sys; print(" ".join(j["id"] for j in json.load(sys.stdin)))')
fi

[ -z "${IDS// /}" ] && { echo "Nic ve stavu packed."; exit 0; }

for id in $IDS; do
	out="$DEST/$id"
	if [ -d "$out" ]; then
		echo "  = $id (uz stazeno)"
		continue
	fi
	tmp=$(mktemp -d)
	if curl -fsS ${AUTH[@]+"${AUTH[@]}"} -o "$tmp/bundle.zip" "$API/packed/$id/download"; then
		mkdir -p "$out"
		unzip -qo "$tmp/bundle.zip" -d "$out"
		name=$(python3 -c "
import json,sys
try: print(json.load(open('$out/item.json'))['name'])
except Exception: print('$id')")
		echo "  + $name  ($out)"
	else
		echo "  ! $id se nepodarilo stahnout"
	fi
	rm -rf "$tmp"
done

echo
echo "Hotovo -> $DEST"
echo "Ve Studiu: Avatar -> Accessory Fitting Tool -> Load Mesh/Model -> vyber .fbx"
