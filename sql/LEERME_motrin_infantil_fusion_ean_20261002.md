# Motrin Infantil 120 ml — fusión EAN (2026-10-02)

## Qué pasó

Había dos códigos para el **mismo** Motrin Infantil suspensión 120 ml (ibuprofeno 2 g/100 ml, sabor frutas):

| EAN | Origen |
|---|---|
| `7501007535494` | Ticket Farmalive / empaque viejo J&J · SKU `FC-07535494` |
| `7501109902866` | Caja actual Kenvue · a veces `FC-09902866` |

No es el Pediátrico gotas 15 ml (`7501109902637`).

Por eso Agotados podía listar un renglón en 0 mientras el otro tenía piezas.

## Qué hacer

1. Pegar en Supabase → SQL Editor → Run:
   `sql/patch_motrin_infantil_fusion_ean_20261002.sql`
2. Verificar el SELECT final:
   - `FC-07535494` activo, `codigo_barras = 7501109902866`, stock = piezas reales
   - `FC-09902866` (si existía) `activo = false`
   - `id_scan_viejo` e `id_scan_nuevo` = mismo `id`
3. En Inventario: filtro Agotados → Motrin no debe aparecer si hay stock.
4. Pistola: ambos EAN abren la misma ficha (POS / Recibir).

El deploy del front trae el par en `eanParesConocidos.js`. El SQL hay que pegarlo a mano en producción.
