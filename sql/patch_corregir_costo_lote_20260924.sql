-- Corregir el costo de un lote deja rastro. Un update directo no reescribe ventas.
-- 24 sep 2026. Idempotente. Pegar después de los patches de consumos y cajas abiertas.

begin;

create or replace function public.fn_corregir_costo_lote(
  p_lote_id bigint,
  p_costo_nuevo numeric,
  p_actor bigint,
  p_motivo text,
  p_propagar boolean,
  p_fuente text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_lote public.lotes%rowtype;
  v_n int := 0;
  v_pesos numeric := 0;
  v_puede boolean;
begin
  if p_costo_nuevo is null or p_costo_nuevo <= 0 then
    raise exception 'costo nuevo invalido';
  end if;

  select * into v_lote from public.lotes where id = p_lote_id for update;
  if not found then
    raise exception 'lote % no existe', p_lote_id;
  end if;

  v_puede := coalesce(v_lote.costo_es_estimado, false) or coalesce(p_propagar, false);
  if not v_puede and exists (
    select 1 from public.pedido_item_consumos c where c.lote_id = p_lote_id
  ) and v_lote.costo_unitario is distinct from p_costo_nuevo then
    raise exception 'el lote % ya tiene ventas y su costo no es estimado', p_lote_id;
  end if;

  perform set_config('app.fc_corregir_costo_lote', '1', true);
  update public.lotes
  set costo_unitario = p_costo_nuevo,
      costo_es_estimado = false,
      costo_fuente = coalesce(nullif(btrim(p_fuente), ''), 'manual')
  where id = p_lote_id;
  perform set_config('app.fc_corregir_costo_lote', '', true);

  if v_puede then
    update public.pedido_item_consumos c
    set costo_unitario_anterior = c.costo_unitario,
        costo_unitario = case
          when c.modo = 'unidad' then round(
            p_costo_nuevo / greatest(coalesce(
              (select ca.unidades_por_caja from public.cajas_abiertas ca where ca.id = c.caja_abierta_id),
              (select pr.unidades_por_caja
                 from public.pedido_items pi
                 join public.productos pr on pr.id = pi.producto_id
                where pi.id = c.pedido_item_id),
              1
            ), 1), 4)
          else p_costo_nuevo
        end,
        ajustado_at = now(),
        ajustado_por = p_actor,
        costo_origen = 'lote'
    where c.lote_id = p_lote_id
      and (
        c.costo_unitario is distinct from p_costo_nuevo
        or c.modo = 'unidad'
      );

    get diagnostics v_n = row_count;
    select coalesce(sum((c.costo_unitario - coalesce(c.costo_unitario_anterior, c.costo_unitario)) * c.cantidad), 0)
      into v_pesos
    from public.pedido_item_consumos c
    where c.lote_id = p_lote_id
      and c.ajustado_at is not null
      and c.ajustado_por = p_actor
      and c.ajustado_at > now() - interval '5 seconds';
  end if;

  insert into public.audit_log (usuario_id, accion, tabla, registro_id, detalle)
  values (
    p_actor,
    'corregir_costo_lote',
    'lotes',
    p_lote_id::text,
    jsonb_build_object(
      'costo_anterior', v_lote.costo_unitario,
      'costo_nuevo', p_costo_nuevo,
      'motivo', p_motivo,
      'consumos', v_n,
      'delta_pesos', v_pesos,
      'propagado', v_puede
    )::text
  );

  return jsonb_build_object(
    'lote_id', p_lote_id,
    'costo_anterior', v_lote.costo_unitario,
    'costo_nuevo', p_costo_nuevo,
    'consumos', v_n,
    'delta_pesos', v_pesos
  );
end;
$$;

create or replace function public.admin_corregir_costo_lote(
  p_session_token uuid,
  p_lote_id bigint,
  p_costo_nuevo numeric,
  p_motivo text,
  p_propagar boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);
  if p_motivo is null or btrim(p_motivo) = '' then
    raise exception 'motivo requerido';
  end if;
  return public.fn_corregir_costo_lote(
    p_lote_id, p_costo_nuevo, v_actor, p_motivo, p_propagar,
    case when coalesce(p_propagar, false) then 'manual' else 'factura' end
  );
end;
$$;

revoke all on function public.admin_corregir_costo_lote(uuid, bigint, numeric, text, boolean) from public;
grant execute on function public.admin_corregir_costo_lote(uuid, bigint, numeric, text, boolean) to anon, authenticated;

create or replace function public.fn_lote_poner_costo_recibir(
  p_lote_id bigint,
  p_costo numeric
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_estimado boolean;
  v_tiene boolean;
begin
  if p_costo is null or p_costo <= 0 or p_lote_id is null then
    return;
  end if;
  select coalesce(costo_es_estimado, false) into v_estimado
  from public.lotes where id = p_lote_id;
  select exists (
    select 1 from public.pedido_item_consumos where lote_id = p_lote_id
  ) into v_tiene;

  if v_tiene and not coalesce(v_estimado, false) then
    return;
  end if;
  if v_tiene and v_estimado then
    perform public.fn_corregir_costo_lote(p_lote_id, p_costo, null, 'factura de recibir', true, 'factura');
    return;
  end if;

  perform set_config('app.fc_corregir_costo_lote', '1', true);
  update public.lotes
  set costo_unitario = p_costo,
      costo_es_estimado = true,
      costo_fuente = 'recibir'
  where id = p_lote_id;
  perform set_config('app.fc_corregir_costo_lote', '', true);
end;
$$;

create or replace function public.trg_lotes_costo_congelado()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if TG_OP = 'INSERT' then
    if NEW.costo_unitario is not null and NEW.costo_fuente is null then
      NEW.costo_es_estimado := true;
      NEW.costo_fuente := 'recibir';
    end if;
    return NEW;
  end if;

  if NEW.costo_unitario is distinct from OLD.costo_unitario
     and coalesce(current_setting('app.fc_corregir_costo_lote', true), '') <> '1'
     and exists (select 1 from public.pedido_item_consumos c where c.lote_id = OLD.id)
  then
    raise exception 'no se puede cambiar el costo del lote %: ya tiene ventas. Usa admin_corregir_costo_lote.', OLD.id;
  end if;
  return NEW;
end;
$$;

drop trigger if exists trg_lotes_costo_congelado on public.lotes;
create trigger trg_lotes_costo_congelado
  before insert or update of costo_unitario on public.lotes
  for each row
  execute function public.trg_lotes_costo_congelado();

-- Una compra nueva no mueve el precio de anaquel ni el de la pieza.
create or replace function public.trg_enforce_precio_unidad()
returns trigger
language plpgsql
as $$
begin
  if TG_OP = 'UPDATE'
     and NEW.costo is distinct from OLD.costo
     and NEW.precio is not distinct from OLD.precio
     and NEW.precio_unidad is not distinct from OLD.precio_unidad
     and NEW.venta_unidad is not distinct from OLD.venta_unidad
     and NEW.unidades_por_caja is not distinct from OLD.unidades_por_caja
     and NEW.categoria is not distinct from OLD.categoria
     and NEW.tipo is not distinct from OLD.tipo
  then
    return NEW;
  end if;

  if coalesce(new.venta_unidad, false)
     and coalesce(new.unidades_por_caja, 0) > 0 then
    new.precio_unidad := public.precio_unidad_efectivo(
      new.costo, new.precio, new.unidades_por_caja, new.categoria, new.tipo, new.precio_unidad
    );
  elsif not coalesce(new.venta_unidad, false) then
    new.precio_unidad := 0;
    new.unidades_por_caja := 0;
  end if;
  return new;
end;
$$;

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
      fecha_caducidad = coalesce(fecha_caducidad, v_item.fecha_caducidad)
    where id = v_item.lote_id;
    perform public.fn_lote_poner_costo_recibir(v_item.lote_id, v_item.costo_estimado);

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
  if v_estado not in ('borrador', 'pendiente_alta', 'pendiente_caducidad') then
    raise exception 'Este ticket ya se cerró. Si faltan caducidades, hay que reabrirlo.';
  end if;

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
    set fecha_caducidad = p_fecha_caducidad
    where id = v_item.lote_id;
    perform public.fn_lote_poner_costo_recibir(v_item.lote_id, v_costo);
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


commit;
