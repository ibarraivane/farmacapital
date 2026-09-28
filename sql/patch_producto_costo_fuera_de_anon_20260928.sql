-- ============================================================================
-- FarmaCapital · 28-sep-2026 · productos.costo fuera de la llave anon
--
-- La tienda pedía productos?select=* y el rol anon leía el costo.
-- Revocar solo la columna NO alcanza: el GRANT de tabla sigue ganando.
-- Hay que quitar el SELECT de tabla y volver a dar columna por columna,
-- sin costo.
--
-- ORDEN: desplegar primero el cliente de esta rama (tienda con columnas
-- explícitas; inventario / recibir / reabasto / referencias / Rappi leen
-- el costo por empleado_listar_productos_staff). Después pegar este archivo
-- en Supabase → SQL Editor → Run.
--
-- Si se corre antes del deploy, la tienda y el inventario que aún hacen
-- select=* dejan de cargar hasta que llegue el cliente nuevo.
-- Idempotente. No toca precios, stock ni lotes.
-- ============================================================================

begin;

create or replace function public.empleado_listar_productos_staff(
  p_session_token uuid,
  p_solo_activos boolean default false,
  p_desde timestamptz default null,
  p_offset integer default 0,
  p_limit integer default 1000
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_limit integer;
  v_offset integer;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_limit := coalesce(p_limit, 1000);
  if v_limit < 1 or v_limit > 1000 then
    v_limit := 1000;
  end if;
  v_offset := greatest(coalesce(p_offset, 0), 0);

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.nombre nulls last, x.id)
    from (
      select pr.*
      from public.productos pr
      where (p_solo_activos is not true or pr.activo is true)
        and (p_desde is null or pr.updated_at >= p_desde)
      order by pr.nombre nulls last, pr.id
      offset v_offset
      limit v_limit
    ) x
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.empleado_listar_productos_staff(uuid, boolean, timestamptz, integer, integer) from public;
grant execute on function public.empleado_listar_productos_staff(uuid, boolean, timestamptz, integer, integer) to anon, authenticated;

-- Tabla: anon y authenticated ven todas las columnas menos costo.
-- El dueño y service_role siguen viendo el costo. El personal lo pide
-- con el RPC de arriba (security definer + sesión de empleado).
do $$
declare
  cols text;
begin
  select string_agg(quote_ident(column_name), ', ' order by ordinal_position)
    into cols
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'productos'
    and column_name <> 'costo';

  if cols is null or btrim(cols) = '' then
    raise exception 'public.productos no tiene columnas';
  end if;

  execute 'revoke select on table public.productos from anon, authenticated';
  execute format(
    'grant select (%s) on table public.productos to anon, authenticated',
    cols
  );
end $$;

notify pgrst, 'reload schema';

commit;

-- Verificación (correr aparte, con un token de empleado vigente):
--   select jsonb_array_length(public.empleado_listar_productos_staff('<TOKEN>', false, null, 0, 2));
-- La tienda, sin sesión, ya no puede:
--   select costo from public.productos limit 1;  -- como anon: permission denied
