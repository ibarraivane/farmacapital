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

commit;
