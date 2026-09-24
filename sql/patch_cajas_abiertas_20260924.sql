-- Cajas abiertas: la pieza suelta sale con el costo de la caja que se abrió.
-- 24 sep 2026. Idempotente. Pegar después de patch_pedido_item_consumos_20260924.sql.
-- Reemplaza abrir_caja_lote, la rama de pieza de create_sale_transaction_v2
-- y el reintegro de una pieza al borrar o devolver el pedido.

begin;

create table if not exists public.cajas_abiertas (
  id                 bigserial primary key,
  producto_id        bigint not null references public.productos(id),
  lote_id            bigint references public.lotes(id),
  unidades_por_caja  integer not null check (unidades_por_caja > 0),
  unidades_restantes integer not null check (unidades_restantes >= 0),
  costo_caja         numeric(12, 4),
  costo_origen       text not null default 'lote',
  abierta_at         timestamptz not null default now(),
  abierta_por        bigint,
  cerrada_at         timestamptz
);

create index if not exists idx_cajas_abiertas_producto
  on public.cajas_abiertas (producto_id)
  where cerrada_at is null and unidades_restantes > 0;

alter table public.cajas_abiertas enable row level security;
revoke all on public.cajas_abiertas from public, anon, authenticated;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'pedido_item_consumos_caja_abierta_id_fkey'
  ) then
    alter table public.pedido_item_consumos
      add constraint pedido_item_consumos_caja_abierta_id_fkey
      foreign key (caja_abierta_id) references public.cajas_abiertas(id) on delete set null;
  end if;
end $$;

-- Lo que ya está suelto en anaquel, sin saber de qué lote salió.
insert into public.cajas_abiertas (
  producto_id, lote_id, unidades_por_caja, unidades_restantes,
  costo_caja, costo_origen, abierta_at
)
select
  p.id,
  null,
  greatest(coalesce(p.unidades_por_caja, 1), 1),
  p.stock_unidades,
  nullif(p.costo, 0),
  case when coalesce(p.costo, 0) > 0 then 'catalogo_actual' else 'sin_costo' end,
  now()
from public.productos p
where coalesce(p.stock_unidades, 0) > 0
  and not exists (
    select 1 from public.cajas_abiertas c
    where c.producto_id = p.id and c.cerrada_at is null and c.unidades_restantes > 0
  );

create or replace function public.fn_sync_stock_unidades(p_producto_id bigint)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_sum integer;
begin
  select coalesce(sum(unidades_restantes), 0)::integer
    into v_sum
  from public.cajas_abiertas
  where producto_id = p_producto_id
    and cerrada_at is null;
  update public.productos set stock_unidades = v_sum where id = p_producto_id;
  return v_sum;
end;
$$;

create or replace function public.fn_vender_unidades(
  p_pedido_id bigint,
  p_producto_id bigint,
  p_cantidad integer,
  p_precio numeric,
  p_user_id bigint,
  p_tipo text
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_restante integer;
  v_caja public.cajas_abiertas%rowtype;
  v_tomar integer;
  v_item_id bigint;
  v_costo_pieza numeric;
  v_upc integer;
begin
  if p_cantidad is null or p_cantidad <= 0 then
    raise exception 'cantidad invalida';
  end if;
  v_restante := p_cantidad;

  perform 1 from public.productos where id = p_producto_id for update;

  while v_restante > 0 loop
    select * into v_caja
    from public.cajas_abiertas
    where producto_id = p_producto_id
      and cerrada_at is null
      and unidades_restantes > 0
    order by abierta_at asc, id asc
    limit 1
    for update;

    if not found then
      raise exception 'piezas sueltas insuficientes para producto % (faltan %)',
        p_producto_id, v_restante;
    end if;

    v_tomar := least(v_restante, v_caja.unidades_restantes);
    v_upc := greatest(v_caja.unidades_por_caja, 1);
    v_costo_pieza := case
      when coalesce(v_caja.costo_caja, 0) > 0 then round(v_caja.costo_caja / v_upc, 4)
      else null
    end;

    update public.cajas_abiertas
    set unidades_restantes = unidades_restantes - v_tomar,
        cerrada_at = case when unidades_restantes - v_tomar <= 0 then now() else cerrada_at end
    where id = v_caja.id;

    perform set_config('app.fc_consumo_manual', '1', true);
    insert into public.pedido_items (pedido_id, producto_id, cantidad, precio_unitario, lote_id)
    values (p_pedido_id, p_producto_id, v_tomar, p_precio, null)
    returning id into v_item_id;
    perform set_config('app.fc_consumo_manual', '', true);

    insert into public.pedido_item_consumos (
      pedido_item_id, lote_id, caja_abierta_id, modo, cantidad, costo_unitario, costo_origen
    ) values (
      v_item_id,
      v_caja.lote_id,
      v_caja.id,
      'unidad',
      v_tomar,
      v_costo_pieza,
      case
        when v_costo_pieza is null then 'sin_costo'
        when v_caja.costo_origen = 'catalogo_actual' then 'catalogo_actual'
        when v_caja.costo_origen = 'sin_costo' then 'sin_costo'
        else 'caja_abierta'
      end
    );

    v_restante := v_restante - v_tomar;
  end loop;

  perform public.fn_sync_stock_unidades(p_producto_id);

  insert into public.movimientos_inventario (
    producto_id, tipo, cantidad, motivo, usuario_id, referencia
  ) values (
    p_producto_id, 'salida', p_cantidad,
    format('Venta %s (unidad) pedido #%s', p_tipo, p_pedido_id),
    p_user_id, p_pedido_id::text
  );
end;
$$;

create or replace function public.fn_reintegrar_piezas_item(
  p_item_id bigint,
  p_motivo text
)
returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_c record;
  v_producto bigint;
begin
  if not exists (
    select 1 from public.pedido_item_consumos
    where pedido_item_id = p_item_id and modo = 'unidad'
  ) then
    return false;
  end if;

  select producto_id into v_producto from public.pedido_items where id = p_item_id;

  for v_c in
    select caja_abierta_id, cantidad, costo_unitario, costo_origen
    from public.pedido_item_consumos
    where pedido_item_id = p_item_id and modo = 'unidad'
  loop
    if v_c.caja_abierta_id is not null then
      update public.cajas_abiertas
      set unidades_restantes = least(
            unidades_por_caja,
            unidades_restantes + v_c.cantidad::integer
          ),
          cerrada_at = null
      where id = v_c.caja_abierta_id;
    else
      insert into public.cajas_abiertas (
        producto_id, unidades_por_caja, unidades_restantes, costo_caja, costo_origen
      )
      select
        v_producto,
        greatest(coalesce(p.unidades_por_caja, 1), 1),
        least(greatest(coalesce(p.unidades_por_caja, 1), 1), v_c.cantidad::integer),
        case when v_c.costo_unitario is null then null
             else round(v_c.costo_unitario * greatest(coalesce(p.unidades_por_caja, 1), 1), 4)
        end,
        'catalogo_actual'
      from public.productos p
      where p.id = v_producto;
    end if;
  end loop;

  if v_producto is not null then
    perform public.fn_sync_stock_unidades(v_producto);
  end if;
  return true;
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
      perform public.fn_vender_unidades(
        v_pedido_id, v_producto_id, v_cantidad, v_db_precio, p_user_id, p_tipo
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
  v_producto_stock integer;
  v_lote_id bigint;
  v_lote_cantidad integer;
  v_costo numeric;
begin
  if p_producto_id is null then raise exception 'producto_id requerido'; end if;
  if p_user_id is null then raise exception 'user_id requerido'; end if;

  select greatest(coalesce(p.unidades_por_caja, 1), 1), coalesce(p.stock, 0)
    into v_upc, v_producto_stock
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

  select costo_unitario into v_costo from public.lotes where id = v_lote_id;

  update public.lotes
  set cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - 1),
      activo = case
        when greatest(0, coalesce(cantidad_actual, 0) - 1) <= 0 then false
        else activo
      end
  where id = v_lote_id;

  insert into public.cajas_abiertas (
    producto_id, lote_id, unidades_por_caja, unidades_restantes,
    costo_caja, costo_origen, abierta_por
  ) values (
    p_producto_id, v_lote_id, v_upc, v_upc,
    v_costo,
    case when coalesce(v_costo, 0) > 0 then 'lote' else 'sin_costo' end,
    p_user_id
  );

  perform public.fn_sync_stock_unidades(p_producto_id);

  insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo, usuario_id)
  values (p_producto_id, 'ajuste', 1, format('Abrir caja (+%s unidades sueltas)', v_upc), p_user_id);

  return query
  select p.stock, p.stock_unidades from public.productos p where p.id = p_producto_id;
end;
$$;


create or replace function public.fn_pedido_online_liberar_stock(
  p_pedido_id bigint,
  p_actor_id bigint,
  p_motivo text default null
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_item record;
  v_n    int := 0;
  v_motivo text;
begin
  if not public.fn_pedido_online_debe_restock(p_pedido_id) then
    return 0;
  end if;

  v_motivo := coalesce(
    p_motivo,
    'Reintegro pedido #' || p_pedido_id
  );

  for v_item in
    select id, producto_id, cantidad, lote_id
    from public.pedido_items
    where pedido_id = p_pedido_id
  loop
    if v_item.producto_id is null or coalesce(v_item.cantidad, 0) <= 0 then
      continue;
    end if;
    if exists (
      select 1 from public.productos p
      where p.id = v_item.producto_id and coalesce(p.bajo_pedido, false)
    ) then
      continue;
    end if;
    begin
      if exists (
        select 1 from public.pedido_item_consumos c
        where c.pedido_item_id = v_item.id and c.modo = 'unidad'
      ) then
        perform public.fn_reintegrar_piezas_item(v_item.id, v_motivo);
      else
      perform public.restock_via_lote(
        v_item.producto_id,
        v_item.cantidad::integer,
        v_motivo,
        p_actor_id,
        v_item.lote_id
      );
      end if;
      v_n := v_n + 1;
    exception when others then
      raise notice 'restock falló pedido % producto %: %',
        p_pedido_id, v_item.producto_id, SQLERRM;
    end;
  end loop;

  update public.pedidos
     set stock_consumido_at = null
   where id = p_pedido_id
     and stock_consumido_at is not null;

  return v_n;
end;
$$;


commit;
