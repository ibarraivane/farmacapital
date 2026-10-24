-- ============================================================================
-- Alta mostrador (fotos caja 2026-10-23): Klonaza + Xarelto
-- Stock 1 c/u. Sin inventar lote ni caducidad (null hasta ver MMAA en caja).
-- Costo null hasta compra; precio = ancla retail.
--
-- 1) Klonaza Atlantis · Floroglucinol / Trimetilfloroglucinol / Clonixinato
--    80 mg / 80 mg / 125 mg · C/20 cápsulas · EAN 7501471800029
--    NO confundir con FC-71800210 (7501471800210) solo floroglucinol/trimetil C/20.
--    Ancla Farmalisto $304 → PVP $304
--
-- 2) Xarelto Bayer · Rivaroxabán 20 mg · C/28 tabletas · EAN 7501318608788
--    Reg. No. 357M2008 SSA IV · ancla Vitau $3214 → PVP $3214
--
-- Fotos: public/catalogo-propia/
--   klonaza-80-80-125-c20-7501471800029.jpg
--   xarelto-20mg-c28-7501318608788.jpg
-- ORDEN: 1) merge/deploy  2) pegar TODO este SQL en Supabase → Run.
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  ---------------------------------------------------------------------------
  -- 1) Klonaza Atlantis C/20 · EAN 7501471800029 · físico 1
  ---------------------------------------------------------------------------
  if exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501471800029'
       or p.sku in ('FC-71800029', 'FC-ND-71800029')
  ) then
    raise notice 'Klonaza 7501471800029 ya existe; no se inserta.';
  else
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Klonaza',
        'sku', 'FC-71800029',
        'codigo_barras', '7501471800029',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Alta foto mostrador 2026-10-23 · Atlantis Klonaza floroglucinol/trimetilfloroglucinol/clonixinato 80/80/125 mg C/20 cápsulas · EAN 7501471800029 · ancla Farmalisto $304 · stock 1 · sin costo de compra · receta',
        'precio', 304,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', true
      ),
      1,
      'INV-MOSTRADOR-20261023',
      null::date,
      null::numeric,
      null::bigint
    ) f;

    update public.productos set
      marca = 'Atlantis',
      presentacion = 'Caja con 20 cápsulas',
      principio_activo = 'Floroglucinol / Trimetilfloroglucinol / Clonixinato de lisina',
      concentracion = '80 mg / 80 mg / 125 mg',
      forma_farmaceutica = 'Cápsulas',
      subcategoria = 'Antiespasmódicos',
      laboratorio = 'Atlantis Pharma / Tecnofarma',
      disponible = 'inmediato',
      visible_tienda = true,
      imagen_url = 'https://www.farmacapital.mx/catalogo-propia/klonaza-80-80-125-c20-7501471800029.jpg',
      imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/klonaza-80-80-125-c20-7501471800029.jpg'
    where id = v_pid;

    raise notice 'Klonaza creado id % lote % stock 1 PVP 304', v_pid, v_lid;
  end if;

  ---------------------------------------------------------------------------
  -- 2) Xarelto Bayer 20 mg C/28 · EAN 7501318608788 · físico 1
  ---------------------------------------------------------------------------
  if exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501318608788'
       or p.sku in ('FC-18608788', 'FC-ND-18608788')
  ) then
    raise notice 'Xarelto 7501318608788 ya existe; no se inserta.';
  else
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Xarelto 20 mg',
        'sku', 'FC-18608788',
        'codigo_barras', '7501318608788',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Alta foto mostrador 2026-10-23 · Bayer Xarelto rivaroxabán 20 mg C/28 tabletas · EAN 7501318608788 · Reg. 357M2008 SSA IV · ancla Vitau $3214 · stock 1 · sin costo de compra · receta',
        'precio', 3214,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', true
      ),
      1,
      'INV-MOSTRADOR-20261023',
      null::date,
      null::numeric,
      null::bigint
    ) f;

    update public.productos set
      marca = 'Bayer',
      presentacion = 'Caja con 28 tabletas',
      principio_activo = 'Rivaroxabán',
      concentracion = '20 mg',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Anticoagulantes',
      laboratorio = 'Bayer',
      disponible = 'inmediato',
      visible_tienda = true,
      imagen_url = 'https://www.farmacapital.mx/catalogo-propia/xarelto-20mg-c28-7501318608788.jpg',
      imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/xarelto-20mg-c28-7501318608788.jpg'
    where id = v_pid;

    raise notice 'Xarelto 20 mg creado id % lote % stock 1 PVP 3214', v_pid, v_lid;
  end if;
end $$;

-- Si ya existían: asegurar ficha + llevar stock a 1 (sin inventar caducidad)
update public.productos p
set
  nombre = coalesce(nullif(btrim(p.nombre), ''), 'Klonaza'),
  marca = coalesce(nullif(btrim(p.marca), ''), 'Atlantis'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Caja con 20 cápsulas'),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''),
    'Floroglucinol / Trimetilfloroglucinol / Clonixinato de lisina'),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '80 mg / 80 mg / 125 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Cápsulas'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Medicamentos'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Antiespasmódicos'),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'marca'),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'Atlantis Pharma / Tecnofarma'),
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), '7501471800029'),
  precio = case when coalesce(p.precio, 0) <= 1 then 304 else p.precio end,
  requiere_receta = true,
  activo = true,
  visible_tienda = true,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  imagen_url = coalesce(
    nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/klonaza-80-80-125-c20-7501471800029.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/klonaza-80-80-125-c20-7501471800029.jpg'
  )
where p.codigo_barras = '7501471800029'
   or p.sku in ('FC-71800029', 'FC-ND-71800029');

update public.productos p
set
  nombre = coalesce(nullif(btrim(p.nombre), ''), 'Xarelto 20 mg'),
  marca = coalesce(nullif(btrim(p.marca), ''), 'Bayer'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Caja con 28 tabletas'),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), 'Rivaroxabán'),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '20 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Tabletas'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Medicamentos'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Anticoagulantes'),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'marca'),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'Bayer'),
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), '7501318608788'),
  precio = case when coalesce(p.precio, 0) <= 1 then 3214 else p.precio end,
  requiere_receta = true,
  activo = true,
  visible_tienda = true,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  imagen_url = coalesce(
    nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/xarelto-20mg-c28-7501318608788.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/xarelto-20mg-c28-7501318608788.jpg'
  )
where p.codigo_barras = '7501318608788'
   or p.sku in ('FC-18608788', 'FC-ND-18608788');

-- Ajuste stock → 1 si el producto ya existía sin piezas (o distinto)
do $$
declare
  r record;
  v_sum integer;
  v_lote bigint;
  v_costo numeric;
begin
  for r in
    select id, sku, codigo_barras
    from public.productos
    where codigo_barras in ('7501471800029', '7501318608788')
       or sku in ('FC-71800029', 'FC-ND-71800029', 'FC-18608788', 'FC-ND-18608788')
  loop
    select coalesce(sum(cantidad_actual), 0) into v_sum
      from public.lotes
     where producto_id = r.id and coalesce(activo, true);
    if v_sum is distinct from 1 then
      select costo into v_costo from public.productos where id = r.id;
      select id into v_lote from public.lotes
       where producto_id = r.id
       order by coalesce(activo, true) desc, coalesce(cantidad_actual, 0) desc, id desc
       limit 1;
      if v_lote is null then
        insert into public.lotes (
          producto_id, numero_lote, cantidad_inicial, cantidad_actual,
          fecha_caducidad, costo_unitario, activo
        ) values (r.id, 'INV-MOSTRADOR-20261023', 1, 1, null, v_costo, true);
      else
        update public.lotes set cantidad_actual = 0, activo = false
         where producto_id = r.id and id <> v_lote
           and coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0;
        update public.lotes
           set cantidad_actual = 1, activo = true,
               cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), 1)
         where id = v_lote;
      end if;
      insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
      values (r.id, 'ajuste', 1,
        'Alta foto mostrador 2026-10-23 · ' || coalesce(r.sku, r.codigo_barras) || ' → 1');
      raise notice 'Stock ajustado a 1 para %', coalesce(r.sku, r.codigo_barras);
    end if;
  end loop;
end $$;

-- Galería (idempotente)
insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  u.url,
  u.storage_path,
  0,
  true,
  'propia'
from (
  values
    ('7501471800029',
     'https://www.farmacapital.mx/catalogo-propia/klonaza-80-80-125-c20-7501471800029.jpg',
     'catalogo-propia/klonaza-80-80-125-c20-7501471800029.jpg'),
    ('7501318608788',
     'https://www.farmacapital.mx/catalogo-propia/xarelto-20mg-c28-7501318608788.jpg',
     'catalogo-propia/xarelto-20mg-c28-7501318608788.jpg')
) as u(ean, url, storage_path)
join public.productos p on p.codigo_barras = u.ean
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = p.id
    and i.storage_path = u.storage_path
);

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.principio_activo,
  p.concentracion,
  p.presentacion,
  p.tipo,
  p.costo,
  p.precio,
  p.stock,
  p.requiere_receta,
  left(p.imagen_url, 96) as foto
from public.productos p
where p.codigo_barras in ('7501471800029', '7501318608788')
   or p.sku in (
     'FC-71800029', 'FC-ND-71800029',
     'FC-18608788', 'FC-ND-18608788'
   )
order by p.sku;
