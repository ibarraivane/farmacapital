-- ============================================================
-- FarmaCapital — Limpiar SOLO inventario (productos, lotes, movimientos)
-- ============================================================
-- Usar cuando hay datos de prueba o cargas duplicadas de tickets.
-- NO borra clientes ni catálogo (usuarios, médicos, banners).
-- SÍ borra pedidos/ventas de prueba (pedido_items referencia lotes y productos).
--
-- Objetivo esperado tras recarga única (_EJECUTAR_1..4):
--   ~627 productos/líneas ticket | ~1,046 piezas en lotes
--
-- PASOS:
--   1) Ejecuta "PASO 0 — Conteos" y revisa números.
--   2) Pon v_confirmar := true en PASO 1 y ejecuta solo ese bloque DO.
--   3) Ejecuta patch si no lo hiciste: sql/patch_fix_create_producto_carga_tickets.sql
--   4) Ejecuta UNA sola vez: carga_inventario_tickets_EJECUTAR_1 → _2 → _3 → _4
--   5) Ejecuta: sql/verificar_inventario_carga.sql
--   6) (Opcional) sql/actualizar_codigos_barras_tickets.sql si capturaste barcodes nuevos
-- ============================================================

-- ── PASO 0 — Conteos (solo lectura) ─────────────────────────
select 'productos' as tabla, count(*)::bigint as filas from public.productos
union all select 'lotes', count(*) from public.lotes
union all select 'movimientos_inventario', count(*) from public.movimientos_inventario
union all select 'productos_fc_tickets',
  (select count(*) from public.productos where sku like 'FC-%' and sku not like 'FC100%')
union all select 'productos_seed_fc100',
  (select count(*) from public.productos where sku like 'FC100%')
union all select 'stock_lotes', coalesce((select sum(cantidad_actual) from public.lotes), 0)::bigint
order by 1;


-- ── PASO 1 — Borrado inventario (v_confirmar := true) ───────
do $$
declare
  v_confirmar boolean := false;  -- ⚠️ cambiar a true para ejecutar
  n bigint;
  t text;
begin
  if not v_confirmar then
    raise exception using
      message = 'Seguridad: pon v_confirmar := true y vuelve a ejecutar solo este bloque DO.';
  end if;

  raise notice '=== Limpiar solo inventario — inicio ===';

  -- pedido_items.lote_id → lotes(id): hay que quitar ventas de prueba antes de borrar lotes
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='citas' and column_name='pedido_consulta_id') then
    update public.citas set pedido_consulta_id = null where pedido_consulta_id is not null;
    get diagnostics n = row_count;
    raise notice 'citas.pedido_consulta_id anulados: %', n;
  end if;

  foreach t in array array[
    'consumibles_consulta',
    'devolucion_items',
    'devoluciones',
    'facturas',
    'envios',
    'stock_reservations',
    'pedido_items',
    'movimientos_caja',
    'pedidos',
    'recetas',
    'bitacora_cofepris',
    'bitacora_antibioticos'
  ]
  loop
    if exists (select 1 from information_schema.tables where table_schema='public' and table_name=t) then
      execute format('delete from public.%I', t);
      get diagnostics n = row_count;
      raise notice 'delete %: % filas', t, n;
    end if;
  end loop;

  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='compra_items') then
    delete from public.compra_items;
    get diagnostics n = row_count;
    raise notice 'delete compra_items: % filas', n;
  end if;

  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='compras') then
    delete from public.compras;
    get diagnostics n = row_count;
    raise notice 'delete compras: % filas', n;
  end if;

  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='promocion_productos') then
    delete from public.promocion_productos;
    get diagnostics n = row_count;
    raise notice 'delete promocion_productos: % filas', n;
  end if;

  foreach t in array array[
    'movimientos_inventario',
    'lotes_producto',
    'lotes',
    'productos'
  ]
  loop
    if exists (select 1 from information_schema.tables where table_schema='public' and table_name=t) then
      execute format('delete from public.%I', t);
      get diagnostics n = row_count;
      raise notice 'delete %: % filas', t, n;
    end if;
  end loop;

  foreach t in array array['productos', 'lotes']
  loop
    begin
      execute format(
        'select setval(pg_get_serial_sequence(''public.%I'', ''id''), 1, false)',
        t
      );
      raise notice 'secuencia reiniciada: %', t;
    exception when others then
      raise notice '%', format('secuencia no reiniciada (%s): %s', t, SQLERRM);
    end;
  end loop;

  raise notice '=== Limpiar solo inventario — listo. Recarga _EJECUTAR_1..4 UNA vez. ===';
end $$;
