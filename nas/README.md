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

Storage: `$DATA_DIR/{incoming,converted,packed,rejected,jobs}` (viz .env; snap
docker na JODA vidí jen `/home` a `/media` — `/pool` mountovat nejde) +
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
- `GET /app/` — Flutter web build appky (stejný origin ⇒ žádné CORS a přes
  ugc.ol1n.com platí jedna Access cookie pro appku i API). Build se sem
  dostane jako `web/` adresář: `flutter build web --release --base-href /app/`
  v repu ugc_studio, pak `cp -R build/web ../ugc-backend/web` a redeploy.
- interní: `POST /worker/claim`, `POST /worker/result/{id}`

Stavy jobu: `new → approved → converting → converted(PASS/WARN/FAIL) → packed`,
odbočky `rejected`, `rerolled`, `failed`.

## Fantasy characters (`/v1/fc/`)

Druhá doména téhle továrny: 2D obrázek → rigovaný animovaný 3D model. Plán a
rozhodnutí jsou v `docs/FANTASYCHARACTER_PLAN.md`; tohle je jen kontrakt.

Pipeline je fronta kroků (`character_steps`), ne jeden sloupec se stavem —
plán chce retry per krok, takže každý pokus má vlastní řádek s chybou:

```
uploaded → preprocessed → meshed → cleaned → rigged → animated → exported → done
char.preprocess  char.mesh  char.clean  char.rig  char.animate  char.export.user
```

- `POST /v1/fc/characters` — multipart `image` + `name` + `animation_ids`
  (opakované pole nebo čárkami), volitelně `owner_id`, `auto_apose=false` → 202
- `GET /v1/fc/characters?owner=&status=`, `GET /v1/fc/characters/{id}` (postava,
  klipy s frame ranges, historie kroků, exporty, URL existujících artefaktů)
- `DELETE /v1/fc/characters/{id}`
- `POST /v1/fc/characters/{id}/retry` — `{from_step}`, bez něj poslední selhavší
- `POST /v1/fc/characters/{id}/animations` — `{animation_ids}`, přehodí výběr a
  pustí znovu jen animate+export (mesh se nepočítá znovu)
- `GET /v1/fc/characters/{id}/download?format=glb|fbx|zip`
- `GET /v1/fc/characters/{id}/file/{artifact}` — `final_glb`, `thumb_png`, …
- `GET /v1/fc/characters/{id}/events` — SSE jen pro tuhle postavu
- `POST /v1/fc/characters/{id}/export` — `{target: roblox|luanti|user}`
- `GET /v1/fc/exports/{id}`
- `GET /v1/fc/animations?category=&tag=&license=`, `PUT /v1/fc/animations/{id}`

Worker (stejný vzor jako `/worker/claim`, soubory po sdíleném `/data`):

- `POST /worker/fc/claim` → `{step_id, step, character, dir, files, clips}`
  nebo 204
- `POST /worker/fc/result/{step_id}` → `{artifacts, frame_ranges, external_id,
  artifact_path}` nebo `{error}`. Artefakty jdou přes whitelist sloupců, takže
  výsledek od workera nemůže sáhnout na status ani id.

Storage: `$DATA_DIR/characters/{id}/` (`source.png`, `mesh.glb`, `rigged.fbx`,
`model.glb`, `model.fbx`, `preview.mp4`, `thumb.png`), knihovna klipů
`$DATA_DIR/animlib/`.

Auth: `FC_API_KEYS` (čárkami oddělené) → hlavička `X-API-Key` nebo
`Authorization: Bearer`. Nenastavené = scope otevřený, počítá se s LAN/Access
před tím, stejně jako u zbytku API.

### FC workery

`ugc-fc` (stejný image jako `ugc-blender`, jiná smyčka) točí
`POST /worker/fc/claim` a podle kroku volá buď ComfyUI na Sparku, nebo
headless Blender na JODA:

| Krok | Kde | Čím |
|---|---|---|
| `char.preprocess` | Spark | ComfyUI `fc_preprocess.json` (RMBG + volitelná A-pose) |
| `char.mesh` | Spark | ComfyUI `fc_mesh.json` (TRELLIS) |
| `char.clean` | JODA | `fc_cleanup.py` — decimate, atlas, výška 1.8 m, pivot na zem |
| `char.rig` | **JODA** | `fc_rig_template.py` — Mixamo kostra z proporcí meshe, heat map váhy |
| `char.animate` | JODA | `fc_retarget.py` — klipy na jednu timeline + NLA tracky |
| `char.export.user` | JODA | `fc_export.py` — GLB, FBX, turntable mp4, thumb |
| `char.export.roblox` | JODA | `fc_roblox_pack.py` — ≤10k tris, 4 váhy/vertex, ≤256 kostí |
| `char.export.luanti` | JODA | `fc_luanti_pack.py` — 2k tris, 512² PNG, `anim_ranges.lua` |

Turntable renderuje **Cycles na CPU**, ne Eevee: JODA nemá GPU a Eevee v tom
kontejneru padá na `EGL_BAD_MATCH` (a Blender u toho vrátí nulu, takže po sobě
nechá prázdný mp4 — proto se kontroluje velikost souboru). Celý turntable ale
trval 15 minut na 48 snímků, takže `FC_PREVIEW` je ve výchozím stavu `thumb`
(jeden snímek); `full` zapni, až bude render na Sparku, `none` vypne oboje.
Preview je nepovinné — když selže, GLB a FBX se odevzdají a v reportu je
`preview_error`.

Rig **nejede na neuronce**: ani UniRig, ani MIA se na GB10 rozběhnout nedají
(`cumm` nezná CUDA arch 12.1, `bpy` nemá wheel pro linux aarch64 — měření je
v `docs/FANTASYCHARACTER_PLAN.md` §12). `fc_rig_template.py` staví Mixamo
kostru z proporcí meshe, takže klipy z knihovny na ni sedají stejně.
`FC_RIG=comfy` přepne zpět, až některý z těch upstreamů Blackwell doplní.

Workflow JSONy patří do `workflows/`, kontrakt (titulky nodů, ne čísla) je
popsaný ve `workflows/README.md`. Bez `FC_COMFY_URL` selžou ComfyUI kroky hned
s hláškou, ne timeoutem.

Knihovna klipů: stáhni FBX ručně do `$DATA_DIR/animlib` (Mixamo nemá API a
automatizace je proti ToS) a zaregistruj je:

```bash
python3 worker/seed_animlib.py --dir /data/animlib --license mixamo-embedded
```

Testy bez Blenderu a bez ComfyUI:

```bash
go test ./...                                              # API a pipeline
python3 -m unittest discover -s worker -p 'fc_*_test.py'   # worker, Lua ranges
./golden_test.sh                                           # konverze v kontejneru
```

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

Cloudflare Access — hotovo 2026-08-22 z CLI (token `AccessApp`, uložený na
JODA v `~/.cloudflare-access-token`): app `ugc` (AUD už je v
`cloudflared/config.yml`), policy `app-service-token` (any valid service
token) + `owner-sso` (e-mail majitele).

⚠ `cloudflared/credentials.json` musí být **0444** — konektor běží jako uid
65532 a na 0400 dostane „permission denied" a tunel se nezaregistruje
(projeví se jako error 1033 na hostname).

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

Cloudflare Access — hotovo 2026-08-22 z CLI (token `AccessApp`, uložený na
JODA v `~/.cloudflare-access-token`): app `ugc` (AUD už je v
`cloudflared/config.yml`), policy `app-service-token` (any valid service
token) + `owner-sso` (e-mail majitele).

⚠ `cloudflared/credentials.json` musí být **0444** — konektor běží jako uid
65532 a na 0400 dostane „permission denied" a tunel se nezaregistruje
(projeví se jako error 1033 na hostname).

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
