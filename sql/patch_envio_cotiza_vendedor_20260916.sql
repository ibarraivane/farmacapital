-- FarmaCapital — domicilio: el vendedor cotiza DiDi/Uber; el cliente paga después.
-- También: precio de tarjeta = solo 3.49%+IVA (el $4 va al cobro MP).
-- POS lista pedidos de envío pendientes aunque aún no paguen (para cotizar).
-- El badge / count de «por surtir» sigue exigiendo pago confirmado.

begin;

create or replace function public.fc_precio_online_mp(p_precio numeric)
returns numeric
language sql
immutable
set search_path = public, pg_temp
as $$
  select case
    when p_precio is null or p_precio <= 0.01 then null
    else ceil(round(p_precio / (1 - 0.040484), 2))
  end;
$$;

grant execute on function public.fc_precio_online_mp(numeric) to anon, authenticated;

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
          'logistics_meta', coalesce(p.logistics_meta, '{}'::jsonb),
          'costo_envio', p.costo_envio,
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
        and (
          public.fn_pedido_online_pago_confirmado(p.metodo_pago, p.payment_status, p.tipo)
          or (
            p.tipo_entrega = 'envio'
            and lower(trim(coalesce(p.payment_status, ''))) is distinct from 'approved'
          )
        )
      order by p.created_at desc
      limit v_lim
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_pedidos_tienda_web_pendientes(uuid, int) to anon, authenticated;

commit;

-- select public.fc_precio_online_mp(10);  -- 11
