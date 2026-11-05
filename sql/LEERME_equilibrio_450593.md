# Equilibrio 450593 — Recibir

Cliente **307513** Luis Ángel Palillero Ventura · pedido online · sucursal Iztapalapa 2 · 04-nov-2026.

## Qué correr

1. Pegar **todo** `sql/patch_equilibrio_450593_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.
2. En Recibir debe aparecer el botón vivo **Equilibrio · 450593**.
3. Escanear cada caja → MMAA de la caja (no inventar `0000`) → confirmar.

## Totales

- 2 renglones / **8 pzas** / **$236.88** (subtotal P.U. $224.40 + IVA $12.48)
- Folio **450593** del ticket térmico.
- **1 alta** stock 0: FC-83140731 Vengesic
- Ya en catálogo: FC-66055303

## Notas de mapeo

| Clave ticket | EAN | SKU | Nota |
|---|---|---|---|
| JAY142 | 7506022315281 | FC-66055303 | Meditest ya en catálogo · Jayor |
| COL100 | 0780083140731 | FC-83140731 | Vengesic Collins · alta · LGEN +60% |

## Regenerar

`python3 scripts/generar_carga_equilibrio_450593.py`
