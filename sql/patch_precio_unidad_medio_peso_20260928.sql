-- Precio por unidad en pasos de $0.50 (medio peso).
-- Pegar en Supabase → SQL Editor → Run. Idempotente. No se aplica solo.
--
-- $1.50 guardado se cobra $1.50. $1.20 se ajusta a $1.00. $1.30 a $1.50.
-- peso_publico sigue redondeando caja y blister al peso entero.
-- No toca precio_blister (sigue con ceil) ni precio_caja_cobro_pos.
--
-- create_sale_transaction_v2 parte del cuerpo con blister
-- (patch_venta_blister_20260926.sql) y, si ya existen, usa
-- fn_piezas_sueltas_disponibles / fn_abrir_cajas_para_piezas
-- (patch_venta_pieza_abre_caja_20260926.sql) para no perder abrir caja.

begin;

-- El cobro ya llama a esta función. Si no existe, ni la caja ni la pieza cierran la venta.
create or replace function public.blisters_por_caja(p_upc integer, p_ppb integer)
returns integer
language sql
immutable
as $$
  select case
    when coalesce(p_ppb, 0) >= 2
     and coalesce(p_upc, 0) >= 2
     and (p_upc % p_ppb) = 0
     and (p_upc / p_ppb) >= 2
    then p_upc / p_ppb
    else 0
  end;
$$;

create or replace function public.precio_blister_efectivo(
  p_costo numeric,
  p_precio_caja numeric,
  p_upc integer,
  p_ppb integer,
  p_categoria text,
  p_tipo text,
  p_precio_blister_guardado numeric
)
returns numeric
language sql
immutable
as $$
  select case
    when public.blisters_por_caja(p_upc, p_ppb) < 2 then 0
    when coalesce(p_precio_blister_guardado, 0) > 0
      then ceil(p_precio_blister_guardado)
    else public.calc_precio_unidad_sugerido(
      p_costo,
      p_precio_caja,
      public.blisters_por_caja(p_upc, p_ppb),
      p_categoria,
      p_tipo
    )
  end;
$$;

grant execute on function public.blisters_por_caja(integer, integer)
  to anon, authenticated, service_role;
grant execute on function public.precio_blister_efectivo(numeric, numeric, integer, integer, text, text, numeric)
  to anon, authenticated, service_role;

-- Caja y blister siguen en peso entero. Si un borrador dejó peso_publico
-- en pasos de $0.50, esto lo regresa. La unidad no lo usa: ver create_sale.
create or replace function public.peso_publico(p numeric)
returns numeric
language sql
immutable
parallel safe
as $$
  select case when p is null then 0 else round(p, 0) end;
$$;

grant execute on function public.peso_publico(numeric)
  to anon, authenticated, service_role;

-- numeric(12,2) alcanza para $1.50. Si la columna es entera, se amplía.
do $$
declare
  v_type text;
  v_scale integer;
begin
  select c.data_type, c.numeric_scale
    into v_type, v_scale
  from information_schema.columns c
  where c.table_schema = 'public'
    and c.table_name = 'productos'
    and c.column_name = 'precio_unidad';

  if v_type in ('smallint', 'integer', 'bigint')
     or (v_type = 'numeric' and v_scale is not null and v_scale < 2) then
    execute $sql$
      alter table public.productos
        alter column precio_unidad type numeric(12,2)
        using round(coalesce(precio_unidad, 0)::numeric, 2)
    $sql$;
  end if;
end $$;

-- Misma regla que src/lib/denominacionPrecio.js (snapPrecioVenta, paso $0.50).
create or replace function public.snap_precio_venta(p numeric)
returns numeric
language sql
immutable
parallel safe
as $$
  select case
    when p is null or p < 0 then null
    else (round(round(p * 100) / 50.0) * 50) / 100
  end;
$$;

grant execute on function public.snap_precio_venta(numeric)
  to anon, authenticated, service_role;

-- El guardado > 0 se ajusta a $0.50. Cero o vacío sigue usando la sugerencia (peso entero).
create or replace function public.precio_unidad_efectivo(
  p_costo numeric,
  p_precio_caja numeric,
  p_upc integer,
  p_categoria text,
  p_tipo text,
  p_precio_unidad_guardado numeric
)
returns numeric
language sql
immutable
as $$
  select case
    when public.snap_precio_venta(coalesce(p_precio_unidad_guardado, 0)) > 0
      then public.snap_precio_venta(coalesce(p_precio_unidad_guardado, 0))
    else public.calc_precio_unidad_sugerido(
      p_costo, p_precio_caja, p_upc, p_categoria, p_tipo
    )
  end;
$$;

grant execute on function public.precio_unidad_efectivo(numeric, numeric, integer, text, text, numeric)
  to anon, authenticated, service_role;

-- Al guardar, $1.50 se queda. No sube el manual a la regla.
create or replace function public.trg_enforce_precio_unidad()
returns trigger
language plpgsql
as $$
begin
  if coalesce(new.venta_unidad, false)
     and coalesce(new.unidades_por_caja, 0) > 0 then
    if coalesce(new.precio_unidad, 0) > 0 then
      new.precio_unidad := public.snap_precio_venta(new.precio_unidad);
    end if;
    if coalesce(new.precio_unidad, 0) <= 0 then
      new.precio_unidad := public.precio_unidad_efectivo(
        new.costo, new.precio, new.unidades_por_caja,
        new.categoria, new.tipo, new.precio_unidad
      );
    end if;
  elsif not coalesce(new.venta_unidad, false) then
    new.precio_unidad := 0;
    new.unidades_por_caja := 0;
  end if;
  return new;
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
      coalesce(p.tipo, '')
    into v_stock_actual, v_stock_unidades_actual, v_stock_blisters_actual,
         v_precio_prod, v_precio_unidad_prod, v_precio_blister_prod, v_upc, v_ppb,
         v_costo_prod, v_categoria_prod, v_tipo_prod
    from public.productos p
    where p.id = v_producto_id
    for update;

    if not found then
      raise exception 'producto % no existe', v_producto_id;
    end if;

    if v_modo_venta = 'blister' and public.blisters_por_caja(v_upc, v_ppb) < 2 then
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
      when 'blister' then public.precio_blister_efectivo(
        v_costo_prod,
        v_precio_prod,
        v_upc,
        v_ppb,
        v_categoria_prod,
        v_tipo_prod,
        v_precio_blister_prod
      )
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
      coalesce(p.tipo, '')
    into v_precio_prod, v_precio_unidad_prod, v_precio_blister_prod, v_upc, v_ppb,
         v_stock_unidades_actual, v_stock_blisters_actual,
         v_costo_prod, v_categoria_prod, v_tipo_prod
    from public.productos p
    where p.id = v_producto_id
    for update;

    v_db_precio := case v_modo_venta
      when 'unidad' then public.precio_unidad_efectivo(
        v_costo_prod,
        v_precio_prod,
        v_upc,
        v_categoria_prod,
        v_tipo_prod,
        v_precio_unidad_prod
      )
      when 'blister' then public.precio_blister_efectivo(
        v_costo_prod,
        v_precio_prod,
        v_upc,
        v_ppb,
        v_categoria_prod,
        v_tipo_prod,
        v_precio_blister_prod
      )
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
        format('Venta %s (unidad) pedido #%s', p_tipo, v_pedido_id),
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
        format('Venta %s (blister) pedido #%s', p_tipo, v_pedido_id),
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
