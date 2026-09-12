-- ============================================================
-- FARMAX — Security Advisor (Supabase) 2026-09-08
-- ============================================================
-- Cierra los 2 ERROR del Security Advisor y el warning
-- function_search_path_mutable, sin romper el modelo de auth
-- (anon + p_session_token + RPCs SECURITY DEFINER).
--
-- ERRORES
--   1) producto_precios_referencia_actual es SECURITY DEFINER
--      (default de Postgres). La tabla ya tiene RLS SELECT true;
--      con security_invoker=true el frontend sigue leyendo igual.
--   2) rappi_sync_queue es pública y no tenía RLS. El panel
--      RappiSyncPanel lee filas vía cliente anon. Se habilita
--      RLS + SELECT; INSERT/UPDATE/DELETE siguen solo por
--      trigger SECURITY DEFINER y service_role.
--
-- WARNINGS que SÍ se corrigen
--   - search_path mutable: ALTER FUNCTION SET search_path en
--     todas las funciones public que no lo tengan. No reescribe
--     cuerpos. Incluye extensions (pgcrypto en Supabase).
--
-- WARNINGS / INFO que se dejan a propósito
--   - anon/authenticated EXECUTE en RPCs de sesión (admin_*,
--     empleado_*, cliente_*, *_secure, recepción, login):
--     el POS las llama como anon con p_session_token. Revocar
--     esas tumba la app. Triggers y mutadores legacy SIN token
--     se cierran en patch_seguridad_advisor_20260908_b.sql.
--   - rls_enabled_no_policy (sesiones, audit, recetas, etc.):
--     RLS ON + cero policies = deny-all por REST. Es el diseño
--     F6c. No agregar policies SELECT.
--   - rls_policy_always_true en importaciones_referencia y
--     producto_precios_referencia: el módulo de precios y
--     ultimaCompra insertan/actualizan desde el cliente anon.
--     No quitar esas policies.
--   - public_bucket_allows_listing (banners, productos):
--     storageFarmax.list() necesita SELECT amplio para borrar.
--   - auth_leaked_password_protection: se activa en el
--     dashboard (Auth → Password security), no en SQL.
--
-- Correr en el SQL Editor de Supabase. Idempotente.
-- ============================================================

begin;

-- 1) Vista: respetar RLS del invocador (ERROR security_definer_view)
do $$
begin
  if to_regclass('public.producto_precios_referencia_actual') is null then
    raise notice 'producto_precios_referencia_actual no existe; se omite.';
    return;
  end if;
  execute 'alter view public.producto_precios_referencia_actual set (security_invoker = true)';
  execute 'grant select on public.producto_precios_referencia_actual to anon, authenticated';
end
$$;


-- 2) rappi_sync_queue: RLS + lectura para el panel (ERROR rls_disabled_in_public)
do $$
begin
  if to_regclass('public.rappi_sync_queue') is null then
    raise notice 'rappi_sync_queue no existe; se omite RLS.';
    return;
  end if;

  execute 'alter table public.rappi_sync_queue enable row level security';

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'rappi_sync_queue'
      and policyname = 'rappi_sync_queue_select'
  ) then
    execute $p$
      create policy rappi_sync_queue_select
        on public.rappi_sync_queue
        for select
        to anon, authenticated
        using (true)
    $p$;
  end if;

  -- Escrituras solo servicio / trigger (F6a ya revocó; se reafirma)
  revoke insert, update, delete on public.rappi_sync_queue from anon, authenticated, public;
  grant select on public.rappi_sync_queue to anon, authenticated;
end
$$;


-- 3) Pedidos: policy INSERT always-true huérfana (no está en el repo;
--    los inserts van por RPC SECURITY DEFINER). F6a ya revocó INSERT.
drop policy if exists insert_pedidos on public.pedidos;


-- 4) search_path fijo en funciones public que no lo tienen
do $$
declare
  r record;
  n int := 0;
begin
  for r in
    select
      case when p.prokind = 'p' then 'procedure' else 'function' end as kind,
      format(
        '%I.%I(%s)',
        n.nspname,
        p.proname,
        pg_get_function_identity_arguments(p.oid)
      ) as ident
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.prokind in ('f', 'p')
      and not exists (
        select 1
        from unnest(coalesce(p.proconfig, '{}')) cfg
        where cfg like 'search_path=%'
      )
  loop
    execute format(
      'alter %s %s set search_path = public, extensions, pg_temp',
      r.kind,
      r.ident
    );
    n := n + 1;
  end loop;
  raise notice 'search_path fijado en % funciones public', n;
end
$$;

commit;
