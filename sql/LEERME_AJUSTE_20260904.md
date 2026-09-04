# SQL 2026-09-04 — aplicado

Todos los SQL de este lote ya corrieron en Supabase (4-sep). No pegues más de esta lista.

## Ya aplicado

1. **Precios de venta (seguro) — 10 SKUs**  
   Afrin 113, Amikacina 55, Penipot 31, Clindamicina 135, Listerine 97, Pedialyte 35, Ibupro-Cafe 41, Tropharma 62, Dac 66, Grisi 33.  
   Backup: `productos_precio_backup_20260904`.

2. **Duplicados — 10 liberaciones**  
   EAN se queda en la tarjeta con más stock; las extras sin código (no se borran).

3. **Códigos de barras exactos — ~96 SKUs**  
   Clave Equilibrio → Levic. No inventa códigos.

4. **Laboratorio**  
   Columna `productos.laboratorio` + FarmaLive por EAN (con o sin dígito verificador).  
   En Inventario **aún no se ve** esa columna; está en la base.

## No correr

- `patch_precios_venta_revisar_compra_20260904.sql` — 12 SKUs (XL-3, Electrolit, Desenfriol…). Decisión de negocio en Referencias.
- `patch_precios_venta_outliers_NO_CORRER_20260904.sql` — otra presentación.

## En el sitio (ya publicado)

Referencias: percentil + piso. Filtro **Revisar compra**. Recibir alta: 60% / 25% sobre costo.

## Rollback de PVP

```sql
update public.productos p
   set precio = b.precio
  from public.productos_precio_backup_20260904 b
 where p.id = b.id;
```
