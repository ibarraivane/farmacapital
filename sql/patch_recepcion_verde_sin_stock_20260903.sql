-- =============================================================================
-- Recibir: el verde MENTÍA — confirmado + MMAA sin lote_id = sin stock en
-- Inventario/POS. Causas:
--   1) recepcion_entrar_stock_item hacía return silencioso si pendiente_alta
--      o producto_id null (p. ej. Nadro «41 sin registrar» antes del relink).
--   2) recepcion_confirmar_item marcaba confirmado=true ANTES de entrar stock
--      y no verificaba que hubiera lote.
--   3) Tras enlazar catálogo, nadie re-entraba el stock de lo ya «verde».
--
-- Este patch:
--   A) entrar_stock: enlaza por EAN; si ya hay producto y no puede crear lote → error.
--   B) confirmar_item: exige lote_id tras entrar (salvo pendiente_alta real).
--   C) cerrar: repara huérfanos (confirmado + producto + MMAA + sin lote).
--   D) RPC recepcion_reparar_stock_huerfanos para pegar una vez y sanar histórico.
--   E) Resync productos.stock desde lotes (por si falta el trigger).
-- Idempotente. Pegar entero en Supabase → SQL Editor → Run.
-- =============================================================================

begin;

-- ── A. Entrada de stock (no tragar el fallo) ─────────────────────────────────
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
  v_producto_id bigint;
begin
  if p_cantidad is null or p_cantidad <= 0 then
    return null;
  end if;

  select * into v_item from public.recepcion_items where id = p_item_id;
  if not found then raise exception 'renglon no existe'; end if;

  -- Ticket/PDF con EAN aún no enlazado: intenta catálogo en vivo.
  if v_item.pendiente_alta or v_item.producto_id is null then
    v_producto_id := public.fc_buscar_producto_escaneo(v_item.codigo_escaneado);
    if v_producto_id is null then
      -- Sigue siendo alta pendiente: no hay anaquel que sumar (UI ámbar).
      return v_item.lote_id;
    end if;
    update public.recepcion_items
    set producto_id = v_producto_id, pendiente_alta = false
    where id = p_item_id;
    select * into v_item from public.recepcion_items where id = p_item_id;
  end if;

  if v_item.fecha_caducidad is null then
    raise exception 'Caducidad requerida (MMAA de la caja)';
  end if;

  if v_item.lote_id is not null then
    update public.lotes
    set
      cantidad_actual = coalesce(cantidad_actual, 0) + p_cantidad,
      activo = true,
      fecha_caducidad = coalesce(fecha_caducidad, v_item.fecha_caducidad),
      costo_unitario = coalesce(v_item.costo_estimado, costo_unitario)
    where id = v_item.lote_id;

    if v_item.costo_estimado is not null and v_item.costo_estimado > 0 then
      update public.productos
      set costo = v_item.costo_estimado
      where id = v_item.producto_id;
    end if;

    insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo, usuario_id)
    values (
      v_item.producto_id, 'entrada', p_cantidad,
      format('Recibir confirmado (lote %s)', coalesce(v_item.numero_lote, v_item.lote_id::text)),
      p_user_id::integer
    );

    update public.productos p
    set stock = coalesce((
      select sum(l.cantidad_actual) from public.lotes l
      where l.producto_id = p.id and coalesce(l.activo, true)
    ), 0)
    where p.id = v_item.producto_id;

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

  if v_lote_id is null then
    raise exception
      'No se pudo crear el lote en anaquel para % (producto %). Revisa receive_merchandise_lote.',
      coalesce(v_item.codigo_escaneado, '?'),
      v_item.producto_id;
  end if;

  update public.recepcion_items
  set lote_id = v_lote_id, numero_lote = v_numero
  where id = p_item_id;

  -- Caché productos.stock (por si trg_sync_productos_stock no está).
  update public.productos p
  set stock = coalesce((
    select sum(l.cantidad_actual) from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0)
  where p.id = v_item.producto_id;

  return v_lote_id;
end;
$$;

-- ── B. Confirmar: verde solo si hay lote (o sigue pendiente de alta) ─────────
create or replace function public.recepcion_confirmar_item(
  p_session_token uuid,
  p_item_id bigint,
  p_fecha_caducidad date,
  p_cantidad integer default null,
  p_costo numeric default null
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
  v_costo numeric;
  v_lote_id bigint;
  v_pendiente boolean;
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

  v_costo := case
    when p_costo is not null and p_costo > 0 then p_costo
    else v_item.costo_estimado
  end;

  update public.recepcion_items
  set
    fecha_caducidad = p_fecha_caducidad,
    cantidad = v_qty,
    costo_estimado = v_costo,
    confirmado = true
  where id = p_item_id;

  if v_item.confirmado and v_item.lote_id is not null then
    v_delta := v_qty - v_item.cantidad;
    update public.lotes
    set fecha_caducidad = p_fecha_caducidad,
        costo_unitario = coalesce(v_costo, costo_unitario)
    where id = v_item.lote_id;
    if v_costo is not null and v_costo > 0 and not v_item.pendiente_alta and v_item.producto_id is not null then
      update public.productos set costo = v_costo where id = v_item.producto_id;
    end if;
    if v_delta > 0 then
      perform public.recepcion_entrar_stock_item(p_item_id, v_delta, v_proveedor, v_user);
    elsif v_delta < 0 then
      update public.lotes
      set
        cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) + v_delta),
        activo = (greatest(0, coalesce(cantidad_actual, 0) + v_delta) > 0)
      where id = v_item.lote_id;
      update public.productos p
      set stock = coalesce((
        select sum(l.cantidad_actual) from public.lotes l
        where l.producto_id = p.id and coalesce(l.activo, true)
      ), 0)
      where p.id = v_item.producto_id;
    end if;
  else
    perform public.recepcion_entrar_stock_item(p_item_id, v_qty, v_proveedor, v_user);
  end if;

  select lote_id, pendiente_alta
    into v_lote_id, v_pendiente
  from public.recepcion_items
  where id = p_item_id;

  -- Verde mentiroso: confirmado en catálogo pero sin lote → no ocultar el fallo.
  if not coalesce(v_pendiente, false) and v_lote_id is null then
    raise exception
      'El renglón quedó confirmado pero NO entró a inventario (sin lote). Escanea de nuevo o revisa que el EAN esté en catálogo.';
  end if;

  update public.recepciones set updated_at = now() where id = v_item.recepcion_id;
  return public.fc_recepcion_json(v_item.recepcion_id);
end;
$$;

-- ── C. Cerrar: repara huérfanos antes de validar ─────────────────────────────
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

  -- Huérfanos verdes: confirmado + producto + MMAA + sin lote → entrar ahora.
  for v_item in
    select i.*
    from public.recepcion_items i
    where i.recepcion_id = p_recepcion_id
      and i.confirmado
      and not i.pendiente_alta
      and i.producto_id is not null
      and i.fecha_caducidad is not null
      and i.lote_id is null
    order by i.id
  loop
    perform public.recepcion_entrar_stock_item(
      v_item.id, v_item.cantidad, v_rec.proveedor, v_user
    );
  end loop;

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

    update public.productos p
    set stock = coalesce((
      select sum(l.cantidad_actual) from public.lotes l
      where l.producto_id = p.id and coalesce(l.activo, true)
    ), 0)
    where p.id = v_item.producto_id;
  end loop;

  v_diff := case
    when v_rec.total_ticket is null then 0
    else round(v_subtotal - v_rec.total_ticket, 2)
  end;

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
  else
    v_estado := 'confirmada';
  end if;

  update public.recepciones
  set
    estado = v_estado,
    subtotal_estimado = round(v_subtotal, 2),
    diferencia = v_diff,
    capturado_por = coalesce(capturado_por, v_user),
    cerrado_en = now(),
    updated_at = now()
  where id = p_recepcion_id;

  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

-- ── D. Reparar histórico (una vez / bajo demanda) ────────────────────────────
create or replace function public.recepcion_reparar_stock_huerfanos(
  p_session_token uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_item record;
  v_ok int := 0;
  v_fail int := 0;
  v_errores jsonb := '[]'::jsonb;
  v_lote bigint;
begin
  if p_session_token is not null then
    v_user := public.fn_require_empleado(p_session_token);
  else
    v_user := null;
  end if;

  for v_item in
    select i.id, i.cantidad, i.codigo_escaneado, r.proveedor, r.folio, i.producto_id
    from public.recepcion_items i
    join public.recepciones r on r.id = i.recepcion_id
    where i.confirmado
      and not coalesce(i.pendiente_alta, false)
      and i.producto_id is not null
      and i.fecha_caducidad is not null
      and i.lote_id is null
      and i.cantidad > 0
    order by i.id
  loop
    begin
      v_lote := public.recepcion_entrar_stock_item(
        v_item.id, v_item.cantidad, v_item.proveedor, v_user
      );
      if v_lote is null then
        v_fail := v_fail + 1;
        v_errores := v_errores || jsonb_build_array(jsonb_build_object(
          'item_id', v_item.id,
          'ean', v_item.codigo_escaneado,
          'folio', v_item.folio,
          'error', 'sin lote'
        ));
      else
        v_ok := v_ok + 1;
      end if;
    exception when others then
      v_fail := v_fail + 1;
      v_errores := v_errores || jsonb_build_array(jsonb_build_object(
        'item_id', v_item.id,
        'ean', v_item.codigo_escaneado,
        'folio', v_item.folio,
        'error', SQLERRM
      ));
    end;
  end loop;

  return jsonb_build_object(
    'reparados', v_ok,
    'fallidos', v_fail,
    'errores', v_errores
  );
end;
$$;

grant execute on function public.recepcion_entrar_stock_item(bigint, integer, text, bigint) to anon, authenticated;
grant execute on function public.recepcion_confirmar_item(uuid, bigint, date, integer, numeric) to anon, authenticated;
grant execute on function public.recepcion_cerrar(uuid, bigint) to anon, authenticated;
grant execute on function public.recepcion_reparar_stock_huerfanos(uuid) to anon, authenticated;

commit;

-- ── Diagnóstico: verdes sin anaquel (lo que buscas en Inventario y no está) ──
select
  r.id as recepcion_id,
  r.proveedor,
  r.folio,
  r.estado,
  i.id as item_id,
  i.codigo_escaneado as ean,
  left(coalesce(p.nombre, i.nombre_snapshot), 48) as nombre,
  i.cantidad,
  i.confirmado,
  i.pendiente_alta,
  i.fecha_caducidad,
  i.lote_id,
  p.stock as stock_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where i.confirmado
  and i.lote_id is null
  and i.fecha_caducidad is not null
order by r.id desc, i.id
limit 100;

-- Reparar (descomenta tras revisar el SELECT de arriba):
-- select public.recepcion_reparar_stock_huerfanos(null);
