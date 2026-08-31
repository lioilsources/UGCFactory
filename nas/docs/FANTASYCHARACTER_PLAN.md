# FANTASYCHARACTER_PLAN.md

Handoff plán pro Claude Code. 2D obrázek fantasy postavičky → texturovaný, rigovaný, animovaný 3D model (GLB + FBX) s Mixamo-kompatibilní kostrou. Výstup lze otáčet v appce, stáhnout do Blenderu a hromadně spawnovat v Robloxu (MountainsSimulator) a Luanti (DoggioWars).

## 0. Routing – kam tento soubor patří

| Fáze | Kam | Poznámka |
|---|---|---|
| 1 (ComfyUI workflowy) | `UGCFactory/spark/` + `nas/workflows/` | kontrakt nodů viz `nas/workflows/README.md` |
| 2–3 (workery, API, exportéry) | `UGCFactory/nas/` | **hotovo**, tento soubor žije tady |
| 4 (3D viewer) | `UGCFactory/app/lib/shared/` | `model_view.dart` už existuje — rozšířit, ne extrahovat |
| 5 (FC obrazovky) | `UGCFactory/app/` | modul vedle stávajícího cockpitu |
| 6a (Roblox spawner) | `lioilsources/MountainsSimulator` | sekce 6.1 |
| 6b (Luanti mod) | `lioilsources/DoggioWars` | sekce 6.2, mod do `mods/fantasy_mobs/` |

> **Routing přepsaný oproti původnímu plánu.** Ten posílal fázi 1–4 do
> samostatného `lioilsources/ugc-backend`, appku do nového
> `fantasy_character` a viewer do nového `ol1n_3d_viewer`. Ukázalo se, že
> `ugc-backend` i `ugc_studio` byly zastaralé kopie toho, co v `UGCFactory`
> běží dál (backend o 258 řádků `main.go` napřed, klient o pět dní novější),
> a že viewer, který měl vzniknout extrakcí z `ugc_studio`, ve skutečnosti
> leží v `UGCFactory/app/lib/shared/model_view.dart`. Oba samostatné
> repozitáře byly proto zrušeny a všechno je v tomhle monorepu; nové
> repozitáře pro appku ani viewer nevznikají, aby se klientský kód
> neduplikoval.

Rozhodnutí: **jeden monorepo, sdílený backend i klient.** `nas/` se rozšiřuje o doménu `characters` a stává se obecnou asset factory; `app/` dostane FC obrazovky vedle stávajícího UGC cockpitu a oba použijí tentýž 3D viewer.

## 1. Cíle a ne-cíle

Cíle V1:
- Vstup: 1 obrázek (PNG/JPG) humanoidní postavy + výběr 1..N animací z lokální knihovny.
- Výstup: `model.glb` (skinned, s animačními klipy), `model.fbx` (rig + textury, pro Blender), `preview.mp4` (turntable), `thumb.png`.
- Appka: upload, výběr animací, 3D viewer s přehráváním klipů, download.
- Hromadný export pro Roblox (Open Cloud) a Luanti (GLB + Lua tabulka frame ranges).

Ne-cíle V1:
- Nehumanoidní postavy (draci, quadrupedi, ocasy) – V2 přes plné UniRig s vlastní kostrou.
- Listování Mixamo webu z appky – Mixamo nemá API, automatizace je proti ToS Adobe. Knihovna klipů je lokální, kurátovaná, stažená ručně jednou.
- Facial rig, cloth sim, morph targets.

## 2. Architektura

```
UGCFactory/app (FC modul) ──HTTPS──▶ Caddy (ugc.ol1n.com) ──▶ nas :8095 (JODA)
                                                               │
                                     ┌─────────────────────────┼──────────────────────────┐
                                     ▼                         ▼                          ▼
                             ComfyUI (Spark)          Blender worker (JODA)        Storage (JODA)
                             - rmbg                   - cleanup.py                 /data/characters/{id}/
                             - A-pose (SDXL+OpenPose) - retarget.py                /data/animlib/
                             - TRELLIS img→3D         - export_gltf.py
                             - UniRig/MIA auto-rig    - luanti_pack.py
```

Job pipeline (stavy jednoho `character`):
`uploaded → preprocessed → meshed → cleaned → rigged → animated → exported → done | failed`

Každý krok je samostatný job typ v existující job queue `ugc-backend`, aby šel retry per krok:
`char.preprocess`, `char.mesh`, `char.clean`, `char.rig`, `char.animate`, `char.export.{roblox|luanti|user}`.

## 3. Backend – `ugc-backend`

### 3.1 Datový model (sqlc / migrate)

```sql
CREATE TABLE characters (
  id            uuid PRIMARY KEY,
  owner_id      text NOT NULL,
  name          text NOT NULL,
  status        text NOT NULL,            -- viz stavy výše
  error         text,
  source_image  text NOT NULL,            -- storage path
  apose_image   text,
  mesh_glb      text,                     -- TRELLIS output
  clean_glb     text,
  rigged_fbx    text,
  final_glb     text,
  final_fbx     text,
  preview_mp4   text,
  thumb_png     text,
  tri_count     int,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE animations (                 -- knihovna klipů
  id            text PRIMARY KEY,          -- slug: 'idle_01', 'walk_forward'
  name          text NOT NULL,
  category      text NOT NULL,             -- idle|locomotion|combat|emote|misc
  source        text NOT NULL,             -- 'mixamo' | 'cc0-quaternius' | 'own'
  license       text NOT NULL,             -- pro export zákazníkům rozhoduje
  fbx_path      text NOT NULL,
  preview_gif   text,
  frames        int NOT NULL,
  fps           int NOT NULL DEFAULT 30,
  loop          bool NOT NULL DEFAULT false,
  tags          text[]
);

CREATE TABLE character_animations (
  character_id  uuid REFERENCES characters(id) ON DELETE CASCADE,
  animation_id  text REFERENCES animations(id),
  frame_start   int,                        -- vyplní retarget.py (sloučená timeline)
  frame_end     int,
  PRIMARY KEY (character_id, animation_id)
);

CREATE TABLE exports (
  id            uuid PRIMARY KEY,
  character_id  uuid REFERENCES characters(id),
  target        text NOT NULL,             -- roblox|luanti|user
  status        text NOT NULL,
  external_id   text,                      -- Roblox assetId
  artifact_path text,
  created_at    timestamptz NOT NULL DEFAULT now()
);
```

### 3.2 API (prefix `/v1/fc/`, vlastní API key scope oddělený od UGC cockpitu)

```
POST   /v1/fc/characters                 multipart: image, name, animation_ids[]  → 202 {id}
GET    /v1/fc/characters                 ?owner → list
GET    /v1/fc/characters/{id}            status + artifact URLs
DELETE /v1/fc/characters/{id}
POST   /v1/fc/characters/{id}/retry      {from_step}
POST   /v1/fc/characters/{id}/animations {animation_ids[]}  → re-run animate+export
GET    /v1/fc/characters/{id}/download   ?format=glb|fbx|zip
GET    /v1/fc/animations                 ?category&tag → knihovna s preview
POST   /v1/fc/characters/{id}/export     {target: roblox|luanti}
GET    /v1/fc/exports/{id}
WS/SSE /v1/fc/characters/{id}/events     progress pro appku
```

### 3.3 Workery

**ComfyUI (Spark) – workflow `fc_pipeline.json`, volaný přes `/prompt` API jako dnes TRELLIS:**

1. `LoadImage` → `BiRefNet`/`RMBG-2.0` → RGBA na neutrálním pozadí.
2. **A-pose kanonizace** (volitelný krok, zapnout přes flag): SDXL + OpenPose ControlNet (fixní A-pose skeleton PNG) + IP-Adapter (identita postavy, už máš z face-avatar) → obrázek téže postavy v A-pose. Bez tohoto kroku rig často selže u dynamických póz.
3. `TRELLIS` image→3D → GLB s texturou (existující nody).
4. `UniRig: Auto Rig` (MIA mode) → rigovaný FBX s Mixamo kostrou (`mixamorig:Hips` …).
5. `SaveFile` nody → cesty vrátit do `ugc-backend`.

**Blender worker (JODA) – headless skripty v `workers/blender/`:**

- `cleanup.py` – import GLB, `Decimate` na cílový tri budget (parametr: 8000 user / 5000 roblox / 2000 luanti), `Remesh` pokud non-manifold, pivot na spodek bounding boxu, výška 1.8 m, bake textury do jedné 1024² (Roblox) / 512² (Luanti) atlas, export GLB.
- `retarget.py` – import rigovaného FBX (target) + N Mixamo FBX klipů (source). Protože názvy kostí se shodují, stačí `Action` copy (bez retarget addonu). Klipy poskládat za sebe na jednu timeline s 5-frame mezerou, zapsat `{clip_id: [start, end]}` do JSON (→ `character_animations`). NLA tracky pojmenované podle `animation_id`, aby glTF exportér vyexportoval samostatné klipy.
- `export_gltf.py` – GLB (skinning, all animations, textures embedded), FBX (Binary, textury vedle), turntable render 360° 4 s → `preview.mp4` (Eevee, 512²), `thumb.png`.
- `luanti_pack.py` – GLB (2k tris, 512² PNG oddělená, jedna timeline) + `anim_ranges.lua`.
- `roblox_pack.py` – FBX ≤ 10k tris, max 4 influences/vertex (`Limit Total`), 1024² textura, ověřit počet kostí ≤ 256.

### 3.4 Sdílený viewer – `app/lib/shared/model_view.dart`

Viewer už v monorepu je (85 řádků) a používá ho UGC cockpit; nikam se
neextrahuje, jen se rozšíří. Požadavky navíc pro FC:
- přehrávání pojmenovaných animačních klipů (`flutter_3d_controller` umí `playAnimation(animationName)`),
- přepínač klipů + loop, turntable auto-rotate, reset kamery,
- expose `Ol1nModelViewer(url, animations: [...], onReady)`.
Stávající cockpit musí projít beze změny chování.

## 4. Spark – co doplnit do ComfyUI

### 4.1 Nody a váhy

| Položka | Zdroj | Velikost |
|---|---|---|
| `ComfyUI-UniRig` (PozzettiAndrea) | GitHub, custom_nodes | – |
| MIA checkpointy | HF `jasongzy/Make-It-Animatable` | ~1 GB |
| UniRig checkpointy (V2 fallback) | HF `VAST-AI/UniRig` | ~2 GB |
| OpenPose ControlNet SDXL | HF `thibaud/controlnet-openpose-sdxl-1.0` | ~2.5 GB |
| BiRefNet / RMBG-2.0 | HF | ~1 GB |
| (později) Hunyuan3D 2.1 | HF `tencent/Hunyuan3D-2.1` | ~15 GB, PBR textury |

Vše se vejde do 128 GB unified memory vedle stávajícího TRELLIS + SDXL.

### 4.2 ARM64 (aarch64, GB10, sm_121) – build poznámky

Žádné z níže uvedených nemá aarch64 wheels, kompiluj ze zdroje uvnitř ComfyUI kontejneru/venv:

```
# pořadí záleží
pip install --no-build-isolation torch-scatter torch-cluster   # potřebuje MIA
# pouze pro plné UniRig (V2):
pip install --no-build-isolation spconv-cu12X                   # nemá aarch64 – build z git spconv, ~30 min
pip install flash-attn --no-build-isolation                     # ověřit sm_121 support, jinak fallback na SDPA
```

- Nastav `TORCH_CUDA_ARCH_LIST="12.1"` (ověř přesnou hodnotu pro GB10 přes `torch.cuda.get_device_capability()`).
- Zvaž samostatný Docker image `comfyui-fc` s vybuildovanými extensions, aby build nešel při každém restartu.
- **MIA cesta nepotřebuje spconv ani flash-attn** – proto V1 jede na MIA. UniRig nechat na V2.
- Akceptační test: `fc_pipeline.json` na referenčním obrázku (rytíř v A-pose) → rigged FBX < 60 s celkem, kostra obsahuje `mixamorig:` prefix, 65 kostí.

### 4.3 Knihovna animací (`/data/animlib/`)

- Ručně stáhnout z Mixamo (bez skinu: "Without Skin", 30 fps, FBX Binary) kurátorovanou sadu ~50 klipů: idle ×3, walk, run, jump, crouch walk, 4× attack, hit, death ×2, 6× emote/dance, wave, sit, climb.
- Pro každý klip vygenerovat `preview.gif` (Blender, default Mixamo mannequin) + záznam do `animations`.
- **Licence:** Mixamo klipy lze použít v projektech, nesmí se redistribuovat samostatně. Pro placené exporty zákazníkům vést paralelní CC0 sadu (Quaternius Universal Animation Library, Kenney) se stejnou Mixamo kostrou – nastavit `license` sloupec a filtrovat při exportu `target=user`.

## 5. FC obrazovky v `app/`

Stack: to, co appka už má (Flutter, Riverpod, Dio, SSE) + `image_picker` a viewer z `lib/shared/`.

Obrazovky:
1. **Home** – galerie mých postav (thumb + status badge).
2. **Create** – vyber obrázek (galerie/foto), pojmenuj, toggle "Auto A-pose", výběr animací (grid s GIF preview, kategorie), tlačítko Generate. Progress přes SSE (kroky pipeline jako stepper).
3. **Character detail** – 3D viewer, seznam klipů (tap = play), tlačítka Download GLB / FBX / ZIP, Share, "Add animations", "Send to Roblox / Luanti".
4. **Library** – prohlížení animační knihovny (to "Mixamo listování"), preview, oblíbené.

Auth: reuse toho, co má cockpit (API key / Sign in with Apple – rozhodnout). Monetizace až V1.1 (počet generování/měsíc).

Akceptace: end-to-end z fotky na mobilu do otáčejícího se animovaného modelu < 3 min.

## 6. Zaplavení světů

### 6.1 Roblox – MountainsSimulator

- `ugc-backend` `char.export.roblox`: `roblox_pack.py` → Open Cloud Assets API `POST /assets/v1/assets` (assetType `Model`, FBX) → uloží `assetId` do `exports.external_id`. Moderace automaticky, poll `operations`.
- Animace: Mixamo kostra je pro všechny postavy shodná → **KeyframeSequence nahrát jednou** přes Animation Editor (import FBX klipu na libovolnou postavu z pipeline), zapsat `animationId` do configu. Open Cloud animace neuploaduje, tohle je jediný ruční krok.
- Luau `NPCSpawner` (ServerScriptService):
  - načte seznam `assetId` (JSON z backendu nebo `HttpService`),
  - spawn podle výškové mapy z `terrain-fetch` (biom pásma: louky < 1500 m, skály > 2500 m → jiné typy postav),
  - `Humanoid` + `Animator`, state machine idle/wander/flee, `Humanoid:MoveTo` s raycast na terén,
  - limit ~250 aktivních NPC, `StreamingEnabled`, despawn > 400 studs od hráčů, respawn pool.
- Limity hlídané v `roblox_pack.py`: ≤ 10k tris/MeshPart, ≤ 4 influences/vertex, 1024² textura.

### 6.2 Luanti – DoggioWars

- `char.export.luanti`: `luanti_pack.py` → `models/fc_{slug}.glb`, `textures/fc_{slug}.png`, `anim_ranges.lua`. Luanti ≥ 5.10 umí GLB se skeletální animací nativně.
- Mod `fantasy_mobs/`:
  - `init.lua` iteruje `characters/*.lua` (generované), `minetest.register_entity("fantasy_mobs:"..slug, {...})` s `visual="mesh"`, `mesh`, `textures`, `animation=ranges.idle`,
  - jednoduché chování (idle/wander/flee od hráče) nebo napojení na `mobs_redo` API,
  - spawn per ostrov: `minetest.register_abm` / ABM na trávě s density parametrem, cap na mapblock.
- Rozpočet: 2k tris, 512² textura (mobil). Jedna timeline, klipy přes `set_animation({x=,y=})`.

## 7. Fáze a akceptace

| Fáze | Obsah | Hotovo když |
|---|---|---|
| 1 | Spark: UniRig node + MIA build na ARM, `fc_pipeline.json` | referenční obrázek → rigged FBX s Mixamo kostrou |
| 2 | Blender: cleanup + retarget + export, knihovna 10 klipů | GLB přehrává 3 klipy v Blender/three.js |
| 3 | `ugc-backend`: schéma, job typy, API, SSE | curl end-to-end, `status=done` |
| 4 | rozšířit `app/lib/shared/model_view.dart` o klipy | cockpit beze změny chování |
| 5 | FC modul v `app/` (TestFlight) | fotka → animovaný model na mobilu < 3 min |
| 6 | Roblox + Luanti exportéry a spawnery | 50 postav běhá v obou světech |
| V2 | UniRig plný (non-humanoid), Hunyuan3D 2.1, CC0 knihovna pro prodej | – |

## 8. Rizika

- ARM build extensions (torch-scatter/cluster) – rezervuj den; fallback: MIA jako samostatná FastAPI služba mimo ComfyUI.
- Kvalita rigu závisí na A-pose – bez kanonizace čekej ~30 % selhání u akčních póz.
- TRELLIS textury nejsou PBR, u Robloxu stačí, pro "Blender-ready" prodej zvaž Hunyuan3D 2.1.
- Roblox moderace může odmítnout některé fantasy motivy (zbraně, krev) – flag v UI.

## 9. Otevřené otázky

- Auth pro FC appku: sdílet s `ugc_studio`, nebo Sign in with Apple?
- Kde má běžet turntable render – Eevee na JODA (CPU, pomalé) vs. renderovat v ComfyUI na Sparku?
- Chceš per-uživatel kvóty už ve V1?

## 10. Poznámky k implementaci (doplněno při realizaci fáze 3)

- **SQLite, ne Postgres.** `ugc-backend` jede na `modernc.org/sqlite` s migrací v `store.go`;
  DDL výše je Postgresové. Překlad: `uuid` → `TEXT` (hex id), `timestamptz` → `TEXT`
  RFC3339 (stejně jako `jobs`/`items`), `text[]` → JSON `TEXT` (stejně jako `items.tags`),
  `bool` → `INTEGER`. Sémantika sloupců je zachovaná 1:1.
- **Krokovou frontu drží `character_steps`.** Plán chce retry per krok; stávající „queue" je
  jen sloupec `status` v `jobs`. Samostatná tabulka kroků dává historii pokusů i chyb
  a claim přes compare-and-swap ve stejném duchu jako `ClaimNextApproved`.

## 11. Co ukázalo měření (fáze 2)

Skripty běžely v `ugc-blender:latest` (Blender 4.2.9 LTS) na JODA proti
fixture z `testdata/gen_fc_fixture.py`. Tři věci vyšly jinak, než plán čekal:

**Eevee na JODA je slepá ulička, ne jen „pomalé".** Turntable spadne na
`EGL Error (0x3009): EGL_BAD_MATCH` — stroj nemá GPU a kontejner nemá EGL
surface. Jeden snímek 512² trval **150 s** a stejně skončil chybou; 96 snímků
by byly čtyři hodiny. Blender u toho vrátí **exit code 0** a nechá po sobě
48bajtový `preview.mp4`, takže krok bez kontroly velikosti hlásí úspěch s
rozbitým souborem. Otevřená otázka §9 tím padá na dvě možnosti: Cycles CPU na
JODA, nebo render na Sparku — a měření mluví pro Spark: Cycles CPU turntable
sice **projde** (48 snímků, 12 fps, `CYCLES_SAMPLES=16`, validní mp4 i thumb),
ale trval **15 minut** — a to na fixture o dvanácti trojúhelnících. Na reálné
postavě to bude horší, takže by každý export držel workera čtvrt hodiny kvůli
videu, které je jen pohodlí.

Proto má `fc_export.py` tři režimy (`job["preview"]`, worker je řídí přes
`FC_PREVIEW`): `thumb` (výchozí — jeden snímek), `full` (celý turntable,
zapnout až bude render na Sparku) a `none`. Preview je navíc nepovinné — když
selže, GLB a FBX se odevzdají a v reportu je `preview_error`.

**Přepočet měřítka Mixamo klipů dělá škodu.** Klip ve 100× měřítku vyšel po
„korekci" podle poměru výšek kostry přesně 100× vedle (`0.0005` místo
`0.05`) — FBX import translační kanály normalizuje sám. Retarget proto
translace nepřepočítává, jen hlásí `height_ratio`; korekci lze zapnout
per-klip přes `location_scale`.

**Zbytek sedí.** `fc_cleanup.py`: výška přesně 1.8 m, UV doplněné, jeden
materiál. `fc_retarget.py`: mezera 5 snímků drží (`idle_01` 1–20, `walk_cm`
25–54), NLA tracky pojmenované podle klipů, kostry se potkaly na všech
kostech. `fc_roblox_pack.py`: 7 kostí, 2 váhy/vertex. `fc_luanti_pack.py`:
GLB + platná `anim_ranges.lua`.

Neověřené zůstávají ComfyUI kroky (`preprocess`, `mesh`, `rig`) — ty potřebují
workflow z fáze 1 — a chování na skutečném Mixamo FBX, protože fixture je
sedmikostrová náhražka, ne `mixamorig` s 65 kostmi.
