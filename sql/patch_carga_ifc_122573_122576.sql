-- Farma Centre / IFC F8 Tienda · altas de catálogo (122573 + 122576).
-- SIN bloques dollar-quote. Stock = 0; entra al escanear en Recibir.
-- Fotos: URL de ficha (Mayfar/Kohn). Copias en public/catalogo-propia/
-- para sql de foto propia DESPUÉS del deploy (como Dibar).
-- Orden: 1) este archivo  2) patch_recepcion_ifc_122573.sql
--         3) patch_recepcion_ifc_122576.sql
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.

begin;

-- 1) Reomatolum: ya existe; costo + ficha; no pisa PVP ni foto buena
update public.productos set
  costo = 20.00,
  marca = coalesce(nullif(btrim(marca), ''), 'Del Viejito'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '60 g'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Pomada'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
  codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7503002045008'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://acdn-us.mitiendanube.com/stores/004/824/171/products/mer128-8c5715a7144487dbd317373352570961-640-0.webp')
where sku = 'FC-1FBF5206'
   or codigo_barras = '7503002045008';

-- 2) Kohn lavaojos plástico
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Kohn lavaojos de plástico',
  'FC-46604917',
  '7506346604917',
  'Dispositivo médico',
  'marca',
  'Ticket IFC 122573 · Farma Centre · EAN Sufarmed · foto Kohn México',
  4.00, 7.00, 0, 2, true, false,
  'Kohn',
  'Pieza',
  'Dispositivo',
  'https://kohnmexico.com/wp-content/uploads/2016/12/lava_ojos.jpg'
where public.fc_buscar_producto_escaneo('7506346604917') is null
  and not exists (select 1 from public.productos where sku = 'FC-46604917');

update public.productos set
  costo = 4.00,
  precio = case when coalesce(precio, 0) <= 0 then 7.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Kohn'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Pieza'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Dispositivo médico'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://kohnmexico.com/wp-content/uploads/2016/12/lava_ojos.jpg')
where sku = 'FC-46604917' or codigo_barras = '7506346604917';

-- 3) Mercurio Pomada Manzana (sin EAN público; ligar código de la caja)
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio Pomada Manzana 50 g',
  'FC-MER-MANZANA',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 122576 · Farma Centre · ficha Mayfar MER-010 · falta EAN de caja',
  9.50, 16.00, 0, 2, true, false,
  'Mercurio',
  '50 g',
  'Pomada',
  'https://acdn-us.mitiendanube.com/stores/004/824/171/products/mer010-3391c4a7525545e5be17194451807817-640-0.webp'
where not exists (select 1 from public.productos where sku = 'FC-MER-MANZANA');

update public.productos set
  costo = 9.50,
  precio = case when coalesce(precio, 0) <= 0 then 16.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '50 g'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Pomada'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://acdn-us.mitiendanube.com/stores/004/824/171/products/mer010-3391c4a7525545e5be17194451807817-640-0.webp')
where sku = 'FC-MER-MANZANA';

commit;

select sku, codigo_barras as ean, left(nombre, 42) as nombre, costo, precio, stock,
  left(imagen_url, 72) as foto
from public.productos
where sku in ('FC-1FBF5206', 'FC-46604917', 'FC-MER-MANZANA')
   or codigo_barras in ('7503002045008', '7506346604917')
order by sku;
