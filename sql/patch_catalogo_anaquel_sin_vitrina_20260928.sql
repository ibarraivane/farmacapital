-- Catálogo más ligero · 28-sep-2026
--
-- No borra suplementos ni dermatología. Siguen en productos (bajo_pedido)
-- y en «Te lo conseguimos».
--
-- El POS armaba un solo JSON con TODO el catálogo activo, vitrina incluida.
-- Con esos miles de filas la respuesta se llena y la base trabaja de más.
-- Estas dos lecturas dejan fuera la vitrina. El anaquel pagina por la app.
--
-- Pegar en Supabase → SQL Editor → Run. Idempotente.

begin;

drop table if exists public._fc_cat_bp_stg;

create index if not exists idx_productos_anaquel_nombre
  on public.productos (nombre, id)
  where coalesce(bajo_pedido, false) = false;

create or replace function public.empleado_listar_productos_con_lotes_pos(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  return coalesce((
    select jsonb_agg(((to_jsonb(pr) - 'costo') || jsonb_build_object('lotes', lt.js)) order by pr.nombre nulls last)
    from public.productos pr
    left join lateral (
      select
        coalesce(
          jsonb_agg(
            jsonb_build_object(
              'fecha_caducidad', l.fecha_caducidad,
              'cantidad_actual', l.cantidad_actual,
              'activo', l.activo
            )
            order by l.id
          ),
          '[]'::jsonb
        ) as js
      from public.lotes l
      where l.producto_id = pr.id
    ) lt on true
    where coalesce(pr.activo, true) is true
      and coalesce(pr.bajo_pedido, false) = false
  ), '[]'::jsonb);
end;
$$;

create or replace function public.empleado_listar_productos_pos_delta(
  p_session_token uuid,
  p_desde timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);

  return jsonb_build_object(
    'ahora', clock_timestamp(),
    'productos', coalesce((
      select jsonb_agg(((to_jsonb(pr) - 'costo') || jsonb_build_object('lotes', lt.js)) order by pr.nombre nulls last)
      from public.productos pr
      left join lateral (
        select coalesce(
          jsonb_agg(
            jsonb_build_object(
              'id', l.id,
              'numero_lote', l.numero_lote,
              'fecha_caducidad', l.fecha_caducidad,
              'cantidad_actual', l.cantidad_actual,
              'activo', l.activo
            )
            order by l.id
          ),
          '[]'::jsonb
        ) as js
        from public.lotes l
        where l.producto_id = pr.id
      ) lt on true
      where pr.updated_at >= p_desde
        and coalesce(pr.bajo_pedido, false) = false
    ), '[]'::jsonb)
  );
end;
$$;

revoke all on function public.empleado_listar_productos_con_lotes_pos(uuid) from public;
grant execute on function public.empleado_listar_productos_con_lotes_pos(uuid) to anon, authenticated;

revoke all on function public.empleado_listar_productos_pos_delta(uuid, timestamptz) from public;
grant execute on function public.empleado_listar_productos_pos_delta(uuid, timestamptz) to anon, authenticated;

commit;

-- Siguen en la tabla. Esto solo confirma que la vitrina no se fue.
-- select count(*) filter (where coalesce(bajo_pedido, false)) as vitrina,
--        count(*) filter (where not coalesce(bajo_pedido, false)) as anaquel
--   from public.productos;
