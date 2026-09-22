# Nadro folio E090246807 · 20-sep-2026 · $1,421.75

Factura CFDI Nadro México Sur · 3 renglones · 8 piezas.

## Veredicto

| EAN | Ticket | SKU | Piezas | Costo u. | Acción |
|---|---|---|---:|---:|---|
| `7501022112106` | EXCELSIOR POM 8 G | `FC-22112106` | 3 | $50.69 | **Alta nueva** |
| `7502223111202` | LIDOCAINA 10% SPRAY 115 ML LGEN | `EQ-QUM014` | 3 | $134.34 | Solo costo (Pharmacaine) |
| `7502214986659` | MIFEPRISTONA 200MG CJA 1 TAB | `FC-14986659` | 2 | $433.33 | **Alta nueva** |

Suma renglones: $152.07 + $403.02 + $866.66 = **$1,421.75** ✓

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_e090246807.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_nadro_e090246807.sql`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja.

## Notas de ficha

- **Excelsior:** nombre de mostrador desde iNadro (Grisi pomada 8 g), no el código del ticket.
- **Pharmacaine:** ya en catálogo como `EQ-QUM014` / `7502223111202`. Costo sube de ~$101 a $134.34.
- **Mifepristona:** `DKT MEXICO` en Nadro es distribuidor, no marca de mostrador. Requiere receta.

## Recibir

Subir también `sql/generated/ticket_nadro_e090246807.csv` si prefieren CSV en lugar del SQL.
