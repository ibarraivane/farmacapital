-- ============================================================
-- FARMAX — Introspección MÍNIMA (una sola query, un solo resultado)
-- ============================================================
-- Correr en SQL Editor de Supabase y pegar todo el resultado aquí.
-- Devuelve solo una tabla con las 4 secciones que necesito para F2:
--   1) tablas_y_filas     -> lista de tablas con conteo aprox
--   2) columnas_clave     -> columnas de productos, lotes, pedidos,
--                            pedido_items, clientes, movimientos_inventario
--   3) foreign_keys       -> FKs de esas mismas tablas
--   4) indices_existentes -> índices de esas mismas tablas
-- ============================================================

with
tablas as (
  select
    '1_tablas_y_filas'::text as seccion,
    c.relname                as nombre,
    c.reltuples::bigint::text as detalle_1,
    null::text               as detalle_2,
    null::text               as detalle_3
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relkind = 'r'
),
columnas as (
  select
    '2_columnas_clave'::text as seccion,
    table_name               as nombre,
    column_name              as detalle_1,
    data_type                as detalle_2,
    is_nullable || coalesce(' default ' || column_default, '') as detalle_3
  from information_schema.columns
  where table_schema = 'public'
    and table_name in (
      'productos', 'lotes', 'pedidos', 'pedido_items',
      'clientes', 'movimientos_inventario', 'usuarios',
      'facturas', 'empleados', 'bitacora_antibioticos'
    )
),
fks as (
  select
    '3_foreign_keys'::text                              as seccion,
    tc.table_name                                       as nombre,
    kcu.column_name                                     as detalle_1,
    ccu.table_name || '.' || ccu.column_name            as detalle_2,
    rc.delete_rule                                      as detalle_3
  from information_schema.table_constraints tc
  join information_schema.key_column_usage kcu
    using (constraint_schema, constraint_name, table_schema, table_name)
  join information_schema.referential_constraints rc
    on rc.constraint_name = tc.constraint_name
   and rc.constraint_schema = tc.constraint_schema
  join information_schema.constraint_column_usage ccu
    on ccu.constraint_name = tc.constraint_name
   and ccu.constraint_schema = tc.constraint_schema
  where tc.table_schema = 'public'
    and tc.constraint_type = 'FOREIGN KEY'
),
idx as (
  select
    '4_indices_existentes'::text as seccion,
    tablename                    as nombre,
    indexname                    as detalle_1,
    indexdef                     as detalle_2,
    null::text                   as detalle_3
  from pg_indexes
  where schemaname = 'public'
)
select * from tablas
union all
select * from columnas
union all
select * from fks
union all
select * from idx
order by seccion, nombre, detalle_1;
