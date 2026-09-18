# Levofloxacino: ficha, precio y buscador (18-sep-2026)

## Qué se veía

En tienda, AMSA (caja 750 mg en la foto) y Beadvance 500 mg salían **al mismo precio**.
En POS, `Levofloxaci` traía 2 productos y `Levofloxacino` traía 3, partidos distinto.

## Qué es cada SKU

| SKU | Lab | Dosis real | EAN | PVP |
|---|---|---|---|---|
| `FC-C721E8D7` | AMSA | **500 mg** × 7 (GS1 `7501349021419`, ticket Equilibrio) | 7501349021419 | `ceil(costo × 1.60)` |
| `FC-28833707` | Beadvance | 500 mg × 7 | 7501342802954 | `ceil(costo × 1.60)` |
| `FC-52200809` | Landsteiner / Cina | **750 mg** × 7 | 7502225092486 | mínimo $47 |
| `FC-B25B4654` | duplicado pobre (decía ciprofloxacino) | — | — | desactivar |

La foto de 750 mg en el AMSA está mal: ese EAN es 500 mg. Si en anaquel hay cajas AMSA 750 mg, van con EAN `7501349021433` (SKU nuevo), no en `FC-C721E8D7`.

## Aplicar

1. Merge / deploy del buscador (prefijo de la misma molécula + mismo empaque 7 tab).
2. Correr en Supabase: `sql/patch_levofloxacino_fichas_y_precios_20260918.sql`
3. Cambiar la foto del AMSA a la caja **500 mg** (no la de puntos verdes 750 mg).

El SELECT del final lista otras familias con la misma dosis/PVP invertido para revisar a mano (no se tocan solas).
