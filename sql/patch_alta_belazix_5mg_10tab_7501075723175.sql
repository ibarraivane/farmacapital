-- Alta Belazix (Levocetirizina) 5 mg · Novag · caja con 10 tabletas.
-- EAN 7501075723175 (caja física / pistola). NO confundir con EQ-NOV154
-- Belazix C/20 (EAN 7501075722604), que sí está en catálogo.
--
-- Por qué no salía al escanear: el C/10 nunca tuvo fila con este EAN.
-- El C/20 (EQ-NOV154) es otra presentación.
--
-- Costo ancla: ticket Farma MX 108588 · BELAZIX TABLETAS 5 MG C/10 · $33.12.
-- Precio: genérico +60% al costo → ceil(33.12×1.6) = $53.
-- 3 cajas en mostrador (stock 3). Caducidad/lote: no inventar; si la caja
-- trae MMAA, capturarlos en Recibir / lotes después.
-- Foto: public/catalogo-propia/belazix-5mg-10tab-novag-7501075723175.jpg
--       (caja real). Correr este SQL DESPUÉS del deploy de Vercel.
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Belazix 5 mg',
  'FC-75723175',
  '7501075723175',
  'Alergia',
  'Antihistamínico',
  'generico',
  'Alta mostrador · EAN C/10 7501075723175 · distinto del Belazix C/20 EQ-NOV154 · costo Farmamx $33.12 · 3 pzas físicas',
  'Novag',
  '10 tabletas',
  'Levocetirizina',
  '5 mg',
  'Tabletas',
  33.12,
  53,
  'https://www.farmacapital.mx/catalogo-propia/belazix-5mg-10tab-novag-7501075723175.jpg',
  'https://www.farmacapital.mx/catalogo-propia/belazix-5mg-10tab-novag-7501075723175.jpg',
  3,
  1,
  true,
  false
where public.fc_buscar_producto_escaneo('7501075723175') is null
  and public.fc_buscar_producto_escaneo('FC-75723175') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501075723175'
       or p.sku = 'FC-75723175'
  );

-- Si ya existía (p. ej. alta a medias): completa ficha y stock solo si estaba en 0.
update public.productos p
set
  stock = case when coalesce(p.stock, 0) <= 0 then 3 else p.stock end,
  nombre = 'Belazix 5 mg',
  marca = 'Novag',
  presentacion = '10 tabletas',
  principio_activo = 'Levocetirizina',
  concentracion = '5 mg',
  forma_farmaceutica = 'Tabletas',
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Alergia'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Antihistamínico'),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'generico'),
  costo = case when coalesce(p.costo, 0) <= 0 then 33.12 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 0.01 then 52.99 else p.precio end,
  activo = true,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/belazix-5mg-10tab-novag-7501075723175.jpg'),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/belazix-5mg-10tab-novag-7501075723175.jpg')
where p.codigo_barras = '7501075723175'
   or p.sku = 'FC-75723175';

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/belazix-5mg-10tab-novag-7501075723175.jpg',
  'catalogo-propia/belazix-5mg-10tab-novag-7501075723175.jpg',
  0,
  true,
  'propia'
from public.productos p
where (p.codigo_barras = '7501075723175' or p.sku = 'FC-75723175')
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%belazix-5mg-10tab-novag-7501075723175%'
  );

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.principio_activo,
  p.concentracion,
  p.stock,
  p.costo,
  p.precio,
  left(p.imagen_url, 96) as foto
from public.productos p
where p.codigo_barras = '7501075723175'
   or p.sku = 'FC-75723175';

-- Referencia (no tocar): Belazix C/20 ya existente
select sku, codigo_barras, nombre, presentacion, stock
from public.productos
where sku = 'EQ-NOV154' or codigo_barras = '7501075722604';
