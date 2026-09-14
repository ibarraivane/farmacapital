# Relectura de tickets — unitario vs cantidad (14 sep 2026)

Había un error: se leyó el **importe del renglón** como si fuera el **precio de una pieza**, y luego se multiplicó otra vez por la cantidad.

## Qué pasó

El CSV `sql/generated/ticket_bodega_f42_77827.csv` trae:

| columna | Escudo Rosa | Sedal Rizos 135 ml |
|---|---:|---:|
| `cantidad` | 2 | 2 |
| `precio_unitario` | 8.965 | 18.165 |
| `subtotal` | 17.93 | 36.33 |

Esa columna `precio_unitario` **no es el costo de una**. Es el **importe** (lo que se pagó por las 2 piezas). El `subtotal` es ese importe × cantidad otra vez: está inflado al doble.

| | Lectura mala | Lectura buena |
|---|---|---|
| Escudo Rosa | 2 × $8.97 = $17.93 | **2 × $4.48 = $8.96** |
| Sedal 135 ml | 2 × $18.17 = $36.33 | **2 × $9.08 = $18.16** |
| Grisi Neutro | 3 × $20.87 = $62.61 | **3 × $6.96 = $20.87** |

El dueño ya había dicho que Sedal se compró a **$9.08**. El OCR del PDF (`auditoria_precios_fixes.csv`) y el catálogo vivo coinciden: unitario = importe ÷ piezas.

Recibir ya sabía esto (`unidadDesdeImporte` / `fc_costo_unitario_renglon`): si el renglón trae el total de N, se parte. El error fue tratar el CSV como si `precio_unitario` ya viniera partido.

## Bodega F-42 77827 — qty ≥ 2

Unitario real = `precio_unitario` del CSV ÷ `cantidad`.

| Producto | Pzas | CSV «unitario» (es importe) | Unitario real | Catálogo vivo |
|---|---:|---:|---:|---:|
| Escudo Rosa 110 g | 2 | $8.97 | **$4.48** | $4.48 |
| Grisi Neutro 150 g | 3 | $20.87 | **$6.96** | $6.96 |
| Escudo Frescura 110 g | 2 | $14.45 | **$7.23** | $7.23 |
| Dove barra 135 g | 2 | $30.21 | **$15.10** | $15.10 |
| Pert oliva 100 ml | 2 | $14.80 | **$7.40** | $7.40 |
| Sedal Rizos 135 ml | 2 | $18.17 | **$9.08** | $9.08 |
| Palmolive 120 g | 2 | $26.15 | **$13.07** | $13.07 |
| Claris C/40 | 2 | $18.86 | **$9.43** | $9.43 |
| Kotex nocturna C/5 | 2 | $10.01 | **$5.01** | $5.01 |
| Kotex regular C/10 | 2 | $21.21 | **$10.61** | $10.61 |
| Saba Invisible C/10 | 2 | $20.34 | **$10.17** | $10.17 |
| Ego Force roll-on | 2 | $23.90 | **$11.95** | $11.95 |
| Gel X-Treme / Gorila | 2 | $22.61 / $28.31 | **$11.31 / $14.15** | $11.31 / $14.15 |
| Nivea Pearl spray | 2 | $64.73 | **$32.37** | $32.37 |
| Dove spray 150 ml | 2 | $64.29 | **$32.14** | $32.14 |
| Cepillos Pro / Oral-B | 2 | $27.00 / $31.02 | **$13.50 / $15.51** | $13.50 / $15.51 |

Los renglones de **1 pieza** (Obao, Axe, Rexona, Sedal 300 ml, etc.) no se tocan: ahí importe = unitario.

## Otros tickets (Farmalive, Nadro, City Farma, Levic, IFC…)

En esos CSV, cuando hay 2+ piezas, `precio_unitario` **sí** cuadra con el catálogo (Afrin, Electrolit, Neomelubrina, Pioglitazona, etc.). El lío de importe-como-unitario es el de Bodega F-42 77827.

## Qué no se corre

- No subir costos a $8.97 / $18.17 / $20.87.
- Si ya se corrió esa alza: `sql/patch_corregir_costos_partida_qty_20260914.sql` ahora **devuelve** el unitario.
- Las sugerencias de PVP usan el costo de una pieza: Escudo $4.48 → techo $10, no $20.
