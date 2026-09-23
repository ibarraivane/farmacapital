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

Mepiel (lista 2026): `docs/catalogos/mepiel_lista_2026.csv`. El costo es **precio cliente c/IVA** (lo que cobra ME Piel). El PVP de la lista queda como techo en la referencia, no como `productos.precio`. La vitrina sigue en 0 (Ordenar). Si el EAN ya está en Dermaexpress, se conserva el costo más barato y la foto de Dermaexpress cuando el producto aún no tiene imagen.

```bash
node scripts/generar-alta-mepiel.js
python3 scripts/buscar_fotos_mepiel.py   # Farmatodo, solo los que siguen sin foto
node scripts/generar-alta-mepiel.js      # vuelve a armar el SQL con las fotos nuevas
```

SQL en orden: `sql/alta_mepiel_2026/00_staging.sql`, luego `01_…`, luego el `*_aplicar.sql`. No pisa anaquel (stock > 0) ni un precio que el dueño ya haya publicado.

Si el SQL Editor responde `Failed to fetch (api.supabase.com)`, no es el catálogo: el panel no está hablando con Supabase. Carga directo a Postgres (hace falta la URI Session del pooler, puerto 6543, en `DATABASE_URL` o en `.env.local`):

```bash
node scripts/aplicar-alta-mepiel-pg.js
```
