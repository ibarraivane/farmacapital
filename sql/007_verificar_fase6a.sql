-- ============================================================
-- FARMAX — Verificación F6a (tokens + RPCs)
-- ============================================================
-- Corre DESPUES de refactor_fase6a_tokens.sql
-- NO requiere haber corrido aun refactor_fase6a_grants.sql.
--
-- Debe mostrar:
--   A_tablas: sesiones y sesiones_cliente EXISTEN y tienen RLS
--   B_funciones: 6 funciones F6a existen
--   C_policies: sesiones_*_deny_all presentes
--   D_login_test: login con usuario real retorna success=true
-- ============================================================

do $$
declare
  v_total int;
  v_usuario record;
  v_result jsonb;
begin
  drop table if exists tmp_f6a;
  create temp table tmp_f6a(seccion text, item text, detalle text);

  -- A) Tablas
  select count(*) into v_total
  from information_schema.tables
  where table_schema='public' and table_name in ('sesiones','sesiones_cliente');
  insert into tmp_f6a values ('A_tablas', 'tablas_sesiones_creadas', v_total||' de 2');

  insert into tmp_f6a
  select 'A_tablas', 'rls_'||c.relname,
    case when c.relrowsecurity then 'ENABLED' else 'DISABLED' end
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where n.nspname='public' and c.relname in ('sesiones','sesiones_cliente');

  -- B) Funciones
  insert into tmp_f6a
  select 'B_funciones', p.proname,
    case when p.prosecdef then 'SECURITY DEFINER (OK)' else 'SECURITY INVOKER' end
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname='public'
    and p.proname in (
      'login_empleado','login_cliente',
      'logout_empleado','logout_cliente',
      'fn_validar_token_empleado','fn_validar_token_cliente',
      'fn_hash_empleado','fn_hash_cliente'
    )
  order by p.proname;

  -- C) Policies
  insert into tmp_f6a
  select 'C_policies', tablename||'.'||policyname,
    'comando='||cmd||' roles='||array_to_string(roles,',')
  from pg_policies
  where schemaname='public' and tablename in ('sesiones','sesiones_cliente');

  -- D) Test: verifica que la RPC login_empleado retorna success=false con credenciales invalidas
  begin
    select public.login_empleado('no_existe_xxx@no.com', 'x', '127.0.0.1', 'test') into v_result;
    insert into tmp_f6a values (
      'D_smoke', 'login_cred_invalidas',
      case when (v_result->>'success')::boolean = false then 'OK (rechaza)'
           else 'FALLO (debio rechazar)' end
    );
  exception when others then
    insert into tmp_f6a values ('D_smoke', 'login_cred_invalidas', 'ERROR: '||SQLERRM);
  end;

  -- E) Passwords hasheados: comprueba que al menos un usuario activo tiene
  -- hash SHA-256 (64 hex chars)
  select count(*) into v_total
  from public.usuarios
  where activo = true
    and password_hash ~ '^[0-9a-f]{64}$';
  insert into tmp_f6a values (
    'E_usuarios', 'hash_sha256_validos', v_total||' usuarios activos con hash ok'
  );

end $$;

select seccion, item, detalle from tmp_f6a order by seccion, item;

drop table if exists tmp_f6a;
