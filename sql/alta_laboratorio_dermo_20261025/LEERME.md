# Catálogo dermo a precio de laboratorio (25-oct-2026)

**Regla de precios**
- `costo` = precio de venta al médico / especialista (compra)
- `precio` = precio al público de la lista (por ahora)
- **SVR**: anaquel con stock + PVP FarmaCapital
- **Alastin / Medik8**: `bajo_pedido=true`, `stock=0` — se ve el PVP y se **ordena**
  (reserva), no se compra como si hubiera existencia

Se **quita del inventario** lo cargado desde listas de páginas (MePiel / Dermaexpress).
Solo se mantienen / cargan estas listas de laboratorio.

| Archivo | Qué hace | Filas |
|---|---|---|
| `../patch_fuentes_laboratorio_dermo_20261025.sql` | Fuentes `svr`, `alastin`, `medik8` | — |
| `00_retirar_mepiel_dermaexpress.sql` | **Obligatorio**: apaga MePiel/Dermaexpress sin stock | — |
| `01_svr_stock.sql` | SVR anaquel: costo factura + PVP FarmaCapital | 10 |
| `02_alastin_lab.sql` | Alastin: costo = c/IVA médico · precio = PVP sugerido | 14 |
| `03_staging_medik8.sql` + `03a_filas_*.sql` + `03b_aplicar_medik8.sql` | Medik8: costo = especialistas · precio = RRP | 92 |

## Orden en Supabase

1. `sql/patch_fuentes_laboratorio_dermo_20261025.sql`
2. `00_retirar_mepiel_dermaexpress.sql` ← primero limpia listas web
3. `01_svr_stock.sql`
4. `02_alastin_lab.sql`
5. `03_staging_medik8.sql` → todos los `03a_filas_*` → `03b_aplicar_medik8.sql`

## CSV fuente

- `docs/catalogos/laboratorio_svr_stock_20261025.csv`
- `docs/catalogos/laboratorio_alastin_2026.csv`
- `docs/catalogos/laboratorio_medik8_especialistas_2025.csv`

Cuando lleguen más listas de laboratorio, agrégalas en `docs/catalogos/` y
extiende `scripts/generar_alta_laboratorio_dermo.py`.

## Notas

- **SVR Topialyse Gel Lavant**: margen ~15% (costo $475.70 → PVP $559).
- **Alastin**: costo = precio con IVA de lista (sin descuento volumen). Si compras $30k+ sin IVA, baja el costo al escalón.
- **Medik8**: sin EAN en PDF; al recibir, escanear y pegar `codigo_barras`.
- Birdman / Ewafra no se tocan.
