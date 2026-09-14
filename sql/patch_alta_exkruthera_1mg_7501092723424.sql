-- Exkruthera Fruquintinib 1 mg · Takeda · caja con frasco 21 cápsulas.
-- Ficha SFE Pacientes (https://pacientes.sfe.com.mx/Productos/5043), no un ticket.
-- EAN/GTIN 7501092723424 (dígito de control OK). Registro 295M2025 SSA IV.
-- 4 pzas en stock. Costo y PVP en NULL = por definir (POS no vende si precio ≤ 0.01).
-- Caducidad NO: no vino la caja. No inventar lote ni MMAA.
-- Foto: public/catalogo-propia/exkruthera-fruquintinib-1mg-21caps.jpg
--       (packshot SFE). Correr este SQL DESPUÉS del deploy de Vercel.
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Exkruthera Fruquintinib 1 mg caja con frasco 21 cápsulas',
  'FC-09272342',
  '7501092723424',
  'Medicamentos',
  'Oncología',
  'marca',
  'Alta mostrador · ficha SFE / Takeda · registro 295M2025 SSA IV · costo y PVP por definir · 4 pzas sin lote (caducidad de la caja)',
  'Takeda',
  'Caja con frasco con 21 cápsulas',
  'Fruquintinib',
  '1 mg',
  'Cápsula',
  null,
  null,
  'https://www.farmacapital.mx/catalogo-propia/exkruthera-fruquintinib-1mg-21caps.jpg',
  'https://www.farmacapital.mx/catalogo-propia/exkruthera-fruquintinib-1mg-21caps.jpg',
  4,
  1,
  true,
  true
where public.fc_buscar_producto_escaneo('7501092723424') is null
  and public.fc_buscar_producto_escaneo('FC-09272342') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501092723424'
       or p.sku = 'FC-09272342'
  );

-- Si ya existía sin stock: solo suma a 4 si está en 0. No pisa costo/PVP ni foto buena.
update public.productos p
set
  stock = case when coalesce(p.stock, 0) <= 0 then 4 else p.stock end,
  nombre = coalesce(nullif(btrim(p.nombre), ''), 'Exkruthera Fruquintinib 1 mg caja con frasco 21 cápsulas'),
  marca = coalesce(nullif(btrim(p.marca), ''), 'Takeda'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Caja con frasco con 21 cápsulas'),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), 'Fruquintinib'),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '1 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Cápsula'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Medicamentos'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Oncología'),
  requiere_receta = true,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/exkruthera-fruquintinib-1mg-21caps.jpg'),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/exkruthera-fruquintinib-1mg-21caps.jpg')
where p.codigo_barras = '7501092723424'
   or p.sku = 'FC-09272342';

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/exkruthera-fruquintinib-1mg-21caps.jpg',
  'catalogo-propia/exkruthera-fruquintinib-1mg-21caps.jpg',
  0,
  true,
  'propia'
from public.productos p
where (p.codigo_barras = '7501092723424' or p.sku = 'FC-09272342')
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%exkruthera-fruquintinib-1mg-21caps%'
  );

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.stock,
  p.costo,
  p.precio,
  p.requiere_receta,
  left(p.imagen_url, 88) as foto
from public.productos p
where p.codigo_barras = '7501092723424'
   or p.sku = 'FC-09272342';
