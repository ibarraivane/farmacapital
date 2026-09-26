-- Venta por pieza: si faltan sueltas pero hay cajas cerradas, se abre la caja.
-- Caso 2026-09-26: Amoxicilina 500 mg (producto 1181) con 3 cajas y 0 sueltas.
-- El POS cobraba 2 piezas y la base respondía
-- "piezas sueltas insuficientes para producto 1181 (faltan 2)".
-- Pegar en Supabase → SQL Editor. Idempotente.
-- La regla de “se puede abrir” es la misma que puedeAbrirCajaParaPiezas
-- en src/utils/productoCajaFalsa.js.

begin;

create or replace function public.fn_puede_abrir_caja_para_piezas(p_producto_id bigint)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_venta boolean;
  v_upc integer;
  v_precio numeric;
  v_uni numeric;
  v_texto text;
  v_pres text;
  v_ratio numeric;
  v_pieza boolean;
begin
  select
    coalesce(p.venta_unidad, false),
    greatest(coalesce(p.unidades_por_caja, 1), 1),
    coalesce(p.precio, 0),
    coalesce(p.precio_unidad, 0),
    lower(concat_ws(' ', coalesce(p.nombre, ''), coalesce(p.presentacion, ''), coalesce(p.forma_farmaceutica, ''))),
    coalesce(p.presentacion, '')
  into v_venta, v_upc, v_precio, v_uni, v_texto, v_pres
  from public.productos p
  where p.id = p_producto_id;

  if not found or not v_venta or v_upc < 2 then
    return false;
  end if;

  if v_texto ~ '\m(oxido|óxido|mercurio|frasco|pote|tarro)\M' then
    return false;
  end if;

  if v_uni > 0 and v_precio > 0 then
    v_ratio := v_precio / v_uni;
    v_pieza := v_pres ~* '^pieza\M'
      or v_texto ~ '\m(c/[[:space:]]*1|1[[:space:]]+pza|1[[:space:]]+pieza|1[[:space:]]+unidad)\M';
    if v_upc <= 4 and v_ratio >= 2 then
      return true;
    end if;
    if v_pieza and v_ratio <= 1.6 then
      return false;
    end if;
    if v_ratio <= 1.5 and v_upc >= 6 then
      return false;
    end if;
    if v_ratio < 1.8 then
      return false;
    end if;
  end if;

  return true;
end;
$$;

create or replace function public.fn_piezas_sueltas_disponibles(p_producto_id bigint)
returns integer
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_sueltas integer;
  v_upc integer;
  v_cajas integer;
begin
  select
    coalesce(p.stock_unidades, 0),
    greatest(coalesce(p.unidades_por_caja, 1), 1)
  into v_sueltas, v_upc
  from public.productos p
  where p.id = p_producto_id;

  if not found then
    return 0;
  end if;

  if not public.fn_puede_abrir_caja_para_piezas(p_producto_id) then
    return v_sueltas;
  end if;

  select coalesce(sum(l.cantidad_actual), 0)::integer
    into v_cajas
  from public.lotes l
  where l.producto_id = p_producto_id
    and coalesce(l.activo, true) = true
    and coalesce(l.cantidad_actual, 0) > 0
    and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date);

  return v_sueltas + (greatest(v_cajas, 0) * v_upc);
end;
$$;

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
begin
  if p_producto_id is null then
    raise exception 'producto_id requerido';
  end if;
  if p_cantidad is null or p_cantidad <= 0 then
    raise exception 'cantidad invalida para producto %', p_producto_id;
  end if;

  select
    coalesce(p.stock_unidades, 0),
    greatest(coalesce(p.unidades_por_caja, 1), 1)
  into v_sueltas, v_upc
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

    update public.productos
    set stock_unidades = v_sueltas
    where id = p_producto_id;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo, usuario_id
    ) values (
      p_producto_id, 'ajuste', 1,
      format('Abrir caja para venta por pieza (+%s)', v_upc),
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

grant execute on function public.fn_puede_abrir_caja_para_piezas(bigint) to anon, authenticated, service_role;
grant execute on function public.fn_piezas_sueltas_disponibles(bigint) to anon, authenticated, service_role;
grant execute on function public.fn_abrir_cajas_para_piezas(bigint, integer, bigint) to anon, authenticated, service_role;

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
      v_piezas_ya := coalesce((v_piezas_comprometidas ->> v_producto_id::text)::integer, 0);
      v_piezas_disp := public.fn_piezas_sueltas_disponibles(v_producto_id);
      if coalesce(v_piezas_disp, 0) < v_piezas_ya + v_cantidad then
        raise exception 'piezas sueltas insuficientes para producto % (faltan %)',
          v_producto_id, (v_piezas_ya + v_cantidad) - coalesce(v_piezas_disp, 0);
      end if;
      v_piezas_comprometidas := v_piezas_comprometidas
        || jsonb_build_object(v_producto_id::text, v_piezas_ya + v_cantidad);
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
      select a.stock_unidades, a.lote_id
        into v_stock_unidades_actual, v_lote_pieza
      from public.fn_abrir_cajas_para_piezas(v_producto_id, v_cantidad, p_user_id) a;

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
