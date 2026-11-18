# IFC F8 132647 — Recibir

Cliente **LUIS** · MENUDEO · CJ 01 · 07-nov-2026 14:27.

## Qué correr

1. Pegar **todo** `sql/patch_ifc_132647_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.
2. En Recibir debe aparecer el botón vivo **IFC F8 Tienda · 132647**.
3. Escanear cada pieza → MMAA de la caja (no inventar `0000`) → confirmar.

## Totales

- 2 renglones / **11 pzas** / **$215.50**
- Folio **132647** del ticket térmico.
- Ambos ya en catálogo (solo actualiza costo).

## Notas de mapeo

| Ticket | EAN | SKU | Nota |
|---|---|---|---|
| MERCURIO ACEITE RICINO … 84529 | 3311000001292 | FC-00001292 | ya · $9.50 |
| PROTEC VENDA YESO 20CM … 84129 | 7501048640829 | FC-46640629 | ya · pieza 20 cm × 2.75 m |

## Regenerar

`python3 scripts/generar_carga_ifc_132647.py`
