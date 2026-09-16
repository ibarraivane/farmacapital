-- FarmaCapital — BAJO PEDIDO (vitrina /conseguir + encargo con reserva en tarjeta).
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.
--
-- ORDEN: este patch va ANTES de cualquier alta/UPDATE de productos con
-- bajo_pedido = true (dermatología, vitaminas, suplementos, proteína).
-- Después: sql/patch_bajo_pedido_alertas_dashboard_20260916.sql
-- (dashboard / badge sidebar). Verificar receta online:
-- sql/verificar_cliente_crear_pedido_online_receta.sql
--
-- Reglas:
--   * productos.precio = ANCLA de mostrador. Nunca se guarda inflado.
--   * Web cobra fc_precio_online_mp(precio): (ancla + $4×1.16) / (1 − 3.49%×1.16), ceil a peso.
--     El cliente ve ese precio en la tarjeta; el checkout solo suma líneas (sin +$4 extra).
--   * El pedido de encargo se crea con cliente_crear_pedido_bajo_pedido (NO toca
--     cliente_crear_pedido_online) y queda logistics_meta.bajo_pedido = true.
--   * Pago: reserva en tarjeta (Mercado Pago, capture manual). payment_status:
--     authorized (reservado) → approved (cobrado al conseguirlo) | cancelled.
--     Mientras está authorized NO entra a «pedidos por surtir» (el gate exige approved).

begin;

-- ── 1) productos.bajo_pedido ────────────────────────────────
alter table public.productos
  add column if not exists bajo_pedido boolean not null default false;

create index if not exists productos_bajo_pedido_idx
  on public.productos (id)
  where bajo_pedido;

comment on column public.productos.bajo_pedido is
  'true = no está en anaquel; vitrina /conseguir con stock 0, se encarga con reserva. No marcar si hay stock real de góndola.';

-- ── 2) columnas de pedidos que usa el flujo (ya existen en prod; por si acaso) ──
alter table public.pedidos
  add column if not exists logistics_meta     jsonb not null default '{}'::jsonb,
  add column if not exists payment_provider   text,
  add column if not exists payment_status     text,
  add column if not exists payment_id         text,
  add column if not exists paid_at            timestamptz,
  add column if not exists payment_payload    jsonb,
  add column if not exists guest_nombre       text,
  add column if not exists guest_telefono     text,
  add column if not exists guest_email        text,
  add column if not exists whatsapp_recibo    boolean not null default false,
  add column if not exists puntos_acreditados boolean not null default false;

create index if not exists pedidos_bajo_pedido_idx
  on public.pedidos (created_at desc)
  where (logistics_meta ->> 'bajo_pedido') = 'true';

-- ── 3) Precio web con Mercado Pago (espejo de src/lib/precioOnlineMp.js) ──
create or replace function public.fc_precio_online_mp(p_precio numeric)
returns numeric
language sql
immutable
set search_path = public, pg_temp
as $$
  select case
    when p_precio is null or p_precio <= 0.01 then null
    else ceil(round((p_precio + 4 * 1.16) / (1 - 0.040484), 2))
  end;
$$;

grant execute on function public.fc_precio_online_mp(numeric) to anon, authenticated;

-- ── 4) Crear pedido de ENCARGO (solo líneas bajo_pedido) ─────
create or replace function public.cliente_crear_pedido_bajo_pedido(
  p_session_token   uuid,
  p_cart            jsonb,
  p_tipo_entrega    text default 'recoger',
  p_direccion       text default null,
  p_guest_nombre    text default null,
  p_guest_telefono  text default null,
  p_guest_email     text default null,
  p_whatsapp_recibo boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli_id    bigint;
  v_pedido_id bigint;
  v_item      jsonb;
  v_pid       bigint;
  v_qty       numeric;
  v_prod      record;
  v_unit      numeric;
  v_total     numeric := 0;
  v_n_items   int := 0;
  v_guest     boolean := false;
  v_tel       text;
  v_tel10     text;
  v_existing  bigint;
begin
  if p_session_token is not null then
    v_cli_id := public.fn_validar_token_cliente(p_session_token);
    if v_cli_id is null then
      raise exception 'Sesión cliente inválida' using errcode = '28000';
    end if;
  else
    v_guest := true;
    if coalesce(trim(p_guest_telefono), '') = '' then
      raise exception 'Teléfono requerido para checkout sin cuenta';
    end if;
    if coalesce(trim(p_guest_nombre), '') = '' then
      raise exception 'Nombre requerido para checkout sin cuenta';
    end if;
    v_tel := trim(p_guest_telefono);
    v_tel10 := right(regexp_replace(v_tel, '\D', '', 'g'), 10);
    if length(v_tel10) <> 10 then
      raise exception 'Teléfono de 10 dígitos requerido';
    end if;

    -- Igual que el checkout normal: un invitado no se pega a una cuenta con contraseña.
    select c.id into v_existing
      from public.clientes c
     where right(regexp_replace(coalesce(c.telefono, ''), '\D', '', 'g'), 10) = v_tel10
       and c.password_hash is not null
       and length(c.password_hash) > 0
     limit 1;
    if v_existing is not null then
      raise exception 'Ya hay una cuenta con este teléfono. Inicia sesión para continuar';
    end if;

    select c.id into v_cli_id
      from public.clientes c
     where right(regexp_replace(coalesce(c.telefono, ''), '\D', '', 'g'), 10) = v_tel10
     limit 1;
    if v_cli_id is null then
      insert into public.clientes (nombre, telefono, email, puntos)
      values (trim(p_guest_nombre), v_tel, nullif(trim(coalesce(p_guest_email, '')), ''), 0)
      returning id into v_cli_id;
    end if;
  end if;

  if jsonb_typeof(p_cart) is distinct from 'array' or jsonb_array_length(p_cart) = 0 then
    raise exception 'Carrito vacío';
  end if;
  if jsonb_array_length(p_cart) > 30 then
    raise exception 'Demasiados productos en un encargo';
  end if;
  if p_tipo_entrega not in ('recoger', 'envio') then
    raise exception 'Tipo de entrega inválido';
  end if;
  if p_tipo_entrega = 'envio' and coalesce(trim(p_direccion), '') = '' then
    raise exception 'Dirección requerida para envío';
  end if;

  -- Validar todo antes de insertar.
  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item ->> 'producto_id')::bigint;
    v_qty := (v_item ->> 'cantidad')::numeric;
    if v_qty is null or v_qty <> trunc(v_qty) or v_qty < 1 or v_qty > 12 then
      raise exception 'Cantidad inválida (1 a 12) para producto %', v_pid;
    end if;

    select id, nombre, precio, activo, bajo_pedido, controlado
      into v_prod
      from public.productos
     where id = v_pid;

    if v_prod.id is null then
      raise exception 'Producto % no existe', v_pid;
    end if;
    if not coalesce(v_prod.activo, false) then
      raise exception 'Producto "%" no está disponible', v_prod.nombre;
    end if;
    if not coalesce(v_prod.bajo_pedido, false) then
      raise exception 'El producto "%" no es de encargo; cómpralo en el carrito normal', v_prod.nombre;
    end if;
    if coalesce(v_prod.controlado, false) then
      raise exception 'El producto "%" es controlado y solo se vende en mostrador', v_prod.nombre;
    end if;

    v_unit := public.fc_precio_online_mp(v_prod.precio);
    if v_unit is null then
      raise exception 'Producto "%" aún no tiene precio; pide cotización', v_prod.nombre;
    end if;

    v_total := v_total + v_unit * v_qty;
    v_n_items := v_n_items + 1;
  end loop;

  if v_total <= 0 then
    raise exception 'Total inválido';
  end if;

  insert into public.pedidos (
    cliente_id, total, estado, tipo, tipo_entrega, direccion, metodo_pago,
    whatsapp_recibo, guest_nombre, guest_telefono, guest_email, puntos_acreditados,
    logistics_meta
  ) values (
    v_cli_id, v_total, 'pendiente', 'online', p_tipo_entrega,
    case when p_tipo_entrega = 'envio' then p_direccion else null end,
    'tarjeta',
    coalesce(p_whatsapp_recibo, false),
    case when v_guest then trim(p_guest_nombre) else null end,
    case when v_guest then v_tel else null end,
    case when v_guest then nullif(trim(coalesce(p_guest_email, '')), '') else null end,
    false,
    jsonb_build_object('bajo_pedido', true, 'surtido', 'mayorista')
  ) returning id into v_pedido_id;

  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item ->> 'producto_id')::bigint;
    v_qty := (v_item ->> 'cantidad')::numeric;
    insert into public.pedido_items (pedido_id, producto_id, cantidad, precio_unitario)
    select v_pedido_id, p.id, v_qty, public.fc_precio_online_mp(p.precio)
      from public.productos p
     where p.id = v_pid;
  end loop;

  -- Puntos: se acreditan al COBRAR la reserva (service_acreditar_puntos_pedido), no aquí.
  return jsonb_build_object(
    'success', true,
    'pedido_id', v_pedido_id,
    'cliente_id', v_cli_id,
    'total', v_total,
    'items', v_n_items,
    'bajo_pedido', true
  );
end;
$$;

grant execute on function public.cliente_crear_pedido_bajo_pedido(uuid, jsonb, text, text, text, text, text, boolean) to anon, authenticated;

-- ── 5) Inventario: interruptor bajo_pedido (RPC propia, no toca admin_editar_producto) ──
create or replace function public.admin_set_bajo_pedido_producto(
  p_session_token uuid,
  p_producto_id   bigint,
  p_bajo_pedido   boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_prod  record;
begin
  v_actor := public.fn_require_admin(p_session_token);

  select id, nombre, stock, bajo_pedido into v_prod
    from public.productos where id = p_producto_id for update;
  if v_prod.id is null then
    raise exception 'Producto % no encontrado', p_producto_id;
  end if;

  if coalesce(p_bajo_pedido, false) and coalesce(v_prod.stock, 0) > 0
     and not coalesce(v_prod.bajo_pedido, false) then
    raise exception '"%" tiene % en existencia: es de anaquel, no lo marques bajo pedido', v_prod.nombre, v_prod.stock;
  end if;

  update public.productos
     set bajo_pedido = coalesce(p_bajo_pedido, false)
   where id = p_producto_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor, (select nombre from public.usuarios where id = v_actor),
            'bajo_pedido_producto', 'productos', p_producto_id::text,
            jsonb_build_object('bajo_pedido', coalesce(p_bajo_pedido, false)));
  exception when others then
    null; -- la bitácora no tumba el guardado
  end;

  return jsonb_build_object('id', p_producto_id, 'bajo_pedido', coalesce(p_bajo_pedido, false));
end;
$$;

revoke all on function public.admin_set_bajo_pedido_producto(uuid, bigint, boolean) from public;
grant execute on function public.admin_set_bajo_pedido_producto(uuid, bigint, boolean) to anon, authenticated;

-- ── 6) Mostrador: encargos con reserva (pendientes de conseguir / cobrar) ──
create or replace function public.empleado_listar_encargos_bajo_pedido(
  p_session_token uuid,
  p_limit int default 100
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_lim int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limit, 100), 300));
  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        jsonb_build_object(
          'id', p.id,
          'total', p.total,
          'created_at', p.created_at,
          'estado', p.estado,
          'tipo_entrega', p.tipo_entrega,
          'direccion', p.direccion,
          'metodo_pago', p.metodo_pago,
          'payment_status', p.payment_status,
          'payment_payload', coalesce(p.payment_payload, '{}'::jsonb),
          'paid_at', p.paid_at,
          'logistics_meta', coalesce(p.logistics_meta, '{}'::jsonb),
          'guest_nombre', p.guest_nombre,
          'guest_telefono', p.guest_telefono,
          'clientes', jsonb_build_object('nombre', cl.nombre, 'telefono', cl.telefono),
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.clientes cl on cl.id = p.cliente_id
      left join lateral (
        select jsonb_agg(jsonb_build_object(
                 'cantidad', i.cantidad,
                 'precio_unitario', i.precio_unitario,
                 'productos', jsonb_build_object('id', pr.id, 'nombre', pr.nombre, 'sku', pr.sku,
                                                 'codigo_barras', pr.codigo_barras,
                                                 'stock', pr.stock)
               ) order by i.id) as js
          from public.pedido_items i
          join public.productos pr on pr.id = i.producto_id
         where i.pedido_id = p.id
      ) pi on true
      where (p.logistics_meta ->> 'bajo_pedido') = 'true'
        and p.estado <> 'cancelado'
        and (
          lower(coalesce(p.payment_status, '')) = 'authorized'
          or (lower(coalesce(p.payment_status, '')) in ('cancelled', 'approved')
              and p.created_at > now() - interval '7 days')
        )
      order by p.created_at desc
      limit v_lim
    ) q
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_encargos_bajo_pedido(uuid, int) to anon, authenticated;

commit;

-- ── Verificación rápida ──
-- select public.fc_precio_online_mp(10);    -- 16   (Skittles)
-- select public.fc_precio_online_mp(100);   -- 110
-- select public.fc_precio_online_mp(459);   -- 484  (Anthelios)
-- select public.fc_precio_online_mp(0.01);  -- null
