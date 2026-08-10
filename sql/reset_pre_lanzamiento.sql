-- ============================================================
-- FarmaCapital — Reset operativo pre-lanzamiento
-- ============================================================
-- ⚠️  DESTRUCTIVO E IRREVERSIBLE. Haz backup antes:
--     GitHub Actions backup o pg_dump manual.
--
-- Qué borra (por defecto):
--   • Pedidos, items, envíos, facturas, devoluciones
--   • Citas, consumibles de consulta
--   • Cortes de caja, movimientos de caja
--   • Bitácoras COFEPRIS/antibióticos, recetas POS
--   • Inventario completo: lotes, movimientos, productos de prueba
--   • Clientes de prueba, puntos, direcciones, sesiones tienda
--   • Reservas de stock, compras, auditoría operativa
--
-- Qué NO toca:
--   • usuarios, empleados (staff)
--   • configuracion, banners, promociones (estructura)
--   • medicos, procedimientos_medicos, equipamiento
--   • proveedores, sucursales
--
-- Cómo ejecutar en Supabase SQL Editor:
--   1) Ejecuta solo el bloque "PASO 0 — Conteos" y revisa números.
--   2) Cambia v_confirmar abajo a true y ejecuta "PASO 1 — Borrado".
-- ============================================================

-- ── PASO 0 — Conteos (seguro, solo lectura) ─────────────────
select 'pedidos' as tabla, count(*)::bigint as filas from public.pedidos
union all select 'pedido_items', count(*) from public.pedido_items
union all select 'envios', count(*) from public.envios
union all select 'facturas', count(*) from public.facturas
union all select 'devoluciones', count(*) from public.devoluciones
union all select 'devolucion_items', count(*) from public.devolucion_items
union all select 'citas', count(*) from public.citas
union all select 'consumibles_consulta', count(*) from public.consumibles_consulta
union all select 'cortes_caja', count(*) from public.cortes_caja
union all select 'movimientos_caja', count(*) from public.movimientos_caja
union all select 'productos', count(*) from public.productos
union all select 'lotes', count(*) from public.lotes
union all select 'movimientos_inventario', count(*) from public.movimientos_inventario
union all select 'clientes', count(*) from public.clientes
union all select 'stock_reservations', count(*) from public.stock_reservations
order by 1;


-- ── PASO 1 — Borrado (editar v_confirmar := true) ───────────
do $$
declare
  v_confirmar              boolean := false;  -- ⚠️ true para ejecutar
  v_limpiar_inventario     boolean := true;
  v_limpiar_clientes       boolean := true;
  v_limpiar_sesiones       boolean := true;
  v_limpiar_auditoria      boolean := true;
  n                        bigint;
  t                        text;
begin
  if not v_confirmar then
    raise exception using
      message = 'Seguridad: abre este script, pon v_confirmar := true y vuelve a ejecutar solo el bloque DO.';
  end if;

  raise notice '=== FarmaCapital reset pre-lanzamiento — inicio ===';

  -- Citas ↔ pedidos consulta
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
    'citas',
    'cortes_caja',
    'bitacora_cofepris',
    'bitacora_antibioticos',
    'recetas',
    'compra_items',
    'compras'
  ]
  loop
    if exists (select 1 from information_schema.tables where table_schema='public' and table_name=t) then
      execute format('delete from public.%I', t);
      get diagnostics n = row_count;
      raise notice 'delete %: % filas', t, n;
    end if;
  end loop;

  if v_limpiar_inventario then
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

    -- Reiniciar IDs de catálogo (opcional pero útil al cargar SKUs nuevos)
    foreach t in array array['productos', 'lotes', 'pedidos', 'citas', 'clientes']
    loop
      begin
        execute format(
          'select setval(pg_get_serial_sequence(''public.%I'', ''id''), 1, false)',
          t
        );
        raise notice 'secuencia reiniciada: %', t;
      exception when others then
        raise notice 'secuencia no reiniciada (%): %', t, SQLERRM;
      end;
    end loop;
  end if;

  if v_limpiar_clientes then
    if exists (select 1 from information_schema.tables where table_schema='public' and table_name='movimientos_puntos') then
      delete from public.movimientos_puntos;
      get diagnostics n = row_count;
      raise notice 'delete movimientos_puntos: % filas', n;
    end if;
    if exists (select 1 from information_schema.tables where table_schema='public' and table_name='direcciones_cliente') then
      delete from public.direcciones_cliente;
      get diagnostics n = row_count;
      raise notice 'delete direcciones_cliente: % filas', n;
    end if;
    if exists (select 1 from information_schema.tables where table_schema='public' and table_name='clientes') then
      delete from public.clientes;
      get diagnostics n = row_count;
      raise notice 'delete clientes: % filas', n;
    end if;
  end if;

  if v_limpiar_sesiones then
    foreach t in array array['sesiones_cliente', 'sesiones', 'password_reset_requests']
    loop
      if exists (select 1 from information_schema.tables where table_schema='public' and table_name=t) then
        execute format('delete from public.%I', t);
        get diagnostics n = row_count;
        raise notice 'delete %: % filas', t, n;
      end if;
    end loop;
  end if;

  if v_limpiar_auditoria then
    foreach t in array array['audit_log_detallado', 'audit_log']
    loop
      if exists (select 1 from information_schema.tables where table_schema='public' and table_name=t) then
        execute format('delete from public.%I', t);
        get diagnostics n = row_count;
        raise notice 'delete %: % filas', n;
      end if;
    end loop;
  end if;

  raise notice '=== Reset completado. Carga SKUs reales en Inventario y registra lotes antes de vender. ===';
end $$;
