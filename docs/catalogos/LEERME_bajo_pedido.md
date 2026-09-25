# Catálogos bajo pedido (septiembre 2026)

Listas de mayoreo para la vitrina `/conseguir`. **No** se venden con PVP de Promexsa ni de otra farmacia.

| Archivo | Proveedor | Rol |
|---|---|---|
| `catalogo_dermaexpress.csv` | Dermaexpress | Costo mayoreo dermo + foto Shopify |
| `catalogo_birdman.csv` | Birdman | Costo base (escalón chico). Sin playeras |
| `ewafra_dis_agosto_2026.csv` | Ewafra (lista DIS ago-2026) | Costo lista 6 −20% de insumos |
| `catalogo_promexsa.csv` | Promexsa | **Techo / nombre / foto.** No es mayoreo |
| `fotos_bajo_pedido.csv` | — | URLs a espejar |
| `manifiesto_bajo_pedido_20260917.json` | — | SKUs generados |

## Cómo regenerar

```bash
python3 scripts/parse_ewafra_dis_pdf.py lista_dis_agosto_2026.pdf docs/catalogos/ewafra_dis_agosto_2026.csv
node scripts/generar-alta-bajo-pedido.js
node scripts/espejar-imagenes-bajo-pedido.js
```

SQL a correr **después** de `patch_bajo_pedido_20260916.sql` y `patch_fuentes_bajo_pedido_20260917.sql`:

1. `sql/patch_fuentes_bajo_pedido_20260917.sql`
2. **No** pegar `patch_alta_catalogo_bajo_pedido_20260917.sql` (900 KB; el editor lo corta).
   Usar `sql/alta_bajo_pedido_partes/` en orden (`00` → `01…28` → `99`). Ver ese LEERME.

Las fotos de terceros (Shopify / Tienda Nube) quedan en `imagen_url` para que la vitrina no salga vacía. El espejo baja a `catalogo-imagenes/bajo-pedido/` (gitignored); con `--public` copia a `public/catalogo-propia/`. DIS sin match Promexsa queda `foto_pendiente` en el manifiesto: el alta existe, la foto no está cerrada.

Espejo 17-sep-2026: **2,231** packshots bajaron a `catalogo-imagenes/bajo-pedido/` (3 rechazadas en `fotos_pendientes_bajo_pedido.csv`). **1,086** SKUs siguen sin foto de origen (`sin_imagen_bajo_pedido.csv`), casi todos Ewafra sin match Promexsa: el alta existe, la foto no está cerrada.

Mepiel: cuando llegue la lista, cruzar por EAN contra Dermaexpress y cargar fuente `mepiel`.

## Suplementos Mayoreo (2026-09-22)

`catalogo_suplementosmayoreo.csv` es el export de suplementosmayoreo.com. La columna `precio` es **costo de mayoreo**. La vitrina queda en `precio = 0` (Ordenar).

```bash
node scripts/generar-alta-suplementos-mayoreo.js
```

SQL, después de `patch_bajo_pedido_20260916.sql`:

1. `sql/patch_fuente_suplementosmayoreo_20260922.sql`
2. `sql/alta_suplementos_mayoreo_partes/` en orden (`00` → filas → `99`)

No usa la staging de Dermaexpress (`_fc_cat_bp_stg`). Hormonales, SARMs, clenbuterol, somatropina, inyectables y merch (playeras, gorras, muestras) no entran. La foto es la del CSV (Firebase del mayorista); el resto queda `foto_pendiente` en `alta_suplementos_mayoreo_20260922.csv`.
