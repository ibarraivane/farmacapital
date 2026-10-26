# Kitoscell no salía en Inventario

## Qué pasó

Compraron **Kitoscell Gel 3.5 g** (EAN `7502224228060`, SKU `FC-24228060`): hay **3 piezas** y precio **$130**, pero el producto seguía con `bajo_pedido = true` (vitrina «Te lo conseguimos»).

Inventario y POS **no cargan** la vitrina por defecto → parece que “no están en inventario”.

Mismo caso (stock > 0 + vitrina): Isdin Ureadin Ultra 20 (1) y Accu-Chek Active (1).

## Qué correr

1. Pegar **todo** `sql/patch_kitoscell_anaquel_stock_20261025.sql` en Supabase → SQL Editor → Run.
2. En Inventario buscar **Kitoscell** (con s): deben aparecer las 3 piezas en anaquel, sin prender «Suplementos y dermatología».
3. En POS también debe salir al buscar / escanear.

## Qué hace el patch

- `bajo_pedido = false` en todo producto con stock > 0 que seguía en vitrina.
- Nombre de mostrador: `Kitoscell Gel` (quita «Tubo C»).
- Recibir: al entrar stock, apaga `bajo_pedido` para que no se repita.

## Nota

La marca comercial es **Kitoscell** (con s). Otras presentaciones (10 g, 30 g, 90 g) siguen en vitrina con stock 0 hasta que las reciban.
