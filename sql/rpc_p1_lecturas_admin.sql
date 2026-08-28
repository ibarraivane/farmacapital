-- ============================================================
-- FARMAX — P1: Lecturas admin/operación vía RPC (RLS estricto)
-- ============================================================
-- Ejecutar en Supabase DESPUÉS de:
--   refactor_fase6b_rpcs_auth.sql, rpc_p0_lecturas_tienda_pos.sql
-- ============================================================

begin;

drop function if exists public.empleado_listar_bitacora_cofepris(uuid, int);
drop function if exists public.empleado_corte_turno_hoy_existe(uuid, timestamptz, text);

-- ── Transacciones / ítems pedido ────────────────────────────────────────────

create or replace function public.empleado_listar_pedidos_transacciones(
  p_session_token uuid,
  p_created_desde timestamptz default null,
  p_created_hasta timestamptz default null,
  p_limite int default 400
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_lim int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limite, 400), 800));
  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        to_jsonb(p) ||
        jsonb_build_object(
          'clientes', jsonb_build_object('nombre', cl.nombre, 'telefono', cl.telefono),
          'usuarios', jsonb_build_object('nombre', u.nombre)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.clientes cl on cl.id = p.cliente_id
      left join public.usuarios u on u.id = p.atendido_por
      where (p_created_desde is null or p.created_at >= p_created_desde)
        and (p_created_hasta is null or p.created_at <= p_created_hasta)
      order by p.created_at desc
      limit v_lim
    ) s
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_listar_pedido_items_basico(
  p_session_token uuid,
  p_pedido_id bigint
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
      jsonb_build_object(
        'cantidad', i.cantidad,
        'precio_unitario', i.precio_unitario,
        'productos', jsonb_build_object('nombre', pr.nombre, 'sku', pr.sku)
      )
      order by i.id
    )
    from public.pedido_items i
    join public.productos pr on pr.id = i.producto_id
    where i.pedido_id = p_pedido_id
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_listar_pedido_items_detalle_transacciones(
  p_session_token uuid,
  p_pedido_id bigint
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
      to_jsonb(i) ||
      jsonb_build_object(
        'productos', jsonb_build_object('nombre', pr.nombre, 'sku', pr.sku),
        'lotes', jsonb_build_object(
          'numero_lote', lo.numero_lote,
          'fecha_caducidad', lo.fecha_caducidad
        )
      )
      order by i.id
    )
    from public.pedido_items i
    join public.productos pr on pr.id = i.producto_id
    left join public.lotes lo on lo.id = i.lote_id
    where i.pedido_id = p_pedido_id
  ), '[]'::jsonb);
end;
$$;


-- ── Mi Día (vendedor) ───────────────────────────────────────────────────────

create or replace function public.empleado_midia_snapshot(
  p_session_token uuid,
  p_empleado_id bigint,
  p_turno_start timestamptz,
  p_turno_end timestamptz,
  p_mes_start timestamptz,
  p_fecha_citas date
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
    'ped_turno', coalesce((
      select jsonb_agg(row_js order by ord)
      from (
        select
          jsonb_build_object(
            'id', p.id,
            'total', p.total,
            'cliente_id', p.cliente_id,
            'created_at', p.created_at,
            'pedido_items', coalesce(pi.js, '[]'::jsonb)
          ) as row_js,
          p.created_at as ord
        from public.pedidos p
        left join lateral (
          select jsonb_agg(
            jsonb_build_object(
              'cantidad', x.cantidad,
              'productos', jsonb_build_object(
                'nombre', pr.nombre,
                'sku', pr.sku,
                'categoria', pr.categoria
              ),
              'lotes', jsonb_build_object(
                'numero_lote', lo.numero_lote
              )
            )
            order by x.id
          ) as js
          from public.pedido_items x
          join public.productos pr on pr.id = x.producto_id
          left join public.lotes lo on lo.id = x.lote_id
          where x.pedido_id = p.id
        ) pi on true
        where p.atendido_por = p_empleado_id
          and (p.estado)::text = 'completado'
          and p.created_at >= p_turno_start
          and p.created_at <= p_turno_end
      ) q
    ), '[]'::jsonb),
    'ped_mes', coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'total', p.total, 'created_at', p.created_at) order by p.created_at)
      from public.pedidos p
      where p.atendido_por = p_empleado_id
        and (p.estado)::text = 'completado'
        and p.created_at >= p_mes_start
    ), '[]'::jsonb),
    'citas_espera', (
      select count(*)::int
      from public.citas c
      where c.fecha = p_fecha_citas
        and (c.estado)::text = 'confirmada'
    )
  );
end;
$$;


-- ── Admin: alertas barra + home dashboard pequeño ───────────────────────────

create or replace function public.empleado_admin_alertas_snapshot(
  p_session_token uuid,
  p_hoy date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_stock int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::int into v_stock
  from public.productos p
  where coalesce(p.activo, true)
    and coalesce(p.stock, 0) < coalesce(p.stock_minimo, 0);

  return jsonb_build_object(
    'stock_bajo', coalesce(v_stock, 0),
    'pend_pedidos', coalesce((
      select jsonb_agg(to_jsonb(r) order by r.created_at desc nulls last)
      from (
        select id, tipo, metodo_pago, estado, created_at
        from public.pedidos
        where (estado)::text = 'pendiente'
        order by created_at desc nulls last
        limit 400
      ) r
    ), '[]'::jsonb),
    'citas_web_hoy', (
      select count(*)::int
      from public.citas c
      where c.fecha = p_hoy
        and c.cliente_id is not null
    )
  );
end;
$$;


create or replace function public.empleado_admin_home_snapshot(
  p_session_token uuid,
  p_hoy_local date,
  p_today_start timestamptz,
  p_today_end timestamptz,
  p_week_start timestamptz,
  p_month_start timestamptz
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
    'citas_agenda_hoy', coalesce((
      select jsonb_agg(row_js order by c.hora nulls last)
      from (
        select
          jsonb_build_object(
            'id', c.id,
            'nombre', c.nombre,
            'telefono', c.telefono,
            'hora', c.hora,
            'fecha', c.fecha,
            'motivo', c.motivo,
            'estado', c.estado,
            'pago_estado', c.pago_estado,
            'consumibles_consulta', coalesce(cc.js, '[]'::jsonb)
          ) as row_js,
          c.hora
        from public.citas c
        left join lateral (
          select jsonb_agg(
            jsonb_build_object(
              'id', x.id,
              'cantidad', x.cantidad,
              'precio', x.precio,
              'cobrado', x.cobrado,
              'nombre', x.nombre,
              'producto_id', x.producto_id
            )
            order by x.id
          ) as js
          from public.consumibles_consulta x
          where x.cita_id = c.id
        ) cc on true
        where c.fecha = p_hoy_local
          and (c.estado)::text = any (array['confirmada','en_consulta','completada','pagada'])
      ) q
    ), '[]'::jsonb),
    'ventas_hoy', coalesce((
      select jsonb_agg(jsonb_build_object('total', p.total))
      from public.pedidos p
      where (p.estado)::text = 'completado'
        and p.created_at >= p_today_start
        and p.created_at <= p_today_end
    ), '[]'::jsonb),
    'ventas_semana', coalesce((
      select jsonb_agg(jsonb_build_object('total', p.total))
      from public.pedidos p
      where (p.estado)::text = 'completado'
        and p.created_at >= p_week_start
    ), '[]'::jsonb),
    'ventas_mes', coalesce((
      select jsonb_agg(jsonb_build_object('total', p.total))
      from public.pedidos p
      where (p.estado)::text = 'completado'
        and p.created_at >= p_month_start
    ), '[]'::jsonb),
    'citas_completadas_hoy', coalesce((
      select jsonb_agg(jsonb_build_object('id', c.id))
      from public.citas c
      where c.fecha = p_hoy_local
        and coalesce(c.estado, '') <> 'cancelada'
        and (
          (c.estado)::text = any (array['completada','pagada'])
          or coalesce(c.pago_estado, '') = 'pagada'
        )
    ), '[]'::jsonb)
  );
end;
$$;


-- ── Dashboard operación (bundle) ─────────────────────────────────────────────

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
    'ped_mes', coalesce((
      select jsonb_agg(jsonb_build_object(
        'total', p.total,
        'atendido_por', p.atendido_por,
        'usuarios', jsonb_build_object('nombre', u.nombre)
      ))
      from public.pedidos p
      left join public.usuarios u on u.id = p.atendido_por
      where (p.estado)::text = 'completado' and p.created_at >= v_ms
    ), '[]'::jsonb),
    'ped_todos', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where (p.estado)::text='completado'), '[]'::jsonb),
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

    'ped_receta_farmax', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where (p.estado)::text='completado' and (p.receta_origen)::text = 'medico_farmax' and p.created_at >= v_ms), '[]'::jsonb),

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


-- ── Dashboard reporte por período ─────────────────────────────────────────────

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


-- ── Clientes detalle ──────────────────────────────────────────────────────────

create or replace function public.empleado_cliente_detalle_historial(
  p_session_token uuid,
  p_cliente_id bigint,
  p_telefono text,
  p_limite_pedidos int default 25,
  p_limite_citas int default 15
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
    'pedidos', coalesce((
      select jsonb_agg(row_js order by ord desc)
      from (
        select
          to_jsonb(p) ||
          jsonb_build_object(
            'pedido_items', coalesce((
              select jsonb_agg(
                to_jsonb(i) ||
                jsonb_build_object('productos', to_jsonb(pr))
                order by i.id
              )
              from public.pedido_items i
              join public.productos pr on pr.id = i.producto_id
              where i.pedido_id = p.id
            ), '[]'::jsonb)
          ) as row_js,
          p.created_at as ord
        from public.pedidos p
        where p.cliente_id = p_cliente_id
        order by p.created_at desc
        limit greatest(1, least(coalesce(p_limite_pedidos,25), 80))
      ) s
    ), '[]'::jsonb),
    'citas', coalesce((
      select jsonb_agg(to_jsonb(c) order by c.fecha desc, c.created_at desc nulls last)
      from (
        select *
        from public.citas c
        where trim(coalesce(c.telefono,'')) = trim(coalesce(p_telefono,''))
        order by fecha desc, created_at desc nulls last
        limit greatest(1, least(coalesce(p_limite_citas,15), 50))
      ) c
    ), '[]'::jsonb)
  );
end;
$$;


-- ── Corte de caja ────────────────────────────────────────────────────────────

create or replace function public.empleado_sum_efectivo_pedidos_rango(
  p_session_token uuid,
  p_desde timestamptz,
  p_hasta timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_sum numeric;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select coalesce(sum(p.total), 0) into v_sum
  from public.pedidos p
  where (p.estado)::text = 'completado'
    and lower(trim(coalesce(p.metodo_pago,''))) in ('efectivo')
    and p.created_at >= p_desde
    and p.created_at <= p_hasta;
  return jsonb_build_object('efectivo_sistema', v_sum);
end;
$$;


create or replace function public.empleado_listar_cortes_caja(
  p_session_token uuid,
  p_limite int default 40,
  p_fecha_desde date default null,
  p_fecha_hasta date default null,
  p_turno text default null
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
    select jsonb_agg(to_jsonb(c) order by c.created_at desc nulls last)
    from (
      select *
      from public.cortes_caja c
      where (p_fecha_desde is null or (c.fecha::date) >= p_fecha_desde)
        and (p_fecha_hasta is null or (c.fecha::date) <= p_fecha_hasta)
        and (p_turno is null or p_turno = '' or p_turno = 'todos' or c.turno = p_turno)
      order by c.created_at desc nulls last
      limit greatest(1, least(coalesce(p_limite,40), 120))
    ) c
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_corte_turno_en_fecha(
  p_session_token uuid,
  p_fecha date,
  p_turno text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_id bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select cc.id into v_id
  from public.cortes_caja cc
  where cc.turno = p_turno
    and ((cc.created_at at time zone 'America/Mexico_City')::date) = p_fecha
  limit 1;
  return jsonb_build_object('existe', v_id is not null, 'id', v_id);
end;
$$;


-- ── Facturación ─────────────────────────────────────────────────────────────

create or replace function public.empleado_listar_facturas(
  p_session_token uuid,
  p_limite int default 120
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
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        to_jsonb(f) ||
        jsonb_build_object(
          'clientes', jsonb_build_object(
            'nombre', cl.nombre,
            'telefono', cl.telefono
          )
        ) as row_js,
        f.created_at as ord
      from public.facturas f
      left join public.clientes cl on cl.id = f.cliente_id
      order by f.created_at desc nulls last
      limit greatest(1, least(coalesce(p_limite,120), 400))
    ) s
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_buscar_pedidos_facturacion(
  p_session_token uuid,
  p_busqueda text,
  p_limite int default 12
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_id bigint;
  v_tel text;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_id := nullif(trim(p_busqueda), '')::bigint;
  v_tel := trim(coalesce(p_busqueda,''));

  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        to_jsonb(p) ||
        jsonb_build_object(
          'clientes', jsonb_build_object(
            'nombre', cl.nombre,
            'telefono', cl.telefono,
            'rfc', cl.rfc,
            'razon_social', cl.razon_social,
            'email', cl.email
          )
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.clientes cl on cl.id = p.cliente_id
      where (p.estado)::text = 'completado'
        and (
          (v_id is not null and p.id = v_id)
          or (v_id is null and v_tel <> '' and cl.telefono = v_tel)
        )
      order by p.created_at desc
      limit greatest(1, least(coalesce(p_limite,12), 40))
    ) s
  ), '[]'::jsonb);
end;
$$;


-- ── Devoluciones ─────────────────────────────────────────────────────────────

create or replace function public.empleado_buscar_pedidos_devolucion(
  p_session_token uuid,
  p_busqueda text,
  p_limite int default 12
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_id bigint;
  v_tel text;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_id := nullif(trim(p_busqueda), '')::bigint;
  v_tel := trim(coalesce(p_busqueda,''));

  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        to_jsonb(p) ||
        jsonb_build_object(
          'clientes', jsonb_build_object('nombre', cl.nombre, 'telefono', cl.telefono),
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.clientes cl on cl.id = p.cliente_id
      left join lateral (
        select jsonb_agg(
          jsonb_build_object(
            'id', i.id,
            'cantidad', i.cantidad,
            'precio_unitario', i.precio_unitario,
            'lote_id', i.lote_id,
            'productos', jsonb_build_object('id', pr.id, 'nombre', pr.nombre, 'stock', pr.stock)
          )
          order by i.id
        ) as js
        from public.pedido_items i
        join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
      ) pi on true
      where (p.estado)::text = 'completado'
        and (
          (v_id is not null and p.id = v_id)
          or (v_id is null and v_tel <> '' and cl.telefono = v_tel)
        )
      order by p.created_at desc
      limit greatest(1, least(coalesce(p_limite,12), 40))
    ) s
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_listar_devoluciones(
  p_session_token uuid,
  p_limite int default 200
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
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        to_jsonb(d) ||
        jsonb_build_object(
          'clientes', jsonb_build_object('nombre', cl.nombre, 'telefono', cl.telefono),
          'pedidos', jsonb_build_object('id', ped.id, 'total', ped.total),
          'devolucion_items', coalesce(di.js, '[]'::jsonb)
        ) as row_js,
        d.created_at as ord
      from public.devoluciones d
      left join public.clientes cl on cl.id = d.cliente_id
      left join public.pedidos ped on ped.id = d.pedido_id
      left join lateral (
        select jsonb_agg(
          jsonb_build_object(
            'id', x.id,
            'producto_nombre', x.producto_nombre,
            'cantidad', x.cantidad,
            'precio_unitario', x.precio_unitario
          )
          order by x.id
        ) as js
        from public.devolucion_items x
        where x.devolucion_id = d.id
      ) di on true
      order by d.created_at desc nulls last
      limit greatest(1, least(coalesce(p_limite,200), 500))
    ) s
  ), '[]'::jsonb);
end;
$$;


-- ── COFEPRIS bitácora ─────────────────────────────────────────────────────────

create or replace function public.empleado_listar_bitacora_cofepris(
  p_session_token uuid,
  p_limite int default 400,
  p_created_desde timestamptz default null,
  p_created_hasta timestamptz default null
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
    select jsonb_agg(to_jsonb(b) order by b.created_at desc nulls last)
    from (
      select *
      from public.bitacora_cofepris b
      where (p_created_desde is null or b.created_at >= p_created_desde)
        and (p_created_hasta is null or b.created_at <= p_created_hasta)
      order by b.created_at desc nulls last
      limit greatest(1, least(coalesce(p_limite,400), 800))
    ) b
  ), '[]'::jsonb);
end;
$$;


-- ── RRHH comisiones ─────────────────────────────────────────────────────────

create or replace function public.empleado_rrhh_comisiones_pedidos(
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
  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'total', p.total,
        'atendido_por', p.atendido_por,
        'usuarios', jsonb_build_object('nombre', u.nombre)
      )
      order by p.created_at desc
    )
    from public.pedidos p
    left join public.usuarios u on u.id = p.atendido_por
    where (p.estado)::text = 'completado'
      and p.created_at >= p_desde
  ), '[]'::jsonb);
end;
$$;


-- ── Lotes / proveedores ──────────────────────────────────────────────────────

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
        'productos', jsonb_build_object('nombre', pr.nombre, 'sku', pr.sku, 'categoria', pr.categoria),
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


create or replace function public.empleado_listar_productos_min_activos(
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
    select jsonb_agg(jsonb_build_object('id', p.id,'nombre', p.nombre,'sku', p.sku) order by p.nombre nulls last)
    from public.productos p
    where coalesce(p.activo,true)
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_listar_proveedores_catalogo(
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
    select jsonb_agg(jsonb_build_object('id', p.id,'nombre', p.nombre) order by p.nombre nulls last)
    from public.proveedores p
  ), '[]'::jsonb);
end;
$$;


-- Grants

grant execute on function public.empleado_listar_pedidos_transacciones(uuid, timestamptz, timestamptz, int) to anon, authenticated;
grant execute on function public.empleado_listar_pedido_items_basico(uuid, bigint) to anon, authenticated;
grant execute on function public.empleado_listar_pedido_items_detalle_transacciones(uuid, bigint) to anon, authenticated;
grant execute on function public.empleado_midia_snapshot(uuid, bigint, timestamptz, timestamptz, timestamptz, date) to anon, authenticated;
grant execute on function public.empleado_admin_alertas_snapshot(uuid, date) to anon, authenticated;
grant execute on function public.empleado_admin_home_snapshot(uuid, date, timestamptz, timestamptz, timestamptz, timestamptz) to anon, authenticated;
grant execute on function public.empleado_dashboard_operacion_bundle(uuid, jsonb) to anon, authenticated;
grant execute on function public.empleado_dashboard_reporte_bundle(uuid, timestamptz, date) to anon, authenticated;
grant execute on function public.empleado_cliente_detalle_historial(uuid, bigint, text, int, int) to anon, authenticated;
grant execute on function public.empleado_sum_efectivo_pedidos_rango(uuid, timestamptz, timestamptz) to anon, authenticated;
grant execute on function public.empleado_listar_cortes_caja(uuid, int, date, date, text) to anon, authenticated;
grant execute on function public.empleado_corte_turno_en_fecha(uuid, date, text) to anon, authenticated;
grant execute on function public.empleado_listar_facturas(uuid, int) to anon, authenticated;
grant execute on function public.empleado_buscar_pedidos_facturacion(uuid, text, int) to anon, authenticated;
grant execute on function public.empleado_buscar_pedidos_devolucion(uuid, text, int) to anon, authenticated;
grant execute on function public.empleado_listar_devoluciones(uuid, int) to anon, authenticated;
grant execute on function public.empleado_listar_bitacora_cofepris(uuid, int, timestamptz, timestamptz) to anon, authenticated;
grant execute on function public.empleado_rrhh_comisiones_pedidos(uuid, timestamptz) to anon, authenticated;
grant execute on function public.empleado_listar_lotes_inventario(uuid) to anon, authenticated;
grant execute on function public.empleado_listar_productos_min_activos(uuid) to anon, authenticated;
grant execute on function public.empleado_listar_proveedores_catalogo(uuid) to anon, authenticated;

commit;
