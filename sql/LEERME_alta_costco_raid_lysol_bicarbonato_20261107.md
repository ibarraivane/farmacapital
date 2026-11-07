# Alta Costco · Raid + Lysol + bicarbonato · 07-nov-2026

Compra Costco (sin remisión PDF). Ninguno estaba en catálogo.

| Producto | EAN / ref | SKU | Costo | PVP (+25% marca) |
|---|---|---|---|---|
| Bicarbonato Just About Foods 6.1 kg | Costco `#694121` (sin EAN en bolsa) | `FC-00694121` | $259 | $324 |
| Raid Casa y Jardín eucalipto 3×430 ml | `7503046433663` | `FC-04643366` | $289 | $362 |
| Raid MAX eucalipto 3×430 ml | `7501032914233` | `FC-03291423` | $329 | $412 |
| Lysol Crisp Linen 3×475 g | `7501058784278` | `FC-05878427` | $519 | $649 |

## No confundir

- Lysol **lata suelta** 475 g `7501058752796` / `FC-58752796` — otro SKU.
- Lysol 354 g `7501058796882` / `FC-58796882` — otro SKU.
- Bicarbonato Velázquez 200 g `FC-08DB70CB` — otro producto.

## Qué pegar

1. Supabase → SQL Editor → Run: `sql/patch_alta_costco_raid_lysol_bicarbonato_20261107.sql` (**v2**: sin temp table / sin `×`; si la v1 falló, pega esta).
2. Stock queda en **0** (sin inventar lote/MMAA). Ajusta a **1** por SKU en Inventario (1 paquete físico c/u).
3. Fotos: pendientes (packshot Costco / mostrador).

Si el Lysol entró con cuponera −25%, actualiza `costo` a ~389 y recalcula PVP.
