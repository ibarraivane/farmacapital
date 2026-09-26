-- Venta por blister dentro de la venta por pieza.
-- Pegar en Supabase → SQL Editor ANTES del deploy del POS.
-- Si el cliente sale primero, el fallback del catálogo pide columnas que aún no existen.
--
-- Sin piezas_por_blister (0), abrir caja sigue soltando piezas. No mueve stock existente.
-- Con blister bien partido (30/10 = 3, al menos 2 tiras de 2 piezas):
--   abrir caja  → stock_blisters
--   abrir blister → stock_unidades
--   modo_venta 'blister' cobra precio_blister y resta stock_blisters.

begin;

alter table public.productos
  add column if not exists piezas_por_blister integer not null default 0,
  add column if not exists precio_blister numeric not null default 0,
  add column if not exists stock_blisters integer not null default 0;

comment on column public.productos.piezas_por_blister is
  'Piezas de una tira. 0 = no hay venta por blister; abrir caja suelta piezas.';
comment on column public.productos.precio_blister is
  'Precio de mostrador por blister. 0 = usa la misma regla que la pieza, con divisor = blisters por caja.';
comment on column public.productos.stock_blisters is
  'Blisters sueltos (caja ya abierta, tira aún cerrada).';

-- ── Cuántas tiras salen de una caja ─────────────────────────────────────────
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

-- Precio efectivo: el guardado si es > 0; si no, la regla de pieza con divisor = tiras.
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

-- ── Abrir caja: blisters si está configurado; si no, piezas ─────────────────
drop function if exists public.abrir_caja_secure(uuid, bigint);
drop function if exists public.abrir_caja_lote(bigint, bigint);

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
begin
  if p_producto_id is null then raise exception 'producto_id requerido'; end if;
  if p_user_id is null then raise exception 'user_id requerido'; end if;

  select
    greatest(coalesce(p.unidades_por_caja, 1), 1),
    coalesce(p.piezas_por_blister, 0),
    coalesce(p.stock_unidades, 0),
    coalesce(p.stock_blisters, 0),
    coalesce(p.stock, 0)
  into v_upc, v_ppb, v_stock_unidades_actual, v_stock_blisters_actual, v_producto_stock
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

  v_blisters := public.blisters_por_caja(v_upc, v_ppb);

  if v_blisters >= 2 then
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

create or replace function public.abrir_caja_secure(
  p_session_token uuid,
  p_producto_id   bigint
)
returns table(stock_nuevo integer, stock_unidades_nuevo integer, stock_blisters_nuevo integer)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  return query
  select * from public.abrir_caja_lote(p_producto_id, v_user_id);
end;
$$;

revoke execute on function public.abrir_caja_secure(uuid, bigint) from public;
grant execute on function public.abrir_caja_secure(uuid, bigint)
  to anon, authenticated, service_role;

-- ── Abrir blister: 1 tira → N piezas. No toca lotes. ────────────────────────
create or replace function public.abrir_blister_lote(
  p_producto_id bigint,
  p_user_id bigint
)
returns table(stock_blisters_nuevo integer, stock_unidades_nuevo integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_ppb integer;
  v_upc integer;
  v_blisters integer;
  v_stock_blisters_actual integer;
  v_stock_unidades_actual integer;
begin
  if p_producto_id is null then raise exception 'producto_id requerido'; end if;
  if p_user_id is null then raise exception 'user_id requerido'; end if;

  select
    coalesce(p.piezas_por_blister, 0),
    greatest(coalesce(p.unidades_por_caja, 1), 1),
    coalesce(p.stock_blisters, 0),
    coalesce(p.stock_unidades, 0)
  into v_ppb, v_upc, v_stock_blisters_actual, v_stock_unidades_actual
  from public.productos p
  where p.id = p_producto_id
  for update;

  if not found then
    raise exception 'producto % no existe', p_producto_id;
  end if;

  v_blisters := public.blisters_por_caja(v_upc, v_ppb);
  if v_blisters < 2 then
    raise exception 'producto % no se vende por blister', p_producto_id;
  end if;

  if v_stock_blisters_actual < 1 then
    raise exception 'producto % no tiene blisters sueltos', p_producto_id;
  end if;

  update public.productos
  set
    stock_blisters = v_stock_blisters_actual - 1,
    stock_unidades = v_stock_unidades_actual + v_ppb
  where id = p_producto_id;

  insert into public.movimientos_inventario (
    producto_id, tipo, cantidad, motivo, usuario_id
  ) values (
    p_producto_id, 'ajuste', 1,
    format('Abrir blister (+%s piezas)', v_ppb),
    p_user_id
  );

  return query
  select p.stock_blisters, p.stock_unidades
  from public.productos p
  where p.id = p_producto_id;
end;
$$;

revoke execute on function public.abrir_blister_lote(bigint, bigint)
  from public, anon, authenticated;

create or replace function public.abrir_blister_secure(
  p_session_token uuid,
  p_producto_id   bigint
)
returns table(stock_blisters_nuevo integer, stock_unidades_nuevo integer)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  return query
  select * from public.abrir_blister_lote(p_producto_id, v_user_id);
end;
$$;

revoke execute on function public.abrir_blister_secure(uuid, bigint) from public;
grant execute on function public.abrir_blister_secure(uuid, bigint)
  to anon, authenticated, service_role;

-- ── Cobro: modo_venta blister ───────────────────────────────────────────────
-- Cuerpo vigente: patch_precio_exclusivo_caducidad_20260824 (precio especial FEFO).
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
        v_precio_blister_prod
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

-- ── Inventario puede guardar las tres columnas ──────────────────────────────
-- Cuerpo vigente: patch_admin_guardar_proveedor_producto.sql
create or replace function public.admin_editar_producto(
  p_session_token uuid,
  p_producto_id   bigint,
  p_patch         jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_allowed  text[] := array[
    'nombre','sku','codigo_barras','categoria','subcategoria',
    'marca','tipo','descripcion','precio','costo','stock_minimo',
    'descuento_pct','imagen_url','imagen_mobile_url',
    'presentacion','principio_activo','denominacion_generica',
    'denominacion_distintiva','concentracion','forma_farmaceutica',
    'ubicacion_texto','laboratorio',
    'requiere_receta','notas','activo',
    'controlado','grupo_controlado','visible_tienda',
    'venta_unidad','unidades_por_caja','precio_unidad','stock_unidades',
    'piezas_por_blister','precio_blister','stock_blisters',
    'precio_similares','precio_del_ahorro','fecha_actualizacion_precios',
    'manual_price_override'
  ];
  v_cols      text[];
  v_key       text;
  v_set_parts text[] := array[]::text[];
  v_sql       text;
  v_count     int;
  v_row       public.productos%rowtype;
  v_toca_precio boolean := false;
  v_did_proveedor boolean := false;
  v_prov jsonb;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if p_patch ? 'proveedor' then
    v_prov := public.admin_guardar_proveedor_producto(
      p_session_token,
      p_producto_id,
      p_patch->>'proveedor'
    );
    v_did_proveedor := true;
  end if;

  select array_agg(column_name::text) into v_cols
  from information_schema.columns
  where table_schema = 'public' and table_name = 'productos';

  for v_key in select jsonb_object_keys(p_patch)
  loop
    if v_key = any(v_allowed) and v_key = any(v_cols) then
      if v_key in ('precio', 'costo', 'precio_unidad') then
        v_toca_precio := true;
      end if;
      v_set_parts := array_append(
        v_set_parts,
        format('%I = ($1 ->> %L)::text::%s',
               v_key, v_key,
               case v_key
                 when 'precio' then 'numeric'
                 when 'costo'  then 'numeric'
                 when 'descuento_pct' then 'numeric'
                 when 'precio_unidad' then 'numeric'
                 when 'precio_blister' then 'numeric'
                 when 'precio_similares' then 'numeric'
                 when 'precio_del_ahorro' then 'numeric'
                 when 'fecha_actualizacion_precios' then 'date'
                 when 'stock_minimo' then 'integer'
                 when 'unidades_por_caja' then 'integer'
                 when 'stock_unidades' then 'integer'
                 when 'piezas_por_blister' then 'integer'
                 when 'stock_blisters' then 'integer'
                 when 'activo' then 'boolean'
                 when 'requiere_receta' then 'boolean'
                 when 'controlado' then 'boolean'
                 when 'visible_tienda' then 'boolean'
                 when 'venta_unidad' then 'boolean'
                 when 'manual_price_override' then 'boolean'
                 else 'text'
               end
              )
      );
    end if;
  end loop;

  if v_toca_precio and 'manual_price_override' = any(v_cols)
     and not exists (
       select 1 from unnest(v_set_parts) s
       where s like 'manual_price_override =%'
     ) then
    v_set_parts := array_append(v_set_parts, 'manual_price_override = true');
  end if;

  if array_length(v_set_parts, 1) is null then
    if v_did_proveedor then
      return jsonb_build_object(
        'success', true,
        'proveedor', v_prov
      );
    end if;
    raise exception 'No hay campos permitidos para actualizar';
  end if;

  v_sql := format(
    'update public.productos set %s where id = $2 returning *',
    array_to_string(v_set_parts, ', ')
  );

  execute v_sql using p_patch, p_producto_id into v_row;
  get diagnostics v_count = row_count;
  if v_count = 0 then
    raise exception 'Producto % no encontrado', p_producto_id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'editar_producto', 'productos', p_producto_id::text, p_patch
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'producto', jsonb_build_object(
      'id', v_row.id,
      'precio', v_row.precio,
      'costo', v_row.costo,
      'precio_unidad', v_row.precio_unidad,
      'precio_blister', v_row.precio_blister,
      'manual_price_override', v_row.manual_price_override
    ),
    'proveedor', v_prov
  );
end;
$$;

grant execute on function public.admin_editar_producto(uuid, bigint, jsonb)
  to anon, authenticated;

-- ── Margen del dashboard: el blister no es una caja ni una pieza ────────────
-- Cuerpo vigente: patch_online_pickup_meta_vendedora_20260916.sql
create or replace function public.empleado_dashboard_reporte_bundle(
  p_session_token uuid,
  p_desde timestamptz,
  p_desde_fecha date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  return jsonb_build_object(
    'peds', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'total', p.total,
          'created_at', p.created_at,
          'tipo', p.tipo,
          'atendido_por', p.atendido_por,
          'usuarios', jsonb_build_object('nombre', u.nombre)
        )
        order by p.created_at desc
      )
      from public.pedidos p
      left join public.usuarios u on u.id = p.atendido_por
      where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por)
        and p.created_at >= p_desde
    ), '[]'::jsonb),
    'cons', coalesce((
      select jsonb_agg(jsonb_build_object('id', c.id))
      from public.citas c
      where c.fecha >= p_desde_fecha
        and coalesce(c.estado,'') <> 'cancelada'
        and ((c.estado)::text = any(array['completada','pagada']) or coalesce(c.pago_estado,'')='pagada')
    ), '[]'::jsonb),
    'ponl', coalesce((
      select jsonb_agg(jsonb_build_object('total', p.total))
      from public.pedidos p
      where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por)
        and (p.tipo)::text = 'online'
        and p.created_at >= p_desde
    ), '[]'::jsonb),
    'devs', coalesce((select jsonb_agg(jsonb_build_object('total_devuelto', d.total_devuelto)) from public.devoluciones d where (d.estado)::text='aprobada' and d.created_at >= p_desde), '[]'::jsonb),
    'peds_cat', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'total', p.total,
          'productos', coalesce(pi.js, '[]'::jsonb)
        )
        order by p.created_at desc
      )
      from public.pedidos p
      left join lateral (
        select jsonb_agg(
          jsonb_build_object(
            'precio_unitario', x.precio_unitario,
            'cantidad', x.cantidad,
            'productos', jsonb_build_object(
              'categoria', pr.categoria,
              'costo', pr.costo,
              'precio', pr.precio,
              'precio_unidad', pr.precio_unidad,
              'precio_blister', pr.precio_blister,
              'venta_unidad', pr.venta_unidad,
              'unidades_por_caja', pr.unidades_por_caja,
              'piezas_por_blister', pr.piezas_por_blister
            )
          )
          order by x.id
        ) as js
        from public.pedido_items x
        join public.productos pr on pr.id = x.producto_id
        where x.pedido_id = p.id
      ) pi on true
      where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por)
        and p.created_at >= p_desde
    ), '[]'::jsonb),
    'peds_receta_farmax', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where public.fn_pedido_cuenta_en_ventas(p.estado, p.tipo, p.atendido_por) and (p.receta_origen)::text='medico_farmax' and p.created_at >= p_desde), '[]'::jsonb),
    'citas_receta_ext_period_count', (
      select count(*)::int from public.citas c
      where c.fecha >= p_desde_fecha
        and coalesce(c.receta_surtido_en,'') = 'externa'
        and coalesce(c.estado,'') <> 'cancelada'
        and ((c.estado)::text = any(array['completada','pagada']) or coalesce(c.pago_estado,'')='pagada')
    )
  );
end;
$$;

grant execute on function public.empleado_dashboard_reporte_bundle(uuid, timestamptz, date)
  to anon, authenticated;

notify pgrst, 'reload schema';

commit;
