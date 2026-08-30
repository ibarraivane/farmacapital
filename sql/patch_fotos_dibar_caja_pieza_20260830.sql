-- ============================================================================
-- Fotos Dibar 500 ml (propias) + packshots Nadro por EAN + cajas de granel
--
-- DESPUÉS de que Vercel publique este commit (los JPG viven en
-- public/catalogo-propia/). Si corres el SQL antes, las URLs de Dibar 404.
--
--  1) Alcohol Dibar azul 71.6° 500 ml  id 349  foto de mostrador
--  2) Alcohol Dibar rojo 96° 500 ml    id 340  foto de mostrador
--  3) Amikacina AMSA 500 mg/2 ml       id 75   Nadro EAN 7501349021488
--     (reemplaza la foto del código de barras que salía en catálogo)
--  4) Crema Grisi aloe vera manos 80 ml id 317 Nadro EAN 810120501765
--
-- No inventa foto si el EAN no coincide (Grisi concha, Bocetix, Calazin,
-- Colágeno-Naturex, Colchicina, Cafiaspirina tartrato, Aquito).
-- No toca stock, caducidad ni activo. Las cajas de granel se ocultan
-- solo en la tienda web (código); el POS sigue vendiendo por pieza.
-- ============================================================================

begin;

-- 1) Dibar azul 500 ml
update public.productos
   set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/dibar-azul-500ml.jpg',
       imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/dibar-azul-500ml.jpg'
 where id = 349
   and sku = 'FC-68901124';

-- 2) Dibar rojo 500 ml
update public.productos
   set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/dibar-rojo-500ml.jpg',
       imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/dibar-rojo-500ml.jpg'
 where id = 340
   and sku = 'FC-68990023';

-- 3) Amikacina: packshot de caja, no el panel del código
update public.productos
   set imagen_url = 'https://nadro.vtexassets.com/arquivos/ids/200029/7501349021488_01.jpg',
       imagen_mobile_url = 'https://nadro.vtexassets.com/arquivos/ids/200029/7501349021488_01.jpg'
 where id = 75
   and sku = 'FC-11294615'
   and codigo_barras = '7501349021488';

-- 4) Grisi aloe vera manos 80 ml
update public.productos
   set imagen_url = 'https://nadro.vtexassets.com/arquivos/ids/230829/810120501765_01.jpg',
       imagen_mobile_url = 'https://nadro.vtexassets.com/arquivos/ids/230829/810120501765_01.jpg'
 where id = 317
   and sku = 'FC-20501765'
   and codigo_barras = '8101205017656';

-- Galería: una principal por producto.
update public.producto_imagenes
   set es_principal = false
 where producto_id in (349, 340, 75, 317)
   and es_principal;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select v.producto_id, v.url, v.storage_path,
       coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = v.producto_id), 0) + 1,
       true, v.origen
  from (values
    (349, 'https://www.farmacapital.mx/catalogo-propia/dibar-azul-500ml.jpg',
     'catalogo-propia/dibar-azul-500ml.jpg', 'propia'),
    (340, 'https://www.farmacapital.mx/catalogo-propia/dibar-rojo-500ml.jpg',
     'catalogo-propia/dibar-rojo-500ml.jpg', 'propia'),
    (75, 'https://nadro.vtexassets.com/arquivos/ids/200029/7501349021488_01.jpg',
     null, 'distribuidor'),
    (317, 'https://nadro.vtexassets.com/arquivos/ids/230829/810120501765_01.jpg',
     null, 'distribuidor')
  ) as v(producto_id, url, storage_path, origen)
on conflict (producto_id, url) do update
   set es_principal = true,
       storage_path = excluded.storage_path,
       origen = excluded.origen;

commit;

select id, sku, nombre, presentacion, imagen_url
  from public.productos
 where id in (349, 340, 75, 317)
 order by id;
