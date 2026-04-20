-- ============================================================
-- FARMAX — F3a addendum (consolidado)
-- ============================================================
-- Agrega/reemplaza RPCs necesarios para que F3b (frontend) pueda
-- reemplazar todos los writes directos a productos.stock:
--
--   1) create_producto_with_lote  (v2: cubre todos los campos del form)
--   2) consume_stock_via_lotes    (decrementa FEFO por delta)
--   3) receive_merchandise_lote   (recepcion de mercancia = nuevo lote)
--
-- Correr DESPUES de refactor_fase3a_rpcs_lotes.sql.
-- ============================================================

begin;

-- ============================================================
-- 1) create_producto_with_lote (v2, extendida)
-- ============================================================
-- Cubre todos los campos del formulario de Inventario/AdminDashboard.
-- Reemplaza la version anterior (misma firma), agregando:
--   venta_unidad, proveedor, descuento_pct, descripcion, receta,
--   requiere_receta, precio_unidad, precio_similares, precio_del_ahorro.
-- Tambien sincroniza productos.lote / productos.fecha_caducidad (legacy,
-- se eliminaran en F4) con los del lote que se crea.
-- ============================================================

create or replace function public.create_producto_with_lote(
  p_producto_data jsonb,
  p_cantidad_inicial integer default 0,
  p_numero_lote text default null,
  p_fecha_caducidad date default null,
  p_costo_unitario numeric default null,
  p_user_id bigint default null
)
returns table(producto_id bigint, lote_id bigint)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_producto_id bigint;
  v_lote_id bigint := null;
  v_lote_numero text;
begin
  if p_producto_data is null then
    raise exception 'producto_data requerido';
  end if;
  if (p_producto_data->>'nombre') is null or btrim(p_producto_data->>'nombre') = '' then
    raise exception 'nombre requerido';
  end if;

  insert into public.productos (
    nombre, sku, codigo_barras, categoria, tipo, descripcion,
    precio, costo, precio_unidad, precio_similares, precio_del_ahorro,
    stock, stock_minimo, stock_unidades, unidades_por_caja,
    venta_unidad, proveedor, descuento_pct,
    lote, fecha_caducidad,
    receta, requiere_receta, activo
  ) values (
    p_producto_data->>'nombre',
    p_producto_data->>'sku',
    p_producto_data->>'codigo_barras',
    p_producto_data->>'categoria',
    p_producto_data->>'tipo',
    p_producto_data->>'descripcion',
    nullif(p_producto_data->>'precio', '')::numeric,
    nullif(p_producto_data->>'costo', '')::numeric,
    nullif(p_producto_data->>'precio_unidad', '')::numeric,
    nullif(p_producto_data->>'precio_similares', '')::numeric,
    nullif(p_producto_data->>'precio_del_ahorro', '')::numeric,
    0,
    coalesce(nullif(p_producto_data->>'stock_minimo', '')::integer, 0),
    coalesce(nullif(p_producto_data->>'stock_unidades', '')::integer, 0),
    nullif(p_producto_data->>'unidades_por_caja', '')::integer,
    coalesce(nullif(p_producto_data->>'venta_unidad', '')::boolean, false),
    p_producto_data->>'proveedor',
    coalesce(nullif(p_producto_data->>'descuento_pct', '')::numeric, 0),
    coalesce(p_numero_lote, p_producto_data->>'lote'),
    coalesce(p_fecha_caducidad, nullif(p_producto_data->>'fecha_caducidad', '')::date),
    nullif(p_producto_data->>'receta', '')::boolean,
    nullif(p_producto_data->>'requiere_receta', '')::boolean,
    coalesce(nullif(p_producto_data->>'activo', '')::boolean, true)
  ) returning id into v_producto_id;

  if coalesce(p_cantidad_inicial, 0) > 0 then
    v_lote_numero := coalesce(
      p_numero_lote,
      p_producto_data->>'lote',
      'INICIAL-' || to_char(now(), 'YYYYMMDD-HH24MISS')
    );

    insert into public.lotes (
      producto_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_caducidad, costo_unitario, activo
    ) values (
      v_producto_id,
      v_lote_numero,
      p_cantidad_inicial, p_cantidad_inicial,
      coalesce(p_fecha_caducidad, nullif(p_producto_data->>'fecha_caducidad', '')::date),
      coalesce(p_costo_unitario, nullif(p_producto_data->>'costo', '')::numeric),
      true
    ) returning id into v_lote_id;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo, usuario_id
    ) values (
      v_producto_id, 'entrada', p_cantidad_inicial,
      'Alta de producto con stock inicial',
      p_user_id
    );
  end if;

  return query select v_producto_id, v_lote_id;
end;
$$;

grant execute on function public.create_producto_with_lote(
  jsonb, integer, text, date, numeric, bigint
) to anon, authenticated, service_role;


-- ============================================================
-- 2) consume_stock_via_lotes: decrementa FEFO por delta (sin race)
-- ============================================================
-- Lo necesita Admin.jsx surtirOnline (marcar pedido listo) y
-- cualquier flujo que deba bajar stock sin pasar por
-- create_sale_transaction_v2.
-- ============================================================

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
    order by l.fecha_caducidad asc nulls last, l.id asc
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


-- ============================================================
-- 3) receive_merchandise_lote: recepcion de mercancia = nuevo lote
-- ============================================================
-- Crea un lote nuevo con los datos de la recepcion, opcionalmente
-- actualiza productos.costo/proveedor como metadata, y deja que el
-- trigger sincronice productos.stock.
-- ============================================================

create or replace function public.receive_merchandise_lote(
  p_producto_id bigint,
  p_cantidad integer,
  p_numero_lote text default null,
  p_fecha_caducidad date default null,
  p_costo_unitario numeric default null,
  p_proveedor text default null,
  p_user_id bigint default null
)
returns table(lote_id bigint, stock_nuevo integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_lote_id bigint;
  v_numero text;
begin
  if p_producto_id is null then raise exception 'producto_id requerido'; end if;
  if p_cantidad is null or p_cantidad <= 0 then raise exception 'cantidad invalida'; end if;

  perform 1 from public.productos p where p.id = p_producto_id for update;
  if not found then
    raise exception 'producto % no existe', p_producto_id;
  end if;

  v_numero := coalesce(
    nullif(btrim(p_numero_lote), ''),
    'RX-' || to_char(now(), 'YYYYMMDD-HH24MISS')
  );

  insert into public.lotes (
    producto_id, numero_lote, cantidad_inicial, cantidad_actual,
    fecha_caducidad, costo_unitario, activo
  ) values (
    p_producto_id, v_numero, p_cantidad, p_cantidad,
    p_fecha_caducidad, p_costo_unitario, true
  ) returning id into v_lote_id;

  -- Actualizar metadata en productos (costo / proveedor / legacy lote & caducidad)
  update public.productos
  set
    costo = coalesce(p_costo_unitario, costo),
    proveedor = coalesce(nullif(btrim(p_proveedor), ''), proveedor),
    lote = coalesce(v_numero, lote),
    fecha_caducidad = coalesce(p_fecha_caducidad, fecha_caducidad)
  where id = p_producto_id;

  insert into public.movimientos_inventario (
    producto_id, tipo, cantidad, motivo, usuario_id
  ) values (
    p_producto_id, 'entrada', p_cantidad,
    format('Recepcion de mercancia (lote %s)', v_numero),
    p_user_id
  );

  return query
  select v_lote_id, p.stock
  from public.productos p
  where p.id = p_producto_id;
end;
$$;

grant execute on function public.receive_merchandise_lote(
  bigint, integer, text, date, numeric, text, bigint
) to anon, authenticated, service_role;


commit;
