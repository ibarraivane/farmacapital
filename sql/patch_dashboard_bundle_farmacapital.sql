-- Parche: alias FarmaCapital en bundles del dashboard + receta_origen médico
-- Ejecutar en Supabase SQL Editor si los KPIs de receta consultorio salen en $0.

-- Alias en bundle operación (JS lee ped_receta_farmacapital o ped_receta_farmax)
create or replace function public.empleado_dashboard_operacion_bundle(
  p_session_token uuid,
  p_ctx jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_ts timestamptz;
  v_te timestamptz;
  v_ys timestamptz;
  v_ye timestamptz;
  v_ws timestamptz;
  v_ps timestamptz;
  v_pe timestamptz;
  v_ms timestamptz;
  v_me timestamptz;
  v_hoy_local date;
  v_ayer_local date;
  v_inicio_mes date;
  v_receta jsonb;
begin
  v_dummy := public.fn_require_empleado(p_session_token);

  v_ts := (p_ctx->>'today_start')::timestamptz;
  v_te := (p_ctx->>'today_end')::timestamptz;
  v_ys := (p_ctx->>'yesterday_start')::timestamptz;
  v_ye := (p_ctx->>'yesterday_end')::timestamptz;
  v_ws := (p_ctx->>'week_start')::timestamptz;
  v_ps := (p_ctx->>'week_prev_start')::timestamptz;
  v_pe := (p_ctx->>'week_prev_end')::timestamptz;
  v_ms := (p_ctx->>'month_start')::timestamptz;
  v_me := (p_ctx->>'month_prev_end')::timestamptz;
  v_hoy_local := (p_ctx->>'hoy_local')::date;
  v_ayer_local := (p_ctx->>'ayer_local')::date;
  v_inicio_mes := (p_ctx->>'inicio_mes_local')::date;

  v_receta := coalesce((
    select jsonb_agg(jsonb_build_object('total', p.total))
    from public.pedidos p
    where (p.estado)::text = 'completado'
      and (p.receta_origen)::text = any (array['medico_farmacapital', 'medico_farmax'])
      and p.created_at >= v_ms
  ), '[]'::jsonb);

  return jsonb_build_object(
    'cfg_rows', coalesce((
      select jsonb_agg(jsonb_build_object('clave', c.clave, 'valor', c.valor))
      from public.configuracion c
      where c.clave = any (array[
        'estimado_receta_externa',
        'meta_ventas_dia', 'meta_ventas_semana', 'meta_ventas_mes',
        'meta_ticket_prom', 'meta_consultas_dia', 'meta_consultas_mes'
      ])
    ), '[]'::jsonb),
    'ped_hoy', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where (p.estado)::text='completado' and p.created_at >= v_ts and p.created_at <= v_te), '[]'::jsonb),
    'ped_ayer', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where (p.estado)::text='completado' and p.created_at >= v_ys and p.created_at <= v_ye), '[]'::jsonb),
    'ped_semana', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where (p.estado)::text='completado' and p.created_at >= v_ws), '[]'::jsonb),
    'ped_semana_ant', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where (p.estado)::text='completado' and p.created_at >= v_ps and p.created_at <= v_pe), '[]'::jsonb),
    'ped_mes', coalesce((select jsonb_agg(jsonb_build_object('total', p.total,'atendido_por', p.atendido_por)) from public.pedidos p where (p.estado)::text='completado' and p.created_at >= v_ms), '[]'::jsonb),
    -- SUM en vez de jsonb_agg de todos los tickets (hincha/tumba el bundle).
    'ventas_acumuladas', coalesce((select sum(p.total)::numeric from public.pedidos p where (p.estado)::text='completado'), 0),
    'ped_todos', coalesce((
      select case
        when s.t is null then '[]'::jsonb
        else jsonb_build_array(jsonb_build_object('total', s.t))
      end
      from (select sum(p.total)::numeric as t from public.pedidos p where (p.estado)::text = 'completado') s
    ), '[]'::jsonb),
    'ped_mes_ant', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where (p.estado)::text='completado' and p.created_at >= (p_ctx->>'month_prev_start')::timestamptz and p.created_at <= v_me), '[]'::jsonb),
    'citas_hoy', coalesce((select jsonb_agg(jsonb_build_object('id', c.id)) from public.citas c where c.fecha = v_hoy_local and coalesce(c.estado,'') <> 'cancelada' and ((c.estado)::text = any(array['completada','pagada']) or coalesce(c.pago_estado,'')='pagada')), '[]'::jsonb),
    'citas_ayer', coalesce((select jsonb_agg(jsonb_build_object('id', c.id)) from public.citas c where c.fecha = v_ayer_local and coalesce(c.estado,'') <> 'cancelada' and ((c.estado)::text = any(array['completada','pagada']) or coalesce(c.pago_estado,'')='pagada')), '[]'::jsonb),
    'ped_mes_tipo', coalesce((select jsonb_agg(jsonb_build_object('total', p.total,'tipo', p.tipo)) from public.pedidos p where (p.estado)::text='completado' and p.created_at >= v_ms), '[]'::jsonb),
    'ped_items_top', coalesce((
      select jsonb_agg(row_js)
      from (
        select jsonb_build_object(
          'cantidad', pi.cantidad,
          'precio_unitario', pi.precio_unitario,
          'productos', jsonb_build_object('nombre', pr.nombre)
        ) as row_js
        from public.pedido_items pi
        join public.productos pr on pr.id = pi.producto_id
        order by pi.id desc
        limit 1000
      ) q
    ), '[]'::jsonb),
    'bajo_stock', coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id,'nombre', p.nombre,'stock', p.stock,'stock_minimo', p.stock_minimo))
      from public.productos p
      where coalesce(p.activo,true) and coalesce(p.stock,0) <= 0
      order by p.nombre nulls last
      limit 5
    ), '[]'::jsonb),
    'por_caducar', coalesce((
      select jsonb_agg(jsonb_build_object('producto_id', l.producto_id))
      from public.lotes l
      where coalesce(l.activo,true)
        and coalesce(l.cantidad_actual,0) > 0
        and l.fecha_caducidad is not null
        and l.fecha_caducidad <= (current_date + interval '30 days')
      limit 200
    ), '[]'::jsonb),
    'cortes_con_dif', coalesce((
      select jsonb_agg(jsonb_build_object('id', cc.id,'diferencia', cc.diferencia))
      from public.cortes_caja cc
      where cc.diferencia is not null and cc.diferencia <> 0
      order by cc.id desc
      limit 10
    ), '[]'::jsonb),
    'ped_receta_farmax', v_receta,
    'ped_receta_farmacapital', v_receta,
    'citas_receta_ext_mes_count', (
      select count(*)::int from public.citas c
      where c.fecha >= v_inicio_mes
        and coalesce(c.receta_surtido_en,'') = 'externa'
        and coalesce(c.estado,'') <> 'cancelada'
        and ((c.estado)::text = any(array['completada','pagada']) or coalesce(c.pago_estado,'')='pagada')
    ),
    'citas_kpi_mes', coalesce((
      select jsonb_agg(jsonb_build_object(
        'medicamentos_prescritos', c.medicamentos_prescritos,
        'duracion_consulta_segundos', c.duracion_consulta_segundos
      ))
      from public.citas c
      where c.fecha >= v_inicio_mes
        and coalesce(c.estado,'') <> 'cancelada'
    ), '[]'::jsonb)
  );
end;
$$;
