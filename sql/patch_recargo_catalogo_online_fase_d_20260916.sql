-- FarmaCapital — Fase (d) métodos de pago: RECARGO_CATALOGO_ONLINE = 8%
-- Ejecutar tras fases (b) y (c).
-- Recargo solo domicilio/prepago MP. Pickup sin recargo.
-- pedido_items.precio_unitario = precio base/oferta (SIN recargo).
-- pedidos.total envío = monto con recargo (fee envío se suma después en attach).
-- Constante 0.08 alineada a REACT_APP_RECARGO_CATALOGO_ONLINE.

begin;

alter table public.pedidos
  add column if not exists subtotal_productos numeric,
  add column if not exists recargo_procesamiento_pago numeric not null default 0,
  add column if not exists monto_cobrado_mercadopago numeric;

comment on column public.pedidos.subtotal_productos is
  'Suma de precio base/oferta × qty (sin recargo MP). Snapshot al crear pedido online.';
comment on column public.pedidos.recargo_procesamiento_pago is
  'Diferencia cobrada vs subtotal para canal MP (interno; no mostrar al cliente como comisión).';
comment on column public.pedidos.monto_cobrado_mercadopago is
  'Monto de productos cobrado vía MP (subtotal + recargo). 0 en pickup.';

create or replace function public.precio_cobro_online(p_producto_id bigint)
returns numeric
language plpgsql
stable
security invoker
set search_path = public, pg_temp
as $$
declare
  v_base numeric;
  v_factor numeric := 0.08;
begin
  begin
    v_base := public.precio_oferta_publico(p_producto_id);
  exception when undefined_function then
    select coalesce(precio, 0) into v_base from public.productos where id = p_producto_id;
  end;
  if coalesce(v_base, 0) <= 0 then
    return 0;
  end if;
  return round(v_base * (1 + v_factor), 2);
end;
$$;

grant execute on function public.precio_cobro_online(bigint) to anon, authenticated;

create or replace function public.cliente_crear_pedido_online(
  p_session_token          uuid,
  p_cart                   jsonb,
  p_metodo_pago            text,
  p_tipo_entrega           text default 'recoger',
  p_direccion              text default null,
  p_guest_nombre           text default null,
  p_guest_telefono         text default null,
  p_guest_email            text default null,
  p_reservation_session_id text default null,
  p_whatsapp_recibo        boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli_id       bigint;
  v_pedido_id    bigint;
  v_item         jsonb;
  v_pid          bigint;
  v_qty          numeric;
  v_prod         record;
  v_total        numeric := 0;
  v_puntos_ganados int := 0;
  v_telefono_norm text;
  v_n_items      int := 0;
  v_sum_lotes    integer;
  v_stock_eff    integer;
  v_precio_line  numeric;
  v_precio_cobro numeric;
  v_metodo       text;
  v_es_pickup    boolean;
  v_subtotal     numeric := 0;
  v_recargo      numeric := 0;
  v_factor_recargo numeric := 0.08; -- RECARGO_CATALOGO_ONLINE; alinear con env REACT_APP_RECARGO_CATALOGO_ONLINE
  v_monto_mp     numeric := 0;
begin
  if p_session_token is not null then
    v_cli_id := public.fn_validar_token_cliente(p_session_token);
    if v_cli_id is null then
      raise exception 'Sesión cliente inválida' using errcode = '28000';
    end if;
  else
    if p_guest_telefono is null or length(trim(p_guest_telefono))=0 then
      raise exception 'Teléfono requerido para checkout sin cuenta';
    end if;
    if p_guest_nombre is null or length(trim(p_guest_nombre))=0 then
      raise exception 'Nombre requerido para checkout sin cuenta';
    end if;

    v_telefono_norm := trim(p_guest_telefono);

    select id into v_cli_id from public.clientes where telefono = v_telefono_norm limit 1;

    if v_cli_id is null then
      insert into public.clientes (nombre, telefono, email, puntos)
      values (trim(p_guest_nombre), v_telefono_norm,
              nullif(trim(coalesce(p_guest_email,'')),''), 0)
      returning id into v_cli_id;
    end if;
  end if;

  if jsonb_array_length(coalesce(p_cart,'[]'::jsonb)) = 0 then
    raise exception 'Carrito vacío';
  end if;

  if p_tipo_entrega not in ('recoger','envio') then
    raise exception 'Tipo de entrega inválido';
  end if;
  if p_tipo_entrega = 'envio' and (p_direccion is null or length(trim(p_direccion))=0) then
    raise exception 'Dirección requerida para envío';
  end if;

  v_es_pickup := p_tipo_entrega = 'recoger';

  if v_es_pickup then
    v_metodo := 'pendiente_tienda';
  else
    if coalesce(p_metodo_pago, '') not in ('tarjeta','mercadopago','efectivo') then
      raise exception 'Método de pago inválido';
    end if;
    v_metodo := p_metodo_pago;
  end if;

  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item->>'producto_id')::bigint;
    v_qty := (v_item->>'cantidad')::numeric;
    if v_qty is null or v_qty <= 0 then
      raise exception 'Cantidad inválida para producto %', v_pid;
    end if;

    select id, precio, activo, stock, nombre, controlado
    into v_prod from public.productos where id = v_pid;

    if v_prod.id is null then
      raise exception 'Producto % no existe', v_pid;
    end if;
    if not coalesce(v_prod.activo, false) then
      raise exception 'Producto "%" no está disponible', v_prod.nombre;
    end if;
    if coalesce(v_prod.controlado, false) then
      raise exception 'El producto "%" es controlado y solo se vende en mostrador',
                      v_prod.nombre;
    end if;

    select coalesce(sum(l.cantidad_actual), 0)::integer
      into v_sum_lotes
      from public.lotes l
      where l.producto_id = v_pid
        and coalesce(l.activo, true);

    v_stock_eff := greatest(coalesce(v_prod.stock, 0), coalesce(v_sum_lotes, 0));

    if v_stock_eff < v_qty then
      raise exception 'Stock insuficiente para "%": disponible=%, solicitado=%',
                      v_prod.nombre, v_stock_eff, v_qty;
    end if;

    begin
      v_precio_line := public.precio_oferta_publico(v_pid);
    exception when undefined_function then
      v_precio_line := coalesce(v_prod.precio, 0);
    end;

    if coalesce(v_precio_line, 0) <= 0.01 then
      raise exception 'Producto "%" aún no tiene precio de venta', v_prod.nombre;
    end if;

    v_subtotal := v_subtotal + (v_precio_line * v_qty);
    if v_es_pickup then
      v_precio_cobro := v_precio_line;
    else
      v_precio_cobro := round(v_precio_line * (1 + v_factor_recargo), 2);
    end if;
    v_monto_mp := v_monto_mp + (v_precio_cobro * v_qty);
    v_n_items := v_n_items + 1;
  end loop;

  v_subtotal := round(v_subtotal, 2);
  v_monto_mp := round(v_monto_mp, 2);
  v_recargo := round(v_monto_mp - v_subtotal, 2);
  -- pedidos.total = lo que se cobra (pickup: base; envío: base+recargo). El fee envío se suma después en attach.
  v_total := case when v_es_pickup then v_subtotal else v_monto_mp end;

  if v_total <= 0 then
    raise exception 'Total inválido';
  end if;

  -- MONTO_MINIMO sobre subtotal de productos (sin recargo, sin envío)
  if not v_es_pickup and v_subtotal < 150 then
    raise exception 'El pedido a domicilio tiene un mínimo de $150 en productos (antes de envío). Agrega algo más al carrito o recógelo en farmacia sin mínimo.';
  end if;

  insert into public.pedidos (
    cliente_id, total, estado, tipo, tipo_entrega, direccion,
    metodo_pago, whatsapp_recibo, payment_status, payment_provider,
    subtotal_productos, recargo_procesamiento_pago, monto_cobrado_mercadopago
  ) values (
    v_cli_id, v_total, 'pendiente', 'online', p_tipo_entrega, p_direccion,
    v_metodo, coalesce(p_whatsapp_recibo, false),
    case when v_es_pickup then 'pending_store' else null end,
    null,
    v_subtotal,
    case when v_es_pickup then 0 else v_recargo end,
    case when v_es_pickup then 0 else v_monto_mp end
  ) returning id into v_pedido_id;

  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item->>'producto_id')::bigint;
    v_qty := (v_item->>'cantidad')::numeric;
    begin
      v_precio_line := public.precio_oferta_publico(v_pid);
    exception when undefined_function then
      select coalesce(precio, 0) into v_precio_line from public.productos where id = v_pid;
    end;

    insert into public.pedido_items (pedido_id, producto_id, cantidad, precio_unitario)
    values (v_pedido_id, v_pid, v_qty, v_precio_line);
  end loop;

  -- Puntos: solo en prepago/domicilio al crear (legacy). Pickup acredita al cobrar BBVA.
  if not v_es_pickup then
    v_puntos_ganados := floor(v_subtotal / 10);
    if v_puntos_ganados > 0 then
      update public.clientes
         set puntos = coalesce(puntos, 0) + v_puntos_ganados
       where id = v_cli_id;
    end if;
  else
    v_puntos_ganados := 0;
  end if;

  if p_reservation_session_id is not null then
    begin
      perform public.confirm_stock_reservation(p_reservation_session_id, v_pedido_id);
    exception when others then
      raise notice 'confirm_stock_reservation no disponible: %', SQLERRM;
    end;
  end if;

  return jsonb_build_object(
    'success', true,
    'pedido_id', v_pedido_id,
    'cliente_id', v_cli_id,
    'total', v_total,
    'puntos_ganados', v_puntos_ganados,
    'items', v_n_items,
    'whatsapp_recibo', coalesce(p_whatsapp_recibo, false),
    'metodo_pago', v_metodo,
    'payment_status', case when v_es_pickup then 'pending_store' else null end,
    'cobro_en_tienda', v_es_pickup,
    'subtotal_productos', v_subtotal,
    'recargo_procesamiento_pago', case when v_es_pickup then 0 else v_recargo end,
    'monto_cobrado_mercadopago', case when v_es_pickup then 0 else v_monto_mp end
  );
end;
$$;


grant execute on function public.cliente_crear_pedido_online(
  uuid, jsonb, text, text, text, text, text, text, text, boolean
) to anon, authenticated;

comment on function public.cliente_crear_pedido_online(uuid, jsonb, text, text, text, text, text, text, text, boolean) is
  'Checkout: pickup sin recargo/pending_store; envío con recargo 8% en total + desglose; ítems a precio base; mínimo $150 subtotal.';

commit;
