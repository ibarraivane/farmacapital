-- FARMAX — Parche: admin_listar_clientes (columnas según pg_catalog)
--
-- Si la tabla clientes no tiene created_at, notas, email, etc., un SELECT fijo falla.
-- information_schema a veces no coincide con la tabla real; pg_attribute sí.
--
-- Ejecutar en Supabase SQL Editor (idempotente).

begin;

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

commit;
