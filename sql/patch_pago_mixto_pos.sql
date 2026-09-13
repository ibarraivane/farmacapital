-- Pago mixto POS: parte efectivo + parte tarjeta en la misma venta.
-- Ejecutar en Supabase SQL Editor (o migración) antes de desplegar el front.
--
-- Qué hace:
--   1) Columnas pedidos.monto_efectivo / monto_tarjeta
--   2) Permite metodo_pago = 'mixto'
--   3) empleado_cobrar_venta_pos acepta los montos mixtos
--   4) El corte (reconcile_cash_rango) suma cada pata al cajón correcto

begin;

alter table public.pedidos
  add column if not exists monto_efectivo numeric not null default 0;

alter table public.pedidos
  add column if not exists monto_tarjeta numeric not null default 0;

comment on column public.pedidos.monto_efectivo is
  'Parte cobrada en efectivo cuando metodo_pago = mixto (o 0).';
comment on column public.pedidos.monto_tarjeta is
  'Parte cobrada con tarjeta/Point/BBVA cuando metodo_pago = mixto (o 0).';

-- Constraint de metodo_pago: soltar el check viejo e incluir mixto.
-- NOT VALID evita tumbar el patch si hay valores históricos raros;
-- las filas nuevas sí se validan.
do $$
declare
  cname text;
begin
  for cname in
    select con.conname
    from pg_constraint con
    where con.conrelid = 'public.pedidos'::regclass
      and con.contype = 'c'
      and pg_get_constraintdef(con.oid) ilike '%metodo_pago%'
  loop
    execute format('alter table public.pedidos drop constraint %I', cname);
  end loop;
end $$;

alter table public.pedidos
  add constraint chk_metodo_pago check (
    metodo_pago is null
    or lower(btrim(metodo_pago)) in (
      'efectivo',
      'tarjeta',
      'mercadopago',
      'mercadopago_point',
      'spei',
      'mixto'
    )
  ) not valid;

do $$
begin
  if not exists (
    select 1
    from public.pedidos
    where metodo_pago is not null
      and lower(btrim(metodo_pago)) not in (
        'efectivo', 'tarjeta', 'mercadopago', 'mercadopago_point', 'spei', 'mixto'
      )
  ) then
    alter table public.pedidos validate constraint chk_metodo_pago;
  end if;
exception when others then
  raise notice 'chk_metodo_pago quedó NOT VALID (hay valores históricos fuera de la lista).';
end $$;

-- Cobro POS con crédito y/o mixto (misma transacción que la venta).
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
  v_user_id bigint;
  v_pedido_id bigint;
  v_ok boolean;
  v_cred numeric;
  v_metodo text;
  v_ef numeric;
  v_tar numeric;
  v_a_cobrar numeric;
begin
  v_user_id := public.fn_require_caja_abierta_vendedor(p_session_token);
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
    -- Montos parciales solo aplican a mixto.
    v_ef := null;
    v_tar := null;
  end if;

  select t.pedido_id, t.success
    into v_pedido_id, v_ok
    from public.create_sale_transaction_v2(
      v_user_id, v_metodo, p_total, p_cart_items,
      p_cliente_id, p_tipo, p_tipo_entrega, p_direccion
    ) t;

  if not coalesce(v_ok, false) or v_pedido_id is null then
    raise exception 'No se pudo crear la venta';
  end if;

  if v_cred > 0 then
    perform public.fn_mover_credito_cliente(
      p_cliente_id, 'canjeado', v_cred, null, v_pedido_id,
      'Canje en venta #' || v_pedido_id, v_user_id
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

grant execute on function public.empleado_cobrar_venta_pos(
  uuid, text, numeric, jsonb, bigint, text, text, text, numeric, numeric, numeric
) to anon, authenticated;

-- Corte: sumar patas de ventas mixtas al efectivo y a la tarjeta.
create or replace function public.reconcile_cash_rango(
  p_inicio timestamptz,
  p_fin    timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_ef_pedidos   numeric := 0;
  v_tar_pedidos  numeric := 0;
  v_mp_pedidos   numeric := 0;
  v_spei_pedidos numeric := 0;
  v_ef_mixto     numeric := 0;
  v_tar_mixto    numeric := 0;
  v_ef_serv   numeric := 0;
  v_tar_serv  numeric := 0;
  v_dev_ef numeric := 0;
  v_dev_in numeric := 0;
  v_dev_tar numeric := 0;
  v_dev_cred numeric := 0;
begin
  if p_inicio is null or p_fin is null or p_fin <= p_inicio then
    return jsonb_build_object(
      'efectivo_sistema', 0, 'tarjeta', 0, 'mercadopago', 0, 'spei', 0,
      'efectivo_pedidos', 0, 'efectivo_servicios', 0,
      'efectivo_devoluciones', 0, 'efectivo_cambios_ingreso', 0,
      'credito_otorgado', 0, 'tarjeta_pedidos', 0, 'tarjeta_servicios', 0,
      'tarjeta_cambios', 0, 'rango_inicio', p_inicio, 'rango_fin', p_fin,
      'vacio', true
    );
  end if;

  select
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'tarjeta'),  0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago in ('mercadopago','mercadopago_point')), 0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'spei'),     0),
    coalesce(sum(coalesce(monto_efectivo, 0)) filter (where metodo_pago = 'mixto'), 0),
    coalesce(sum(coalesce(monto_tarjeta, 0)) filter (where metodo_pago = 'mixto'), 0)
  into v_ef_pedidos, v_tar_pedidos, v_mp_pedidos, v_spei_pedidos, v_ef_mixto, v_tar_mixto
  from public.pedidos
  where estado = 'completado'
    and created_at > p_inicio
    and created_at <= p_fin;

  v_ef_pedidos := v_ef_pedidos + v_ef_mixto;
  v_tar_pedidos := v_tar_pedidos + v_tar_mixto;

  select
    coalesce(sum(total_cobrado) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total_cobrado) filter (where metodo_pago = 'tarjeta'),  0)
  into v_ef_serv, v_tar_serv
  from public.pagos_servicio
  where created_at > p_inicio
    and created_at <= p_fin;

  select
    coalesce(sum(monto_efectivo), 0),
    coalesce(sum(monto_efectivo_ingreso), 0),
    coalesce(sum(monto_tarjeta_ingreso), 0),
    coalesce(sum(monto_credito), 0)
  into v_dev_ef, v_dev_in, v_dev_tar, v_dev_cred
  from public.devoluciones
  where estado = 'aprobada'
    and created_at > p_inicio
    and created_at <= p_fin;

  return jsonb_build_object(
    'efectivo_sistema',   v_ef_pedidos + v_ef_serv - v_dev_ef + v_dev_in,
    'tarjeta',            v_tar_pedidos + v_tar_serv + v_dev_tar,
    'mercadopago',        v_mp_pedidos,
    'spei',               v_spei_pedidos,
    'efectivo_pedidos',   v_ef_pedidos,
    'efectivo_servicios', v_ef_serv,
    'efectivo_devoluciones', v_dev_ef,
    'efectivo_cambios_ingreso', v_dev_in,
    'credito_otorgado',   v_dev_cred,
    'tarjeta_pedidos',    v_tar_pedidos,
    'tarjeta_servicios',  v_tar_serv,
    'tarjeta_cambios',    v_dev_tar,
    'rango_inicio',       p_inicio,
    'rango_fin',          p_fin,
    'vacio',              false
  );
end;
$$;

grant execute on function public.reconcile_cash_rango(timestamptz, timestamptz)
  to anon, authenticated;

commit;
