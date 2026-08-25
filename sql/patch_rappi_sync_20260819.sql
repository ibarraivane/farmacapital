-- ============================================================
-- FARMACAPITAL — Sincronización de disponibilidad → Rappi
-- ============================================================
-- Idempotente. Correr en Supabase SQL Editor.
--
-- Qué hace:
--   1) Tabla rappi_sync_queue + trigger en productos.stock (y flags
--      de elegibilidad). Encola SOLO cambios de disponible_rappi o
--      si stock_rappi cruza el umbral de 5.
--      stock_rappi = GREATEST(stock - reserva_mostrador, 0)
--      reserva_mostrador = configuracion.rappi_reserva_mostrador (default 2)
--   2) Worker (Vercel /api/webhooks/rappi-sync) drena la cola.
--      No llama a Rappi desde este trigger.
--   3) RPC ingest_rappi_order: pedido entrante descuenta stock y
--      guarda external_order_id en pedidos.logistics_meta.
--
-- Hobby de Vercel: el cron mínimo es diario. NO uses */2 * * * *.
-- Para casi tiempo real: Database Webhook (INSERT en rappi_sync_queue)
-- → POST https://TU-DOMINIO/api/webhooks/rappi-sync
--   Header: Authorization: Bearer <CRON_SECRET>
-- O un cron externo (cron-job.org) cada 2 min al mismo URL.
--
-- Pide al KAM: client_id, client_secret, store_id, y la URL exacta
-- de Disponibilidad del Developer Portal. Sin RAPPI_API_BASE el
-- worker queda inerte (no truena).
-- ============================================================

begin;

alter table public.pedidos
  add column if not exists logistics_meta jsonb not null default '{}'::jsonb;

create table if not exists public.rappi_sync_queue (
  id            bigserial primary key,
  producto_id   bigint references public.productos(id) on delete set null,
  sku           text not null,
  accion        text not null default 'disponibilidad'
                  check (accion in ('disponibilidad')),
  payload       jsonb not null default '{}'::jsonb,
  intentos      integer not null default 0,
  estado        text not null default 'pendiente'
                  check (estado in ('pendiente', 'procesando', 'ok', 'error', 'omitido')),
  last_error    text,
  available_at  timestamptz not null default now(),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  processed_at  timestamptz
);

create unique index if not exists rappi_sync_queue_sku_pendiente_uidx
  on public.rappi_sync_queue (sku)
  where estado = 'pendiente';

create index if not exists rappi_sync_queue_drain_idx
  on public.rappi_sync_queue (estado, available_at, created_at);

create index if not exists rappi_sync_queue_error_idx
  on public.rappi_sync_queue (created_at desc)
  where estado = 'error';

create unique index if not exists pedidos_rappi_external_order_uidx
  on public.pedidos ((logistics_meta->>'external_order_id'))
  where coalesce(logistics_meta->>'logistics_provider', '') = 'rappi'
    and coalesce(logistics_meta->>'external_order_id', '') <> '';

comment on table public.rappi_sync_queue is
  'Cola de push de disponibilidad a Rappi. El trigger solo encola; el worker en /api/webhooks/rappi-sync hace el HTTP.';

insert into public.configuracion (clave, valor)
values
  ('rappi_sync_paused', 'false'),
  ('rappi_reserva_mostrador', '2')
on conflict (clave) do nothing;

-- ── helpers ────────────────────────────────────────────────
create or replace function public.rappi_cfg_int(p_clave text, p_default integer)
returns integer
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v text;
  n integer;
begin
  select c.valor into v
  from public.configuracion c
  where c.clave = p_clave
  limit 1;
  begin
    n := trim(coalesce(v, ''))::integer;
  exception when others then
    n := null;
  end;
  if n is null or n < 0 then
    return p_default;
  end if;
  return n;
end;
$$;

-- Elegible para Rappi: activo y sin receta.
-- No se usa productos.controlado: esa columna no existe en producción.
drop function if exists public.rappi_producto_eligible(public.productos);
drop function if exists public.rappi_producto_eligible(boolean, boolean);

create or replace function public.rappi_producto_eligible(
  p_activo boolean,
  p_requiere_receta boolean
)
returns boolean
language sql
immutable
as $$
  select coalesce(p_activo, true)
     and not coalesce(p_requiere_receta, false);
$$;

create or replace function public.rappi_stock_publicado(p_stock integer, p_reserva integer)
returns integer
language sql
immutable
as $$
  select greatest(coalesce(p_stock, 0) - greatest(coalesce(p_reserva, 2), 0), 0);
$$;

-- ── trigger: encolar solo cambios de estado ────────────────
create or replace function public.trg_productos_rappi_sync_queue()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_reserva integer;
  v_sku text;
  v_old_sr integer;
  v_new_sr integer;
  v_old_disp boolean;
  v_new_disp boolean;
  v_old_elig boolean;
  v_new_elig boolean;
  v_enqueue boolean := false;
  v_reason text;
begin
  v_sku := nullif(btrim(coalesce(new.sku, '')), '');
  if v_sku is null then
    return new;
  end if;

  v_reserva := public.rappi_cfg_int('rappi_reserva_mostrador', 2);
  v_new_elig := public.rappi_producto_eligible(new.activo, new.requiere_receta);
  v_new_sr := public.rappi_stock_publicado(new.stock, v_reserva);
  v_new_disp := v_new_elig and v_new_sr > 0;

  if tg_op = 'INSERT' then
    v_enqueue := v_new_disp;
    v_reason := 'insert';
  else
    v_old_elig := public.rappi_producto_eligible(old.activo, old.requiere_receta);
    v_old_sr := public.rappi_stock_publicado(old.stock, v_reserva);
    v_old_disp := v_old_elig and v_old_sr > 0;

    if v_old_disp is distinct from v_new_disp then
      v_enqueue := true;
      v_reason := 'availability';
    elsif v_new_disp and ((v_old_sr <= 5) is distinct from (v_new_sr <= 5)) then
      v_enqueue := true;
      v_reason := 'threshold';
    end if;
  end if;

  if not v_enqueue then
    return new;
  end if;

  insert into public.rappi_sync_queue (
    producto_id, sku, accion, payload, estado, available_at
  ) values (
    new.id,
    v_sku,
    'disponibilidad',
    jsonb_build_object(
      'sku', v_sku,
      'producto_id', new.id,
      'stock_local', coalesce(new.stock, 0),
      'reserva_mostrador', v_reserva,
      'stock_rappi', v_new_sr,
      'disponible', v_new_disp,
      'eligible', v_new_elig,
      'reason', v_reason
    ),
    'pendiente',
    now()
  )
  on conflict (sku) where (estado = 'pendiente')
  do update set
    producto_id = excluded.producto_id,
    payload = excluded.payload,
    updated_at = now(),
    available_at = least(public.rappi_sync_queue.available_at, now());

  return new;
end;
$$;

drop trigger if exists trg_productos_rappi_sync on public.productos;
create trigger trg_productos_rappi_sync
  after insert or update of stock, activo, requiere_receta
  on public.productos
  for each row
  execute procedure public.trg_productos_rappi_sync_queue();

-- ── claim batch (service_role) ─────────────────────────────
create or replace function public.rappi_claim_sync_batch(p_limit integer default 25)
returns setof public.rappi_sync_queue
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_limit integer := greatest(1, least(coalesce(p_limit, 25), 100));
begin
  update public.rappi_sync_queue
     set estado = 'pendiente',
         updated_at = now(),
         available_at = now()
   where estado = 'procesando'
     and coalesce(updated_at, created_at) < now() - interval '10 minutes';

  return query
  update public.rappi_sync_queue q
     set estado = 'procesando',
         intentos = q.intentos + 1,
         updated_at = now()
    from (
      select id
        from public.rappi_sync_queue
       where estado = 'pendiente'
         and available_at <= now()
       order by created_at
       limit v_limit
       for update skip locked
    ) s
   where q.id = s.id
   returning q.*;
end;
$$;

revoke all on function public.rappi_claim_sync_batch(integer) from public, anon, authenticated;
grant execute on function public.rappi_claim_sync_batch(integer) to service_role;

-- ── ingest pedido Rappi ────────────────────────────────────
create or replace function public.ingest_rappi_order(p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_ext text;
  v_existing bigint;
  v_item jsonb;
  v_sku text;
  v_qty integer;
  v_prod public.productos%rowtype;
  v_total numeric := 0;
  v_pedido_id bigint;
  v_stock_antes integer;
  v_stock_nuevo integer;
  v_lotes_activos integer;
  v_lotes_disponibles integer;
  v_restante integer;
  v_lote_id bigint;
  v_lote_numero text;
  v_lote_caducidad date;
  v_lote_disponible integer;
  v_lote_tomar integer;
  v_items jsonb := '[]'::jsonb;
begin
  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    return jsonb_build_object('ok', false, 'error', 'payload_invalido');
  end if;

  v_ext := nullif(btrim(coalesce(
    p_payload->>'external_order_id',
    p_payload->>'order_id',
    ''
  )), '');
  if v_ext is null then
    return jsonb_build_object('ok', false, 'error', 'falta_external_order_id');
  end if;

  if jsonb_typeof(p_payload->'items') is distinct from 'array'
     or jsonb_array_length(p_payload->'items') = 0 then
    return jsonb_build_object('ok', false, 'error', 'sin_items');
  end if;

  select p.id into v_existing
    from public.pedidos p
   where coalesce(p.logistics_meta->>'logistics_provider', '') = 'rappi'
     and p.logistics_meta->>'external_order_id' = v_ext
   limit 1;
  if v_existing is not null then
    return jsonb_build_object('ok', true, 'already_ingested', true, 'pedido_id', v_existing);
  end if;

  -- Validar + total (lock de filas en el segundo loop).
  for v_item in select value from jsonb_array_elements(p_payload->'items')
  loop
    v_sku := nullif(btrim(coalesce(v_item->>'sku', '')), '');
    begin
      v_qty := nullif(coalesce(v_item->>'qty', v_item->>'cantidad', ''), '')::integer;
    exception when others then
      v_qty := null;
    end;
    if v_sku is null or v_qty is null or v_qty <= 0 then
      return jsonb_build_object('ok', false, 'error', 'item_invalido', 'sku', v_sku);
    end if;

    select * into v_prod
      from public.productos
     where sku = v_sku
     limit 1;
    if not found then
      return jsonb_build_object('ok', false, 'error', 'sku_no_existe', 'sku', v_sku);
    end if;
    v_total := v_total + (coalesce(v_prod.precio, 0) * v_qty);
    v_items := v_items || jsonb_build_array(jsonb_build_object(
      'producto_id', v_prod.id,
      'sku', v_sku,
      'qty', v_qty,
      'precio', coalesce(v_prod.precio, 0)
    ));
  end loop;

  insert into public.pedidos (
    total, estado, tipo, tipo_entrega, metodo_pago, notas, logistics_meta
  ) values (
    round(v_total, 2),
    'pendiente',
    'online',
    'envio',
    'rappi',
    'Pedido Rappi ' || v_ext,
    jsonb_build_object(
      'order_channel', 'rappi_marketplace',
      'fulfillment_type', 'marketplace_courier',
      'logistics_provider', 'rappi',
      'external_order_id', v_ext,
      'store_id', p_payload->>'store_id',
      'ingested_at', now()
    )
  )
  returning id into v_pedido_id;

  for v_item in select value from jsonb_array_elements(v_items)
  loop
    v_qty := (v_item->>'qty')::integer;

    select * into v_prod
      from public.productos
     where id = (v_item->>'producto_id')::bigint
     for update;

    v_stock_antes := coalesce(v_prod.stock, 0);
    if v_stock_antes < v_qty then
      raise exception 'stock insuficiente para % (stock %, pedido %)',
        v_prod.sku, v_stock_antes, v_qty;
    end if;

    select count(*)::integer into v_lotes_activos
      from public.lotes l
     where l.producto_id = v_prod.id
       and l.activo = true;

    if v_lotes_activos > 0 then
      select coalesce(sum(l.cantidad_actual), 0)::integer
        into v_lotes_disponibles
        from public.lotes l
       where l.producto_id = v_prod.id
         and l.activo = true
         and coalesce(l.cantidad_actual, 0) > 0
         and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date);

      if coalesce(v_lotes_disponibles, 0) < v_qty then
        raise exception 'lotes FEFO insuficientes para %', v_prod.sku;
      end if;

      v_restante := v_qty;
      while v_restante > 0 loop
        select f.lote_id, f.numero_lote, f.fecha_caducidad, f.cantidad_disponible
          into v_lote_id, v_lote_numero, v_lote_caducidad, v_lote_disponible
          from public.get_lote_fefo(v_prod.id) f;

        if not found then
          raise exception 'sin lotes FEFO para %', v_prod.sku;
        end if;

        v_lote_tomar := least(v_restante, coalesce(v_lote_disponible, 0));
        if v_lote_tomar <= 0 then
          raise exception 'lote FEFO inválido para %', v_prod.sku;
        end if;

        update public.lotes
           set cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - v_lote_tomar),
               activo = case
                 when greatest(0, coalesce(cantidad_actual, 0) - v_lote_tomar) <= 0 then false
                 else activo
               end
         where id = v_lote_id;

        insert into public.pedido_items (
          pedido_id, producto_id, cantidad, precio_unitario, lote_id
        ) values (
          v_pedido_id, v_prod.id, v_lote_tomar, (v_item->>'precio')::numeric,
          v_lote_id
        );

        v_restante := v_restante - v_lote_tomar;
      end loop;
    else
      insert into public.pedido_items (
        pedido_id, producto_id, cantidad, precio_unitario
      ) values (
        v_pedido_id, v_prod.id, v_qty, (v_item->>'precio')::numeric
      );
    end if;

    -- Con lotes, el trigger trg_sync_productos_stock ya dejó productos.stock
    -- en la suma PEPS. No reescribir: desfasaba caché vs lotes.
    if v_lotes_activos = 0 then
      v_stock_nuevo := v_stock_antes - v_qty;
      update public.productos
         set stock = v_stock_nuevo
       where id = v_prod.id;
    else
      select coalesce(stock, 0) into v_stock_nuevo
        from public.productos where id = v_prod.id;
    end if;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo, usuario_id, referencia
    ) values (
      v_prod.id, 'salida', v_qty,
      format('Rappi %s pedido #%s', v_ext, v_pedido_id),
      null, v_pedido_id::text
    );
  end loop;

  return jsonb_build_object('ok', true, 'pedido_id', v_pedido_id, 'external_order_id', v_ext);
exception
  when unique_violation then
    select p.id into v_existing
      from public.pedidos p
     where coalesce(p.logistics_meta->>'logistics_provider', '') = 'rappi'
       and p.logistics_meta->>'external_order_id' = v_ext
     limit 1;
    return jsonb_build_object(
      'ok', true,
      'already_ingested', true,
      'pedido_id', v_existing
    );
end;
$$;

revoke all on function public.ingest_rappi_order(jsonb) from public, anon, authenticated;
grant execute on function public.ingest_rappi_order(jsonb) to service_role;

grant select on public.rappi_sync_queue to anon, authenticated;
revoke insert, update, delete on public.rappi_sync_queue from anon, authenticated;
grant all on public.rappi_sync_queue to service_role;
grant usage, select on sequence public.rappi_sync_queue_id_seq to service_role;

commit;
