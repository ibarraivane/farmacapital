-- Guarda el ticket completo al eliminar un pedido (para poder restaurarlo).
-- Corre en Supabase → SQL Editor → Run. Sin esto, Eliminar solo deja
-- "se reintegró N ítems" y hay que reconstruir a ciegas desde el kardex.

create or replace function public.admin_eliminar_pedido(
  p_session_token uuid,
  p_pedido_id     bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id    bigint;
  v_item        record;
  v_cnt         int := 0;
  v_pedido_snap jsonb;
  v_items_snap  jsonb;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if not exists (select 1 from public.pedidos where id = p_pedido_id) then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  select to_jsonb(p.*) into v_pedido_snap
  from public.pedidos p
  where p.id = p_pedido_id;

  select coalesce(jsonb_agg(to_jsonb(i.*) order by i.id), '[]'::jsonb)
    into v_items_snap
  from public.pedido_items i
  where i.pedido_id = p_pedido_id;

  for v_item in
    select producto_id, cantidad, lote_id
    from public.pedido_items
    where pedido_id = p_pedido_id
  loop
    if v_item.producto_id is not null and coalesce(v_item.cantidad, 0) > 0 then
      begin
        perform public.restock_via_lote(
          v_item.producto_id,
          v_item.cantidad,
          'Reintegro por eliminación de pedido #' || p_pedido_id,
          v_actor_id,
          v_item.lote_id
        );
      exception when others then
        raise notice 'restock_via_lote falló para producto %: %', v_item.producto_id, SQLERRM;
      end;
      v_cnt := v_cnt + 1;
    end if;
  end loop;

  delete from public.pedido_items where pedido_id = p_pedido_id;
  delete from public.pedidos where id = p_pedido_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'eliminar_pedido', 'pedidos', p_pedido_id::text,
      jsonb_build_object(
        'items_restaurados', v_cnt,
        'pedido', v_pedido_snap,
        'items', v_items_snap
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'items_restaurados', v_cnt);
end;
$$;

grant execute on function public.admin_eliminar_pedido(uuid, bigint)
  to anon, authenticated, service_role;
