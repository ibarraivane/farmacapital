# Verificación de costos — 14 sep 2026

Fuente: ticket Bodega F-42 folio 77827 (`sql/generated/ticket_bodega_f42_77827.csv`).
El costo del catálogo **no es el ticket** cuando alguien partió el unitario entre las piezas.

## Escudo Rosa — no nos costó $4.48

| | |
|---|---|
| Ticket | `JBN ESCUDO ROSA PROT Y CUID 110G` |
| EAN | `7501943489004` |
| Piezas | **2** |
| Precio unitario | **$8.965** |
| Importe | **$17.93** |
| Catálogo hoy | $4.48 (= $8.97 ÷ 2) |

El $4.48 salió de un parche OCR (`patch_fix_costos_ocr_tickets.sql`) que volvió a dividir. El historial bueno ya tenía $8.96 (`patch_backfill_historial_tickets_20260824.sql`).

Con costo real **$8.97** y PVP **$42** el recargo sigue alto (368%). Techo 2.2× → **$20**, no $10.

## Misma trampa (costo catálogo = ticket ÷ piezas)

| Producto | Catálogo (mal) | Ticket unitario | Piezas | PVP | ¿Sigue caro? |
|---|---:|---:|---:|---:|---|
| Escudo Rosa 110 g | $4.48 | **$8.97** | 2 | $42 | Sí → ~$20 |
| Grisi Neutro 150 g | $6.96 | **$20.87** | 3 | $56 | Un poco → ~$46 |
| Escudo Frescura 110 g | $7.23 | **$14.45** | 2 | $42 | Sí → ~$32 |
| Dove barra 135 g | $15.10 | **$30.21** | 2 | $47 | No (56% sobre $30) |
| Pert oliva 100 ml | $7.40 | **$14.80** | 2 | $21 | No (~42%) |
| **Sedal Rizos 135 ml** | $9.08 | **$18.17** | 2 | $20 | **Al revés: PVP casi al costo** |
| Nivea Milk 400+100 | $22.30 | **$85.87** | 1 | $207 | Casi el techo ($189) |
| Kotex nocturna C/5 | $5.01 | **$10.01** | 2 | $16 | No |
| Claris C/40 | $9.43 | **$18.86** | 2 | $27 | No (queda corto) |
| Saba Invisible C/10 | $10.17 | **$20.34** | 2 | $29 | No |
| Ego Force roll-on | $11.95 | **$23.90** | 2 | $34 | No |
| Palmolive 120 g | $13.07 | **$26.14** | 2 | $37 | No |
| Gel X-Treme / Gorila | $11–$14 | **$22.61 / $28.30** | 2 | $32 / $40 | No |
| Nivea Pearl spray | $32.37 | **$64.73** | 2 | $91 | No (es ~40%, la regla) |
| Dove spray 150 ml | $32.14 | **$64.28** | 2 | $90 | No |
| Cepillos Pro / Oral-B | $13.50 / $15.51 | **$27 / $31.02** | 2 | $33 / $37 | No |
| Kotex regular C/10 | $10.61 | **$21.21** | 2 | $25 | No (margen corto) |

## Costos que sí cuadran con el ticket

Obao Coco $24.95, Obao Piel $25.83, Grisi Avena $21.72, Grisi Burra $21.88, Palmolive líquido $35.61, Nivea Softmilk 100 ml ~$26, Nivea Softmilk 400 ml $84.49, Evenflo Colors $15.48 (Farmalive).

## Sedal rizos $9.08

El ticket 77827 dice **2 × $18.165 = $36.33**, no $9.08. El $9.08 es $18.17 ÷ 2. Si hay otro ticket a $9.08, no está en los CSV del repo. Con $18.17 de costo, vender a $20 deja ~10%.

SQL para devolver el unitario del ticket: `sql/patch_corregir_costos_partida_qty_20260914.sql`
