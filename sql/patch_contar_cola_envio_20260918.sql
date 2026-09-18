-- Badge POS / Pedidos online: también cuenta domicilio pendiente de cotizar
-- (sin exigir Mercado Pago approved). Pegar en Supabase SQL Editor.

begin;

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
    and (
      public.fn_pedido_online_pago_confirmado(p.metodo_pago, p.payment_status, p.tipo)
      or (
        p.tipo_entrega = 'envio'
        and lower(trim(coalesce(p.payment_status, ''))) is distinct from 'approved'
      )
    );
  return coalesce(v_cnt, 0);
end;
$$;

grant execute on function public.empleado_contar_pedidos_tienda_web_pendientes(uuid) to anon, authenticated;

commit;
