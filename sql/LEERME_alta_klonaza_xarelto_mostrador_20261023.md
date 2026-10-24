# Alta: Klonaza + Xarelto (fotos 2026-10-23)

Cajas en mostrador. No estaban en catálogo. Stock **1** de cada una.

## Qué correr

1. Merge/deploy (para que vivan las fotos en `/catalogo-propia/`).
2. Pegar **todo** `sql/patch_alta_klonaza_xarelto_mostrador_20261023.sql` en Supabase → SQL Editor → Run.
3. Cuando veas MMAA en la caja: actualizar el lote (no dejar `0000`).

Re-ejecutable: si la galería ya tiene la URL (`ux_producto_imagenes_producto_url`), no vuelve a insertar.

## Productos

| Producto | EAN caja | SKU | PVP ancla |
|---|---|---|---|
| Klonaza Atlantis 80/80/125 mg C/20 cápsulas | **7501471800029** | FC-71800029 | $304 (Farmalisto) |
| Xarelto Bayer rivaroxabán 20 mg C/28 tabletas | **7501318608788** | FC-18608788 | $3214 (Vitau) |

Costo null hasta compra. Ambos con receta.

## No confundir

- `7501471800210` / FC-71800210 = floroglucinol/trimetil **sin** clonixinato (otro SKU).
- Este Klonaza es el trío 80/80/125 mg (`7501471800029`).

## No hacer

- No darlos de alta a mano en Inventario → Catálogo.
- No inventar caducidad `0000`.
- No pegar PVP Fahorro/Similares como si fuera costo de mayoreo.
