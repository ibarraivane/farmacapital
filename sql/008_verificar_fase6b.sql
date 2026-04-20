-- ============================================================
-- FARMAX — 008: verificación de F6b
-- ============================================================
-- Confirma que las 52 RPCs de F6b existen, son SECURITY DEFINER
-- con search_path fijo, y están granteadas a anon/authenticated.
-- ============================================================

do $$
declare
  v_esperadas text[] := array[
    -- F6b.1 auth (11)
    'fn_require_admin','fn_require_empleado','fn_require_cliente','fn_generar_salt',
    'admin_crear_usuario','admin_toggle_usuario','admin_reset_password','admin_eliminar_usuario',
    'solicitar_reset_password','registrar_cliente','cliente_cambiar_password',
    -- F6b.2 transacciones (10)
    'crear_factura','admin_eliminar_pedido','admin_editar_pedido','admin_cancelar_pedido',
    'marcar_pedido_listo','crear_devolucion','registrar_corte_caja','registrar_nomina',
    'cobrar_consulta','admin_ajustar_puntos',
    -- F6b.3 catálogo (18)
    'admin_editar_producto','admin_toggle_producto','admin_eliminar_producto',
    'admin_upsert_banner','admin_toggle_banner','admin_eliminar_banner',
    'admin_upsert_promocion','admin_toggle_promocion','admin_eliminar_promocion',
    'admin_crear_lote','admin_desactivar_lote',
    'crear_cita','actualizar_estado_cita','agregar_consumible_cita','eliminar_consumible_cita',
    'cliente_actualizar_nota_clinica','admin_ajustar_nota_cliente',
    -- F6b.4 tienda (5)
    'cliente_actualizar_perfil','cliente_agendar_cita','cliente_cancelar_cita',
    'cliente_crear_pedido_online','cliente_cancelar_pedido_online',
    -- F6b.5 wrappers (7 nuevos + marcar_pedido_listo ya contado)
    'create_sale_transaction_secure','abrir_caja_secure','restock_via_lote_secure',
    'adjust_stock_secure','create_producto_secure','receive_merchandise_secure',
    'consume_stock_secure'
  ];
  v_total_esperadas int;
begin
  v_total_esperadas := array_length(v_esperadas, 1);

  create temp table tmp_f6b_chk (
    seccion   text,
    check_name text,
    valor     text,
    detalle   text
  ) on commit drop;

  -- A) Todas las funciones existen
  insert into tmp_f6b_chk
  select 'A_existencia',
         fname,
         case when exists (
           select 1 from pg_proc p
           join pg_namespace n on n.oid = p.pronamespace
           where n.nspname='public' and p.proname = fname
         ) then 'OK' else 'FALTA' end,
         null
  from unnest(v_esperadas) as fname;

  -- B) Todas son SECURITY DEFINER
  insert into tmp_f6b_chk
  select 'B_security_definer',
         p.proname,
         case when p.prosecdef then 'OK' else 'INVOKER' end,
         null
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname='public'
    and p.proname = any(v_esperadas)
    and p.prokind = 'f';

  -- C) Todas tienen search_path fijo
  insert into tmp_f6b_chk
  select 'C_search_path',
         p.proname,
         case
           when p.proconfig is null then 'SIN_SEARCH_PATH'
           when exists (
             select 1 from unnest(p.proconfig) as c
             where c like 'search_path=%'
           ) then 'OK'
           else 'SIN_SEARCH_PATH'
         end,
         array_to_string(p.proconfig, ', ')
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname='public'
    and p.proname = any(v_esperadas)
    and p.prokind = 'f';

  -- D) Grants a anon / authenticated
  insert into tmp_f6b_chk
  select 'D_grants',
         p.proname,
         case
           when has_function_privilege('anon',          p.oid, 'EXECUTE')
            and has_function_privilege('authenticated', p.oid, 'EXECUTE')
             then 'OK'
           when has_function_privilege('authenticated', p.oid, 'EXECUTE')
             then 'SOLO_AUTH'
           else 'SIN_GRANT'
         end,
         null
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname='public'
    and p.proname = any(v_esperadas)
    and p.prokind = 'f';

  -- Resumen
  insert into tmp_f6b_chk values
    ('Z_resumen',
     'total_esperadas',
     v_total_esperadas::text,
     null),
    ('Z_resumen',
     'existentes',
     (select count(*)::text from tmp_f6b_chk where seccion='A_existencia' and valor='OK'),
     null),
    ('Z_resumen',
     'faltantes',
     (select count(*)::text from tmp_f6b_chk where seccion='A_existencia' and valor='FALTA'),
     (select string_agg(check_name, ', ')
        from tmp_f6b_chk where seccion='A_existencia' and valor='FALTA')),
    ('Z_resumen',
     'security_invoker',
     (select count(*)::text from tmp_f6b_chk where seccion='B_security_definer' and valor='INVOKER'),
     (select string_agg(check_name, ', ')
        from tmp_f6b_chk where seccion='B_security_definer' and valor='INVOKER')),
    ('Z_resumen',
     'sin_search_path',
     (select count(*)::text from tmp_f6b_chk where seccion='C_search_path' and valor='SIN_SEARCH_PATH'),
     (select string_agg(check_name, ', ')
        from tmp_f6b_chk where seccion='C_search_path' and valor='SIN_SEARCH_PATH')),
    ('Z_resumen',
     'sin_grant',
     (select count(*)::text from tmp_f6b_chk where seccion='D_grants' and valor='SIN_GRANT'),
     (select string_agg(check_name, ', ')
        from tmp_f6b_chk where seccion='D_grants' and valor='SIN_GRANT')),
    ('Z_resumen',
     'solo_auth',
     (select count(*)::text from tmp_f6b_chk where seccion='D_grants' and valor='SOLO_AUTH'),
     (select string_agg(check_name, ', ')
        from tmp_f6b_chk where seccion='D_grants' and valor='SOLO_AUTH'));
end;
$$;

-- ============================================================
-- Output: resumen primero, luego detalle de fallas
-- ============================================================
with resumen as (
  select * from tmp_f6b_chk where seccion = 'Z_resumen'
), fallas as (
  select * from tmp_f6b_chk
  where seccion <> 'Z_resumen'
    and valor not in ('OK')
)
select * from resumen
union all
select * from fallas
order by seccion, check_name;

-- ============================================================
-- Resultado esperado:
--   total_esperadas = 50
--   existentes      = 50
--   faltantes       = 0
--   security_invoker= 0
--   sin_search_path = 0
--   sin_grant       = 0
--   solo_auth       = 0 (todas expuestas a anon también)
-- Si no, lista detallada de cuáles fallan.
-- ============================================================
