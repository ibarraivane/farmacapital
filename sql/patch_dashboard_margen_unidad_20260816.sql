-- Margen por categoría: el tab usaba costo de CAJA × cantidad aunque
-- la venta hubiera sido por pieza (Pedido #27 Aspirina = −339%).
-- Se exponen venta_unidad / unidades_por_caja / precio / precio_unidad
-- para que el dashboard prorratee costo/caja.

create or replace function public.empleado_dashboard_reporte_bundle(
  p_session_token uuid,
  p_desde timestamptz,
  p_desde_fecha date
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
    'peds', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'total', p.total,
          'created_at', p.created_at,
          'tipo', p.tipo,
          'atendido_por', p.atendido_por,
          'usuarios', jsonb_build_object('nombre', u.nombre)
        )
        order by p.created_at desc
      )
      from public.pedidos p
      left join public.usuarios u on u.id = p.atendido_por
      where (p.estado)::text = 'completado'
        and p.created_at >= p_desde
    ), '[]'::jsonb),
    'cons', coalesce((
      select jsonb_agg(jsonb_build_object('id', c.id))
      from public.citas c
      where c.fecha >= p_desde_fecha
        and coalesce(c.estado,'') <> 'cancelada'
        and ((c.estado)::text = any(array['completada','pagada']) or coalesce(c.pago_estado,'')='pagada')
    ), '[]'::jsonb),
    'ponl', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where (p.estado)::text='completado' and (p.tipo)::text='online' and p.created_at >= p_desde), '[]'::jsonb),
    'devs', coalesce((select jsonb_agg(jsonb_build_object('total_devuelto', d.total_devuelto)) from public.devoluciones d where (d.estado)::text='aprobada' and d.created_at >= p_desde), '[]'::jsonb),
    'peds_cat', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'total', p.total,
          'productos', coalesce(pi.js, '[]'::jsonb)
        )
        order by p.created_at desc
      )
      from public.pedidos p
      left join lateral (
        select jsonb_agg(
          jsonb_build_object(
            'precio_unitario', x.precio_unitario,
            'cantidad', x.cantidad,
            'productos', jsonb_build_object(
              'categoria', pr.categoria,
              'costo', pr.costo,
              'precio', pr.precio,
              'precio_unidad', pr.precio_unidad,
              'venta_unidad', pr.venta_unidad,
              'unidades_por_caja', pr.unidades_por_caja
            )
          )
          order by x.id
        ) as js
        from public.pedido_items x
        join public.productos pr on pr.id = x.producto_id
        where x.pedido_id = p.id
      ) pi on true
      where (p.estado)::text = 'completado'
        and p.created_at >= p_desde
    ), '[]'::jsonb),
    'peds_receta_farmax', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where (p.estado)::text='completado' and (p.receta_origen)::text='medico_farmax' and p.created_at >= p_desde), '[]'::jsonb),
    'citas_receta_ext_period_count', (
      select count(*)::int from public.citas c
      where c.fecha >= p_desde_fecha
        and coalesce(c.receta_surtido_en,'') = 'externa'
        and coalesce(c.estado,'') <> 'cancelada'
        and ((c.estado)::text = any(array['completada','pagada']) or coalesce(c.pago_estado,'')='pagada')
    )
  );
end;
$$;

grant execute on function public.empleado_dashboard_reporte_bundle(uuid, timestamptz, date) to anon, authenticated;
