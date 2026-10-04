-- Caja con dos tamaños (parches Alfa Med: 5 grandes y 5 chicos).
-- Pegar en Supabase → SQL Editor → Run. Idempotente. No se aplica solo.
--
-- El renglón que en inventario dice «chico» se guarda en las columnas del blister
-- (piezas_por_blister = cuántos chicos trae la caja, precio_blister, stock_blisters).
-- No es una tira de tabletas: abrir la caja suma los dos tamaños a la vez.
-- Sin este parche, el mostrador rechaza el chico («no se vende por blister»).

begin;

create or replace function public.es_caja_dos_tamanos(p_nombre text, p_presentacion text)
returns boolean
language sql
immutable
as $$
  select coalesce(p_nombre, '') ~* '(2|dos)[[:space:]]*tama'
      or coalesce(p_presentacion, '') ~* '(2|dos)[[:space:]]*tama';
$$;

grant execute on function public.es_caja_dos_tamanos(text, text)
  to anon, authenticated, service_role;

-- ── Abrir caja: los dos tamaños, o la regla de blister / pieza ──────────────
create or replace function public.abrir_caja_lote(
  p_producto_id bigint,
  p_user_id bigint
)
returns table(stock_nuevo integer, stock_unidades_nuevo integer, stock_blisters_nuevo integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_upc integer;
  v_ppb integer;
  v_blisters integer;
  v_stock_unidades_actual integer;
  v_stock_blisters_actual integer;
  v_producto_stock integer;
  v_lote_id bigint;
  v_lote_cantidad integer;
  v_nombre text;
  v_presentacion text;
  v_dos boolean;
begin
  if p_producto_id is null then raise exception 'producto_id requerido'; end if;
  if p_user_id is null then raise exception 'user_id requerido'; end if;

  select
    greatest(coalesce(p.unidades_por_caja, 1), 1),
    coalesce(p.piezas_por_blister, 0),
    coalesce(p.stock_unidades, 0),
    coalesce(p.stock_blisters, 0),
    coalesce(p.stock, 0),
    coalesce(p.nombre, ''),
    coalesce(p.presentacion, '')
  into v_upc, v_ppb, v_stock_unidades_actual, v_stock_blisters_actual, v_producto_stock,
       v_nombre, v_presentacion
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

  v_dos := public.es_caja_dos_tamanos(v_nombre, v_presentacion);
  v_blisters := public.blisters_por_caja(v_upc, v_ppb);

  if v_dos and v_ppb >= 1 then
    update public.productos
    set
      stock_unidades = v_stock_unidades_actual + v_upc,
      stock_blisters = v_stock_blisters_actual + v_ppb
    where id = p_producto_id;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo, usuario_id
    ) values (
      p_producto_id, 'ajuste', 1,
      format('Abrir caja (+%s grandes, +%s chicos)', v_upc, v_ppb),
      p_user_id
    );
  elsif v_blisters >= 2 then
    update public.productos
    set stock_blisters = v_stock_blisters_actual + v_blisters
    where id = p_producto_id;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo, usuario_id
    ) values (
      p_producto_id, 'ajuste', 1,
      format('Abrir caja (+%s blisters)', v_blisters),
      p_user_id
    );
  else
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
  end if;

  return query
  select p.stock, p.stock_unidades, p.stock_blisters
  from public.productos p
  where p.id = p_producto_id;
end;
$$;

revoke execute on function public.abrir_caja_lote(bigint, bigint)
  from public, anon, authenticated;

-- ── Si la venta por grande abre la caja, también suelta los chicos ──────────
create or replace function public.fn_abrir_cajas_para_piezas(
  p_producto_id bigint,
  p_cantidad integer,
  p_user_id bigint
)
returns table(stock_unidades integer, lote_id bigint)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_sueltas integer;
  v_inicial integer;
  v_upc integer;
  v_lote bigint;
  v_disp integer;
  v_primero bigint := null;
  v_abiertas integer := 0;
  v_sync boolean := false;
  v_hay_lotes boolean;
  v_ppb integer;
  v_chicos integer;
  v_dos boolean;
begin
  if p_producto_id is null then
    raise exception 'producto_id requerido';
  end if;
  if p_cantidad is null or p_cantidad <= 0 then
    raise exception 'cantidad invalida para producto %', p_producto_id;
  end if;

  select
    coalesce(p.stock_unidades, 0),
    greatest(coalesce(p.unidades_por_caja, 1), 1),
    coalesce(p.piezas_por_blister, 0),
    coalesce(p.stock_blisters, 0),
    public.es_caja_dos_tamanos(coalesce(p.nombre, ''), coalesce(p.presentacion, ''))
  into v_sueltas, v_upc, v_ppb, v_chicos, v_dos
  from public.productos p
  where p.id = p_producto_id
  for update;

  if not found then
    raise exception 'producto % no existe', p_producto_id;
  end if;

  v_inicial := v_sueltas;

  if v_sueltas >= p_cantidad or not public.fn_puede_abrir_caja_para_piezas(p_producto_id) then
    if v_sueltas < p_cantidad then
      raise exception 'piezas sueltas insuficientes para producto % (faltan %)',
        p_producto_id, p_cantidad - v_sueltas;
    end if;
    return query select v_sueltas, null::bigint;
    return;
  end if;

  while v_sueltas < p_cantidad loop
    select f.lote_id, f.cantidad_disponible
      into v_lote, v_disp
    from public.get_lote_fefo(p_producto_id) f;

    if not found or coalesce(v_disp, 0) < 1 then
      if not v_sync then
        select exists(
          select 1 from public.lotes l where l.producto_id = p_producto_id
        ) into v_hay_lotes;
        if not v_hay_lotes then
          perform public.fn_ensure_lote_stock_vendible(p_producto_id);
        end if;
        v_sync := true;
        continue;
      end if;
      raise exception 'piezas sueltas insuficientes para producto % (faltan %)',
        p_producto_id, p_cantidad - v_sueltas;
    end if;

    update public.lotes
    set
      cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - 1),
      activo = case
        when greatest(0, coalesce(cantidad_actual, 0) - 1) <= 0 then false
        else activo
      end
    where id = v_lote;

    v_sueltas := v_sueltas + v_upc;
    if v_dos and v_ppb >= 1 then
      v_chicos := v_chicos + v_ppb;
    end if;

    update public.productos
    set
      stock_unidades = v_sueltas,
      stock_blisters = case when v_dos and v_ppb >= 1 then v_chicos else stock_blisters end
    where id = p_producto_id;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo, usuario_id
    ) values (
      p_producto_id, 'ajuste', 1,
      case
        when v_dos and v_ppb >= 1 then format('Abrir caja para venta por tamaño (+%s grandes, +%s chicos)', v_upc, v_ppb)
        else format('Abrir caja para venta por pieza (+%s)', v_upc)
      end,
      p_user_id
    );

    if v_primero is null then
      v_primero := v_lote;
    end if;

    v_abiertas := v_abiertas + 1;
    if v_abiertas > 200 then
      raise exception 'piezas sueltas insuficientes para producto % (faltan %)',
        p_producto_id, p_cantidad - v_sueltas;
    end if;
  end loop;

  return query
  select v_sueltas, case when v_inicial = 0 then v_primero else null::bigint end;
end;
$$;

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
  v_stock_blisters_actual integer;
  v_stock_blisters_nuevo integer;
  v_calc_total numeric := 0;
  v_db_precio numeric;
  v_lotes_disponibles integer;
  v_restante integer;
  v_lote_id bigint;
  v_lote_disponible integer;
  v_lote_tomar integer;
  v_precio_prod numeric;
  v_precio_unidad_prod numeric;
  v_precio_blister_prod numeric;
  v_upc integer;
  v_ppb integer;
  v_costo_prod numeric;
  v_categoria_prod text;
  v_tipo_prod text;
  v_notas text;
  v_tipo_guardado text;
  v_piezas_comprometidas jsonb := '{}'::jsonb;
  v_piezas_ya integer;
  v_piezas_disp integer;
  v_lote_pieza bigint;
  v_nombre text;
  v_presentacion text;
  v_dos boolean;
begin
  if p_user_id is null then raise exception 'user_id es requerido'; end if;
  if p_metodo_pago is null or btrim(p_metodo_pago) = '' then
    raise exception 'metodo_pago es requerido';
  end if;
  if p_total is null or p_total < 0 then raise exception 'total invalido'; end if;
  if p_cart_items is null or jsonb_typeof(p_cart_items) <> 'array'
     or jsonb_array_length(p_cart_items) = 0 then
    raise exception 'cart_items debe ser un arreglo no vacio';
  end if;
  if p_tipo is null or btrim(p_tipo) = '' then raise exception 'p_tipo es requerido'; end if;
  if p_tipo not in ('pos', 'online', 'pickup', 'delivery') then
    raise exception 'p_tipo invalido. Permitidos: pos, online, pickup, delivery';
  end if;

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

    if v_producto_id is null then raise exception 'cart_item sin producto_id'; end if;
    if v_cantidad is null or v_cantidad <= 0 then
      raise exception 'cantidad invalida para producto %', v_producto_id;
    end if;
    if v_modo_venta not in ('caja', 'unidad', 'blister') then
      raise exception 'modo_venta invalido para producto % (permitidos: caja, unidad, blister)',
        v_producto_id;
    end if;
    if v_precio_unitario is not null and v_precio_unitario < 0 then
      raise exception 'precio_unitario invalido para producto %', v_producto_id;
    end if;

    select
      p.stock,
      coalesce(p.stock_unidades, 0),
      coalesce(p.stock_blisters, 0),
      coalesce(p.precio, 0),
      coalesce(p.precio_unidad, 0)::numeric,
      coalesce(p.precio_blister, 0)::numeric,
      greatest(coalesce(p.unidades_por_caja, 1), 1),
      coalesce(p.piezas_por_blister, 0),
      coalesce(p.costo, 0),
      coalesce(p.categoria, ''),
      coalesce(p.tipo, ''),
      coalesce(p.nombre, ''),
      coalesce(p.presentacion, '')
    into v_stock_actual, v_stock_unidades_actual, v_stock_blisters_actual,
         v_precio_prod, v_precio_unidad_prod, v_precio_blister_prod, v_upc, v_ppb,
         v_costo_prod, v_categoria_prod, v_tipo_prod, v_nombre, v_presentacion
    from public.productos p
    where p.id = v_producto_id
    for update;

    if not found then
      raise exception 'producto % no existe', v_producto_id;
    end if;

    v_dos := public.es_caja_dos_tamanos(v_nombre, v_presentacion);

    if v_modo_venta = 'blister'
       and public.blisters_por_caja(v_upc, v_ppb) < 2
       and not (
         v_dos
         and coalesce(v_ppb, 0) >= 1
         and coalesce(v_precio_blister_prod, 0) > 0
       ) then
      raise exception 'producto % no se vende por blister', v_producto_id;
    end if;

    v_db_precio := case v_modo_venta
      when 'unidad' then public.precio_unidad_efectivo(
        v_costo_prod,
        v_precio_prod,
        v_upc,
        v_categoria_prod,
        v_tipo_prod,
        v_precio_unidad_prod
      )
      when 'blister' then case
        when v_dos and coalesce(v_precio_blister_prod, 0) > 0 then ceil(v_precio_blister_prod)
        else public.precio_blister_efectivo(
          v_costo_prod,
          v_precio_prod,
          v_upc,
          v_ppb,
          v_categoria_prod,
          v_tipo_prod,
          v_precio_blister_prod
        )
      end
      else coalesce(v_precio_prod, 0)
    end;
    -- Unidad: $0.50 ($1.50 se queda). Caja y blister siguen en peso entero.
    if p_tipo = 'pos' and v_modo_venta = 'unidad' then
      v_db_precio := coalesce(public.snap_precio_venta(v_db_precio), 0);
    elsif p_tipo = 'pos' then
      v_db_precio := public.peso_publico(v_db_precio);
    end if;
    if v_modo_venta = 'caja' and p_tipo = 'pos' then
      v_db_precio := public.precio_caja_cobro_pos(
        v_producto_id, v_cantidad, v_precio_unitario
      );
    end if;

    if v_modo_venta = 'unidad' then
      if to_regprocedure('public.fn_piezas_sueltas_disponibles(bigint)') is not null then
        v_piezas_ya := coalesce((v_piezas_comprometidas ->> v_producto_id::text)::integer, 0);
        v_piezas_disp := public.fn_piezas_sueltas_disponibles(v_producto_id);
        if coalesce(v_piezas_disp, 0) < v_piezas_ya + v_cantidad then
          raise exception 'piezas sueltas insuficientes para producto % (faltan %)',
            v_producto_id, (v_piezas_ya + v_cantidad) - coalesce(v_piezas_disp, 0);
        end if;
        v_piezas_comprometidas := v_piezas_comprometidas
          || jsonb_build_object(v_producto_id::text, v_piezas_ya + v_cantidad);
      elsif coalesce(v_stock_unidades_actual, 0) < v_cantidad then
        raise exception 'stock_unidades insuficiente para producto % (stock %, solicitado %)',
          v_producto_id, coalesce(v_stock_unidades_actual, 0), v_cantidad;
      end if;
    elsif v_modo_venta = 'blister' then
      if coalesce(v_stock_blisters_actual, 0) < v_cantidad then
        raise exception 'stock_blisters insuficiente para producto % (stock %, solicitado %)',
          v_producto_id, coalesce(v_stock_blisters_actual, 0), v_cantidad;
      end if;
    else
      select coalesce(sum(l.cantidad_actual), 0)::integer
        into v_lotes_disponibles
      from public.lotes l
      where l.producto_id = v_producto_id
        and coalesce(l.activo, true) = true
        and coalesce(l.cantidad_actual, 0) > 0
        and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date);

      if coalesce(v_lotes_disponibles, 0) < v_cantidad then
        perform public.fn_ensure_lote_stock_vendible(v_producto_id);
        select coalesce(sum(l.cantidad_actual), 0)::integer
          into v_lotes_disponibles
        from public.lotes l
        where l.producto_id = v_producto_id
          and coalesce(l.activo, true) = true
          and coalesce(l.cantidad_actual, 0) > 0
          and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date);
      end if;

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

  insert into public.pedidos (
    cliente_id, total, estado, tipo, tipo_entrega, metodo_pago, atendido_por, notas
  ) values (
    p_cliente_id, p_total, 'completado', v_tipo_guardado,
    p_tipo_entrega, p_metodo_pago, p_user_id, v_notas
  ) returning id into v_pedido_id;

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

    select
      coalesce(p.precio, 0),
      coalesce(p.precio_unidad, 0)::numeric,
      coalesce(p.precio_blister, 0)::numeric,
      greatest(coalesce(p.unidades_por_caja, 1), 1),
      coalesce(p.piezas_por_blister, 0),
      coalesce(p.stock_unidades, 0),
      coalesce(p.stock_blisters, 0),
      coalesce(p.costo, 0),
      coalesce(p.categoria, ''),
      coalesce(p.tipo, ''),
      coalesce(p.nombre, ''),
      coalesce(p.presentacion, '')
    into v_precio_prod, v_precio_unidad_prod, v_precio_blister_prod, v_upc, v_ppb,
         v_stock_unidades_actual, v_stock_blisters_actual,
         v_costo_prod, v_categoria_prod, v_tipo_prod, v_nombre, v_presentacion
    from public.productos p
    where p.id = v_producto_id
    for update;

    v_dos := public.es_caja_dos_tamanos(v_nombre, v_presentacion);

    v_db_precio := case v_modo_venta
      when 'unidad' then public.precio_unidad_efectivo(
        v_costo_prod,
        v_precio_prod,
        v_upc,
        v_categoria_prod,
        v_tipo_prod,
        v_precio_unidad_prod
      )
      when 'blister' then case
        when v_dos and coalesce(v_precio_blister_prod, 0) > 0 then ceil(v_precio_blister_prod)
        else public.precio_blister_efectivo(
          v_costo_prod,
          v_precio_prod,
          v_upc,
          v_ppb,
          v_categoria_prod,
          v_tipo_prod,
          v_precio_blister_prod
        )
      end
      else coalesce(v_precio_prod, 0)
    end;
    -- Unidad: $0.50 ($1.50 se queda). Caja y blister siguen en peso entero.
    if p_tipo = 'pos' and v_modo_venta = 'unidad' then
      v_db_precio := coalesce(public.snap_precio_venta(v_db_precio), 0);
    elsif p_tipo = 'pos' then
      v_db_precio := public.peso_publico(v_db_precio);
    end if;
    if v_modo_venta = 'caja' and p_tipo = 'pos' then
      v_db_precio := public.precio_caja_cobro_pos(
        v_producto_id, v_cantidad, v_precio_unitario
      );
    end if;

    if v_modo_venta = 'unidad' then
      v_lote_pieza := null;
      if to_regprocedure('public.fn_abrir_cajas_para_piezas(bigint,integer,bigint)') is not null then
        select a.stock_unidades, a.lote_id
          into v_stock_unidades_actual, v_lote_pieza
        from public.fn_abrir_cajas_para_piezas(v_producto_id, v_cantidad, p_user_id) a;
      end if;

      v_stock_unidades_nuevo := v_stock_unidades_actual - v_cantidad;

      update public.productos
      set stock_unidades = v_stock_unidades_nuevo
      where id = v_producto_id;

      insert into public.pedido_items (
        pedido_id, producto_id, cantidad, precio_unitario, lote_id
      ) values (
        v_pedido_id, v_producto_id, v_cantidad, v_db_precio, v_lote_pieza
      );

      insert into public.movimientos_inventario (
        producto_id, tipo, cantidad, motivo, usuario_id, referencia
      ) values (
        v_producto_id, 'salida', v_cantidad,
        format('Venta %s (%s) pedido #%s', p_tipo, case when v_dos then 'grande' else 'unidad' end, v_pedido_id),
        p_user_id, v_pedido_id::text
      );

    elsif v_modo_venta = 'blister' then
      v_stock_blisters_nuevo := v_stock_blisters_actual - v_cantidad;

      update public.productos
      set stock_blisters = v_stock_blisters_nuevo
      where id = v_producto_id;

      insert into public.pedido_items (
        pedido_id, producto_id, cantidad, precio_unitario, lote_id
      ) values (
        v_pedido_id, v_producto_id, v_cantidad, v_db_precio, null
      );

      insert into public.movimientos_inventario (
        producto_id, tipo, cantidad, motivo, usuario_id, referencia
      ) values (
        v_producto_id, 'salida', v_cantidad,
        format('Venta %s (%s) pedido #%s', p_tipo, case when v_dos then 'chico' else 'blister' end, v_pedido_id),
        p_user_id, v_pedido_id::text
      );

    else
      perform public.fn_ensure_lote_stock_vendible(v_producto_id);
      v_restante := v_cantidad;
      while v_restante > 0 loop
        select f.lote_id, f.cantidad_disponible
          into v_lote_id, v_lote_disponible
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
          pedido_id, producto_id, cantidad, precio_unitario, lote_id
        ) values (
          v_pedido_id, v_producto_id, v_lote_tomar, v_db_precio, v_lote_id
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

commit;
