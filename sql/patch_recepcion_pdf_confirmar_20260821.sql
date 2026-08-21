-- =============================================================================
-- Recibir: PDF/CSV arma lista en gris; pistola confirma caducidad.
-- Si el SKU ya existe pero el lote es otro (o no hay fecha), queda pendiente
-- de corroborar MMAA. No vuelve a sumar stock si el lote ya está en anaquel.
-- 21 ago 2026. Idempotente. Pegar entero en Supabase → SQL Editor.
-- =============================================================================

begin;

alter table public.recepcion_items
  add column if not exists origen text not null default 'pistola',
  add column if not exists confirmado boolean not null default false,
  add column if not exists lote_distinto boolean not null default false;

update public.recepcion_items
set confirmado = true
where confirmado = false
  and fecha_caducidad is not null
  and origen = 'pistola';

alter table public.recepciones drop constraint if exists recepciones_estado_chk;
alter table public.recepciones add constraint recepciones_estado_chk
  check (estado in ('borrador', 'confirmada', 'descuadre', 'pendiente_alta', 'pendiente_caducidad'));

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
  v_sin_confirmar int;
  v_sin_cad int;
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
        'numero_lote', i.numero_lote,
        'pendiente_alta', i.pendiente_alta,
        'confirmado', i.confirmado,
        'origen', i.origen,
        'lote_distinto', i.lote_distinto,
        'lote_id', i.lote_id,
        'lotes_piso', (
          select coalesce(jsonb_agg(l.numero_lote order by l.fecha_caducidad nulls first, l.id), '[]'::jsonb)
          from public.lotes l
          where l.producto_id = i.producto_id
            and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
        )
      )
      order by i.confirmado, i.id
    ), '[]'::jsonb),
    coalesce(sum(i.cantidad * coalesce(i.costo_estimado, 0)), 0),
    count(*)::int,
    coalesce(sum(i.cantidad), 0)::int,
    count(*) filter (where i.pendiente_alta)::int,
    count(*) filter (where not i.confirmado)::int,
    count(*) filter (where i.lote_id is not null and i.fecha_caducidad is null)::int
  into v_items, v_subtotal, v_renglones, v_piezas, v_pendientes, v_sin_confirmar, v_sin_cad
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
    'sin_confirmar', v_sin_confirmar,
    'sin_caducidad_anaquel', v_sin_cad,
    'updated_at', v_rec.updated_at,
    'cerrado_en', v_rec.cerrado_en,
    'items', v_items
  );
end;
$$;

-- Carga masiva desde PDF/CSV. No crea stock. No inventa caducidad.
create or replace function public.recepcion_cargar_renglones(
  p_session_token uuid,
  p_recepcion_id bigint,
  p_items jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_estado text;
  v_el jsonb;
  v_codigo text;
  v_sku text;
  v_nombre text;
  v_qty integer;
  v_costo numeric;
  v_lote text;
  v_pid bigint;
  v_lote_id bigint;
  v_distinto boolean;
  v_piso int;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'No hay renglones en el ticket';
  end if;

  select estado into v_estado from public.recepciones where id = p_recepcion_id for update;
  if not found then raise exception 'recepcion no existe'; end if;
  if v_estado <> 'borrador' then raise exception 'solo se edita una recepcion en borrador'; end if;

  for v_el in select value from jsonb_array_elements(p_items)
  loop
    v_codigo := nullif(btrim(coalesce(v_el->>'codigo', v_el->>'codigo_barras', v_el->>'ean', '')), '');
    v_sku := nullif(btrim(coalesce(v_el->>'sku', '')), '');
    v_nombre := nullif(btrim(coalesce(v_el->>'nombre', v_el->>'descripcion', v_el->>'descripcion_ticket', '')), '');
    v_qty := coalesce(nullif(v_el->>'cantidad', '')::integer, nullif(v_el->>'qty', '')::integer, 1);
    v_costo := nullif(v_el->>'costo', '')::numeric;
    if v_costo is null then
      v_costo := nullif(v_el->>'precio', '')::numeric;
    end if;
    if v_costo is null then
      v_costo := nullif(v_el->>'precio_unitario', '')::numeric;
    end if;
    v_lote := nullif(btrim(coalesce(v_el->>'numero_lote', v_el->>'lote', '')), '');
    if v_qty is null or v_qty <= 0 then
      continue;
    end if;

    v_pid := null;
    if v_codigo is not null then
      v_pid := public.fc_buscar_producto_escaneo(v_codigo);
    end if;
    if v_pid is null and v_sku is not null then
      v_pid := public.fc_buscar_producto_escaneo(v_sku);
    end if;

    v_lote_id := null;
    v_distinto := false;
    v_piso := 0;
    if v_pid is not null then
      select count(*)::int into v_piso
      from public.lotes l
      where l.producto_id = v_pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0;

      if v_lote is not null then
        select l.id into v_lote_id
        from public.lotes l
        where l.producto_id = v_pid
          and l.numero_lote = v_lote
          and coalesce(l.activo, true)
        order by l.id desc
        limit 1;
      end if;

      v_distinto := exists (
        select 1 from public.lotes l
        where l.producto_id = v_pid
          and coalesce(l.activo, true)
          and coalesce(l.cantidad_actual, 0) > 0
          and (v_lote is null or l.numero_lote is distinct from v_lote)
      );
    end if;

    insert into public.recepcion_items (
      recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
      cantidad, fecha_caducidad, numero_lote, costo_estimado,
      pendiente_alta, origen, confirmado, lote_distinto, lote_id
    ) values (
      p_recepcion_id,
      v_pid,
      coalesce(v_codigo, v_sku),
      coalesce(v_nombre, 'Renglón de ticket'),
      v_qty,
      null,  -- caducidad solo de la caja, nunca del PDF
      v_lote,
      v_costo,
      (v_pid is null),
      'pdf',
      false,
      v_distinto,
      v_lote_id
    );
  end loop;

  update public.recepciones set updated_at = now() where id = p_recepcion_id;
  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

create or replace function public.recepcion_confirmar_item(
  p_session_token uuid,
  p_item_id bigint,
  p_fecha_caducidad date,
  p_cantidad integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_item public.recepcion_items%rowtype;
  v_estado text;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_fecha_caducidad is null then
    raise exception 'Caducidad requerida (MMAA de la caja)';
  end if;

  select i.* into v_item
  from public.recepcion_items i
  where i.id = p_item_id;
  if not found then raise exception 'renglon no existe'; end if;

  select estado into v_estado from public.recepciones where id = v_item.recepcion_id for update;
  if v_estado <> 'borrador' then raise exception 'solo se edita una recepcion en borrador'; end if;

  update public.recepcion_items
  set
    fecha_caducidad = p_fecha_caducidad,
    cantidad = coalesce(p_cantidad, cantidad),
    confirmado = true
  where id = p_item_id;

  if v_item.lote_id is not null then
    update public.lotes
    set fecha_caducidad = p_fecha_caducidad
    where id = v_item.lote_id;
  end if;

  update public.recepciones set updated_at = now() where id = v_item.recepcion_id;
  return public.fc_recepcion_json(v_item.recepcion_id);
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
  v_gray public.recepcion_items%rowtype;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_cantidad is null or p_cantidad <= 0 then
    raise exception 'cantidad invalida';
  end if;

  select estado into v_estado from public.recepciones where id = p_recepcion_id for update;
  if not found then raise exception 'recepcion no existe'; end if;
  if v_estado <> 'borrador' then raise exception 'solo se edita una recepcion en borrador'; end if;

  v_codigo := btrim(coalesce(p_codigo, ''));
  if v_codigo = '' then raise exception 'codigo requerido'; end if;

  v_producto_id := public.fc_buscar_producto_escaneo(v_codigo);

  -- Pistola sobre renglón gris del ticket: confirma, no duplica.
  select * into v_gray
  from public.recepcion_items i
  where i.recepcion_id = p_recepcion_id
    and not i.confirmado
    and (
      (v_producto_id is not null and i.producto_id = v_producto_id)
      or public.fc_match_codigo_barras(v_codigo, i.codigo_escaneado)
      or upper(btrim(coalesce(i.codigo_escaneado, ''))) = upper(v_codigo)
    )
  order by i.id
  limit 1;

  if found then
    if p_fecha_caducidad is null then
      raise exception 'Caducidad requerida (MMAA de la caja)';
    end if;
    return public.recepcion_confirmar_item(
      p_session_token, v_gray.id, p_fecha_caducidad, p_cantidad
    );
  end if;

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
      and confirmado
      and fecha_caducidad is not distinct from p_fecha_caducidad
    limit 1;
  end if;

  if v_item_id is not null then
    update public.recepcion_items
    set cantidad = cantidad + p_cantidad, confirmado = true, origen = coalesce(origen, 'pistola')
    where id = v_item_id;
  else
    insert into public.recepcion_items (
      recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
      cantidad, fecha_caducidad, costo_estimado, pendiente_alta,
      origen, confirmado
    ) values (
      p_recepcion_id, v_producto_id, v_codigo, v_nombre,
      p_cantidad, p_fecha_caducidad, v_costo, v_pendiente,
      'pistola', true
    )
    returning id into v_item_id;
  end if;

  update public.recepciones set updated_at = now() where id = p_recepcion_id;
  return public.fc_recepcion_json(p_recepcion_id);
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
  v_anaquel_sin_cad int := 0;
  v_gris_sin_cad int := 0;
  v_estado text;
  v_diff numeric;
begin
  v_user := public.fn_require_empleado(p_session_token);

  select * into v_rec from public.recepciones where id = p_recepcion_id for update;
  if not found then raise exception 'recepcion no existe'; end if;
  if v_rec.estado <> 'borrador' then raise exception 'esta recepcion ya esta cerrada'; end if;

  select
    count(*) filter (where confirmado and not pendiente_alta),
    count(*) filter (where pendiente_alta),
    count(*) filter (where lote_id is not null and fecha_caducidad is null),
    count(*) filter (where not confirmado and not pendiente_alta),
    coalesce(sum(cantidad * coalesce(costo_estimado, 0)) filter (where confirmado), 0)
  into v_mapeados, v_pendientes, v_anaquel_sin_cad, v_gris_sin_cad, v_subtotal
  from public.recepcion_items
  where recepcion_id = p_recepcion_id;

  if v_anaquel_sin_cad > 0 then
    raise exception 'Faltan % caducidad(es) de producto que ya está en anaquel. Escanea y teclea MMAA.', v_anaquel_sin_cad;
  end if;
  if v_mapeados = 0 then
    raise exception 'Confirma al menos un renglón con caducidad (pistola + MMAA).';
  end if;

  for v_item in
    select i.*
    from public.recepcion_items i
    where i.recepcion_id = p_recepcion_id
      and i.confirmado
      and not i.pendiente_alta
      and i.producto_id is not null
      and i.lote_id is null
    order by i.id
  loop
    if v_item.fecha_caducidad is null then
      raise exception 'Falta caducidad en un renglón confirmado';
    end if;
    v_numero := coalesce(
      nullif(btrim(v_item.numero_lote), ''),
      'RX-' || coalesce(nullif(btrim(v_rec.folio), ''), to_char(now(), 'YYYYMMDD'))
        || '-' || v_item.id::text
    );
    select lote_id into v_lote_id
    from public.receive_merchandise_lote(
      v_item.producto_id, v_item.cantidad, v_numero,
      v_item.fecha_caducidad, v_item.costo_estimado, v_rec.proveedor, v_user
    );
    update public.recepcion_items
    set lote_id = v_lote_id, numero_lote = v_numero
    where id = v_item.id;
  end loop;

  v_diff := case
    when v_rec.total_ticket is null then 0
    else round(v_subtotal - v_rec.total_ticket, 2)
  end;

  -- Lista gris sin pistola: el stock de lo confirmado sí entra, pero el documento
  -- sigue abierto para no perder las cajas que faltan.
  if v_gris_sin_cad > 0 then
    update public.recepciones
    set
      subtotal_estimado = round(v_subtotal, 2),
      diferencia = v_diff,
      capturado_por = coalesce(capturado_por, v_user),
      updated_at = now()
    where id = p_recepcion_id;
    return public.fc_recepcion_json(p_recepcion_id);
  end if;

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

grant execute on function public.recepcion_cargar_renglones(uuid, bigint, jsonb) to anon, authenticated;
grant execute on function public.recepcion_confirmar_item(uuid, bigint, date, integer) to anon, authenticated;
grant execute on function public.recepcion_agregar_item(uuid, bigint, text, integer, date) to anon, authenticated;
grant execute on function public.recepcion_cerrar(uuid, bigint) to anon, authenticated;

commit;
