-- ============================================================================
-- Galaxal Lacosamida 50 mg · Teva · caja con 14 tabletas
--
-- Caja física (fotos mostrador) + ficha FESA / Farmalisto / Sanorim:
--   EAN 7501559603757 · SKU FC-59603757 (últimos 8 del EAN)
--   Costo $226 · PVP $250 (precios de compra/venta reales; no piso markup)
--   Receta: sí (antiepiléptico)
--
-- Stock 0 hasta Recibir. Sin inventar lote ni caducidad.
-- Foto: public/catalogo-propia/galaxal-lacosamida-50mg-c14-7501559603757.jpg
--       packshot FESA (EAN en path). jsDelivr inmediato + /catalogo-propia/ tras deploy.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta,
  disponible, visible_tienda
)
select
  'Galaxal 50 mg',
  'FC-59603757',
  '7501559603757',
  'Medicamentos',
  'Neurología',
  'marca',
  'Alta mostrador · Teva Galaxal lacosamida 50 mg C/14 · EAN 7501559603757 · costo $226 · PVP $250',
  'Teva',
  'Caja con 14 tabletas',
  'Lacosamida',
  '50 mg',
  'Tableta',
  226,
  250,
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@82541ecd/public/catalogo-propia/galaxal-lacosamida-50mg-c14-7501559603757.jpg',
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@82541ecd/public/catalogo-propia/galaxal-lacosamida-50mg-c14-7501559603757.jpg',
  0,
  1,
  true,
  true,
  'inmediato',
  true
where public.fc_buscar_producto_escaneo('7501559603757') is null
  and public.fc_buscar_producto_escaneo('FC-59603757') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501559603757'
       or p.sku = 'FC-59603757'
  );

-- Si ya existía: completar ficha sin pisar costo/PVP/stock/foto buena.
update public.productos p
set
  nombre = coalesce(nullif(btrim(p.nombre), ''), 'Galaxal 50 mg'),
  marca = coalesce(nullif(btrim(p.marca), ''), 'Teva'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Caja con 14 tabletas'),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), 'Lacosamida'),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '50 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Tableta'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Medicamentos'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Neurología'),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'marca'),
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), '7501559603757'),
  costo = case when coalesce(p.costo, 0) <= 0.01 then 226 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 1 then 250 else p.precio end,
  requiere_receta = true,
  activo = true,
  visible_tienda = true,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  imagen_url = coalesce(
    nullif(btrim(p.imagen_url), ''),
    'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@82541ecd/public/catalogo-propia/galaxal-lacosamida-50mg-c14-7501559603757.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(p.imagen_mobile_url), ''),
    'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@82541ecd/public/catalogo-propia/galaxal-lacosamida-50mg-c14-7501559603757.jpg'
  )
where p.codigo_barras = '7501559603757'
   or p.sku = 'FC-59603757';

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@82541ecd/public/catalogo-propia/galaxal-lacosamida-50mg-c14-7501559603757.jpg',
  'catalogo-propia/galaxal-lacosamida-50mg-c14-7501559603757.jpg',
  0,
  true,
  'propia'
from public.productos p
where (p.codigo_barras = '7501559603757' or p.sku = 'FC-59603757')
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%galaxal-lacosamida-50mg-c14-7501559603757%'
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.principio_activo,
  p.concentracion,
  p.presentacion,
  p.forma_farmaceutica,
  p.categoria,
  p.subcategoria,
  p.tipo,
  p.costo,
  p.precio,
  p.stock,
  p.requiere_receta,
  left(p.imagen_url, 96) as foto
from public.productos p
where p.codigo_barras = '7501559603757'
   or p.sku = 'FC-59603757';
