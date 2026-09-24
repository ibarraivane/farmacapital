-- Diagnóstico SOLO LECTURA — costo por lote y margen realizado.
-- 24 sep 2026. Pegar en Supabase → SQL Editor. No cambia datos.
--
-- Lo que el repo ya muestra (no hace falta la base para esto):
--   · create_sale_transaction_v2 vigente: sql/patch_precio_exclusivo_caducidad_20260824.sql
--     (caja reparte FEFO en varios renglones; pieza guarda lote_id null).
--   · precio_unidad_efectivo tiene dos cuerpos en el repo. El último archivo
--     es sql/patch_precio_unidad_manual_20260824.sql (el guardado manda si > 0).
--     La consulta 1 dice cuál está desplegada.
--   · schema_inventario.sql crea lotes_select USING (true). La consulta 2
--     dice si esa política sigue viva.
--   · El pedido en línea descuenta con fn_pedido_online_comprometer_stock
--     → consume_stock_via_lotes y NO escribe pedido_items.lote_id
--     (sql/patch_online_stock_al_crear_20260923.sql).

-- 1. Cuerpo desplegado de precio_unidad_efectivo
select pg_get_functiondef('public.precio_unidad_efectivo(numeric,numeric,integer,text,text,numeric)'::regprocedure)
  as precio_unidad_efectivo;

-- 2. Políticas reales de lotes y pedido_items
select schemaname, tablename, policyname, cmd, roles, qual, with_check
from pg_policies
where schemaname = 'public'
  and tablename in ('lotes', 'pedido_items', 'productos')
order by tablename, policyname;

-- 3. Stock de catálogo vs suma de lotes (lo que sobre es stock sin capa)
select
  count(*) filter (where abs(coalesce(p.stock, 0) - coalesce(l.qty, 0)) > 0) as productos_desfasados,
  count(*) filter (where coalesce(p.stock, 0) > coalesce(l.qty, 0)) as stock_sin_capa,
  coalesce(sum(greatest(coalesce(p.stock, 0) - coalesce(l.qty, 0), 0)), 0) as piezas_sin_capa
from public.productos p
left join (
  select producto_id, sum(coalesce(cantidad_actual, 0)) as qty
  from public.lotes
  where coalesce(activo, true)
  group by producto_id
) l on l.producto_id = p.id
where coalesce(p.activo, true);

-- 3b. Los 30 desfaces más grandes
select p.id, p.sku, p.nombre,
       coalesce(p.stock, 0) as stock_catalogo,
       coalesce(l.qty, 0) as stock_lotes,
       coalesce(p.stock, 0) - coalesce(l.qty, 0) as delta
from public.productos p
left join (
  select producto_id, sum(coalesce(cantidad_actual, 0)) as qty
  from public.lotes
  where coalesce(activo, true)
  group by producto_id
) l on l.producto_id = p.id
where coalesce(p.activo, true)
  and coalesce(p.stock, 0) <> coalesce(l.qty, 0)
order by abs(coalesce(p.stock, 0) - coalesce(l.qty, 0)) desc
limit 30;

-- 4. Lotes inventados (SYNC / REINTEGRO) todavía con piezas
select
  count(*) filter (where numero_lote like 'SYNC-%') as lotes_sync,
  count(*) filter (where numero_lote like 'REINTEGRO-%') as lotes_reintegro,
  coalesce(sum(cantidad_actual) filter (where numero_lote like 'SYNC-%'), 0) as piezas_sync,
  coalesce(sum(cantidad_actual) filter (where numero_lote like 'REINTEGRO-%'), 0) as piezas_reintegro
from public.lotes
where coalesce(activo, true)
  and coalesce(cantidad_actual, 0) > 0
  and (numero_lote like 'SYNC-%' or numero_lote like 'REINTEGRO-%');

-- 5. Lotes vivos sin costo
select
  count(*) as lotes_vivos,
  count(*) filter (where coalesce(costo_unitario, 0) <= 0) as lotes_sin_costo,
  coalesce(sum(cantidad_actual) filter (where coalesce(costo_unitario, 0) <= 0), 0) as piezas_sin_costo
from public.lotes
where coalesce(activo, true)
  and coalesce(cantidad_actual, 0) > 0;

-- 6. Renglones vendidos sin lote, por canal y mes
select
  to_char(p.created_at at time zone 'America/Mexico_City', 'YYYY-MM') as mes,
  coalesce(p.tipo, 'sin_tipo') as canal,
  count(*) as renglones,
  count(*) filter (where x.lote_id is null) as sin_lote,
  count(*) filter (where x.lote_id is not null) as con_lote
from public.pedido_items x
join public.pedidos p on p.id = x.pedido_id
where p.estado::text = 'completado'
group by 1, 2
order by 1 desc, 2;

-- 7. Dónde vive el descuento de stock del pedido en línea
select p.proname
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'fn_pedido_online_comprometer_stock',
    'consume_stock_via_lotes',
    'create_sale_transaction_v2',
    'precio_unidad_efectivo',
    'abrir_caja_lote'
  )
order by 1;
