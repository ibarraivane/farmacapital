-- FarmaCapital — Fase (b) métodos de pago: pickup sin Preference / Link MP
-- Ejecutar en Supabase SQL Editor tras backup.
--
-- Pickup (tipo_entrega=recoger):
--   metodo_pago = pendiente_tienda
--   payment_status = pending_store
--   entra a cola POS y se puede surtir sin payment_status=approved de MP
--   NO acredita puntos al crear (se acreditan al cobrar BBVA en fase a)
--
-- Domicilio (envio): sin cambio de gate MP approved.
--
-- Requiere: precio_oferta_publico (sql/patch_precio_oferta_publico_20260830.sql)
--           columnas payment_* (sql/fix_pedidos_payment_tracking.sql)
--           whatsapp_recibo (sql/patch_pedidos_whatsapp_recibo.sql)

begin;

-- 1) Ampliar chk_metodo_pago con pendiente_tienda
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
      'mixto',
      'pendiente_tienda'
    )
  ) not valid;

do $$
begin
  if not exists (
    select 1
    from public.pedidos
    where metodo_pago is not null
      and lower(btrim(metodo_pago)) not in (
        'efectivo', 'tarjeta', 'mercadopago', 'mercadopago_point',
        'spei', 'mixto', 'pendiente_tienda'
      )
  ) then
    alter table public.pedidos validate constraint chk_metodo_pago;
  end if;
exception when others then
  raise notice 'chk_metodo_pago quedó NOT VALID (valores históricos fuera de lista).';
end $$;

-- 2) Gate: pendiente_tienda puede surtirse / aparecer en cola
create or replace function public.fn_pedido_online_pago_confirmado(
  p_metodo_pago text,
  p_payment_status text,
  p_tipo text default null
)
returns boolean
language plpgsql
immutable
as $$
declare
  v_metodo text := lower(trim(coalesce(p_metodo_pago, '')));
  v_status text := lower(trim(coalesce(p_payment_status, '')));
  v_tipo   text := lower(trim(coalesce(p_tipo, '')));
begin
  if v_tipo is not null and v_tipo <> '' and v_tipo <> 'online' then
    return true;
  end if;

  -- Pickup web: confirmado, pendiente de cobro en tienda (BBVA)
  if v_metodo = 'pendiente_tienda' then
    return true;
  end if;

  if v_metodo in ('mercadopago', 'tarjeta') then
    return v_status = 'approved';
  end if;

  if v_metodo = 'efectivo' then
    return true;
  end if;

  if v_status <> '' then
    return v_status = 'approved';
  end if;

  return false;
end;
$$;

comment on function public.fn_pedido_online_pago_confirmado(text, text, text) is
  'true cuando un pedido online puede mostrarse en POS para surtir (MP/tarjeta=approved; pendiente_tienda=pickup sin prepago).';

-- 3) RPC checkout: pickup → pending_store; envío → mercadopago; precio_oferta_publico
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
  v_metodo       text;
  v_es_pickup    boolean;
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

    v_total := v_total + (v_precio_line * v_qty);
    v_n_items := v_n_items + 1;
  end loop;

  if v_total <= 0 then
    raise exception 'Total inválido';
  end if;

  insert into public.pedidos (
    cliente_id, total, estado, tipo, tipo_entrega, direccion,
    metodo_pago, whatsapp_recibo, payment_status, payment_provider
  ) values (
    v_cli_id, v_total, 'pendiente', 'online', p_tipo_entrega, p_direccion,
    v_metodo, coalesce(p_whatsapp_recibo, false),
    case when v_es_pickup then 'pending_store' else null end,
    null
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
    v_puntos_ganados := floor(v_total / 10);
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
    'cobro_en_tienda', v_es_pickup
  );
end;
$$;

grant execute on function public.cliente_crear_pedido_online(
  uuid, jsonb, text, text, text, text, text, text, text, boolean
) to anon, authenticated;

comment on function public.cliente_crear_pedido_online(uuid, jsonb, text, text, text, text, text, text, text, boolean) is
  'Checkout tienda: pickup → pendiente_tienda/pending_store sin puntos; envío → metodo del cliente; precios vía precio_oferta_publico.';

commit;
