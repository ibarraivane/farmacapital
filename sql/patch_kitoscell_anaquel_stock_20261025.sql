-- Kitoscell (y otros) con piezas en anaquel pero marcados bajo_pedido.
-- Inventario y POS ocultan la vitrina: con stock real no deben quedarse ahí.
--
-- Caso: Kitoscell Gel 3.5 g (FC-24228060 / 7502224228060) — 3 pzas, precio $130.
-- También: Isdin Ureadin Ultra 20 (1) y Accu-Chek Active (1).
--
-- Además: al confirmar Recibir, si entra stock se apaga bajo_pedido.
-- Idempotente. Pegar entero en Supabase → SQL Editor → Run.

begin;

-- ── 1) Datos: lo que ya tiene piezas pasa a anaquel ──────────────────────────
update public.productos
   set bajo_pedido = false
 where coalesce(bajo_pedido, false) = true
   and coalesce(stock, 0) > 0;

-- Nombre de mostrador (sin «Tubo C» de ticket)
update public.productos
   set nombre = 'Kitoscell Gel',
       marca = coalesce(nullif(btrim(marca), ''), 'Cell Pharma'),
       principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Pirfenidona'),
       presentacion = coalesce(nullif(btrim(presentacion), ''), '3.5 g'),
       forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Gel'),
       concentracion = coalesce(nullif(btrim(concentracion), ''), '8 g/100 g')
 where codigo_barras = '7502224228060'
    or sku = 'FC-24228060';

-- ── 2) Recibir: stock físico → ya no es vitrina ──────────────────────────────
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
    ), 0),
        -- Piezas en anaquel: sale de «Te lo conseguimos».
        bajo_pedido = false
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
  ), 0),
      bajo_pedido = false
  where p.id = v_item.producto_id;

  return v_lote_id;
end;
$$;

commit;

-- Verificación (opcional):
-- select id, sku, nombre, stock, bajo_pedido, precio
--   from public.productos
--  where codigo_barras in ('7502224228060','8470001541871','4015630082988')
--     or nombre ilike '%kitoscell%';
