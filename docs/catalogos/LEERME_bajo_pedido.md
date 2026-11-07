# Catálogos bajo pedido / laboratorio (octubre 2026)

Listas de mayoreo y **precio directo de laboratorio** para la vitrina `/conseguir`
y el anaquel. **No** se venden con PVP de Promexsa ni de otra farmacia.

## Prioridad 2026: laboratorio directo

Para dermo pedible al laboratorio:
- **`costo`** = precio al médico / especialista
- **`precio`** = precio al público de la lista
- **SVR**: solo PVP del catálogo FarmaCapital + costo de factura
- **MePiel / Dermaexpress**: se retiran del inventario (sin stock) con
  `sql/alta_laboratorio_dermo_20261025/00_retirar_mepiel_dermaexpress.sql`

Ver `sql/alta_laboratorio_dermo_20261025/LEERME.md`.

| Archivo | Proveedor | Rol |
|---|---|---|
| `laboratorio_svr_stock_20261025.csv` | SVR | Stock real + costo factura + PVP FarmaCapital |
| `laboratorio_alastin_2026.csv` | Alastin | Costo lab c/IVA + PVP sugerido (bajo pedido) |
| `laboratorio_medik8_especialistas_2025.csv` | Medik8 / Dermatotec | Costo especialistas + RRP |
| `catalogo_birdman.csv` | Birdman | Costo base (escalón chico). Sin playeras |
| `ewafra_dis_agosto_2026.csv` | Ewafra (lista DIS ago-2026) | Costo lista 6 −20% de insumos |
| `catalogo_promexsa.csv` | Promexsa | **Techo / nombre / foto.** No es mayoreo |
| `catalogo_dermaexpress.csv` | Dermaexpress | Legado (fotos / cruce). No mandar costo si hay lab |
| `fotos_bajo_pedido.csv` | — | URLs a espejar |
| `manifiesto_bajo_pedido_20260917.json` | — | SKUs generados (Dermaexpress/Birdman/Ewafra) |

## Regenerar laboratorio dermo

```bash
python3 scripts/generar_alta_laboratorio_dermo.py
```

Orden SQL: `sql/patch_fuentes_laboratorio_dermo_20261025.sql` →
`sql/alta_laboratorio_dermo_20261025/` (ver LEERME ahí).

## Regenerar vitrina mayoristas (Birdman / Ewafra / legado)

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

**MePiel:** la PR draft `cursor/alta-catalogo-mepiel-2026-83df` queda sustituida por las listas de laboratorio. Si ya se aplicó MePiel en Postgres, usar `sql/alta_laboratorio_dermo_20261025/09_retirar_mepiel_sin_stock.sql` (opcional, revisar conteo antes).
