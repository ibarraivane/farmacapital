# Levic A 9012442706 · 12-oct-2026 · $943.81

Factura papel (fotos) · entrega 833148360 · PUE efectivo · TOT 25 pzas.

## Qué pegar en Supabase

1. `sql/patch_carga_levic_9012442706.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_levic_9012442706.sql`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja.

## Renglones

| Clave | EAN | Mostrador | Pzas | Costo | Lote |
|---|---|---|---|---|---|
| ALP0609 | 7501384541620 | Gabapentina 400 mg (Psicofarma C/15) | 1 | 54.16 | 6080726 |
| ALP0675 | *(sin EAN publicado)* | Rosuvastatina 20 mg (Alpharma C/15) | 1 | 43.85 | 2609123 |
| AMS322 | 7501349021181 | Cefalexina 500 mg AMSA C/20 (ya catálogo) | 4 | 39.58 | J26A067 |
| AMS329 | 7501349020436 | Gabapentina 300 mg AMSA C/15 | 2 | 23.27 | U26E313 |
| BEA394 | 7501342803715 | Telmisartán 40 mg beadvance C/30 | 2 | 39.35 | U26F330 |
| CHI055 | 7501088505485 | Synalar-O 15 mL | 1 | 188.05 | BEK048 |
| GEN002 | 7501842900105 | Adopren 600 mg C/10 | 5 | 15.93 | 602015A |
| GEN003 | 7501842952890 | Adopren 800 mg C/10 | 3 | 19.60 | 603025A |
| NOV125 | 7501075721249 | Natrazim 40 mg C/14 | 2 | 21.73 | 881976 |
| SET021 | *(sin EAN)* | Seltz Magnesio Complex 20 tab | 1 | 83.34 | L60639 |
| VIT068 | 7501478316813 | Ibuprofeno cafeína 400/100 (Gel Pharma; ya catálogo) | 3 | 31.87 | M26091 |

Subtotal $930.48 + IVA $13.33 (solo Magnesio Complex) = **$943.81**.

ALP0675 y SET021 se buscan por SKU (`EQ-ALP0675` / `EQ-SET021`) hasta que la pistola lea el EAN de la caja.
