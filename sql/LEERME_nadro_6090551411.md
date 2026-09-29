# Nadro folio 6090551411 · 28-sep-2026 · $440.18

Factura CFDI Nadro México Sur · UUID `63A7365A-98A6-4068-83F3-1897395A2AE8` · 4 renglones · 21 piezas.

Subtotal renglones $379.47 + IVA $60.71 = **$440.18**.

## Veredicto

| EAN pistola | Ticket | SKU | Piezas | Costo u. | Acción |
|---|---|---|---:|---:|---|
| `7501026462245` | CHUPON TERNURA FLOR/BALON MIEL S | `FC-26462078` | 18 | $3.10 | Solo costo + renombrar ficha |
| `4042809591446` | LEUKOPLAST HYPAFIX 10 CM X 2M | `FC-09591446` | 1 | $71.63 | **Alta nueva** + foto |
| `650240032431` | MJE ASEPXIA PVO COM TONO CANELA 10G | `FC-40032431` | 1 | $126.02 | **Alta nueva** + foto |
| `650240032455` | MJE ASEPXIABBPVOCOMPNATMA 10G | `FC-40032455` | 1 | $126.02 | **Alta nueva** + foto |

## EANs corregidos (como Garnier)

| Factura (DV inválido) | Pistola / iNadro / caja |
|---|---|
| `7501025462245` | `7501026462245` |
| `4042809591448` | `4042809591446` |

El chupón **ya estaba** en catálogo (`FC-26462078`). El papel imprimió un dígito mal; el código de la tira es `7501026462245`.

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_6090551411.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_nadro_6090551411.sql`.

CSV: `sql/generated/ticket_nadro_6090551411.csv`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja. No inventar `0000`.

## Ficha (no el código del PDF)

- **Chupón:** Ternura flor y balón con miel (marca Ternura; Nadro dice CARTER = fabricante).
- **Hypafix:** Leukoplast Hypafix 10 cm × 2 m (marca Leukoplast; Nadro dice ESSITY).
- **Asepxia Canela / Natural Mate:** nombres de mostrador desde descripción iNadro; marca Asepxia (no GENOMMALAB).

Precios sugeridos de alta: recargo **+25%** al costo (marca).

Regenerar: `python3 scripts/generar_carga_nadro_6090551411.py`
