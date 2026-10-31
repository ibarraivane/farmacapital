# Alta FreeStyle Optium tiras C/50 · `093815996491`

La caja **sí existía a medias** en bajo pedido (`FC-01896386`, ewafra) pero **sin código de barras**, sin foto y con typo «Rectivas». El pistola busca por EAN → «no está en el sistema».

## Qué pegar

Todo `sql/patch_alta_freestyle_optium_50_093815996491.sql` en Supabase → SQL Editor → Run.

## Ficha

| Campo | Valor |
|---|---|
| Nombre | FreeStyle Optium |
| EAN | `093815996491` (REF `99649-75`) |
| SKU | `FC-01896386` (si ya estaba) o `FC-15996491` |
| Marca / lab | FreeStyle · Abbott |
| Presentación | Caja con 50 tiras |
| Costo / PVP | **$408.33** / **$511** (+25% marca) |

## Después del SQL

1. Recargar Recibir / Inventario.
2. Escanear `093815996491` → debe abrir el renglón.
3. MMAA de la caja (p. ej. EXP 2027-10 → `1027`) · lote en la caja · Guardar.
4. Foto en `catalogo-propia/` tras merge/deploy.
