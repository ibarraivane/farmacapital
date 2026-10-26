# Catálogo dermo a precio de laboratorio (25-oct-2026)

Reemplaza la estrategia de **MePiel / Dermaexpress** para las marcas que ya
podemos comprar a precio directo de laboratorio.

| Archivo | Qué hace | Filas |
|---|---|---|
| `../patch_fuentes_laboratorio_dermo_20261025.sql` | Fuentes `svr`, `alastin`, `medik8` | — |
| `01_svr_stock.sql` | SVR con stock, costo factura y PVP FarmaCapital | 10 |
| `02_alastin_lab.sql` | Alastin listo para ordenar (costo c/IVA + PVP sugerido) | 14 |
| `00_staging_medik8.sql` + `03a_filas_*.sql` + `03b_aplicar_medik8.sql` | Medik8 / Dermatotec | 92 |
| `09_retirar_mepiel_sin_stock.sql` | **Opcional**: apaga vitrina MePiel sin stock | — |

## Orden en Supabase

1. `sql/patch_fuentes_laboratorio_dermo_20261025.sql`
2. `01_svr_stock.sql`
3. `02_alastin_lab.sql`
4. `00_staging_medik8.sql` → todos los `03a_filas_*` → `03b_aplicar_medik8.sql`
5. (Opcional, después de revisar) `09_retirar_mepiel_sin_stock.sql`

## CSV fuente

- `docs/catalogos/laboratorio_svr_stock_20261025.csv`
- `docs/catalogos/laboratorio_alastin_2026.csv`
- `docs/catalogos/laboratorio_medik8_especialistas_2025.csv`

Cuando lleguen más listas de laboratorio, agrégalas en `docs/catalogos/` y
extiende `scripts/generar_alta_laboratorio_dermo.py`.

## Notas

- **SVR Topialyse Gel Lavant**: margen ~15% (costo $475.70 → PVP $559). El resto SVR ronda 31–32% de margen sobre venta.
- **Alastin**: el costo guardado es el de lista **con IVA sin descuento**. Si compras $30k+ sin IVA, actualiza el costo al escalón real.
- **Medik8**: la lista no trae EAN; el SKU es estable por nombre+tamaño. Cuando escanees la caja, pégalo en `codigo_barras`.
- La PR draft de MePiel (`cursor/alta-catalogo-mepiel-2026-83df`) **no se mergea**; este flujo la sustituye para dermo pedible.
