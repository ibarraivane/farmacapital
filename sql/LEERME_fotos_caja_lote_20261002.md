# Fotos caja mostrador — 02-oct-2026

## Orden

1. **Merge / deploy** de esta rama (JPGs en `public/catalogo-propia/`).
2. En Supabase SQL Editor, en este orden:
   1. `sql/patch_alta_aktyzar_c14_20261002.sql` (alta C/14; el resto ya existía)
   2. `sql/patch_fotos_caja_lote_20261002.sql` (cablea las 5 fotos)

## Qué entra

| Producto | SKU / EAN | Archivo | Acción |
|---|---|---|---|
| Levofloxacino AMSA 500 mg C/7 | `FC-C721E8D7` / `7501349021419` | `…-caja-20261002.jpg` | Reemplazo de foto |
| **Aktyzar Omeprazol 20 mg C/14** | `FC-74792207` / `7502274792207` | `aktyzar-…-c-14-…jpg` | **Alta** + foto (C/120 ya existía) |
| Amikacina AMSA 500 mg/2 mL ×2 amp | `FC-11294615` / `7501349021488` | `amikacina-amsa-…jpg` | Reemplazo (antes Nadro) |
| Broxtorfan Adulto jarabe 120 mL | EAN `7501573907992` | `…-caja-20261002.jpg` | Reemplazo (quitaba marca de agua) |
| Cefalver susp 125 mg/5 mL 90 mL | `EQ-MAV007` / `7503000422610` | `cefalver-…jpg` | Reemplazo (antes Nadro) |

## Notas

- Origen `propia` (caja del dueño). No hotlink Nadro/Levic.
- Aktyzar C/14: costo ancla mayoreo $8.86 → precio $15 (+60% genérico). Stock 0 hasta Recibir.
- No inventa caducidad.
