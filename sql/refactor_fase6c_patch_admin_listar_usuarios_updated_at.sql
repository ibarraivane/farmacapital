-- FARMAX — Parche: admin_listar_usuarios (sin updated_at + casts al tipo del RETURNS)
-- Síntomas:
--   • "column u.updated_at does not exist"
--   • "structure of query does not match function result type" (p. ej. id integer, created_at timestamp)
-- Ejecutar en Supabase SQL Editor (idempotente).

begin;

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

  -- Tipos alineados con public.usuarios (id int4, sin columna updated_at).
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

commit;
