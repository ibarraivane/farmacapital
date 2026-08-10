-- ============================================================
-- Fix: create_producto_with_lote / receive_merchandise_lote
-- Alineado a columnas REALES de public.productos (sin proveedor, receta, etc.)
--
-- EJECUTAR PRIMERO, luego sql/carga_inventario_tickets_EJECUTAR_1..4.sql
-- ============================================================

begin;

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

  -- Solo columnas confirmadas en productos (ver sql/seed_productos_prueba.sql)
  insert into public.productos (
    nombre,
    sku,
    precio,
    costo,
    stock,
    stock_minimo,
    stock_unidades,
    categoria,
    tipo,
    descripcion,
    codigo_barras,
    requiere_receta,
    activo
  ) values (
    p_producto_data->>'nombre',
    p_producto_data->>'sku',
    nullif(p_producto_data->>'precio', '')::numeric,
    nullif(p_producto_data->>'costo', '')::numeric,
    0,
    coalesce(nullif(p_producto_data->>'stock_minimo', '')::integer, 5),
    coalesce(nullif(p_producto_data->>'stock_unidades', '')::integer, 0),
    coalesce(nullif(p_producto_data->>'categoria', ''), 'GENERAL'),
    coalesce(nullif(p_producto_data->>'tipo', ''), 'GENERICO'),
    p_producto_data->>'descripcion',
    nullif(p_producto_data->>'codigo_barras', ''),
    coalesce(nullif(p_producto_data->>'requiere_receta', '')::boolean, false),
    coalesce(nullif(p_producto_data->>'activo', '')::boolean, true)
  ) returning id into v_producto_id;

  if coalesce(p_cantidad_inicial, 0) > 0 then
    v_lote_numero := coalesce(
      p_numero_lote,
      'INICIAL-' || to_char(now(), 'YYYYMMDD-HH24MISS')
    );

    insert into public.lotes (
      producto_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_caducidad, costo_unitario, activo
    ) values (
      v_producto_id,
      v_lote_numero,
      p_cantidad_inicial, p_cantidad_inicial,
      p_fecha_caducidad,
      coalesce(p_costo_unitario, nullif(p_producto_data->>'costo', '')::numeric),
      true
    ) returning id into v_lote_id;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo, usuario_id
    ) values (
      v_producto_id, 'entrada', p_cantidad_inicial,
      'Alta de producto con stock inicial',
      p_user_id::integer
    );
  end if;

  return query select v_producto_id, v_lote_id;
end;
$$;

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

  update public.productos
  set costo = coalesce(p_costo_unitario, costo)
  where id = p_producto_id;

  insert into public.movimientos_inventario (
    producto_id, tipo, cantidad, motivo, usuario_id
  ) values (
    p_producto_id, 'entrada', p_cantidad,
    format('Recepcion de mercancia (lote %s)', v_numero),
    p_user_id::integer
  );

  return query
  select v_lote_id, p.stock
  from public.productos p
  where p.id = p_producto_id;
end;
$$;

grant execute on function public.create_producto_with_lote(
  jsonb, integer, text, date, numeric, bigint
) to anon, authenticated, service_role;

grant execute on function public.receive_merchandise_lote(
  bigint, integer, text, date, numeric, text, bigint
) to anon, authenticated, service_role;

commit;

-- Prueba rápida (opcional, ejecutar aparte):
-- select producto_id, lote_id from create_producto_with_lote(
--   '{"nombre":"PRUEBA CARGA","sku":"FC-TEST-1","categoria":"GENERAL","tipo":"GENERICO","descripcion":"test","costo":10,"precio":13.5,"activo":true}'::jsonb,
--   1, 'LOTE-TEST', '2028-01-01'::date, 10, null
-- );
