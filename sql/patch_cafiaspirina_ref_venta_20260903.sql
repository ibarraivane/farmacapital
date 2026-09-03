-- Cafiaspirina C/100 (FC-08491096): referencia de venta comparable.
--
-- La fila vieja (otros_venta $128.90, «Claude 20260815 · Cafiaspirina Tar C/100»)
-- no nombra tienda ni confirma empaque. Inventario → Referencias no puede
-- mostrar rendimiento vs mercado con eso.
--
-- Comparable: misma caja C/100, 500 mg / 30 mg, Farmacias Guadalajara
-- (artículo 606723, línea 2026-09-03). Lista $190.19; promo online $126.48
-- (puede diferir en sucursal). NO usar Fahorro C/40 ($66): otro empaque.
-- Similares no trae esta patente.
--
-- No toca productos.precio ni precio_unidad (caja / pieza / blíster).
-- El costo 2-pack ($217.46 vs $108.73) queda para otro ticket.

begin;

insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza,
  nombre_fuente, notas
)
select
  p.id,
  'otros_venta',
  'venta',
  190.19,
  date '2026-09-03',
  'manual',
  90,
  'Cafiaspirina 500 mg/30 mg 100 tabletas — Farmacias Guadalajara',
  'Lista online GDL art. 606723 · 2026-09-03. Promo web $126.48 (puede no aplicar en sucursal). Reemplaza ref. $128.90 sin fuente. No comparar con C/40.'
from public.productos p
where p.sku = 'FC-08491096'
  and p.activo = true
  and not exists (
    select 1
    from public.producto_precios_referencia r
    where r.producto_id = p.id
      and r.fuente = 'otros_venta'
      and r.fecha = date '2026-09-03'
      and r.precio = 190.19
      and r.origen = 'manual'
  );

commit;
