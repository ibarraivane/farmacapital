# Nadro folio 6091460910 · 22-oct-2026 · $1,626.29

Factura CFDI Nadro México Sur · 3 renglones · 4 piezas.

## Veredicto

| EAN pistola | Ticket | SKU | Piezas | Costo u. | Acción |
|---|---|---|---:|---:|---|
| `7501385491085` | DANZEN 10 MG 20 TAB | `FC-85491085` | 1 | $373.31 | **Alta nueva** |
| `7501385420061` | DANZEN 5 MG 30 TAB | `FC-85420061` | 1 | $290.02 | **Alta nueva** |
| `7502214986659` | MIFEPRISTONA 200MG CJA 1 TAB | `FC-14986659` | 2 | $481.48 | Solo costo (ya en catálogo) |

Suma renglones: $373.31 + $290.02 + $962.96 = **$1,626.29** ✓

## EAN del papel

El CFDI a veces imprime dígito verificador inválido. iNadro / pistola:

| Producto | Papel (inválido) | Pistola |
|---|---|---|
| Danzen 10 mg | `…91095` u OCR similar | **`7501385491085`** |
| Mifepristona | `…88890` / `…88658` | **`7502214986659`** (mismo EAN que Nadro E090246807) |

Danzen 5 mg ya venía bien: `7501385420061`.

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_6091460910.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_nadro_6091460910.sql`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja.

## Notas de ficha

- **Danzen:** marca Danzen / lab Sanfer / serratiopeptidasa. Dosis en el nombre (`10 mg` / `5 mg`); empaque en presentación. Receta.
- **Mifepristona:** ya cargada en E090246807. `DKT MEXICO` en Nadro es distribuidor, no marca. Costo sube a $481.48. Receta.
- **Precio sugerido alta:** recargo sobre costo (+25% marca / +60% genérico). No pisa PVP si ya hay precio.

## Recibir

CSV: `sql/generated/ticket_nadro_6091460910.csv`.

Regenerar: `python3 scripts/generar_carga_nadro_6091460910.py`
