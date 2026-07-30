-- Al marcar listo un pedido pick-up, actualiza delivery_status sin UPDATE directo desde el cliente.
-- Ejecutar en Supabase SQL Editor una vez.

begin;

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

  select id, estado, tipo, tipo_entrega, cliente_id into v_pedido
  from public.pedidos where id = p_pedido_id;

  if v_pedido.id is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
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

grant execute on function public.marcar_pedido_listo(uuid, bigint) to anon, authenticated;

commit;
