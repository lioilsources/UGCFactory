# ugc-backend

Srdce UGC továrny na NAS (JODA): Spark sem pushuje vygenerované GLB, Flutter
appka je triaguje, blender worker konvertuje schválené na Roblox FBX a Mac si
stahuje hotové balíčky pro Studio. Viz UGC_NAS_PLAN.md / UGC_FORGE_PLAN.md.

```
Spark ──POST /jobs──▶ ugc-api ◀──SSE/triage── Flutter appka
                        │  ▲
              /worker/claim │ verdict
                        ▼  │
                   ugc-blender (headless Blender, CPU bake)
                        │
                 /data/packed/{id}/ ──GET /packed/{id}/download──▶ Mac (Studio)
```

## Služby (ugc-stack.yaml)

| Služba | Co dělá |
|---|---|
| `ugc-api` | Go, :8095 — joby, triage, katalog, SSE, pack, proxy na Spark |
| `ugc-blender` | worker: poll → `blender -b convert.py` → validate → verdict |
| `cloudflared` | dedikovaný tunnel `ugc-nas` → ugc.ol1n.com (vzor finetune) |

Storage: `/media/storage/ugc/{incoming,converted,packed,rejected,jobs}` +
`ugc.db` (SQLite WAL). Jediný cenný adresář je `packed/` — patří do NAS záloh.

## API kontrakt

- `POST /jobs` — multipart `glb` + `preview` + `meta` (JSON: id, prompt,
  category, style, backend, seed, collection)
- `GET /jobs?status=…`, `GET /jobs/{id}`, `GET /jobs/{id}/preview|glb`
- `POST /jobs/{id}/approve` — stage-aware: `new`→konverze, `converted`→pack
- `POST /jobs/{id}/reject`, `POST /jobs/{id}/reroll` (→ Spark, stejný prompt)
- `POST /generate` — proxy na Spark ImageStudio (batch composer z appky)
- `GET /items`, `PATCH /items/{id}` — katalog (název, cena, tagy, limited)
- `GET /packed/{id}/download` — zip pro Mac
- `GET /events` — SSE stream; `GET /healthz`
- interní: `POST /worker/claim`, `POST /worker/result/{id}`

Stavy jobu: `new → approved → converting → converted(PASS/WARN/FAIL) → packed`,
odbočky `rejected`, `rerolled`, `failed`.

## Deploy na JODA

```bash
rsync -a --exclude .git . joda:~/deploy/ugc-backend/
ssh joda "cd ~/deploy/ugc-backend && cp -n .env.example .env && docker compose -f ugc-stack.yaml up -d --build"
```

Tunnel (jednorázově, na JODA — cert.pem už tam je):

```bash
cloudflared tunnel create ugc-nas
cloudflared tunnel route dns ugc-nas ugc.ol1n.com
cp ~/.cloudflared/<TUNNEL_ID>.json ~/deploy/ugc-backend/cloudflared/credentials.json
# do cloudflared/config.yml doplnit TUNNEL_ID a AUD_TAG z Access aplikace
```

Cloudflare Access (dashboard, jednorázově): app `ugc` pro ugc.ol1n.com,
policy Service Auth (service tokeny: spark, app) + Allow (owner e-mail);
AUD tag aplikace patří do `cloudflared/config.yml` (vynucení už na konektoru).

## Konverze (blender_scripts/)

`convert.py`: import GLB → cleanup → voxel remesh (mimo sf3d) + decimate na
0.9×limit → Smart UV (pokud chybí) → CPU bake 1024 px přes EMIT (bez světel)
→ scale do bbox kategorie → attachment empty → FBX (+Z up, −Y forward,
textura zvlášť). `validate.py` čte report → PASS/WARN/FAIL (bez Blenderu).
Limity: `spec/roblox_spec.json` (ověřeno proti create.roblox.com 2026-08-21;
strop textury na Marketplace je 2048, bake držíme 1024).

⚠ Axis konvence: před hromadným během ověř JEDEN mesh ve Studiu (Accessory
Fitting Tool) — pokud bude ležet na boku, přepni `axis_up`/`axis_forward`
v `export_fbx()` a přegeneruj.

## Golden test

```bash
docker build -f worker/Dockerfile -t ugc-blender:latest .
./golden_test.sh   # ico-sphere GLB bez UV → convert → report asserty
```

## Mac (zbytková role)

Studio: stáhnout zip (`/packed/{id}/download`), import FBX, Accessory Fitting
Tool, Marketplace submission. Volitelně `ugc-pull.sh` (curl s Access tokenem).
