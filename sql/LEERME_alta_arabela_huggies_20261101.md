# Alta foto 2026-11-01 — Arabela peine + Huggies Gold shampoo

## Productos

| SKU | EAN / clave | Nombre | Stock | Costo | PVP | Margen |
|---|---|---|---|---|---|---|
| `FC-48519024` | CLAVE K199B (sin EAN) | Arabela cepillo y peine para cejas | **2** | $7 | $15 | 53.3% |
| `FC-43417434` | `7501943417434` | Huggies Gold Manzanilla y Miel 200 ml | **1** | $30 | $50 | 40% |

Precios los fijó el dueño (no se usó +25% / +60% sobre costo).

## Fotos (van en el deploy)

- `public/catalogo-propia/arabela-cepillo-peine-cejas-k199b.jpg`
- `public/catalogo-propia/huggies-gold-shampoo-manzanilla-miel-200ml-7501943417434.jpg`

## Cómo aplicar

1. Merge / deploy de este PR (para que las fotos salgan en `farmacapital.mx/catalogo-propia/…`).
2. Pegar **todo** `sql/patch_alta_arabela_peine_huggies_shampoo_20261101.sql` en Supabase → SQL Editor → Run.
3. El `select` final debe mostrar ambos SKUs con stock 2 y 1.

Idempotente: si ya existen, solo imprime notice y no duplica.
