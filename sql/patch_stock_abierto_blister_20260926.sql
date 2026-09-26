-- Reparte la caja abierta en blisters enteros y el resto cortado.
-- Pegar en Supabase → SQL Editor.
--
-- Amox FC-49021570 hoy: 10 piezas sueltas, 0 blisters, tira de 6.
-- 10 = 1 blister + 4 pastillas. La caja trae 2 blisters (12/6).
-- Cada vez que se vende una pieza o una tira, el stock se vuelve a partir igual.

begin;

create or replace function public.stock_abierto_despues_de_venta(
  p_blisters integer,
  p_unidades integer,
  p_ppb integer,
  p_modo text,
  p_cantidad integer,
  p_producto_id bigint
)
returns table(stock_blisters integer, stock_unidades integer)
language plpgsql
stable
as $$
declare
  v_ppb integer := coalesce(p_ppb, 0);
  v_b integer := greatest(coalesce(p_blisters, 0), 0);
  v_u integer := greatest(coalesce(p_unidades, 0), 0);
  v_pool integer;
  v_toma integer;
begin
  if v_ppb < 2 then
    if p_modo = 'unidad' then
      if v_u < p_cantidad then
        raise exception 'stock_unidades insuficiente para producto % (stock %, solicitado %)',
          p_producto_id, v_u, p_cantidad;
      end if;
      stock_blisters := v_b;
      stock_unidades := v_u - p_cantidad;
      return next;
      return;
    end if;
    raise exception 'producto % no se vende por blister', p_producto_id;
  end if;

  v_pool := v_b * v_ppb + v_u;
  v_toma := case when p_modo = 'blister' then p_cantidad * v_ppb else p_cantidad end;
  if v_pool < v_toma then
    raise exception 'stock abierto insuficiente para producto % (piezas %, solicitado %)',
      p_producto_id, v_pool, v_toma;
  end if;
  v_pool := v_pool - v_toma;
  stock_blisters := v_pool / v_ppb;
  stock_unidades := v_pool % v_ppb;
  return next;
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
        v_precio_blister_prod,
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

    if v_modo_venta in ('unidad', 'blister') then
      perform 1 from public.stock_abierto_despues_de_venta(
        v_stock_blisters_actual,
        v_stock_unidades_actual,
        case when public.blisters_por_caja(v_upc, v_ppb) >= 2 then v_ppb else 0 end,
        v_modo_venta,
        v_cantidad,
        v_producto_id
      );
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
        v_precio_blister_prod,
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

    if v_modo_venta = 'unidad' or v_modo_venta = 'blister' then
      select f.stock_blisters, f.stock_unidades
        into v_stock_blisters_nuevo, v_stock_unidades_nuevo
      from public.stock_abierto_despues_de_venta(
        v_stock_blisters_actual,
        v_stock_unidades_actual,
        case when public.blisters_por_caja(v_upc, v_ppb) >= 2 then v_ppb else 0 end,
        v_modo_venta,
        v_cantidad,
        v_producto_id
      ) f;

      update public.productos
      set
        stock_blisters = v_stock_blisters_nuevo,
        stock_unidades = v_stock_unidades_nuevo
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
        format('Venta %s (%s) pedido #%s', p_tipo, v_modo_venta, v_pedido_id),
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



grant execute on function public.stock_abierto_despues_de_venta(integer, integer, integer, text, integer, bigint)
  to anon, authenticated, service_role;

update public.productos p
   set stock_blisters = q.blisters,
       stock_unidades = q.piezas
  from (
    select id,
           (coalesce(stock_blisters, 0) * piezas_por_blister + coalesce(stock_unidades, 0)) / piezas_por_blister as blisters,
           (coalesce(stock_blisters, 0) * piezas_por_blister + coalesce(stock_unidades, 0)) % piezas_por_blister as piezas
      from public.productos
     where public.blisters_por_caja(unidades_por_caja, piezas_por_blister) >= 2
       and coalesce(stock_unidades, 0) >= piezas_por_blister
  ) q
 where p.id = q.id
   and (p.stock_blisters is distinct from q.blisters or p.stock_unidades is distinct from q.piezas);

notify pgrst, 'reload schema';

commit;

select sku, left(nombre, 42) as nombre,
       unidades_por_caja as upc,
       piezas_por_blister as por_tira,
       public.blisters_por_caja(unidades_por_caja, piezas_por_blister) as blisters_por_caja,
       stock_blisters, stock_unidades
  from public.productos
 where sku = 'FC-49021570';
