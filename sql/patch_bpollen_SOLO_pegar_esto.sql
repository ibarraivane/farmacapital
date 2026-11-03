-- =============================================================================
-- PEGAR SOLO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Arregla los 2 amarillos BPOllen del Nadro (5% y 2.5%).
-- Sin temp tables, sin do $$, sin producto_imagenes (eso a veces tumba el Run).
-- =============================================================================

-- 1) BPOllen 5%
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica,
  principio_activo, concentracion, imagen_url, imagen_mobile_url
)
select
  'BPOllen gel 5%',
  'FC-02461306',
  '7502002461306',
  'Dermatología',
  'Acné',
  'marca',
  'Alta Recibir BPOllen 5% · Nadro 6091723171',
  185.63,
  233,
  0,
  1,
  true,
  false,
  'BPOllen',
  'Farmapiel',
  'Tubo 60 g',
  'Gel',
  'Peróxido de benzoílo',
  '5%',
  'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-5-7502002461306.jpg',
  'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-5-7502002461306.jpg'
where not exists (
  select 1 from public.productos
  where codigo_barras = '7502002461306' or sku = 'FC-02461306'
);

update public.productos
set
  codigo_barras = coalesce(nullif(trim(codigo_barras), ''), '7502002461306'),
  marca = coalesce(nullif(trim(marca), ''), 'BPOllen'),
  laboratorio = coalesce(nullif(trim(laboratorio), ''), 'Farmapiel'),
  presentacion = coalesce(nullif(trim(presentacion), ''), 'Tubo 60 g'),
  forma_farmaceutica = coalesce(nullif(trim(forma_farmaceutica), ''), 'Gel'),
  principio_activo = coalesce(nullif(trim(principio_activo), ''), 'Peróxido de benzoílo'),
  concentracion = coalesce(nullif(trim(concentracion), ''), '5%'),
  costo = 185.63,
  precio = case when coalesce(precio, 0) <= 0 then 233 else precio end,
  imagen_url = coalesce(nullif(trim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-5-7502002461306.jpg'),
  imagen_mobile_url = coalesce(nullif(trim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-5-7502002461306.jpg'),
  activo = true,
  tipo = coalesce(nullif(trim(tipo), ''), 'marca')
where codigo_barras = '7502002461306' or sku = 'FC-02461306';

-- 2) BPOllen 2.5%
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica,
  principio_activo, concentracion, imagen_url, imagen_mobile_url
)
select
  'BPOllen gel 2.5%',
  'FC-02461290',
  '7502002461290',
  'Dermatología',
  'Acné',
  'marca',
  'Alta Recibir BPOllen 2.5% · Nadro 6091723171',
  170.78,
  214,
  0,
  1,
  true,
  false,
  'BPOllen',
  'Farmapiel',
  'Tubo 60 g',
  'Gel',
  'Peróxido de benzoílo',
  '2.5%',
  'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-2.5-7502002461290.jpg',
  'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-2.5-7502002461290.jpg'
where not exists (
  select 1 from public.productos
  where codigo_barras = '7502002461290' or sku = 'FC-02461290'
);

update public.productos
set
  codigo_barras = coalesce(nullif(trim(codigo_barras), ''), '7502002461290'),
  marca = coalesce(nullif(trim(marca), ''), 'BPOllen'),
  laboratorio = coalesce(nullif(trim(laboratorio), ''), 'Farmapiel'),
  presentacion = coalesce(nullif(trim(presentacion), ''), 'Tubo 60 g'),
  forma_farmaceutica = coalesce(nullif(trim(forma_farmaceutica), ''), 'Gel'),
  principio_activo = coalesce(nullif(trim(principio_activo), ''), 'Peróxido de benzoílo'),
  concentracion = coalesce(nullif(trim(concentracion), ''), '2.5%'),
  costo = 170.78,
  precio = case when coalesce(precio, 0) <= 0 then 214 else precio end,
  imagen_url = coalesce(nullif(trim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-2.5-7502002461290.jpg'),
  imagen_mobile_url = coalesce(nullif(trim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-2.5-7502002461290.jpg'),
  activo = true,
  tipo = coalesce(nullif(trim(tipo), ''), 'marca')
where codigo_barras = '7502002461290' or sku = 'FC-02461290';

-- 3) Enlaza los amarillos en Recibir (cualquier ticket vivo con esos EAN)
update public.recepcion_items i
set
  producto_id = p.id,
  pendiente_alta = false,
  nombre_snapshot = coalesce(nullif(trim(i.nombre_snapshot), ''), p.nombre),
  costo_estimado = coalesce(nullif(i.costo_estimado, 0), p.costo)
from public.productos p
where p.codigo_barras = i.codigo_escaneado
  and i.codigo_escaneado in ('7502002461306', '7502002461290')
  and coalesce(i.confirmado, false) = false;

-- 4) Verificación (debe devolver 2 filas de productos y los renglones enlazados)
select sku, codigo_barras as ean, nombre, costo, precio, activo
from public.productos
where codigo_barras in ('7502002461306', '7502002461290')
   or sku in ('FC-02461306', 'FC-02461290')
order by codigo_barras;

select
  r.folio,
  r.estado,
  i.codigo_escaneado as ean,
  i.nombre_snapshot,
  i.pendiente_alta,
  i.producto_id,
  i.confirmado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where i.codigo_escaneado in ('7502002461306', '7502002461290')
order by r.id desc, i.id;
