-- FarmaCapital — Pedido online: permitir medicamentos con receta (firma whatsapp del front)
-- Verificado en prod: fn_digits_mx OK; RPC con whatsapp_recibo aún bloquea Rx.
-- Quita el IF de receta en la firma que usa el front + elimina overload de 9 args.
-- Supabase → SQL Editor → Run TODO el archivo.

begin;

create or replace function public.fn_digits_mx(p_text text)
returns text
language sql
immutable
as $$
  select case
    when p_text is null then ''
    else right(regexp_replace(p_text, '\D', '', 'g'), 10)
  end;
$$;

drop function if exists public.cliente_crear_pedido_online(
  uuid, jsonb, text, text, text, text, text, text, text
);

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
  v_existing     bigint;
  v_guest        boolean := false;
begin
  if p_session_token is not null then
    v_cli_id := public.fn_validar_token_cliente(p_session_token);
    if v_cli_id is null then
      raise exception 'Sesión cliente inválida' using errcode = '28000';
    end if;
  else
    v_guest := true;
    if p_guest_telefono is null or length(trim(p_guest_telefono))=0 then
      raise exception 'Teléfono requerido para checkout sin cuenta';
    end if;
    if p_guest_nombre is null or length(trim(p_guest_nombre))=0 then
      raise exception 'Nombre requerido para checkout sin cuenta';
    end if;

    v_telefono_norm := trim(p_guest_telefono);

    select c.id into v_existing
      from public.clientes c
     where public.fn_digits_mx(c.telefono) = public.fn_digits_mx(v_telefono_norm)
       and c.password_hash is not null
       and length(c.password_hash) > 0
     limit 1;

    if v_existing is not null then
      raise exception 'Ya hay una cuenta con este teléfono. Inicia sesión para continuar';
    end if;

    select c.id into v_cli_id
      from public.clientes c
     where public.fn_digits_mx(c.telefono) = public.fn_digits_mx(v_telefono_norm)
     limit 1;

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

  if p_metodo_pago not in ('tarjeta','mercadopago','efectivo') then
    raise exception 'Método de pago inválido';
  end if;
  if p_tipo_entrega not in ('recoger','envio') then
    raise exception 'Tipo de entrega inválido';
  end if;
  if p_tipo_entrega = 'envio' and (p_direccion is null or length(trim(p_direccion))=0) then
    raise exception 'Dirección requerida para envío';
  end if;

  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item->>'producto_id')::bigint;
    v_qty := (v_item->>'cantidad')::numeric;
    if v_qty is null or v_qty <= 0 then
      raise exception 'Cantidad inválida para producto %', v_pid;
    end if;

    select id, precio, activo, stock, nombre
      into v_prod
      from public.productos
     where id = v_pid
     for update;

    if v_prod.id is null then
      raise exception 'Producto % no existe', v_pid;
    end if;
    if not coalesce(v_prod.activo, false) then
      raise exception 'Producto "%" no está disponible', v_prod.nombre;
    end if;

    perform 1 from public.lotes
     where producto_id = v_pid and coalesce(activo, true)
     for update;

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
    -- requiere_receta: permitido online (se solicita al entregar / recoger).

    v_total := v_total + (v_prod.precio * v_qty);
    v_n_items := v_n_items + 1;
  end loop;

  if v_total <= 0 then
    raise exception 'Total inválido';
  end if;

  insert into public.pedidos (
    cliente_id, total, estado, tipo, tipo_entrega, direccion, metodo_pago,
    whatsapp_recibo, guest_nombre, guest_telefono, guest_email, puntos_acreditados
  ) values (
    v_cli_id, v_total, 'pendiente', 'online', p_tipo_entrega, p_direccion, p_metodo_pago,
    coalesce(p_whatsapp_recibo, false),
    case when v_guest then trim(p_guest_nombre) else null end,
    case when v_guest then v_telefono_norm else null end,
    case when v_guest then nullif(trim(coalesce(p_guest_email,'')),'') else null end,
    false
  ) returning id into v_pedido_id;

  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item->>'producto_id')::bigint;
    v_qty := (v_item->>'cantidad')::numeric;
    select precio into v_prod from public.productos where id = v_pid;

    insert into public.pedido_items (pedido_id, producto_id, cantidad, precio_unitario)
    values (v_pedido_id, v_pid, v_qty, v_prod.precio);
  end loop;

  v_puntos_ganados := floor(v_total / 10);

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
    'whatsapp_recibo', coalesce(p_whatsapp_recibo, false)
  );
end;
$$;

grant execute on function public.cliente_crear_pedido_online(
  uuid, jsonb, text, text, text, text, text, text, text, boolean
) to anon, authenticated;

commit;
