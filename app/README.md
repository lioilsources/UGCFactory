# ugc_studio

Kokpit UGC továrny: batch composer → fronta → swipe triage, nad `ugc-api`
(NAS, viz [ugc-backend](https://github.com/lioilsources/ugc-backend)).
Flutter (macOS/iOS/Android), Riverpod, go_router — M1 z UGC_STUDIO_APP_PLAN.

## Obrazovky (M1)

- **Composer** — kategorie × styl × kolekce → `POST /generate` per kombinace
  (proxy přes NAS na Spark; ~4 min/item, serializovaně). Ověřené kategorie
  mají odznak; hair je známé riziko (Illustrious neumí vlasy bez hlavy).
- **Fronta** — živý seznam jobů přes SSE `/events`, seskupený podle stavu;
  z ní jde zabalit `converted` a retrynout `failed`.
- **Triage** — swipe: doprava approve (→ Blender konverze), doleva reject,
  kostka = reroll (stejný prompt, nový seed).
- **Nastavení** — URL API (LAN `http://192.168.88.88:8095`, později tunnel).

## Spuštění

```bash
flutter pub get
flutter run -d macos    # nebo -d <iphone>
```

Na telefonu musí být zapnutý **Tailscale** (jinak tailnet jméno nedosáhne).
Při přístupu na LAN adresu vyvolá macOS/iOS dotaz na **Local Network** —
povolit, jinak jsou pakety tiše zahozené (Sequoia). CLI smoke test
(`dart run tool/smoke.dart`) na macOS narazí na stejný gate; API si ověř
raději curlem.

## M2/M3 (další)

3D review (model_viewer_plus nad `/jobs/{id}/glb`), catalog manager
(PATCH /items, ceny, limited), statistiky šablon.
