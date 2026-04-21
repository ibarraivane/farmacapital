-- ============================================================
-- FARMAX — F6a(2/4): RPCs de lectura para tablas de credenciales
-- ============================================================
-- Tras revocar SELECT directo sobre usuarios / clientes / empleados /
-- password_reset_requests, el frontend necesita RPCs SECURITY DEFINER
-- que validen session token y NUNCA expongan password_hash ni salt.
--
-- Idempotente: usa CREATE OR REPLACE.
-- ============================================================

begin;

-- ============================================================
-- admin_listar_usuarios: lista usuarios del sistema (admin panel)
-- ============================================================
-- No devuelve password_hash ni salt.
-- Solo admin puede llamar.
-- DROP: no se puede cambiar RETURNS TABLE solo con CREATE OR REPLACE.
-- ============================================================
drop function if exists public.admin_listar_usuarios(uuid);

create or replace function public.admin_listar_usuarios(
  p_session_token uuid
)
returns table (
  id         integer,
  nombre     text,
  email      text,
  rol        text,
  activo     boolean,
  created_at timestamptz,
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);

  -- Sin columna updated_at: se devuelve created_at dos veces. id = integer (int4) como en la tabla.
  return query
  select
    u.id,
    u.nombre,
    u.email,
    u.rol,
    coalesce(u.activo, false),
    u.created_at,
    u.created_at
  from public.usuarios u
  order by u.nombre;
end;
$$;

grant execute on function public.admin_listar_usuarios(uuid) to anon, authenticated;


-- ============================================================
-- admin_listar_clientes: lista clientes (admin panel)
-- ============================================================
-- No devuelve password_hash ni salt.
-- Cualquier empleado puede listar clientes (ventas, caja, consultorio).
-- DROP: Postgres no permite cambiar RETURNS TABLE solo con CREATE OR REPLACE.
-- ============================================================
drop function if exists public.admin_listar_clientes(uuid);

create or replace function public.admin_listar_clientes(
  p_session_token uuid
)
returns table (
  id                integer,
  nombre            text,
  telefono          text,
  email             text,
  puntos            integer,
  notas             text,
  alergias          text,
  antecedentes      text,
  direccion         text,
  fecha_nacimiento  date,
  genero            text,
  created_at        timestamptz,
  updated_at        timestamptz
)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  has_email    boolean;
  has_puntos   boolean;
  has_notas    boolean;
  has_created  boolean;
  has_updated  boolean;
  expr_email   text;
  expr_puntos  text;
  expr_notas   text;
  expr_ca      text;
  expr_upd     text;
begin
  perform public.fn_require_empleado(p_session_token);

  select
    exists (
      select 1 from pg_catalog.pg_attribute a
      join pg_catalog.pg_class c on c.oid = a.attrelid
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'clientes'
        and a.attname = 'email' and a.attnum > 0 and not a.attisdropped
    ),
    exists (
      select 1 from pg_catalog.pg_attribute a
      join pg_catalog.pg_class c on c.oid = a.attrelid
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'clientes'
        and a.attname = 'puntos' and a.attnum > 0 and not a.attisdropped
    ),
    exists (
      select 1 from pg_catalog.pg_attribute a
      join pg_catalog.pg_class c on c.oid = a.attrelid
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'clientes'
        and a.attname = 'notas' and a.attnum > 0 and not a.attisdropped
    ),
    exists (
      select 1 from pg_catalog.pg_attribute a
      join pg_catalog.pg_class c on c.oid = a.attrelid
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'clientes'
        and a.attname = 'created_at' and a.attnum > 0 and not a.attisdropped
    ),
    exists (
      select 1 from pg_catalog.pg_attribute a
      join pg_catalog.pg_class c on c.oid = a.attrelid
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'clientes'
        and a.attname = 'updated_at' and a.attnum > 0 and not a.attisdropped
    )
  into has_email, has_puntos, has_notas, has_created, has_updated;

  expr_email  := case when has_email  then 'c.email::text' else 'null::text' end;
  expr_puntos := case when has_puntos then 'round(coalesce(c.puntos, 0))::integer' else '0::integer' end;
  expr_notas  := case when has_notas  then 'c.notas::text' else 'null::text' end;

  if has_created then
    expr_ca := 'c.created_at::timestamptz';
  elsif has_updated then
    expr_ca := 'c.updated_at::timestamptz';
  else
    expr_ca := 'now()::timestamptz';
  end if;

  if has_updated and has_created then
    expr_upd := 'coalesce(c.updated_at, c.created_at)::timestamptz';
  elsif has_updated then
    expr_upd := 'c.updated_at::timestamptz';
  elsif has_created then
    expr_upd := 'c.created_at::timestamptz';
  else
    expr_upd := 'now()::timestamptz';
  end if;

  return query execute format(
    $q$
    select
      c.id::integer,
      c.nombre,
      c.telefono,
      %s,
      %s,
      %s,
      null::text,
      null::text,
      null::text,
      null::date,
      null::text,
      %s,
      %s
    from public.clientes c
    order by c.nombre
    $q$,
    expr_email,
    expr_puntos,
    expr_notas,
    expr_ca,
    expr_upd
  );
end;
$$;

grant execute on function public.admin_listar_clientes(uuid) to anon, authenticated;


-- ============================================================
-- admin_obtener_cliente: detalle de un cliente (admin panel)
-- ============================================================
create or replace function public.admin_obtener_cliente(
  p_session_token uuid,
  p_cliente_id    bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_json jsonb;
begin
  perform public.fn_require_empleado(p_session_token);

  select to_jsonb(c.*) - 'password_hash' - 'salt' into v_json
  from public.clientes c
  where c.id = p_cliente_id;

  if v_json is null then
    raise exception 'Cliente % no encontrado', p_cliente_id;
  end if;

  return v_json;
end;
$$;

grant execute on function public.admin_obtener_cliente(uuid, bigint) to anon, authenticated;


-- ============================================================
-- admin_obtener_cliente_por_telefono: para Consultorio (busca por tel)
-- ============================================================
create or replace function public.admin_obtener_cliente_por_telefono(
  p_session_token uuid,
  p_telefono      text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_json jsonb;
begin
  perform public.fn_require_empleado(p_session_token);

  select jsonb_build_object(
    'id',       c.id,
    'nombre',   c.nombre,
    'telefono', c.telefono,
    'email',    c.email,
    'notas',    c.notas,
    'alergias', c.alergias,
    'antecedentes', c.antecedentes
  ) into v_json
  from public.clientes c
  where c.telefono = p_telefono
  limit 1;

  return v_json; -- null si no existe (maybeSingle friendly)
end;
$$;

grant execute on function public.admin_obtener_cliente_por_telefono(uuid, text) to anon, authenticated;


-- ============================================================
-- admin_contar_clientes_desde: count para dashboard
-- ============================================================
create or replace function public.admin_contar_clientes_desde(
  p_session_token uuid,
  p_desde         timestamptz
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_count integer;
begin
  perform public.fn_require_empleado(p_session_token);

  select count(*)::int into v_count
  from public.clientes
  where created_at >= p_desde;

  return v_count;
end;
$$;

grant execute on function public.admin_contar_clientes_desde(uuid, timestamptz) to anon, authenticated;


-- ============================================================
-- admin_listar_empleados: lista empleados (RRHH)
-- ============================================================
-- No devuelve password_hash ni salt (si existen).
-- ============================================================
create or replace function public.admin_listar_empleados(
  p_session_token uuid
)
returns setof jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);

  return query
  select to_jsonb(e.*) - 'password_hash' - 'salt'
  from public.empleados e
  order by e.nombre;
end;
$$;

grant execute on function public.admin_listar_empleados(uuid) to anon, authenticated;


-- ============================================================
-- admin_contar_password_resets_pendientes
-- ============================================================
create or replace function public.admin_contar_password_resets_pendientes(
  p_session_token uuid
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_count       integer := 0;
  v_has_estado  boolean;
  v_has_atendido boolean;
begin
  perform public.fn_require_admin(p_session_token);

  select exists(
    select 1 from information_schema.columns
    where table_schema='public' and table_name='password_reset_requests'
      and column_name='estado'
  ) into v_has_estado;

  select exists(
    select 1 from information_schema.columns
    where table_schema='public' and table_name='password_reset_requests'
      and column_name='atendido'
  ) into v_has_atendido;

  if v_has_estado then
    execute 'select count(*)::int from public.password_reset_requests where estado = ''pendiente'''
      into v_count;
  elsif v_has_atendido then
    execute 'select count(*)::int from public.password_reset_requests where atendido = false'
      into v_count;
  else
    execute 'select count(*)::int from public.password_reset_requests'
      into v_count;
  end if;

  return coalesce(v_count, 0);
end;
$$;

grant execute on function public.admin_contar_password_resets_pendientes(uuid) to anon, authenticated;


-- ============================================================
-- admin_listar_password_resets_pendientes
-- ============================================================
create or replace function public.admin_listar_password_resets_pendientes(
  p_session_token uuid
)
returns setof jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_has_estado   boolean;
  v_has_atendido boolean;
  v_filter       text;
begin
  perform public.fn_require_admin(p_session_token);

  select exists(
    select 1 from information_schema.columns
    where table_schema='public' and table_name='password_reset_requests' and column_name='estado'
  ) into v_has_estado;

  select exists(
    select 1 from information_schema.columns
    where table_schema='public' and table_name='password_reset_requests' and column_name='atendido'
  ) into v_has_atendido;

  if v_has_estado then
    v_filter := 'where estado = ''pendiente''';
  elsif v_has_atendido then
    v_filter := 'where atendido = false';
  else
    v_filter := '';
  end if;

  return query execute format(
    'select to_jsonb(r.*) from public.password_reset_requests r %s order by r.created_at desc',
    v_filter
  );
end;
$$;

grant execute on function public.admin_listar_password_resets_pendientes(uuid) to anon, authenticated;

commit;
