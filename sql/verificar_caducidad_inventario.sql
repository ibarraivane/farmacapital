-- Solo lectura: verifica que caducidad se pueda editar desde inventario.
-- NO modifica precios, stock ni cantidades de lotes.

-- 1) Función RPC (la que fallaba ayer por typo av_prev)
select
  p.proname as funcion,
  pg_get_function_arguments(p.oid) as argumentos
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname = 'admin_editar_lote';

-- 2) Productos con stock pero sin lote activo (ahí NO se puede poner caducidad hasta recibir mercancía)
select p.sku, p.nombre, p.stock,
       count(l.id) filter (where coalesce(l.activo, true) and l.cantidad_actual > 0) as lotes_con_stock
from public.productos p
left join public.lotes l on l.producto_id = p.id
where coalesce(p.activo, true) and p.stock > 0
group by p.id, p.sku, p.nombre, p.stock
having count(l.id) filter (where coalesce(l.activo, true) and l.cantidad_actual > 0) = 0
order by p.nombre
limit 30;

-- 3) Lotes activos sin fecha (editables; solo falta capturar caducidad)
select p.sku, p.nombre, l.id as lote_id, l.numero_lote, l.cantidad_actual, l.fecha_caducidad
from public.lotes l
join public.productos p on p.id = l.producto_id
where coalesce(l.activo, true)
  and l.cantidad_actual > 0
  and l.fecha_caducidad is null
order by p.nombre
limit 30;
