-- Recibir: el ticket arma catálogo + cola. El stock NO entra a POS ni tienda
-- hasta pistola + MMAA (recepcion_confirmar_item).
-- 1) Retira el stock prematuro de Cityfarma / Farmalive / Levic (sin confirmar).
-- 2) Al confirmar, receive_merchandise_lote.
-- Idempotente. Pegar entero en Supabase → SQL Editor.

begin;

-- ── 1. Quitar de anaquel lo que Mary aún no confirmó ────────────────────────
do $$
declare
  r record;
  v_lote public.lotes%rowtype;
  v_nueva integer;
begin
  for r in
    select i.id as item_id, i.lote_id, i.cantidad, i.producto_id, i.nombre_snapshot, rec.folio
    from public.recepcion_items i
    join public.recepciones rec on rec.id = i.recepcion_id
    where rec.estado = 'borrador'
      and not i.confirmado
      and i.lote_id is not null
  loop
    select * into v_lote from public.lotes where id = r.lote_id for update;
    if not found then
      update public.recepcion_items set lote_id = null where id = r.item_id;
      continue;
    end if;

    v_nueva := greatest(0, coalesce(v_lote.cantidad_actual, 0) - r.cantidad);

    update public.lotes
    set
      cantidad_actual = v_nueva,
      activo = (v_nueva > 0)
    where id = r.lote_id;

    if coalesce(v_lote.cantidad_actual, 0) - v_nueva > 0 then
      insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo, usuario_id)
      values (
        r.producto_id,
        'salida',
        coalesce(v_lote.cantidad_actual, 0) - v_nueva,
        format('Recibir: stock no confirmado (folio %s · %s)', coalesce(r.folio, '?'), left(coalesce(r.nombre_snapshot, ''), 40)),
        null
      );
    end if;

    update public.recepcion_items set lote_id = null where id = r.item_id;
  end loop;
end $$;

update public.recepciones
set notas = replace(coalesce(notas, ''), 'stock ya recibido; falta caducidad de caja',
                    'cola Recibir; el stock entra al confirmar pistola + MMAA')
where estado = 'borrador'
  and coalesce(notas, '') ilike '%stock ya recibido%';

-- ── 2. PDF/CSV: lista gris, nunca lote_id (no es stock) ─────────────────────
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
  v_distinto boolean;
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

    v_distinto := false;
    if v_pid is not null then
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
      null,
      v_lote,
      v_costo,
      (v_pid is null),
      'pdf',
      false,
      v_distinto,
      null
    );
  end loop;

  update public.recepciones set updated_at = now() where id = p_recepcion_id;
  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

-- Entra (o suma) stock de un renglón ya confirmado con MMAA.
create or replace function public.recepcion_entrar_stock_item(
  p_item_id bigint,
  p_cantidad integer,
  p_proveedor text,
  p_user_id bigint
)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_item public.recepcion_items%rowtype;
  v_lote_id bigint;
  v_numero text;
  v_folio text;
begin
  if p_cantidad is null or p_cantidad <= 0 then
    return null;
  end if;

  select * into v_item from public.recepcion_items where id = p_item_id;
  if not found then raise exception 'renglon no existe'; end if;
  if v_item.pendiente_alta or v_item.producto_id is null then
    return v_item.lote_id;
  end if;
  if v_item.fecha_caducidad is null then
    raise exception 'Caducidad requerida (MMAA de la caja)';
  end if;

  if v_item.lote_id is not null then
    update public.lotes
    set
      cantidad_actual = coalesce(cantidad_actual, 0) + p_cantidad,
      activo = true,
      fecha_caducidad = coalesce(fecha_caducidad, v_item.fecha_caducidad)
    where id = v_item.lote_id;
    insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo, usuario_id)
    values (
      v_item.producto_id, 'entrada', p_cantidad,
      format('Recibir confirmado (lote %s)', coalesce(v_item.numero_lote, v_item.lote_id::text)),
      p_user_id::integer
    );
    return v_item.lote_id;
  end if;

  select folio into v_folio from public.recepciones where id = v_item.recepcion_id;
  v_numero := coalesce(
    nullif(btrim(v_item.numero_lote), ''),
    'RX-' || coalesce(nullif(btrim(v_folio), ''), to_char(now(), 'YYYYMMDD'))
      || '-' || v_item.id::text
  );

  select lote_id into v_lote_id
  from public.receive_merchandise_lote(
    v_item.producto_id, p_cantidad, v_numero,
    v_item.fecha_caducidad, v_item.costo_estimado, p_proveedor, p_user_id
  );

  update public.recepcion_items
  set lote_id = v_lote_id, numero_lote = v_numero
  where id = p_item_id;

  return v_lote_id;
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
  v_proveedor text;
  v_qty integer;
  v_delta integer;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_fecha_caducidad is null then
    raise exception 'Caducidad requerida (MMAA de la caja)';
  end if;

  select i.* into v_item
  from public.recepcion_items i
  where i.id = p_item_id;
  if not found then raise exception 'renglon no existe'; end if;

  select estado, proveedor into v_estado, v_proveedor
  from public.recepciones where id = v_item.recepcion_id for update;
  if v_estado <> 'borrador' then raise exception 'solo se edita una recepcion en borrador'; end if;

  v_qty := coalesce(p_cantidad, v_item.cantidad);
  if v_qty is null or v_qty <= 0 then raise exception 'cantidad invalida'; end if;

  update public.recepcion_items
  set
    fecha_caducidad = p_fecha_caducidad,
    cantidad = v_qty,
    confirmado = true
  where id = p_item_id;

  if v_item.confirmado and v_item.lote_id is not null then
    v_delta := v_qty - v_item.cantidad;
    update public.lotes
    set fecha_caducidad = p_fecha_caducidad
    where id = v_item.lote_id;
    if v_delta > 0 then
      perform public.recepcion_entrar_stock_item(p_item_id, v_delta, v_proveedor, v_user);
    elsif v_delta < 0 then
      update public.lotes
      set
        cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) + v_delta),
        activo = (greatest(0, coalesce(cantidad_actual, 0) + v_delta) > 0)
      where id = v_item.lote_id;
    end if;
  else
    perform public.recepcion_entrar_stock_item(p_item_id, v_qty, v_proveedor, v_user);
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
  v_proveedor text;
  v_codigo text;
  v_producto_id bigint;
  v_nombre text;
  v_costo numeric;
  v_item_id bigint;
  v_pendiente boolean := false;
  v_gray public.recepcion_items%rowtype;
  v_existente boolean := false;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_cantidad is null or p_cantidad <= 0 then
    raise exception 'cantidad invalida';
  end if;

  select estado, proveedor into v_estado, v_proveedor
  from public.recepciones where id = p_recepcion_id for update;
  if not found then raise exception 'recepcion no existe'; end if;
  if v_estado <> 'borrador' then raise exception 'solo se edita una recepcion en borrador'; end if;

  v_codigo := btrim(coalesce(p_codigo, ''));
  if v_codigo = '' then raise exception 'codigo requerido'; end if;

  v_producto_id := public.fc_buscar_producto_escaneo(v_codigo);

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

  v_existente := (v_item_id is not null);

  if v_existente then
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

  if not v_pendiente and p_fecha_caducidad is not null then
    perform public.recepcion_entrar_stock_item(v_item_id, p_cantidad, v_proveedor, v_user);
  end if;

  update public.recepciones set updated_at = now() where id = p_recepcion_id;
  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

create or replace function public.recepcion_listar_abiertas(
  p_session_token uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_out jsonb;
begin
  v_user := public.fn_require_empleado(p_session_token);
  select coalesce(jsonb_agg(row_to_json(x)::jsonb order by x.updated_at desc), '[]'::jsonb)
  into v_out
  from (
    select
      r.id,
      r.proveedor,
      r.folio,
      r.fecha,
      r.total_ticket,
      r.estado,
      r.updated_at,
      count(i.id)::int as renglones,
      coalesce(sum(i.cantidad), 0)::int as piezas,
      count(*) filter (where i.pendiente_alta)::int as pendientes_alta,
      count(*) filter (where not i.confirmado)::int as sin_confirmar,
      count(*) filter (where i.lote_id is not null and i.fecha_caducidad is null)::int as sin_caducidad_anaquel,
      coalesce(
        array_remove(array_agg(distinct i.codigo_escaneado), null),
        array[]::text[]
      ) as codigos
    from public.recepciones r
    left join public.recepcion_items i on i.recepcion_id = r.id
    where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
    group by r.id
  ) x;
  return v_out;
end;
$$;

grant execute on function public.recepcion_cargar_renglones(uuid, bigint, jsonb) to anon, authenticated;
grant execute on function public.recepcion_confirmar_item(uuid, bigint, date, integer) to anon, authenticated;
grant execute on function public.recepcion_agregar_item(uuid, bigint, text, integer, date) to anon, authenticated;
grant execute on function public.recepcion_listar_abiertas(uuid) to anon, authenticated;
revoke execute on function public.recepcion_entrar_stock_item(bigint, integer, text, bigint) from public, anon, authenticated;

commit;

select r.folio, r.proveedor,
  (select count(*) from public.recepcion_items i where i.recepcion_id = r.id and i.lote_id is not null) as con_lote,
  (select count(*) from public.recepcion_items i where i.recepcion_id = r.id and i.confirmado) as confirmados
from public.recepciones r
where r.estado = 'borrador'
order by r.id;
