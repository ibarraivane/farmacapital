-- FarmaCapital — POS / pedidos online: solo surtir con pago confirmado
-- Ejecutar en Supabase SQL Editor (una vez).
--
-- Problema: pedidos Mercado Pago aparecían en POS al crearse (estado pendiente)
-- antes de que el webhook marcara payment_status = approved.
--
-- Solución: filtro central fn_pedido_online_pago_confirmado + RPCs + marcar_pedido_listo.

begin;

create or replace function public.fn_pedido_online_pago_confirmado(
  p_metodo_pago text,
  p_payment_status text,
  p_tipo text default null
)
returns boolean
language plpgsql
immutable
as $$
declare
  v_metodo text := lower(trim(coalesce(p_metodo_pago, '')));
  v_status text := lower(trim(coalesce(p_payment_status, '')));
  v_tipo   text := lower(trim(coalesce(p_tipo, '')));
begin
  -- Ventas mostrador / otros tipos: no aplicar regla MP
  if v_tipo is not null and v_tipo <> '' and v_tipo <> 'online' then
    return true;
  end if;

  if v_metodo in ('mercadopago', 'tarjeta') then
    return v_status = 'approved';
  end if;

  if v_metodo = 'efectivo' then
    -- Pick-up pagando en mostrador: puede surtirse al crear el pedido
    return true;
  end if;

  -- Pedido online legacy sin metodo_pago claro
  if v_status <> '' then
    return v_status = 'approved';
  end if;

  return false;
end;
$$;

comment on function public.fn_pedido_online_pago_confirmado(text, text, text) is
  'true cuando un pedido online puede mostrarse en POS para surtir (MP/tarjeta = approved).';


create or replace function public.empleado_contar_pedidos_tienda_web_pendientes(p_session_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_cnt bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::bigint into v_cnt
  from public.pedidos p
  where p.estado = 'pendiente'
    and (
      p.tipo = 'online'
      or (
        p.tipo is null
        and lower(trim(coalesce(p.metodo_pago, ''))) = any (array['tarjeta','mercadopago'])
      )
    )
    and public.fn_pedido_online_pago_confirmado(p.metodo_pago, p.payment_status, p.tipo);
  return coalesce(v_cnt, 0);
end;
$$;


create or replace function public.empleado_listar_pedidos_tienda_web_pendientes(
  p_session_token uuid,
  p_limit int default 300
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
  v_lim := greatest(1, least(coalesce(p_limit, 300), 500));
  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        jsonb_build_object(
          'id', p.id,
          'total', p.total,
          'created_at', p.created_at,
          'tipo', p.tipo,
          'metodo_pago', p.metodo_pago,
          'estado', p.estado,
          'tipo_entrega', p.tipo_entrega,
          'direccion', p.direccion,
          'payment_provider', p.payment_provider,
          'payment_status', p.payment_status,
          'payment_id', p.payment_id,
          'paid_at', p.paid_at,
          'delivery_provider', p.delivery_provider,
          'delivery_status', p.delivery_status,
          'delivery_tracking_url', p.delivery_tracking_url,
          'guest_nombre', p.guest_nombre,
          'guest_telefono', p.guest_telefono,
          'clientes', jsonb_build_object(
            'nombre', cl.nombre,
            'telefono', cl.telefono
          ),
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.clientes cl on cl.id = p.cliente_id
      left join lateral (
        select
          jsonb_agg(
            jsonb_build_object(
              'cantidad', i.cantidad,
              'precio_unitario', i.precio_unitario,
              'productos', jsonb_build_object(
                'nombre', pr.nombre,
                'sku', pr.sku,
                'ubicacion_texto', pr.ubicacion_texto
              )
            )
            order by i.id
          ) as js
        from public.pedido_items i
        join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
      ) pi on true
      where p.estado = 'pendiente'
        and (
          p.tipo = 'online'
          or (
            p.tipo is null
            and lower(trim(coalesce(p.metodo_pago, ''))) = any (array['tarjeta','mercadopago'])
          )
        )
        and public.fn_pedido_online_pago_confirmado(p.metodo_pago, p.payment_status, p.tipo)
      order by p.created_at desc
      limit v_lim
    ) s
  ), '[]'::jsonb);
end;
$$;


-- Snapshot admin: pend_pedidos solo con pago confirmado (tienda web)
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
  v_stock bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);

  select count(*)::bigint into v_stock
  from public.productos p
  where coalesce(p.activo, true)
    and coalesce(p.stock, 0) < coalesce(p.stock_minimo, 0);

  return jsonb_build_object(
    'stock_bajo', coalesce(v_stock, 0),
    'pend_pedidos', coalesce((
      select jsonb_agg(to_jsonb(r) order by r.created_at desc nulls last)
      from (
        select id, tipo, metodo_pago, estado, payment_status, created_at
        from public.pedidos
        where (estado)::text = 'pendiente'
          and public.fn_pedido_online_pago_confirmado(metodo_pago, payment_status, tipo)
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
  v_actor_id bigint;
  v_pedido   record;
  v_item     record;
  v_consumidos int := 0;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);

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

  if v_pedido.estado = 'listo' then
    return jsonb_build_object('success', true, 'ya_listo', true);
  end if;
  if v_pedido.estado in ('cancelado','completado') then
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
            v_actor_id,
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

  update public.pedidos
     set estado = 'listo',
         atendido_por = v_actor_id,
         delivery_provider = case when v_pedido.tipo_entrega = 'recoger' then 'pickup' else delivery_provider end,
         delivery_status = case when v_pedido.tipo_entrega = 'recoger' then 'ready_for_pickup' else delivery_status end
   where id = p_pedido_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'marcar_pedido_listo', 'pedidos', p_pedido_id::text,
      jsonb_build_object('items_consumidos', v_consumidos, 'tipo_entrega', v_pedido.tipo_entrega)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'items_consumidos', v_consumidos);
end;
$$;

grant execute on function public.fn_pedido_online_pago_confirmado(text, text, text) to anon, authenticated;
grant execute on function public.empleado_contar_pedidos_tienda_web_pendientes(uuid) to anon, authenticated;
grant execute on function public.empleado_listar_pedidos_tienda_web_pendientes(uuid, int) to anon, authenticated;
grant execute on function public.empleado_admin_alertas_snapshot(uuid, date) to anon, authenticated;
grant execute on function public.marcar_pedido_listo(uuid, bigint) to anon, authenticated;

commit;
