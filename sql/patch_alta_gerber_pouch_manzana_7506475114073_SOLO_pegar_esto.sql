-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Alta: Gerber Junior pouch manzana 95 g
-- EAN de caja: 7506475114073 (SKU FC-75114073)
-- Distinto del Etapa 2 manzana frasco 100 g (7506475102421 / FC-75102421).
-- Stock 0. Sin caducidad inventada. Sin dollar-quote. Sin producto_imagenes.
-- Idempotente.
-- =============================================================================

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, laboratorio,
  imagen_url, imagen_mobile_url
)
select
  'Gerber Junior pouch manzana 95 g',
  'FC-75114073',
  '7506475114073',
  'Bebes',
  'marca',
  'Alta EAN caja · Gerber pouch manzana 95 g · Open Food Facts / Nestle',
  12.79,
  16,
  0,
  1,
  true,
  false,
  'Gerber',
  'Pouch 95 g',
  'Papilla',
  'Nestle',
  'https://www.farmacapital.mx/catalogo-propia/gerber-junior-pouch-manzana-95g-7506475114073.jpg',
  'https://www.farmacapital.mx/catalogo-propia/gerber-junior-pouch-manzana-95g-7506475114073.jpg'
where public.fc_buscar_producto_escaneo('7506475114073') is null
  and public.fc_buscar_producto_escaneo('FC-75114073') is null
  and not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = '7506475114073'
       or p.sku = 'FC-75114073'
  );

-- Si el SKU canónico ya está en otro EAN, alta con FC-ND-
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, laboratorio,
  imagen_url, imagen_mobile_url
)
select
  'Gerber Junior pouch manzana 95 g',
  'FC-ND-75114073',
  '7506475114073',
  'Bebes',
  'marca',
  'Alta EAN caja · Gerber pouch manzana 95 g · SKU canónico ocupado',
  12.79,
  16,
  0,
  1,
  true,
  false,
  'Gerber',
  'Pouch 95 g',
  'Papilla',
  'Nestle',
  'https://www.farmacapital.mx/catalogo-propia/gerber-junior-pouch-manzana-95g-7506475114073.jpg',
  'https://www.farmacapital.mx/catalogo-propia/gerber-junior-pouch-manzana-95g-7506475114073.jpg'
where public.fc_buscar_producto_escaneo('7506475114073') is null
  and exists (
    select 1 from public.productos p
    where p.sku = 'FC-75114073'
      and coalesce(p.codigo_barras, '') <> '7506475114073'
  )
  and not exists (
    select 1 from public.productos p where p.sku = 'FC-ND-75114073'
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then 'Gerber Junior pouch manzana 95 g'
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), 'Gerber'),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), 'Pouch 95 g'),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), 'Papilla'),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), 'Nestle'),
  categoria = coalesce(nullif(trim(p.categoria), ''), 'Bebes'),
  tipo = coalesce(nullif(trim(p.tipo), ''), 'marca'),
  costo = case when coalesce(p.costo, 0) <= 0 then 12.79 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 0 then 16 else p.precio end,
  imagen_url = coalesce(
    nullif(trim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/gerber-junior-pouch-manzana-95g-7506475114073.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(trim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/gerber-junior-pouch-manzana-95g-7506475114073.jpg'
  ),
  updated_at = now()
where p.codigo_barras = '7506475114073'
   or p.sku in ('FC-75114073', 'FC-ND-75114073');

-- VERIFICACION
select id, sku, codigo_barras, nombre, presentacion, costo, precio, left(imagen_url, 80) as imagen
from public.productos
where codigo_barras = '7506475114073'
   or sku in ('FC-75114073', 'FC-ND-75114073', 'FC-75102421')
order by sku;

select public.fc_buscar_producto_escaneo('7506475114073') as pid_escaneo;

commit;
