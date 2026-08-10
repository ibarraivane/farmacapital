-- FarmaCapital — ACTUALIZACIÓN MASIVA INVENTARIO
-- Generado: 2026-08-10
-- Fuente: Excel homologado de tickets (627 líneas)
--
-- ORDEN EN SUPABASE SQL EDITOR:
--   1) ACTUALIZACION_MASIVA_1_preparacion_catalogo.sql  ← columnas + funciones + catálogo
--   2) ACTUALIZACION_MASIVA_2_barcodes_proveedores.sql
--
-- Si falló antes: ejecuta primero sql/patch_productos_campos_catalogo.sql
-- y sql/patch_proveedor_tienda_en_lotes.sql por separado.
--
-- Incluye:
--   • Parche RPCs (proveedor tienda en lotes)
--   • Catálogo: nombre, marca, presentación, PA, precios 60%/30%
--   • Códigos de barras del ticket (349 con EAN)
--   • Proveedor del lote = tienda de compra (627 mapeos)


begin;

-- ── patch_productos_campos_catalogo.sql ──
-- ============================================================
-- Columnas de catálogo en productos (requeridas antes de ACTUALIZACION_MASIVA)
-- Idempotente: seguro ejecutar varias veces.
-- ============================================================


alter table if exists public.productos
  add column if not exists marca text,
  add column if not exists presentacion text,
  add column if not exists principio_activo text,
  add column if not exists concentracion text,
  add column if not exists forma_farmaceutica text,
  add column if not exists denominacion_generica text,
  add column if not exists denominacion_distintiva text,
  add column if not exists ubicacion_texto text,
  add column if not exists precio_similares numeric,
  add column if not exists precio_del_ahorro numeric,
  add column if not exists fecha_actualizacion_precios date;

-- Catálogo proveedores + FK en lotes (si aún no existen)
create table if not exists public.proveedores (
  id          serial       primary key,
  nombre      text         not null,
  rfc         text,
  telefono    text,
  email       text,
  direccion   text,
  activo      boolean      not null default true,
  created_at  timestamptz  not null default now()
);

alter table if exists public.lotes
  add column if not exists proveedor_id integer references public.proveedores(id);

create index if not exists idx_lotes_proveedor_id on public.lotes (proveedor_id);

-- Verificación rápida
select column_name
from information_schema.columns
where table_schema = 'public'
  and table_name = 'productos'
  and column_name in (
    'marca', 'presentacion', 'principio_activo',
    'concentracion', 'forma_farmaceutica'
  )
order by 1;

-- ── patch_proveedor_tienda_en_lotes.sql ──
-- ============================================================
-- Proveedor del lote = tienda de compra (ticket)
-- Resuelve nombre → proveedores.id y lo guarda en lotes.proveedor_id
--
-- Ejecutar ANTES de cargar inventario o junto con backfill:
--   sql/actualizar_proveedor_lotes_tickets.sql
-- ============================================================


create or replace function public.fc_resolver_proveedor_tienda(p_nombre text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id bigint;
  v_nombre text;
begin
  v_nombre := nullif(btrim(p_nombre), '');
  if v_nombre is null then
    return null;
  end if;

  select p.id
  into v_id
  from public.proveedores p
  where lower(btrim(p.nombre)) = lower(v_nombre)
  limit 1;

  if v_id is not null then
    return v_id;
  end if;

  insert into public.proveedores (nombre, activo)
  values (v_nombre, true)
  returning id into v_id;

  return v_id;
end;
$$;

create or replace function public.create_producto_with_lote(
  p_producto_data jsonb,
  p_cantidad_inicial integer default 0,
  p_numero_lote text default null,
  p_fecha_caducidad date default null,
  p_costo_unitario numeric default null,
  p_user_id bigint default null,
  p_proveedor_tienda text default null
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
  v_proveedor_id bigint;
  v_proveedor_nombre text;
begin
  if p_producto_data is null then
    raise exception 'producto_data requerido';
  end if;
  if (p_producto_data->>'nombre') is null or btrim(p_producto_data->>'nombre') = '' then
    raise exception 'nombre requerido';
  end if;

  v_proveedor_nombre := coalesce(
    nullif(btrim(p_proveedor_tienda), ''),
    nullif(btrim(p_producto_data->>'proveedor_tienda'), '')
  );
  v_proveedor_id := public.fc_resolver_proveedor_tienda(v_proveedor_nombre);

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
      fecha_caducidad, costo_unitario, proveedor_id, activo
    ) values (
      v_producto_id,
      v_lote_numero,
      p_cantidad_inicial, p_cantidad_inicial,
      p_fecha_caducidad,
      coalesce(p_costo_unitario, nullif(p_producto_data->>'costo', '')::numeric),
      v_proveedor_id,
      true
    ) returning id into v_lote_id;

    insert into public.movimientos_inventario (
      producto_id, lote_id, tipo, cantidad, motivo, usuario_id
    ) values (
      v_producto_id, v_lote_id, 'entrada', p_cantidad_inicial,
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
  v_proveedor_id bigint;
begin
  if p_producto_id is null then raise exception 'producto_id requerido'; end if;
  if p_cantidad is null or p_cantidad <= 0 then raise exception 'cantidad invalida'; end if;

  perform 1 from public.productos p where p.id = p_producto_id for update;
  if not found then
    raise exception 'producto % no existe', p_producto_id;
  end if;

  v_proveedor_id := public.fc_resolver_proveedor_tienda(p_proveedor);

  v_numero := coalesce(
    nullif(btrim(p_numero_lote), ''),
    'RX-' || to_char(now(), 'YYYYMMDD-HH24MISS')
  );

  insert into public.lotes (
    producto_id, numero_lote, cantidad_inicial, cantidad_actual,
    fecha_caducidad, costo_unitario, proveedor_id, activo
  ) values (
    p_producto_id, v_numero, p_cantidad, p_cantidad,
    p_fecha_caducidad, p_costo_unitario, v_proveedor_id, true
  ) returning id into v_lote_id;

  update public.productos
  set costo = coalesce(p_costo_unitario, costo)
  where id = p_producto_id;

  insert into public.movimientos_inventario (
    producto_id, lote_id, tipo, cantidad, motivo, usuario_id
  ) values (
    p_producto_id, v_lote_id, 'entrada', p_cantidad,
    format('Recepcion de mercancia (lote %s)', v_numero),
    p_user_id::integer
  );

  return query
  select v_lote_id, p.stock
  from public.productos p
  where p.id = p_producto_id;
end;
$$;

grant execute on function public.fc_resolver_proveedor_tienda(text) to anon, authenticated, service_role;
grant execute on function public.create_producto_with_lote(
  jsonb, integer, text, date, numeric, bigint, text
) to anon, authenticated, service_role;
grant execute on function public.receive_merchandise_lote(
  bigint, integer, text, date, numeric, text, bigint
) to anon, authenticated, service_role;

-- ── actualizar_catalogo_campos_y_precios.sql ──
-- Catálogo: nombre/marca/presentación/PA + precios
-- Genéricos y no-medicamentos: +60% sobre costo
-- Medicamento de patente / marca comercial: +30% sobre costo
-- Ejecutar UNA vez. Luego recarga Inventario en Admin.


-- FC-F967863B | margen 30% | TERFICHO 40 CAPS 100 MG
update public.productos set nombre = 'Terficho', marca = 'Terficho', presentacion = '40 CAPSULAS', concentracion = '100 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 46.05, precio = 59.87 where sku = 'FC-F967863B';

-- FC-C721E8D7 | margen 60% | LEVOFLOXACINO 7 TAB 500 MG
update public.productos set nombre = 'Levofloxacino', presentacion = '7 TABLETAS', principio_activo = 'LEVOFLOXACINO', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 18.77, precio = 30.04 where sku = 'FC-C721E8D7';

-- FC-B25B4654 | margen 30% | CINA 7 TAB 750 MG
update public.productos set nombre = 'Cina', marca = 'Cina', presentacion = '7 TABLETAS', concentracion = '750 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 28.87, precio = 37.54 where sku = 'FC-B25B4654';

-- FC-ACA2A2F6 | margen 60% | ALOPURINOL 20 TAB 300 MG
update public.productos set nombre = 'Alopurinol', presentacion = '20 TABLETAS', principio_activo = 'ALOPURINOL', concentracion = '300 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 21.46, precio = 34.34 where sku = 'FC-ACA2A2F6';

-- FC-174824A0 | margen 30% | VERNISEN 6 TAB 200 MG
update public.productos set nombre = 'Vernisen', marca = 'Vernisen', presentacion = '6 TABLETAS', concentracion = '200 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 12.38, precio = 16.1 where sku = 'FC-174824A0';

-- FC-D5AC44CA | margen 30% | AMIFARIN 20 CAPS 500 MG
update public.productos set nombre = 'Amifarin', marca = 'Amifarin', presentacion = '20 CAPSULAS', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 45.78, precio = 59.52 where sku = 'FC-D5AC44CA';

-- FC-9A4E4C31 | margen 60% | CLINDAMICINA FA 600MG/4ML
update public.productos set nombre = 'Clindamicina', presentacion = 'FRASCO AMPULA', principio_activo = 'CLINDAMICINA', concentracion = '600MG/4 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'generico', costo = 88.42, precio = 141.48 where sku = 'FC-9A4E4C31';

-- FC-40CE757D | margen 30% | CEFALVER 12 TAB 1 G
update public.productos set nombre = 'Cefalver', marca = 'Cefalver', presentacion = '12 TABLETAS', concentracion = '1 G', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 62.48, precio = 81.23 where sku = 'FC-40CE757D';

-- FC-B18E386A | margen 30% | CEFAROXIL 15 TAB 500/30 MG
update public.productos set nombre = 'Cefaroxil', marca = 'Cefaroxil', presentacion = '15 TABLETAS', concentracion = '500/30 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 44.44, precio = 57.78 where sku = 'FC-B18E386A';

-- FC-1DA570E3 | margen 30% | CLOXAN 20 COMP 30 MG
update public.productos set nombre = 'Cloxan', marca = 'Cloxan', presentacion = '20 COMPRIMIDOS', concentracion = '30 MG', forma_farmaceutica = 'COMPRIMIDOS', categoria = 'Otro', tipo = 'marca', costo = 9.75, precio = 12.68 where sku = 'FC-1DA570E3';

-- FC-A455EE80 | margen 30% | CEFAGEN 1 SUSP 250MG/5/50 ML
update public.productos set nombre = 'Cefagen', marca = 'Cefagen', presentacion = '1 SUSPENSION', principio_activo = 'CEFALEXINA', concentracion = '250MG/5/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 74.58, precio = 96.96 where sku = 'FC-A455EE80';

-- FC-E374F23E | margen 30% | CEFAGEN 1 SUSP 125MG/5/50 ML
update public.productos set nombre = 'Cefagen', marca = 'Cefagen', presentacion = '1 SUSPENSION', principio_activo = 'CEFALEXINA', concentracion = '125MG/5/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 48.48, precio = 63.03 where sku = 'FC-E374F23E';

-- FC-8FB65B79 | margen 30% | KLARIX 1 SUSP 250MG/5ML 60 ML
update public.productos set nombre = 'Klarix', marca = 'Klarix', presentacion = '1 SUSPENSION', principio_activo = 'CLARITROMICINA', concentracion = '250MG/5 ML 60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 81.67, precio = 106.18 where sku = 'FC-8FB65B79';

-- FC-2EDC6E3B | margen 30% | CEFAGEN 10 TAB 250 MG
update public.productos set nombre = 'Cefagen', marca = 'Cefagen', presentacion = '10 TABLETAS', principio_activo = 'CEFALEXINA', concentracion = '250 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 82.09, precio = 106.72 where sku = 'FC-2EDC6E3B';

-- FC-C101D5B1 | margen 60% | BISOPROLOL 30 TAB 2.5 MG
update public.productos set nombre = 'Bisoprolol', presentacion = '30 TABLETAS', principio_activo = 'BISOPROLOL', concentracion = '2.5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 97.51, precio = 156.02 where sku = 'FC-C101D5B1';

-- FC-7AF7ACB5 | margen 30% | CHARLYN 3 TAB 500 MG
update public.productos set nombre = 'Charlyn', marca = 'Charlyn', presentacion = '3 TABLETAS', principio_activo = 'CIPROFLOXACINO', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 24.98, precio = 32.48 where sku = 'FC-7AF7ACB5';

-- FC-CF18C740 | margen 60% | CLINDAMICINA 16 CAP 300 MG
update public.productos set nombre = 'Clindamicina', presentacion = '16 CAPSULAS', principio_activo = 'CLINDAMICINA', concentracion = '300 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', costo = 30.54, precio = 48.87 where sku = 'FC-CF18C740';

-- FC-E4EFC4C2 | margen 30% | FASICLOR 15 CAPS 500 MG
update public.productos set nombre = 'Fasiclor', marca = 'Fasiclor', presentacion = '15 CAPSULAS', principio_activo = 'CEFACLOR', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 137.92, precio = 179.3 where sku = 'FC-E4EFC4C2';

-- FC-6EAD98A9 | margen 30% | CEPOBROM 12 CAPS 500/0.782 MG
update public.productos set nombre = 'Cepobrom', marca = 'Cepobrom', presentacion = '12 CAPSULAS', principio_activo = 'CEFADROXIL', concentracion = '500/0.782 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 47.97, precio = 62.37 where sku = 'FC-6EAD98A9';

-- FC-CF719C07 | margen 30% | DICLOFEN 12 CAPS 500 MG
update public.productos set nombre = 'Diclofen', marca = 'Diclofen', presentacion = '12 CAPSULAS', principio_activo = 'DICLOFENACO', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 26.82, precio = 34.87 where sku = 'FC-CF719C07';

-- FC-60F627D5 | margen 60% | GENTAMICINA 5 AMP 160MG/2ML
update public.productos set nombre = 'Gentamicina', presentacion = '5 AMPOLLETA', principio_activo = 'GENTAMICINA', concentracion = '160MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'generico', costo = 52.57, precio = 84.12 where sku = 'FC-60F627D5';

-- FC-48F732CF | margen 30% | EPICIN 20 CAPS 500 MG
update public.productos set nombre = 'Epicin', marca = 'Epicin', presentacion = '20 CAPSULAS', principio_activo = 'ERITROMICINA', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 29.56, precio = 38.43 where sku = 'FC-48F732CF';

-- FC-72C28BC1 | margen 30% | KNORICIN 1 SUSP 125MG/5/60 ML
update public.productos set nombre = 'Knoricin', marca = 'Knoricin', presentacion = '1 SUSPENSION', principio_activo = 'NITROFURANTOINA', concentracion = '125MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 45.41, precio = 59.04 where sku = 'FC-72C28BC1';

-- FC-443C330E | margen 30% | CEFAGEN 10 TAB 500 MG
update public.productos set nombre = 'Cefagen', marca = 'Cefagen', presentacion = '10 TABLETAS', principio_activo = 'CEFALEXINA', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 144.13, precio = 187.37 where sku = 'FC-443C330E';

-- FC-492D652F | margen 30% | CEFALVER 20 CAPS 500 MG
update public.productos set nombre = 'Cefalver', marca = 'Cefalver', presentacion = '20 CAPSULAS', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 43.35, precio = 56.36 where sku = 'FC-492D652F';

-- FC-86A95D07 | margen 30% | TROPHARMA 20 TAB 500 MG
update public.productos set nombre = 'Tropharma', marca = 'Tropharma', presentacion = '20 TABLETAS', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 44.53, precio = 57.89 where sku = 'FC-86A95D07';

-- FC-697EEAD0 | margen 30% | KURTOSIL 1 CMA 20/1 MG
update public.productos set nombre = 'Kurtosil', marca = 'Kurtosil', presentacion = '1 CREMA', concentracion = '20/1 MG', forma_farmaceutica = 'CREMA', categoria = 'Otro', tipo = 'marca', costo = 62.48, precio = 81.23 where sku = 'FC-697EEAD0';

-- FC-830BF3FB | margen 30% | DIVILTAC 1 FA 150/10MG/1 ML
update public.productos set nombre = 'Diviltac', marca = 'Diviltac', presentacion = '1 FRASCO AMPULA', concentracion = '150/10MG/1 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 34.45, precio = 44.79 where sku = 'FC-830BF3FB';

-- FC-F3E734A0 | margen 30% | FASICLOR 1 SUSP 375MG/5/50 ML
update public.productos set nombre = 'Fasiclor', marca = 'Fasiclor', presentacion = '1 SUSPENSION', principio_activo = 'CEFACLOR', concentracion = '375MG/5/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 63.44, precio = 82.48 where sku = 'FC-F3E734A0';

-- FC-74A5ABEE | margen 60% | CIPROFLOXACINO 12 TAB 250 MG
update public.productos set nombre = 'Ciprofloxacino', presentacion = '12 TABLETAS', principio_activo = 'CIPROFLOXACINO', concentracion = '250 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 13.69, precio = 21.91 where sku = 'FC-74A5ABEE';

-- FC-AEA8C8DA | margen 30% | NAMIFEN 20 TAB 500 MG
update public.productos set nombre = 'Namifen', marca = 'Namifen', presentacion = '20 TABLETAS', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 24.28, precio = 31.57 where sku = 'FC-AEA8C8DA';

-- FC-2005DD57 | margen 60% | CEFALEXINA 20 CAPS 500 MG
update public.productos set nombre = 'Cefalexina', presentacion = '20 CAPSULAS', principio_activo = 'CEFALEXINA', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', costo = 39.84, precio = 63.75 where sku = 'FC-2005DD57';

-- FC-B4477A00 | margen 30% | PENTIBROXIL 16 CAPS 500/30 MG
update public.productos set nombre = 'Pentibroxil', marca = 'Pentibroxil', presentacion = '16 CAPSULAS', concentracion = '500/30 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 30.04, precio = 39.06 where sku = 'FC-B4477A00';

-- FC-85BDBD3D | margen 30% | ACROXIL-C 1 SUSP 250MG/5/60 ML
update public.productos set nombre = 'Acroxil-C', marca = 'Acroxil-C', presentacion = '1 SUSPENSION', concentracion = '250MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 25.42, precio = 33.05 where sku = 'FC-85BDBD3D';

-- FC-7AA38F97 | margen 30% | PENTIVER 1 SUSP 500MG/5/60 ML
update public.productos set nombre = 'Pentiver', marca = 'Pentiver', presentacion = '1 SUSPENSION', concentracion = '500MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 31.2, precio = 40.56 where sku = 'FC-7AA38F97';

-- FC-9538F7D6 | margen 30% | FASICLOR 1 SUSP 250MG/5/75 ML
update public.productos set nombre = 'Fasiclor', marca = 'Fasiclor', presentacion = '1 SUSPENSION', principio_activo = 'CEFACLOR', concentracion = '250MG/5/75 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 81.18, precio = 105.54 where sku = 'FC-9538F7D6';

-- FC-01B2F362 | margen 30% | FASICLOR 1 SUSP 125MG/5/75 ML
update public.productos set nombre = 'Fasiclor', marca = 'Fasiclor', presentacion = '1 SUSPENSION', principio_activo = 'CEFACLOR', concentracion = '125MG/5/75 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 49.85, precio = 64.81 where sku = 'FC-01B2F362';

-- FC-50587FA6 | margen 30% | MEXAPIN 1 SUSP 125MG/5/60 ML
update public.productos set nombre = 'Mexapin', marca = 'Mexapin', presentacion = '1 SUSPENSION', concentracion = '125MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 13.93, precio = 18.11 where sku = 'FC-50587FA6';

-- FC-B72A6420 | margen 30% | PENTIVER 1 SUSP 250MG/5/90 ML
update public.productos set nombre = 'Pentiver', marca = 'Pentiver', presentacion = '1 SUSPENSION', concentracion = '250MG/5/90 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 27.06, precio = 35.18 where sku = 'FC-B72A6420';

-- FC-D9391288 | margen 60% | AZITROMICINA 1 SUSP 200MG/5/15 ML
update public.productos set nombre = 'Azitromicina', presentacion = '1 SUSPENSION', principio_activo = 'AZITROMICINA', concentracion = '200MG/5/15 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'generico', costo = 68.5, precio = 109.6 where sku = 'FC-D9391288';

-- FC-41339950 | margen 60% | CLARITROMICINA 10 TAB 500 MG
update public.productos set nombre = 'Claritromicina', presentacion = '10 TABLETAS', principio_activo = 'CLARITROMICINA', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 59.45, precio = 95.12 where sku = 'FC-41339950';

-- FC-E6112F15 | margen 60% | NALIXONE 20 TAB 500/50 MG
update public.productos set nombre = 'Nalixone', presentacion = '20 TABLETAS', principio_activo = 'NALIXONE', concentracion = '500/50 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 63.32, precio = 101.32 where sku = 'FC-E6112F15';

-- FC-F183C6E9 | margen 30% | PENIPOT 1 FA 800,000 UI
update public.productos set nombre = 'Penipot', marca = 'Penipot', presentacion = '1 FRASCO AMPULA', concentracion = '800,000 UI', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 19.44, precio = 25.28 where sku = 'FC-F183C6E9';

-- FC-A0D320D1 | margen 60% | AMOXICILINA 12 CAPS 500 MG
update public.productos set nombre = 'Amoxicilina', presentacion = '12 CAPSULAS', principio_activo = 'AMOXICILINA', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', costo = 18.37, precio = 29.4 where sku = 'FC-A0D320D1';

-- FC-95779436 | margen 30% | ACIDO ACETILSALICILICO EF 20 TAB 300 MG
update public.productos set nombre = 'Acetilsalicilico Ef', marca = 'Acido', presentacion = '20 TABLETAS', concentracion = '300 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 19.07, precio = 24.8 where sku = 'FC-95779436';

-- FC-4C621D07 | margen 60% | VANMOXOL 1 SUSP 250/15MG/5/90 ML
update public.productos set nombre = 'Vanmoxol', presentacion = '1 SUSPENSION', principio_activo = 'VANMOXOL', concentracion = '250/15MG/5/90 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'generico', costo = 18.03, precio = 28.85 where sku = 'FC-4C621D07';

-- FC-022543CD | margen 30% | VALCLAN 10 TAB 500/125 MG
update public.productos set nombre = 'Valclan', marca = 'Valclan', presentacion = '10 TABLETAS', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '500/125 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 37.22, precio = 48.39 where sku = 'FC-022543CD';

-- FC-64EB83AA | margen 30% | BENCIL/BENZ COMPL 1 FA 1,2 U 3 ML
update public.productos set nombre = 'Compl', marca = 'Bencil/Benz', presentacion = '1 FRASCO AMPULA', concentracion = '1,2 U 3 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 18.07, precio = 23.5 where sku = 'FC-64EB83AA';

-- FC-D210172A | margen 60% | AMPICILINA 1 FA 1G/5 ML
update public.productos set nombre = 'Ampicilina', presentacion = '1 FRASCO AMPULA', principio_activo = 'AMPICILINA', concentracion = '1 G/5 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'generico', costo = 25.48, precio = 40.77 where sku = 'FC-D210172A';

-- FC-7F90064A | margen 60% | AMPICILINA 1 FA 500MG/2 ML
update public.productos set nombre = 'Ampicilina', presentacion = '1 FRASCO AMPULA', principio_activo = 'AMPICILINA', concentracion = '500MG/2 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'generico', costo = 20.37, precio = 32.6 where sku = 'FC-7F90064A';

-- FC-F82A6E4B | margen 60% | AMPICILINA 10 TAB 1 G
update public.productos set nombre = 'Ampicilina', presentacion = '10 TABLETAS', principio_activo = 'AMPICILINA', concentracion = '1 G', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 27.05, precio = 43.28 where sku = 'FC-F82A6E4B';

-- FC-5F30F9D4 | margen 30% | CLAMOXIN 10 TAB 500/125 MG
update public.productos set nombre = 'Clamoxin', marca = 'Clamoxin', presentacion = '10 TABLETAS', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '500/125 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 48.48, precio = 63.03 where sku = 'FC-5F30F9D4';

-- FC-7D1D9857 | margen 30% | ACIDO ACETILSALICILICO 30 TAB 100MG
update public.productos set nombre = 'Acetilsalicilico', marca = 'Acido', presentacion = '30 TABLETAS', concentracion = '100MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 14.85, precio = 19.31 where sku = 'FC-7D1D9857';

-- FC-516C2E89 | margen 30% | CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50 ML
update public.productos set nombre = '12H Jr', marca = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '400/57MG/5/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 36.79, precio = 47.83 where sku = 'FC-516C2E89';

-- FC-05965071 | margen 30% | ACROXIL-C 12 CAPS 500/8 MG
update public.productos set nombre = 'Acroxil-C', marca = 'Acroxil-C', presentacion = '12 CAPSULAS', concentracion = '500/8 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 24.05, precio = 31.27 where sku = 'FC-05965071';

-- FC-930E0B1B | margen 30% | VANDIL 1 SUSP 250MG/5/75 ML
update public.productos set nombre = 'Vandil', marca = 'Vandil', presentacion = '1 SUSPENSION', concentracion = '250MG/5/75 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 20.58, precio = 26.76 where sku = 'FC-930E0B1B';

-- FC-405A75E3 | margen 30% | ACIDO URSODESOXICOLICO 50 CAP 250 MG
update public.productos set nombre = 'Ursodesoxicolico', marca = 'Acido', presentacion = '50 CAPSULAS', concentracion = '250 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 217.23, precio = 282.4 where sku = 'FC-405A75E3';

-- FC-D06E54FE | margen 30% | VALCLAN 10 TAB 875/125 MG
update public.productos set nombre = 'Valclan', marca = 'Valclan', presentacion = '10 TABLETAS', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '875/125 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 51.18, precio = 66.54 where sku = 'FC-D06E54FE';

-- FC-3A4583F3 | margen 30% | PENIPOT 1 FA 400,000 UI
update public.productos set nombre = 'Penipot', marca = 'Penipot', presentacion = '1 FRASCO AMPULA', concentracion = '400,000 UI', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 14.07, precio = 18.3 where sku = 'FC-3A4583F3';

-- FC-F22C72BE | margen 30% | CLAMOXIN 12H 10 TAB 875/125 MG
update public.productos set nombre = '12H', marca = 'Clamoxin', presentacion = '10 TABLETAS', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '875/125 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 55.03, precio = 71.54 where sku = 'FC-F22C72BE';

-- FC-F48FF7EF | margen 30% | CLAMOXIN 1 SUSP 250/62.5MG/5/60 ML
update public.productos set nombre = 'Clamoxin', marca = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '250/62.5MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 35.62, precio = 46.31 where sku = 'FC-F48FF7EF';

-- FC-4BD80686 | margen 60% | BENEVENTOL 3 CAPS 400 MG
update public.productos set nombre = 'Beneventol', presentacion = '3 CAPSULAS', principio_activo = 'BENEVENTOL', concentracion = '400 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', costo = 88.17, precio = 141.08 where sku = 'FC-4BD80686';

-- FC-974EE5FD | margen 60% | GIMALXINA 1 SUSP 250MG/5/75 ML
update public.productos set nombre = 'Gimalxina', presentacion = '1 SUSPENSION', principio_activo = 'GIMALXINA', concentracion = '250MG/5/75 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'generico', costo = 27.09, precio = 43.35 where sku = 'FC-974EE5FD';

-- FC-0E0A9E42 | margen 30% | CLAMOXIN S 1 SUSP 600/42.9MG/50 ML
update public.productos set nombre = 'S', marca = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '600/42.9MG/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 47.99, precio = 62.39 where sku = 'FC-0E0A9E42';

-- FC-6519183A | margen 30% | CLAMOXIN 1 SUSP 125/31.25MG/5/60 ML
update public.productos set nombre = 'Clamoxin', marca = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '125/31.25MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 27.89, precio = 36.26 where sku = 'FC-6519183A';

-- FC-DDFBABDF | margen 30% | CLAMOXIN 12H PED 1 SUSP 200/28.5MG/40 ML
update public.productos set nombre = '12H Ped', marca = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '200/28.5MG/40 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 25.94, precio = 33.73 where sku = 'FC-DDFBABDF';

-- FC-C9F4ACCC | margen 60% | ACEMETACINA 14 CAPS 90 MG
update public.productos set nombre = 'Acemetacina', presentacion = '14 CAPSULAS', principio_activo = 'ACEMETACINA', concentracion = '90 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', costo = 39.44, precio = 63.11 where sku = 'FC-C9F4ACCC';

-- FC-17376CAE | margen 30% | ASPITAK-P 30 COMP 100 MG
update public.productos set nombre = 'Aspitak-P', marca = 'Aspitak-P', presentacion = '30 COMPRIMIDOS', concentracion = '100 MG', forma_farmaceutica = 'COMPRIMIDOS', categoria = 'Otro', tipo = 'marca', costo = 19.72, precio = 25.64 where sku = 'FC-17376CAE';

-- FC-369D1689 | margen 60% | BENEVENTOL 6 CAPS 400 MG
update public.productos set nombre = 'Beneventol', presentacion = '6 CAPSULAS', principio_activo = 'BENEVENTOL', concentracion = '400 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', costo = 51.43, precio = 82.29 where sku = 'FC-369D1689';

-- FC-B69FCBF4 | margen 30% | LESACLOR (MACLOV) 35 TAB 400 MG
update public.productos set nombre = '(Maclov)', marca = 'Lesaclor', presentacion = '35 TABLETAS', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 146.11, precio = 189.95 where sku = 'FC-B69FCBF4';

-- FC-F4E9C71F | margen 60% | AMOXICILINA 1 SUSP 500MG/5/75 ML
update public.productos set nombre = 'Amoxicilina', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA', concentracion = '500MG/5/75 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'generico', costo = 72.03, precio = 115.25 where sku = 'FC-F4E9C71F';

-- FC-428A228F | margen 60% | GIMALXINA 12 CAPS 500 MG
update public.productos set nombre = 'Gimalxina', presentacion = '12 CAPSULAS', principio_activo = 'GIMALXINA', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', costo = 23.57, precio = 37.72 where sku = 'FC-428A228F';

-- FC-FD845E68 | margen 30% | ACICLOVIR 35 TAB 400 MG
update public.productos set nombre = 'Aciclovir', marca = 'Aciclovir', presentacion = '35 TABLETAS', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 23.68, precio = 30.79 where sku = 'FC-FD845E68';

-- FC-B2123139 | margen 30% | OXIVAG 4 TAB 70 MG
update public.productos set nombre = 'Oxivag', marca = 'Oxivag', presentacion = '4 TABLETAS', concentracion = '70 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 64.09, precio = 83.32 where sku = 'FC-B2123139';

-- FC-11294615 | margen 60% | AMIKACINA 2 AMP 500MG/2 ML
update public.productos set nombre = 'Amikacina', presentacion = '2 AMPOLLETA', principio_activo = 'AMIKACINA', concentracion = '500MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'generico', costo = 31.94, precio = 51.11 where sku = 'FC-11294615';

-- FC-1FEA2FB7 | margen 60% | AMIKACINA 1 AMP 500MG/2 ML
update public.productos set nombre = 'Amikacina', presentacion = '1 AMPOLLETA', principio_activo = 'AMIKACINA', concentracion = '500MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'generico', costo = 29.21, precio = 46.74 where sku = 'FC-1FEA2FB7';

-- FC-AA905BF7 | margen 30% | PERLUDIL 1 FA 150/10 MG
update public.productos set nombre = 'Perludil', marca = 'Perludil', presentacion = '1 FRASCO AMPULA', concentracion = '150/10 MG', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 16.11, precio = 20.95 where sku = 'FC-AA905BF7';

-- FC-AE5EEDF7 | margen 30% | BACTIVER 20 TAB 400/80 MG
update public.productos set nombre = 'Bactiver', marca = 'Bactiver', presentacion = '20 TABLETAS', concentracion = '400/80 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 48.65, precio = 63.25 where sku = 'FC-AE5EEDF7';

-- FC-F8691496 | margen 30% | BACTIVER F 16 TAB 160/800 MG
update public.productos set nombre = 'F', marca = 'Bactiver', presentacion = '16 TABLETAS', concentracion = '160/800 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 16.89, precio = 21.96 where sku = 'FC-F8691496';

-- FC-6074BB64 | margen 30% | REDALIP 30 TAB 200 MG
update public.productos set nombre = 'Redalip', marca = 'Redalip', presentacion = '30 TABLETAS', concentracion = '200 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 21.01, precio = 27.32 where sku = 'FC-6074BB64';

-- FC-E826D304 | margen 30% | LINCOMICINA 600MG/2ML 6 AMPOLLETAS
update public.productos set nombre = 'Lincomicina /2Ml 6 Ampolletas', marca = 'Lincomicina', presentacion = '600 MG', categoria = 'Producto', tipo = 'marca', costo = 47.85, precio = 62.21 where sku = 'FC-E826D304';

-- FC-4F737E93 | margen 30% | CLOXAN 1 SOL 300MG/120ML
update public.productos set nombre = 'Cloxan', marca = 'Cloxan', presentacion = '1 SOLUCION', concentracion = '300MG/120 ML', forma_farmaceutica = 'SOLUCION', categoria = 'Otro', tipo = 'marca', costo = 44.04, precio = 57.26 where sku = 'FC-4F737E93';

-- FC-DB3B2584 | margen 30% | CELESBITAN 1 FA C/BER 6MG/2 ML
update public.productos set nombre = 'Celesbitan', marca = 'Celesbitan', presentacion = '1 FRASCO AMPULA', concentracion = 'C/BER 6MG/2 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 16.91, precio = 21.99 where sku = 'FC-DB3B2584';

-- FC-22B18244 | margen 30% | CEFOTAXIMA I.M. 1 FA 1G/4 ML
update public.productos set nombre = 'I.M', marca = 'Cefotaxima', presentacion = '1 FRASCO AMPULA', concentracion = '1 G/4 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 31.06, precio = 40.38 where sku = 'FC-22B18244';

-- FC-4A0245DA | margen 30% | AMLODIPINO 100 TAB 5 MG
update public.productos set nombre = 'Amlodipino', marca = 'Amlodipino', presentacion = '100 TABLETAS', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 32.52, precio = 42.28 where sku = 'FC-4A0245DA';

-- FC-29670370 | margen 30% | DEGORTZIN 1 SOL 100 MG/50 ML
update public.productos set nombre = 'Degortzin', marca = 'Degortzin', presentacion = '1 SOLUCION', concentracion = '100 MG/50 ML', forma_farmaceutica = 'SOLUCION', categoria = 'Otro', tipo = 'marca', costo = 35.71, precio = 46.43 where sku = 'FC-29670370';

-- FC-69A3C416 | margen 30% | WEXPEC 1 SOL 7.5/2MG/5/120 ML
update public.productos set nombre = 'Wexpec', marca = 'Wexpec', presentacion = '1 SOLUCION', concentracion = '7.5/2MG/5/120 ML', forma_farmaceutica = 'SOLUCION', categoria = 'Otro', tipo = 'marca', costo = 16.65, precio = 21.65 where sku = 'FC-69A3C416';

-- FC-F817BC3A | margen 30% | SIBICOS 1 CMA 1/100/20 G
update public.productos set nombre = 'Sibicos', marca = 'Sibicos', presentacion = '1 CREMA', concentracion = '1/100/20 G', forma_farmaceutica = 'CREMA', categoria = 'Otro', tipo = 'marca', costo = 33.65, precio = 43.75 where sku = 'FC-F817BC3A';

-- FC-447B30F9 | margen 30% | BUDESONIDA 5 AMP 0.250MG/2ML
update public.productos set nombre = 'Budesonida', marca = 'Budesonida', presentacion = '5 AMPOLLETA', concentracion = '0.250MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', costo = 131.38, precio = 170.8 where sku = 'FC-447B30F9';

-- FC-1CF27DC9 | margen 30% | DISON DEX 1 FA 5/2 MG
update public.productos set nombre = 'Dex', marca = 'Dison', presentacion = '1 FRASCO AMPULA', concentracion = '5/2 MG', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 36.86, precio = 47.92 where sku = 'FC-1CF27DC9';

-- FC-3CAA7C5C | margen 60% | CINARIZINA 60 TAB 75 MG
update public.productos set nombre = 'Cinarizina', presentacion = '60 TABLETAS', principio_activo = 'CINARIZINA', concentracion = '75 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 35.05, precio = 56.08 where sku = 'FC-3CAA7C5C';

-- FC-E6B50AC3 | margen 30% | CELECOXIB 10 CAPS 200MG
update public.productos set nombre = 'Celecoxib', marca = 'Celecoxib', presentacion = '10 CAPSULAS', concentracion = '200MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 34.82, precio = 45.27 where sku = 'FC-E6B50AC3';

-- FC-6B2ADEE9 | margen 30% | PRCTAISOL 1 SUSP/AER 200 DOSIS 12.80 G
update public.productos set nombre = 'Prctaisol 1 Susp/Aer 200 Dosis', presentacion = '12.80 G', tipo = 'marca', costo = 96.21, precio = 125.08 where sku = 'FC-6B2ADEE9';

-- FC-DB4A39AE | margen 30% | CALCIO EFE 12 COMP 500 MG
update public.productos set nombre = 'Efe', marca = 'Calcio', presentacion = '12 COMPRIMIDOS', concentracion = '500 MG', forma_farmaceutica = 'COMPRIMIDOS', categoria = 'Otro', tipo = 'marca', costo = 39.07, precio = 50.8 where sku = 'FC-DB4A39AE';

-- FC-FA3D96E6 | margen 30% | BECATRIM N CALCITRIOL 30 CAPS 0.25 MCG
update public.productos set nombre = 'N Calcitriol', marca = 'Becatrim', presentacion = '30 CAPSULAS', concentracion = '0.25 MCG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 47.13, precio = 61.27 where sku = 'FC-FA3D96E6';

-- FC-63975795 | margen 60% | GENTAMICINA 25 COMP 1 MG
update public.productos set nombre = 'Gentamicina', presentacion = '25 COMPRIMIDOS', principio_activo = 'GENTAMICINA', concentracion = '1 MG', forma_farmaceutica = 'COMPRIMIDOS', categoria = 'Otro', tipo = 'generico', costo = 17.58, precio = 28.13 where sku = 'FC-63975795';

-- FC-C6C20517 | margen 30% | BUDIMIN 20 TAB 1 MG
update public.productos set nombre = 'Budimin', marca = 'Budimin', presentacion = '20 TABLETAS', concentracion = '1 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 31.31, precio = 40.71 where sku = 'FC-C6C20517';

-- FC-58DB24C4 | margen 30% | BITENVER 30 TAB 24 MG
update public.productos set nombre = 'Bitenver', marca = 'Bitenver', presentacion = '30 TABLETAS', concentracion = '24 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 62.78, precio = 81.62 where sku = 'FC-58DB24C4';

-- FC-1FFBB505 | margen 30% | SUPRATEX DAC 1 SOL 300/600 MG 120 ML
update public.productos set nombre = 'Dac', marca = 'Supratex', presentacion = '1 SOLUCION', concentracion = '300/600 MG 120 ML', forma_farmaceutica = 'SOLUCION', categoria = 'Otro', tipo = 'marca', costo = 42.14, precio = 54.79 where sku = 'FC-1FFBB505';

-- FC-A909ABC0 | margen 30% | ODIVITOR 10 TAB 20 MG
update public.productos set nombre = 'Odivitor', marca = 'Odivitor', presentacion = '10 TABLETAS', concentracion = '20 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 13.77, precio = 17.91 where sku = 'FC-A909ABC0';

-- FC-82F88FED | margen 60% | CAPTOPRIL 30 TAB 25 MG
update public.productos set nombre = 'Captopril', presentacion = '30 TABLETAS', principio_activo = 'CAPTOPRIL', concentracion = '25 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 7.95, precio = 12.72 where sku = 'FC-82F88FED';

-- FC-6C2878CF | margen 30% | BUDENOVA SUSP 125 MG/ML 5 AMP 2ML
update public.productos set nombre = 'Susp 125 Mg/Ml', marca = 'Budenova', presentacion = '5 AMPOLLETA', concentracion = '2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', costo = 130.24, precio = 169.32 where sku = 'FC-6C2878CF';

-- FC-3B001F9B | margen 30% | AMLODIPINO 30 TAB 5 MG
update public.productos set nombre = 'Amlodipino', marca = 'Amlodipino', presentacion = '30 TABLETAS', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 9.04, precio = 11.76 where sku = 'FC-3B001F9B';

-- FC-B25094C4 | margen 30% | LESACLOR 1 SUSP 200MG/5/125 ML
update public.productos set nombre = 'Lesaclor', marca = 'Lesaclor', presentacion = '1 SUSPENSION', concentracion = '200MG/5/125 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 44.43, precio = 57.76 where sku = 'FC-B25094C4';

-- FC-26EA40A4 | margen 30% | RAMCINET 10 TAB 10 MG
update public.productos set nombre = 'Ramcinet', marca = 'Ramcinet', presentacion = '10 TABLETAS', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 19.65, precio = 25.55 where sku = 'FC-26EA40A4';

-- FC-885F2723 | margen 60% | CARBAMAZEPINA 20 TAB 200 MG
update public.productos set nombre = 'Carbamazepina', presentacion = '20 TABLETAS', principio_activo = 'CARBAMAZEPINA', concentracion = '200 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 18.11, precio = 28.98 where sku = 'FC-885F2723';

-- FC-DF8ADDAB | margen 30% | ERISPAN 1 FA 4MG/3 ML
update public.productos set nombre = 'Erispan', marca = 'Erispan', presentacion = '1 FRASCO AMPULA', concentracion = '4MG/3 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 22.15, precio = 28.8 where sku = 'FC-DF8ADDAB';

-- FC-50AC2C82 | margen 30% | ERISPAN 1 FA 8MG/2 ML
update public.productos set nombre = 'Erispan', marca = 'Erispan', presentacion = '1 FRASCO AMPULA', concentracion = '8MG/2 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 24.45, precio = 31.79 where sku = 'FC-50AC2C82';

-- FC-281E0F22 | margen 30% | BUDESONIDA 1 SUSP NEB AMP 0.500MG
update public.productos set nombre = 'Budesonida', marca = 'Budesonida', presentacion = '1 SUSPENSION', concentracion = 'NEB AMP 0.500MG', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 153.72, precio = 199.84 where sku = 'FC-281E0F22';

-- FC-9F67BB73 | margen 30% | AMIFARIN 1 SUSP 250MG 60 ML
update public.productos set nombre = 'Amifarin', marca = 'Amifarin', presentacion = '1 SUSPENSION', concentracion = '250MG 60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 27.0, precio = 35.1 where sku = 'FC-9F67BB73';

-- FC-4FD413D2 | margen 30% | HASPEN 3 AMP 20 MG/1 ML
update public.productos set nombre = 'Haspen', marca = 'Haspen', presentacion = '3 AMPOLLETA', concentracion = '20 MG/1 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', costo = 23.53, precio = 30.59 where sku = 'FC-4FD413D2';

-- FC-0BDE9283 | margen 30% | CLOPHIVEN 200 DOSIS 50 MCG/15 G
update public.productos set nombre = 'Clophiven 200 Dosis 50 Mcg', marca = 'Clophiven', presentacion = '15 G', categoria = 'Producto', tipo = 'marca', costo = 56.51, precio = 73.47 where sku = 'FC-0BDE9283';

-- FC-97BEFA1A | margen 30% | AMLODIPINO 100 TAB 5 MG
update public.productos set nombre = 'Amlodipino', marca = 'Amlodipino', presentacion = '100 TABLETAS', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 32.52, precio = 42.28 where sku = 'FC-97BEFA1A';

-- FC-DEAF33B0 | margen 30% | BACTIVER 1 SUSP 40/200/5/120 ML
update public.productos set nombre = 'Bactiver', marca = 'Bactiver', presentacion = '1 SUSPENSION', concentracion = '40/200/5/120 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 21.28, precio = 27.67 where sku = 'FC-DEAF33B0';

-- FC-77FE5C83 | margen 30% | SONBLEFAM S 1 CMA 100 G/40 G
update public.productos set nombre = 'S', marca = 'Sonblefam', presentacion = '1 CREMA', concentracion = '100 G/40 G', forma_farmaceutica = 'CREMA', categoria = 'Otro', tipo = 'marca', costo = 32.41, precio = 42.14 where sku = 'FC-77FE5C83';

-- FC-C636D8EA | margen 30% | CEFTRIAXONA I.M. 1 FA 1G/3.5 ML
update public.productos set nombre = 'I.M', marca = 'Ceftriaxona', presentacion = '1 FRASCO AMPULA', concentracion = '1 G/3.5 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 9.8, precio = 12.75 where sku = 'FC-C636D8EA';

-- FC-44B6751A | margen 30% | LAUR AQUITO 500/100/30/4 MG 3 AMP
update public.productos set nombre = 'Aquito 500/100/30/4 Mg', marca = 'Laur', presentacion = '3 AMPOLLETA', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', costo = 59.63, precio = 77.52 where sku = 'FC-44B6751A';

-- FC-9B93AC4C | margen 60% | BENEVENTOL 1 SUSP 100MG/5ML/50 ML
update public.productos set nombre = 'Beneventol', presentacion = '1 SUSPENSION', principio_activo = 'BENEVENTOL', concentracion = '100MG/5 ML/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'generico', costo = 97.6, precio = 156.16 where sku = 'FC-9B93AC4C';

-- FC-2001A890 | margen 30% | AMPIGRIN AD 3 AMP 500/500/100/30MG/3 ML
update public.productos set nombre = 'Ad', marca = 'Ampigrin', presentacion = '3 AMPOLLETA', concentracion = '500/500/100/30MG/3 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', costo = 81.71, precio = 106.23 where sku = 'FC-2001A890';

-- FC-DE106642 | margen 30% | AMPIGRIN INF 3 AMP 250/200/100/30MG/3 ML
update public.productos set nombre = 'Inf', marca = 'Ampigrin', presentacion = '3 AMPOLLETA', concentracion = '250/200/100/30MG/3 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', costo = 73.57, precio = 95.65 where sku = 'FC-DE106642';

-- FC-BE76D409 | margen 30% | AMCEF I.M. 1 FA 1G/3.5 ML
update public.productos set nombre = 'I.M', marca = 'Amcef', presentacion = '1 FRASCO AMPULA', concentracion = '1 G/3.5 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 19.72, precio = 25.64 where sku = 'FC-BE76D409';

-- FC-07F04F88 | margen 30% | AMCEF I.M. 1 FA 500MG/2 ML
update public.productos set nombre = 'I.M', marca = 'Amcef', presentacion = '1 FRASCO AMPULA', concentracion = '500MG/2 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 19.43, precio = 25.26 where sku = 'FC-07F04F88';

-- FC-357D4A17 | margen 30% | CEFTAZIDIMA 1 FA 1G/3 ML
update public.productos set nombre = 'Ceftazidima', marca = 'Ceftazidima', presentacion = '1 FRASCO AMPULA', concentracion = '1 G/3 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', costo = 45.42, precio = 59.05 where sku = 'FC-357D4A17';

-- FC-5D9DFA3D | margen 60% | NORQUINOL 20 TAB 400 MG
update public.productos set nombre = 'Norquinol', presentacion = '20 TABLETAS', principio_activo = 'NORQUINOL', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 48.87, precio = 78.2 where sku = 'FC-5D9DFA3D';

-- FC-E9C38DC4 | margen 60% | CIPROFLOXACINO G.I. 14 TAB 500 MG
update public.productos set nombre = 'Ciprofloxacino G.I', presentacion = '14 TABLETAS', principio_activo = 'CIPROFLOXACINO G.I', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 22.92, precio = 36.68 where sku = 'FC-E9C38DC4';

-- FC-347A49C7 | margen 60% | AMIKACINA 1 AMP 100 MG/2 ML
update public.productos set nombre = 'Amikacina', presentacion = '1 AMPOLLETA', principio_activo = 'AMIKACINA', concentracion = '100 MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'generico', costo = 19.46, precio = 31.14 where sku = 'FC-347A49C7';

-- FC-E4BE37BE | margen 60% | ATORVASTATINA 10 TAB 40 MG
update public.productos set nombre = 'Atorvastatina', presentacion = '10 TABLETAS', principio_activo = 'ATORVASTATINA', concentracion = '40 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 26.35, precio = 42.16 where sku = 'FC-E4BE37BE';

-- FC-1751468C | margen 30% | FLOSPET 8 TAB 400 MG
update public.productos set nombre = 'Flospet', marca = 'Flospet', presentacion = '8 TABLETAS', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 27.33, precio = 35.53 where sku = 'FC-1751468C';

-- FC-6898B64F | margen 30% | BIOERTER 1 SUSP 250 MG/100 ML
update public.productos set nombre = 'Bioerter', marca = 'Bioerter', presentacion = '1 SUSPENSION', concentracion = '250 MG/100 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', costo = 47.7, precio = 62.02 where sku = 'FC-6898B64F';

-- FC-CD261CD5 | margen 30% | DOLIPROFEN 10 TAB 800 MG
update public.productos set nombre = 'Doliprofen', marca = 'Doliprofen', presentacion = '10 TABLETAS', concentracion = '800 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 22.41, precio = 29.14 where sku = 'FC-CD261CD5';

-- FC-5C8C9C11 | margen 30% | GELUBRIN 10 CAPS 600 MG
update public.productos set nombre = 'Gelubrin', marca = 'Gelubrin', presentacion = '10 CAPSULAS', concentracion = '600 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 21.95, precio = 28.54 where sku = 'FC-5C8C9C11';

-- FC-A23F290E | margen 60% | ZITRIASOL 15 CAP 100 MG
update public.productos set nombre = 'Zitriasol', presentacion = '15 CAPSULAS', principio_activo = 'ZITRIASOL', concentracion = '100 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', costo = 34.61, precio = 55.38 where sku = 'FC-A23F290E';

-- FC-5885E577 | margen 30% | PABESORAG 28 TAB 150/12.5 MG
update public.productos set nombre = 'Pabesorag', marca = 'Pabesorag', presentacion = '28 TABLETAS', concentracion = '150/12.5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 60.47, precio = 78.62 where sku = 'FC-5885E577';

-- FC-3D0F54B7 | margen 30% | IBUPRO-CAFE 10 CAPS 400 MG/100 MG
update public.productos set nombre = 'Ibupro-Cafe', marca = 'Ibupro-Cafe', presentacion = '10 CAPSULAS', concentracion = '400 MG/100 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 30.06, precio = 39.08 where sku = 'FC-3D0F54B7';

-- FC-F7A2CACF | margen 30% | INDARZONA 30 CAPS 25/0.5 MG
update public.productos set nombre = 'Indarzona', marca = 'Indarzona', presentacion = '30 CAPSULAS', concentracion = '25/0.5 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 56.3, precio = 73.19 where sku = 'FC-F7A2CACF';

-- FC-50D044FF | margen 30% | WERMY 15 CAPS 300 MG
update public.productos set nombre = 'Wermy', marca = 'Wermy', presentacion = '15 CAPSULAS', concentracion = '300 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 24.51, precio = 31.87 where sku = 'FC-50D044FF';

-- FC-E535DE28 | margen 30% | DIURMESSEL 20 TAB 40 MG
update public.productos set nombre = 'Diurmessel', marca = 'Diurmessel', presentacion = '20 TABLETAS', concentracion = '40 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 9.31, precio = 12.11 where sku = 'FC-E535DE28';

-- FC-1321B34F | margen 30% | HIDROXON 30 TAB 10 MG
update public.productos set nombre = 'Hidroxon', marca = 'Hidroxon', presentacion = '30 TABLETAS', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 34.6, precio = 44.98 where sku = 'FC-1321B34F';

-- FC-1AE9D7E6 | margen 30% | COLLUCORT 1 CMA 1% 60 G
update public.productos set nombre = 'Collucort', marca = 'Collucort', presentacion = '1 CREMA', concentracion = '1% 60 G', forma_farmaceutica = 'CREMA', categoria = 'Otro', tipo = 'marca', costo = 47.85, precio = 62.21 where sku = 'FC-1AE9D7E6';

-- FC-3E863E37 | margen 30% | TRATIDRI 1 GEL 500/50 MG 60 G
update public.productos set nombre = 'Tratidri', marca = 'Tratidri', presentacion = '1 GEL', concentracion = '500/50 MG 60 G', forma_farmaceutica = 'GEL', categoria = 'Otro', tipo = 'marca', costo = 47.47, precio = 61.72 where sku = 'FC-3E863E37';

-- FC-9ABFB996 | margen 30% | ELAPHTERON 20 TAB 100 MG
update public.productos set nombre = 'Elaphteron', marca = 'Elaphteron', presentacion = '20 TABLETAS', concentracion = '100 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 30.77, precio = 40.01 where sku = 'FC-9ABFB996';

-- FC-9A37D44A | margen 30% | AMDORYL 14 CAPS 30 MG
update public.productos set nombre = 'Amdoryl', marca = 'Amdoryl', presentacion = '14 CAPSULAS', concentracion = '30 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 26.11, precio = 33.95 where sku = 'FC-9A37D44A';

-- FC-1BF03D35 | margen 30% | ACETONIDO DE FLUOCINOLONA CMA
update public.productos set nombre = 'Acetonido De Fluocinolona Cma', marca = 'Acetonido', categoria = 'Producto', tipo = 'marca', costo = 18.44, precio = 23.98 where sku = 'FC-1BF03D35';

-- FC-5BC5F234 | margen 60% | FLUCONAZOL 1 CAPS 150 MG
update public.productos set nombre = 'Fluconazol', presentacion = '1 CAPSULAS', principio_activo = 'FLUCONAZOL', concentracion = '150 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', costo = 12.92, precio = 20.68 where sku = 'FC-5BC5F234';

-- FC-A2B284E0 | margen 30% | HIALURONATO DE SODIO 4MG 10 ML
update public.productos set nombre = 'Hialuronato De Sodio 4Mg', marca = 'Hialuronato', presentacion = '10 ML', categoria = 'Producto', tipo = 'marca', costo = 113.89, precio = 148.06 where sku = 'FC-A2B284E0';

-- FC-2E79C2D8 | margen 30% | HIERRO DEX 3 AMP 100 MG/2 ML
update public.productos set nombre = 'Dex', marca = 'Hierro', presentacion = '3 AMPOLLETA', concentracion = '100 MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', costo = 61.33, precio = 79.73 where sku = 'FC-2E79C2D8';

-- FC-28A424E5 | margen 30% | DIZIVER 20 TAB 25 MG
update public.productos set nombre = 'Diziver', marca = 'Diziver', presentacion = '20 TABLETAS', concentracion = '25 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 8.15, precio = 10.6 where sku = 'FC-28A424E5';

-- FC-52D2A43A | margen 30% | ZUKEDIB 30 TAB 2 MG
update public.productos set nombre = 'Zukedib', marca = 'Zukedib', presentacion = '30 TABLETAS', concentracion = '2 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 29.08, precio = 37.81 where sku = 'FC-52D2A43A';

-- FC-3D0ED22B | margen 30% | ZUKEDIB 30 TAB 4 MG
update public.productos set nombre = 'Zukedib', marca = 'Zukedib', presentacion = '30 TABLETAS', concentracion = '4 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 27.98, precio = 36.38 where sku = 'FC-3D0ED22B';

-- FC-04D83B46 | margen 30% | PRALEX 28 TAB 10 MG
update public.productos set nombre = 'Pralex', marca = 'Pralex', presentacion = '28 TABLETAS', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 42.85, precio = 55.71 where sku = 'FC-04D83B46';

-- FC-D11D586A | margen 30% | VALGAB 3 IBE 50MG/6ML
update public.productos set nombre = 'Valgab 3 Ibe /6Ml', marca = 'Valgab', presentacion = '50 MG', categoria = 'Producto', tipo = 'marca', costo = 19.41, precio = 25.24 where sku = 'FC-D11D586A';

-- FC-53506FA4 | margen 60% | ENALAPRIL 30 TAB 10 MG
update public.productos set nombre = 'Enalapril', presentacion = '30 TABLETAS', principio_activo = 'ENALAPRIL', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 8.09, precio = 12.95 where sku = 'FC-53506FA4';

-- FC-F7DB080D | margen 30% | OVISEN 28 TAB 20 MG
update public.productos set nombre = 'Ovisen', marca = 'Ovisen', presentacion = '28 TABLETAS', concentracion = '20 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 20.33, precio = 26.43 where sku = 'FC-F7DB080D';

-- FC-FD92D114 | margen 30% | OVISEN 14 TAB 20 MG
update public.productos set nombre = 'Ovisen', marca = 'Ovisen', presentacion = '14 TABLETAS', concentracion = '20 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 10.19, precio = 13.25 where sku = 'FC-FD92D114';

-- FC-57925EF3 | margen 30% | REGLUSAN 50 TAB 5 MG
update public.productos set nombre = 'Reglusan', marca = 'Reglusan', presentacion = '50 TABLETAS', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 8.88, precio = 11.55 where sku = 'FC-57925EF3';

-- FC-AA7B0686 | margen 30% | DROSQUIM AD 1 IBE 300/160/200 ML
update public.productos set nombre = 'Drosquim Ad 1 Ibe 300/160', marca = 'Drosquim', presentacion = '200 ML', categoria = 'Producto', tipo = 'marca', costo = 70.74, precio = 91.97 where sku = 'FC-AA7B0686';

-- FC-B3B8F9BB | margen 30% | DESROTAN 10 TAB 180 MG
update public.productos set nombre = 'Desrotan', marca = 'Desrotan', presentacion = '10 TABLETAS', concentracion = '180 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 47.31, precio = 61.51 where sku = 'FC-B3B8F9BB';

-- FC-EADF1484 | margen 60% | DIOSMINA HESPERIDINA 20 TAB 450/50 MG
update public.productos set nombre = 'Diosmina Hesperidina', presentacion = '20 TABLETAS', principio_activo = 'DIOSMINA HESPERIDINA', concentracion = '450/50 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 39.41, precio = 63.06 where sku = 'FC-EADF1484';

-- FC-262F2A30 | margen 60% | IRBESARTAN 14 TAB 150 MG
update public.productos set nombre = 'Irbesartan', presentacion = '14 TABLETAS', principio_activo = 'IRBESARTAN', concentracion = '150 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 43.98, precio = 70.37 where sku = 'FC-262F2A30';

-- FC-1DAD5EF1 | margen 30% | TUSILEN AD 1 IBE 240/30/50MG/100/118 ML
update public.productos set nombre = 'Tusilen Ad 1 Ibe 240/30/50Mg/100', marca = 'Tusilen', presentacion = '118 ML', categoria = 'Producto', tipo = 'marca', costo = 24.22, precio = 31.49 where sku = 'FC-1DAD5EF1';

-- FC-BDB2E087 | margen 60% | IRBESARTAN 14 TAB 300 MG
update public.productos set nombre = 'Irbesartan', presentacion = '14 TABLETAS', principio_activo = 'IRBESARTAN', concentracion = '300 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', costo = 70.49, precio = 112.79 where sku = 'FC-BDB2E087';

-- FC-759A5EF9 | margen 30% | WERMY 30 CAPS 300 MG
update public.productos set nombre = 'Wermy', marca = 'Wermy', presentacion = '30 CAPSULAS', concentracion = '300 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 24.89, precio = 32.36 where sku = 'FC-759A5EF9';

-- FC-52844825 | margen 60% | Desod Obao R-Nat Coco R-On 65G
update public.productos set nombre = 'Obao R-Nat Coco', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 29.55, precio = 47.28 where sku = 'FC-52844825';

-- FC-52933307 | margen 60% | Desod Obao Game 48Hr R-On 65G N
update public.productos set nombre = 'Obao Game 48Hr N', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 24.71, precio = 39.54 where sku = 'FC-52933307';

-- FC-27250612 | margen 60% | Desod Obad P/Del R-On 65G
update public.productos set nombre = 'Obao P/Del', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 24.71, precio = 39.54 where sku = 'FC-27250612';

-- FC-27286017 | margen 60% | Desod Obao Clas R-On 65G
update public.productos set nombre = 'Obao Clas', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 45.83, precio = 73.33 where sku = 'FC-27286017';

-- FC-52876406 | margen 60% | Desod Obao Men Tatto Aqua R-On 65G
update public.productos set nombre = 'Obao Men Tatto Aqua', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 45.83, precio = 73.33 where sku = 'FC-52876406';

-- FC-30622622 | margen 60% | Desod Axe Men Young Spy 150Ml
update public.productos set nombre = 'Axe Men Young', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 45.83, precio = 73.33 where sku = 'FC-30622622';

-- FC-06213906 | margen 60% | Desod Axe Icechi E-Frio Spy 150Ml
update public.productos set nombre = 'Axe Icechi E-Frio', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 25.83, precio = 41.33 where sku = 'FC-06213906';

-- FC-93037806 | margen 60% | Desod Rexona Men Marine Spy 150Ml
update public.productos set nombre = 'Rexona Men Marine', marca = 'Rexona', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 62.83, precio = 100.53 where sku = 'FC-93037806';

-- FC-55280956 | margen 60% | Desod Obao Men Tato Rebel R-On65
update public.productos set nombre = 'Obao Men Tato Rebel', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 54.68, precio = 87.49 where sku = 'FC-55280956';

-- FC-93025919 | margen 60% | Desod Axe Excite Seco Spy 152Ml
update public.productos set nombre = 'Axe Excite Seco', marca = 'Axe', presentacion = 'SPRAY 152 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 45.83, precio = 73.33 where sku = 'FC-93025919';

-- FC-93022567 | margen 60% | Desod Rexona Men V8 Tun Spy 90G
update public.productos set nombre = 'Rexona Men V8 Tun Spy', marca = 'Rexona', presentacion = '90 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 51.5, precio = 82.4 where sku = 'FC-93022567';

-- FC-06244795 | margen 60% | Desod Axe Intense 48H Spy 150Ml
update public.productos set nombre = 'Axe Intense 48H', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 54.68, precio = 87.49 where sku = 'FC-06244795';

-- FC-75076009 | margen 60% | Desod Rexona 48H Happy-M Stick 45G
update public.productos set nombre = 'Rexona 48H Happy-M', marca = 'Rexona', presentacion = 'STICK 45 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 53.5, precio = 85.6 where sku = 'FC-75076009';

-- FC-93025797 | margen 60% | Desod Axe Men Dark Temp Spy150Ml
update public.productos set nombre = 'Axe Men Dark Temp', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 53.5, precio = 85.6 where sku = 'FC-93025797';

-- FC-93038223 | margen 60% | Desod Rexona Men Sport Spy 150Ml
update public.productos set nombre = 'Rexona Men Sport', marca = 'Rexona', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 45.83, precio = 73.33 where sku = 'FC-93038223';

-- FC-75062897 | margen 60% | Desod Rexona Bamboo 48H Stick 45G
update public.productos set nombre = 'Rexona Bamboo 48H', marca = 'Rexona', presentacion = 'STICK 45 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 45.83, precio = 73.33 where sku = 'FC-75062897';

-- FC-06245686 | margen 60% | Desod Axe Men Epic-F 48H Spy 150Ml
update public.productos set nombre = 'Axe Men Epic-F 48H', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 45.83, precio = 73.33 where sku = 'FC-06245686';

-- FC-93025865 | margen 60% | Desod Axe Men Gold Temp
update public.productos set nombre = 'Axe Men Gold Temp', marca = 'Axe', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 45.83, precio = 73.33 where sku = 'FC-93025865';

-- FC-22105207 | margen 60% | Jbn Grisi Neutro 150 G
update public.productos set nombre = 'Grisi Neutro', marca = 'Grisi', presentacion = '150 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 20.14, precio = 32.23 where sku = 'FC-22105207';

-- FC-38891190 | margen 60% | Jbn Dove Barra Blanca
update public.productos set nombre = 'Dove Barra Blanca', marca = 'Dove', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 60.54, precio = 96.87 where sku = 'FC-38891190';

-- FC-75062927 | margen 60% | Desod Rexona Pom-Dry48H Stick45G
update public.productos set nombre = 'Rexona Pom-Dry 48 H', marca = 'Rexona', presentacion = 'STICK 45 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 30.21, precio = 48.34 where sku = 'FC-75062927';

-- FC-40036965 | margen 60% | Jbn Asepxia Bicarbon Sod 100G
update public.productos set nombre = 'Asepxia Bicarbon Sod', marca = 'Asepxia', presentacion = '100 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 14.45, precio = 23.12 where sku = 'FC-40036965';

-- FC-40004643 | margen 60% | Jbn Asexia Exfol 100G
update public.productos set nombre = 'Asepxia Exfol', marca = 'Asepxia', presentacion = '100 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 38.66, precio = 61.86 where sku = 'FC-40004643';

-- FC-22150801 | margen 60% | Jbn Grisi Avena 125G
update public.productos set nombre = 'Grisi Avena', marca = 'Grisi', presentacion = '125 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 15.02, precio = 24.04 where sku = 'FC-22150801';

-- FC-25605514 | margen 60% | Jbn Escudo Antibact 110Gr
update public.productos set nombre = 'Escudo Antibact', marca = 'Escudo', presentacion = '110 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 26.75, precio = 42.8 where sku = 'FC-25605514';

-- FC-14119032 | margen 60% | Azufre Jabon C Miel 80
update public.productos set nombre = 'Jabon C Miel 80', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 30.21, precio = 48.34 where sku = 'FC-14119032';

-- FC-06230507 | margen 60% | Jbn Dove Barra Karite Vainill 135G
update public.productos set nombre = 'Dove Barra Karite Vainill', marca = 'Dove', presentacion = '135 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 30.21, precio = 48.34 where sku = 'FC-06230507';

-- FC-22150092 | margen 60% | Jbn Grisi Leche De Burra 125G
update public.productos set nombre = 'Grisi Leche De Burra', marca = 'Grisi', presentacion = '125 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 42.82, precio = 68.52 where sku = 'FC-22150092';

-- FC-22111352 | margen 60% | Jbn Grisi Corp Diabecare 125 G
update public.productos set nombre = 'Grisi Corp Diabecare', marca = 'Grisi', presentacion = '125 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 35.61, precio = 56.98 where sku = 'FC-22111352';

-- FC-75069223 | margen 60% | Desod Rex Mot-Sen Sport Stick
update public.productos set nombre = 'Rexona Mot-Sen Sport Stick', marca = 'Rexona', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 16.7, precio = 26.72 where sku = 'FC-75069223';

-- FC-46059556 | margen 60% | Jbn Liq Palmol N-Bal Dermol 221Mln
update public.productos set nombre = 'Palmolive N-Bal Dermol', marca = 'Palmolive', presentacion = '221 ML', forma_farmaceutica = 'Jabón líquido', categoria = 'Higiene', tipo = 'marca', costo = 52.29, precio = 83.67 where sku = 'FC-46059556';

-- FC-67905186 | margen 60% | Jbn Liq Blumen Coconut Para 221Ml
update public.productos set nombre = 'Blumen Coconut Para', marca = 'Blumen', presentacion = '221 ML', forma_farmaceutica = 'Jabón líquido', categoria = 'Higiene', tipo = 'marca', costo = 128.57, precio = 205.72 where sku = 'FC-67905186';

-- FC-46683133 | margen 60% | Jbn Palmol N-Bal Dermo Limp 120G
update public.productos set nombre = 'Palmolive N-Bal Dermo Limp', marca = 'Palmolive', presentacion = '120 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 8.96, precio = 14.34 where sku = 'FC-46683133';

-- FC-06241206 | margen 60% | Desod Dove Dermac Sk-C 48H Spy150Ml
update public.productos set nombre = 'Dove Dermac Sk-C 48H', marca = 'Dove', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 54.12, precio = 86.6 where sku = 'FC-06241206';

-- FC-43489004 | margen 60% | Jbn Escudo Rosa Prot Y Cuid 110G
update public.productos set nombre = 'Escudo Rosa Prot Y Cuid', marca = 'Escudo', presentacion = '110 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 40.73, precio = 65.17 where sku = 'FC-43489004';

-- FC-42326414 | margen 60% | Agua Mic Garnier De Rosas 400 Ml
update public.productos set nombre = 'Garnier De Rosas', marca = 'Garnier', presentacion = '400 ML', forma_farmaceutica = 'Agua micelar', categoria = 'Cuidado personal', tipo = 'marca', costo = 27.75, precio = 44.41 where sku = 'FC-42326414';

-- FC-76000284 | margen 60% | Agua Mic Vitacilina Ros-Sab 500Mln
update public.productos set nombre = 'Vitacilina Ros-Sab', marca = 'Vitacilina', presentacion = '500 ML', forma_farmaceutica = 'Agua micelar', categoria = 'Cuidado personal', tipo = 'marca', costo = 21.08, precio = 33.73 where sku = 'FC-76000284';

-- FC-82790504 | margen 60% | Desmaq Bifasico Oil Nuvel 125Ml
update public.productos set nombre = 'Nuvel Bifasico Oil', marca = 'Nuvel', presentacion = '125 ML', forma_farmaceutica = 'Desmaquillante', categoria = 'Cuidado personal', tipo = 'marca', costo = 16.7, precio = 26.72 where sku = 'FC-82790504';

-- FC-45722547 | margen 60% | Agua Mice Natural-G Bifasic 120Ml
update public.productos set nombre = 'Natural-G Bifasic', presentacion = '120 ML', forma_farmaceutica = 'Agua micelar', categoria = 'Cuidado personal', tipo = 'marca', costo = 37.72, precio = 60.36 where sku = 'FC-45722547';

-- FC-67905131 | margen 60% | Jbn Liq Blumen Cherry Bloss 221Ml
update public.productos set nombre = 'Blumen Cherry Bloss', marca = 'Blumen', presentacion = '221 ML', forma_farmaceutica = 'Jabón líquido', categoria = 'Higiene', tipo = 'marca', costo = 17.78, precio = 28.45 where sku = 'FC-67905131';

-- FC-21012303 | margen 60% | Tas Hum Claris Desmaq Aloe C/40
update public.productos set nombre = 'Claris Desmaq Aloe', marca = 'Claris', presentacion = 'C/40', forma_farmaceutica = 'Toallas húmedas', categoria = 'Higiene', tipo = 'marca', costo = 14.78, precio = 23.65 where sku = 'FC-21012303';

-- FC-14121782 | margen 60% | Jabon De Proteina De Arroz Y Concha Nacar 8
update public.productos set nombre = 'De Proteina De Arroz Y Concha Nacar 8', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 167.69, precio = 268.31 where sku = 'FC-14121782';

-- FC-25652716 | margen 60% | Jbn Escudo Azul Rey 135G
update public.productos set nombre = 'Escudo Azul Rey', marca = 'Escudo', presentacion = '135 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 73.65, precio = 117.85 where sku = 'FC-25652716';

-- FC-06248052 | margen 60% | Deo Aero Dove Tono Uniforme 150Ml 3Pack
update public.productos set nombre = 'Dove Aero Tono Uniforme 3Pack', marca = 'Dove', presentacion = '150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 147.3, precio = 235.69 where sku = 'FC-06248052';

-- FC-06248045 | margen 60% | Deo Dove Spy Invisible Dry 150Ml C3
update public.productos set nombre = 'Dove Spy Invisible Dry C3', marca = 'Dove', presentacion = '150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 129.46, precio = 207.14 where sku = 'FC-06248045';

-- FC-35911208 | margen 60% | Jbn Liq Palmol Aquarium 221Ml
update public.productos set nombre = 'Palmolive Aquarium', marca = 'Palmolive', presentacion = '221 ML', forma_farmaceutica = 'Jabón líquido', categoria = 'Higiene', tipo = 'marca', costo = 45.83, precio = 73.33 where sku = 'FC-35911208';

-- FC-08837311 | margen 60% | Desod Nivea Pearlb Mspy150Ml
update public.productos set nombre = 'Nivea Pearlb Mspy', marca = 'Nivea', presentacion = '150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 12.54, precio = 20.07 where sku = 'FC-08837311';

-- FC-06209862 | margen 60% | Deo Axe Spy 150Ml 48H Anarchy Fresh Love Fo
update public.productos set nombre = 'Axe 48H Anarchy Fresh Love Fo', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 16.87, precio = 27.0 where sku = 'FC-06209862';

-- FC-43489165 | margen 60% | Jbn Liq Escudo Blanco Neut 225Ml
update public.productos set nombre = 'Escudo Blanco Neut', marca = 'Escudo', presentacion = '225 ML', forma_farmaceutica = 'Jabón líquido', categoria = 'Higiene', tipo = 'marca', costo = 45.83, precio = 73.33 where sku = 'FC-43489165';

-- FC-84900280 | margen 60% | Jaloma Agua De Rosas 130Ml Spray
update public.productos set nombre = 'Jaloma Spray', marca = 'Jaloma', presentacion = '130 ML', forma_farmaceutica = 'Agua de rosas', categoria = 'Cuidado personal', tipo = 'marca', costo = 23.79, precio = 38.07 where sku = 'FC-84900280';

-- FC-06226852 | margen 60% | Desod Axe Wom Anarchy Spy 150Ml
update public.productos set nombre = 'Axe Wom Anarchy', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 88.8, precio = 142.09 where sku = 'FC-06226852';

-- FC-46657035 | margen 60% | Jbn Lio Palmol Flor Czo-Rsa 221Ml
update public.productos set nombre = 'Lio Flor Czo-Rsa', marca = 'Lio', presentacion = '221 ML', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 45.83, precio = 73.33 where sku = 'FC-46657035';

-- FC-56330378 | margen 60% | Loc Limp Ponds Bio-Hydra Dual 200Ml
update public.productos set nombre = 'Ponds Bio-Hydra Dual', marca = 'Ponds', presentacion = '200 ML', forma_farmaceutica = 'Loción limpiadora', categoria = 'Cuidado personal', tipo = 'marca', costo = 28.1, precio = 44.97 where sku = 'FC-56330378';

-- FC-76040436 | margen 60% | Deo Mexsana P/Pies Spy 150Ml
update public.productos set nombre = 'Mexsana P/Pies', marca = 'Mexsana', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 49.29, precio = 78.87 where sku = 'FC-76040436';

-- FC-61113000 | margen 60% | Tco Desod Odolex
update public.productos set nombre = 'Odolex Desod', marca = 'Odolex', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', costo = 31.77, precio = 50.84 where sku = 'FC-61113000';

-- FC-61123009 | margen 60% | Odolex Naturals 300Gr Talco Desodorante
update public.productos set nombre = 'Odolex Naturals Talco Desodorante', marca = 'Odolex', presentacion = '300 G', tipo = 'marca', costo = 23.99, precio = 38.39 where sku = 'FC-61123009';

-- FC-41500096 | margen 60% | Tiraleche De Cristal 1 Pza
update public.productos set nombre = 'De Cristal', presentacion = '1 PZA', forma_farmaceutica = 'Tiraleche', categoria = 'Botiquín', tipo = 'marca', costo = 80.46, precio = 128.74 where sku = 'FC-41500096';

-- FC-20500201 | margen 60% | Sh Pert Plus Ac-Oliva 400Ml
update public.productos set nombre = 'Pert Plus Ac-Oliva', marca = 'Pert', presentacion = '400 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 64.12, precio = 102.6 where sku = 'FC-20500201';

-- FC-72300171 | margen 60% | Ting Polvo 85G
update public.productos set nombre = 'Polvo', presentacion = '85 G', forma_farmaceutica = 'Polvo', categoria = 'Cuidado personal', tipo = 'marca', costo = 43.58, precio = 69.73 where sku = 'FC-72300171';

-- FC-06217461 | margen 60% | Ico Desod Rexona Effi Fresh 200G
update public.productos set nombre = 'Rexona Effi Fresh', marca = 'Rexona', presentacion = '200 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 43.58, precio = 69.73 where sku = 'FC-06217461';

-- FC-82740011 | margen 60% | Quita Esm Nuvel Humec 125Ml
update public.productos set nombre = 'Nuvel Humec', marca = 'Nuvel', presentacion = '125 ML', forma_farmaceutica = 'Quita esmalte', categoria = 'Cuidado personal', tipo = 'marca', costo = 43.58, precio = 69.73 where sku = 'FC-82740011';

-- FC-52910971 | margen 60% | Cra Fructis Pei B-Dano Quim 300Ml
update public.productos set nombre = 'Fructis Pei B-Dano Quim', marca = 'Fructis', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 78.22, precio = 125.16 where sku = 'FC-52910971';

-- FC-52816297 | margen 60% | Cra Fructis Pei Oil-R L-Coco 300Ml
update public.productos set nombre = 'Fructis Pei Oil-R L-Coco', marca = 'Fructis', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 63.05, precio = 100.88 where sku = 'FC-52816297';

-- FC-40025839 | margen 60% | Sh Int Lomecan V 200Ml
update public.productos set nombre = 'Lomecan V', marca = 'Lomecan', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 17.2, precio = 27.52 where sku = 'FC-40025839';

-- FC-40030338 | margen 60% | Sh Int Lomecan V Aclar 200Ml
update public.productos set nombre = 'Lomecan V Aclar', marca = 'Lomecan', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 41.84, precio = 66.95 where sku = 'FC-40030338';

-- FC-45720550 | margen 60% | Silkhair Quita Esmalte Mora Azul 100Ml
update public.productos set nombre = 'Quita Esmalte Mora Azul', presentacion = '100 ML', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', costo = 41.84, precio = 66.95 where sku = 'FC-45720550';

-- FC-92511261 | margen 60% | Cra Nutribela1O Bio Colageno 300Gn
update public.productos set nombre = 'Nutribela Bio Colageno', marca = 'Nutribela', presentacion = '300 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 29.31, precio = 46.9 where sku = 'FC-92511261';

-- FC-92509213 | margen 60% | Cra Nutribela Nutrice Tarro 300G
update public.productos set nombre = 'Nutribela Nutrice Tarro', marca = 'Nutribela', presentacion = '300 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 40.24, precio = 64.39 where sku = 'FC-92509213';

-- FC-06257597 | margen 60% | Rexona 1O0Gr Tco Pies Efficient Orig
update public.productos set nombre = 'Rexona 1O0 G Tco Pies Efficient Orig', marca = 'Rexona', tipo = 'marca', costo = 75.7, precio = 121.12 where sku = 'FC-06257597';

-- FC-46073156 | margen 60% | Sh Caprice Nat Mzna 380 Ml
update public.productos set nombre = 'Caprice Nat Mzna', marca = 'Caprice', presentacion = '380 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 75.7, precio = 121.12 where sku = 'FC-46073156';

-- FC-20500171 | margen 60% | Cra Pert Oliv+Ac Agu P/Pein 100 Ml
update public.productos set nombre = 'Pert Oliv+Ac Agu P/Pein', marca = 'Pert', presentacion = '100 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 25.04, precio = 40.07 where sku = 'FC-20500171';

-- FC-35155922 | margen 60% | Ac Pantene Bambu 400Ml
update public.productos set nombre = 'Pantene Bambu', marca = 'Pantene', presentacion = '400 ML', forma_farmaceutica = 'Acondicionador', categoria = 'Higiene', tipo = 'marca', costo = 15.7, precio = 25.12 where sku = 'FC-35155922';

-- FC-07457826 | margen 60% | Acono Pant Brillo Extremo 40Cml
update public.productos set nombre = 'Pantene Brillo Extremo', marca = 'Pantene', presentacion = '40 ML', forma_farmaceutica = 'Acondicionador', categoria = 'Higiene', tipo = 'marca', costo = 75.7, precio = 121.12 where sku = 'FC-07457826';

-- FC-56340131 | margen 60% | Cra Sedal Rizos Obedie 300Ml
update public.productos set nombre = 'Sedal Rizos Obedie', marca = 'Sedal', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 19.11, precio = 30.58 where sku = 'FC-56340131';

-- FC-01165321 | margen 60% | Acond Pant Rizos Definid 400Ml
update public.productos set nombre = 'Pantene Acond Rizos Definid', marca = 'Pantene', presentacion = '400 ML', tipo = 'marca', costo = 71.8, precio = 114.88 where sku = 'FC-01165321';

-- FC-06249783 | margen 60% | Sh Sedal Rizos Def Inf-Act 180Ml
update public.productos set nombre = 'Sedal Rizos Def Inf-Act', marca = 'Sedal', presentacion = '180 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 50.07, precio = 80.12 where sku = 'FC-06249783';

-- FC-56360429 | margen 60% | Tco Desod Eficc Pies 200 G
update public.productos set nombre = 'Desod Eficc Pies', presentacion = '200 G', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', costo = 36.33, precio = 58.13 where sku = 'FC-56360429';

-- FC-56340025 | margen 60% | Cra Sedal Sos Recon-Estru 300Ml
update public.productos set nombre = 'Sedal Sos Recon-Estru', marca = 'Sedal', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 18.88, precio = 30.21 where sku = 'FC-56340025';

-- FC-56342227 | margen 60% | Cra Sedal Rizos Obedientes 135Ml
update public.productos set nombre = 'Sedal Rizos Obedientes', marca = 'Sedal', presentacion = '135 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 8.24, precio = 13.19 where sku = 'FC-56342227';

-- FC-06249776 | margen 60% | Sh Sedal Ceramidas Inf-Act 180Ml
update public.productos set nombre = 'Sedal Ceramidas Inf-Act', marca = 'Sedal', presentacion = '180 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 75.7, precio = 121.12 where sku = 'FC-06249776';

-- FC-01303454 | margen 60% | Sh Pant Ctrcaida A/Pv 400Ml
update public.productos set nombre = 'Pantene Ctrcaida A/Pv', marca = 'Pantene', presentacion = '400 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 40.66, precio = 65.06 where sku = 'FC-01303454';

-- FC-07457796 | margen 60% | Sh Pant Brillo Extremo
update public.productos set nombre = 'Pantene Brillo Extremo', marca = 'Pantene', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 75.7, precio = 121.12 where sku = 'FC-07457796';

-- FC-35155847 | margen 60% | Sh Pant Bambu Ctrl Caida 400 Ml
update public.productos set nombre = 'Pantene Bambu Ctrl Caida', marca = 'Pantene', presentacion = '400 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 40.66, precio = 65.06 where sku = 'FC-35155847';

-- FC-06249240 | margen 60% | Sh Savile Ker-Sab Fza Repar 700Ml
update public.productos set nombre = 'Savile Ker-Sab Fza Repar', marca = 'Savile', presentacion = '700 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 44.76, precio = 71.62 where sku = 'FC-06249240';

-- FC-06249226 | margen 60% | Sh Savile Bio-Sab Creci Res 700Ml
update public.productos set nombre = 'Savile Bio-Sab Creci Res', marca = 'Savile', presentacion = '700 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 50.07, precio = 80.12 where sku = 'FC-06249226';

-- FC-24511629 | margen 60% | Silica Shine Sil 3/1 Uva 120 Mi
update public.productos set marca = 'Silica Shine', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', costo = 18.17, precio = 29.08 where sku = 'FC-24511629';

-- FC-06234062 | margen 60% | Cra Sedal Anti Nudos 300 Ml
update public.productos set nombre = 'Sedal Anti Nudos', marca = 'Sedal', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 17.77, precio = 28.44 where sku = 'FC-06234062';

-- FC-56342258 | margen 60% | Cra Sedal Recons Estructur 135Ml
update public.productos set nombre = 'Sedal Recons Estructur', marca = 'Sedal', presentacion = '135 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 17.77, precio = 28.44 where sku = 'FC-56342258';

-- FC-61111501 | margen 60% | Tco Desdo Odolex 150 G
update public.productos set nombre = 'Odolex Desdo', marca = 'Odolex', presentacion = '150 G', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', costo = 50.07, precio = 80.12 where sku = 'FC-61111501';

-- FC-61124013 | margen 60% | Tco Odolex Fresh 150G
update public.productos set nombre = 'Odolex Fresh', marca = 'Odolex', presentacion = '150 G', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', costo = 73.76, precio = 118.02 where sku = 'FC-61124013';

-- FC-56340124 | margen 60% | Cra Sedal Sos Ceramida 300Ml
update public.productos set nombre = 'Sedal Sos Ceramida', marca = 'Sedal', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 57.9, precio = 92.64 where sku = 'FC-56340124';

-- FC-35020008 | margen 60% | Sh Hbs Limp Renoy 375Ml
update public.productos set nombre = 'Herbal Essences Limp Renoy', marca = 'Herbal Essences', presentacion = '375 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 57.9, precio = 92.64 where sku = 'FC-35020008';

-- FC-35169035 | margen 60% | Mousse Herbal Ess Rizo 200G
update public.productos set nombre = 'Herbal Essences Rizo', marca = 'Herbal Essences', presentacion = '200 G', forma_farmaceutica = 'Mousse capilar', categoria = 'Higiene', tipo = 'marca', costo = 73.76, precio = 118.02 where sku = 'FC-35169035';

-- FC-35168991 | margen 60% | Sh Hash Anti Comezon 375Ml
update public.productos set nombre = 'Hask Anti Comezon', marca = 'Hask', presentacion = '375 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 32.34, precio = 51.75 where sku = 'FC-35168991';

-- FC-35231237 | margen 60% | Sh Hash Anti Comezon 375Ml
update public.productos set nombre = 'Hask Anti Comezon', marca = 'Hask', presentacion = '375 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 36.73, precio = 58.77 where sku = 'FC-35231237';

-- FC-92504539 | margen 60% | Cera Mod Ego Met 25 G
update public.productos set nombre = 'Ego Mod Met', marca = 'Ego', presentacion = '25 G', forma_farmaceutica = 'Cera capilar', categoria = 'Higiene', tipo = 'marca', costo = 36.73, precio = 58.77 where sku = 'FC-92504539';

-- FC-38312374 | margen 60% | Cera Gel Moco De Gorila Citr 100G
update public.productos set nombre = 'Moco de Gorila Gel Citr', marca = 'Moco de Gorila', presentacion = '100 G', forma_farmaceutica = 'Cera capilar', categoria = 'Higiene', tipo = 'marca', costo = 24.91, precio = 39.86 where sku = 'FC-38312374';

-- FC-35231244 | margen 60% | Sh H&S Anti Comezon 180 Ml
update public.productos set nombre = 'Head & Shoulders Anti Comezon', marca = 'Head & Shoulders', presentacion = '180 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 18.39, precio = 29.43 where sku = 'FC-35231244';

-- FC-35020077 | margen 60% | Sh Hbs Alivio Instant
update public.productos set nombre = 'Herbal Essences Alivio Instant', marca = 'Herbal Essences', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 45.23, precio = 72.37 where sku = 'FC-35020077';

-- FC-92503558 | margen 60% | Gel Ego Magnetic Fij-Alta 200 Ml
update public.productos set nombre = 'Ego Magnetic Fij-Alta', marca = 'Ego', presentacion = '200 ML', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', costo = 56.61, precio = 90.58 where sku = 'FC-92503558';

-- FC-99425580 | margen 60% | Gel X-Extreme Titan 250G
update public.productos set nombre = 'X-Treme Titan', marca = 'X-Treme', presentacion = '250 G', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', costo = 7.37, precio = 11.8 where sku = 'FC-99425580';

-- FC-99428024 | margen 60% | Gel Moco De Gorila Punk 80 G
update public.productos set nombre = 'Moco de Gorila Punk', marca = 'Moco de Gorila', presentacion = '80 G', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', costo = 7.37, precio = 11.8 where sku = 'FC-99428024';

-- FC-46073040 | margen 60% | Sh Caprice Sp Biotina Fza 200Ml
update public.productos set nombre = 'Caprice Sp Biotina Fza', marca = 'Caprice', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 45.26, precio = 72.42 where sku = 'FC-46073040';

-- FC-46073033 | margen 60% | Sh Caprice Sp Acti Ceramida 200Ml
update public.productos set nombre = 'Caprice Sp Acti Ceramida', marca = 'Caprice', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 45.26, precio = 72.42 where sku = 'FC-46073033';

-- FC-54073302 | margen 60% | Silica Shine Sily Oleo Argan 120Ml
update public.productos set nombre = 'Silica Shine Sily Oleo Argan', marca = 'Silica Shine', presentacion = '120 ML', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', costo = 44.76, precio = 71.62 where sku = 'FC-54073302';

-- FC-24511711 | margen 60% | Silica Shine Sily 3/1 Mora 120Ml
update public.productos set nombre = 'Silica Shine Sily 3/1 Mora', marca = 'Silica Shine', presentacion = '120 ML', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', costo = 45.64, precio = 73.03 where sku = 'FC-24511711';

-- FC-24511636 | margen 60% | Silica Shine Sily 3/1 Naran 12Cml
update public.productos set nombre = 'Silica Shine Sily 3/1 Naran', marca = 'Silica Shine', presentacion = '12 ML', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', costo = 50.51, precio = 80.82 where sku = 'FC-24511636';

-- FC-75001865 | margen 60% | Brill Palmol Lio 115M
update public.productos set nombre = 'Lio 115M', marca = 'Lio', forma_farmaceutica = 'Brillantine', categoria = 'Higiene', tipo = 'marca', costo = 17.54, precio = 28.07 where sku = 'FC-75001865';

-- FC-46655055 | margen 60% | Mousse Caprice Volum-Cirl 200 G
update public.productos set nombre = 'Caprice Volum-Cirl', marca = 'Caprice', presentacion = '200 G', forma_farmaceutica = 'Mousse capilar', categoria = 'Higiene', tipo = 'marca', costo = 20.02, precio = 32.04 where sku = 'FC-46655055';

-- FC-06247468 | margen 60% | Gel Ego Fresh C-Cas Fij-Alt 200Ml
update public.productos set nombre = 'Ego Fresh C-Cas Fij-Alt', marca = 'Ego', presentacion = '200 ML', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', costo = 62.04, precio = 99.27 where sku = 'FC-06247468';

-- FC-92506601 | margen 60% | Gel Ego For Men Attraction 200 Ml
update public.productos set nombre = 'Ego For Men Attraction', marca = 'Ego', presentacion = '200 ML', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', costo = 17.98, precio = 28.77 where sku = 'FC-92506601';

-- FC-86494262 | margen 60% | Cep Dent Oral-B Indicat35Sve
update public.productos set nombre = 'Oral-B Indicat35Sve', marca = 'Oral-B', forma_farmaceutica = 'Cepillo dental', categoria = 'Higiene', tipo = 'marca', costo = 8.6, precio = 13.76 where sku = 'FC-86494262';

-- FC-92506045 | margen 60% | Cera Ego Firme Matte 25 G
update public.productos set nombre = 'Ego Firme Matte', marca = 'Ego', presentacion = '25 G', forma_farmaceutica = 'Cera capilar', categoria = 'Higiene', tipo = 'marca', costo = 17.2, precio = 27.52 where sku = 'FC-92506045';

-- FC-84431050 | margen 60% | Acetona Jaloma 60 Ml
update public.productos set nombre = 'Jaloma', marca = 'Jaloma', presentacion = '60 ML', forma_farmaceutica = 'Acetona', categoria = 'Cuidado personal', tipo = 'marca', costo = 19.77, precio = 31.64 where sku = 'FC-84431050';

-- FC-45720567 | margen 60% | Silkhair Quita Esmalte Coco 100 Ml
update public.productos set nombre = 'Quita Esmalte Coco', presentacion = '100 ML', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', costo = 2.75, precio = 4.41 where sku = 'FC-45720567';

-- FC-84437151 | margen 60% | Acetona Jaloma 120 Ml
update public.productos set nombre = 'Jaloma', marca = 'Jaloma', presentacion = '120 ML', forma_farmaceutica = 'Acetona', categoria = 'Cuidado personal', tipo = 'marca', costo = 2.75, precio = 4.41 where sku = 'FC-84437151';

-- FC-48640775 | margen 60% | Protec Tocmx2.75M 1 Pza Venda De Yeso C12
update public.productos set nombre = 'Tocmx2.75M Venda De Yeso C12', presentacion = '1 PZA', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', costo = 2.75, precio = 4.41 where sku = 'FC-48640775';

-- FC-48640799 | margen 60% | Protec 15Cmx2.75M 1 Pza Venda De Yeso C12
update public.productos set nombre = '15Cmx2.75M Venda De Yeso C12', presentacion = '1 PZA', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', costo = 2.75, precio = 4.41 where sku = 'FC-48640799';

-- FC-46640629 | margen 60% | Protec 20Cmx2.75M 1 Pza Venda De Yeso
update public.productos set nombre = '20Cmx2.75M Venda De Yeso', presentacion = '1 PZA', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', costo = 61.02, precio = 97.64 where sku = 'FC-46640629';

-- FC-48640751 | margen 60% | Protec 5Cmx2.75M 1 Pza Venda De Yeso C12 Pz
update public.productos set nombre = '5Cmx2.75M Venda De Yeso C12 Pz', presentacion = '1 PZA', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', costo = 147.15, precio = 235.45 where sku = 'FC-48640751';

-- FC-26462078 | margen 60% | Ternura Flor-Balon 18 Pzs Chupon Con Miel
update public.productos set marca = 'Ternura', tipo = 'marca', costo = 47.79, precio = 76.47 where sku = 'FC-26462078';

-- FC-54500216 | margen 60% | Cra Nivea Sdatarr Giga 400Ml
update public.productos set nombre = 'Nivea Sdatarr Giga', marca = 'Nivea', presentacion = '400 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 42.25, precio = 67.61 where sku = 'FC-54500216';

-- FC-75064938 | margen 60% | Desod Ego Force 24H R-On 45Ml Dic26
update public.productos set nombre = 'Ego Force 24H R-On Dic26', marca = 'Ego', presentacion = '45 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 42.24, precio = 67.59 where sku = 'FC-75064938';

-- FC-20501673 | margen 60% | Cra Hinds Liq Agave Azul 400Ml
update public.productos set nombre = 'Hinds Liq Agave Azul', marca = 'Hinds', presentacion = '400 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 59.81, precio = 95.7 where sku = 'FC-20501673';

-- FC-08802838 | margen 60% | Cra Nivea B Sofmilk Sec400Ml
update public.productos set nombre = 'Nivea B Sofmilk Sec400 Ml', marca = 'Nivea', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 43.63, precio = 69.81 where sku = 'FC-08802838';

-- FC-36040450 | margen 60% | Cra Grisi Conchnac P/Manos 80 Ml
update public.productos set nombre = 'Grisi Conchnac P/Manos', marca = 'Grisi', presentacion = '80 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 86.77, precio = 138.84 where sku = 'FC-36040450';

-- FC-56330309 | margen 60% | Cra Clarant B3 Nml/Gsa 100G
update public.productos set nombre = 'Clariant B3 Nml/Gsa', marca = 'Clariant', presentacion = '100 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 105.35, precio = 168.56 where sku = 'FC-56330309';

-- FC-42270027 | margen 60% | Cra Nivea Cuidada Clar-Nat 200Ml
update public.productos set nombre = 'Nivea Cuidada Clar-Nat', marca = 'Nivea', presentacion = '200 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 85.87, precio = 137.4 where sku = 'FC-42270027';

-- FC-00942760 | margen 60% | Gel Niv Fac Ref Hidra Hyalu 200Ml
update public.productos set nombre = 'Niv Fac Ref Hidra Hyalu', presentacion = '200 ML', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', costo = 62.25, precio = 99.6 where sku = 'FC-00942760';

-- FC-54558682 | margen 60% | Cra Corp Niveamilk 400Ml+Cra100Ml
update public.productos set nombre = 'Corp Niveamilk +Cra100 Ml', presentacion = '400 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 22.3, precio = 35.68 where sku = 'FC-54558682';

-- FC-40030963 | margen 60% | Cra Teatrical Cel-Ma Nutrit 400Ml
update public.productos set nombre = 'Teatrical Cel-Ma Nutrit', marca = 'Teatrical', presentacion = '400 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 34.41, precio = 55.06 where sku = 'FC-40030963';

-- FC-26462061 | margen 60% | Chupon Ternura Ortodontic Miel C3
update public.productos set nombre = 'Ternura Ortodontic Miel C3', marca = 'Ternura', forma_farmaceutica = 'Chupón', categoria = 'Bebés', tipo = 'marca', costo = 74.31, precio = 118.9 where sku = 'FC-26462061';

-- FC-35469151 | margen 60% | Cra Lubriderm Uv Fps15 120Ml
update public.productos set nombre = 'Lubriderm Uv Fps15', marca = 'Lubriderm', presentacion = '120 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 15.51, precio = 24.82 where sku = 'FC-35469151';

-- FC-36032776 | margen 60% | Sh Grisi Ricitos Oro Biopure 250Ml
update public.productos set nombre = 'Ricitos de Oro Oro Biopure', marca = 'Ricitos de Oro', presentacion = '250 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 29.96, precio = 47.94 where sku = 'FC-36032776';

-- FC-07502441 | margen 60% | Jbn Johnson'S Baby Antes/Dor 75 G
update public.productos set nombre = 'Johnson S Baby Antes/Dor', marca = 'Johnson', presentacion = '75 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 20.65, precio = 33.04 where sku = 'FC-07502441';

-- FC-46655079 | margen 60% | Jbn Palmol N-Bal Corp Baby0% 90G
update public.productos set nombre = 'Palmolive N-Bal Corp Baby0%', marca = 'Palmolive', presentacion = '90 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 19.95, precio = 31.92 where sku = 'FC-46655079';

-- FC-82790016 | margen 60% | Tco Nuvel Protec Pura Para Bebe200G
update public.productos set nombre = 'Nuvel Pura Para Bebe200 G', marca = 'Nuvel', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', costo = 39.9, precio = 63.84 where sku = 'FC-82790016';

-- FC-36041402 | margen 60% | Cra Hinds Hidr-Extr Almendras 500Ml
update public.productos set nombre = 'Hinds Hidr-Extr Almendras', marca = 'Hinds', presentacion = '500 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 31.59, precio = 50.55 where sku = 'FC-36041402';

-- FC-07528939 | margen 60% | Cra Lubriderm Thint Psec120Ml
update public.productos set nombre = 'Lubriderm Thint Psec120 Ml', marca = 'Lubriderm', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 49.97, precio = 79.96 where sku = 'FC-07528939';

-- FC-31244486 | margen 60% | Cra Lubriderm P/Normal 120Ml
update public.productos set nombre = 'Lubriderm P/Normal', marca = 'Lubriderm', presentacion = '120 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 43.59, precio = 69.75 where sku = 'FC-31244486';

-- FC-46074504 | margen 60% | Sh Mennen Zero% Sve 400Ml
update public.productos set nombre = 'Mennen Zero% Sve', marca = 'Mennen', presentacion = '400 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 66.93, precio = 107.09 where sku = 'FC-46074504';

-- FC-36033735 | margen 60% | Sh Ricitos Oro Agua De Coco 250Ml
update public.productos set nombre = 'Ricitos de Oro Oro Agua De Coco', marca = 'Ricitos de Oro', presentacion = '250 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 66.93, precio = 107.09 where sku = 'FC-36033735';

-- FC-46650708 | margen 60% | Sh Mennen Lavan-Extrac Aven 200Ml
update public.productos set nombre = 'Mennen Lavan-Extrac Aven', marca = 'Mennen', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 53.99, precio = 86.39 where sku = 'FC-46650708';

-- FC-22133286 | margen 60% | Sh Grisi Rici Oro Miel 250Ml
update public.productos set nombre = 'Grisi Rici Oro Miel', marca = 'Grisi', presentacion = '250 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 70.91, precio = 113.46 where sku = 'FC-22133286';

-- FC-86472048 | margen 60% | Cep Dent Accion Mayo Alcan Somed
update public.productos set nombre = 'Alcanforada Mayo Somed', marca = 'Alcanforada', forma_farmaceutica = 'Cepillo dental', categoria = 'Higiene', tipo = 'marca', costo = 35.45, precio = 56.73 where sku = 'FC-86472048';

-- FC-09498091 | margen 60% | Sensodyne Protec Complet + Acc Lim Efec 90G
update public.productos set nombre = 'Sensodyne Complet + Acc Lim Efec', marca = 'Sensodyne', presentacion = '90 G', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', costo = 48.58, precio = 77.73 where sku = 'FC-09498091';

-- FC-95129166 | margen 60% | Cep Dent Oral-B 3Dw Advant Med2X1
update public.productos set nombre = 'Oral-B 3Dw Advant Med2X1', marca = 'Oral-B', forma_farmaceutica = 'Cepillo dental', categoria = 'Higiene', tipo = 'marca', costo = 70.91, precio = 113.46 where sku = 'FC-95129166';

-- FC-42417644 | margen 60% | Cra Nivea Cuidado Int P/Mano 75Ml
update public.productos set nombre = 'Nivea Cuidado Int P/Mano', marca = 'Nivea', presentacion = '75 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 30.36, precio = 48.58 where sku = 'FC-42417644';

-- FC-09419324 | margen 60% | Cd Sensodyne Original
update public.productos set nombre = 'Sensodyne Original', marca = 'Sensodyne', forma_farmaceutica = 'Crema dental', categoria = 'Higiene', tipo = 'marca', costo = 26.38, precio = 42.21 where sku = 'FC-09419324';

-- FC-40013898 | margen 60% | Cra Teatrical Lanol/Ros 52Gr
update public.productos set nombre = 'Teatrical Lanol/Ros', marca = 'Teatrical', presentacion = '52 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 26.3, precio = 42.09 where sku = 'FC-40013898';

-- FC-54549819 | margen 60% | Cra Corp Niv Soft M P/Seca 100Ml
update public.productos set nombre = 'Corp Niv Soft M P/Seca', presentacion = '100 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 26.3, precio = 42.09 where sku = 'FC-54549819';

-- FC-17360604 | margen 60% | Tas San Kotex Ant Flujo Abundante S/A 10Pz
update public.productos set nombre = 'Kotex Ant Flujo Abundante S/A 10Pz', marca = 'Kotex', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', costo = 10.4, precio = 16.64 where sku = 'FC-17360604';

-- FC-46072050 | margen 60% | Sh Mennen Miel-Mza Sve 200Ml
update public.productos set nombre = 'Mennen Miel-Mza Sve', marca = 'Mennen', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', costo = 20.8, precio = 33.28 where sku = 'FC-46072050';

-- FC-22150221 | margen 60% | Jbn Ricitos D Oro Neutro 90 G
update public.productos set nombre = 'Ricitos de Oro Neutro', marca = 'Ricitos de Oro', presentacion = '90 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 59.36, precio = 94.98 where sku = 'FC-22150221';

-- FC-20501765 | margen 60% | Cra Grisi Aloe Vera P/Manos 80 Mln
update public.productos set nombre = 'Grisi Aloe Vera P/Manos', marca = 'Grisi', presentacion = '80 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 26.48, precio = 42.37 where sku = 'FC-20501765';

-- FC-56326142 | margen 60% | Cra S Ponds Humectante 100G
update public.productos set nombre = 'Ponds S Humectante', marca = 'Ponds', presentacion = '100 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 26.48, precio = 42.37 where sku = 'FC-56326142';

-- FC-48691005 | margen 60% | Protec Tensolastic Plus 10Cmx5M Venda Elast
update public.productos set nombre = 'Tensolastic Plus Venda Elast', presentacion = '10 CM x 5 M', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', costo = 20.02, precio = 32.04 where sku = 'FC-48691005';

-- FC-31976394 | margen 60% | Enj Buc List Anticari-Al 250Ml
update public.productos set nombre = 'Listerine Anticari-Al', marca = 'Listerine', presentacion = '250 ML', forma_farmaceutica = 'Enjuague bucal', categoria = 'Higiene', tipo = 'marca', costo = 30.02, precio = 48.04 where sku = 'FC-31976394';

-- FC-43427754 | margen 60% | Tas Sanit Kotex Nat Flex Noct C/5
update public.productos set nombre = 'Kotex Nat Flex Noct', marca = 'Kotex', presentacion = 'C/5', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', costo = 31.77, precio = 50.84 where sku = 'FC-43427754';

-- FC-31887928 | margen 60% | Enj Buc List Care Zero Mta 250Ml
update public.productos set nombre = 'Listerine Care Zero Mta', marca = 'Listerine', presentacion = '250 ML', forma_farmaceutica = 'Enjuague bucal', categoria = 'Higiene', tipo = 'marca', costo = 26.2, precio = 41.92 where sku = 'FC-31887928';

-- FC-54503095 | margen 60% | Cra Nivea Sda Tarro 100 Ml
update public.productos set nombre = 'Nivea Sda Tarro', marca = 'Nivea', presentacion = '100 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 96.63, precio = 154.61 where sku = 'FC-54503095';

-- FC-85800198 | margen 60% | Tas Hum Th Bebin Super C/80
update public.productos set nombre = 'Huggies Super', marca = 'Huggies', presentacion = 'C/80', forma_farmaceutica = 'Toallas húmedas', categoria = 'Higiene', tipo = 'marca', costo = 36.3, precio = 58.08 where sku = 'FC-85800198';

-- FC-72629012 | margen 60% | Cep Dent Clinic Adulto Med 40 C12
update public.productos set nombre = 'Colgate Adulto Med 40 C12', marca = 'Colgate', forma_farmaceutica = 'Cepillo dental', categoria = 'Higiene', tipo = 'marca', costo = 36.3, precio = 58.08 where sku = 'FC-72629012';

-- FC-10974329 | margen 60% | Enj Buc List Zero Mta Sve 250Ml
update public.productos set nombre = 'Listerine Zero Mta Sve', marca = 'Listerine', presentacion = '250 ML', forma_farmaceutica = 'Enjuague bucal', categoria = 'Higiene', tipo = 'marca', costo = 12.97, precio = 20.76 where sku = 'FC-10974329';

-- FC-00701992 | margen 60% | Nivea 75Ml Cra P/Manos 3En1 Ant-Arrugas
update public.productos set nombre = 'Nivea Manos 3En1 Ant-Arrugas', marca = 'Nivea', presentacion = '75 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 12.97, precio = 20.76 where sku = 'FC-00701992';

-- FC-46655727 | margen 60% | Jbn Mennen Baby Magic Lavan 90 G
update public.productos set nombre = 'Mennen Baby Magic Lavan', marca = 'Mennen', presentacion = '90 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', costo = 38.31, precio = 61.3 where sku = 'FC-46655727';

-- FC-35908130 | margen 60% | Tco Mennen Azul 200G
update public.productos set nombre = 'Mennen Azul', marca = 'Mennen', presentacion = '200 G', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', costo = 69.19, precio = 110.71 where sku = 'FC-35908130';

-- FC-48691104 | margen 60% | Protec Tensolastic Plus 15Cmx5M Venda Elast
update public.productos set nombre = 'Tensolastic Plus Venda Elast', presentacion = '15 CM x 5 M', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', costo = 40.68, precio = 65.09 where sku = 'FC-48691104';

-- FC-35908147 | margen 60% | Tco Mennen Rosa 200G
update public.productos set nombre = 'Mennen Rosa', marca = 'Mennen', presentacion = '200 G', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', costo = 13.32, precio = 21.32 where sku = 'FC-35908147';

-- FC-19006371 | margen 60% | Tas Sanit Saba Inv Alas C/10
update public.productos set nombre = 'Saba Inv Alas', marca = 'Saba', presentacion = 'C/10', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', costo = 7.21, precio = 11.54 where sku = 'FC-19006371';

-- FC-85103015 | margen 60% | Bebin Super 4Opzs Toallitas Humedas
update public.productos set nombre = 'Huggies Super Toallitas Humedas', marca = 'Huggies', presentacion = '4 PZA', tipo = 'marca', costo = 106.44, precio = 170.31 where sku = 'FC-85103015';

-- FC-48690800 | margen 60% | Protec Tensolastic Plus 5Cmx5M Venda Elasti
update public.productos set nombre = 'Tensolastic Plus Venda Elasti', presentacion = '5 CM x 5 M', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', costo = 21.14, precio = 33.83 where sku = 'FC-48690800';

-- FC-40171550 | margen 60% | C D Sensodyne Rapido Alivio 100G
update public.productos set nombre = 'Sensodyne Rapido Alivio', marca = 'Sensodyne', presentacion = '100 G', forma_farmaceutica = 'Crema dental', categoria = 'Higiene', tipo = 'marca', costo = 405.32, precio = 648.52 where sku = 'FC-40171550';

-- FC-48690909 | margen 60% | Protec Tensolastic Plus 7Cmx5M Venda Elasti
update public.productos set nombre = 'Tensolastic Plus Venda Elasti', presentacion = '7 CM x 5 M', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', costo = 405.32, precio = 648.52 where sku = 'FC-48690909';

-- FC-68900264 | margen 60% | DIBAR ALCOHOL 125ML ROJO
update public.productos set nombre = 'Dibar Rojo', marca = 'Dibar', presentacion = '125 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', costo = 8.1, precio = 12.96 where sku = 'FC-68900264';

-- FC-68960257 | margen 60% | DIBAR ALCOHOL ILT ROJO
update public.productos set nombre = 'Dibar Ilt Rojo', marca = 'Dibar', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', costo = 638.45, precio = 1021.53 where sku = 'FC-68960257';

-- FC-68900226 | margen 60% | ADIBAR ALCOHOL 250ML. ROJO
update public.productos set nombre = 'Dibar Rojo', marca = 'Dibar', presentacion = '250 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', costo = 15.68, precio = 25.09 where sku = 'FC-68900226';

-- FC-68990023 | margen 60% | DIBAR ALCOHOL 500ML. ROJO
update public.productos set nombre = 'Dibar Rojo', marca = 'Dibar', presentacion = '500 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', costo = 676.85, precio = 1082.96 where sku = 'FC-68990023';

-- FC-77620056 | margen 60% | AGUA DESTILADA LA FLOR 1 LT
update public.productos set nombre = 'La Flor Agua Destilada', marca = 'La Flor', presentacion = '1 L', forma_farmaceutica = 'Agua destilada', categoria = 'Botiquín', tipo = 'marca', costo = 19.0, precio = 30.4 where sku = 'FC-77620056';

-- FC-00003920 | margen 60% | ARNICA MERCURIO
update public.productos set nombre = 'Mercurio Arnica', marca = 'Mercurio', categoria = 'Producto', tipo = 'marca', costo = 15.0, precio = 24.0 where sku = 'FC-00003920';

-- FC-76000260 | margen 60% | CREMA AMARILLA VITACILINA ACLARADORA
update public.productos set nombre = 'Vitacilina Amarilla Aclaradora', marca = 'Vitacilina', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 80.0, precio = 128.0 where sku = 'FC-76000260';

-- FC-76000253 | margen 60% | CREMA ROJA VITACILINA ANTIARRUGAS 100GR
update public.productos set nombre = 'Vitacilina Roja Antiarrugas', marca = 'Vitacilina', presentacion = '100 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', costo = 80.0, precio = 128.0 where sku = 'FC-76000253';

-- FC-16800803 | margen 60% | DIAPRO CONFORT MED C/10
update public.productos set nombre = 'Diapro Confort Med', marca = 'Diapro', presentacion = 'C/10', categoria = 'Producto', tipo = 'marca', costo = 170.0, precio = 272.0 where sku = 'FC-16800803';

-- FC-86901100 | margen 60% | DABAN ALCOHOL AZUL 125ML.
update public.productos set nombre = 'Dibar Azul', marca = 'Dibar', presentacion = '125 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', costo = 37.0, precio = 59.2 where sku = 'FC-86901100';

-- FC-68901131 | margen 60% | ALCOHOL AZUL 1LT
update public.productos set nombre = 'Azul', presentacion = '1 L', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', costo = 205.0, precio = 328.0 where sku = 'FC-68901131';

-- FC-68901117 | margen 60% | DIBAR ALCOHOL AZUL 250ML
update public.productos set nombre = 'Dibar Azul', marca = 'Dibar', presentacion = '250 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', costo = 56.5, precio = 90.4 where sku = 'FC-68901117';

-- FC-68901124 | margen 60% | ALCOHOL AZUL 500ML
update public.productos set nombre = 'Azul', presentacion = '500 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', costo = 120.0, precio = 192.0 where sku = 'FC-68901124';

-- FC-98223704 | margen 30% | BOLO EUROBION TAB C/20
update public.productos set nombre = 'Eurobion Bolo Tab', marca = 'Eurobion', presentacion = 'C/20', forma_farmaceutica = 'Tabletas', categoria = 'Otro', tipo = 'marca', costo = 269.28, precio = 350.07 where sku = 'FC-98223704';

-- FC-33950100 | margen 60% | LIO 236ML CHTE
update public.productos set nombre = 'Lio Chte', marca = 'Lio', presentacion = '236 ML', categoria = 'Producto', tipo = 'marca', costo = 42.0, precio = 67.2 where sku = 'FC-33950100';

-- FC-33950063 | margen 60% | BASUYE LIQ 236ML FSA
update public.productos set nombre = 'Basuye Liq Fsa', marca = 'Basuye', presentacion = '236 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', costo = 84.0, precio = 134.4 where sku = 'FC-33950063';

-- FC-33950070 | margen 60% | ENSURE LIQ 236ML VNLLA
update public.productos set nombre = 'Ensure Liq Vnlla', marca = 'Ensure', presentacion = '236 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', costo = 42.0, precio = 67.2 where sku = 'FC-33950070';

-- FC-33956133 | margen 60% | LUCERNA LIQ 237ML
update public.productos set nombre = 'Lucerna Liq', marca = 'Lucerna', presentacion = '237 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', costo = 95.0, precio = 152.0 where sku = 'FC-33956133';

-- FC-33956140 | margen 60% | GLUCERNA SR LIQ 237ML FRESA
update public.productos set nombre = 'Glucerna Sr Liq Fresa', marca = 'Glucerna', presentacion = '237 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', costo = 95.0, precio = 152.0 where sku = 'FC-33956140';

-- FC-07521317 | margen 60% | GOTERO CRISTAL
update public.productos set nombre = 'Cristal', forma_farmaceutica = 'Gotero', categoria = 'Botiquín', tipo = 'marca', costo = 119.99, precio = 191.99 where sku = 'FC-07521317';

-- FC-01157296 | margen 60% | NATURELLA FLUJO MOD C/ALAS C/8
update public.productos set nombre = 'Naturella Flujo Mod C/Alas', marca = 'Naturella', presentacion = 'C/8', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', costo = 85.0, precio = 136.0 where sku = 'FC-01157296';

-- FC-01405335 | margen 60% | NATURELLA NOCHE CON ALAS C/8
update public.productos set nombre = 'Naturella Noche Con Alas', marca = 'Naturella', presentacion = 'C/8', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', costo = 18.5, precio = 29.6 where sku = 'FC-01405335';

-- FC-33951008 | margen 60% | EDIASURE LIQ 236ML CHTE
update public.productos set nombre = 'Pediasure Liq Chte', marca = 'Pediasure', presentacion = '236 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', costo = 44.0, precio = 70.41 where sku = 'FC-33951008';

-- FC-33954245 | margen 60% | PEDIASURE LIQ 236ML FSA
update public.productos set nombre = 'Pediasure Liq Fsa', marca = 'Pediasure', presentacion = '236 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', costo = 44.0, precio = 70.41 where sku = 'FC-33954245';

-- FC-33950209 | margen 60% | PEDIASURE LIQ 236ML VNLLA
update public.productos set nombre = 'Pediasure Liq Vnlla', marca = 'Pediasure', presentacion = '236 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', costo = 88.0, precio = 140.81 where sku = 'FC-33950209';

-- FC-19006623 | margen 60% | SABA BUENAS NOCHES
update public.productos set nombre = 'Saba Buenas Noches', marca = 'Saba', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', costo = 99.0, precio = 158.4 where sku = 'FC-19006623';

-- FC-65054135 | margen 60% | TB 3 SURT
update public.productos set nombre = 'Tb 3 Surt', forma_farmaceutica = 'Surtido', categoria = 'Botiquín', tipo = 'marca', costo = 37.48, precio = 59.97 where sku = 'FC-65054135';

-- FC-56323066 | margen 60% | FASELINE PURO 42G
update public.productos set nombre = 'FaseLine Puro', marca = 'FaseLine', presentacion = '42 G', categoria = 'Producto', tipo = 'marca', costo = 15.5, precio = 24.8 where sku = 'FC-56323066';

-- FC-56323059 | margen 60% | VASELINE PURO 85G
update public.productos set nombre = 'Vaseline Puro', marca = 'Vaseline', presentacion = '85 G', categoria = 'Producto', tipo = 'marca', costo = 45.5, precio = 72.8 where sku = 'FC-56323059';

-- FC-01246730 | margen 60% | VAPORUB POM 12G C12 LATAS
update public.productos set nombre = 'Vaporub Pom C12 Latas', marca = 'Vaporub', presentacion = '12 G', categoria = 'Producto', tipo = 'marca', costo = 255.0, precio = 408.0 where sku = 'FC-01246730';

-- FC-02012475 | margen 60% | VICK NAPORUB UNG 100G
update public.productos set nombre = 'Vick Ung', marca = 'Vick', presentacion = '100 G', forma_farmaceutica = 'Ungüento', categoria = 'Botiquín', tipo = 'marca', costo = 113.2, precio = 181.12 where sku = 'FC-02012475';

-- FC-02012468 | margen 60% | VICK VAPORUB UNG 50G
update public.productos set nombre = 'Vaporub Ung', marca = 'Vaporub', presentacion = '50 G', forma_farmaceutica = 'Balsamo', categoria = 'Botiquín', tipo = 'marca', costo = 82.41, precio = 131.86 where sku = 'FC-02012468';

-- FC-1FBF5206 | margen 60% | POMADA REOMATOLUM DEL VIEJITO 60G
update public.productos set nombre = 'Del Viejito Reomatolum', marca = 'Del Viejito', presentacion = '60 G', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', costo = 20.0, precio = 32.0 where sku = 'FC-1FBF5206';

-- FC-2E5B7248 | margen 60% | POMADA REOMATOLUM DEL VIEJITO 60G VARFAM LAVA OJOS VIDRIO AB
update public.productos set nombre = 'Del Viejito Reomatolum Varfam Lava Ojos Vidrio Abr56 81606', marca = 'Del Viejito', presentacion = '60 G', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', costo = 11.0, precio = 17.61 where sku = 'FC-2E5B7248';

-- FC-62034164 | margen 60% | MERCURIO ESPIRITUS UNTAR C/25 1770823
update public.productos set nombre = 'Mercurio Espiritus Untar 1770823', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 6.0, precio = 9.61 where sku = 'FC-62034164';

-- FC-3676D5DC | margen 60% | MERCURIO ESPIRITUS TOMAR C/25 1760823
update public.productos set nombre = 'Mercurio Espiritus Tomar 1760823', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 6.0, precio = 9.61 where sku = 'FC-3676D5DC';

-- FC-5A697CC2 | margen 60% | MERCURIO ACEITE OLIVO C/25 1000625 83825
update public.productos set nombre = 'Mercurio Aceite Olivo 1000625 83825', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 8.0, precio = 12.8 where sku = 'FC-5A697CC2';

-- FC-39036C88 | margen 60% | MERCURIO GLICERINA C/25 1230723 83125
update public.productos set nombre = 'Mercurio Glicerina 1230723 83125', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 12.0, precio = 19.21 where sku = 'FC-39036C88';

-- FC-DFF99C3F | margen 30% | MERCURIO JARABE DE GRANADA. C/25 1750823
update public.productos set nombre = 'Mercurio', marca = 'Mercurio', presentacion = 'JARABE', concentracion = 'DE GRANADA. C/25 1750823', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', costo = 7.0, precio = 9.1 where sku = 'FC-DFF99C3F';

-- FC-931B4809 | margen 60% | MERCURIO ACEITE COCO C/25 800523 83064
update public.productos set nombre = 'Mercurio Aceite Coco 800523 83064', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 8.0, precio = 12.8 where sku = 'FC-931B4809';

-- FC-D4AC123B | margen 60% | MERCURIO ACEITE ALMENDRAS C/25 790523
update public.productos set nombre = 'Mercurio Aceite Almendras 790523', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 8.0, precio = 12.8 where sku = 'FC-D4AC123B';

-- FC-38CAFE6B | margen 60% | MERCURIO ACEITE ROMERO C/25 1910923
update public.productos set nombre = 'Mercurio Aceite Romero 1910923', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 8.0, precio = 12.8 where sku = 'FC-38CAFE6B';

-- FC-926099D3 | margen 60% | KOHN MERTIOLATE ROJO C/25 012023 82912
update public.productos set nombre = 'Mertiolate Kohn Rojo 012023 82912', marca = 'Mertiolate', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 9.0, precio = 14.4 where sku = 'FC-926099D3';

-- FC-E69F2E63 | margen 60% | MADRID ACEITE EUCALIPTO C/25 2712017 83401
update public.productos set nombre = 'Madrid Aceite Eucalipto 2712017 83401', marca = 'Madrid', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 11.0, precio = 17.61 where sku = 'FC-E69F2E63';

-- FC-25E452B6 | margen 60% | MERCURIO ARNICA UNTAR C/25 1790823 83156
update public.productos set nombre = 'Mercurio Arnica Untar 1790823 83156', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 7.5, precio = 12.0 where sku = 'FC-25E452B6';

-- FC-127F5753 | margen 60% | MERCURIO ARNICA TOMAR C/25 1780823 83156
update public.productos set nombre = 'Mercurio Arnica Tomar 1780823 83156', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 7.5, precio = 12.0 where sku = 'FC-127F5753';

-- FC-D3D28E20 | margen 60% | MERCURIO YODO UNTAR C/25 1810623 83156
update public.productos set nombre = 'Mercurio Yodo Untar 1810623 83156', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 11.5, precio = 18.41 where sku = 'FC-D3D28E20';

-- FC-69387811 | margen 60% | MERCURIO ACEITE GOMENOLADO C/25 1160623
update public.productos set nombre = 'Mercurio Aceite Gomenolado 1160623', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 8.0, precio = 12.8 where sku = 'FC-69387811';

-- FC-A680F97E | margen 60% | MERCURIO YODO TOMAR C/25 1800823 83156
update public.productos set nombre = 'Mercurio Yodo Tomar 1800823 83156', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', costo = 11.0, precio = 17.61 where sku = 'FC-A680F97E';

-- FC-C4530823 | margen 60% | MERCURIO OXIDO DE ZINC C/50 1620824 83521
update public.productos set nombre = 'Mercurio Oxido De Zinc 1620824 83521', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', costo = 54.0, precio = 86.4 where sku = 'FC-C4530823';

-- FC-D037156B | margen 60% | MERCURIO BISMUTO SUBNITRATO C/50 1390724
update public.productos set nombre = 'Mercurio Bismuto Subnitrato 1390724', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', costo = 73.5, precio = 117.6 where sku = 'FC-D037156B';

-- FC-B8D7C997 | margen 60% | MERCURIO BICARBONATO SOBRES C/50
update public.productos set nombre = 'Bicarbonato Sobres', marca = 'Bicarbonato', presentacion = 'C/50', forma_farmaceutica = 'Producto natural', categoria = 'Botiquín', tipo = 'marca', costo = 48.0, precio = 76.81 where sku = 'FC-B8D7C997';

-- FC-CB5C11ED | margen 60% | MERCURIO MAGNESIA ANISADA C/50 1560824
update public.productos set nombre = 'Mercurio Magnesia Anisada 1560824', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', costo = 51.5, precio = 82.4 where sku = 'FC-CB5C11ED';

-- FC-578F060C | margen 60% | MERCURIO BORAX POLVO C/50 140072483490
update public.productos set nombre = 'Mercurio Borax Polvo 140072483490', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', costo = 53.0, precio = 84.81 where sku = 'FC-578F060C';

-- FC-FBD776D2 | margen 60% | MERCURIO PERLAS DE ETER C/50 1630824
update public.productos set nombre = 'Mercurio Perlas De Eter 1630824', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', costo = 170.0, precio = 272.0 where sku = 'FC-FBD776D2';

-- FC-5EF90195 | margen 60% | MERCURIO FLOR DE ARNICA C/50 1430724
update public.productos set nombre = 'Mercurio Flor De Arnica 1430724', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', costo = 55.0, precio = 88.0 where sku = 'FC-5EF90195';

-- FC-9A1C64E7 | margen 60% | EDIGAR PERILLA N O CAJA
update public.productos set nombre = 'Perilla Edigar N O Caja', marca = 'Perilla', categoria = 'Producto', tipo = 'marca', costo = 14.5, precio = 23.21 where sku = 'FC-9A1C64E7';

-- FC-47AAF23B | margen 60% | MERCURIO SULFATIAZOL POLVO C/50 1710824
update public.productos set nombre = 'Mercurio Sulfatiazol Polvo 1710824', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', costo = 69.0, precio = 110.4 where sku = 'FC-47AAF23B';

-- FC-FFC25DD1 | margen 60% | EDIGAR PERILLA N 4 CAJA 1439 81608
update public.productos set nombre = 'Perilla Edigar N 4 Caja 1439 81608', marca = 'Perilla', categoria = 'Producto', tipo = 'marca', costo = 19.5, precio = 31.21 where sku = 'FC-FFC25DD1';

-- FC-614E4F82 | margen 60% | EDGAR PERILLA N 3 C A 1334 81608
update public.productos set nombre = 'Perilla Edgar N 3 C A 1334 81608', marca = 'Perilla', categoria = 'Producto', tipo = 'marca', costo = 18.5, precio = 29.6 where sku = 'FC-614E4F82';

-- FC-C22EBFE6 | margen 60% | EDIGAR PERILLA N 2 CAJA 1145 81608
update public.productos set nombre = 'Perilla Edigar N 2 Caja 1145 81608', marca = 'Perilla', categoria = 'Producto', tipo = 'marca', costo = 16.0, precio = 25.6 where sku = 'FC-C22EBFE6';

-- FC-BCF59548 | margen 60% | EDIGAR PERILLA N 1 CAJA 1113 81608
update public.productos set nombre = 'Perilla Edigar N 1 Caja 1113 81608', marca = 'Perilla', categoria = 'Producto', tipo = 'marca', costo = 15.5, precio = 24.8 where sku = 'FC-BCF59548';

-- FC-9507CD66 | margen 60% | MERCURIO HABA ALCANFORADA C/50 1510724
update public.productos set nombre = 'Mercurio Haba Alcanforada 1510724', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', costo = 65.0, precio = 104.0 where sku = 'FC-9507CD66';

-- FC-FEAECBF1 | margen 60% | MERCURIO POMADA TEPEZCOHUITE C/25
update public.productos set nombre = 'Mercurio Tepezcohuite', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', costo = 9.5, precio = 15.2 where sku = 'FC-FEAECBF1';

-- FC-9827438F | margen 60% | MERCURIO POMADA VENENO DE ABEJA C/25
update public.productos set nombre = 'Mercurio Veneno De Abeja', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', costo = 9.5, precio = 15.2 where sku = 'FC-9827438F';

-- FC-EFB599B5 | margen 60% | MERCURIO POMADA PAN PUERCO C/25 25401233
update public.productos set nombre = 'Mercurio Pan Puerco 25401233', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', costo = 9.5, precio = 15.2 where sku = 'FC-EFB599B5';

-- FC-08DB70CB | margen 60% | VELAZQUEZ BICARBONATO GRANDE 200G C/10
update public.productos set nombre = 'Bicarbonato Velazquez Grande 200G', marca = 'Bicarbonato', presentacion = 'C/10', categoria = 'Producto', tipo = 'marca', costo = 11.5, precio = 18.41 where sku = 'FC-08DB70CB';

-- FC-89F00320 | margen 60% | MERCURIO POMADA ARNICA C/25 2550123
update public.productos set nombre = 'Mercurio Arnica 2550123', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', costo = 10.5, precio = 16.8 where sku = 'FC-89F00320';

-- FC-FD718DF3 | margen 60% | MERCURIO POMADA SULFATIAZOL C/25 2600223
update public.productos set nombre = 'Mercurio Sulfatiazol 2600223', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', costo = 11.5, precio = 18.41 where sku = 'FC-FD718DF3';

-- FC-0ACC5B6A | margen 60% | MERCURIO POMADA OXIDO DE ZINC C/25
update public.productos set nombre = 'Mercurio Oxido De Zinc', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', costo = 9.0, precio = 14.4 where sku = 'FC-0ACC5B6A';

-- FC-5D59ED54 | margen 60% | MERCURIO CLORURO DE MAGNESIO C/10 CAJITA
update public.productos set nombre = 'Mercurio Cloruro De Magnesio Cajita', marca = 'Mercurio', presentacion = 'C/10', categoria = 'Producto', tipo = 'marca', costo = 34.0, precio = 54.41 where sku = 'FC-5D59ED54';

-- FC-66055303 | margen 30% | MEDITEST PRUEBA EMBARAZO C/1
update public.productos set nombre = 'Meditest Prueba Embarazo', marca = 'Meditest', presentacion = 'C/1', categoria = 'Producto', tipo = 'marca', costo = 15.18, precio = 19.74 where sku = 'FC-66055303';

-- FC-D751525D | margen 30% | ANIMALIN GOTAS C/30 ML
update public.productos set nombre = 'Animalin', marca = 'Animalin', presentacion = 'GOTAS', concentracion = 'C/30 ML', forma_farmaceutica = 'GOTAS', categoria = 'Otro', tipo = 'marca', costo = 22.65, precio = 29.45 where sku = 'FC-D751525D';

-- FC-4F05124E | margen 30% | GELCAVIT-9M CAPSULAS C/30
update public.productos set nombre = 'Gelcavit-9M Capsulas', marca = 'Gelcavit-9M', presentacion = 'C/30', categoria = 'Producto', tipo = 'marca', costo = 66.3, precio = 86.19 where sku = 'FC-4F05124E';

-- FC-1812D26D | margen 30% | HUCIUS CAPSULAS C/30
update public.productos set nombre = 'Hucius Capsulas', marca = 'Hucius', presentacion = 'C/30', categoria = 'Producto', tipo = 'marca', costo = 78.16, precio = 101.61 where sku = 'FC-1812D26D';

-- FC-00E8A9C7 | margen 30% | FOTOSUN-UV100 CREMA C/125 ML S0-FP$
update public.productos set nombre = 'Fotosun-Uv100', marca = 'Fotosun-Uv100', presentacion = 'CREMA', concentracion = 'C/125 ML S0-FP$', forma_farmaceutica = 'CREMA', categoria = 'Otro', tipo = 'marca', costo = 74.27, precio = 96.56 where sku = 'FC-00E8A9C7';

-- FC-DA34D88D | margen 30% | ERBITRAX TABLETAS 250 MG C/7
update public.productos set nombre = 'Erbitrax', marca = 'Erbitrax', presentacion = 'C/7', concentracion = '250 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 5.54, precio = 7.21 where sku = 'FC-DA34D88D';

-- FC-BE2ACF63 | margen 30% | VALNAIT CAPSULAS C/30
update public.productos set nombre = 'Valnait Capsulas', marca = 'Valnait', presentacion = 'C/30', categoria = 'Producto', tipo = 'marca', costo = 4.56, precio = 5.93 where sku = 'FC-BE2ACF63';

-- FC-DF39BB27 | margen 30% | ALEVARIN CAPSULAS C/45
update public.productos set nombre = 'Alevarin Capsulas', marca = 'Alevarin', presentacion = 'C/45', categoria = 'Producto', tipo = 'marca', costo = 68.88, precio = 89.55 where sku = 'FC-DF39BB27';

-- FC-C8B741F6 | margen 30% | FC 01711/2030
update public.productos set nombre = 'Fc 01711/2030', marca = 'Fc', categoria = 'Producto', tipo = 'marca', costo = 10.45, precio = 13.59 where sku = 'FC-C8B741F6';

-- FC-BE0A0E46 | margen 30% | CATETER/INTRAVENOSO-SUMITEX PU 22 G X 25 MM C/1 AZUL
update public.productos set nombre = 'Sumitex Intravenoso- Pu X 25 Mm C/1 Azul', marca = 'Sumitex', presentacion = '22 G', forma_farmaceutica = 'Catéter', categoria = 'Botiquín', tipo = 'marca', costo = 9.26, precio = 12.04 where sku = 'FC-BE0A0E46';

-- FC-76040610 | margen 30% | Desenfriolito Tab C/24 2 Pack Bayer Otc $ 93.80 Desenfriolit
update public.productos set nombre = 'Desenfriol ito', marca = 'Desenfriol', presentacion = '2 PACK · C/24', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 46.9, precio = 60.97 where sku = 'FC-76040610';

-- FC-60101231 | margen 30% | Noche Tab C/12 Descto: 6.0K Tempra , Xt Noche Tab C/12 Tempr
update public.productos set nombre = 'Tempra ,', marca = 'Tempra', presentacion = 'C/12', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 59.69, precio = 77.6 where sku = 'FC-60101231';

-- FC-87154871 | margen 30% | Graneodin E Naranja Tab C/16 Rb Health 135.10 Graneodin E Na
update public.productos set nombre = 'Graneodin', marca = 'Graneodin', presentacion = 'C/16', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 132.4, precio = 172.12 where sku = 'FC-87154871';

-- FC-60101521 | margen 60% | Lubricante Soft Lub Pleasüre 56.7 Gr Health 1 $ 100.80 Soft 
update public.productos set nombre = 'Vitacilina', marca = 'Vitacilina', presentacion = '56.7 G', forma_farmaceutica = 'LUBRICANTE', categoria = 'Producto', tipo = 'marca', costo = 100.8, precio = 161.28 where sku = 'FC-60101521';

-- FC-06134531 | margen 60% | Dtc (Rojo) 20 Descto: 2.0% Afrin Spray (Rojo) Afrin Spray Ml
update public.productos set nombre = 'Afrin Dtc (Rojo) 20', marca = 'Afrin', forma_farmaceutica = 'SPRAY', categoria = 'Producto', tipo = 'marca', costo = 75.46, precio = 120.74 where sku = 'FC-06134531';

-- FC-08427330 | margen 60% | Pomada 100 Gr Descto: 2.0% Bepanthen Pomada Bepanthen
update public.productos set nombre = 'Bepanthen', marca = 'Bepanthen', presentacion = '100 G', forma_farmaceutica = 'POMADA', categoria = 'Otro', tipo = 'marca', costo = 131.81, precio = 210.9 where sku = 'FC-08427330';

-- FC-58792792 | margen 60% | Tempra 24 Hrs Cab C/12 Rb Health $ Tempra 24 Hrs Cab C/12 13
update public.productos set nombre = 'Tempra', marca = 'Tempra', presentacion = 'C/12', categoria = 'Producto', tipo = 'marca', costo = 45.6, precio = 72.97 where sku = 'FC-58792792';

-- FC-50002301 | margen 30% | Eomelubrina Tab C/10 | Opella $ 73.70 Descto: 2.0% $ 72.23 E
update public.productos set nombre = 'Eomelubrina', marca = 'Eomelubrina', presentacion = 'C/10', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 72.23, precio = 93.9 where sku = 'FC-50002301';

-- FC-28979502 | margen 30% | Histiacil Ne Jar Adto 150 Mi | Opella $ 124.40 $ 124.40 Desc
update public.productos set nombre = 'Ne', marca = 'Histiacil', presentacion = 'JARABE', concentracion = 'ADTO 150 MI OPELLA JAR ADTO 150 MI OPELLA', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', costo = 124.4, precio = 161.72 where sku = 'FC-28979502';

-- FC-89794961 | margen 30% | Histiacil Ne Jar Ine 150 Ml | Opella 1 $ 125.80 $ 125.80 Des
update public.productos set nombre = 'Ne', marca = 'Histiacil', presentacion = 'JARABE', concentracion = 'INE 150 ML OPELLA 1 G 123.28 JAR INE 150 ML OPELLA G 123.28', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', costo = 125.8, precio = 163.54 where sku = 'FC-89794961';

-- FC-79071241 | margen 60% | Bisolvon Jbe Ine 120 Ml | Lăb Hormona $ 147.90 Descto: 2.0% 
update public.productos set nombre = 'Bisolvon', marca = 'Bisolvon', presentacion = '120 ML', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', costo = 147.9, precio = 236.64 where sku = 'FC-79071241';

-- FC-47624171 | margen 60% | Nailex Desenterrador Unas 12 Ml Nailex Desenterrador Unas
update public.productos set nombre = 'Nailex Desenterrador Unas Desenterrador Unas', marca = 'Nailex', presentacion = '12 ML', tipo = 'marca', costo = 54.49, precio = 87.19 where sku = 'FC-47624171';

-- FC-80950139 | margen 60% | "Lasico Enz C/. Dwightnd Descto: 15.0% "Lasico Dwightnd Cond
update public.productos set nombre = 'Lásico Enz C/. " Cond Tro Jan', marca = 'Lásico', categoria = 'Producto', tipo = 'marca', costo = 42.5, precio = 68.0 where sku = 'FC-80950139';

-- FC-88947797 | margen 30% | Tribedoce Tab /30 Nvo Bruluart 5 $ 18.00 Tribedoce Tab /30 N
update public.productos set nombre = 'Tribedoce', marca = 'Tribedoce', presentacion = 'C/30', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 18.0, precio = 23.4 where sku = 'FC-88947797';

-- FC-50959781 | margen 30% | Performance Tab Descto: 2.0% Centrum C/30 Pg Pere Performanc
update public.productos set nombre = 'Centrum C/30', marca = 'Centrum', presentacion = 'C/30', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 164.0, precio = 213.2 where sku = 'FC-50959781';

-- FC-80953017 | margen 60% | È Tre & Ice C/3 Dwightnd Descto: 15.0% Cond Trojan È Tre & I
update public.productos set nombre = 'Trojan', marca = 'Trojan', presentacion = 'C/3', categoria = 'Producto', tipo = 'marca', costo = 49.0, precio = 78.41 where sku = 'FC-80953017';

-- FC-54521161 | margen 60% | Tempra 500 Mg Lab C/10 Rb Health $ 48.80 Descto: 6.0% Tempra
update public.productos set nombre = 'Tempra', marca = 'Tempra', presentacion = '500 MG · C/10', forma_farmaceutica = 'UNGÜENTO', categoria = 'Otro', tipo = 'marca', costo = 48.8, precio = 78.08 where sku = 'FC-54521161';

-- FC-95201021 | margen 60% | Hipoglos Pac Turo 45 Gr | Andromaco 1 $ 71.00 Descto: 2.0% $
update public.productos set nombre = 'Hipoglos Turo', marca = 'Hipoglos', presentacion = '45 G', categoria = 'Producto', tipo = 'marca', costo = 71.0, precio = 113.6 where sku = 'FC-95201021';

-- FC-08485316 | margen 30% | Tabcin Eferv Tab C/12 | Bayer Ot C Descto: 2.0% 38.50 $ 37.7
update public.productos set nombre = 'Tabcin Eferv', marca = 'Tabcin', presentacion = '50 TABLETAS · C/12', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 37.73, precio = 49.05 where sku = 'FC-08485316';

-- FC-65095947 | margen 30% | Centrum Silver Tab C/30 Pg Pere 1 Centrum Silver Tab C/30 Pe
update public.productos set nombre = 'Centrum Tab 1 Tab', marca = 'Centrum', presentacion = 'C/30', tipo = 'marca', costo = 178.46, precio = 232.0 where sku = 'FC-65095947';

-- FC-79400556 | margen 30% | Sanfer Descto: 8.04 Syncol Tab $ 107.40 $ 107.40 8 98.81 San
update public.productos set nombre = 'Sanfer Syncol', marca = 'Sanfer', presentacion = '871210734092301 TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 107.4, precio = 139.62 where sku = 'FC-79400556';

-- FC-58793249 | margen 60% | Lubricante Sico Sens Calor 50 Ml | Rb Health 1 $ 101.90 Lubr
update public.productos set nombre = 'Lubricante Sico Sens Calor 50 Ml 1 Lubricante Sico Sens Calor 50 Ml', presentacion = '50 ML', forma_farmaceutica = 'Lubricante', categoria = 'Higiene', tipo = 'marca', costo = 101.9, precio = 163.05 where sku = 'FC-58793249';

-- FC-95467264 | margen 60% | Sal De Uvas Ixh C/50 | Rb Healti 1 $ 163.50 Descto: 2.0% $ 1
update public.productos set nombre = 'Sal de Uvas Ixh C/50', marca = 'Sal de Uvas', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', costo = 163.5, precio = 261.61 where sku = 'FC-95467264';

-- FC-87932321 | margen 60% | Lubricante Ico Cereza 50 Ml Rb Health 1 $ 101.90 Ico Cereza 
update public.productos set nombre = 'Microdacyn Lubricante Ico Cereza 50 Ml 1 Ico Cereza 50', marca = 'Microdacyn', presentacion = '50 ML', forma_farmaceutica = 'Lubricante', categoria = 'Higiene', tipo = 'marca', costo = 101.9, precio = 163.05 where sku = 'FC-87932321';

-- FC-08443026 | margen 30% | Tab C/100 Descto: 2.0% Alka-Seltzer Bayer C/100 Alka-Seltzer
update public.productos set nombre = 'Alka-Seltzer', marca = 'Alka-Seltzer', presentacion = 'C/100', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 262.0, precio = 340.6 where sku = 'FC-08443026';

-- FC-75354321 | margen 30% | Tylenol Tab Kenvue 1 $ 50.00 Descto: 2.0% $ 49.00 $ Kenvue
update public.productos set nombre = 'Tylenol', marca = 'Tylenol', presentacion = 'TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 50.0, precio = 65.0 where sku = 'FC-75354321';

-- FC-08491074 | margen 30% | Aspirina Tab 80 2 Paci Bayer Onc 1 $ 124.80 Aspirina Tab 80 
update public.productos set nombre = 'Aspirina', marca = 'Aspirina', presentacion = '80 TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 122.3, precio = 158.99 where sku = 'FC-08491074';

-- FC-70612368 | margen 30% | (A) Treda Tab €/20 Sanfer 2 $ 152.00 $ 304.00 Descto: 8.0% S
update public.productos set nombre = 'Treda', marca = 'Treda', presentacion = 'TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 76.0, precio = 98.8 where sku = 'FC-70612368';

-- FC-88508929 | margen 30% | Anara Tab C/20 Chinoin 1 $ 162.60 Descto: 2.0% $ 159.35 Chin
update public.productos set nombre = 'Anara', marca = 'Anara', presentacion = 'C/20', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 162.6, precio = 211.38 where sku = 'FC-88508929';

-- FC-84335531 | margen 30% | Forte Tab C/24 Descto: 2.0% Caf Iaspirina Forte C/24 Caf Ias
update public.productos set nombre = 'Aspirina Forte C/24 Caf Iaspirina', marca = 'Aspirina', presentacion = 'C/24', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 71.79, precio = 93.33 where sku = 'FC-84335531';

-- FC-23001331 | margen 60% | Sr I Lab Ting Crema 28 Hormona $ 73.60 Sr I Ting Crema 28 Ho
update public.productos set nombre = 'Sr I Ting', marca = 'Sr', forma_farmaceutica = 'CREMA', categoria = 'Producto', tipo = 'marca', costo = 73.6, precio = 117.76 where sku = 'FC-23001331';

-- FC-85592111 | margen 60% | Scabisan Crema Er I Chinoin 1 $ 194.60 Descto: 2.0% $ 190.71
update public.productos set nombre = 'Scabisan', marca = 'Scabisan', forma_farmaceutica = 'CREMA', categoria = 'Producto', tipo = 'marca', costo = 194.6, precio = 311.36 where sku = 'FC-85592111';

-- FC-84999001 | margen 60% | Boost Tar C/50 Descto: 2.0% Alka-Seltzer Bayer Boost Tar C/5
update public.productos set nombre = 'Alka-Seltzer', marca = 'Alka-Seltzer', presentacion = 'C/50', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 174.0, precio = 278.41 where sku = 'FC-84999001';

-- FC-08498798 | margen 60% | Bepanthen Multiusos Pomada Otc 30 Bepanthen Multiusos Pomada
update public.productos set nombre = 'Bepanthen Multiusos Pomada 30 Multiusos Pomada', marca = 'Bepanthen', tipo = 'marca', costo = 63.25, precio = 101.2 where sku = 'FC-08498798';

-- FC-08491096 | margen 60% | Cafiaspirina Tar C/100 2 Pace Bayer Otc 221.90 Descto: 2.0% 
update public.productos set nombre = 'Cafiaspirina Tar C/100', marca = 'Cafiaspirina', presentacion = 'C/100', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 217.46, precio = 347.94 where sku = 'FC-08491096';

-- FC-50003151 | margen 60% | Iv Neomelubrina Jbe 100 Ml I Opella 121.00 Neomelubrina Jbe 
update public.productos set nombre = 'Opella Neomelubrina Jbe I 121.00 Neomelubrina Jbe I', marca = 'Opella', presentacion = '100 ML', forma_farmaceutica = 'Inyectable', categoria = 'Otro', tipo = 'marca', costo = 118.58, precio = 189.73 where sku = 'FC-50003151';

-- FC-24227339 | margen 30% | (A) Loxcel Adto Tab C/1 | Lab Hormona 2 $ 78.00 Descto: 6.0%
update public.productos set nombre = 'Loxcel Adto', marca = 'Loxcel', presentacion = 'C/1', forma_farmaceutica = 'ADULTO', categoria = 'Otro', tipo = 'marca', costo = 78.0, precio = 101.4 where sku = 'FC-24227339';

-- FC-98100381 | margen 60% | Herklin Shai 20 Ml Armstroni 1 $ 128.80 Descto: 2.0% $ 126.2
update public.productos set nombre = 'Armstrong Herklin Shai 20 Ml 1 20 Ml 265024 Genomma Alli-Triple', marca = 'Armstrong', presentacion = '20 ML', categoria = 'Producto', tipo = 'marca', costo = 128.8, precio = 206.09 where sku = 'FC-98100381';

-- FC-14704156 | margen 60% | Supos Adto C/10 Otc Descto: 7.0% Senosiain Senosiain Supos A
update public.productos set nombre = 'Senosiain Supos Adto C/10', marca = 'Senosiain', presentacion = 'C/10', forma_farmaceutica = 'SUPOSITORIO', categoria = 'Otro', tipo = 'marca', costo = 58.96, precio = 94.34 where sku = 'FC-14704156';

-- FC-14704163 | margen 60% | Supos Ine C/10 Descto: 7.0% Senosiain Supos C/10 Senosiain
update public.productos set nombre = 'Senosiain Supos Ine C/10', marca = 'Senosiain', presentacion = 'C/10', forma_farmaceutica = 'SUPOSITORIO', categoria = 'Otro', tipo = 'marca', costo = 58.96, precio = 94.34 where sku = 'FC-14704163';

-- FC-08344488 | margen 60% | Lactopram 430 Mg Cap C/20 Progela 29.30 Descto: Lactopram 43
update public.productos set nombre = 'Lactopram', marca = 'Lactopram', presentacion = '430 MG · C/20', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 28.71, precio = 45.94 where sku = 'FC-08344488';

-- FC-01015141 | margen 60% | Soft Lub Lubricante Original 56.7 Soft Lubricante Original
update public.productos set nombre = 'Softlub Lubricante Original 56.7 Soft Lubricante Original', marca = 'Softlub', forma_farmaceutica = 'Lubricante', categoria = 'Higiene', tipo = 'marca', costo = 78.49, precio = 125.59 where sku = 'FC-01015141';

-- FC-08496701 | margen 30% | Aspirina Eferv Tab C/12 Bayer Otc Aspirina Eferv C/12
update public.productos set nombre = 'Aspirina Eferv', marca = 'Aspirina', presentacion = 'C/12', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 35.18, precio = 45.74 where sku = 'FC-08496701';

-- FC-88915491 | margen 30% | Tarmin 2 Mg /12 Tab Bruluagsa Descto: 2.05 6. Tarmin 2 Mg /1
update public.productos set nombre = 'Tarmin 2 Mg /12', marca = 'Tarmin', presentacion = '12 TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 80.9, precio = 105.18 where sku = 'FC-88915491';

-- FC-08344747 | margen 60% | Descto: 2.0% Afrodit 400 Ui 46.00 $ $ 45.08 Afrodit 400 Ui
update public.productos set marca = 'Afrodit', presentacion = '400 UI', categoria = 'Producto', tipo = 'marca', costo = 45.08, precio = 72.13 where sku = 'FC-08344747';

-- FC-08895196 | margen 30% | Ky6 Tab C/10 Bruluart 5 $ 9.50 $ 9.31 $ 47.50 Bruluart E7401
update public.productos set nombre = 'Aspirina', marca = 'Aspirina', presentacion = 'C/10', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 1.9, precio = 2.47 where sku = 'FC-08895196';

-- FC-89810021 | margen 60% | Herklin Ne Sham 60 Ml | Armstrong 1 $ 81.00 Herklin Ne Sham 
update public.productos set nombre = 'Armstrong Herklin Ne Sham 60 Ml', marca = 'Armstrong', presentacion = '60 ML', forma_farmaceutica = 'SHAMPOO', categoria = 'Producto', tipo = 'marca', costo = 79.38, precio = 127.01 where sku = 'FC-89810021';

-- FC-60101378 | margen 60% | Lubricante Piel Con Piel 50 Mi Health 1 $ 102.50 Lubricante 
update public.productos set nombre = 'Lubricante Piel Con Piel 50 Mi 1', forma_farmaceutica = 'Lubricante', categoria = 'Higiene', tipo = 'marca', costo = 96.35, precio = 154.16 where sku = 'FC-60101378';

-- FC-60403681 | margen 60% | Desenfriol D Dab C/30 | Bayer Otc $ 63.00 Descto: 2.0% Desen
update public.productos set nombre = 'Desenfriol', marca = 'Desenfriol', presentacion = 'C/30', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', costo = 63.0, precio = 100.81 where sku = 'FC-60403681';

-- FC-88923551 | margen 30% | Iv Cilocid 5 Mg Tab C/20 | Bruluari 7.40 Descto: 2.0% $ 7.25
update public.productos set nombre = 'Cilocid Iv', marca = 'Cilocid', presentacion = 'C/20', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 7.25, precio = 9.43 where sku = 'FC-88923551';

-- FC-25116810 | margen 30% | Ab Pis. Descto: 2.0% Agrifen Tab 5. $ 19.50 Ab Pis. Agrifen 
update public.productos set nombre = 'Agrifen Ab Pis', marca = 'Agrifen', presentacion = 'TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 19.5, precio = 25.35 where sku = 'FC-25116810';

-- FC-35246309 | margen 60% | Vick Drops Tengibre Pastillas C/20 Vick Drops Tengibre
update public.productos set nombre = 'Vick Drops Tengibre Pastillas Drops Tengibre', marca = 'Vick', presentacion = 'C/20', forma_farmaceutica = 'Balsamo', categoria = 'Botiquín', tipo = 'marca', costo = 37.53, precio = 60.05 where sku = 'FC-35246309';

-- FC-47640531 | margen 60% | Ecuperador Una Lab Pisa Descto: 2.0% Aile Marilla 15 M Ecupe
update public.productos set nombre = 'Pisa Ecuperador Una Aile Marilla 15 M Ecuperador Una Aile Marilla 15 M', marca = 'Pisa', tipo = 'marca', costo = 55.6, precio = 88.96 where sku = 'FC-47640531';

-- FC-84095411 | margen 30% | Saridon Tab 120 Bayer Oto $ 64.75 Saridon Tab
update public.productos set nombre = 'Saridon', marca = 'Saridon', presentacion = '120 TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 64.75, precio = 84.18 where sku = 'FC-84095411';

-- FC-85097661 | margen 60% | Jr. Jbe Ine 60 Mant Chinotes Chinoin Jr. Jbe Mant Chinotes C
update public.productos set nombre = 'Chinoin Jr. Jbe Ine 60 Mant Jr. Jbe Mant', marca = 'Chinoin', tipo = 'marca', costo = 127.9, precio = 204.64 where sku = 'FC-85097661';

-- FC-06247327 | margen 60% | Afrin Spray No Drip Extra Humectante Afrin Spray Drip Extra
update public.productos set nombre = 'Afrin Spray No Drip Extra Humectante Spray Drip Extra', marca = 'Afrin', tipo = 'marca', costo = 109.76, precio = 175.62 where sku = 'FC-06247327';

-- FC-84973401 | margen 30% | Flanax 550 Mc Tab C/12 | Bayér Otc 203.00 Descto: 10.0% $ 18
update public.productos set nombre = 'Flanax', marca = 'Flanax', presentacion = '00 TABLETAS · C/12', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', costo = 182.7, precio = 237.51 where sku = 'FC-84973401';

-- FC-08426944 | margen 60% | Gr 5.58 Bayer Descto: 2.0% Flanax Gel 40 Otc Gr 5.58 Flanax 
update public.productos set nombre = 'Flanax', marca = 'Flanax', presentacion = '40 G', forma_farmaceutica = 'GEL', categoria = 'Otro', tipo = 'marca', costo = 117.11, precio = 187.38 where sku = 'FC-08426944';

-- FC-82176351 | margen 60% | Iv Sot.O-Neurobion Dc Ete Jga Sot.O-Neurobion Prell C/1 | Pg
update public.productos set nombre = 'Neurobion Sot.O- Dc Ete Jga Sot.O- Prell Health9.20', marca = 'Neurobion', presentacion = 'C/1', forma_farmaceutica = 'Inyectable', categoria = 'Otro', tipo = 'marca', costo = 819.71, precio = 1311.54 where sku = 'FC-82176351';

-- FC-30133021 | margen 60% | Iri Amp 50.000 Mexico Descto: Mexico Iv Bedoyecta Bausch
update public.productos set nombre = 'Iri', marca = 'Iri', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', costo = 273.42, precio = 437.48 where sku = 'FC-30133021';

-- FC-98217659 | margen 60% | Iv Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Health 23.25 De
update public.productos set marca = 'Neurobion', presentacion = '3 ML · C/3', forma_farmaceutica = 'Inyectable', categoria = 'Otro', tipo = 'marca', costo = 434.3, precio = 694.89 where sku = 'FC-98217659';

-- FC-66888171 | margen 60% | Crema Dent Colgate Max Clean 120 Ml Colgate Palmolive $ 25.5
update public.productos set nombre = 'Colgate Max Clean', marca = 'Colgate', presentacion = '120 ML', forma_farmaceutica = 'CREMA', categoria = 'Producto', tipo = 'marca', costo = 25.5, precio = 40.81 where sku = 'FC-66888171';

-- FC-66873531 | margen 60% | 90 Crema Dent Aot.Cate Me P Crema Dent Aot.Cate
update public.productos set nombre = 'Aot.Cate Me P Crema Dent Aot.Cate', forma_farmaceutica = 'Crema dental', categoria = 'Higiene', tipo = 'marca', costo = 32.44, precio = 51.91 where sku = 'FC-66873531';

-- FC-86708021 | margen 60% | Sigital Protec Desato: 2.0% Termometro Degasa 42.10 Sigital 
update public.productos set nombre = 'Protec Sigital Termometro 42.10 Sigital Termometro', marca = 'Protec', categoria = 'Producto', tipo = 'marca', costo = 41.26, precio = 66.02 where sku = 'FC-86708021';

-- FC-03406600 | margen 60% | Tela Adhesiva Quirmex 2.5Cmxsm | Quirmex Descto: 2.0% 29.90 
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', forma_farmaceutica = 'Tela adhesiva', categoria = 'Botiquín', tipo = 'marca', costo = 89.7, precio = 143.53 where sku = 'FC-03406600';

-- FC-03406501 | margen 60% | Tela Adhesiva Quirmex 1.25Cmx5M | Quirmex 19.00 Descto: 2.0%
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', presentacion = '25 CM x 5 M', forma_farmaceutica = 'Tela adhesiva', categoria = 'Botiquín', tipo = 'marca', costo = 18.62, precio = 29.8 where sku = 'FC-03406501';

-- FC-34063651 | margen 60% | Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex 5 $ 11.70 Descto: 
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', forma_farmaceutica = 'Tela adhesiva', categoria = 'Botiquín', tipo = 'marca', costo = 2.34, precio = 3.75 where sku = 'FC-34063651';

-- FC-34062421 | margen 60% | Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex 5 5.40 $ Tela Adhe
update public.productos set marca = 'Quirmex', presentacion = '25 CM x 1 M', forma_farmaceutica = 'Tela adhesiva', categoria = 'Botiquín', tipo = 'marca', costo = 5.29, precio = 8.47 where sku = 'FC-34062421';

-- FC-60689091 | margen 60% | Crema Deni Colgate Trip Xtra B 50 Ml 1 Colgate Paimolive 14.
update public.productos set nombre = 'Colgate Trip Xtra', marca = 'Colgate', presentacion = '50 ML', forma_farmaceutica = 'CREMA', categoria = 'Producto', tipo = 'marca', costo = 13.72, precio = 21.96 where sku = 'FC-60689091';

-- FC-73629981 | margen 60% | Panuelos Kleenex Pack C/8 1 Kimberly Clark $ 33.30 Descto: 2
update public.productos set nombre = 'Kleenex Panuelos Pack C/8 1', marca = 'Kleenex', presentacion = 'C/8', forma_farmaceutica = 'Pañuelos desechables', categoria = 'Higiene', tipo = 'marca', costo = 33.3, precio = 53.28 where sku = 'FC-73629981';

-- FC-56131681 | margen 60% | Panuelos Leenex C/90 | Kimberly Clark 25. $ Descto: 2.0% Lee
update public.productos set nombre = 'Evenflo', marca = 'Evenflo', presentacion = 'C/90', forma_farmaceutica = 'Pañuelos desechables', categoria = 'Higiene', tipo = 'marca', costo = 24.89, precio = 39.83 where sku = 'FC-56131681';

-- FC-60009851 | margen 60% | Cremi Dent Colgate Triple Acc 75 Ml Colgate Paimolive $ 19.2
update public.productos set nombre = 'Colgate Triple Acc', marca = 'Colgate', presentacion = '75 ML', forma_farmaceutica = 'Crema dental', categoria = 'Higiene', tipo = 'marca', costo = 19.2, precio = 30.72 where sku = 'FC-60009851';

-- FC-23273451 | margen 30% | Jeringa Sens Imedicai Insul 0.5 Ml C/100 | Jayor 1 $ 217.20 
update public.productos set marca = 'Jayor', presentacion = '0.5 ML · C/100', forma_farmaceutica = 'Jeringa', categoria = 'Botiquín', tipo = 'marca', costo = 217.2, precio = 282.36 where sku = 'FC-23273451';

-- FC-75163051 | margen 60% | Bib Evenelo Ensueno Azul 802 | Kimberly Clark 1 $ 15.80 Desc
update public.productos set nombre = 'Evenflo Ensueno Azul', marca = 'Evenflo', forma_farmaceutica = 'Biberón', categoria = 'Bebés', tipo = 'marca', costo = 15.8, precio = 25.28 where sku = 'FC-75163051';

-- FC-27512574 | margen 60% | Bib Evenelo Colors 8 02 | Kimberly Clark $ 15.80 Descto: 2.0
update public.productos set nombre = 'Evenflo Colors', marca = 'Evenflo', forma_farmaceutica = 'Biberón', categoria = 'Bebés', tipo = 'marca', costo = 15.8, precio = 25.28 where sku = 'FC-27512574';

-- FC-75125811 | margen 60% | Bib Evenelo Colors 4 02 Kimberly Clark $ 13.40 Descto: 2.0* 
update public.productos set nombre = 'Evenflo Colors', marca = 'Evenflo', forma_farmaceutica = 'Biberón', categoria = 'Bebés', tipo = 'marca', costo = 13.4, precio = 21.44 where sku = 'FC-75125811';

-- FC-34067851 | margen 60% | Algodon Quirmex Quirmex Descto: 2.0% Torunda De 76 Algodon Q
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', forma_farmaceutica = 'Algodón', categoria = 'Botiquín', tipo = 'marca', costo = 17.54, precio = 28.07 where sku = 'FC-34067851';

-- FC-48623006 | margen 60% | Pads Facial Protec Redondos C/100 | Degasa 2 $ 21.70 Pads Fa
update public.productos set nombre = 'Protec Pads Facial Redondos C/100', marca = 'Protec', presentacion = 'C/100', forma_farmaceutica = 'Pads', categoria = 'Cuidado personal', tipo = 'marca', costo = 21.7, precio = 34.72 where sku = 'FC-48623006';

-- FC-23272151 | margen 30% | Jeringa Sensimedical Insul 0.3 Ml C/100 | Jayor 1 $ Jeringa 
update public.productos set marca = 'Jayor', presentacion = '0.3 ML', forma_farmaceutica = 'Jeringa', categoria = 'Botiquín', tipo = 'marca', costo = 212.86, precio = 276.72 where sku = 'FC-23272151';

-- FC-68910041 | margen 60% | Algodon Dibar 5 Gr Dibar 12 $ 6.90 Descto: 2.0% $ 6.76 $ 82.
update public.productos set nombre = 'Algodon 5 12 5', presentacion = '5 G', forma_farmaceutica = 'Algodón', categoria = 'Botiquín', tipo = 'marca', costo = 0.58, precio = 0.93 where sku = 'FC-68910041';

-- FC-89100101 | margen 60% | Algodon Dibar 200 Gr Dibak 2 $ 35.30 Descto: 2.0% $ 34.59 70
update public.productos set nombre = 'Algodon 200 Dibak 2 70.60 200 Dibak', presentacion = '200 G', forma_farmaceutica = 'Algodón', categoria = 'Botiquín', tipo = 'marca', costo = 17.65, precio = 28.24 where sku = 'FC-89100101';

-- FC-34067301 | margen 60% | Venda Quirmex 7.5 Cm | Quirmex 12 $ 6.80 Descto: 2.0% $ 6.66
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', presentacion = '5 CM', forma_farmaceutica = 'Venda', categoria = 'Botiquín', tipo = 'marca', costo = 0.57, precio = 0.92 where sku = 'FC-34067301';

-- FC-34067471 | margen 60% | Venda Quirme) Lo Cm Quirmex 8.90 Descto: 2.0% $ 8.72 Lo Cm Q
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', forma_farmaceutica = 'Venda', categoria = 'Botiquín', tipo = 'marca', costo = 8.72, precio = 13.96 where sku = 'FC-34067471';

-- FC-34067781 | margen 60% | Venda Quirmex 30 Cm | Quirmex 24.20 Descto: 2.0% $ 23.72 96.
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', presentacion = '30 CM', forma_farmaceutica = 'Venda', categoria = 'Botiquín', tipo = 'marca', costo = 23.72, precio = 37.96 where sku = 'FC-34067781';

-- FC-68910034 | margen 60% | 60 Gr | Dibar Descto: 2.0% Algodon Dibar $ 10.10 60 Gr | Dib
update public.productos set nombre = 'Dibar Gr Algodon Algodon', marca = 'Dibar', presentacion = '60 G', tipo = 'marca', costo = 10.1, precio = 16.16 where sku = 'FC-68910034';

-- FC-66534951 | margen 60% | Crema Dent Colgate Total Colgate Palmolive $ Colgate Total C
update public.productos set marca = 'Colgate', forma_farmaceutica = 'Crema dental', categoria = 'Higiene', tipo = 'marca', costo = 22.93, precio = 36.69 where sku = 'FC-66534951';

-- FC-83510531 | margen 60% | Gel Antibacterial Protec 250 Ml Degasa 22.40 Antibacterial P
update public.productos set nombre = 'Protec Antibacterial 22.40 Antibacterial', marca = 'Protec', presentacion = '250 ML', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', costo = 123.58, precio = 197.73 where sku = 'FC-83510531';

-- FC-68900127 | margen 60% | Gasa Dibar 10X10 Paq 10 Cajitas/10 126.10 Dibar Gasa Dibar 1
update public.productos set nombre = 'Dibar 10X10 Paq 10 Cajitas/10 126.10 Gasa 10X10 Paq 10 Cajitas/10', marca = 'Dibar', forma_farmaceutica = 'Gasa', categoria = 'Botiquín', tipo = 'marca', costo = 123.58, precio = 197.73 where sku = 'FC-68900127';

-- FC-68900134 | margen 60% | Lox10 Exh C/100 Descto: 2.0% Gasa Dibar Dibar 111.10 Lox10 E
update public.productos set nombre = 'Lox10 Exh C/100 Gasa', presentacion = 'C/100', categoria = 'Producto', tipo = 'marca', costo = 108.88, precio = 174.21 where sku = 'FC-68900134';

-- FC-50882017 | margen 60% | Espuma 120 Mi Descto: 2.0% Dermodine Degasa Espuma 120 Mi De
update public.productos set nombre = 'Dermodine Espuma 120 Mi', marca = 'Dermodine', forma_farmaceutica = 'Espuma', categoria = 'Botiquín', tipo = 'marca', costo = 75.2, precio = 120.32 where sku = 'FC-50882017';

-- FC-08820243 | margen 60% | 0 Dermod Ine M 1 Degasa 37.60 Dermod Ine Degasa
update public.productos set nombre = 'Dermodine Ine M 1 37.60 Ine', marca = 'Dermodine', tipo = 'marca', costo = 36.85, precio = 58.97 where sku = 'FC-08820243';

-- FC-76000277 | margen 60% | Cre Vitacilina Humectante 100 Gr Vitacilina Humectante
update public.productos set nombre = 'Vitacilina Cre Humectante Humectante', marca = 'Vitacilina', presentacion = '100 G', tipo = 'marca', costo = 77.03, precio = 123.25 where sku = 'FC-76000277';

-- FC-51444145 | margen 60% | 0 Stick Tripack Des Old Spice Gr Pg Pere Descto: 2.0% Stick 
update public.productos set nombre = 'Old Spice', marca = 'Old Spice', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', costo = 135.73, precio = 217.17 where sku = 'FC-51444145';

-- FC-83351691 | margen 60% | Jermocleen Agua Oxigenada 230Ml Degasa Jermocleen Agua Oxige
update public.productos set nombre = 'Degasa Agua Oxigenada', marca = 'Degasa', presentacion = '230 ML', forma_farmaceutica = 'Agua oxigenada', categoria = 'Botiquín', tipo = 'marca', costo = 10.19, precio = 16.31 where sku = 'FC-83351691';

-- FC-83351381 | margen 60% | Dermocleen Agua Oxigenada 100Ml | Degasa $ Dermocleen Agua O
update public.productos set marca = 'Degasa', presentacion = '100 ML', forma_farmaceutica = 'Agua oxigenada', categoria = 'Botiquín', tipo = 'marca', costo = 7.64, precio = 12.23 where sku = 'FC-83351381';

-- FC-33956775 | margen 60% | Pedialyte Sr60 Uva 500 Mi Abbott $ 24.30 Pedialyte Sr60 Uva 
update public.productos set nombre = 'Pedialyte Sr60 Uva', marca = 'Pedialyte', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', costo = 24.3, precio = 38.89 where sku = 'FC-33956775';

-- FC-33961373 | margen 60% | Fresa 500 Pedialyte Sr60 Ml Abbott $ Fresa 500 Pedialyte Sr6
update public.productos set marca = 'Abbott', tipo = 'marca', costo = 23.81, precio = 38.1 where sku = 'FC-33961373';

-- FC-48335305 | margen 60% | Agua Oxigenada Dermocleen 480Ml | Degasa 15.00 Agua Oxigenad
update public.productos set nombre = 'Degasa 15.00 Agua Oxigenada', marca = 'Degasa', presentacion = '480 ML', forma_farmaceutica = 'Agua oxigenada', categoria = 'Botiquín', tipo = 'marca', costo = 14.7, precio = 23.52 where sku = 'FC-48335305';

-- FC-33954740 | margen 60% | Manzana 500 Ml Descto: 2.0% Pedialyte Manzana 500 Ml Pedialy
update public.productos set nombre = 'Pedialyte', marca = 'Pedialyte', presentacion = '500 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', costo = 23.81, precio = 38.1 where sku = 'FC-33954740';

-- FC-59225411 | margen 60% | Inder 360 Gf Descto: 2.0% Leche Nido Marcas Nestle Inder 360
update public.productos set nombre = 'Nido', marca = 'Nido', categoria = 'Producto', tipo = 'marca', costo = 74.19, precio = 118.71 where sku = 'FC-59225411';

-- FC-51067711 | margen 60% | 360 Gr | Marcas Descto: 2.0% Leche Nidal 1 Nestle $ 112.70 3
update public.productos set nombre = 'Nido', marca = 'Nido', categoria = 'Producto', tipo = 'marca', costo = 112.7, precio = 180.33 where sku = 'FC-51067711';

-- FC-86167151 | margen 60% | Nestum Probioticos Marcas Nestle Avena 270 Nestum Probiotico
update public.productos set nombre = 'Nestum Probioticos Avena 270 Probioticos', marca = 'Nestum', forma_farmaceutica = 'Suplemento', categoria = 'Abarrotes', tipo = 'marca', costo = 52.43, precio = 83.89 where sku = 'FC-86167151';

-- FC-92821171 | margen 60% | Nutri Rindes Leche Nido Marcas Nestle Bolsa 240 Gr Nutri Rin
update public.productos set nombre = 'Nido Nido Nestle Bolsa Nestle', marca = 'Nido', presentacion = '240 G', forma_farmaceutica = 'Leche', categoria = 'Abarrotes', tipo = 'marca', costo = 30.67, precio = 49.08 where sku = 'FC-92821171';

-- FC-58611420 | margen 60% | Nutri Rindes Leche Nido Marcas Nestle Bolsa Nutri Rindes Lec
update public.productos set nombre = 'Nido Nido Nestle Bolsa', marca = 'Nido', forma_farmaceutica = 'Leche', categoria = 'Abarrotes', tipo = 'marca', costo = 53.7, precio = 85.93 where sku = 'FC-58611420';

-- FC-51078461 | margen 60% | Öpt Imal Leche Nan 1 Marcas Pro Öpt Imal Leche Nan 1
update public.productos set nombre = 'Nan 1 Pro 1', marca = 'Nan', tipo = 'marca', costo = 129.4, precio = 207.05 where sku = 'FC-51078461';

-- FC-51078531 | margen 60% | Öptimal Marcas Nestle Bolsa Leche Nan 2 Gr Öptimal Marcas Ne
update public.productos set nombre = 'Nan Nestle Bolsa Nestle Bolsa', marca = 'Nan', presentacion = '2 G', tipo = 'marca', costo = 58.7, precio = 93.93 where sku = 'FC-51078531';

-- FC-29003221 | margen 60% | Vaso Recolector I Quirmex Quirmex Descto: 2.0% $ 3.70 Recole
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', forma_farmaceutica = 'Vaso recolector', categoria = 'Botiquín', tipo = 'marca', costo = 3.7, precio = 5.93 where sku = 'FC-29003221';

-- FC-51448511 | margen 60% | 525 Ml | Lab Pisa Electrolit Uva $ 20,50 Descto: 2.0% $ 20.0
update public.productos set nombre = 'Electrolit Uva', marca = 'Electrolit', presentacion = '525 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', costo = 20.5, precio = 32.81 where sku = 'FC-51448511';

-- FC-25104411 | margen 60% | Electrolit Coco 625 Ml Lab Pisa 20.50 Descto: 2.0% Electroli
update public.productos set nombre = 'Electrolit Coco', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', costo = 20.09, precio = 32.15 where sku = 'FC-25104411';

-- FC-25149221 | margen 60% | Electrolit Eresa-Kiwi 625 Ml | Lab Pisa 2 20.50 Electrolit E
update public.productos set nombre = 'Electrolit Eresa-Kiwi', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', costo = 20.09, precio = 32.15 where sku = 'FC-25149221';

-- FC-25104268 | margen 60% | Electrolit Èresa 625 Mi | Lab Pisa $ 20.50 Descto: 2.0K $ 20
update public.productos set nombre = 'Electrolit Fresa', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', costo = 20.5, precio = 32.81 where sku = 'FC-25104268';

-- FC-51747971 | margen 60% | Electrolid Mora Azul 625 Ml | Lab Pisa 2 $ 20.50 Descto: 2.0
update public.productos set nombre = 'Electrolit Mora Azul', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', costo = 20.5, precio = 32.81 where sku = 'FC-51747971';

-- FC-43471900 | margen 60% | Absorsec C/120 Clark Descto: 2.0% Toa Hum Kimberly Absorsec 
update public.productos set nombre = 'Absorsec C/120 Toa Hum', presentacion = 'C/120', forma_farmaceutica = 'Toallas húmedas', categoria = 'Higiene', tipo = 'marca', costo = 21.46, precio = 34.34 where sku = 'FC-43471900';

-- FC-34064021 | margen 60% | Cotonetes Quirmex Tarro C/100 1 Quirmex 2 12.00 Cotonetes Qu
update public.productos set nombre = 'Quirmex Tarro 1 2 12.00 Cotonetes Tarro 1', marca = 'Quirmex', presentacion = 'C/100', forma_farmaceutica = 'Cotonetes', categoria = 'Higiene', tipo = 'marca', costo = 11.76, precio = 18.82 where sku = 'FC-34064021';

-- FC-14983153 | margen 60% | Lubricante Prudence Grosella 75 Ml | Dkt Mexico $ 68.20 Lubr
update public.productos set nombre = 'Prudence Grosella', marca = 'Prudence', presentacion = '75 ML', forma_farmaceutica = 'Lubricante', categoria = 'Higiene', tipo = 'marca', costo = 68.2, precio = 109.12 where sku = 'FC-14983153';

-- FC-43454811 | margen 60% | Toa -Hum Huggies Cuidado Puro C/80 | Kimberly Clark $ 39.60 
update public.productos set nombre = 'Huggies Toa -Hum Cuidado Puro C/80 K 9 Cuidado Puro C/80', marca = 'Huggies', presentacion = 'C/80', forma_farmaceutica = 'Toallas húmedas', categoria = 'Higiene', tipo = 'marca', costo = 39.6, precio = 63.37 where sku = 'FC-43454811';

-- FC-49824391 | margen 60% | Retardante C/3 Descto: 9.0% [7502214985348] Cond Prudence 'U
update public.productos set nombre = 'Prudence ''Ull Retardante C/3', marca = 'Prudence', presentacion = 'C/3', categoria = 'Producto', tipo = 'marca', costo = 48.6, precio = 77.77 where sku = 'FC-49824391';

-- FC-14985348 | margen 60% | Cond Prudence 'Ull Sensitive C/3 Dkt Cond Prudence 'Ull Sens
update public.productos set nombre = 'Prudence Ull Sensitive Cond ''Ull Sensitive', marca = 'Prudence', presentacion = 'C/3', forma_farmaceutica = 'Condón', categoria = 'Higiene', tipo = 'marca', costo = 41.31, precio = 66.1 where sku = 'FC-14985348';

-- FC-49853867 | margen 60% | Cond Prudence Extra Pleasure C/3 Dkt Cond Prudence Extra Ple
update public.productos set nombre = 'Softlub Extra Cond Extra', marca = 'Softlub', presentacion = 'C/3', forma_farmaceutica = 'Condón', categoria = 'Higiene', tipo = 'marca', costo = 41.31, precio = 66.1 where sku = 'FC-49853867';

-- FC-49824911 | margen 60% | Cond Prudence Iva C/3 Dki Mexico S Cond Prudence Iva C/3 Mex
update public.productos set nombre = 'Prudence Iva Dki Mexico S Cond Iva Mexico', marca = 'Prudence', presentacion = 'C/3', forma_farmaceutica = 'Condón', categoria = 'Higiene', tipo = 'marca', costo = 31.03, precio = 49.65 where sku = 'FC-49824911';

-- FC-14985805 | margen 60% | Cond Prudence Chicle C/E Idkt Cond Prudence Chicle
update public.productos set nombre = 'Prudence Chicle C/E Idkt Cond Chicle', marca = 'Prudence', forma_farmaceutica = 'Condón', categoria = 'Higiene', tipo = 'marca', costo = 44.23, precio = 70.77 where sku = 'FC-14985805';

-- FC-14983726 | margen 60% | Lubricante Prudence Natural 75 Ml Lubricante Prudence Natura
update public.productos set nombre = 'Prudence Natural Lubricante Natural', marca = 'Prudence', presentacion = '75 ML', forma_farmaceutica = 'Lubricante', categoria = 'Higiene', tipo = 'marca', costo = 62.06, precio = 99.3 where sku = 'FC-14983726';

-- FC-49824771 | margen 60% | Fresa C/3 I Dkt Descto: 9.0% Cond Prudence Fresa I Dkt Cond 
update public.productos set nombre = 'Prudence Fresa', marca = 'Prudence', presentacion = 'C/3', categoria = 'Producto', tipo = 'marca', costo = 31.03, precio = 49.65 where sku = 'FC-49824771';

-- FC-58203691 | margen 60% | 0.9 Mt Hilo Dental Ğum Expanding Sunstar Americasi $ 18.90 D
update public.productos set nombre = 'Sunstar 0.9 Mt Hilo Dental Ğum Expanding Hilo Dental Ğum Expanding', marca = 'Sunstar', tipo = 'marca', costo = 18.9, precio = 30.24 where sku = 'FC-58203691';

-- FC-14982514 | margen 60% | Chocolate C/3 Descto: 9.0% Cond Prudence Dkt Mexico $ 34.10 
update public.productos set nombre = 'Prudence', marca = 'Prudence', presentacion = 'C/3', categoria = 'Producto', tipo = 'marca', costo = 34.1, precio = 54.56 where sku = 'FC-14982514';

-- FC-45079011 | margen 60% | Eresa Pomada Labello Bde Merico $ 56.50 Descto: 2.0% Eresa P
update public.productos set nombre = 'Labello', marca = 'Labello', forma_farmaceutica = 'POMADA', categoria = 'Otro', tipo = 'marca', costo = 56.5, precio = 90.4 where sku = 'FC-45079011';

-- FC-14980596 | margen 60% | Mora C/3 Dkt Cond Prudence Mexico 34.10 Mora C/3 Cond Pruden
update public.productos set nombre = 'Prudence Mora Cond Mexico 34.10 Mora Cond Mexico', marca = 'Prudence', presentacion = 'C/3', tipo = 'marca', costo = 31.03, precio = 49.65 where sku = 'FC-14980596';

-- FC-49800151 | margen 60% | Cond Prudence Clasico C/3 I Dkt Mexico 32.20 Descto: 9.0% Co
update public.productos set nombre = 'Prudence Clasico C/3', marca = 'Prudence', presentacion = 'C/3', forma_farmaceutica = 'Condón', categoria = 'Higiene', tipo = 'marca', costo = 29.3, precio = 46.88 where sku = 'FC-49800151';

-- FC-62746605 | margen 30% | Jarabe 250 Ml 1 Nat Descto: 2.0% Ajolotius Bioal Imentos Jar
update public.productos set nombre = 'Jarabe 250 Ml 1 Nat Ajolotius Bioal Imentos', marca = 'Jarabe', presentacion = 'JARABE', concentracion = '250 ML 1 AJOLOTIUS BIOAL IMENTOS', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', costo = 28.0, precio = 36.4 where sku = 'FC-62746605';

-- FC-45045281 | margen 60% | Pomada Labello Hydro-C I Bde Mexico $ 56.50 Descto: 2.0% $ 5
update public.productos set nombre = 'Labello Hydro-C', marca = 'Labello', forma_farmaceutica = 'POMADA', categoria = 'Otro', tipo = 'marca', costo = 56.5, precio = 90.4 where sku = 'FC-45045281';

-- FC-54504870 | margen 60% | Pomada I.Abeili.C Lasico | Rde Mexic( 56.50 Descto: 2.0% $ 5
update public.productos set nombre = 'Lásico Pomada I.Abeili.C 56.50 56.50', marca = 'Lásico', forma_farmaceutica = 'POMADA', categoria = 'Otro', tipo = 'marca', costo = 55.37, precio = 88.6 where sku = 'FC-54504870';

-- FC-52400212 | margen 30% | Ajolotius Jengibre Tab C/10 Bioalimentos Nati Jengibre C/10 
update public.productos set nombre = 'Ajolotius Jengibre Tab Nati Jengibre', marca = 'Ajolotius', presentacion = 'C/10', tipo = 'marca', costo = 20.5, precio = 26.65 where sku = 'FC-52400212';

-- FC-24004581 | margen 60% | Ajolotius Pastillas Elderberry Past Bioalimentos Nat $ 21.00
update public.productos set nombre = 'Ajolotius Pastillas Elderberry Past', marca = 'Ajolotius', categoria = 'Producto', tipo = 'marca', costo = 21.0, precio = 33.6 where sku = 'FC-24004581';

-- FC-56034041 | margen 60% | Toa Hum Escudo Intbacterial C/50 $ Besbfrzy Clark 15.60 Toa 
update public.productos set marca = 'Escudo', presentacion = 'C/50', forma_farmaceutica = 'Toallas húmedas', categoria = 'Higiene', tipo = 'marca', costo = 15.29, precio = 24.47 where sku = 'FC-56034041';

-- FC-21042481 | margen 60% | 1083 Oro Manzanilla Ml Hnos 31.40 Descto: 2.0% Oro Manzanill
update public.productos set nombre = 'Manzanilla Ml Hnos 31.40 Hnos', marca = 'Manzanilla', categoria = 'Producto', tipo = 'marca', costo = 30.77, precio = 49.24 where sku = 'FC-21042481';

-- FC-52400267 | margen 60% | , Ajolotius Jbe Elderberry 2501 Bioalimentos Nati 74.70 $ $ 
update public.productos set nombre = 'Ajolotius', marca = 'Ajolotius', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', costo = 73.21, precio = 117.14 where sku = 'FC-52400267';

-- FC-62746612 | margen 30% | Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos Nati $ 89.2
update public.productos set nombre = 'Ajolotius', marca = 'Ajolotius', presentacion = 'JARABE', concentracion = 'S/AZUCAR 250 ML. I BIOALIMENTOS NATI', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', costo = 89.2, precio = 115.96 where sku = 'FC-62746612';

-- FC-52400038 | margen 60% | Ajolotius Menta Eucal S/Azucar Past Ajolotius Menta Eucal
update public.productos set nombre = 'Ajolotius Menta Eucal S/Azucar Past Menta Eucal', marca = 'Ajolotius', tipo = 'marca', costo = 21.36, precio = 34.18 where sku = 'FC-52400038';

-- FC-62746698 | margen 30% | Ajolotius Jarabe Reforzado 250 Ml Bioalimentos Nat: Ajolotiu
update public.productos set nombre = 'Ajolotius', marca = 'Ajolotius', presentacion = 'JARABE', concentracion = 'REFORZADO 250 ML BIOALIMENTOS NAT: AJOLOTIUS JARABE REFORZADO', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', costo = 7.45, precio = 9.69 where sku = 'FC-62746698';

-- FC-45307181 | margen 60% | Poroso Arnica Parche Leon Bde Poroso Arnica Parche
update public.productos set nombre = 'Arnica Bde Parche', marca = 'Arnica', tipo = 'marca', costo = 149.35, precio = 238.96 where sku = 'FC-45307181';

-- FC-62746643 | margen 60% | Ajolotius Menta Fucal C/10 Bioalimentos Ajolotius Menta Fuca
update public.productos set nombre = 'Ajolotius Menta Fucal Menta Fucal', marca = 'Ajolotius', presentacion = 'C/10', tipo = 'marca', costo = 19.5, precio = 31.21 where sku = 'FC-62746643';


-- Resumen
select tipo, count(*) as n, round(avg(precio/costo - 1)*100,1) as margen_prom_pct
from public.productos
where sku like 'FC-%' and costo > 0
group by tipo order by 1;

commit;

-- ═══════════════════════════════════════════════════════════
-- VERIFICACIÓN FINAL
-- ═══════════════════════════════════════════════════════════

select count(*) as productos_fc
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';

select sum(cantidad_actual) as piezas_en_lotes from public.lotes where coalesce(activo, true);

select
  count(*) filter (where codigo_barras is not null and btrim(codigo_barras) <> '') as con_barcode,
  count(*) filter (where marca is not null and btrim(marca) <> '') as con_marca,
  count(*) filter (where presentacion is not null and btrim(presentacion) <> '') as con_presentacion
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';

select
  count(*) as lotes_activos,
  count(*) filter (where proveedor_id is not null) as lotes_con_tienda
from public.lotes
where coalesce(activo, true);

