-- Enriquece datos de producto en listado de lotes (marca, código de barras, presentación).
-- Ejecutar en Supabase SQL Editor.

create or replace function public.empleado_listar_lotes_inventario(
  p_session_token uuid
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

  return coalesce((
    select jsonb_agg(
      to_jsonb(l) ||
      jsonb_build_object(
        'productos', jsonb_build_object(
          'id', pr.id,
          'nombre', pr.nombre,
          'sku', pr.sku,
          'codigo_barras', pr.codigo_barras,
          'marca', pr.marca,
          'presentacion', pr.presentacion,
          'forma_farmaceutica', pr.forma_farmaceutica,
          'categoria', pr.categoria
        ),
        'proveedores', jsonb_build_object('id', pv.id, 'nombre', pv.nombre)
      )
      order by l.fecha_caducidad nulls last
    )
    from public.lotes l
    join public.productos pr on pr.id = l.producto_id
    left join public.proveedores pv on pv.id = l.proveedor_id
    where coalesce(l.activo, true)
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_lotes_inventario(uuid) to anon, authenticated;
