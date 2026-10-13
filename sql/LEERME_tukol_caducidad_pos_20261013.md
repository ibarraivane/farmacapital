# Tukol-D adulto: Sin lotes en POS con stock en inventario (13-oct-2026)

Correr en Supabase SQL Editor:

1. `patch_tukol_caducidad_invalida_pos_20261013.sql`

## Qué pasó

| Dónde | Qué veías |
|---|---|
| Inventario | 1 pieza (suma `lotes.cantidad_actual`) |
| POS | Tag **Sin lotes** · Agregar bloqueado |

El lote vivo de `FC-40010712` tenía `fecha_caducidad = 0027-10-01` (año 27), metido por el restore de ago-2026 (`patch_restaurar_caducidades_y_costos_20260818.sql`). Debía ser **2027-10-01**.

FEFO del POS y `get_lote_fefo` tratan cualquier fecha `< hoy` como vencida → 0 vendible. Inventario no filtra vencidos al pintar la columna Stock.

## Qué hace el patch

- Corrige años `< 1990` en `lotes` (00YY → 20YY si cae en 2020–2045; si no, NULL). Tukol: `0027-10-01` → `2027-10-01`.
- `get_lote_fefo` trata año inválido como sin MMAA (no bloquea cobro).

El front (`ordenarLotesFefo`) ya alinea con la misma regla.
