# Rexona roll-on 30 ml (V8 + Powder Dry) — 2026-10-04

## Orden

1. Pegar en Supabase → SQL Editor → Run: `patch_alta_rexona_rollon_v8_powder_dry_20261004.sql`
2. Esperar deploy de este PR (`public/catalogo-propia/…` en farmacapital.mx)
3. Pegar: `patch_fotos_rexona_rollon_v8_powder_dry_20261004.sql`

## Productos

| EAN-8 | SKU | Nombre | Costo | PVP | Stock | Caducidad | Lote |
|---|---|---|---|---|---|---|---|
| 78930841 | FC-78930841 | Rexona Men V8 | $18 | **$23** | 6 | 2028-02-29 | ULB251954 |
| 78924239 | FC-78924239 | Rexona Powder Dry | $18 | **$23** | 6 | 2028-03-31 | ULC061232 |

PVP = `ceil(18 × 1.25)` marca/patente (+25% sobre costo).

## Fotos

- `public/catalogo-propia/rexona-men-v8-roll-on-30-ml-78930841.jpg`
- `public/catalogo-propia/rexona-powder-dry-roll-on-30-ml-78924239.jpg`
