-- FarmaCapital — checkout domicilio: invitados + sin mínimo $150
-- Regresión del patch_online_stock_al_crear_20260923:
--   1) INSERT ya no guardaba guest_nombre/telefono/email → attach fallaba
--      con guest_phone_mismatch y el cliente veía «No se pudo registrar la dirección».
--   2) Volvió el raise de mínimo $150 (quitado el 21-sep) → pedidos chicos de
--      domicilio no se creaban aunque la UI ya no muestra ese piso.
-- Pegar en Supabase → SQL Editor → Run.

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
  v_factor_recargo numeric := 0.08;
  v_monto_mp     numeric := 0;
  v_items_stock  int := 0;
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

    select id, precio, activo, stock, nombre, controlado, bajo_pedido
    into v_prod from public.productos where id = v_pid for update;

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

    -- Stock vendible = lotes activos no caducados (misma regla que consume_stock_via_lotes).
    if not coalesce(v_prod.bajo_pedido, false) then
      select coalesce(sum(l.cantidad_actual), 0)::integer
        into v_sum_lotes
        from public.lotes l
        where l.producto_id = v_pid
          and coalesce(l.activo, true)
          and coalesce(l.cantidad_actual, 0) > 0
          and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date);

      v_stock_eff := coalesce(v_sum_lotes, 0);

      if v_stock_eff < v_qty then
        raise exception 'Stock insuficiente para "%": disponible=%, solicitado=%',
                        v_prod.nombre, v_stock_eff, v_qty;
      end if;
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
  v_total := case when v_es_pickup then v_subtotal else v_monto_mp end;

  if v_total <= 0 then
    raise exception 'Total inválido';
  end if;


  insert into public.pedidos (
    cliente_id, total, estado, tipo, tipo_entrega, direccion,
    metodo_pago, whatsapp_recibo, payment_status, payment_provider,
    subtotal_productos, recargo_procesamiento_pago, monto_cobrado_mercadopago,
    guest_nombre, guest_telefono, guest_email
  ) values (
    v_cli_id, v_total, 'pendiente', 'online', p_tipo_entrega, p_direccion,
    v_metodo, coalesce(p_whatsapp_recibo, false),
    case when v_es_pickup then 'pending_store' else null end,
    null,
    v_subtotal,
    case when v_es_pickup then 0 else v_recargo end,
    case when v_es_pickup then 0 else v_monto_mp end,
    case when p_session_token is null then trim(p_guest_nombre) else null end,
    case when p_session_token is null then v_telefono_norm else null end,
    case when p_session_token is null then nullif(trim(coalesce(p_guest_email,'')),'') else null end
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

  -- Baja el anaquel YA (no esperar a Surtir).
  v_items_stock := public.fn_pedido_online_comprometer_stock(v_pedido_id);

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
    'items_stock_comprometidos', v_items_stock,
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
  'Checkout online: compromete stock FEFO al crear;
