-- ============================================================
-- FARMAX — Security Advisor (Supabase) 2026-09-08 B
-- ============================================================
-- Segunda pasada: cierra warnings de EXECUTE en funciones
-- internas / triggers / RPCs legacy SIN token de sesión.
--
-- El POS, admin, login, recepción y tienda siguen llamando
-- RPCs SECURITY DEFINER como rol `anon` + p_session_token.
-- Esas NO se tocan. Cada una valida el token adentro.
--
-- Por qué por NOMBRE y no por firma
--   F6f revocó create_producto_with_lote(jsonb,int,text,date,numeric,bigint)
--   y en producción quedó otra sobrecarga de 7 args (p_proveedor_tienda).
--   El Advisor la sigue viendo. Aquí se revocan TODAS las
--   sobrecargas de cada nombre listado.
--
-- Qué SÍ se revoca (anon / authenticated / public)
--   - Triggers: handle_new_auth_user, trg_productos_rappi_sync_queue,
--     fn_sync_productos_stock, fn_descontar_saldo_mp_recargas,
--     fc_registrar_ultima_compra_lote.
--   - Helpers internos (otros SECURITY DEFINER los llaman como
--     owner; el API usa service_role para fn_require_admin).
--   - Mutadores legacy sin token: adjust_stock, create_sale_*,
--     create_producto_with_lote, consume_stock_via_lotes,
--     receive_merchandise_lote, recepcion_entrar_stock_item,
--     reconcile_*, fn_descontar_fefo_cantidad, etc.
--
-- Qué NO se toca (rompería la app)
--   - admin_*, empleado_*, cliente_*, login_*, logout_*,
--     registrar_cliente, solicitar_reset_password
--   - *_secure y recepción (recepcion_abrir, …)
--   - public_cita_*, tienda_public_lotes_resumen_checkout,
--     reserve_stock_for_checkout
--   - Policies always-true de importaciones_referencia /
--     producto_precios_referencia (el módulo Precios escribe
--     como anon). Migrar a RPC es otro ticket.
--   - SELECT amplio en storage.objects de banners/productos:
--     storageFarmax.list() borra fotos viejas. InventarioModule
--     todavía usa el bucket `productos`.
--   - auth_leaked_password_protection: dashboard Auth →
--     Password security → HaveIBeenPwned. No es SQL.
--
-- Correr en el SQL Editor DESPUÉS de
--   sql/patch_seguridad_advisor_20260908.sql
-- Idempotente. service_role conserva EXECUTE.
-- ============================================================

begin;

do $$
declare
  v_nombres text[] := array[
    -- triggers / colas (el trigger sigue disparándose; solo se cierra /rpc)
    'handle_new_auth_user',
    'trg_productos_rappi_sync_queue',
    'fn_sync_productos_stock',
    'fn_descontar_saldo_mp_recargas',
    'fc_registrar_ultima_compra_lote',

    -- helpers (F6b.auth ya los revocó; F6b/F6d los re-grantearon)
    'fn_generar_salt',
    'fn_require_admin',
    'fn_require_empleado',
    'fn_require_cliente',
    'fn_require_caja_abierta_vendedor',

    -- helpers de negocio, solo llamados desde otras RPCs
    'fn_config_num',
    'rappi_cfg_int',
    'get_lote_fefo',
    'importe_cajas_fefo',
    'precio_caja_cobro_pos',
    'precio_especial_lote_vigente',
    'fc_resolver_proveedor_tienda',
    'fc_recepcion_upsert_ticket_corroborar',
    'fn_asegurar_cliente_telefono',
    'fn_descontar_fefo_cantidad',
    'fn_ejecutar_efectos_devolucion',
    'fn_mover_credito_cliente',
    'fn_ensure_lote_stock_vendible',
    'fn_sync_turno_caja',

    -- mutadores legacy: el frontend vivo usa *_secure
    'adjust_stock',
    'adjust_stock_via_lotes',
    'abrir_caja_lote',
    'create_sale_transaction',
    'create_sale_transaction_v2',
    'create_producto_with_lote',
    'consume_stock_via_lotes',
    'receive_merchandise_lote',
    'recepcion_entrar_stock_item',
    'reconcile_cash_rango',
    'reconcile_shift_cash'
  ];
  r record;
  n_revocadas int := 0;
  n_faltantes int := 0;
  v_faltantes text[] := '{}';
begin
  -- nombres del arreglo que no existen en public (aviso, no error)
  select coalesce(array_agg(nombre order by nombre), '{}')
    into v_faltantes
  from unnest(v_nombres) as nombre
  where not exists (
    select 1
    from pg_proc p
    join pg_namespace ns on ns.oid = p.pronamespace
    where ns.nspname = 'public'
      and p.proname = nombre
      and p.prokind in ('f', 'p')
  );
  n_faltantes := coalesce(array_length(v_faltantes, 1), 0);

  for r in
    select
      case when p.prokind = 'p' then 'procedure' else 'function' end as kind,
      format(
        '%I.%I(%s)',
        ns.nspname,
        p.proname,
        pg_get_function_identity_arguments(p.oid)
      ) as ident
    from pg_proc p
    join pg_namespace ns on ns.oid = p.pronamespace
    where ns.nspname = 'public'
      and p.prokind in ('f', 'p')
      and p.proname = any(v_nombres)
    order by p.proname, p.oid
  loop
    execute format(
      'revoke execute on %s %s from public, anon, authenticated',
      r.kind,
      r.ident
    );
    execute format(
      'grant execute on %s %s to service_role',
      r.kind,
      r.ident
    );
    n_revocadas := n_revocadas + 1;
  end loop;

  raise notice
    'advisor B: EXECUTE revocado en % sobrecargas; % nombres del listado no existen (%)',
    n_revocadas,
    n_faltantes,
    case when n_faltantes = 0 then 'ninguno'
         else array_to_string(v_faltantes, ', ')
    end;
end
$$;

commit;

-- Comprobar en el editor: anon no debe tener EXECUTE en estos nombres.
select
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args,
  has_function_privilege('anon', p.oid, 'EXECUTE') as anon_exec,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') as auth_exec,
  has_function_privilege('service_role', p.oid, 'EXECUTE') as service_exec
from pg_proc p
join pg_namespace ns on ns.oid = p.pronamespace
where ns.nspname = 'public'
  and p.prokind in ('f', 'p')
  and p.proname in (
    'handle_new_auth_user',
    'trg_productos_rappi_sync_queue',
    'fn_sync_productos_stock',
    'fn_descontar_saldo_mp_recargas',
    'fc_registrar_ultima_compra_lote',
    'fn_generar_salt',
    'fn_require_admin',
    'fn_require_empleado',
    'fn_require_cliente',
    'fn_require_caja_abierta_vendedor',
    'fn_config_num',
    'rappi_cfg_int',
    'get_lote_fefo',
    'importe_cajas_fefo',
    'precio_caja_cobro_pos',
    'precio_especial_lote_vigente',
    'fc_resolver_proveedor_tienda',
    'fc_recepcion_upsert_ticket_corroborar',
    'fn_asegurar_cliente_telefono',
    'fn_descontar_fefo_cantidad',
    'fn_ejecutar_efectos_devolucion',
    'fn_mover_credito_cliente',
    'fn_ensure_lote_stock_vendible',
    'fn_sync_turno_caja',
    'adjust_stock',
    'adjust_stock_via_lotes',
    'abrir_caja_lote',
    'create_sale_transaction',
    'create_sale_transaction_v2',
    'create_producto_with_lote',
    'consume_stock_via_lotes',
    'receive_merchandise_lote',
    'recepcion_entrar_stock_item',
    'reconcile_cash_rango',
    'reconcile_shift_cash'
  )
order by p.proname, 2;
