-- Congela el costo vendido en pedido_item_consumos.
-- 24 sep 2026. Idempotente. Pegar en Supabase → SQL Editor. No se ejecuta desde el repo.
--
-- El trigger corre en cada insert de pedido_items (POS, tienda, Rappi, WhatsApp).
-- Si el renglón trae lote, el costo es el del lote. Si no, queda un marcador
-- catalogo_actual hasta que se asigne el lote.
-- La pieza suelta (PR de cajas abiertas) puede saltarse el trigger con
-- set_config('app.fc_consumo_manual', '1', true) y escribir ella el consumo.

begin;

alter table public.lotes
  add column if not exists costo_es_estimado boolean not null default false,
  add column if not exists costo_fuente text;

comment on column public.lotes.costo_es_estimado is
  'True si el costo nació de ticket/OCR y todavía se puede corregir hacia las ventas.';
comment on column public.lotes.costo_fuente is
  'factura, ticket_ocr, recibir, manual o sync.';

create table if not exists public.pedido_item_consumos (
  id                      bigserial primary key,
  pedido_item_id          bigint not null references public.pedido_items(id) on delete cascade,
  lote_id                 bigint references public.lotes(id) on delete set null,
  caja_abierta_id         bigint,
  modo                    text not null check (modo in ('caja', 'unidad')),
  cantidad                numeric not null check (cantidad > 0),
  costo_unitario          numeric(12, 4),
  costo_origen            text not null check (costo_origen in (
    'lote', 'lote_estimado', 'caja_abierta', 'estimado_por_fecha', 'catalogo_actual', 'sin_costo'
  )),
  congelado_at            timestamptz not null default now(),
  costo_unitario_anterior numeric(12, 4),
  ajustado_at             timestamptz,
  ajustado_por            bigint
);

create index if not exists idx_pedido_item_consumos_item
  on public.pedido_item_consumos (pedido_item_id);
create index if not exists idx_pedido_item_consumos_lote
  on public.pedido_item_consumos (lote_id);

alter table public.pedido_item_consumos enable row level security;
revoke all on public.pedido_item_consumos from public, anon, authenticated;

-- Respaldo de ventas que ya tenían lote, antes de cualquier relleno.
create table if not exists public.pedido_items_costo_respaldo_20260924 as
select
  pi.id as pedido_item_id,
  pi.pedido_id,
  pi.producto_id,
  pi.cantidad,
  pi.precio_unitario,
  pi.lote_id,
  l.costo_unitario as costo_lote,
  l.numero_lote,
  p.created_at as vendido_at,
  now() as respaldado_at
from public.pedido_items pi
join public.pedidos p on p.id = pi.pedido_id
left join public.lotes l on l.id = pi.lote_id
where pi.lote_id is not null;

alter table public.pedido_items_costo_respaldo_20260924 enable row level security;
revoke all on public.pedido_items_costo_respaldo_20260924 from public, anon, authenticated;

create or replace function public.fn_pedido_item_congelar_costo()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_costo numeric;
  v_estimado boolean;
  v_origen text;
  v_modo text := 'caja';
begin
  if coalesce(current_setting('app.fc_consumo_manual', true), '') = '1' then
    return NEW;
  end if;

  if TG_OP = 'UPDATE' and NEW.lote_id is not distinct from OLD.lote_id then
    return NEW;
  end if;

  if NEW.lote_id is not null then
    select l.costo_unitario, coalesce(l.costo_es_estimado, false)
      into v_costo, v_estimado
    from public.lotes l
    where l.id = NEW.lote_id;

    if coalesce(v_costo, 0) > 0 and v_estimado then
      v_origen := 'lote_estimado';
    elsif coalesce(v_costo, 0) > 0 then
      v_origen := 'lote';
    else
      v_origen := 'sin_costo';
      v_costo := null;
    end if;

    delete from public.pedido_item_consumos
    where pedido_item_id = NEW.id
      and costo_origen in ('catalogo_actual', 'sin_costo', 'estimado_por_fecha');

    if not exists (
      select 1 from public.pedido_item_consumos c where c.pedido_item_id = NEW.id
    ) then
      insert into public.pedido_item_consumos (
        pedido_item_id, lote_id, modo, cantidad, costo_unitario, costo_origen
      ) values (
        NEW.id, NEW.lote_id, v_modo, NEW.cantidad, v_costo, v_origen
      );
    end if;
    return NEW;
  end if;

  if TG_OP = 'UPDATE' then
    return NEW;
  end if;

  select pr.costo into v_costo
  from public.productos pr
  where pr.id = NEW.producto_id;

  if coalesce(v_costo, 0) > 0 then
    v_origen := 'catalogo_actual';
  else
    v_origen := 'sin_costo';
    v_costo := null;
  end if;

  insert into public.pedido_item_consumos (
    pedido_item_id, lote_id, modo, cantidad, costo_unitario, costo_origen
  ) values (
    NEW.id, null, v_modo, NEW.cantidad, v_costo, v_origen
  );
  return NEW;
end;
$$;

drop trigger if exists trg_pedido_item_congelar_costo on public.pedido_items;
create trigger trg_pedido_item_congelar_costo
  after insert or update of lote_id on public.pedido_items
  for each row
  execute function public.fn_pedido_item_congelar_costo();

-- Relleno del historial. Con lote: costo del lote. Sin lote: último costo de
-- compra anterior a la venta (estimado_por_fecha), o el catálogo, o sin costo.
insert into public.pedido_item_consumos (
  pedido_item_id, lote_id, modo, cantidad, costo_unitario, costo_origen, congelado_at
)
select
  pi.id,
  pi.lote_id,
  case
    when pi.lote_id is not null then 'caja'
    when coalesce(pr.venta_unidad, false)
      and coalesce(pr.unidades_por_caja, 1) > 1
      and (
        (coalesce(pr.precio_unidad, 0) > 0 and abs(pi.precio_unitario - pr.precio_unidad) <= 1)
        or (coalesce(pr.precio, 0) > 0 and pi.precio_unitario < pr.precio * 0.45)
      )
      then 'unidad'
    else 'caja'
  end as modo,
  pi.cantidad,
  case
    when pi.lote_id is not null and coalesce(l.costo_unitario, 0) > 0 then l.costo_unitario
    when pi.lote_id is not null then null
    when hist.costo is not null and coalesce(pr.venta_unidad, false)
      and coalesce(pr.unidades_por_caja, 1) > 1
      and (
        (coalesce(pr.precio_unidad, 0) > 0 and abs(pi.precio_unitario - pr.precio_unidad) <= 1)
        or (coalesce(pr.precio, 0) > 0 and pi.precio_unitario < pr.precio * 0.45)
      )
      then round(hist.costo / pr.unidades_por_caja, 4)
    when hist.costo is not null then hist.costo
    when coalesce(pr.costo, 0) > 0 and coalesce(pr.venta_unidad, false)
      and coalesce(pr.unidades_por_caja, 1) > 1
      and (
        (coalesce(pr.precio_unidad, 0) > 0 and abs(pi.precio_unitario - pr.precio_unidad) <= 1)
        or (coalesce(pr.precio, 0) > 0 and pi.precio_unitario < pr.precio * 0.45)
      )
      then round(pr.costo / pr.unidades_por_caja, 4)
    when coalesce(pr.costo, 0) > 0 then pr.costo
    else null
  end as costo_unitario,
  case
    when pi.lote_id is not null and coalesce(l.costo_unitario, 0) > 0 and coalesce(l.costo_es_estimado, false)
      then 'lote_estimado'
    when pi.lote_id is not null and coalesce(l.costo_unitario, 0) > 0 then 'lote'
    when pi.lote_id is not null then 'sin_costo'
    when hist.costo is not null then 'estimado_por_fecha'
    when coalesce(pr.costo, 0) > 0 then 'catalogo_actual'
    else 'sin_costo'
  end as costo_origen,
  p.created_at
from public.pedido_items pi
join public.pedidos p on p.id = pi.pedido_id
left join public.productos pr on pr.id = pi.producto_id
left join public.lotes l on l.id = pi.lote_id
left join lateral (
  select l2.costo_unitario as costo
  from public.lotes l2
  where l2.producto_id = pi.producto_id
    and l2.created_at <= p.created_at
    and coalesce(l2.costo_unitario, 0) > 0
  order by l2.created_at desc
  limit 1
) hist on pi.lote_id is null
where not exists (
  select 1 from public.pedido_item_consumos c where c.pedido_item_id = pi.id
);

-- Pedido en línea: al comprometer stock, el renglón queda con lote_id
-- (y se parte si cruza dos lotes). El trigger sustituye el marcador.
create or replace function public.fn_pedido_item_asignar_lotes_fefo(
  p_item_id bigint,
  p_actor bigint,
  p_motivo text
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_item public.pedido_items%rowtype;
  v_restante integer;
  v_lote_id bigint;
  v_disp integer;
  v_tomar integer;
  v_primero boolean := true;
begin
  select * into v_item from public.pedido_items where id = p_item_id for update;
  if not found then
    return 0;
  end if;
  if v_item.lote_id is not null then
    return 0;
  end if;

  v_restante := v_item.cantidad::integer;
  if v_restante is null or v_restante <= 0 then
    return 0;
  end if;

  perform public.fn_ensure_lote_stock_vendible(v_item.producto_id);

  while v_restante > 0 loop
    select l.id, coalesce(l.cantidad_actual, 0)
      into v_lote_id, v_disp
    from public.lotes l
    where l.producto_id = v_item.producto_id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
      and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date)
    order by l.fecha_caducidad asc nulls last, l.id asc
    limit 1
    for update;

    if not found then
      raise exception 'sin lotes FEFO para producto %', v_item.producto_id;
    end if;

    v_tomar := least(v_restante, v_disp);
    update public.lotes
    set cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - v_tomar),
        activo = case
          when greatest(0, coalesce(cantidad_actual, 0) - v_tomar) <= 0 then false
          else activo
        end
    where id = v_lote_id;

    if v_primero then
      update public.pedido_items
      set cantidad = v_tomar, lote_id = v_lote_id
      where id = v_item.id;
      v_primero := false;
    else
      insert into public.pedido_items (pedido_id, producto_id, cantidad, precio_unitario, lote_id)
      values (v_item.pedido_id, v_item.producto_id, v_tomar, v_item.precio_unitario, v_lote_id);
    end if;

    v_restante := v_restante - v_tomar;
  end loop;

  insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo, usuario_id, referencia)
  values (
    v_item.producto_id, 'salida', v_item.cantidad::integer,
    coalesce(p_motivo, 'Pedido online'),
    p_actor::integer, v_item.pedido_id::text
  );

  return 1;
end;
$$;

create or replace function public.fn_pedido_online_comprometer_stock(p_pedido_id bigint)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_pedido record;
  v_item   record;
  v_actor  bigint;
  v_n      int := 0;
begin
  select id, tipo, estado, stock_consumido_at
    into v_pedido
  from public.pedidos
  where id = p_pedido_id
  for update;

  if v_pedido.id is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;
  if coalesce(v_pedido.tipo, '') <> 'online' then
    return 0;
  end if;
  if v_pedido.stock_consumido_at is not null then
    return 0;
  end if;
  if v_pedido.estado = 'cancelado' then
    return 0;
  end if;

  v_actor := public.fn_actor_sistema_inventario();
  if v_actor is null then
    raise exception 'No hay usuario admin/gerente para registrar el movimiento de stock online';
  end if;

  for v_item in
    select id, producto_id, cantidad, lote_id
    from public.pedido_items
    where pedido_id = p_pedido_id
    order by id
  loop
    if v_item.producto_id is null or coalesce(v_item.cantidad, 0) <= 0 then
      continue;
    end if;
    if v_item.lote_id is not null then
      continue;
    end if;
    if exists (
      select 1 from public.productos p
      where p.id = v_item.producto_id and coalesce(p.bajo_pedido, false)
    ) then
      continue;
    end if;

    v_n := v_n + public.fn_pedido_item_asignar_lotes_fefo(
      v_item.id,
      v_actor,
      'Pedido online #' || p_pedido_id
    );
  end loop;

  update public.pedidos
     set stock_consumido_at = now()
   where id = p_pedido_id;

  return v_n;
end;
$$;

commit;
