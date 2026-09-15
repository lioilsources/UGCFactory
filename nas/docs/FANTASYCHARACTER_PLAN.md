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

## 12. Auto-rig na GB10: proč V1 jede na šabloně (měřeno 2026-08-31)

Plán počítal s auto-rigem z neuronky — §4.2 vybírá pro V1 **MIA** s
odůvodněním, že *„MIA cesta nepotřebuje spconv ani flash-attn"*. Obě cesty
jsem na Sparku zkusil dotáhnout a **ani jedna se rozběhnout nedá**, každá
z jiného důvodu.

### Co funguje

Stroj CUDA rozšíření překládat umí, to není problém:

| | výsledek |
|---|---|
| `nvcc` | 13.0.88, je na stroji (jen mimo PATH, `CUDA_HOME` nenastavené) |
| `torch-scatter` | přeloženo **s CUDA kernely**, `scatter_add` ověřen během na GPU |
| `torch-cluster` | přeloženo **s CUDA kernely**, `knn_graph` ověřen během na GPU |
| `pytorch3d 0.7.8` | přeloženo (`PYTORCH3D_FORCE_NO_CUDA=1`), transformace ověřeny na GPU |

Spark je `aarch64`, torch 2.11.0+cu130, compute capability **(12, 1)** —
plán hádal `TORCH_CUDA_ARCH_LIST="12.1"` správně.

### A (UniRig): `cumm` nezná Blackwell

Node `PozzettiAndrea/ComfyUI-UniRig`, který plán jmenuje, **nemá MIA režim** —
je to čistý UniRig a `nodes/unirig/ptv3_encoder.py` importuje `spconv.pytorch`
a `torch_scatter` napřímo. Spconv tedy není volitelný, jak §4.2 předpokládá.

Build padá na `ValueError: Unknown CUDA arch (12.1) or GPU not supported`
z `cumm/common.py`. Ten seznam je natvrdo v kódu: verze `0.7.13`, kterou si
spconv pinuje, končí na `9.0`; nejnovější přidává `10.0` a `12.0`, ale
**`12.1` tam pořád není**. Bez CUDA se spconv přeloží, ale za běhu hlásí
*„not implemented for CPU ONLY build"*.

### B (MIA): `bpy` nemá wheel pro linux aarch64

`bpy` nemá aarch64 wheel pro Linux v žádné verzi — ani pinovaná 4.3.0, ani
nejnovější 5.2.1. (Pozor na `arm64` soubory na PyPI, to jsou macOS.) A MIA
Blender volá **už při importu**: `model.py` → `util.dataset_mixamo` →
`get_kinematic_tree()`, které na úrovni modulu dělá `blender_utils.load_file()`
nad `data/Mixamo/bones.fbx` — souborem, který **v publikovaném HF repu není**.

### C: šablona, na kterou sedí stejné klipy

`fc_rig_template.py` kostru neodhaduje sítí, ale staví ji z proporcí meshe
(řezy po výšce → šířka ramen, rozestup nohou) a váhy nechá spočítat Blenderu.
Kosti mají Mixamo jména, takže `fc_retarget.py` i knihovna klipů fungují beze
změny.

Ověřeno na JODA (Blender 4.2.9) celým řetězem mesh → rig → retarget → export:
22 kostí, heat map váhy, 7 % vrcholů bez váhy, `bones_missing_in_target: {}`
a výsledné GLB nese oba klipy pod jejich jmény se skinem o 23 kloubech.

Past, kterou to odhalilo: **heat weighting umí selhat tiše** — vytvoří vertex
groups i modifikátor, nechá je prázdné a nevyhodí výjimku. Pozná se to jedině
spočítáním vah, což `bind()` dělá, a padá pak na obálku.

Omezení: šablona předpokládá humanoida stojícího zpředma. Report má
`fit_warnings` a worker loguje, když zůstane přes 25 % vrcholů bez váhy.

### Až Blackwell doplní

Na stroji leží připravené: UniRig node jako `custom_nodes/ComfyUI-UniRig.disabled`
(nenačte se) i s váhami v `models/unirig/` (2,8 GB), a MIA v `~/Code/Make-It-Animatable`
s checkpointy (2,2 GB). Přepnout zpět jde přes `FC_RIG=comfy`.

### Váhy: proč se pořád padá na obálku (měřeno 2026-09-02)

Heat weighting na modelech z pipeline selhává. Příčina **není děravost**, jak
to napoprvé vypadalo — proxy po voxel remeshi má nula otevřených hran a heat
map přesto vrátí prázdno. Rozhoduje **počet nespojitých kusů**: brnění Test
Knighta se při jemném voxelu rozpadlo na 112 ostrůvků a Blender hlásí
*„failed to find solution for one or more bones"*, protože do většiny z nich
žádná kost nezasahuje. Hrubší voxel je slije:

| voxel (podíl bboxu) | vrcholů | kusů | obarveno |
|---|---|---|---|
| 0,012 | 12516 | 112 | **0** |
| 0,020 | 3762 | 25 | vše |
| 0,045 | 580 | 4 | vše |

`bind_via_proxy` proto zkouší hrubosti od nejjemnější a váhy z proxy přenáší
zpět interpolací; originál si nechá geometrii, UV i materiál.

**Ale jasného vítěze to nedalo.** Natažení hran během klipu:

| | průměr | nejhorších 0,1 % | jejich klidová délka |
|---|---|---|---|
| obálka | 1,0188 | 2,94× | 22,6 mm |
| heat-proxy | **1,0114** | 4,86× | **38,5 mm** |

Proxy deformuje celkově hladčeji, ale roztahuje hrany **běžné velikosti**,
zatímco obálka jen krátké — a právě to je vidět jako střepy. Omezení na čtyři
váhy na vrchol s tím nehnulo (4,86 → 4,76).

Proto je metoda přepínatelná přes `FC_RIG_WEIGHTS` (`auto` | `proxy` |
`envelope`), ne zadrátovaná. Rozhodnout to podle čísel nejde, obě metriky
mluví proti sobě.

## 13. Animace na fotkách: retarget, šablona po řezech a MIA (měřeno 2026-09-15)

Celopostavové fotky dávaly dobrý mesh — výstup TRELLISu, cleanup i rig
v klidové póze vypadají v pořádku — a pak se postava v Zombie Walku
přeložila v pase. Měřeno na pěti postavách: dvě fotky celé postavy, Test
Knight, ilustrace oříznutá pod boky a obraz trupu. Metrika je natažení hran
během klipu (`max(r, 1/r)`, průměr přes hrany a snímky; 1,0 = žádná
deformace), vždy se stejným klipem.

### Retarget: světové osy místo kopie Action

`fc_retarget.py` kopíroval lokální rotace 1:1. Šablona má ale nohy a klíční
kosti otočené o 180° kolem vlastní osy a paže v klidu dolů místo T-pózy, takže
stehno bylo proti zdroji průměrně 66° mimo, nejvíc 116°. Po přepočtu přes
světové osy (`bake_clip`) je každá kost ve směru zdroje na 0,0° a chodidla do
3 cm od země (dřív až 18 cm nad). Nasazeno, commit 3df9f4f.

Zkoušeno a vráceno: srovnávat směr jen u kostí s velkým rozdílem klidové pózy
(práh 15–35°) a výšku boků škálovat délkou nohou. Obojí vyšlo na všech pěti
postavách o kus hůř (např. foto 1 1,332 → 1,347) a chodidla se vznášela o 4–6 cm
— UpLeg hlava sedí u sablony ve výšce Hips, u Mixamo níž, a vzorec to nebral.

### Šablona po řezech: nenasazeno

Kosti šablony leží v jedné rovině uprostřed bboxu. Na fotce, kde ruce visí
kousek za tělem, pak paže meshe leží 14 cm za kostí a 10 cm vedle a v animaci
odlétá do stran. Zkoušeno: mesh posypat 150 k body, řezat po 1 % výšky, klouby
dát do středu shluků (paže sledovat shora, nohy od stehen dolů, páteř jako
přímka). Průměrné natažení (stejný retarget):

| postava | šablona | řezy (vše) | řezy (jen paže) | MIA |
|---|---|---|---|---|
| foto 1 | 1,332 | 1,258 | 1,281 | **1,200** |
| foto 2 (ruce za zády) | 1,370 | 1,376 | 1,411 | **1,334** |
| Test Knight | **1,234** | 1,389 | 1,416 | 1,587 |
| ilustrace bez nohou | **1,467** | 1,312* | 1,458 | 1,994 |
| obraz trupu | **1,345** | 1,359 | 1,347 | 1,735 |

\* s vodorovnými pažemi, vizuálně nesmysl.

Paže po řezech sedí líp (u foto 1 přestaly odlétat), ale jinde to škodí víc:
u rytíře řez v úrovni kolen bere plášť a kolena jdou cik-cak, páteř podle
chocholu a drdolů zkroutila hlavu. Šablona zůstala, jak byla; pokus není v repu.

### MIA: běží, ale jen pro celé postavy

`FC_RIG=comfy` padal na `MIALoadModel`: *Object of type NodeOutput is not JSON
serializable*. Tři příčiny za sebou a oprava na Sparku:

- `comfy-env` 0.2.11, UniRig pinuje 0.4.1: `.venv/bin/pip install comfy-env==0.4.1`
- 0.4.1 hledá prostředí v `~/.ce/envs/unirig-nodes` a pixi v `~/.pixi/bin`:
  symlink na staré `~/.ce/_env_cfd2fa/.pixi/envs/default` + `pixi.toml/lock`,
  `ln -s ~/.local/bin/pixi ~/.pixi/bin/pixi` (`comfy-env install` ne — bral by
  `bpy` z kanálu bez aarch64 buildu)
- v izolovaném Pythonu 3.13 chyběl `torch_cluster`: build s
  `TORCH_CUDA_ARCH_LIST=12.1 FORCE_CUDA=1`, log v
  `custom_nodes/ComfyUI-UniRig/torch_cluster_py313_build.log`

Produkční ComfyUI opravu převezme až po restartu (`systemctl --user restart
comfyui`), a to jen s prázdnou frontou — sdílí ho i jiní klienti.

`fc_rig.json` navíc nešel spustit vůbec (commit a154434) a surový výstup MIA
nejde rovnou dál; `fc_rig_mia.py` ho srovná: mesh má výšku 2 a střed v počátku
(→ rozměry `clean.glb`), 7 % vrcholů je bez váhy (→ váhy nejbližšího
váženého, jinak nejhorší hrana 75×), až 8 vah na vrchol (→ 4) a materiál je
poloprůhledný (→ materiál z `clean.glb`).

Z tabulky: MIA vyhrává u fotek celé postavy a v renderu je jediná, která
vypadá jako reference (ruce vpředu, pokrčená kolena). U brnění s pláštěm,
oříznutých postav a malby je výrazně horší — plášť roztáhne do křídel.
Výchozí je proto `FC_RIG=auto`: rig oběma cestami, na každý první klip
postavy, nechat nižší průměrné natažení (`fc_rig_score.py`, každý druhý snímek).
Na všech pěti postavách to vybere vizuálně lepší variantu; ověřeno naostro na
foto 1 (MIA 1,196 proti šabloně 1,332, 29 s) a Test Knightovi (šablona 1,234
proti MIA 1,611, 17 s). Nejhorší hrany (p99,9) nerozhodují — u MIA je dělá
blána mezi rukou a bokem a vybíraly by šablonu i tam, kde vypadá hůř.

Produkční ComfyUI restartováno 2026-09-15 18:01 a všech pět postav přepočteno
od `char.rig` (4 min): MIA vybrána u foto 1 (1,201 proti 1,332), šablona u
ostatních. Foto 2 vyšlo tentokrát pro MIA hůř než v testu (1,421 proti 1,334)
— MIA není mezi běhy deterministická, rozhoduje aktuální běh.

### Chodidla na zemi

S MIA rigem mesh zajížděl 9–14 cm pod zem po celý klip. Výška boků se brala
jako pohyb boků zdroje × poměr výšek koster, a to u kostry jiných proporcí
nesedí. Nově `bake_clip` v každém snímku postaví pózu s boky v klidové výšce,
změří nejnižší kost chodidla a boky posune tak, aby byla nad zemí jako ve
zdroji (× poměr délek nohou). To samo zlepšilo foto 1 jen na −8,7 cm: podrážka
leží pod kostmi a při odvalení špičky se pod ně otočí. `keep_mesh_above_floor`
proto po upečení projde snímky a kde skinovaný mesh klesne pod klidovou zem,
zvedne boky o rozdíl — jen nahoru, aby skok dál mohl od země odlétnout.
Výsledek: nejnižší bod meshe 0,0 cm ve všech snímcích u MIA i šablony,
natažení beze změny, retarget 2–3 s.

## 14. A-pose a domyšlení nohou před TRELLISem (měřeno 2026-09-15)

Checkbox „Auto A-pose" v appce slibuje překreslení do A-pózy, ale
`fc_preprocess.json` dělá jen RMBG. Skutečný problém, který by A-pose měla
řešit, jsou **srostlé končetiny**: ruce přitisknuté k tělu a stehna u sebe
TRELLIS slije do jednoho objemu, šablona pak paži v řezech nenajde, MIA nechá
ruce u boků bez vah a při chůzi vzniká blána mezi stehny. Druhý problém jsou
fotky oříznuté nad kotníky — rig má nohy, mesh ne.

Vyzkoušeno na ComfyUI na Sparku (vše už tam bylo, žádné stahování), skript
`fc_pose_exp.py` (scratch, není v repu), metriky z DWPose (`DWPreprocessor` +
`SavePoseKpsAsJsonFile`): úhel paže od svislice, vodorovná mezera zápěstí od
osy trupu a rozteč kotníků/kolen, vše v šířkách ramen; tvář ArcFace
(`video-stack/tools/face_drift.py`) proti vstupu.

### Domyšlení nohou: FLUX Fill outpaint funguje

`ImagePadForOutpaint` (bottom = boky + 2,2 × trup − výška, zaokrouhleno na 16,
feathering 40) → `InpaintModelConditioning` → FLUX Fill fp8, guidance 30,
28 kroků, ~80–130 s. Prompt: „Continue the same figure downward, seamlessly:
the legs of the same person in the same clothing and the same art style,
standing straight and facing the camera, feet shoulder-width apart, matching
shoes, on a plain flat floor, consistent lighting." Ilustrace oříznutá nad
kotníky i malba oříznutá v bocích dostaly nohy ve stejném stylu, kotníky
detekované; viditelná část zůstala pixel-přesně (tvář 0,99). „Feet
shoulder-width apart" model poslouchá jen někdy: malba kolena 1,0–1,1, ilustrace
0,25 (stehna u sebe).

### A-pose: FLUX Kontext s podrobným promptem odtáhne paže, nohy ne

Graf z Ol1nLLM (`flux_hair_kontext.api.json` bez masky), guidance 2,5,
28 kroků, ~90–240 s podle vytížení. Prompt rozhoduje:

| | paže (°) | zápěstí od osy | tvář |
|---|---|---|---|
| foto 2 vstup | 3 | 0,54 | — |
| p1 podrobný („keep this exact person… arms at about 35 degrees, palms open, feet shoulder-width apart") | 19–20 | 1,03–1,09 | **0,96** |
| p2 krátký („same person… A-pose") | 21–22 | 1,02–1,07 | 0,72–0,73 |

Podrobný prompt drží identitu (0,96 = prakticky nezměněná tvář), oblečení
i pozadí; krátký ji sráží. U rytíře 15° → 19–27°, kotníky 0,81 → 0,99–1,52.
Nohy od sebe ale Kontext spolehlivě nedá: u ilustrace po outpaintu nechal
kolena na 0,17 a tvář překreslil (0,41 proti outpaintu).

### Brána: kostra na výsledku (auto rig, Zombie Walk, stejná metrika jako §13)

| postava | vstup | jen outpaint | Kontext p1 | outpaint + Kontext |
|---|---|---|---|---|
| foto 2 | 1,370 | — | **1,286** | — |
| Test Knight | 1,234 | — | **1,167** | — |
| malba (trup) | 1,346 | **1,206** (MIA) | — | 1,318 |
| ilustrace (nad kotníky) | 1,467 | 1,531 | — | 1,567 |

Vizuálně (render animace): u foto 2 a rytíře se paže po Kontextu oddělily a
kývou samostatně místo blány přes trup; malba z plovoucího torza tančí celá.
Čísla ilustrace jsou pastí metriky, ne důkazem zhoršení: bez nohou se natažení
počítá na meshi, který nohy nemá, s domyšlenýma nohama u sebe přibude přesně ta
blána mezi stehny. Kontext na malbě skóre zhoršil (1,206 → 1,318) — jeden běh,
TRELLIS i MIA jsou mezi běhy nedeterministické, rozdíly kolem 0,1 jsou na hraně
šumu (foto 2 MIA vyšla 1,33 a 1,42 ze stejného vstupu).

### Co z toho plyne

- Outpaint nasadit, když DWPose nevidí kotníky — bez něj postava nemá nohy vůbec.
- Kontext p1 nasadit, když je zápěstí blíž než ~0,8 šířky ramen od osy trupu
  (foto 2 0,54, malba 0,56; rytíř 0,81 byl už na hraně). Na fotkách drží
  identitu, na ilustracích ji mění — gate podle tváře (ArcFace < 0,7 → vrátit
  vstup) se nabízí, ale u malby/rytíře tvář není a rozhodnout nejde.
- Stehna u sebe zůstávají otevřená: ani Fill, ani Kontext je spolehlivě
  nerozdělí. Kandidát je VACE s řídicí kostrou (§ „A-pose" výše v rozhovoru
  2026-09-15) nebo cílený inpaint mezery mezi stehny.
- Cena: +2 až +6 min na postavu na sdíleném GPU.

Testovací postavy `owner=poseexp` na NASu (6 ks) a výstupy v
`~/Code/ComfyUI/output/fc_exp/` na Sparku zůstaly pro srovnání.
