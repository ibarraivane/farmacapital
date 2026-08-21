-- =============================================================================
-- FARMA CAPITAL — Recepción de mercancía + FEFO con NULL primero + alerta 90d
-- 21 ago 2026. Idempotente. Pegar entero en Supabase → SQL Editor.
--
-- 1) FEFO: lotes sin fecha de caducidad se venden PRIMERO (stock ciego viejo),
--    no al final. Si no, el lote nuevo con fecha se agota y el viejo se pudre.
-- 2) Alertas de caducidad a 90 días (dashboard).
-- 3) Documento de recepción (recepciones + recepcion_items) para la vendedora:
--    cabecera del ticket + renglones con pistola. El costo NO lo captura ella;
--    se copia el último de productos. Al cerrar se crean los lotes.
-- =============================================================================

begin;

-- ── 1) FEFO: unknown dates first ─────────────────────────────────────────────
create or replace function public.get_lote_fefo(
  p_producto_id bigint
)
returns table(
  lote_id bigint,
  numero_lote text,
  fecha_caducidad date,
  cantidad_disponible integer
)
language sql
security definer
set search_path = public
as $$
  select
    l.id as lote_id,
    l.numero_lote,
    l.fecha_caducidad,
    coalesce(l.cantidad_actual, 0)::integer as cantidad_disponible
  from public.lotes l
  where l.producto_id = p_producto_id
    and l.activo = true
    and coalesce(l.cantidad_actual, 0) > 0
    and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date)
  order by l.fecha_caducidad asc nulls first, l.id asc
  limit 1;
$$;

comment on function public.get_lote_fefo(bigint) is
  'FEFO: sin fecha primero (stock ciego), luego la caducidad más próxima. No vende vencidos.';

grant execute on function public.get_lote_fefo(bigint) to anon, authenticated, service_role;

create or replace function public.consume_stock_via_lotes(
  p_producto_id bigint,
  p_cantidad integer,
  p_motivo text,
  p_user_id bigint,
  p_referencia text default null
)
returns table(stock_nuevo integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_lote_id bigint;
  v_lote_cantidad integer;
  v_restante integer;
  v_disponible integer;
begin
  if p_producto_id is null then
    raise exception 'producto_id requerido';
  end if;
  if p_cantidad is null or p_cantidad <= 0 then
    raise exception 'cantidad invalida';
  end if;
  if p_user_id is null then
    raise exception 'user_id requerido';
  end if;

  perform 1 from public.productos p where p.id = p_producto_id for update;
  if not found then
    raise exception 'producto % no existe', p_producto_id;
  end if;

  select coalesce(sum(l.cantidad_actual), 0)::integer
    into v_disponible
  from public.lotes l
  where l.producto_id = p_producto_id
    and coalesce(l.activo, true) = true
    and coalesce(l.cantidad_actual, 0) > 0
    and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date);

  if coalesce(v_disponible, 0) < p_cantidad then
    raise exception 'stock insuficiente para producto % (disponible %, solicitado %)',
      p_producto_id, coalesce(v_disponible, 0), p_cantidad;
  end if;

  v_restante := p_cantidad;
  while v_restante > 0 loop
    select l.id, coalesce(l.cantidad_actual, 0)
      into v_lote_id, v_lote_cantidad
    from public.lotes l
    where l.producto_id = p_producto_id
      and coalesce(l.activo, true) = true
      and coalesce(l.cantidad_actual, 0) > 0
      and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date)
    order by l.fecha_caducidad asc nulls first, l.id asc
    limit 1
    for update;

    if not found then
      raise exception 'sin lotes disponibles para producto %', p_producto_id;
    end if;

    if v_lote_cantidad >= v_restante then
      update public.lotes
      set
        cantidad_actual = cantidad_actual - v_restante,
        activo = case
          when (cantidad_actual - v_restante) <= 0 then false
          else activo
        end
      where id = v_lote_id;
      v_restante := 0;
    else
      update public.lotes
      set cantidad_actual = 0, activo = false
      where id = v_lote_id;
      v_restante := v_restante - v_lote_cantidad;
    end if;
  end loop;

  insert into public.movimientos_inventario (
    producto_id, tipo, cantidad, motivo, usuario_id, referencia
  ) values (
    p_producto_id, 'salida', p_cantidad,
    coalesce(p_motivo, 'Consumo'),
    p_user_id, p_referencia
  );

  return query
  select p.stock from public.productos p where p.id = p_producto_id;
end;
$$;

grant execute on function public.consume_stock_via_lotes(
  bigint, integer, text, bigint, text
) to anon, authenticated, service_role;


-- ── 2) Dashboard: caducidad a 90 días ────────────────────────────────────────
create or replace function public.empleado_contar_por_caducar(
  p_session_token uuid,
  p_dias integer default 90
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_dias integer;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_dias := greatest(1, least(coalesce(p_dias, 90), 365));
  return coalesce((
    select jsonb_build_object(
      'dias', v_dias,
      'count', count(*)::int,
      'productos', coalesce(
        jsonb_agg(jsonb_build_object('producto_id', q.producto_id) order by q.producto_id),
        '[]'::jsonb
      )
    )
    from (
      select distinct l.producto_id
      from public.lotes l
      where coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.fecha_caducidad is not null
        and l.fecha_caducidad >= current_date
        and l.fecha_caducidad <= (current_date + make_interval(days => v_dias))
    ) q
  ), jsonb_build_object('dias', v_dias, 'count', 0, 'productos', '[]'::jsonb));
end;
$$;

grant execute on function public.empleado_contar_por_caducar(uuid, integer)
  to anon, authenticated;


-- ── 3) Tablas del documento de recepción ─────────────────────────────────────
create table if not exists public.recepciones (
  id                bigserial primary key,
  proveedor         text,
  folio             text,
  fecha             date not null default current_date,
  total_ticket      numeric(12,2),
  estado            text not null default 'borrador',
  capturado_por     bigint references public.usuarios(id),
  cerrado_en        timestamptz,
  subtotal_estimado numeric(12,2),
  diferencia        numeric(12,2),
  notas             text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  constraint recepciones_estado_chk
    check (estado in ('borrador', 'confirmada', 'descuadre', 'pendiente_alta'))
);

create table if not exists public.recepcion_items (
  id                bigserial primary key,
  recepcion_id      bigint not null references public.recepciones(id) on delete cascade,
  producto_id       bigint references public.productos(id),
  codigo_escaneado  text,
  nombre_snapshot   text,
  cantidad          integer not null check (cantidad > 0),
  fecha_caducidad   date,
  numero_lote       text,
  costo_estimado    numeric(12,2),
  pendiente_alta    boolean not null default false,
  lote_id           bigint references public.lotes(id),
  created_at        timestamptz not null default now()
);

create index if not exists recepciones_estado_idx
  on public.recepciones (estado, updated_at desc);
create index if not exists recepcion_items_recepcion_idx
  on public.recepcion_items (recepcion_id);

alter table public.recepciones enable row level security;
alter table public.recepcion_items enable row level security;

revoke all on public.recepciones from public, anon, authenticated;
revoke all on public.recepcion_items from public, anon, authenticated;
grant all on public.recepciones to service_role;
grant all on public.recepcion_items to service_role;
grant usage, select on sequence public.recepciones_id_seq to service_role;
grant usage, select on sequence public.recepcion_items_id_seq to service_role;


-- ── 4) Helpers ───────────────────────────────────────────────────────────────
create or replace function public.fc_match_codigo_barras(p_scan text, p_stored text)
returns boolean
language sql
immutable
parallel safe
as $$
  select
    case
      when coalesce(btrim(p_scan), '') = '' or coalesce(btrim(p_stored), '') = '' then false
      when replace(p_scan, ' ', '') = replace(p_stored, ' ', '') then true
      when length(replace(p_scan, ' ', '')) = 12
        and length(replace(p_stored, ' ', '')) = 13
        and replace(p_stored, ' ', '') = '0' || replace(p_scan, ' ', '') then true
      when length(replace(p_stored, ' ', '')) = 12
        and length(replace(p_scan, ' ', '')) = 13
        and replace(p_scan, ' ', '') = '0' || replace(p_stored, ' ', '') then true
      else false
    end;
$$;

create or replace function public.fc_buscar_producto_escaneo(p_codigo text)
returns bigint
language plpgsql
stable
set search_path = public
as $$
declare
  v_codigo text;
  v_id bigint;
  v_n int;
begin
  v_codigo := btrim(coalesce(p_codigo, ''));
  if v_codigo = '' then
    return null;
  end if;

  select count(*), min(p.id)
    into v_n, v_id
  from public.productos p
  where coalesce(p.activo, true)
    and (
      public.fc_match_codigo_barras(v_codigo, p.codigo_barras)
      or upper(btrim(coalesce(p.sku, ''))) = upper(v_codigo)
    );

  if v_n = 1 then
    return v_id;
  end if;
  if v_n > 1 then
    select p.id into v_id
    from public.productos p
    where coalesce(p.activo, true)
      and public.fc_match_codigo_barras(v_codigo, p.codigo_barras)
    order by p.id
    limit 1;
    if v_id is not null then
      return v_id;
    end if;
    select p.id into v_id
    from public.productos p
    where coalesce(p.activo, true)
      and upper(btrim(coalesce(p.sku, ''))) = upper(v_codigo)
    order by p.id
    limit 1;
    return v_id;
  end if;
  return null;
end;
$$;

create or replace function public.fc_recepcion_json(p_recepcion_id bigint)
returns jsonb
language plpgsql
stable
set search_path = public
as $$
declare
  v_rec public.recepciones%rowtype;
  v_items jsonb;
  v_subtotal numeric;
  v_renglones int;
  v_piezas int;
  v_pendientes int;
begin
  select * into v_rec from public.recepciones where id = p_recepcion_id;
  if not found then
    return null;
  end if;

  select
    coalesce(jsonb_agg(
      jsonb_build_object(
        'id', i.id,
        'producto_id', i.producto_id,
        'codigo_escaneado', i.codigo_escaneado,
        'nombre', coalesce(pr.nombre, i.nombre_snapshot, i.codigo_escaneado),
        'sku', pr.sku,
        'cantidad', i.cantidad,
        'fecha_caducidad', i.fecha_caducidad,
        'pendiente_alta', i.pendiente_alta,
        'lote_id', i.lote_id
      )
      order by i.id
    ), '[]'::jsonb),
    coalesce(sum(i.cantidad * coalesce(i.costo_estimado, 0)), 0),
    count(*)::int,
    coalesce(sum(i.cantidad), 0)::int,
    count(*) filter (where i.pendiente_alta)::int
  into v_items, v_subtotal, v_renglones, v_piezas, v_pendientes
  from public.recepcion_items i
  left join public.productos pr on pr.id = i.producto_id
  where i.recepcion_id = p_recepcion_id;

  return jsonb_build_object(
    'id', v_rec.id,
    'proveedor', v_rec.proveedor,
    'folio', v_rec.folio,
    'fecha', v_rec.fecha,
    'total_ticket', v_rec.total_ticket,
    'estado', v_rec.estado,
    'capturado_por', v_rec.capturado_por,
    'subtotal_estimado', round(v_subtotal, 2),
    'diferencia', case
      when v_rec.total_ticket is null then null
      else round(v_subtotal - v_rec.total_ticket, 2)
    end,
    'renglones', v_renglones,
    'piezas', v_piezas,
    'pendientes_alta', v_pendientes,
    'updated_at', v_rec.updated_at,
    'cerrado_en', v_rec.cerrado_en,
    'items', v_items
  );
end;
$$;


-- ── 5) RPCs de recepción ─────────────────────────────────────────────────────
create or replace function public.recepcion_borrador_abierto(
  p_session_token uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_id bigint;
begin
  v_user := public.fn_require_empleado(p_session_token);
  select r.id into v_id
  from public.recepciones r
  where r.estado = 'borrador'
  order by r.updated_at desc
  limit 1;
  if v_id is null then
    return jsonb_build_object('recepcion', null);
  end if;
  return jsonb_build_object('recepcion', public.fc_recepcion_json(v_id), 'actor_id', v_user);
end;
$$;

create or replace function public.recepcion_abrir(
  p_session_token uuid,
  p_proveedor text default null,
  p_folio text default null,
  p_total_ticket numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_id bigint;
begin
  v_user := public.fn_require_empleado(p_session_token);

  select r.id into v_id
  from public.recepciones r
  where r.estado = 'borrador'
  order by r.updated_at desc
  limit 1;

  if v_id is not null then
    update public.recepciones
    set
      proveedor = coalesce(nullif(btrim(p_proveedor), ''), proveedor),
      folio = coalesce(nullif(btrim(p_folio), ''), folio),
      total_ticket = coalesce(p_total_ticket, total_ticket),
      updated_at = now()
    where id = v_id;
    return public.fc_recepcion_json(v_id);
  end if;

  insert into public.recepciones (proveedor, folio, total_ticket, capturado_por)
  values (
    nullif(btrim(p_proveedor), ''),
    nullif(btrim(p_folio), ''),
    p_total_ticket,
    v_user
  )
  returning id into v_id;

  return public.fc_recepcion_json(v_id);
end;
$$;

create or replace function public.recepcion_guardar_cabecera(
  p_session_token uuid,
  p_recepcion_id bigint,
  p_proveedor text default null,
  p_folio text default null,
  p_total_ticket numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_estado text;
begin
  v_user := public.fn_require_empleado(p_session_token);
  select estado into v_estado from public.recepciones where id = p_recepcion_id;
  if not found then
    raise exception 'recepcion no existe';
  end if;
  if v_estado <> 'borrador' then
    raise exception 'solo se edita una recepcion en borrador';
  end if;

  update public.recepciones
  set
    proveedor = coalesce(nullif(btrim(p_proveedor), ''), proveedor),
    folio = coalesce(nullif(btrim(p_folio), ''), folio),
    total_ticket = p_total_ticket,
    updated_at = now()
  where id = p_recepcion_id;

  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

create or replace function public.recepcion_agregar_item(
  p_session_token uuid,
  p_recepcion_id bigint,
  p_codigo text,
  p_cantidad integer,
  p_fecha_caducidad date default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_estado text;
  v_codigo text;
  v_producto_id bigint;
  v_nombre text;
  v_costo numeric;
  v_item_id bigint;
  v_pendiente boolean := false;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_cantidad is null or p_cantidad <= 0 then
    raise exception 'cantidad invalida';
  end if;

  select estado into v_estado from public.recepciones where id = p_recepcion_id for update;
  if not found then
    raise exception 'recepcion no existe';
  end if;
  if v_estado <> 'borrador' then
    raise exception 'solo se edita una recepcion en borrador';
  end if;

  v_codigo := btrim(coalesce(p_codigo, ''));
  if v_codigo = '' then
    raise exception 'codigo requerido';
  end if;

  v_producto_id := public.fc_buscar_producto_escaneo(v_codigo);

  if v_producto_id is not null then
    select nombre, costo into v_nombre, v_costo
    from public.productos where id = v_producto_id;
  else
    if v_codigo ~ '^[0-9]{8,}$' then
      v_pendiente := true;
      v_nombre := 'Pendiente de alta';
    else
      raise exception 'Producto no encontrado. Escanea el codigo de barras de la caja.';
    end if;
  end if;

  if v_pendiente then
    select id into v_item_id
    from public.recepcion_items
    where recepcion_id = p_recepcion_id
      and pendiente_alta
      and codigo_escaneado = v_codigo
      and fecha_caducidad is not distinct from p_fecha_caducidad
    limit 1;
  else
    select id into v_item_id
    from public.recepcion_items
    where recepcion_id = p_recepcion_id
      and not pendiente_alta
      and producto_id = v_producto_id
      and fecha_caducidad is not distinct from p_fecha_caducidad
    limit 1;
  end if;

  if v_item_id is not null then
    update public.recepcion_items
    set cantidad = cantidad + p_cantidad
    where id = v_item_id;
  else
    insert into public.recepcion_items (
      recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
      cantidad, fecha_caducidad, costo_estimado, pendiente_alta
    ) values (
      p_recepcion_id, v_producto_id, v_codigo, v_nombre,
      p_cantidad, p_fecha_caducidad, v_costo, v_pendiente
    )
    returning id into v_item_id;
  end if;

  update public.recepciones set updated_at = now() where id = p_recepcion_id;
  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

create or replace function public.recepcion_quitar_item(
  p_session_token uuid,
  p_item_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_recepcion_id bigint;
  v_estado text;
begin
  v_user := public.fn_require_empleado(p_session_token);
  select i.recepcion_id, r.estado
    into v_recepcion_id, v_estado
  from public.recepcion_items i
  join public.recepciones r on r.id = i.recepcion_id
  where i.id = p_item_id;
  if not found then
    raise exception 'renglon no existe';
  end if;
  if v_estado <> 'borrador' then
    raise exception 'solo se edita una recepcion en borrador';
  end if;
  delete from public.recepcion_items where id = p_item_id;
  update public.recepciones set updated_at = now() where id = v_recepcion_id;
  return public.fc_recepcion_json(v_recepcion_id);
end;
$$;

create or replace function public.recepcion_descartar(
  p_session_token uuid,
  p_recepcion_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_estado text;
begin
  v_user := public.fn_require_empleado(p_session_token);
  select estado into v_estado from public.recepciones where id = p_recepcion_id;
  if not found then
    raise exception 'recepcion no existe';
  end if;
  if v_estado <> 'borrador' then
    raise exception 'solo se descarta un borrador';
  end if;
  delete from public.recepciones where id = p_recepcion_id;
  return jsonb_build_object('ok', true, 'id', p_recepcion_id);
end;
$$;

create or replace function public.recepcion_cerrar(
  p_session_token uuid,
  p_recepcion_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_rec public.recepciones%rowtype;
  v_item record;
  v_lote_id bigint;
  v_numero text;
  v_subtotal numeric := 0;
  v_pendientes int := 0;
  v_mapeados int := 0;
  v_sin_cad int := 0;
  v_estado text;
  v_diff numeric;
begin
  v_user := public.fn_require_empleado(p_session_token);

  select * into v_rec from public.recepciones where id = p_recepcion_id for update;
  if not found then
    raise exception 'recepcion no existe';
  end if;
  if v_rec.estado <> 'borrador' then
    raise exception 'esta recepcion ya esta cerrada';
  end if;

  select
    count(*) filter (where not pendiente_alta),
    count(*) filter (where pendiente_alta),
    count(*) filter (where not pendiente_alta and fecha_caducidad is null),
    coalesce(sum(cantidad * coalesce(costo_estimado, 0)), 0)
  into v_mapeados, v_pendientes, v_sin_cad, v_subtotal
  from public.recepcion_items
  where recepcion_id = p_recepcion_id;

  if v_mapeados = 0 then
    raise exception 'No hay productos del catalogo para recibir. Escanea al menos una caja que ya exista.';
  end if;
  if v_sin_cad > 0 then
    raise exception 'Falta la caducidad en % renglón(es). Teclea MMAA (ej. 0629).', v_sin_cad;
  end if;

  for v_item in
    select i.*, p.costo as costo_actual, p.nombre as nombre_prod
    from public.recepcion_items i
    join public.productos p on p.id = i.producto_id
    where i.recepcion_id = p_recepcion_id
      and not i.pendiente_alta
    order by i.id
  loop
    v_numero := coalesce(
      nullif(btrim(v_item.numero_lote), ''),
      'RX-' || coalesce(nullif(btrim(v_rec.folio), ''), to_char(now(), 'YYYYMMDD'))
        || '-' || v_item.id::text
    );

    select lote_id
      into v_lote_id
    from public.receive_merchandise_lote(
      v_item.producto_id,
      v_item.cantidad,
      v_numero,
      v_item.fecha_caducidad,
      v_item.costo_estimado,  -- ultimo costo conocido; la vendedora no lo escribe
      v_rec.proveedor,
      v_user
    );

    update public.recepcion_items
    set lote_id = v_lote_id, numero_lote = v_numero
    where id = v_item.id;
  end loop;

  v_diff := case
    when v_rec.total_ticket is null then 0
    else round(v_subtotal - v_rec.total_ticket, 2)
  end;

  if v_pendientes > 0 then
    v_estado := 'pendiente_alta';
  elsif v_rec.total_ticket is not null and abs(v_diff) > 1 then
    v_estado := 'descuadre';
  else
    v_estado := 'confirmada';
  end if;

  update public.recepciones
  set
    estado = v_estado,
    subtotal_estimado = round(v_subtotal, 2),
    diferencia = v_diff,
    cerrado_en = now(),
    capturado_por = coalesce(capturado_por, v_user),
    updated_at = now()
  where id = p_recepcion_id;

  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

grant execute on function public.fc_match_codigo_barras(text, text) to anon, authenticated, service_role;
grant execute on function public.fc_buscar_producto_escaneo(text) to anon, authenticated, service_role;
grant execute on function public.fc_recepcion_json(bigint) to service_role;
grant execute on function public.recepcion_borrador_abierto(uuid) to anon, authenticated;
grant execute on function public.recepcion_abrir(uuid, text, text, numeric) to anon, authenticated;
grant execute on function public.recepcion_guardar_cabecera(uuid, bigint, text, text, numeric) to anon, authenticated;
grant execute on function public.recepcion_agregar_item(uuid, bigint, text, integer, date) to anon, authenticated;
grant execute on function public.recepcion_quitar_item(uuid, bigint) to anon, authenticated;
grant execute on function public.recepcion_descartar(uuid, bigint) to anon, authenticated;
grant execute on function public.recepcion_cerrar(uuid, bigint) to anon, authenticated;

commit;

-- Verificación rápida (solo lectura)
select
  (select count(*) from public.recepciones) as recepciones,
  (select proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'recepcion_cerrar') as rpc_cerrar,
  (select pg_get_functiondef(p.oid) like '%nulls first%'
     from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'get_lote_fefo') as fefo_nulls_first;
