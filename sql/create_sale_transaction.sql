-- FARMAX: Atomic sale transaction for POS / checkout safety
-- Note: In PostgreSQL functions, transaction control is implicit.
-- Supabase RPC runs this function inside a transaction; any raised exception
-- aborts and rolls back all writes done by this function call.

create or replace function public.create_sale_transaction(
  p_user_id bigint,
  p_metodo_pago text,
  p_total numeric,
  p_cart_items jsonb
)
returns table(pedido_id bigint, success boolean)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pedido_id bigint;
  v_item jsonb;
  v_producto_id bigint;
  v_cantidad integer;
  v_precio_unitario numeric;
  v_stock_actual integer;
  v_stock_nuevo integer;
  v_db_precio numeric;
  v_calc_total numeric := 0;
begin
  if p_user_id is null then
    raise exception 'user_id es requerido';
  end if;

  if p_metodo_pago is null or btrim(p_metodo_pago) = '' then
    raise exception 'metodo_pago es requerido';
  end if;

  if p_total is null or p_total < 0 then
    raise exception 'total inválido';
  end if;

  if p_cart_items is null or jsonb_typeof(p_cart_items) <> 'array' or jsonb_array_length(p_cart_items) = 0 then
    raise exception 'cart_items debe ser un arreglo no vacío';
  end if;

  -- 1) Validate + lock every product row before creating the order.
  for v_item in
    select value
    from jsonb_array_elements(p_cart_items)
  loop
    v_producto_id := nullif(coalesce(v_item->>'producto_id', v_item->>'product_id', v_item->>'id'), '')::bigint;
    v_cantidad := nullif(coalesce(v_item->>'cantidad', v_item->>'qty'), '')::integer;
    v_precio_unitario := nullif(coalesce(v_item->>'precio_unitario', v_item->>'unit_price', v_item->>'precio'), '')::numeric;

    if v_producto_id is null then
      raise exception 'cart_item sin producto_id';
    end if;
    if v_cantidad is null or v_cantidad <= 0 then
      raise exception 'cantidad inválida para producto %', v_producto_id;
    end if;
    if v_precio_unitario is null or v_precio_unitario < 0 then
      raise exception 'precio_unitario inválido para producto %', v_producto_id;
    end if;

    -- Lock product row to prevent race conditions.
    select p.stock
      into v_stock_actual
    from public.productos p
    where p.id = v_producto_id
    for update;

    if not found then
      raise exception 'producto % no existe', v_producto_id;
    end if;

    if coalesce(v_stock_actual, 0) < v_cantidad then
      raise exception 'stock insuficiente para producto % (stock %, solicitado %)',
        v_producto_id, coalesce(v_stock_actual, 0), v_cantidad;
    end if;

    v_calc_total := v_calc_total + (v_precio_unitario * v_cantidad);
  end loop;

  -- Optional integrity check: caller total vs computed total.
  if round(coalesce(v_calc_total, 0), 2) <> round(coalesce(p_total, 0), 2) then
    raise exception 'total no coincide (esperado %, recibido %)', round(v_calc_total, 2), round(p_total, 2);
  end if;

  -- 2) Create pedido.
  insert into public.pedidos (
    cliente_id,
    total,
    estado,
    tipo,
    metodo_pago,
    atendido_por
  )
  values (
    null,
    p_total,
    'completado',
    'tienda_fisica',
    p_metodo_pago,
    p_user_id
  )
  returning id into v_pedido_id;

  -- 3) Insert items, 4) decrement stock, 5) log inventory movement.
  for v_item in
    select value
    from jsonb_array_elements(p_cart_items)
  loop
    v_producto_id := nullif(coalesce(v_item->>'producto_id', v_item->>'product_id', v_item->>'id'), '')::bigint;
    v_cantidad := nullif(coalesce(v_item->>'cantidad', v_item->>'qty'), '')::integer;
    v_precio_unitario := nullif(coalesce(v_item->>'precio_unitario', v_item->>'unit_price', v_item->>'precio'), '')::numeric;

    -- Row is locked already in this transaction, read current value again.
    select p.stock
      into v_stock_actual
    from public.productos p
    where p.id = v_producto_id
    for update;

    v_stock_nuevo := v_stock_actual - v_cantidad;

    insert into public.pedido_items (
      pedido_id,
      producto_id,
      cantidad,
      precio_unitario,
      lote,
      caducidad
    )
    values (
      v_pedido_id,
      v_producto_id,
      v_cantidad,
      v_precio_unitario,
      null,
      null
    );

    update public.productos
    set stock = v_stock_nuevo
    where id = v_producto_id;

    insert into public.movimientos_inventario (
      producto_id,
      tipo,
      cantidad,
      stock_antes,
      stock_despues,
      motivo,
      usuario_id
    )
    values (
      v_producto_id,
      'salida',
      v_cantidad,
      v_stock_actual,
      v_stock_nuevo,
      format('Venta POS pedido #%s', v_pedido_id),
      p_user_id
    );
  end loop;

  return query
  select v_pedido_id, true;

exception
  when others then
    -- Re-raise so outer transaction (RPC call) rolls back everything.
    raise;
end;
$$;

grant execute on function public.create_sale_transaction(bigint, text, numeric, jsonb) to anon, authenticated, service_role;

-- FARMAX: FEFO helper (first-expiring lot)
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
  order by l.fecha_caducidad asc nulls last, l.id asc
  limit 1;
$$;

grant execute on function public.get_lote_fefo(bigint) to anon, authenticated, service_role;

-- FARMAX v2: Atomic sale transaction with channel/delivery fields
create or replace function public.create_sale_transaction_v2(
  p_user_id bigint,
  p_metodo_pago text,
  p_total numeric,
  p_cart_items jsonb,
  p_cliente_id bigint default null,
  p_tipo text default 'pos',
  p_tipo_entrega text default null,
  p_direccion text default null
)
returns table(pedido_id bigint, success boolean)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pedido_id bigint;
  v_item jsonb;
  v_producto_id bigint;
  v_cantidad integer;
  v_precio_unitario numeric;
  v_modo_venta text;
  v_stock_actual integer;
  v_stock_unidades_actual integer;
  v_stock_nuevo integer;
  v_stock_unidades_nuevo integer;
  v_db_precio numeric;
  v_calc_total numeric := 0;
  v_lotes_activos integer;
  v_lotes_disponibles integer;
  v_restante integer;
  v_lote_id bigint;
  v_lote_numero text;
  v_lote_caducidad date;
  v_lote_disponible integer;
  v_lote_tomar integer;
  v_precio_prod numeric;
  v_precio_unidad_prod numeric;
  v_upc integer;
  v_notas text;
  v_tipo_guardado text;
begin
  if p_user_id is null then
    raise exception 'user_id es requerido';
  end if;

  if p_metodo_pago is null or btrim(p_metodo_pago) = '' then
    raise exception 'metodo_pago es requerido';
  end if;

  if p_total is null or p_total < 0 then
    raise exception 'total inválido';
  end if;

  if p_cart_items is null or jsonb_typeof(p_cart_items) <> 'array' or jsonb_array_length(p_cart_items) = 0 then
    raise exception 'cart_items debe ser un arreglo no vacío';
  end if;

  if p_tipo is null or btrim(p_tipo) = '' then
    raise exception 'p_tipo es requerido';
  end if;

  if p_tipo not in ('pos', 'online', 'pickup', 'delivery') then
    raise exception 'p_tipo inválido. Permitidos: pos, online, pickup, delivery';
  end if;

  -- 1) Validate + lock each product row FOR UPDATE.
  for v_item in
    select value
    from jsonb_array_elements(p_cart_items)
  loop
    v_producto_id := nullif(coalesce(v_item->>'producto_id', v_item->>'product_id', v_item->>'id'), '')::bigint;
    v_cantidad := nullif(coalesce(v_item->>'cantidad', v_item->>'qty'), '')::integer;
    v_precio_unitario := nullif(coalesce(v_item->>'precio_unitario', v_item->>'unit_price', v_item->>'precio'), '')::numeric;
    v_modo_venta := lower(coalesce(v_item->>'modo_venta', 'caja'));

    if v_producto_id is null then
      raise exception 'cart_item sin producto_id';
    end if;
    if v_cantidad is null or v_cantidad <= 0 then
      raise exception 'cantidad inválida para producto %', v_producto_id;
    end if;
    if v_modo_venta not in ('caja', 'unidad') then
      raise exception 'modo_venta inválido para producto % (permitidos: caja, unidad)', v_producto_id;
    end if;
    -- Keep client unit price optional, but never trust it for totals/persistence.
    if v_precio_unitario is not null and v_precio_unitario < 0 then
      raise exception 'precio_unitario inválido para producto %', v_producto_id;
    end if;

    select
      p.stock,
      coalesce(p.stock_unidades, 0),
      coalesce(p.precio, 0),
      coalesce(p.precio_unidad, 0)::numeric,
      greatest(coalesce(p.unidades_por_caja, 1), 1)
    into v_stock_actual, v_stock_unidades_actual, v_precio_prod, v_precio_unidad_prod, v_upc
    from public.productos p
    where p.id = v_producto_id
    for update;

    if not found then
      raise exception 'producto % no existe', v_producto_id;
    end if;

    if v_modo_venta = 'unidad' then
      v_db_precio := coalesce(
        nullif(v_precio_unidad_prod, 0),
        ceil((v_precio_prod / nullif(v_upc, 0))::numeric)::numeric
      );
    else
      v_db_precio := coalesce(v_precio_prod, 0);
    end if;

    if v_modo_venta = 'unidad' then
      if coalesce(v_stock_unidades_actual, 0) < v_cantidad then
        raise exception 'stock_unidades insuficiente para producto % (stock %, solicitado %)',
          v_producto_id, coalesce(v_stock_unidades_actual, 0), v_cantidad;
      end if;
    else
      if coalesce(v_stock_actual, 0) < v_cantidad then
        raise exception 'stock insuficiente para producto % (stock %, solicitado %)',
          v_producto_id, coalesce(v_stock_actual, 0), v_cantidad;
      end if;

      -- If lots exist for this product, FEFO availability becomes mandatory.
      select count(*)::integer
        into v_lotes_activos
      from public.lotes l
      where l.producto_id = v_producto_id
        and l.activo = true;

      if v_lotes_activos > 0 then
        select coalesce(sum(l.cantidad_actual), 0)::integer
          into v_lotes_disponibles
        from public.lotes l
        where l.producto_id = v_producto_id
          and l.activo = true
          and coalesce(l.cantidad_actual, 0) > 0
          and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date);

        if coalesce(v_lotes_disponibles, 0) < v_cantidad then
          raise exception 'lotes FEFO insuficientes para producto % (disponible %, solicitado %)',
            v_producto_id, coalesce(v_lotes_disponibles, 0), v_cantidad;
        end if;
      end if;
    end if;

    if v_db_precio < 0 then
      raise exception 'precio de base inválido para producto %', v_producto_id;
    end if;

    v_calc_total := v_calc_total + (v_db_precio * v_cantidad);
  end loop;

  if round(coalesce(v_calc_total, 0), 2) <> round(coalesce(p_total, 0), 2) then
    raise exception 'Total mismatch detected';
  end if;

  -- Dirección / entrega: muchas bases solo tienen notas (no columna direccion).
  v_notas := null;
  if (p_direccion is not null and btrim(p_direccion) <> '')
     or (p_tipo_entrega is not null and btrim(p_tipo_entrega) <> '') then
    v_notas := trim(
      concat_ws(
        E'\n',
        case
          when p_tipo_entrega is not null and btrim(p_tipo_entrega) <> '' then 'Entrega: ' || btrim(p_tipo_entrega)
          else null
        end,
        case
          when p_direccion is not null and btrim(p_direccion) <> '' then 'Dirección: ' || btrim(p_direccion)
          else null
        end
      )
    );
  end if;

  -- Valor guardado en pedidos.tipo (el UI y reportes usan tienda_fisica / online).
  v_tipo_guardado := case p_tipo
    when 'pos' then 'tienda_fisica'
    when 'online' then 'online'
    when 'pickup' then 'online'
    when 'delivery' then 'online'
    else 'tienda_fisica'
  end;

  -- 2) Create pedido with channel/delivery fields.
  insert into public.pedidos (
    cliente_id,
    total,
    estado,
    tipo,
    tipo_entrega,
    metodo_pago,
    atendido_por,
    notas
  )
  values (
    p_cliente_id,
    p_total,
    'completado',
    v_tipo_guardado,
    p_tipo_entrega,
    p_metodo_pago,
    p_user_id,
    v_notas
  )
  returning id into v_pedido_id;

  -- 3) Insert items + 4) atomic stock decrement + 5) movimiento log.
  for v_item in
    select value
    from jsonb_array_elements(p_cart_items)
  loop
    v_producto_id := nullif(coalesce(v_item->>'producto_id', v_item->>'product_id', v_item->>'id'), '')::bigint;
    v_cantidad := nullif(coalesce(v_item->>'cantidad', v_item->>'qty'), '')::integer;
    v_precio_unitario := nullif(coalesce(v_item->>'precio_unitario', v_item->>'unit_price', v_item->>'precio'), '')::numeric;
    v_modo_venta := lower(coalesce(v_item->>'modo_venta', 'caja'));

    select
      p.stock,
      coalesce(p.stock_unidades, 0),
      coalesce(p.precio, 0),
      coalesce(p.precio_unidad, 0)::numeric,
      greatest(coalesce(p.unidades_por_caja, 1), 1)
    into v_stock_actual, v_stock_unidades_actual, v_precio_prod, v_precio_unidad_prod, v_upc
    from public.productos p
    where p.id = v_producto_id
    for update;

    if not found then
      raise exception 'producto % no existe', v_producto_id;
    end if;

    if v_modo_venta = 'unidad' then
      v_db_precio := coalesce(
        nullif(v_precio_unidad_prod, 0),
        ceil((v_precio_prod / nullif(v_upc, 0))::numeric)::numeric
      );
    else
      v_db_precio := coalesce(v_precio_prod, 0);
    end if;

    if v_modo_venta = 'unidad' then
      v_stock_unidades_nuevo := v_stock_unidades_actual - v_cantidad;
    else
      v_stock_nuevo := v_stock_actual - v_cantidad;
    end if;

    if v_modo_venta = 'caja' then
      select count(*)::integer
        into v_lotes_activos
      from public.lotes l
      where l.producto_id = v_producto_id
        and l.activo = true;

      if v_lotes_activos > 0 then
        v_restante := v_cantidad;
        while v_restante > 0 loop
          select
            f.lote_id,
            f.numero_lote,
            f.fecha_caducidad,
            f.cantidad_disponible
            into v_lote_id, v_lote_numero, v_lote_caducidad, v_lote_disponible
          from public.get_lote_fefo(v_producto_id) f;

          if not found then
            raise exception 'sin lotes FEFO disponibles para producto %', v_producto_id;
          end if;

          v_lote_tomar := least(v_restante, coalesce(v_lote_disponible, 0));
          if v_lote_tomar <= 0 then
            raise exception 'lote FEFO inválido para producto %', v_producto_id;
          end if;

          update public.lotes
          set
            cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - v_lote_tomar),
            activo = case
              when greatest(0, coalesce(cantidad_actual, 0) - v_lote_tomar) <= 0 then false
              else activo
            end
          where id = v_lote_id;

          insert into public.pedido_items (
            pedido_id,
            producto_id,
            cantidad,
            precio_unitario,
            lote,
            caducidad
          )
          values (
            v_pedido_id,
            v_producto_id,
            v_lote_tomar,
            v_db_precio,
            v_lote_numero,
            v_lote_caducidad
          );

          v_restante := v_restante - v_lote_tomar;
        end loop;
      else
        insert into public.pedido_items (
          pedido_id,
          producto_id,
          cantidad,
          precio_unitario,
          lote,
          caducidad
        )
        values (
          v_pedido_id,
          v_producto_id,
          v_cantidad,
          v_db_precio,
          null,
          null
        );
      end if;
    else
      insert into public.pedido_items (
        pedido_id,
        producto_id,
        cantidad,
        precio_unitario,
        lote,
        caducidad
      )
      values (
        v_pedido_id,
        v_producto_id,
        v_cantidad,
        v_db_precio,
        null,
        null
      );
    end if;

    if v_modo_venta = 'unidad' then
      update public.productos
      set stock_unidades = v_stock_unidades_nuevo
      where id = v_producto_id;
    else
      update public.productos
      set stock = v_stock_nuevo
      where id = v_producto_id;
    end if;

    insert into public.movimientos_inventario (
      producto_id,
      tipo,
      cantidad,
      stock_antes,
      stock_despues,
      motivo,
      usuario_id
    )
    values (
      v_producto_id,
      'salida',
      v_cantidad,
      case when v_modo_venta = 'unidad' then v_stock_unidades_actual else v_stock_actual end,
      case when v_modo_venta = 'unidad' then v_stock_unidades_nuevo else v_stock_nuevo end,
      format('Venta %s (%s) pedido #%s', p_tipo, v_modo_venta, v_pedido_id),
      p_user_id
    );
  end loop;

  return query
  select v_pedido_id, true;

exception
  when others then
    raise;
end;
$$;

grant execute on function public.create_sale_transaction_v2(bigint, text, numeric, jsonb, bigint, text, text, text) to anon, authenticated, service_role;
