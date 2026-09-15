-- FARMAX — Envío a domicilio Plan B (tarifa en checkout, un solo pago MP)
-- Aditivo. No toca RH, corte de caja ni FEFO.
-- Validaciones de radio, proveedor y despacho van en SQL, no solo en UI.

begin;

alter table public.pedidos
  add column if not exists costo_envio numeric,
  add column if not exists logistics_meta jsonb not null default '{}'::jsonb;

create table if not exists public.tabla_tarifa_envio (
  id                serial primary key,
  distancia_min_km  numeric not null,
  distancia_max_km  numeric not null,
  costo_base        numeric not null check (costo_base >= 0),
  gratis_desde      numeric not null check (gratis_desde >= 0),
  activo            boolean not null default true,
  check (distancia_min_km >= 0),
  check (distancia_max_km > distancia_min_km)
);

create unique index if not exists uq_tabla_tarifa_envio_tramo
  on public.tabla_tarifa_envio (distancia_min_km, distancia_max_km)
  where activo;

insert into public.tabla_tarifa_envio (distancia_min_km, distancia_max_km, costo_base, gratis_desde)
select * from (values
  (0::numeric, 2::numeric, 30::numeric, 180::numeric),
  (2::numeric, 4::numeric, 45::numeric, 230::numeric),
  (4::numeric, 5::numeric, 65::numeric, 320::numeric)
) as v(distancia_min_km, distancia_max_km, costo_base, gratis_desde)
where not exists (select 1 from public.tabla_tarifa_envio);

create table if not exists public.envio_colonias_propio (
  id       serial primary key,
  colonia  text not null,
  activo   boolean not null default true
);

create unique index if not exists uq_envio_colonias_propio_colonia
  on public.envio_colonias_propio (lower(trim(colonia)))
  where activo;

alter table public.direcciones_cliente
  add column if not exists calle text,
  add column if not exists numero text,
  add column if not exists referencia text;

alter table public.envios
  add column if not exists distancia_km numeric,
  add column if not exists costo_cotizado numeric,
  add column if not exists costo_tabla numeric,
  add column if not exists proveedor text,
  add column if not exists cotizar_antes_de timestamptz,
  add column if not exists mp_preference_id text,
  add column if not exists mp_payment_id text,
  add column if not exists colonia text;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'envios_proveedor_chk'
      and conrelid = 'public.envios'::regclass
  ) then
    alter table public.envios
      add constraint envios_proveedor_chk
      check (proveedor is null or proveedor in ('didi', 'uber', 'propio'));
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'envios_estado_plan_b_chk'
      and conrelid = 'public.envios'::regclass
  ) then
    alter table public.envios
      add constraint envios_estado_plan_b_chk
      check (estado in (
        'pendiente',
        'pendiente_cotizacion',
        'cotizado',
        'link_enviado',
        'pagado',
        'en_ruta',
        'entregado',
        'fuera_radio',
        'vencido',
        'cancelado'
      ));
  end if;
end $$;

comment on table public.tabla_tarifa_envio is
  'Tramos de costo de envío. Valores de arranque; ajustables. RADIO_MAXIMO_KM vive también en env.';
comment on column public.envios.proveedor is
  'Operativo interno: didi (default) | uber (fallback manual) | propio (colonias). No se muestra al cliente.';
comment on column public.envios.cotizar_antes_de is
  'SLA de cotización (TIEMPO_MAXIMO_COTIZACION_MIN). Visible en pedido/POS.';

create or replace function public.fc_radio_maximo_km()
returns numeric
language sql
stable
as $$
  select coalesce(
    (
      select max(distancia_max_km)
      from public.tabla_tarifa_envio
      where activo
    ),
    5
  );
$$;

create or replace function public.fc_calcular_tarifa_envio(
  p_distancia_km numeric,
  p_subtotal numeric default 0
)
returns table (
  ok boolean,
  error text,
  distancia_km numeric,
  costo numeric,
  costo_tabla numeric,
  gratis boolean,
  gratis_desde numeric
)
language plpgsql
stable
as $$
declare
  v_radio numeric := public.fc_radio_maximo_km();
  v_row public.tabla_tarifa_envio%rowtype;
begin
  if p_distancia_km is null or p_distancia_km < 0 then
    return query select false, 'distancia_invalida', p_distancia_km, null::numeric, null::numeric, false, null::numeric;
    return;
  end if;
  if p_distancia_km > v_radio then
    return query select false, 'fuera_radio', p_distancia_km, null::numeric, null::numeric, false, null::numeric;
    return;
  end if;
  select * into v_row
  from public.tabla_tarifa_envio t
  where t.activo
    and p_distancia_km >= t.distancia_min_km
    and p_distancia_km <= t.distancia_max_km
  order by t.distancia_max_km
  limit 1;
  if not found then
    return query select false, 'fuera_radio', p_distancia_km, null::numeric, null::numeric, false, null::numeric;
    return;
  end if;
  return query select
    true,
    null::text,
    p_distancia_km,
    case when coalesce(p_subtotal, 0) >= v_row.gratis_desde then 0 else v_row.costo_base end,
    v_row.costo_base,
    coalesce(p_subtotal, 0) >= v_row.gratis_desde,
    v_row.gratis_desde;
end;
$$;

create or replace function public.fc_envio_validar_despacho()
returns trigger
language plpgsql
as $$
begin
  if new.distancia_km is not null and new.distancia_km > public.fc_radio_maximo_km()
     and new.estado not in ('fuera_radio', 'cancelado') then
    raise exception 'fuera_radio: distancia % > radio máximo', new.distancia_km;
  end if;
  if new.estado in ('en_ruta', 'entregado')
     and coalesce(new.costo_cotizado, 0) > 0 then
    if tg_op = 'INSERT' then
      raise exception 'envio_no_pagado: hay que cobrar el envío antes de despachar';
    end if;
    if tg_op = 'UPDATE'
       and coalesce(old.estado, '') not in ('pagado', 'en_ruta', 'entregado') then
      raise exception 'envio_no_pagado: el envío debe estar cobrado en checkout (o pagado) antes de despachar';
    end if;
  end if;
  if new.proveedor is not null and new.proveedor not in ('didi', 'uber', 'propio') then
    raise exception 'proveedor inválido';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_envios_validar_despacho on public.envios;
create trigger trg_envios_validar_despacho
  before insert or update on public.envios
  for each row
  execute procedure public.fc_envio_validar_despacho();

-- Historial del cliente: deadline y estado de cotización (sin nombrar proveedor).
create or replace function public.cliente_listar_mis_pedidos(
  p_session_token uuid,
  p_limite int default 120
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli bigint;
begin
  v_cli := public.fn_require_cliente(p_session_token);
  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        jsonb_build_object(
          'id', p.id,
          'total', p.total,
          'estado', p.estado,
          'tipo', p.tipo,
          'metodo_pago', p.metodo_pago,
          'tipo_entrega', p.tipo_entrega,
          'direccion', p.direccion,
          'created_at', p.created_at,
          'payment_provider', p.payment_provider,
          'payment_status', p.payment_status,
          'payment_id', p.payment_id,
          'paid_at', p.paid_at,
          'delivery_status', p.delivery_status,
          'delivery_tracking_url', p.delivery_tracking_url,
          'logistics_meta', coalesce(p.logistics_meta, '{}'::jsonb),
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join lateral (
        select
          jsonb_agg(
            jsonb_build_object(
              'producto_id', i.producto_id,
              'cantidad', i.cantidad,
              'precio_unitario', i.precio_unitario,
              'productos', jsonb_build_object(
                'id', pr.id,
                'nombre', pr.nombre
              )
            )
            order by i.id
          ) as js
        from public.pedido_items i
        join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
      ) pi on true
      where p.cliente_id = v_cli
      order by p.created_at desc
      limit greatest(1, least(coalesce(p_limite, 120), 500))
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.cliente_listar_mis_pedidos(uuid, int) to anon, authenticated;

create or replace function public.empleado_listar_pedidos_tienda_web_pendientes(
  p_session_token uuid,
  p_limit int default 300
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
  v_lim := greatest(1, least(coalesce(p_limit, 300), 500));
  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        jsonb_build_object(
          'id', p.id,
          'total', p.total,
          'created_at', p.created_at,
          'tipo', p.tipo,
          'metodo_pago', p.metodo_pago,
          'estado', p.estado,
          'tipo_entrega', p.tipo_entrega,
          'direccion', p.direccion,
          'payment_provider', p.payment_provider,
          'payment_status', p.payment_status,
          'payment_id', p.payment_id,
          'paid_at', p.paid_at,
          'delivery_status', p.delivery_status,
          'delivery_tracking_url', p.delivery_tracking_url,
          'logistics_meta', coalesce(p.logistics_meta, '{}'::jsonb),
          'costo_envio', p.costo_envio,
          'guest_nombre', p.guest_nombre,
          'guest_telefono', p.guest_telefono,
          'clientes', jsonb_build_object(
            'nombre', cl.nombre,
            'telefono', cl.telefono
          ),
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.clientes cl on cl.id = p.cliente_id
      left join lateral (
        select
          jsonb_agg(
            jsonb_build_object(
              'cantidad', i.cantidad,
              'precio_unitario', i.precio_unitario,
              'productos', jsonb_build_object(
                'nombre', pr.nombre,
                'sku', pr.sku,
                'ubicacion_texto', pr.ubicacion_texto
              )
            )
            order by i.id
          ) as js
        from public.pedido_items i
        join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
      ) pi on true
      where p.estado = 'pendiente'
        and (
          p.tipo = 'online'
          or (
            p.tipo is null
            and lower(trim(coalesce(p.metodo_pago, ''))) = any (array['tarjeta','mercadopago'])
          )
        )
        and public.fn_pedido_online_pago_confirmado(p.metodo_pago, p.payment_status, p.tipo)
      order by p.created_at desc
      limit v_lim
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_pedidos_tienda_web_pendientes(uuid, int) to anon, authenticated;

create or replace function public.empleado_listar_pedidos_online_historial(
  p_session_token uuid,
  p_limite int default 40
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
  v_lim := greatest(1, least(coalesce(p_limite, 40), 200));
  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        jsonb_build_object(
          'id', p.id,
          'total', p.total,
          'created_at', p.created_at,
          'tipo', p.tipo,
          'metodo_pago', p.metodo_pago,
          'estado', p.estado,
          'tipo_entrega', p.tipo_entrega,
          'direccion', p.direccion,
          'delivery_tracking_url', p.delivery_tracking_url,
          'logistics_meta', coalesce(p.logistics_meta, '{}'::jsonb),
          'clientes', jsonb_build_object(
            'nombre', cl.nombre,
            'telefono', cl.telefono
          ),
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.clientes cl on cl.id = p.cliente_id
      left join lateral (
        select
          jsonb_agg(
            jsonb_build_object(
              'cantidad', i.cantidad,
              'precio_unitario', i.precio_unitario,
              'productos', jsonb_build_object(
                'nombre', pr.nombre,
                'sku', pr.sku,
                'ubicacion_texto', pr.ubicacion_texto
              )
            )
            order by i.id
          ) as js
        from public.pedido_items i
        join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
      ) pi on true
      where p.tipo = 'online'
        and (p.estado)::text = any (array['listo','completado'])
      order by p.created_at desc
      limit v_lim
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_pedidos_online_historial(uuid, int) to anon, authenticated;

commit;
