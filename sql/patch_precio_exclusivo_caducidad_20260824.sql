-- Precio especial de caducidad en caja POS: no se apila con promo ni descuento_pct.
-- Correr DESPUÉS de sql/patch_descuento_caducidad_20260824.sql
-- create_sale acepta el total FEFO si el POS lo manda; si no, cobra el PVP como hoy.

begin;

create or replace function public.precio_especial_lote_vigente(
  p_lote_id bigint,
  p_hoy date default (timezone('America/Mexico_City', now()))::date
)
returns numeric
language sql
stable
security definer
set search_path = public
as $$
  select p.precio_propuesto
  from public.propuestas_descuento_caducidad p
  where to_regclass('public.propuestas_descuento_caducidad') is not null
    and p.lote_id = p_lote_id
    and p.estado = 'APROBADA'
    and coalesce(p.precio_propuesto, 0) > 0
    and (p.vigencia_desde is null or p.vigencia_desde <= p_hoy)
    and (p.vigencia_hasta is null or p.vigencia_hasta >= p_hoy)
  order by p.id desc
  limit 1;
$$;

create or replace function public.importe_cajas_fefo(
  p_producto_id bigint,
  p_cantidad integer,
  p_hoy date default (timezone('America/Mexico_City', now()))::date
)
returns numeric
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_restante integer := coalesce(p_cantidad, 0);
  v_total numeric := 0;
  v_pvp numeric := 0;
  v_desc numeric := 0;
  v_catalog numeric;
  v_especial numeric;
  v_unit numeric;
  v_take integer;
  v_lote record;
begin
  if v_restante <= 0 then
    return 0;
  end if;

  select coalesce(p.precio, 0), coalesce(p.descuento_pct, 0)
    into v_pvp, v_desc
  from public.productos p
  where p.id = p_producto_id;

  if not found then
    return 0;
  end if;

  v_catalog := public.peso_publico(v_pvp * (1 - coalesce(v_desc, 0) / 100.0));

  if to_regclass('public.propuestas_descuento_caducidad') is null then
    return v_catalog * v_restante;
  end if;

  for v_lote in
    select l.id, coalesce(l.cantidad_actual, 0)::integer as qty
    from public.lotes l
    where l.producto_id = p_producto_id
      and coalesce(l.activo, true) = true
      and coalesce(l.cantidad_actual, 0) > 0
      and (l.fecha_caducidad is null or l.fecha_caducidad >= p_hoy)
    order by l.fecha_caducidad asc nulls first, l.id asc
  loop
    exit when v_restante <= 0;
    v_take := least(v_restante, v_lote.qty);
    if v_take <= 0 then
      continue;
    end if;
    v_especial := public.precio_especial_lote_vigente(v_lote.id, p_hoy);
    if v_especial is not null then
      v_unit := public.peso_publico(v_especial);
    else
      v_unit := v_catalog;
    end if;
    v_total := v_total + (v_unit * v_take);
    v_restante := v_restante - v_take;
  end loop;

  if v_restante > 0 then
    v_total := v_total + (v_catalog * v_restante);
  end if;

  return v_total;
end;
$$;

create or replace function public.precio_caja_cobro_pos(
  p_producto_id bigint,
  p_cantidad integer,
  p_precio_cliente numeric
)
returns numeric
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_pvp numeric := 0;
  v_catalog numeric;
  v_importe numeric;
begin
  if p_cantidad is null or p_cantidad <= 0 then
    return 0;
  end if;

  select coalesce(p.precio, 0) into v_pvp
  from public.productos p
  where p.id = p_producto_id;

  v_catalog := public.peso_publico(v_pvp);
  v_importe := public.importe_cajas_fefo(p_producto_id, p_cantidad);

  if p_precio_cliente is not null
     and round(p_precio_cliente * p_cantidad, 2) = round(v_importe, 2) then
    return v_importe / p_cantidad;
  end if;

  return v_catalog;
end;
$$;

create or replace function public.empleado_precios_especiales_caducidad_vigentes(
  p_session_token uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_hoy date := (timezone('America/Mexico_City', now()))::date;
begin
  v_dummy := public.fn_require_empleado(p_session_token);

  if to_regclass('public.propuestas_descuento_caducidad') is null then
    return '[]'::jsonb;
  end if;

  return coalesce((
    select jsonb_agg(row_js order by lote_id)
    from (
      select distinct on (p.lote_id)
        jsonb_build_object(
          'lote_id', p.lote_id,
          'producto_id', p.producto_id,
          'precio_propuesto', p.precio_propuesto,
          'vigencia_desde', p.vigencia_desde,
          'vigencia_hasta', p.vigencia_hasta,
          'estado', p.estado,
          'texto_etiqueta', p.texto_etiqueta
        ) as row_js,
        p.lote_id
      from public.propuestas_descuento_caducidad p
      where p.estado = 'APROBADA'
        and coalesce(p.precio_propuesto, 0) > 0
        and (p.vigencia_desde is null or p.vigencia_desde <= v_hoy)
        and (p.vigencia_hasta is null or p.vigencia_hasta >= v_hoy)
      order by p.lote_id, p.id desc
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.precio_especial_lote_vigente(bigint, date) to anon, authenticated, service_role;
grant execute on function public.importe_cajas_fefo(bigint, integer, date) to anon, authenticated, service_role;
grant execute on function public.precio_caja_cobro_pos(bigint, integer, numeric) to anon, authenticated, service_role;
grant execute on function public.empleado_precios_especiales_caducidad_vigentes(uuid) to anon, authenticated;

-- create_sale: caja POS usa precio_caja_cobro_pos (especial si el ticket cuadra).
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
  v_lote_disponible integer;
  v_lote_tomar integer;
  v_precio_prod numeric;
  v_precio_unidad_prod numeric;
  v_upc integer;
  v_costo_prod numeric;
  v_categoria_prod text;
  v_tipo_prod text;
  v_notas text;
  v_tipo_guardado text;
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
      greatest(coalesce(p.unidades_por_caja, 1), 1),
      coalesce(p.costo, 0),
      coalesce(p.categoria, ''),
      coalesce(p.tipo, '')
    into v_stock_actual, v_stock_unidades_actual,
         v_precio_prod, v_precio_unidad_prod, v_upc,
         v_costo_prod, v_categoria_prod, v_tipo_prod
    from public.productos p
    where p.id = v_producto_id
    for update;

    if not found then
      raise exception 'producto % no existe', v_producto_id;
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
      else coalesce(v_precio_prod, 0)
    end;
    if p_tipo = 'pos' then
      v_db_precio := public.peso_publico(v_db_precio);
    end if;
    if v_modo_venta = 'caja' and p_tipo = 'pos' then
      v_db_precio := public.precio_caja_cobro_pos(
        v_producto_id, v_cantidad, v_precio_unitario
      );
    end if;

    if v_modo_venta = 'unidad' then
      if coalesce(v_stock_unidades_actual, 0) < v_cantidad then
        raise exception 'stock_unidades insuficiente para producto % (stock %, solicitado %)',
          v_producto_id, coalesce(v_stock_unidades_actual, 0), v_cantidad;
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
      greatest(coalesce(p.unidades_por_caja, 1), 1),
      coalesce(p.stock_unidades, 0),
      coalesce(p.costo, 0),
      coalesce(p.categoria, ''),
      coalesce(p.tipo, '')
    into v_precio_prod, v_precio_unidad_prod, v_upc, v_stock_unidades_actual,
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
      else coalesce(v_precio_prod, 0)
    end;
    if p_tipo = 'pos' then
      v_db_precio := public.peso_publico(v_db_precio);
    end if;
    if v_modo_venta = 'caja' and p_tipo = 'pos' then
      v_db_precio := public.precio_caja_cobro_pos(
        v_producto_id, v_cantidad, v_precio_unitario
      );
    end if;

    if v_modo_venta = 'unidad' then
      v_stock_unidades_nuevo := v_stock_unidades_actual - v_cantidad;

      update public.productos
      set stock_unidades = v_stock_unidades_nuevo
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
        format('Venta %s (unidad) pedido #%s', p_tipo, v_pedido_id),
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
