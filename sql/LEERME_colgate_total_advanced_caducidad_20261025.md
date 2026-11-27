# Colgate Total Advanced Clean 75 ml — caducidad

| Campo | Valor |
|-------|-------|
| EAN | `7509546052632` |
| SKU | `FC-46052632` |
| producto_id | `20250` |
| Stock | **3** |
| Ticket | Bodega F-42 · folio **28130** · 24-oct-2026 12:39 (hora del ticket) |
| Alta en catálogo | 24-oct-2026 13:24 America/Mexico_City |
| Entrada a stock (aprox.) | 24-oct-2026 16:37 America/Mexico_City |
| Lote | `RX-28130-5942` (id **3056**) |
| Caducidad en sistema | **2026-10-31** (MMAA `1026` → oct 2026) |

## Qué pasó

En el ticket térmico la línea viene como:

`CEP DENT COLGATE TA+C D T ACC 75ML OCT26`

Walmart/Bodega suele pegar el mes/año de caducidad al final del nombre. Al armar la carga (**PR #486**) se dejó nota explícita: **no** guardar `OCT26` como caducidad; pedir MMAA de la caja al escanear.

En anaquel quedó `2026-10-31` (mismo mes/año que el ticket). Otra pasta del mismo folio (`Colgate Luminous White`, lote `RX-28130-5951`) tiene caducidad **2027-09-30** — contrastable.

## Cómo corregir (cuando lean la caja)

1. **Inventario** → buscar Colgate Total Advanced Clean → editar caducidad del lote (MMAA de la caja, p. ej. `0928` → sep 2028).
2. O pegar en Supabase el patch `sql/patch_corregir_colgate_total_advanced_caducidad_20261025.sql` **después** de poner la fecha real (no inventar).

Diagnóstico solo lectura: `sql/diagnostico_colgate_total_advanced_caducidad_20261025.sql`.

## No hacer

- Inventar MMAA “a ojo” ni copiar otra pasta del ticket.
- Dejar `2026-10-31` si la caja dice otro mes/año: FEFO y alertas de caducidad la tratan como crítica (~5 días).
