-- ============================================================================
-- FARMACAPITAL — Theraflu TD de día limón 10 sobres
-- EAN 7501065008459 · Haleon · SKU FC-06500845
--
-- En catálogo solo estaba el verde de NOCHE (id 616, FC-5008473,
-- EAN 7501065008473) mal nombrado «Theraflu TD Limón Resfriado Severo».
-- Ese es Theraflu noche (paracetamol + feniramina + fenilefrina).
-- El de día no existía: Theraflu TD, caja roja, no causa sueño.
--
-- Ficha Haleon (theraflu.com.mx/productos/theraflu-td-aliviar-sintomas-
-- resfriado-comun-sin-sueno.html) + iNadro THERAFLU EXT-TD ROJO 10SB
-- ECONOPACK. No usar el código del ticket (THERAFLU TD ROJO SOB C/10).
--
-- Cada sobre: paracetamol 650 mg + fenilefrina 10 mg. Sabor limón.
-- Costo $170.32 (Farmalive 9861, 2 pzas). Marca +25% al costo → $213.
-- Stock 0 hasta Recibir (no inventar piezas ni caducidad).
--
-- No es Theraflu Daytime (frutos del bosque + dextrometorfano,
-- EAN 7501065010438 / 7501065010445): otro SKU, no se crea aquí.
--
-- Foto: packshot Haleon → public/catalogo-propia/
--       theraflu-td-dia-limon-10-sobres-7501065008459.jpg
-- ORDEN: 1) merge/deploy  2) pegar este SQL en Supabase → Run.
-- SIN bloques $$. Pegar TODO.
-- ============================================================================

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  laboratorio, costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Theraflu TD de día limón 10 sobres',
  'FC-06500845',
  '7501065008459',
  'Respiratorio',
  'Antigripal',
  'marca',
  'Theraflu TD Haleon · no causa sueño · paracetamol 650 mg / fenilefrina 10 mg · sabor limón · caja 10 sobres · ficha Haleon + iNadro EXT-TD ROJO · EAN 7501065008459',
  'Theraflu',
  'Caja con 10 sobres sabor limón',
  'Paracetamol + Fenilefrina',
  '650 mg / 10 mg',
  'Granulado',
  'HALEON',
  170.32,
  213,
  'https://www.farmacapital.mx/catalogo-propia/theraflu-td-dia-limon-10-sobres-7501065008459.jpg',
  'https://www.farmacapital.mx/catalogo-propia/theraflu-td-dia-limon-10-sobres-7501065008459.jpg',
  0,
  2,
  true,
  false
where public.fc_buscar_producto_escaneo('7501065008459') is null
  and public.fc_buscar_producto_escaneo('FC-06500845') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501065008459'
       or p.sku = 'FC-06500845'
  );

-- Completa ficha si ya existía (alta FL-5008459 u otra) sin pisar foto/costo/precio buenos.
update public.productos p
set
  nombre = 'Theraflu TD de día limón 10 sobres',
  marca = 'Theraflu',
  presentacion = 'Caja con 10 sobres sabor limón',
  principio_activo = 'Paracetamol + Fenilefrina',
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '650 mg / 10 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Granulado'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Respiratorio'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Antigripal'),
  tipo = 'marca',
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'HALEON'),
  requiere_receta = false,
  activo = true,
  codigo_barras = '7501065008459',
  costo = case when coalesce(p.costo, 0) <= 0.01 then 170.32 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 1 then 213 else p.precio end,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/theraflu-td-dia-limon-10-sobres-7501065008459.jpg'),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/theraflu-td-dia-limon-10-sobres-7501065008459.jpg'),
  descripcion = trim(both ' ·' from concat_ws(
    ' · ',
    nullif(trim(both ' ·' from coalesce(p.descripcion, '')), ''),
    'Theraflu TD de día · Haleon · no causa sueño · EAN 7501065008459'
  ))
where p.codigo_barras = '7501065008459'
   or p.sku in ('FC-06500845', 'FL-5008459');

-- El verde 7501065008473 es NOCHE (feniramina). En catálogo decía «Theraflu TD».
update public.productos p
set
  nombre = 'Theraflu noche limón 10 sobres',
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Caja con 10 sobres sabor limón'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Antigripal'),
  principio_activo = 'Paracetamol + Feniramina + Fenilefrina',
  marca = coalesce(nullif(btrim(p.marca), ''), 'Theraflu'),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'HALEON')
where p.codigo_barras = '7501065008473'
   or p.sku = 'FC-5008473';

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/theraflu-td-dia-limon-10-sobres-7501065008459.jpg',
  'catalogo-propia/theraflu-td-dia-limon-10-sobres-7501065008459.jpg',
  0,
  true,
  'propia'
from public.productos p
where (p.codigo_barras = '7501065008459' or p.sku = 'FC-06500845')
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%theraflu-td-dia-limon-10-sobres-7501065008459%'
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.principio_activo,
  p.costo,
  p.precio,
  p.stock,
  p.activo,
  left(p.imagen_url, 90) as foto
from public.productos p
where p.codigo_barras in ('7501065008459', '7501065008473')
   or p.sku in ('FC-06500845', 'FC-5008473', 'FL-5008459')
order by p.codigo_barras, p.sku;
