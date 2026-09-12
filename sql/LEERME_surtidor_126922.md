# El Surtidor 126922 · 08-sep-2026 · $474.59

## Qué pegar en Supabase

1. **Después del merge/deploy** (para que vivan las JPG):  
   `sql/patch_carga_surtidor_126922.sql` — altas + cola Recibir.
2. Si corriste la carga antes del deploy:  
   `sql/patch_fotos_surtidor_126922.sql`.

## Renglones

| # | Ticket | EAN pistola | Producto | Qty | Costo | Alta? |
|---|---|---|---|---|---|---|
| 1 | `7501318612655` | mismo | Aspirina Protect 100 mg C/28 | 1 | 134.99 | **Sí** |
| 2 | `7501868901131` | mismo | Alcohol Dibar azul 1 L | 2 | 41.00 | No |
| 3 | `7501868901117` | mismo | Alcohol Dibar azul 250 ml | 2 | 11.30 | No |
| 4 | `7501868901124` | mismo | Alcohol Dibar azul 500 ml | 2 | 24.00 | No |
| 5 | `7501033950100` | **`7501033954061`** | Ensure Singles chocolate 237 ml | 1 | 42.00 | No |
| 6 | `7501033950063` | **`7501033954078`** | Ensure Singles fresa 237 ml | 1 | 42.00 | No |
| 7 | `7501033951008` | **`7501033956317`** | Pediasure Plus chocolate 237 ml | 1 | 44.00 | No |
| 8 | `7501033950209` | **`7501033956294`** | Pediasure Plus vainilla 237 ml | 1 | 44.00 | No |
| 9 | `750101906116` (truncado) | **`7501019068713`** | Saba Diarios largos C/16 | 1 | 15.00 | **Sí** |

## Notas de pistola

- Ensure/Pediasure: el ticket dice 236 ml con EAN viejos; la botella y el catálogo usan 237 ml. En Recibir va el EAN actual.
- Saba: el ticket cortó el código; el de paquete C/16 largos es `7501019068713` (YZA).
- Caducidad: gris hasta MMAA de la caja. No poner `0000`.
- Dibar 250 ml: sin foto nueva propia (el crop del grupal no era Dibar). 1 L y 500 ml sí.

## Fotos en repo

`public/catalogo-propia/aspirina-protect-100mg-c28.jpg`  
`public/catalogo-propia/dibar-azul-1000ml.jpg`  
`public/catalogo-propia/ensure-singles-chocolate-237ml.jpg`  
`public/catalogo-propia/ensure-singles-fresa-237ml.jpg`  
`public/catalogo-propia/pediasure-plus-chocolate-237ml.jpg`  
`public/catalogo-propia/pediasure-plus-vainilla-237ml.jpg`  
`public/catalogo-propia/saba-diarios-largos-c16.jpg`
