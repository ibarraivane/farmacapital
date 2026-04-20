-- ============================================================
-- FARMAX — F3a: RPCs para que TODO el stock pase por lotes
-- ============================================================
--
-- Objetivo: despues de F3a, productos.stock es estrictamente un
-- campo derivado (lo escribe solo el trigger fn_sync_productos_stock).
-- Todo cambio de stock se hace via lotes, usando:
--
--   - create_sale_transaction_v2  (ventas, ya existente, reescrita)
--   - abrir_caja_lote             (abrir 1 caja -> N unidades)
--   - restock_via_lote            (devoluciones / entradas manuales)
--   - adjust_stock_via_lotes      (ajustes manuales, puede ser +/-)
--   - create_producto_with_lote   (alta de producto con stock inicial)
--
-- Todas las funciones son idempotentes en su definicion (CREATE OR
-- REPLACE) y no tocan datos ya existentes.
-- ============================================================

begin;

-- ============================================================
-- 1) create_sale_transaction_v2: reescrita para depender solo de lotes
-- ============================================================
-- Cambios vs la version anterior:
--   - En modo 'caja', YA NO hace UPDATE productos SET stock (el trigger
--     fn_sync_productos_stock lo hace automaticamente al mover lotes).
--   - Siempre exige lotes FEFO (ya no hay fallback "sin lotes" porque
--     F2.5a garantiza que todo producto con stock > 0 tiene lote).
--   - Popula pedido_items.lote_id (FK) ademas del texto legacy 'lote'.
--   - En modo 'unidad' sigue tocando productos.stock_unidades directo
--     (no hay modelo de lotes para unidades sueltas).
-- ============================================================

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
  v_stock_unidades_nuevo integer;
  v_calc_total numeric := 0;
  v_db_precio numeric;
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
  -- Validaciones basicas
  if p_user_id is null then
    raise exception 'user_id es requerido';
  end if;
  if p_metodo_pago is null or btrim(p_metodo_pago) = '' then
    raise exception 'metodo_pago es requerido';
  end if;
  if p_total is null or p_total < 0 then
    raise exception 'total invalido';
  end if;
  if p_cart_items is null or jsonb_typeof(p_cart_items) <> 'array'
     or jsonb_array_length(p_cart_items) = 0 then
    raise exception 'cart_items debe ser un arreglo no vacio';
  end if;
  if p_tipo is null or btrim(p_tipo) = '' then
    raise exception 'p_tipo es requerido';
  end if;
  if p_tipo not in ('pos', 'online', 'pickup', 'delivery') then
    raise exception 'p_tipo invalido. Permitidos: pos, online, pickup, delivery';
  end if;

  -- 1) Validar + lock fila producto + validar disponibilidad FEFO
  for v_item in select value from jsonb_array_elements(p_cart_items)
  loop
    v_producto_id := nullif(coalesce(
      v_item->>'producto_id', v_item->>'product_id', v_item->>'id'
    ), '')::bigint;
    v_cantidad := nullif(coalesce(
      v_item->>'cantidad', v_item->>'qty'
    ), '')::integer;
    v_precio_unitario := nullif(coalesce(
      v_item->>'precio_unitario', v_item->>'unit_price', v_item->>'precio'
    ), '')::numeric;
    v_modo_venta := lower(coalesce(v_item->>'modo_venta', 'caja'));

    if v_producto_id is null then
      raise exception 'cart_item sin producto_id';
    end if;
    if v_cantidad is null or v_cantidad <= 0 then
      raise exception 'cantidad invalida para producto %', v_producto_id;
    end if;
    if v_modo_venta not in ('caja', 'unidad') then
      raise exception 'modo_venta invalido para producto % (permitidos: caja, unidad)',
        v_producto_id;
    end if;
    if v_precio_unitario is not null and v_precio_unitario < 0 then
      raise exception 'precio_unitario invalido para producto %', v_producto_id;
    end if;

    select
      p.stock,
      coalesce(p.stock_unidades, 0),
      coalesce(p.precio, 0),
      coalesce(p.precio_unidad, 0)::numeric,
      greatest(coalesce(p.unidades_por_caja, 1), 1)
    into v_stock_actual, v_stock_unidades_actual,
         v_precio_prod, v_precio_unidad_prod, v_upc
    from public.productos p
    where p.id = v_producto_id
    for update;

    if not found then
      raise exception 'producto % no existe', v_producto_id;
    end if;

    v_db_precio := case v_modo_venta
      when 'unidad' then coalesce(
        nullif(v_precio_unidad_prod, 0),
        ceil((v_precio_prod / nullif(v_upc, 0))::numeric)::numeric
      )
      else coalesce(v_precio_prod, 0)
    end;

    if v_modo_venta = 'unidad' then
      if coalesce(v_stock_unidades_actual, 0) < v_cantidad then
        raise exception 'stock_unidades insuficiente para producto % (stock %, solicitado %)',
          v_producto_id, coalesce(v_stock_unidades_actual, 0), v_cantidad;
      end if;
    else
      -- Modo caja: validar via lotes (FEFO)
      select coalesce(sum(l.cantidad_actual), 0)::integer
        into v_lotes_disponibles
      from public.lotes l
      where l.producto_id = v_producto_id
        and coalesce(l.activo, true) = true
        and coalesce(l.cantidad_actual, 0) > 0
        and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date);

      if coalesce(v_lotes_disponibles, 0) < v_cantidad then
        raise exception 'lotes FEFO insuficientes para producto % (disponible %, solicitado %)',
          v_producto_id, coalesce(v_lotes_disponibles, 0), v_cantidad;
      end if;
    end if;

    if v_db_precio < 0 then
      raise exception 'precio base invalido para producto %', v_producto_id;
    end if;

    v_calc_total := v_calc_total + (v_db_precio * v_cantidad);
  end loop;

  if round(coalesce(v_calc_total, 0), 2) <> round(coalesce(p_total, 0), 2) then
    raise exception 'Total mismatch detected (esperado %, recibido %)',
      round(v_calc_total, 2), round(p_total, 2);
  end if;

  -- Notas de entrega
  v_notas := null;
  if (p_direccion is not null and btrim(p_direccion) <> '')
     or (p_tipo_entrega is not null and btrim(p_tipo_entrega) <> '') then
    v_notas := trim(concat_ws(
      E'\n',
      case when p_tipo_entrega is not null and btrim(p_tipo_entrega) <> ''
           then 'Entrega: ' || btrim(p_tipo_entrega) else null end,
      case when p_direccion is not null and btrim(p_direccion) <> ''
           then 'Direccion: ' || btrim(p_direccion) else null end
    ));
  end if;

  v_tipo_guardado := case p_tipo
    when 'pos' then 'tienda_fisica'
    when 'online' then 'online'
    when 'pickup' then 'online'
    when 'delivery' then 'online'
    else 'tienda_fisica'
  end;

  -- 2) Crear pedido
  insert into public.pedidos (
    cliente_id, total, estado, tipo, tipo_entrega, metodo_pago, atendido_por, notas
  ) values (
    p_cliente_id, p_total, 'completado', v_tipo_guardado,
    p_tipo_entrega, p_metodo_pago, p_user_id, v_notas
  ) returning id into v_pedido_id;

  -- 3) Items + decremento via lotes + log
  for v_item in select value from jsonb_array_elements(p_cart_items)
  loop
    v_producto_id := nullif(coalesce(
      v_item->>'producto_id', v_item->>'product_id', v_item->>'id'
    ), '')::bigint;
    v_cantidad := nullif(coalesce(
      v_item->>'cantidad', v_item->>'qty'
    ), '')::integer;
    v_modo_venta := lower(coalesce(v_item->>'modo_venta', 'caja'));

    -- Releer precios autoritativos desde la DB (nunca confiar en el cliente)
    select
      coalesce(p.precio, 0),
      coalesce(p.precio_unidad, 0)::numeric,
      greatest(coalesce(p.unidades_por_caja, 1), 1),
      coalesce(p.stock_unidades, 0)
    into v_precio_prod, v_precio_unidad_prod, v_upc, v_stock_unidades_actual
    from public.productos p
    where p.id = v_producto_id
    for update;

    v_db_precio := case v_modo_venta
      when 'unidad' then coalesce(
        nullif(v_precio_unidad_prod, 0),
        ceil((v_precio_prod / nullif(v_upc, 0))::numeric)::numeric
      )
      else coalesce(v_precio_prod, 0)
    end;

    if v_modo_venta = 'unidad' then
      -- Unidad: decrementar productos.stock_unidades directo (no hay modelo de lotes)
      v_stock_unidades_nuevo := v_stock_unidades_actual - v_cantidad;

      update public.productos
      set stock_unidades = v_stock_unidades_nuevo
      where id = v_producto_id;

      insert into public.pedido_items (
        pedido_id, producto_id, cantidad, precio_unitario,
        lote_id, lote, caducidad
      ) values (
        v_pedido_id, v_producto_id, v_cantidad, v_db_precio,
        null, null, null
      );

      insert into public.movimientos_inventario (
        producto_id, tipo, cantidad, motivo, usuario_id, referencia
      ) values (
        v_producto_id, 'salida', v_cantidad,
        format('Venta %s (unidad) pedido #%s', p_tipo, v_pedido_id),
        p_user_id, v_pedido_id::text
      );

    else
      -- Caja: consumir lotes FEFO. El trigger sincroniza productos.stock.
      v_restante := v_cantidad;
      while v_restante > 0 loop
        select f.lote_id, f.numero_lote, f.fecha_caducidad, f.cantidad_disponible
          into v_lote_id, v_lote_numero, v_lote_caducidad, v_lote_disponible
        from public.get_lote_fefo(v_producto_id) f;

        if not found then
          raise exception 'sin lotes FEFO disponibles para producto %', v_producto_id;
        end if;

        v_lote_tomar := least(v_restante, coalesce(v_lote_disponible, 0));
        if v_lote_tomar <= 0 then
          raise exception 'lote FEFO invalido para producto %', v_producto_id;
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
          pedido_id, producto_id, cantidad, precio_unitario,
          lote_id, lote, caducidad
        ) values (
          v_pedido_id, v_producto_id, v_lote_tomar, v_db_precio,
          v_lote_id, v_lote_numero, v_lote_caducidad
        );

        v_restante := v_restante - v_lote_tomar;
      end loop;

      insert into public.movimientos_inventario (
        producto_id, tipo, cantidad, motivo, usuario_id, referencia
      ) values (
        v_producto_id, 'salida', v_cantidad,
        format('Venta %s (caja) pedido #%s', p_tipo, v_pedido_id),
        p_user_id, v_pedido_id::text
      );
    end if;
  end loop;

  return query select v_pedido_id, true;

exception when others then
  raise;
end;
$$;

grant execute on function public.create_sale_transaction_v2(
  bigint, text, numeric, jsonb, bigint, text, text, text
) to anon, authenticated, service_role;


-- ============================================================
-- 2) abrir_caja_lote: convierte 1 caja -> N unidades sueltas
-- ============================================================

create or replace function public.abrir_caja_lote(
  p_producto_id bigint,
  p_user_id bigint
)
returns table(stock_nuevo integer, stock_unidades_nuevo integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_upc integer;
  v_stock_unidades_actual integer;
  v_producto_stock integer;
  v_lote_id bigint;
  v_lote_cantidad integer;
begin
  if p_producto_id is null then raise exception 'producto_id requerido'; end if;
  if p_user_id is null then raise exception 'user_id requerido'; end if;

  select
    greatest(coalesce(p.unidades_por_caja, 1), 1),
    coalesce(p.stock_unidades, 0),
    coalesce(p.stock, 0)
  into v_upc, v_stock_unidades_actual, v_producto_stock
  from public.productos p
  where p.id = p_producto_id
  for update;

  if not found then
    raise exception 'producto % no existe', p_producto_id;
  end if;

  if v_producto_stock <= 0 then
    raise exception 'producto % no tiene cajas disponibles', p_producto_id;
  end if;

  select f.lote_id, f.cantidad_disponible
    into v_lote_id, v_lote_cantidad
  from public.get_lote_fefo(p_producto_id) f;

  if not found or coalesce(v_lote_cantidad, 0) < 1 then
    raise exception 'sin lotes disponibles para producto %', p_producto_id;
  end if;

  update public.lotes
  set
    cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - 1),
    activo = case
      when greatest(0, coalesce(cantidad_actual, 0) - 1) <= 0 then false
      else activo
    end
  where id = v_lote_id;

  update public.productos
  set stock_unidades = v_stock_unidades_actual + v_upc
  where id = p_producto_id;

  insert into public.movimientos_inventario (
    producto_id, tipo, cantidad, motivo, usuario_id
  ) values (
    p_producto_id, 'ajuste', 1,
    format('Abrir caja (+%s unidades sueltas)', v_upc),
    p_user_id
  );

  return query
  select p.stock, p.stock_unidades
  from public.productos p
  where p.id = p_producto_id;
end;
$$;

grant execute on function public.abrir_caja_lote(bigint, bigint)
  to anon, authenticated, service_role;


-- ============================================================
-- 3) restock_via_lote: reintegrar stock (devoluciones, entradas)
-- ============================================================
-- Si p_lote_id se pasa, se suma a ese lote.
-- Si no, se suma al lote activo mas reciente; si no hay, crea uno sintetico.
-- ============================================================

create or replace function public.restock_via_lote(
  p_producto_id bigint,
  p_cantidad integer,
  p_motivo text,
  p_user_id bigint,
  p_lote_id bigint default null
)
returns table(stock_nuevo integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_lote_id bigint;
begin
  if p_producto_id is null then raise exception 'producto_id requerido'; end if;
  if p_cantidad is null or p_cantidad <= 0 then raise exception 'cantidad invalida'; end if;
  if p_user_id is null then raise exception 'user_id requerido'; end if;

  if p_lote_id is not null then
    select id into v_lote_id
    from public.lotes
    where id = p_lote_id and producto_id = p_producto_id
    for update;
    if not found then
      raise exception 'lote % no existe para producto %', p_lote_id, p_producto_id;
    end if;
  else
    select id into v_lote_id
    from public.lotes
    where producto_id = p_producto_id and coalesce(activo, true) = true
    order by (fecha_caducidad is null) asc, fecha_caducidad desc nulls last, id desc
    limit 1
    for update;
  end if;

  if v_lote_id is null then
    insert into public.lotes (
      producto_id, numero_lote, cantidad_inicial, cantidad_actual, activo
    ) values (
      p_producto_id,
      'REINTEGRO-' || to_char(now(), 'YYYYMMDD-HH24MISS'),
      p_cantidad, p_cantidad, true
    ) returning id into v_lote_id;
  else
    update public.lotes
    set cantidad_actual = coalesce(cantidad_actual, 0) + p_cantidad,
        activo = true
    where id = v_lote_id;
  end if;

  insert into public.movimientos_inventario (
    producto_id, tipo, cantidad, motivo, usuario_id
  ) values (
    p_producto_id, 'entrada', p_cantidad,
    coalesce(p_motivo, 'Reintegro'),
    p_user_id
  );

  return query
  select p.stock from public.productos p where p.id = p_producto_id;
end;
$$;

grant execute on function public.restock_via_lote(bigint, integer, text, bigint, bigint)
  to anon, authenticated, service_role;


-- ============================================================
-- 4) adjust_stock_via_lotes: ajuste manual (+/-) a un nuevo stock objetivo
-- ============================================================

create or replace function public.adjust_stock_via_lotes(
  p_producto_id bigint,
  p_nuevo_stock integer,
  p_motivo text,
  p_user_id bigint
)
returns table(stock_nuevo integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_stock_actual integer;
  v_delta integer;
  v_lote_id bigint;
  v_lote_cantidad integer;
  v_restante integer;
begin
  if p_producto_id is null then raise exception 'producto_id requerido'; end if;
  if p_nuevo_stock is null or p_nuevo_stock < 0 then raise exception 'nuevo_stock invalido'; end if;
  if p_user_id is null then raise exception 'user_id requerido'; end if;

  select coalesce(p.stock, 0) into v_stock_actual
  from public.productos p
  where p.id = p_producto_id
  for update;

  if not found then
    raise exception 'producto % no existe', p_producto_id;
  end if;

  v_delta := p_nuevo_stock - v_stock_actual;

  if v_delta = 0 then
    return query select v_stock_actual;
    return;
  end if;

  if v_delta > 0 then
    perform public.restock_via_lote(
      p_producto_id, v_delta,
      coalesce(p_motivo, 'Ajuste manual (+)'),
      p_user_id, null
    );
  else
    v_restante := abs(v_delta);
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
        raise exception 'no hay lotes suficientes para disminuir stock en producto %',
          p_producto_id;
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
      producto_id, tipo, cantidad, motivo, usuario_id
    ) values (
      p_producto_id, 'ajuste', abs(v_delta),
      coalesce(p_motivo, 'Ajuste manual (-)'),
      p_user_id
    );
  end if;

  return query
  select p.stock from public.productos p where p.id = p_producto_id;
end;
$$;

grant execute on function public.adjust_stock_via_lotes(bigint, integer, text, bigint)
  to anon, authenticated, service_role;


-- ============================================================
-- 5) create_producto_with_lote: alta atomica de producto + lote inicial
-- ============================================================
-- p_producto_data es un jsonb con los campos del producto:
--   nombre (requerido), sku, precio, costo, stock_minimo, stock_unidades,
--   unidades_por_caja, categoria, tipo, receta, activo, descripcion,
--   codigo_barras, precio_unidad, precio_similares, precio_del_ahorro,
--   requiere_receta
-- p_cantidad_inicial > 0 crea un lote asociado.
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
begin
  if p_producto_data is null then
    raise exception 'producto_data requerido';
  end if;
  if (p_producto_data->>'nombre') is null or btrim(p_producto_data->>'nombre') = '' then
    raise exception 'nombre requerido';
  end if;

  insert into public.productos (
    nombre, sku, precio, costo, stock, stock_minimo, stock_unidades,
    unidades_por_caja, categoria, tipo, receta, activo, descripcion,
    codigo_barras, precio_unidad, precio_similares, precio_del_ahorro,
    requiere_receta
  ) values (
    p_producto_data->>'nombre',
    p_producto_data->>'sku',
    nullif(p_producto_data->>'precio', '')::numeric,
    nullif(p_producto_data->>'costo', '')::numeric,
    0,
    coalesce(nullif(p_producto_data->>'stock_minimo', '')::integer, 0),
    coalesce(nullif(p_producto_data->>'stock_unidades', '')::integer, 0),
    nullif(p_producto_data->>'unidades_por_caja', '')::integer,
    p_producto_data->>'categoria',
    p_producto_data->>'tipo',
    nullif(p_producto_data->>'receta', '')::boolean,
    coalesce(nullif(p_producto_data->>'activo', '')::boolean, true),
    p_producto_data->>'descripcion',
    p_producto_data->>'codigo_barras',
    nullif(p_producto_data->>'precio_unidad', '')::numeric,
    nullif(p_producto_data->>'precio_similares', '')::numeric,
    nullif(p_producto_data->>'precio_del_ahorro', '')::numeric,
    nullif(p_producto_data->>'requiere_receta', '')::boolean
  ) returning id into v_producto_id;

  if coalesce(p_cantidad_inicial, 0) > 0 then
    insert into public.lotes (
      producto_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_caducidad, costo_unitario, activo
    ) values (
      v_producto_id,
      coalesce(p_numero_lote, 'INICIAL-' || to_char(now(), 'YYYYMMDD-HH24MISS')),
      p_cantidad_inicial, p_cantidad_inicial,
      p_fecha_caducidad, p_costo_unitario, true
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


commit;

-- ============================================================
-- FIN F3a
-- ============================================================
-- Siguiente paso: correr sql/004_verificar_fase3a.sql para
-- validar que:
--   - Las 5 funciones existen.
--   - Una venta de prueba decrementa lote y productos.stock sincronizado.
--   - adjust_stock_via_lotes + abrir_caja_lote funcionan.
-- ============================================================
