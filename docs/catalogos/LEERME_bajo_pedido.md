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

## Suplementos Birdman: EAN y foto

El CSV de mayoreo no trae código de barras. La ficha pública de [b2b.birdman.com](https://b2b.birdman.com) sí (`/products/{handle}.js` → `variant.barcode` + packshot). El SKU de mayoreo cruza 1 a 1 con esa ficha.

```bash
node scripts/enriquecer-birdman-ean.js
```

Eso reescribe `birdman_ean_imagen.csv` y `sql/patch_birdman_ean_imagen_20260923.sql`. Corrida 23-sep-2026: **114 de 117** suplementos traen EAN-13 (dígito verificador ok). Si el mayoreo no trae código, se toma el de la tienda `mx.birdman.com` del mismo SKU. Quedan sin código publicado: shaker negro, shaker rosa y Falcon Pumpkin 510 g (edición limitada). Los 117 tienen packshot.

El parche pone `codigo_barras` y, si la ficha estaba vacía, `imagen_url`. No cambia el SKU `FC-` (si el EAN reescribiera el SKU, el regen duplicaría el producto). No pisa un código o una foto que ya existan. Hay que correrlo en el SQL Editor.

## Fotos que faltaban (23-sep-2026)

De los 1,086 sin foto al alta, los dermatológicos y los suplementos/proteína ya tienen packshot:

- **50** dermocosméticos: ficha viva de Dermaexpress (el SKU de la tienda es el EAN). Dos fotos de esa tienda estaban cruzadas (el kit Avène salía como Vichy Mineral 89; el Musti salía como Stelatopia) y se tomaron de Dermamedina y de mustela.com. DermaPharma cubre el lápiz Korff. Las dos tarjetas de regalo no tienen producto.
- **83** de Birdman (proteína, suplemento y los 5 de merch que también estaban vacíos): packshot del mayoreo. Amazon MX responde por EAN; Mercado Libre corta el acceso automático.

`sql/patch_fotos_derm_suplementos_20260923.sql` solo llena `imagen_url` vacía. Los **951** de Ewafra siguen sin foto: el listado DIS no trae EAN, así que no se pueden cruzar con Dermaexpress ni con Amazon.

## Mepiel

La fuente `mepiel` sigue reservada: no hay lista de costo en el repo. La tienda `tienda.mepieldistribuidores.com.mx` es WooCommerce y desde aquí responde 403 (Cloudflare), así que no se pueden inventar EAN ni fotos.

Cuando haya export (columnas `ean`, `costo`, `nombre`, y `imagen_url` si la trae):

```bash
node scripts/cruzar-mepiel-por-ean.js docs/catalogos/catalogo_mepiel.csv
```

El cruce es por EAN contra Dermaexpress / `codigo_barras`. Si el producto ya está, suma la referencia de compra `mepiel` y solo llena la foto si estaba vacía. Un EAN que no exista no se da de alta solo: queda en el CSV de pendientes.
