-- Para que un ticket no vuelva a entrar dos veces a stock.
--
-- No modifica existencias. Solo cambia Recibir:
--   1) Primero bloquea el ticket y después lee el renglón.
--      Dos toques seguidos ya no crean dos lotes.
--   2) Si el renglón ya tiene lote y le vuelven a mandar la cantidad
--      completa, no suma. Un aumento de verdad manda solo la diferencia.
--
-- Pegar entero en Supabase → SQL Editor → Run.
-- La baja de la factura Levic es otro archivo y no va aquí.

begin;

-- ── 1) Recibir: no sumar otra vez la cantidad completa ─────────────
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

  select * into v_item
  from public.recepcion_items
  where id = p_item_id
  for update;
  if not found then raise exception 'renglon no existe'; end if;

  if v_item.pendiente_alta or v_item.producto_id is null then
    v_producto_id := public.fc_buscar_producto_escaneo(v_item.codigo_escaneado);
    if v_producto_id is null then
      return v_item.lote_id;
    end if;
    update public.recepcion_items
    set producto_id = v_producto_id, pendiente_alta = false
    where id = p_item_id;
    select * into v_item
    from public.recepcion_items
    where id = p_item_id
    for update;
  end if;

  if v_item.fecha_caducidad is null then
    raise exception 'Caducidad requerida (MMAA de la caja)';
  end if;

  if v_item.lote_id is not null then
    -- Doble toque / cierre que manda otra vez la cantidad del renglón.
    -- Un aumento real manda solo el delta, que es menor que la cantidad ya guardada.
    if p_cantidad >= coalesce(v_item.cantidad, 0)
       and exists (
         select 1
         from public.lotes l
         where l.id = v_item.lote_id
           and coalesce(l.cantidad_inicial, 0) >= coalesce(v_item.cantidad, 0)
       )
    then
      return v_item.lote_id;
    end if;

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

  update public.productos p
  set stock = coalesce((
    select sum(l.cantidad_actual) from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0)
  where p.id = v_item.producto_id;

  return v_lote_id;
end;
$$;

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
  v_recepcion_id bigint;
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

  select i.recepcion_id into v_recepcion_id
  from public.recepcion_items i
  where i.id = p_item_id;
  if not found then raise exception 'renglon no existe'; end if;

  select estado, proveedor into v_estado, v_proveedor
  from public.recepciones
  where id = v_recepcion_id
  for update;
  if v_estado not in ('borrador', 'pendiente_alta', 'pendiente_caducidad') then
    raise exception 'Este ticket ya se cerró. Si faltan caducidades, hay que reabrirlo.';
  end if;

  -- Después del lock: si el otro toque ya creó el lote, esta lectura lo ve.
  select i.* into v_item
  from public.recepcion_items i
  where i.id = p_item_id
  for update;

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

  if not coalesce(v_pendiente, false) and v_lote_id is null then
    raise exception
      'El renglón quedó confirmado pero NO entró a inventario (sin lote). Escanea de nuevo o revisa que el EAN esté en catálogo.';
  end if;

  update public.recepciones set updated_at = now() where id = v_item.recepcion_id;
  return public.fc_recepcion_json(v_item.recepcion_id);
end;
$$;

revoke execute on function public.recepcion_entrar_stock_item(bigint, integer, text, bigint) from public, anon, authenticated;
grant execute on function public.recepcion_confirmar_item(uuid, bigint, date, integer, numeric)
  to anon, authenticated;

commit;
