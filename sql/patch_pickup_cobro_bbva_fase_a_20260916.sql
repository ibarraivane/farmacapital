-- FarmaCapital — Fase (a) métodos de pago: cobro pickup con terminal BBVA
-- Ejecutar en Supabase SQL Editor tras fase (b):
--   sql/patch_pickup_pendiente_tienda_fase_b_20260916.sql
--
-- Actualiza EL MISMO pedido online (no crea venta mostrador).
-- Acredita puntos vía service_acreditar_puntos_pedido (idempotente).

begin;

create or replace function public.empleado_cobrar_pedido_online_bbva(
  p_session_token uuid,
  p_pedido_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_pedido   record;
  v_pts      jsonb;
  v_payload  jsonb;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);

  if p_pedido_id is null then
    raise exception 'pedido_id requerido';
  end if;

  select id, tipo, tipo_entrega, estado, metodo_pago, payment_status,
         payment_provider, total, cliente_id
    into v_pedido
  from public.pedidos
  where id = p_pedido_id
  for update;

  if v_pedido.id is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  if coalesce(v_pedido.tipo, '') <> 'online' then
    raise exception 'Solo pedidos online';
  end if;

  if coalesce(v_pedido.tipo_entrega, '') <> 'recoger' then
    raise exception 'Solo pick-up se cobra con BBVA en este flujo';
  end if;

  if v_pedido.estado not in ('pendiente', 'listo') then
    raise exception 'No se puede cobrar un pedido en estado: %', v_pedido.estado;
  end if;

  -- Idempotente: ya cobrado BBVA
  if lower(trim(coalesce(v_pedido.payment_status, ''))) = 'approved'
     and lower(trim(coalesce(v_pedido.payment_provider, ''))) = 'bbva' then
    return jsonb_build_object(
      'success', true,
      'already', true,
      'pedido_id', v_pedido.id,
      'total', v_pedido.total
    );
  end if;

  if lower(trim(coalesce(v_pedido.metodo_pago, ''))) not in ('pendiente_tienda', 'efectivo')
     and lower(trim(coalesce(v_pedido.payment_status, ''))) <> 'pending_store' then
    raise exception 'Este pedido no está pendiente de cobro en tienda';
  end if;

  v_payload := jsonb_build_object(
    'terminal', 'bbva',
    'confirmed_by', v_actor_id,
    'confirmed_at', now(),
    'folio', 'PED-' || v_pedido.id::text
  );

  update public.pedidos
     set metodo_pago = 'tarjeta',
         payment_provider = 'bbva',
         payment_status = 'approved',
         paid_at = now(),
         payment_payload = coalesce(payment_payload, '{}'::jsonb) || v_payload,
         monto_tarjeta = coalesce(total, 0)
   where id = v_pedido.id;

  begin
    v_pts := public.service_acreditar_puntos_pedido(v_pedido.id);
  exception when others then
    v_pts := jsonb_build_object('ok', false, 'error', SQLERRM);
  end;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'cobrar_pedido_online_bbva', 'pedidos', v_pedido.id::text,
      jsonb_build_object('total', v_pedido.total, 'puntos', v_pts)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'pedido_id', v_pedido.id,
    'total', v_pedido.total,
    'payment_status', 'approved',
    'payment_provider', 'bbva',
    'puntos', v_pts
  );
end;
$$;

grant execute on function public.empleado_cobrar_pedido_online_bbva(uuid, bigint) to anon, authenticated;

comment on function public.empleado_cobrar_pedido_online_bbva(uuid, bigint) is
  'Confirma cobro BBVA de pickup online pendiente_tienda → approved. No crea venta nueva.';

-- Historial: incluir payment_* para mostrar «Cobrar BBVA» en listo pendiente
create or replace function public.empleado_listar_pedidos_online_historial(
  p_session_token uuid,
  p_limite int default 40
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
  v_lim := greatest(1, least(coalesce(p_limite, 40), 200));
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
          'paid_at', p.paid_at,
          'guest_nombre', p.guest_nombre,
          'guest_telefono', p.guest_telefono,
          'delivery_tracking_url', p.delivery_tracking_url,
          'logistics_meta', coalesce(p.logistics_meta, '{}'::jsonb),
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
      where p.tipo = 'online'
        and (p.estado)::text = any (array['listo','completado'])
      order by p.created_at desc
      limit v_lim
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_pedidos_online_historial(uuid, int) to anon, authenticated;

commit;
