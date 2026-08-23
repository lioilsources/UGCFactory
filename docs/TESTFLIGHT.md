# TestFlight pro ugc_studio

CI/CD staví na centrálním [Distribution](https://github.com/lioilsources/Distribution)
repu — certifikáty a klíče jsou sdílené napříč appkami, per-app se řeší jen
App ID, provisioning profil a záznam v App Store Connect.

Workflow `.github/workflows/release-ios.yml` je převzatý z `Distribution/workflows/`
a upravený pro tenhle monorepo (Flutter projekt je v `app/`, ne v kořeni).
Navíc předává Cloudflare Access token přes `--dart-define`, aby appka z
TestFlightu dosáhla na `ugc.ol1n.com`.

## Co zbývá udělat (vyžaduje desktop a Apple účet)

1. **App ID** na developer.apple.com → Identifiers → `+` → App IDs →
   `com.ol1n.ugcStudio`
2. **App Store Distribution provisioning profile** → Profiles → `+` →
   Distribution → App Store → vybrat to App ID → stáhnout
3. Uložit do `Distribution/Apple/UGCFactory/<cokoliv>.mobileprovision`
4. **Vytvořit appku v App Store Connect** (bez ní TestFlight upload spadne)
5. Nastavit GitHub secrets:
   ```bash
   export BW_SESSION=$(bw unlock --raw)
   cd /Volumes/YOTTA/Dev/Distribution
   ./scripts/setup-gh-secrets.sh --repo lioilsources/UGCFactory --app UGCFactory
   ```
6. Přidat dva secrets navíc, které skript nezná (Access token pro API):
   ```bash
   gh secret set UGC_CF_CLIENT_ID --repo lioilsources/UGCFactory < <(sed -n 's/^CF_CLIENT_ID=//p' app/.cf-token)
   gh secret set UGC_CF_CLIENT_SECRET --repo lioilsources/UGCFactory < <(sed -n 's/^CF_CLIENT_SECRET=//p' app/.cf-token)
   ```

## Vydání

```bash
git tag v0.1.0 && git push origin v0.1.0
```

Workflow se spustí na tag `v*`, nebo ručně přes **Actions → Release iOS →
Run workflow**. Build number se bere z čísla běhu, takže se nemusí ručně
zvyšovat.

## Proč to zatím nejede

Chybí kroky 1–5 výše — všechny vyžadují přihlášení k Apple účtu.
Do té doby zůstává instalace přes `make app-ios` (podpis platí do 2. 8. 2027).
