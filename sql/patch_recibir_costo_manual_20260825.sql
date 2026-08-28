-- Recibir manual: capturar el costo de la caja, no heredar el del catálogo.
--
-- Problema: al escanear sin ticket, recepcion_agregar_item copiaba
-- productos.costo en recepcion_items.costo_estimado. Como Historia y la
-- referencia de "última compra" leen costo_estimado, el ticket quedaba
-- grabado con el costo viejo (la factura Levic A9012100253 entró a 12.92
-- cuando la factura decía 13.61).
--
-- Ahora el costo viaja como parámetro. Si no lo mandan, se comporta igual
-- que antes y toma el del catálogo.
-- Idempotente. Pegar en Supabase.

begin;

-- Las firmas viejas se van: si se quedan, agregar un parámetro con default
-- deja la llamada de 4/5 argumentos ambigua.
drop function if exists public.recepcion_agregar_item(uuid, bigint, text, integer, date);
drop function if exists public.recepcion_confirmar_item(uuid, bigint, date, integer);

-- ───────────────────────────────────────────────────────────────
-- Entrada de stock: el costo del renglón manda sobre el del lote
-- ───────────────────────────────────────────────────────────────
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
      fecha_caducidad = coalesce(fecha_caducidad, v_item.fecha_caducidad),
      -- si el ticket trae costo, ese es el bueno
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

-- ───────────────────────────────────────────────────────────────
-- Confirmar un renglón: ahora acepta el costo de la caja
-- ───────────────────────────────────────────────────────────────
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

  -- costo nuevo si lo mandan; si no, se respeta el que ya traía el renglón
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
    end if;
  else
    perform public.recepcion_entrar_stock_item(p_item_id, v_qty, v_proveedor, v_user);
  end if;

  update public.recepciones set updated_at = now() where id = v_item.recepcion_id;
  return public.fc_recepcion_json(v_item.recepcion_id);
end;
$$;

-- ───────────────────────────────────────────────────────────────
-- Agregar por pistola: el costo tecleado gana al del catálogo
-- ───────────────────────────────────────────────────────────────
create or replace function public.recepcion_agregar_item(
  p_session_token uuid,
  p_recepcion_id bigint,
  p_codigo text,
  p_cantidad integer,
  p_fecha_caducidad date default null,
  p_costo numeric default null
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
      p_session_token, v_gray.id, p_fecha_caducidad, p_cantidad, p_costo
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

  -- lo tecleado en la caja manda; el catálogo es sólo el respaldo.
  -- En pendiente de alta antes no quedaba costo ninguno: ahora sí.
  if p_costo is not null and p_costo > 0 then
    v_costo := p_costo;
  end if;

  if v_pendiente then
    select id into v_item_id
    from public.recepcion_items
    where recepcion_id = p_recepcion_id
      and pendiente_alta
      and codigo_escaneado = v_codigo
      and fecha_caducidad is not distinct from p_fecha_caducidad
      and costo_estimado is not distinct from v_costo
    limit 1;
  else
    select id into v_item_id
    from public.recepcion_items
    where recepcion_id = p_recepcion_id
      and not pendiente_alta
      and producto_id = v_producto_id
      and confirmado
      and fecha_caducidad is not distinct from p_fecha_caducidad
      and costo_estimado is not distinct from v_costo
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

grant execute on function public.recepcion_entrar_stock_item(bigint, integer, text, bigint) to anon, authenticated;
grant execute on function public.recepcion_confirmar_item(uuid, bigint, date, integer, numeric) to anon, authenticated;
grant execute on function public.recepcion_agregar_item(uuid, bigint, text, integer, date, numeric) to anon, authenticated;

commit;

-- ─────────────── Comprobación: las firmas nuevas ───────────────
select p.proname, pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in ('recepcion_agregar_item', 'recepcion_confirmar_item', 'recepcion_entrar_stock_item')
order by p.proname;
