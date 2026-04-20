-- ============================================================
-- FARMAX — Verificación F4
-- ============================================================
-- Corre DESPUES de refactor_fase4a_rpcs_sin_legacy.sql
--              y  refactor_fase4b_drop_legacy.sql
-- ============================================================
-- Debe mostrar una sola tabla consolidada. Esperado:
--   - 5 filas "A_column_dropped" con "OK (no existe)"
--   - 3 filas "B_rpcs" con "EXISTE"
--   - 1 fila  "C_invariante" con coinciden = total productos
-- ============================================================

do $$
declare
  r record;
  v_coinciden int;
  v_total int;
begin
  drop table if exists tmp_f4_result;
  create temp table tmp_f4_result(
    seccion text, item text, detalle_1 text, detalle_2 text
  ) on commit drop;

  -- ============================================================
  -- A) Confirmar que las columnas legacy ya NO existen
  -- ============================================================
  for r in
    with target(tabla, columna) as (values
      ('pedido_items', 'lote'),
      ('pedido_items', 'caducidad'),
      ('productos',    'lote'),
      ('productos',    'fecha_caducidad'),
      ('lotes',        'proveedor')
    )
    select t.tabla, t.columna,
      case when exists (
        select 1 from information_schema.columns
        where table_schema = 'public'
          and table_name = t.tabla
          and column_name = t.columna
      ) then 'FALLO (aun existe)' else 'OK (no existe)' end as estado
    from target t
  loop
    insert into tmp_f4_result values (
      'A_column_dropped', r.tabla || '.' || r.columna, r.estado, null
    );
  end loop;

  -- ============================================================
  -- B) Confirmar que los RPCs actualizados siguen existiendo
  -- ============================================================
  for r in
    with target(fname) as (values
      ('create_sale_transaction_v2'),
      ('create_producto_with_lote'),
      ('receive_merchandise_lote')
    )
    select t.fname,
      case when exists (
        select 1 from pg_proc p
        join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public' and p.proname = t.fname
      ) then 'EXISTE' else 'FALTA' end as estado
    from target t
  loop
    insert into tmp_f4_result values (
      'B_rpcs', r.fname, r.estado, null
    );
  end loop;

  -- ============================================================
  -- C) Invariante: productos.stock == sum(lotes.cantidad_actual)
  -- ============================================================
  select count(*) into v_total from public.productos;
  select count(*) into v_coinciden
  from public.productos p
  left join lateral (
    select coalesce(sum(l.cantidad_actual), 0)::int as suma
    from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true) = true
  ) s on true
  where coalesce(p.stock, 0) = coalesce(s.suma, 0);

  insert into tmp_f4_result values (
    'C_invariante', 'stock == sum(lotes)',
    'coinciden=' || v_coinciden, 'total=' || v_total
  );

  -- ============================================================
  -- D) Conteo de pedido_items por completitud de lote_id
  -- ============================================================
  insert into tmp_f4_result
  select 'D_pedido_items', 'total_items',
         (select count(*) from public.pedido_items)::text, null
  union all
  select 'D_pedido_items', 'con_lote_id',
         (select count(*) from public.pedido_items where lote_id is not null)::text, null
  union all
  select 'D_pedido_items', 'sin_lote_id',
         (select count(*) from public.pedido_items where lote_id is null)::text,
         'Incluye items de venta unidad (OK si coincide con historico unidad)';

end $$;

select seccion, item, detalle_1, detalle_2
from tmp_f4_result
order by seccion, item;
