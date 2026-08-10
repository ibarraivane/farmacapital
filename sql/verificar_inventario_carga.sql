-- Verificación post-carga tickets (ejecutar en Supabase SQL Editor)

select count(*) as productos_total from public.productos;

select count(*) as productos_tickets
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';

select count(*) as productos_seed_fc100 from public.productos where sku like 'FC100%';

select count(*) as lotes from public.lotes;

select count(*) as movimientos from public.movimientos_inventario;

select sum(stock) as stock_total_productos from public.productos;

select sum(cantidad_actual) as stock_total_lotes from public.lotes;

-- Desajustes stock producto vs lotes (debe devolver 0 filas)
select
  p.id,
  p.sku,
  p.stock as stock_producto,
  coalesce(sum(l.cantidad_actual), 0) as stock_lotes
from public.productos p
left join public.lotes l
  on l.producto_id = p.id and coalesce(l.activo, true)
where p.sku like 'FC-%' and p.sku not like 'FC100%'
group by p.id, p.sku, p.stock
having p.stock <> coalesce(sum(l.cantidad_actual), 0)
limit 20;
