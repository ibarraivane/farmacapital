-- ============================================================================
-- Diagnóstico stock: Recibir + pedidos online
-- 23-sep-2026. Solo lectura. Pegar en Supabase → SQL Editor → Run.
-- ============================================================================

-- 1) ¿Ya está el patch de stock al crear pedido online?
select
  exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'pedidos'
      and column_name = 'stock_consumido_at'
  ) as tiene_columna_stock_consumido_at,
  exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'fn_pedido_online_comprometer_stock'
  ) as tiene_fn_comprometer_stock;

-- 2) Desfase productos.stock vs suma de lotes activos (top 40 peores)
select
  p.id,
  p.sku,
  left(p.nombre, 48) as nombre,
  coalesce(p.stock, 0) as stock_columna,
  coalesce((
    select sum(l.cantidad_actual)::int
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
  ), 0) as suma_lotes,
  coalesce((
    select sum(l.cantidad_actual)::int
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
      and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date)
  ), 0) as lotes_vendibles,
  coalesce(p.stock, 0) - coalesce((
    select sum(l.cantidad_actual)::int
    from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0) as delta
from public.productos p
where coalesce(p.activo, true)
  and coalesce(p.bajo_pedido, false) = false
order by abs(
  coalesce(p.stock, 0) - coalesce((
    select sum(l.cantidad_actual)::int
    from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0)
) desc
limit 40;

-- 3) Recibir: renglones confirmados SIN lote (verde huérfano = stock no entró)
select
  ri.id as item_id,
  r.id as ticket_id,
  r.proveedor,
  r.estado as ticket_estado,
  left(coalesce(p.nombre, ri.nombre_snapshot, ''), 48) as producto,
  ri.cantidad,
  ri.confirmado,
  ri.lote_id,
  ri.fecha_caducidad,
  ri.created_at
from public.recepcion_items ri
join public.recepciones r on r.id = ri.recepcion_id
left join public.productos p on p.id = ri.producto_id
where coalesce(ri.confirmado, false) = true
  and ri.lote_id is null
  and coalesce(ri.cantidad, 0) > 0
order by ri.created_at desc nulls last
limit 50;

-- 4) Últimas entradas por Recibir (sí tienen lote) — ¿subió stock?
select
  ri.created_at,
  r.proveedor,
  p.sku,
  left(p.nombre, 40) as nombre,
  ri.cantidad as qty_recibida,
  l.cantidad_actual as lote_qty,
  p.stock as stock_producto,
  ri.lote_id
from public.recepcion_items ri
join public.recepciones r on r.id = ri.recepcion_id
join public.productos p on p.id = ri.producto_id
left join public.lotes l on l.id = ri.lote_id
where coalesce(ri.confirmado, false) = true
  and ri.lote_id is not null
  and ri.created_at > now() - interval '14 days'
order by ri.created_at desc
limit 40;

-- 5) Pedidos online recientes: ¿comprometen stock?
select
  p.id,
  p.created_at,
  p.estado,
  p.tipo_entrega,
  p.stock_consumido_at,
  (select count(*) from public.pedido_items i where i.pedido_id = p.id) as items,
  exists (
    select 1 from public.movimientos_inventario m
    where m.referencia in (
      'pedido_online:' || p.id::text,
      'pedido_listo:' || p.id::text
    )
  ) as tiene_movimiento_salida
from public.pedidos p
where p.tipo = 'online'
  and p.created_at > now() - interval '14 days'
order by p.created_at desc
limit 40;

-- 6) Pedidos online pendientes SIN stock_consumido_at (legado / patch no aplicado)
select count(*) as online_pendientes_sin_compromiso
from public.pedidos p
where p.tipo = 'online'
  and p.estado = 'pendiente'
  and p.stock_consumido_at is null
  and p.created_at > now() - interval '30 days';
