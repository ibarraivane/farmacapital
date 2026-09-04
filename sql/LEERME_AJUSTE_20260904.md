# SQL 2026-09-04 — qué correr y en qué orden

**No está aplicado en Supabase.** Pégalo en el SQL Editor, en este orden.

## 1. Precios de venta (seguro) — 10 SKUs

`patch_precios_venta_aplicar_20260904.sql`

Subidas ≤30% y bajadas ≤20%, siempre arriba del costo. Hace backup en `productos_precio_backup_20260904`.

## 2. Códigos de barras exactos — 96 SKUs

`patch_barcodes_exactos_20260904.sql`

Solo si `codigo_barras` está vacío y el EAN no lo tiene otro SKU.

## 3. Duplicados — 10 liberaciones

`patch_barcodes_duplicados_20260904.sql`

## 4. Laboratorio

`patch_laboratorio_columna_20260904.sql`

Columna nueva + backfill desde FarmaLive por EAN.

## Opcional — piso > mercado (12 SKUs)

`patch_precios_venta_revisar_compra_20260904.sql`

Te deja al piso (no al min de Similares). Puede verse caro. Revísalo antes.

## No correr

`patch_precios_venta_outliers_NO_CORRER_20260904.sql`

39 refs de **otra presentación** (Amlodipino $12→$282, Aciclovir $31→$334). Solo lista.

## Rollback de PVP

```sql
update public.productos p
   set precio = b.precio
  from public.productos_precio_backup_20260904 b
 where p.id = b.id;
```
