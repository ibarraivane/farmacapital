-- Inventario · 28-sep-2026
--
-- La llave pública ya no puede leer productos.costo. Un select=* (o cualquier
-- select que pida esa columna) responde:
--   permission denied for table productos
--
-- No se vuelve a dar GRANT de costo a anon: la tienda usa la misma llave.
-- El catálogo de mostrador lo pide por sesión. Solo admin y gerente lo ven.
-- El vendedor recibe [].
--
-- Pegar en Supabase → SQL Editor → Run. Idempotente.

begin;

create or replace function public.empleado_listar_costos_productos(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
begin
  v_user_id := public.fn_require_empleado(p_session_token);

  select u.rol into v_rol
  from public.usuarios u
  where u.id = v_user_id;

  if v_rol is null or v_rol not in ('admin', 'gerente') then
    return '[]'::jsonb;
  end if;

  return coalesce((
    select jsonb_agg(
      jsonb_build_object('id', p.id, 'costo', p.costo)
      order by p.id
    )
    from public.productos p
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.empleado_listar_costos_productos(uuid) from public;
grant execute on function public.empleado_listar_costos_productos(uuid) to anon, authenticated;

commit;
