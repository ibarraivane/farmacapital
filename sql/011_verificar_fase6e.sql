-- ============================================================
-- FARMAX — Verificación F6e: Inmutabilidad de audit logs
-- ============================================================
-- Ejecutar DESPUÉS de refactor_fase6e_proteger_audit.sql.
-- Cada bloque devuelve una fila con estado OK/FAIL.
-- ============================================================

-- 1) Las 2 tablas existen
select
  'tablas_existen' as check_name,
  count(*) as encontradas,
  case when count(*) = 2 then 'OK' else 'FAIL' end as estado
from information_schema.tables
where table_schema = 'public'
  and table_name in ('audit_log', 'audit_log_detallado');


-- 2) Nadie (anon/authenticated/public) tiene grants en audit_log_detallado
select
  'grants_revocados_det' as check_name,
  coalesce(count(*), 0) as grants_residuales,
  case when coalesce(count(*), 0) = 0 then 'OK' else 'FAIL' end as estado
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name = 'audit_log_detallado'
  and grantee in ('anon', 'authenticated', 'PUBLIC');


-- 3) Nadie (anon/authenticated/public) tiene grants en audit_log
select
  'grants_revocados_legacy' as check_name,
  coalesce(count(*), 0) as grants_residuales,
  case when coalesce(count(*), 0) = 0 then 'OK' else 'FAIL' end as estado
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name = 'audit_log'
  and grantee in ('anon', 'authenticated', 'PUBLIC');


-- 4) service_role solo tiene SELECT (si existe el rol)
select
  'service_role_solo_select' as check_name,
  string_agg(distinct privilege_type, ',' order by privilege_type) as privilegios,
  case
    when not exists (select 1 from pg_roles where rolname = 'service_role')
      then 'SKIP (no existe service_role)'
    when string_agg(distinct privilege_type, ',' order by privilege_type) = 'SELECT'
      then 'OK'
    else 'FAIL'
  end as estado
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name in ('audit_log', 'audit_log_detallado')
  and grantee = 'service_role';


-- 5) Triggers de inmutabilidad instalados (4 en total)
select
  'triggers_inmutabilidad' as check_name,
  count(*) as encontrados,
  case when count(*) >= 4 then 'OK' else 'FAIL' end as estado,
  string_agg(trigger_name || ' (' || event_manipulation || ')', ', ' order by trigger_name) as detalle
from information_schema.triggers
where event_object_schema = 'public'
  and event_object_table in ('audit_log', 'audit_log_detallado')
  and trigger_name like '%immutable%';


-- 6) Funciones de inmutabilidad existen y son SECURITY DEFINER
select
  'funciones_immutable' as check_name,
  count(*) as encontradas,
  case when count(*) = 2 then 'OK' else 'FAIL' end as estado
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in ('fn_audit_log_immutable', 'fn_audit_log_immutable_stmt')
  and p.prosecdef = true;


-- 7) RPCs de lectura para dashboard existen
select
  'rpcs_lectura_dashboard' as check_name,
  count(*) as encontradas,
  case when count(*) = 3 then 'OK' else 'FAIL' end as estado,
  string_agg(p.proname, ', ' order by p.proname) as funciones
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'admin_listar_audit_log',
    'admin_listar_audit_log_detallado',
    'admin_contar_audit_log_detallado'
  );


-- 8) Smoke test de inmutabilidad (debe bloquear)
-- ADVERTENCIA: este bloque provoca un ERROR intencional.
-- Solo descomentar si quieres verificar el bloqueo:
/*
do $$
declare
  v_id bigint;
  v_bloqueado boolean := false;
begin
  -- Insertar una fila de prueba (usando bypass simulado de trigger)
  -- Como este DO corre fuera de RPC, no tiene contexto de actor,
  -- pero aún puede insertar porque INSERT no está bloqueado.
  insert into public.audit_log_detallado (tabla, operacion, registro_id)
  values ('__test_immutability__', 'INSERT', 'test')
  returning id into v_id;

  -- Intentar modificar (DEBE FALLAR)
  begin
    update public.audit_log_detallado set tabla = 'hacked' where id = v_id;
  exception when others then
    v_bloqueado := true;
  end;

  -- Limpiar (con bypass)
  perform set_config('app.audit_bypass', 'true', true);
  delete from public.audit_log_detallado where id = v_id;

  raise notice 'Smoke test: inmutabilidad %', case when v_bloqueado then 'OK (update bloqueado)' else 'FAIL (update permitido)' end;
end $$;
*/
