# Lote 17-sep-2026 — primer corte de tus cuentas

No pude entrar a tus logins. Este lote cruza lo que venden DermaPharma, Birdman, Suplementos Mayoreo y Promexsa con **fichas públicas Fahorro (SKU = EAN + packshot + precio de lista)**. Sin EAN no se inventó nada.

Pegar en Supabase **después** de publicar este PR (las fotos apuntan a `farmacapital.mx/catalogo-propia/…`).

`sql/patch_alta_bajo_pedido_mayoristas_20260917.sql` — 10 SKUs. Idempotente.

| EAN | Mostrador | Ancla | Dónde sale |
| --- | --- | ---: | --- |
| 3337875890021 | La Roche-Posay Mela B3 suero 30 ml | 1467 | `/dermocosmetica` |
| 3337875761031 | La Roche-Posay Anthelios Age Correct FPS 50+ 50 ml | 998 | `/dermocosmetica` |
| 8429420248977 | Isdin Fusion Water Magic FPS 50 50 ml | 784 | `/dermocosmetica` |
| 8429420160750 | Isdin FotoUltra 100 Active Unify 50 ml | 813 | `/dermocosmetica` |
| 8429420244191 | Isdin FotoUltra Age Repair Fusion Water Color 50 ml | 792 | `/dermocosmetica` |
| 7503025737355 | Birdman creatina monohidratada 450 g | 584 | `/vitaminas?rubro=proteina` |
| 7503037273377 | Birdman Fitmingo proteína vegetal moka 510 g | 604 | `/vitaminas?rubro=proteina` |
| 7503037273940 | Birdman creatina Electrolyte Refresher Golden Peach 300 g | 482 | `/vitaminas?rubro=proteina` |
| 748927054804 | Optimum Nutrition Gold Standard whey vainilla 907 g | 1253 | `/vitaminas?rubro=proteina` |
| 7798031060140 | Nebucor nebulizador P-103 | 890 | `/dispositivos` |

Se omitió el inspirómetro Handy 7500399029079: Fahorro lo tiene en $0. Los SKU Promexsa tipo `ORT-…` / `DIS-…` siguen fuera.

Para el siguiente corte: exporta de tu B2B EAN + precio de lista (el tuyo, no el de Fahorro) y pégalo en `docs/fichas_proxima_vitrina.json`.
