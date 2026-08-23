# UGCFactory 🏭

Továrna na Roblox UGC itemy: z promptu vznikne texturovaný 3D model,
zkonvertovaný do robloxích limitů a zabalený k nahrání na Marketplace.
Tři stroje, jedno repo.

```
        ┌──────────── SPARK (GB10, GPU) ────────────┐
prompt →│ ComfyUI: Illustrious → RMBG → TRELLIS.2    │→ texturovaný GLB
        │ ugc-pipeline :8092                        │      │
        └───────────────────────────────────────────┘      │ push
                                                           ▼
        ┌──────────── NAS / JODA (24/7) ────────────────────────┐
        │ ugc-api :8095   fronta, triage, katalog, SSE, balení   │
        │ ugc-blender     GLB → FBX (≤4k tris, UV, bake)         │
        │ cloudflared     ugc.ol1n.com za Cloudflare Access      │
        └────────────────────────────────────────────────────────┘
             ▲ swipe triage                    │ packed zip
        ┌────┴─────────────┐          ┌────────▼──────────┐
        │ app (Flutter)    │          │ Mac: Roblox Studio│
        │ Android/iOS/web  │          │ import + submission│
        └──────────────────┘          └───────────────────┘
```

## Struktura

| Adresář | Co to je |
|---|---|
| `spark/` | Go služba `ugc-pipeline` — koncept → cleanplate → GLB → push na NAS, plus ověřené ComfyUI workflow šablony |
| `nas/` | Go `ugc-api` + headless Blender worker + compose stack + Cloudflare tunnel |
| `app/` | Flutter appka `ugc_studio` — Composer, fronta, swipe triage (Android, iOS, macOS, web) |
| `docs/` | smoke test REPORT.md, licence img→3D backendů |

## Nasazení

```bash
make deploy-nas      # ugc-api + blender worker + tunnel na JODA
make deploy-spark    # ugc-pipeline na SPARK
make app-web         # web build appky → nas/web → redeploy (mobil bez Xcode)
make app-android     # APK na připojený telefon
make status          # zdraví všech služeb
make test            # Go testy + flutter test
```

## Přístup k appce

| Kudy | Adresa | Podmínka |
|---|---|---|
| mobil / prohlížeč | `http://joda.tailde0de8.ts.net:8095/app/` | zapnutý Tailscale |
| odkudkoli | `https://ugc.ol1n.com/app/` | přihlášení přes Cloudflare Access |
| nativní Android / iOS | `make app-android` / `make app-ios` | připojený telefon |

Nativní appka umí obojí — v Nastavení se přepíná mezi Tailscale a internetem.
Pro internet potřebuje Access service token: zkopíruj `app/.cf-token.example`
na `app/.cf-token` a vyplň. Makefile ho zabuduje přes `--dart-define`, takže
**token nikdy není ve zdrojácích** (soubor je v .gitignore); jde ho i přepsat
přímo v Nastavení appky.

## Vyzkoušet item na vlastním avataru

```bash
./tools/ugc-pull.sh          # stáhne vše ve stavu packed do ~/UGC/inbox/
```

Ve Studiu pak **Avatar → Accessory Fitting Tool → Load Mesh/Model** →
vyber `.fbx`, přiřaď texturu (`*_tex.png`), vyber typ doplňku a nasaď na
testovacího avatara. Tohle je zdarma a okamžité.

Nosit item na **veřejném profilu** už vyžaduje publikaci na Marketplace:
ověření účtu vládním dokladem, poplatek **80 Robux** za nahrání a moderaci.
Náramenníky mají navíc zálohu 1 000 Robux při zalistování (ověřeno
2026-08-22). Ve vlastní hře jde item nasadit i bez toho —
`Humanoid:AddAccessory()` nad nahraným meshem.

## Dva 3D backendy: rychlý draft, drahý finál

| | SF3D | TRELLIS |
|---|---|---|
| čas na mesh | **~1,5 s** | ~4 min |
| geometrie | 11k vertexů, low-poly | 32k vertexů, jemnější |
| normály | **ano** | ne |
| textura | 1024², bez zapečeného světla | 2048² |
| licence | Stability Community (do $1M) | MIT |

**Výchozí backend se volí podle kategorie.** Šperky (`hat`, `helmet`, `neck`)
jdou rovnou TRELLISem — SF3D u ažurových struktur protrhne obruč a slije
perly do hrbolů. Kompaktní tvary (kabelky, masky, ocasy, zbraně) jedou
SF3D, kde je rozdíl neznatelný a rychlost 170×.

**Draft se před finálem přepočítá.** Schválení SF3D kusu v triage ho
nepošle rovnou do Blenderu: NAS požádá Spark o remesh TRELLISem
(`POST /ugc/remesh/{id}`), job čeká ve stavu `remeshing` a teprve s lepším
meshem jde na konverzi. Bez toho by draft doputoval až do finálního FBX —
tedy by se zlepšoval jen náhled v triage, ne prodávaný produkt.

SF3D není ComfyUI node; běží jako vlastní služba na Sparku
(`spark/sf3d-server/server.py`, port 8093) a drží model v paměti — proto
1,5 s místo 22 s, které stojí start `run.py`.

## Fronta přežije restart

`ugc-pipeline` ukládá nedokončené joby do `/spool/queue` a při startu je
načte zpět. Bez toho každý `make deploy-spark` zahodil rozdělanou práci
(jednou to stálo pět klobouků a podruhé skoro pět hodin fronty).

## Dva modely, podle toho co se generuje

| Co | Model | Prompt |
|---|---|---|
| předměty (zbraně, helmy, křídla, korunky) | Illustrious | danbooru tagy |
| co se nosí na těle (vlasy, oblečení, šperk na krku) | Juggernaut XL | produktová fotka |

Vybírá se automaticky podle kategorie (`PickModel` v `spark/internal/ugc`),
`checkpoint` v requestu to přebije. Důvod je v trénovacích datech: danbooru
modely znají předmět jako věc, ale oblečení a vlasy jen na postavě — na
prompt „dračí šaty" nakreslí draka. Fotorealistické modely mají v datech
e-shopové fotky, takže „šaty na neviditelné figuríně" jim jde přirozeně
(srovnávací test 2026-08-22: Illustrious drak, Juggernaut i FLUX správně
šaty; FLUX je 3× pomalejší, proto výchozí Juggernaut).

## Provozní znalosti (draze zaplacené)

- **ComfyUI tiše vyřadí nody** s chybějícím povinným vstupem a ohlásí
  „success". `Trellis2UnWrapAndRasterizer` **musí** dostat `bvh` z generátoru.
  Validační chyby jsou v odpovědi na `POST /prompt` — číst je.
- **Illustrious mluví danbooru tagy**, ne anglicky. `no humans, still life,
  object focus` funguje; „no character" nakreslí item na bustě.
- **Decimate počítá faces, Roblox trojúhelníky** — triangulovat před decimací.
  Fragmentovaný mesh (ořezaný koncept) se pod limit nedostane vůbec.
- **`make deploy-spark` zabije rozpracovanou frontu** — ugc-pipeline drží
  stav jobů v paměti, takže restart kontejneru zahodí vše, co ještě nedoběhlo
  (přišlo se na to ztrátou 5 klobouků). Před nasazením zkontroluj
  `curl spark:8092/ugc/jobs`, nebo počítej s doposláním.
- **Docker na JODA je snap** — mountovat jde jen `/home` a `/media`;
  `/pool` i `/tmp` se tiše vyprázdní. Data proto žijí na `/media/storage/ugc`.
- **SQLite drží data ve WAL** — při stěhování kopírovat `ugc.db` **i**
  `-wal`/`-shm`; samotný `.db` má 4 KB a byl by prázdný.
- `cloudflared/credentials.json` musí být **0444** (konektor běží jako uid
  65532); jinak error 1033.
- Token v `cert.pem` umí jen tunely a DNS — na Access apps je potřeba
  API token s `Access: Apps and Policies: Edit`.
- **3D prohlížeč servíruje ugc-api** (`/viewer/{id}` + `/viewer/assets/`),
  ne lokální proxy `model_viewer_plus`. Stránka, model i skript jsou tak na
  jednom originu a odpadají všechny platformní pasti (cleartext localhost
  na Androidu, ATS ve WKWebView na iOS, CORS všude) — každá z nich selhávala
  tiše a jinak.
- **GLB s 2048² texturami (~12 MB) se v model-viewer nevykreslí** — skončí
  černou plochou bez chyby. Ověřeno bisekcí v headless Chromu: samotná
  geometrie i tytéž textury zmenšené se zobrazí. Proto ugc-api vedle plné
  verze drží `preview.glb` se 512px texturami (~2 MB) a servíruje ho;
  originál je na `?full=1` a jde do konverze.

## Historie

Vzniklo ze čtyř plánů (UGC_NAS / UGC_SPARK / UGC_FORGE / UGC_STUDIO_APP)
sloučením repozitářů `ugc-backend` a `ugc_studio` (historie zachována přes
`git subtree`) a vyjmutím UGC pipeline z `AiStack/gen-queue`.
