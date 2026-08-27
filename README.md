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

**Draft se přepočítá až při balení, ne při triage.** Tlačítko *Zabalit*
nad zkonvertovaným kusem vyvolá remesh TRELLISem (`POST /ugc/remesh/{id}`),
job počká ve stavu `remeshing` a teprve s lepším meshem se rekonvertuje a
zabalí. Nejdřív to viselo na triage approve — jenže tam se schvalují
desítky kusů za minutu, každý spustil ~3minutový TRELLIS a fronta ComfyUI
narostla na 111 čekajících úloh, takže výroba nových konceptů se zastavila
na timeoutech. Pack je druhé síto: drahý výpočet se utratí jen za kusy,
které jsi opravdu viděl a chceš.

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

## Zadní strana: symetrie místo dalšího pohledu

Model vzniká z jednoho obrázku, takže zadní stranu nikdo neviděl — TRELLIS
si ji domýšlí a vyjde plochá a nezdobená. **„Rear view" prompting nefunguje:**
při stejném seedu vyrobil Juggernaut z pokynu „zezadu" ženu v klobouku ve
tříčtvrtečním pohledu a draka zase zepředu (test 2026-08-27). SDXL modely
pokyn o kameře u předmětů ignorují.

U kusů, které radiálně symetrické opravdu jsou (dort, korunka), je proto
levnější přední výseč zkopírovat než zadní stranu dogenerovat. Job nese
pole `symmetry`; s hodnotou `radial` nechá `convert.py` po retopu 120°
výseč kolem osy Z, dvakrát ji otočí a šev svaří.

**Přední strana je v Blenderu +Y, ne −Y.** Oba backendy staví mesh čelem
k glTF −Z (proto má prohlížeč výchozí orbit 200°), a import Y-up → Z-up
z toho udělá +Y. Znaménko rozhoduje, jestli se dokola kopíruje viděná, nebo
domyšlená strana — a špatně otočené to vypadá věrohodně, protože kopie
domyšlené strany je pořád konzistentní. Ověřeno renderem dortu proti
konceptu: na +Y jsou ostré potečené polevy z předlohy, na −Y rozmazaná záda. Kopie nesou UV originálu,
takže zdobení dokola obstará už existující EMIT bake — žádný krok navíc.

Zapíná se v Composeru (*Zdobení dokola*) a u už vygenerovaných kusů
`POST /jobs/{id}/reconvert?symmetry=radial` (`none` vypíná) — nový běh
Sparku kvůli tomu není potřeba. Report konverze pak nese `symmetry` a
`symmetry_seam_verts` (kolik vrcholů se svařilo na švu).

**Zapínat jen tam, kde symetrie opravdu je.** Ověřeno 2026-08-27: třípatrový
dort i vysoká královská koruna vyjdou zezadu zdobené a šev je sotva znát;
„agate slice headband crown" (plochý plátek achátu na stojánku) se stejným
nastavením rozpadl na slepenec tří výsečí. Radiální je koruna dokola, ne
každý kus v kolekci Crowns.

Šev zůstává jako vlásečnice: po svaření okrajových vrcholů a zaplnění děr
jich zbývá ~13 otevřených hran z ~5400, takže symetrický kus končí na
`WARN: mesh neni watertight`. Report proto nese i `open_edges` — malé číslo
je zbytek švu, velké rozpadlý mesh.

Nahledy zkonvertovaného kusu (triage vidí jen vstupní GLB, ne výsledné FBX):

    docker exec ugcfactory-ugc-blender-1 blender -b --factory-startup -noaudio \
      -P /app/blender_scripts/render_views.py -- \
      --dir /data/converted/<id> --angles 0,180

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
