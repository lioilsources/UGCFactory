# UGCFactory

<!-- Max 80 řádků. Co se nevejde, jde do docs/ a sem jeden odkaz. Veřejné repo: žádné LAN IP, domovské cesty, ID. -->

## Účel
Továrna na Roblox UGC itemy a fantasy postavy: prompt → koncept → 3D model (GLB) →
konverze do robloxích limitů (FBX) → zabalení k nahrání. Tři stroje (SPARK, NAS/JODA, appka), jedno repo.

## Build a test
```
make test            # gate: go test (nas), go vet (spark), flutter test (app)
make deploy-nas      # ugc-api + blender worker + tunnel na JODA
make deploy-spark    # ugc-pipeline na SPARK
make app-web         # web build appky -> nas/web -> redeploy NAS
make app-android     # APK na připojený telefon
make status          # zdraví všech služeb
```

## Mapa
- `spark/` — Go služba `ugc-pipeline` (port 8092), ComfyUI workflow šablony, `sf3d-server/` (user systemd unit).
- `nas/` — Go `ugc-api` (port 8095), headless Blender worker, compose stack `ugc-stack.yaml`, Cloudflare tunnel.
- `app/` — Flutter appka `ugc_studio` (Composer, fronta, triage; Android/iOS/macOS/web).
- `tools/ugc-pull.sh` — stažení zabalených kusů na Mac.
- `docs/` — smoke report, licence 3D backendů, TestFlight postup.
- `.github/workflows/` — release z tagu (TestFlight, Firebase Android, macOS); PR workflow není.

## Invarianty
- `.env` na NAS se při deployi nepřepisuje, jen doplní chybějící klíče z `nas/.env.example`.
- `nas/cloudflared/credentials.json` je mimo git a deploy ho nesmí přepsat.
- Access token appky žije v `app/.cf-token` (gitignored), do buildu jde přes `--dart-define`.
- `make deploy-spark` restartuje pipeline; nedokončené joby drží `/spool/queue`.

## Kam dál
- `README.md` — architektura, provozní znalosti, backendy SF3D/TRELLIS.
- `nas/README.md`, `nas/docs/FANTASYCHARACTER_PLAN.md` — API a linka fantasy postav.
- `app/README.md`, `docs/TESTFLIGHT.md` — appka a její vydávání.
