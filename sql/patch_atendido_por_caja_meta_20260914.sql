-- ============================================================
-- Atendido_por sigue a quien tiene la caja abierta
-- 14-sep-2026. Idempotente. Pegar en Supabase SQL Editor.
--
-- Si un admin/gerente cobra con la caja de la vendedora abierta,
-- la venta cuenta para ella (Mi Día / meta), no para el admin.
-- Respeta la firma de cobro con pago mixto.
-- ============================================================

begin;

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

drop function if exists public.empleado_cobrar_venta_pos(
  uuid, text, numeric, jsonb, bigint, text, text, text, numeric
);
drop function if exists public.empleado_cobrar_venta_pos(
  uuid, text, numeric, jsonb, bigint, text, text, text, numeric, numeric, numeric
);

create or replace function public.empleado_cobrar_venta_pos(
  p_session_token uuid,
  p_metodo_pago text,
  p_total numeric,
  p_cart_items jsonb,
  p_cliente_id bigint default null,
  p_tipo text default 'pos',
  p_tipo_entrega text default null,
  p_direccion text default null,
  p_monto_credito numeric default 0,
  p_monto_efectivo numeric default null,
  p_monto_tarjeta numeric default null
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
  v_metodo text;
  v_ef numeric;
  v_tar numeric;
  v_a_cobrar numeric;
begin
  v_actor := public.fn_require_caja_abierta_vendedor(p_session_token);
  v_atendido := public.fn_atendido_por_venta(v_actor);
  v_metodo := lower(btrim(coalesce(p_metodo_pago, '')));
  if v_metodo = '' then
    raise exception 'metodo_pago es requerido';
  end if;

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

  v_a_cobrar := round(coalesce(p_total, 0) - v_cred, 2);
  v_ef := case when p_monto_efectivo is null then null else round(p_monto_efectivo, 2) end;
  v_tar := case when p_monto_tarjeta is null then null else round(p_monto_tarjeta, 2) end;

  if v_metodo = 'mixto' then
    if v_ef is null or v_tar is null then
      raise exception 'Pago mixto requiere monto_efectivo y monto_tarjeta';
    end if;
    if v_ef <= 0 or v_tar <= 0 then
      raise exception 'En mixto, efectivo y tarjeta deben ser mayores a cero';
    end if;
    if round(v_ef + v_tar, 2) <> v_a_cobrar then
      raise exception 'Mixto: efectivo (%) + tarjeta (%) debe igualar lo por cobrar (%)',
        v_ef, v_tar, v_a_cobrar;
    end if;
  elsif v_ef is not null or v_tar is not null then
    v_ef := null;
    v_tar := null;
  end if;

  select t.pedido_id, t.success
    into v_pedido_id, v_ok
    from public.create_sale_transaction_v2(
      v_atendido, v_metodo, p_total, p_cart_items,
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
  end if;

  if v_cred > 0 or v_metodo = 'mixto' then
    update public.pedidos
       set monto_credito = v_cred,
           monto_efectivo = coalesce(v_ef, 0),
           monto_tarjeta = coalesce(v_tar, 0)
     where id = v_pedido_id;
  end if;

  return query select v_pedido_id, true;
end;
$$;

grant execute on function public.create_sale_transaction_secure(uuid, text, numeric, jsonb, bigint, text, text, text) to anon, authenticated;
grant execute on function public.empleado_cobrar_venta_pos(
  uuid, text, numeric, jsonb, bigint, text, text, text, numeric, numeric, numeric
) to anon, authenticated;

commit;
