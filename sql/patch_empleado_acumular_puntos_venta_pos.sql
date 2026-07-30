-- Acreditar puntos y vincular cliente a pedido POS (empleado/cajero).
-- Ejecutar en Supabase SQL Editor una vez.

begin;

create or replace function public.empleado_acumular_puntos_venta_pos(
  p_session_token uuid,
  p_pedido_id     bigint,
  p_cliente_id    bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor   bigint;
  v_pedido  record;
  v_pts     int;
  v_total   int;
  v_credito int := 0;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  select id, cliente_id, total, coalesce(notas, '') as notas
    into v_pedido
  from public.pedidos
  where id = p_pedido_id
  for update;

  if v_pedido.id is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  if not exists (select 1 from public.clientes where id = p_cliente_id) then
    raise exception 'Cliente no encontrado';
  end if;

  if v_pedido.cliente_id is null then
    update public.pedidos set cliente_id = p_cliente_id where id = p_pedido_id;
  elsif v_pedido.cliente_id is distinct from p_cliente_id then
    update public.pedidos set cliente_id = p_cliente_id where id = p_pedido_id;
  end if;

  v_pts := greatest(0, floor(coalesce(v_pedido.total, 0) / 10));

  if v_pts > 0 and v_pedido.notas not like '%|PTS_OK|%' then
    update public.clientes
       set puntos = coalesce(puntos, 0) + v_pts
     where id = p_cliente_id;
    update public.pedidos
       set notas = trim(both from coalesce(notas, '') || ' |PTS_OK|')
     where id = p_pedido_id;
    v_credito := v_pts;
  end if;

  select coalesce(puntos, 0) into v_total from public.clientes where id = p_cliente_id;

  return jsonb_build_object(
    'success', true,
    'puntos_ganados', v_credito,
    'puntos_total', v_total
  );
end;
$$;

grant execute on function public.empleado_acumular_puntos_venta_pos(uuid, bigint, bigint)
  to anon, authenticated;

commit;
