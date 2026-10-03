-- Puntos FarmaCapital → escala estilo Monedero del Ahorro.
-- 1 punto = $1. Se gana 1 punto por cada $100 (mismo 1% que antes).
-- Convierte saldos viejos (÷10) una sola vez. SIN do $$.
-- Correr en Supabase SQL Editor después del deploy del front.

begin;

create or replace function public.fc_puntos_por_compra(p_monto numeric)
returns integer
language sql
immutable
parallel safe
as $f$
  select greatest(0, floor(coalesce(p_monto, 0) / 100)::integer);
$f$;

comment on function public.fc_puntos_por_compra(numeric) is
  'Puntos FarmaCapital: 1 pt por cada $100 de compra (1 pt = $1).';

grant execute on function public.fc_puntos_por_compra(numeric) to anon, authenticated, service_role;

-- Saldos: escala vieja era 10× (1 pt/$10 a $0.10). ÷10 conserva pesos.
update public.clientes
   set puntos = floor(coalesce(puntos, 0) / 10)::integer,
       notas = trim(both from coalesce(notas, '') || ' |PTS_ESCALA_V2|')
 where coalesce(puntos, 0) > 0
   and coalesce(notas, '') not like '%|PTS_ESCALA_V2|%';

create or replace function public.service_acreditar_puntos_pedido(p_pedido_id bigint)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_pedido record;
  v_pts integer;
begin
  if p_pedido_id is null then
    return jsonb_build_object('ok', false, 'error', 'missing_pedido');
  end if;

  select * into v_pedido from public.pedidos where id = p_pedido_id for update;
  if v_pedido.id is null then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  if coalesce(v_pedido.puntos_acreditados, false) then
    return jsonb_build_object('ok', true, 'already', true);
  end if;
  if v_pedido.cliente_id is null then
    return jsonb_build_object('ok', false, 'error', 'no_cliente');
  end if;

  v_pts := public.fc_puntos_por_compra(v_pedido.total);
  if v_pts > 0 then
    update public.clientes
       set puntos = coalesce(puntos, 0) + v_pts
     where id = v_pedido.cliente_id;
  end if;

  update public.pedidos
     set puntos_acreditados = true
   where id = p_pedido_id;

  return jsonb_build_object('ok', true, 'puntos', v_pts);
end;
$$;

revoke all on function public.service_acreditar_puntos_pedido(bigint) from public, anon, authenticated;
grant execute on function public.service_acreditar_puntos_pedido(bigint) to service_role;

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
    raise exception 'El pedido ya está vinculado a otro cliente';
  end if;

  v_pts := public.fc_puntos_por_compra(v_pedido.total);

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

create or replace function public.cliente_canjear_puntos_tienda(
  p_session_token uuid,
  p_puntos integer
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli_id bigint;
  v_pts int;
  v_nuevos int;
  v_ben text;
  v_codigo text;
  v_notas text;
begin
  if p_session_token is null then
    return jsonb_build_object('success', false, 'error', 'Sesión requerida');
  end if;
  v_cli_id := public.fn_validar_token_cliente(p_session_token);
  if v_cli_id is null then
    return jsonb_build_object('success', false, 'error', 'Sesión inválida');
  end if;

  if p_puntos not in (10, 25, 50, 80, 100) then
    return jsonb_build_object('success', false, 'error', 'Canje no válido');
  end if;

  v_ben := case p_puntos
    when 10 then '$10 descuento'
    when 25 then 'Envío gratis'
    when 50 then '$50 descuento'
    when 80 then 'Consulta médica gratis'
    when 100 then 'Producto gratis'
  end;

  select coalesce(puntos, 0) into v_pts from public.clientes where id = v_cli_id;
  if v_pts < p_puntos then
    return jsonb_build_object('success', false, 'error', 'Puntos insuficientes');
  end if;

  v_codigo := 'FC-' || p_puntos || '-' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));
  v_nuevos := v_pts - p_puntos;

  select coalesce(notas, '') into v_notas from public.clientes where id = v_cli_id;
  v_notas := trim(both from (v_notas || E'\n' || to_char(now() at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI')
    || ' CANJE ' || v_codigo || ' · ' || p_puntos || ' pts · ' || v_ben));

  update public.clientes
     set puntos = v_nuevos,
         notas = v_notas
   where id = v_cli_id;

  return jsonb_build_object(
    'success', true,
    'puntos', v_nuevos,
    'codigo', v_codigo,
    'beneficio', v_ben,
    'puntos_canjeados', p_puntos
  );
end;
$$;

grant execute on function public.cliente_canjear_puntos_tienda(uuid, integer) to anon, authenticated;

-- Pedido online (última versión conocida): mismos puntos /100.
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

  -- Baja el anaquel YA (no esperar a Surtir).
  v_items_stock := public.fn_pedido_online_comprometer_stock(v_pedido_id);

  if not v_es_pickup then
    v_puntos_ganados := public.fc_puntos_por_compra(v_subtotal);
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

commit;
