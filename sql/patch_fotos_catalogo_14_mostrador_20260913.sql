-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Paquete: 14 altas mostrador 2026-09-13 (patch_alta_catalogo_14_mostrador_20260913.sql)
-- Archivos en public/catalogo-propia/
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

-- St. Ives avena y karité 200 ml
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/st-ives-avena-karite-200ml.jpg'
where (codigo_barras = '7506306208353' or sku in ('FC-06208353', 'FC-ND-06208353'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/st-ives-avena-karite-200ml%'
  );

-- Seda Pure Brillo Keratin 125 ml
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/seda-pure-brillo-keratina-125ml.png'
where (codigo_barras = '7502254072831' or sku in ('FC-54072831', 'FC-ND-54072831'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/seda-pure-brillo-keratina-125ml%'
  );

-- L'Oréal Studio Line Invisi Fix 180 g
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/loreal-studio-line-invisi-fix-180g.jpg'
where (codigo_barras = '7501027233974' or sku in ('FC-27233974', 'FC-ND-27233974'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/loreal-studio-line-invisi-fix-180g%'
  );

-- Listerine Pro-Encías 250 ml
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/listerine-pro-encias-250ml.jpg'
where (codigo_barras = '7702035433299' or sku in ('FC-35433299', 'FC-ND-35433299'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/listerine-pro-encias-250ml%'
  );

-- Seda Pure bifase keratina 250 ml
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/seda-pure-bifase-keratina-250ml.png'
where (codigo_barras = '7502254073715' or sku in ('FC-54073715', 'FC-ND-54073715'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/seda-pure-bifase-keratina-250ml%'
  );

-- Just For Men barba negro
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/just-for-men-barba-negro.jpg'
where (codigo_barras = '7501080111455' or sku in ('FC-80111455', 'FC-ND-80111455'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/just-for-men-barba-negro%'
  );

-- St. Ives colágeno y elastina 200 ml
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/st-ives-colageno-elastina-200ml.jpg'
where (codigo_barras = '7506306208315' or sku in ('FC-06208315', 'FC-ND-06208315'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/st-ives-colageno-elastina-200ml%'
  );

-- Seda Pure sílica uva spray 300 ml
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/seda-pure-silica-uva-spray-300ml.jpg'
where (codigo_barras = '7502254073357' or sku in ('FC-54073357', 'FC-ND-54073357'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/seda-pure-silica-uva-spray-300ml%'
  );

-- Seda Pure sílica argán spray 300 ml
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/seda-pure-silica-argan-spray-300ml.png'
where (codigo_barras = '7502254073371' or sku in ('FC-54073371', 'FC-ND-54073371'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/seda-pure-silica-argan-spray-300ml%'
  );

-- Pert kera + aguacate 100 ml
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/pert-crema-peinar-kera-aguacate-100ml.jpg'
where (codigo_barras = '810120500164' or sku in ('FC-20500164', 'FC-ND-20500164'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/pert-crema-peinar-kera-aguacate-100ml%'
  );

-- Grisi Organogal Silver kit
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/grisi-organogal-silver-kit.jpg'
where (codigo_barras = '850040940602' or sku in ('FC-40940602', 'FC-ND-40940602'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/grisi-organogal-silver-kit%'
  );

-- BIC Comfort 3 ×12
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/bic-comfort3-12pzas.jpg'
where (codigo_barras = '070330717541' or sku in ('FC-30717541', 'FC-ND-30717541'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/bic-comfort3-12pzas%'
  );

-- BIC Soleil 3 ×12
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/bic-soleil-3-12pzas.jpg'
where (codigo_barras = '070330731813' or sku in ('FC-30731813', 'FC-ND-30731813'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/bic-soleil-3-12pzas%'
  );

-- Kleenex bote 50
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/kleenex-panuelos-bote-50.png'
where (codigo_barras = '7501943476271' or sku in ('FC-43476271', 'FC-ND-43476271'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/kleenex-panuelos-bote-50%'
  );

-- Galería principal (si existe producto_imagenes)
insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       u.url,
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from (
  values
    ('7506306208353', 'https://www.farmacapital.mx/catalogo-propia/st-ives-avena-karite-200ml.jpg'),
    ('7502254072831', 'https://www.farmacapital.mx/catalogo-propia/seda-pure-brillo-keratina-125ml.png'),
    ('7501027233974', 'https://www.farmacapital.mx/catalogo-propia/loreal-studio-line-invisi-fix-180g.jpg'),
    ('7702035433299', 'https://www.farmacapital.mx/catalogo-propia/listerine-pro-encias-250ml.jpg'),
    ('7502254073715', 'https://www.farmacapital.mx/catalogo-propia/seda-pure-bifase-keratina-250ml.png'),
    ('7501080111455', 'https://www.farmacapital.mx/catalogo-propia/just-for-men-barba-negro.jpg'),
    ('7506306208315', 'https://www.farmacapital.mx/catalogo-propia/st-ives-colageno-elastina-200ml.jpg'),
    ('7502254073357', 'https://www.farmacapital.mx/catalogo-propia/seda-pure-silica-uva-spray-300ml.jpg'),
    ('7502254073371', 'https://www.farmacapital.mx/catalogo-propia/seda-pure-silica-argan-spray-300ml.png'),
    ('810120500164', 'https://www.farmacapital.mx/catalogo-propia/pert-crema-peinar-kera-aguacate-100ml.jpg'),
    ('850040940602', 'https://www.farmacapital.mx/catalogo-propia/grisi-organogal-silver-kit.jpg'),
    ('070330717541', 'https://www.farmacapital.mx/catalogo-propia/bic-comfort3-12pzas.jpg'),
    ('070330731813', 'https://www.farmacapital.mx/catalogo-propia/bic-soleil-3-12pzas.jpg'),
    ('7501943476271', 'https://www.farmacapital.mx/catalogo-propia/kleenex-panuelos-bote-50.png')
) as u(ean, url)
join public.productos p on p.codigo_barras = u.ean
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = p.id and i.url = u.url
);

commit;

select p.codigo_barras, p.sku, p.nombre, p.imagen_url
from public.productos p
where p.codigo_barras in (
  '7506306208353', '7502254072831', '7501027233974', '7702035433299',
  '7502254073715', '7501080111455', '7506306208315', '7502254073357',
  '7502254073371', '810120500164', '850040940602', '070330717541',
  '070330731813', '7501943476271'
)
order by p.codigo_barras;
