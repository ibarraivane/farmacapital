-- FarmaCapital — 11-sep-2026
-- Meta de vendedora en 0 aunque hay ventas: si un admin/gerente cobra con la
-- caja del turno abierta, atendido_por quedaba en el admin y Mi Día no sumaba.
-- Idempotente. Pegar en Supabase SQL Editor.

begin;

-- Quién “dueño” de la venta para meta / comisiones:
-- si hay caja abierta, cuenta para esa persona; si no, para quien cobró.
create or replace function public.fn_atendido_por_venta(p_actor_id bigint)
returns bigint
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_caja bigint;
begin
  select s.empleado_id
    into v_caja
  from public.caja_sesiones s
  where s.estado = 'abierta'
  order by s.abierta_at desc nulls last, s.id desc
  limit 1;

  if v_caja is not null then
    return v_caja;
  end if;
  return p_actor_id;
end;
$$;

grant execute on function public.fn_atendido_por_venta(bigint) to anon, authenticated;

create or replace function public.create_sale_transaction_secure(
  p_session_token uuid,
  p_metodo_pago   text,
  p_total         numeric,
  p_cart_items    jsonb,
  p_cliente_id    bigint default null,
  p_tipo          text   default 'pos',
  p_tipo_entrega  text   default null,
  p_direccion     text   default null
)
returns table(pedido_id bigint, success boolean)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_atendido bigint;
begin
  v_actor := public.fn_require_caja_abierta_vendedor(p_session_token);
  v_atendido := public.fn_atendido_por_venta(v_actor);
  return query
  select * from public.create_sale_transaction_v2(
    v_atendido, p_metodo_pago, p_total, p_cart_items,
    p_cliente_id, p_tipo, p_tipo_entrega, p_direccion
  );
end;
$$;

create or replace function public.empleado_cobrar_venta_pos(
  p_session_token uuid,
  p_metodo_pago text,
  p_total numeric,
  p_cart_items jsonb,
  p_cliente_id bigint default null,
  p_tipo text default 'pos',
  p_tipo_entrega text default null,
  p_direccion text default null,
  p_monto_credito numeric default 0
)
returns table(pedido_id bigint, success boolean)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_atendido bigint;
  v_pedido_id bigint;
  v_ok boolean;
  v_cred numeric;
begin
  v_actor := public.fn_require_caja_abierta_vendedor(p_session_token);
  v_atendido := public.fn_atendido_por_venta(v_actor);
  v_cred := round(coalesce(p_monto_credito, 0), 2);
  if v_cred < 0 then
    raise exception 'Crédito inválido';
  end if;
  if v_cred > 0 and p_cliente_id is null then
    raise exception 'Identifica al cliente para usar su crédito';
  end if;
  if v_cred > round(coalesce(p_total, 0), 2) then
    raise exception 'El crédito no puede ser mayor al total';
  end if;

  select t.pedido_id, t.success
    into v_pedido_id, v_ok
    from public.create_sale_transaction_v2(
      v_atendido, p_metodo_pago, p_total, p_cart_items,
      p_cliente_id, p_tipo, p_tipo_entrega, p_direccion
    ) t;

  if not coalesce(v_ok, false) or v_pedido_id is null then
    raise exception 'No se pudo crear la venta';
  end if;

  if v_cred > 0 then
    perform public.fn_mover_credito_cliente(
      p_cliente_id, 'canjeado', v_cred, null, v_pedido_id,
      'Canje en venta #' || v_pedido_id, v_atendido
    );
    update public.pedidos
       set monto_credito = v_cred
     where id = v_pedido_id;
  end if;

  return query select v_pedido_id, true;
end;
$$;

-- Mi Día: siempre el empleado del token (no confiar en p_empleado_id del cliente).
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
begin
  v_actor := public.fn_require_empleado(p_session_token);
  -- Admins pueden consultar a otra persona; vendedor solo a sí mismo.
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
        where p.atendido_por = v_actor
          and (p.estado)::text = 'completado'
          and p.created_at >= p_turno_start
          and p.created_at <= p_turno_end
      ) q
    ), '[]'::jsonb),
    'ped_mes', coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'total', p.total, 'created_at', p.created_at) order by p.created_at)
      from public.pedidos p
      where p.atendido_por = v_actor
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

grant execute on function public.empleado_midia_snapshot(uuid, bigint, timestamptz, timestamptz, timestamptz, date)
  to anon, authenticated;

commit;

-- ── Diagnóstico de hoy (solo lectura) ─────────────────────────
-- select p.id, p.total, p.estado,
--        (p.created_at at time zone 'America/Mexico_City') as hora_cdmx,
--        p.atendido_por, u.nombre as vendedor
-- from public.pedidos p
-- left join public.usuarios u on u.id = p.atendido_por
-- where ((p.created_at at time zone 'America/Mexico_City')::date)
--         = (now() at time zone 'America/Mexico_City')::date
-- order by p.created_at;
--
-- Si el vendedor está mal, reasigna desde Transacciones (columna Vendedor)
-- o con admin_actualizar_pedido_atendido_por.
