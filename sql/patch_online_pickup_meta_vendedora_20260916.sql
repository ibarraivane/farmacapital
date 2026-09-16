-- ============================================================
-- Online pick-up → meta de la vendedora
-- 16-sep-2026. Idempotente. Pegar en Supabase SQL Editor.
--
-- Problema:
--   Al surtir un pedido online de recoger quedaba en estado 'listo'.
--   Mi Día / dashboard / comisiones solo suman 'completado', así que
--   la venta no entraba a metas de nadie. Además atendido_por era
--   quien dio clic (a veces admin), no quien tiene la caja abierta.
--
-- Solución:
--   1) Pick-up surtido → estado completado (sigue listo para el cliente
--      vía delivery_status = ready_for_pickup).
--   2) atendido_por = fn_atendido_por_venta (caja abierta).
--   3) atendido_at = momento del surtido, para que cuente en el turno
--      aunque el cliente haya pedido anoche.
--   4) Backfill de pick-ups ya surtidos en 'listo'.
-- ============================================================

begin;

alter table public.pedidos
  add column if not exists atendido_at timestamptz;

comment on column public.pedidos.atendido_at is
  'Momento en que se atribuyó la venta (surtido online / cobro POS). Para metas de turno.';

create or replace function public.marcar_pedido_listo(
  p_session_token uuid,
  p_pedido_id     bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id     bigint;
  v_atendido_id  bigint;
  v_pedido       record;
  v_item         record;
  v_consumidos   int := 0;
  v_nuevo_estado text;
  v_es_pickup    boolean;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  v_atendido_id := public.fn_atendido_por_venta(v_actor_id);

  select id, estado, tipo, tipo_entrega, cliente_id, metodo_pago, payment_status
    into v_pedido
  from public.pedidos where id = p_pedido_id;

  if v_pedido.id is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  if coalesce(v_pedido.tipo, '') = 'online'
     and not public.fn_pedido_online_pago_confirmado(v_pedido.metodo_pago, v_pedido.payment_status, v_pedido.tipo) then
    raise exception 'Pago no confirmado. Espera la aprobación de Mercado Pago antes de surtir.';
  end if;

  if v_pedido.estado in ('listo', 'completado') then
    -- Idempotente: si ya estaba listo/completado pero sin vendedora, repara atribución.
    update public.pedidos
       set atendido_por = coalesce(atendido_por, v_atendido_id),
           atendido_at = coalesce(atendido_at, now()),
           estado = case
             when coalesce(tipo_entrega, '') = 'recoger' and estado = 'listo' then 'completado'
             else estado
           end,
           delivery_provider = case
             when coalesce(tipo_entrega, '') = 'recoger' then coalesce(delivery_provider, 'pickup')
             else delivery_provider
           end,
           delivery_status = case
             when coalesce(tipo_entrega, '') = 'recoger' then coalesce(delivery_status, 'ready_for_pickup')
             else delivery_status
           end
     where id = p_pedido_id
       and (
         atendido_por is null
         or atendido_at is null
         or (coalesce(tipo_entrega, '') = 'recoger' and estado = 'listo')
       );
    return jsonb_build_object('success', true, 'ya_listo', true);
  end if;

  if v_pedido.estado = 'cancelado' then
    raise exception 'No se puede marcar listo un pedido en estado: %', v_pedido.estado;
  end if;

  for v_item in
    select id, producto_id, cantidad, lote_id
    from public.pedido_items where pedido_id = p_pedido_id
  loop
    if v_item.producto_id is not null and coalesce(v_item.cantidad, 0) > 0 then
      if v_item.lote_id is null then
        begin
          perform public.consume_stock_via_lotes(
            v_item.producto_id,
            v_item.cantidad::integer,
            'Pedido listo #' || p_pedido_id,
            v_atendido_id,
            'pedido_listo:' || p_pedido_id::text
          );
          v_consumidos := v_consumidos + 1;
        exception when others then
          raise exception 'Error al consumir stock de producto %: %', v_item.producto_id, SQLERRM;
        end;
      end if;
    end if;
  end loop;

  begin
    perform public.release_stock_reservation(p_pedido_id);
  exception when others then null;
  end;

  v_es_pickup := coalesce(v_pedido.tipo_entrega, '') = 'recoger';
  -- Pick-up: stock ya salió y el pago está confirmado → cuenta en metas.
  -- Envío: sigue 'listo' hasta delivered (webhook Uber / cierre manual).
  v_nuevo_estado := case when v_es_pickup then 'completado' else 'listo' end;

  update public.pedidos
     set estado = v_nuevo_estado,
         atendido_por = v_atendido_id,
         atendido_at = now(),
         delivery_provider = case when v_es_pickup then 'pickup' else delivery_provider end,
         delivery_status = case when v_es_pickup then 'ready_for_pickup' else delivery_status end
   where id = p_pedido_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'marcar_pedido_listo', 'pedidos', p_pedido_id::text,
      jsonb_build_object(
        'items_consumidos', v_consumidos,
        'tipo_entrega', v_pedido.tipo_entrega,
        'estado', v_nuevo_estado,
        'atendido_por', v_atendido_id
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'items_consumidos', v_consumidos,
    'estado', v_nuevo_estado,
    'atendido_por', v_atendido_id
  );
end;
$$;

grant execute on function public.marcar_pedido_listo(uuid, bigint) to anon, authenticated;

-- Mi Día: ventana de turno/mes con atendido_at (surtido) cuando existe.
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
  v_actor bigint;
  v_hoy date := (now() at time zone 'America/Mexico_City')::date;
begin
  v_actor := public.fn_require_empleado(p_session_token);
  if exists (
    select 1 from public.usuarios u
    where u.id = v_actor and lower(coalesce(u.rol, '')) in ('admin', 'gerente')
  ) and p_empleado_id is not null then
    v_actor := p_empleado_id;
  end if;

  return jsonb_build_object(
    'ped_turno', coalesce((
      select jsonb_agg(row_js order by ord)
      from (
        select
          jsonb_build_object(
            'id', p.id,
            'total', p.total,
            'metodo_pago', p.metodo_pago,
            'cliente_id', p.cliente_id,
            'created_at', p.created_at,
            'atendido_at', p.atendido_at,
            'tipo', p.tipo,
            'pedido_items', coalesce(pi.js, '[]'::jsonb)
          ) as row_js,
          coalesce(p.atendido_at, p.created_at) as ord
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
        -- completado = venta cerrada; listo+online = envío ya surtido (aún no delivered)
        where (
            (p.estado)::text = 'completado'
            or (
              (p.estado)::text = 'listo'
              and (p.tipo)::text = 'online'
              and p.atendido_por is not null
            )
          )
          and (
            (
              p.atendido_por = v_actor
              and coalesce(p.atendido_at, p.created_at) >= p_turno_start
              and coalesce(p.atendido_at, p.created_at) <= p_turno_end
            )
            or exists (
              select 1
              from public.caja_sesiones s
              where s.empleado_id = v_actor
                and s.fecha = v_hoy
                and p.created_at >= s.abierta_at
                and p.created_at <= coalesce(s.cerrada_at, p_turno_end, now())
            )
          )
      ) q
    ), '[]'::jsonb),
    'ped_mes', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', p.id,
          'total', p.total,
          'created_at', p.created_at,
          'atendido_at', p.atendido_at
        )
        order by coalesce(p.atendido_at, p.created_at)
      )
      from public.pedidos p
      where (
          (p.estado)::text = 'completado'
          or (
            (p.estado)::text = 'listo'
            and (p.tipo)::text = 'online'
            and p.atendido_por is not null
          )
        )
        and coalesce(p.atendido_at, p.created_at) >= p_mes_start
        and (
          p.atendido_por = v_actor
          or exists (
            select 1
            from public.caja_sesiones s
            where s.empleado_id = v_actor
              and p.created_at >= s.abierta_at
              and p.created_at <= coalesce(s.cerrada_at, now())
          )
        )
    ), '[]'::jsonb),
    'srv_turno', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', ps.id,
          'total_cobrado', ps.total_cobrado,
          'monto_servicio', ps.monto_servicio,
          'categoria', ps.categoria,
          'proveedor', ps.proveedor,
          'folio', ps.folio,
          'metodo_pago', ps.metodo_pago,
          'comision', ps.comision,
          'referencia', ps.referencia,
          'created_at', ps.created_at
        )
        order by ps.created_at
      )
      from public.pagos_servicio ps
      where ps.atendido_por = v_actor
        and ps.created_at >= p_turno_start
        and ps.created_at <= p_turno_end
    ), '[]'::jsonb),
    'srv_mes', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', ps.id,
          'total_cobrado', ps.total_cobrado,
          'monto_servicio', ps.monto_servicio,
          'categoria', ps.categoria,
          'proveedor', ps.proveedor,
          'folio', ps.folio,
          'created_at', ps.created_at
        )
        order by ps.created_at
      )
      from public.pagos_servicio ps
      where ps.atendido_por = v_actor
        and ps.created_at >= p_mes_start
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

grant execute on function public.empleado_midia_snapshot(uuid, bigint, timestamptz, timestamptz, timestamptz, date) to anon, authenticated;

-- Comisiones RRHH: mismos criterios (online listo surtido cuenta).
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
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        jsonb_build_object(
          'total', p.total,
          'atendido_por', p.atendido_por,
          'usuarios', jsonb_build_object('nombre', u.nombre),
          'fuente', 'pedido',
          'created_at', coalesce(p.atendido_at, p.created_at)
        ) as row_js,
        coalesce(p.atendido_at, p.created_at) as ord
      from public.pedidos p
      left join public.usuarios u on u.id = p.atendido_por
      where (
          (p.estado)::text = 'completado'
          or (
            (p.estado)::text = 'listo'
            and (p.tipo)::text = 'online'
            and p.atendido_por is not null
          )
        )
        and coalesce(p.atendido_at, p.created_at) >= p_desde

      union all

      select
        jsonb_build_object(
          'total', ps.total_cobrado,
          'atendido_por', ps.atendido_por,
          'usuarios', jsonb_build_object('nombre', u2.nombre),
          'fuente', 'servicio',
          'created_at', ps.created_at
        ) as row_js,
        ps.created_at as ord
      from public.pagos_servicio ps
      left join public.usuarios u2 on u2.id = ps.atendido_por
      where ps.created_at >= p_desde
    ) q
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_rrhh_comisiones_pedidos(uuid, timestamptz) to anon, authenticated;

-- Backfill: pick-ups online ya surtidos que nunca pasaron a completado.
update public.pedidos p
   set estado = 'completado',
       delivery_provider = coalesce(p.delivery_provider, 'pickup'),
       delivery_status = coalesce(p.delivery_status, 'ready_for_pickup'),
       atendido_at = coalesce(
         p.atendido_at,
         (
           select a.created_at
           from public.audit_log a
           where a.accion = 'marcar_pedido_listo'
             and a.tabla = 'pedidos'
             and a.registro_id = p.id::text
           order by a.created_at desc nulls last
           limit 1
         ),
         p.created_at
       )
 where (p.tipo)::text = 'online'
   and coalesce(p.tipo_entrega, '') = 'recoger'
   and (p.estado)::text = 'listo';

-- Backfill atendido_at en pedidos ya atribuidos (POS u online).
update public.pedidos p
   set atendido_at = coalesce(
     (
       select a.created_at
       from public.audit_log a
       where a.accion = 'marcar_pedido_listo'
         and a.tabla = 'pedidos'
         and a.registro_id = p.id::text
       order by a.created_at desc nulls last
       limit 1
     ),
     p.created_at
   )
 where p.atendido_por is not null
   and p.atendido_at is null
   and (p.estado)::text = 'completado';

-- ── Dashboard: misma regla de “qué cuenta como venta” ───────────────────────
-- Helper: completado, o online ya surtido (listo) con vendedora.
create or replace function public.fn_pedido_cuenta_en_ventas(
  p_estado text,
  p_tipo text,
  p_atendido_por bigint
)
returns boolean
language sql
immutable
as $$
  select
    (p_estado)::text = 'completado'
    or (
      (p_estado)::text = 'listo'
      and (p_tipo)::text = 'online'
      and p_atendido_por is not null
    );
$$;

comment on function public.fn_pedido_cuenta_en_ventas(text, text, bigint) is
  'True si el pedido debe sumar en dashboard / metas (completado, o online surtido en listo).';

grant execute on function public.fn_pedido_cuenta_en_ventas(text, text, bigint) to anon, authenticated;

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

    'ped_hoy', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por) and p.created_at >= v_ts and p.created_at <= v_te), '[]'::jsonb),
    'ped_ayer', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por) and p.created_at >= v_ys and p.created_at <= v_ye), '[]'::jsonb),
    'ped_semana', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por) and p.created_at >= v_ws), '[]'::jsonb),
    'ped_semana_ant', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por) and p.created_at >= v_ps and p.created_at <= v_pe), '[]'::jsonb),
    'ped_mes', coalesce((
      select jsonb_agg(jsonb_build_object(
        'total', p.total,
        'atendido_por', p.atendido_por,
        'usuarios', jsonb_build_object('nombre', u.nombre)
      ))
      from public.pedidos p
      left join public.usuarios u on u.id = p.atendido_por
      where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por) and p.created_at >= v_ms
    ), '[]'::jsonb),
    'ventas_acumuladas', coalesce((select sum(p.total)::numeric from public.pedidos p where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por)), 0),
    'ped_todos', coalesce((
      select case
        when s.t is null then '[]'::jsonb
        else jsonb_build_array(jsonb_build_object('total', s.t))
      end
      from (select sum(p.total)::numeric as t from public.pedidos p where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por)) s
    ), '[]'::jsonb),
    'ped_mes_ant', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por) and p.created_at >= (p_ctx->>'month_prev_start')::timestamptz and p.created_at <= v_me), '[]'::jsonb),

    'citas_hoy', coalesce((select jsonb_agg(jsonb_build_object('id', c.id)) from public.citas c where c.fecha = v_hoy_local and coalesce(c.estado,'') <> 'cancelada' and ((c.estado)::text = any(array['completada','pagada']) or coalesce(c.pago_estado,'')='pagada')), '[]'::jsonb),
    'citas_ayer', coalesce((select jsonb_agg(jsonb_build_object('id', c.id)) from public.citas c where c.fecha = v_ayer_local and coalesce(c.estado,'') <> 'cancelada' and ((c.estado)::text = any(array['completada','pagada']) or coalesce(c.pago_estado,'')='pagada')), '[]'::jsonb),

    -- Aquí se arma “Tienda online” vs “Farmacia física”
    'ped_mes_tipo', coalesce((select jsonb_agg(jsonb_build_object('total', p.total,'tipo', p.tipo)) from public.pedidos p where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por) and p.created_at >= v_ms), '[]'::jsonb),

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

    'ped_receta_farmax', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por) and (p.receta_origen)::text = 'medico_farmax' and p.created_at >= v_ms), '[]'::jsonb),

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

grant execute on function public.empleado_dashboard_operacion_bundle(uuid, jsonb) to anon, authenticated;

-- Reporte: cubeta ponl (online) también con listo surtido.
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
      where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por)
        and p.created_at >= p_desde
    ), '[]'::jsonb),
    'cons', coalesce((
      select jsonb_agg(jsonb_build_object('id', c.id))
      from public.citas c
      where c.fecha >= p_desde_fecha
        and coalesce(c.estado,'') <> 'cancelada'
        and ((c.estado)::text = any(array['completada','pagada']) or coalesce(c.pago_estado,'')='pagada')
    ), '[]'::jsonb),
    'ponl', coalesce((
      select jsonb_agg(jsonb_build_object('total', p.total))
      from public.pedidos p
      where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por)
        and (p.tipo)::text = 'online'
        and p.created_at >= p_desde
    ), '[]'::jsonb),
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
      where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por)
        and p.created_at >= p_desde
    ), '[]'::jsonb),
    'peds_receta_farmax', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por) and (p.receta_origen)::text='medico_farmax' and p.created_at >= p_desde), '[]'::jsonb),
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

-- ── Diagnóstico pedido #335 (MP FARMACAPITAL-PED-335) ───────────────────────
-- Ejecutar aparte si quieres ver el estado actual:
--   select id, tipo, estado, tipo_entrega, payment_status, atendido_por, total, created_at
--   from public.pedidos where id = 335;

commit;
