-- ============================================================
-- FARMAX — Diagnóstico de seguridad previo a F6
-- ============================================================
-- Objetivo: entender el estado actual antes de habilitar RLS.
-- No modifica nada. Solo lee.
-- ============================================================

do $$
declare
  r record;
  v_total int;
  v_hashed int;
begin
  drop table if exists tmp_sec;
  create temp table tmp_sec(
    seccion text, item text, detalle_1 text, detalle_2 text
  );

  -- ============================================================
  -- A) Tabla usuarios: estructura y estado de contraseñas
  -- ============================================================
  insert into tmp_sec
  select 'A_usuarios', 'columnas', string_agg(column_name, ', ' order by ordinal_position), null
  from information_schema.columns
  where table_schema='public' and table_name='usuarios';

  select count(*) into v_total from public.usuarios;
  insert into tmp_sec values ('A_usuarios', 'total_registros', v_total::text, null);

  -- ¿Las contraseñas están hasheadas?
  begin
    execute $q$
      select count(*), count(*) filter (where password like '$2%' or password like '$argon%' or password like '$scrypt%')
      from public.usuarios
    $q$ into v_total, v_hashed;
    insert into tmp_sec values (
      'A_usuarios', 'password_format',
      case
        when v_total = 0 then 'SIN USUARIOS'
        when v_hashed = v_total then 'HASHED (OK)'
        when v_hashed = 0 then 'PLAINTEXT (CRITICO)'
        else 'MIXTO'
      end,
      'total='||v_total||' hashed='||v_hashed
    );
  exception when undefined_column then
    insert into tmp_sec values ('A_usuarios', 'password_format', 'columna password no existe', null);
  end;

  -- ============================================================
  -- B) Supabase auth.users
  -- ============================================================
  select count(*) into v_total from auth.users;
  insert into tmp_sec values (
    'B_supabase_auth', 'auth_users_count', v_total::text,
    case when v_total = 0 then 'NO usa Supabase Auth' else 'USA Supabase Auth' end
  );

  insert into tmp_sec values (
    'B_supabase_auth', 'link_usuarios_auth',
    case when exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name='usuarios'
        and column_name in ('auth_uid','auth_id','supabase_uid','auth_user_id')
    ) then 'SI (hay columna de link)'
      else 'NO (usuarios y auth.users desconectados)'
    end,
    null
  );

  -- ============================================================
  -- C) RLS por tabla
  -- ============================================================
  for r in
    select c.relname as tabla, c.relrowsecurity as rls_enabled, c.relforcerowsecurity as rls_forzado
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname='public' and c.relkind='r'
    order by c.relname
  loop
    insert into tmp_sec values (
      'C_rls_tablas', r.tabla,
      case when r.rls_enabled then 'ENABLED' else 'DISABLED' end,
      case when r.rls_forzado then 'FORZADO' else 'no forzado' end
    );
  end loop;

  -- ============================================================
  -- D) Políticas existentes
  -- ============================================================
  select count(*) into v_total from pg_policies where schemaname='public';
  insert into tmp_sec values ('D_politicas', 'total_politicas', v_total::text, null);

  for r in
    select tablename, count(*) as n from pg_policies
    where schemaname='public'
    group by tablename order by tablename
  loop
    insert into tmp_sec values ('D_politicas', r.tablename, r.n::text||' politicas', null);
  end loop;

  -- ============================================================
  -- E) Uso de auth.uid()
  -- ============================================================
  select count(*) into v_total
  from pg_policies
  where schemaname='public'
    and (qual ilike '%auth.uid%' or with_check ilike '%auth.uid%');
  insert into tmp_sec values ('E_auth_uid_uso', 'en_policies', v_total::text, null);

  select count(*) into v_total
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname='public' and p.prokind = 'f'
    and pg_get_functiondef(p.oid) ilike '%auth.uid%';
  insert into tmp_sec values ('E_auth_uid_uso', 'en_funciones', v_total::text, null);

  -- ============================================================
  -- F) Security DEFINER vs INVOKER
  -- ============================================================
  select count(*) into v_total
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname='public' and p.prosecdef = true;
  insert into tmp_sec values ('F_rpcs_security', 'security_definer', v_total::text, null);

  select count(*) into v_total
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname='public' and p.prosecdef = false;
  insert into tmp_sec values ('F_rpcs_security', 'security_invoker', v_total::text, null);

  -- ============================================================
  -- G) Grants a roles públicos (anon/authenticated/public)
  -- ============================================================
  for r in
    select grantee, table_name, string_agg(distinct privilege_type, ',' order by privilege_type) as privs
    from information_schema.role_table_grants
    where table_schema='public' and grantee in ('anon','authenticated','public')
    group by grantee, table_name
    order by grantee, table_name
  loop
    insert into tmp_sec values ('G_grants_'||r.grantee, r.table_name, r.privs, null);
  end loop;

  -- ============================================================
  -- H) Columnas con PII / datos sensibles
  -- ============================================================
  for r in
    select table_name, column_name, data_type
    from information_schema.columns
    where table_schema='public'
      and (
        column_name ilike '%password%' or
        column_name ilike '%telefono%' or
        column_name ilike '%email%' or
        column_name ilike '%rfc%' or
        column_name ilike '%curp%' or
        column_name ilike '%direccion%' or
        column_name ilike '%cedula%' or
        column_name ilike '%receta%' or
        column_name ilike '%paciente%' or
        column_name ilike '%medico%'
      )
    order by table_name, column_name
  loop
    insert into tmp_sec values (
      'H_pii_candidatos', r.table_name||'.'||r.column_name, r.data_type, null
    );
  end loop;

end $$;

select seccion, item, detalle_1, detalle_2
from tmp_sec
order by seccion, item;

drop table if exists tmp_sec;
