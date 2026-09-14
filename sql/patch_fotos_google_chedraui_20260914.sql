-- Google + ficha oficial / Chedraui (14-sep-2026)
-- Pegar DESPUÉS de patch_fotos_aas_psicofarma_alendronico_20260914.sql
-- origen de galería: solo rappi | distribuidor | propia | gs1 | otro
--
-- Fuentes (cada pieza se abrió):
--   Garnier Agua Micelar Carbón 400 ml · garnier.com.mx + EAN 3600542478359
--   Jaloma Agua de Rosas 250 ml · jaloma.com.mx (no es el spray 130 ml)
--   Jaloma Agua de Arroz 250 ml · jaloma.com.mx / DAX EAN 759684900259
--   Adidas Power Booster 150 ml · Chedraui (misma lata 150 ml)
--   Allegra D 60/25 mg C/10 · allegra.com.mx
--   Xiomara Cera Mate 60 g · Chedraui EAN 7501846505283
--   Vitacilina Facial Melatonina · Chedraui EAN 7502250343102
--   Rexona Happy Morning roll-on 50 ml · Chedraui EAN 75075996
--   Savilé bicarbonato+limón spray 150 ml · savilemexico.com.mx EAN 7506306215528
--   Savilé bicarbonato+limón stick 45 g · Chedraui EAN 75068639
--   Escudo antiséptico spray 200 ml · Chedraui EAN 7506425629442
--   Honey Keeper Kids Chamomile 414 ml · Chedraui EAN 814266022610
--   Honey Keeper Kids Lavender 414 ml · Chedraui EAN 814266022627
--
-- Pide deploy de Vercel. No se toca codigo_barras.
-- No se usó: Jaloma rosas 130 ml (solo hay packshot de 250 ml);
-- Gerber 113 g ≠ 100 g; Sico 7501685171113 ≠ 7501685171118;
-- Savile roll-on 75068622; Honey Keeper oat 414 ml (Chedraui tiene otro EAN).

begin;

update public.productos
set nombre = 'Garnier Agua Micelar Carbón 400 ml',
    marca = 'Garnier',
    presentacion = 'Frasco 400 ml',
    descripcion = 'Garnier SkinActive Agua Micelar Jelly Carbón 400 ml'
where sku = 'FC-42478359';

update public.productos
set nombre = 'Jaloma Agua de Rosas 250 ml',
    marca = 'Jaloma',
    presentacion = 'Spray 250 ml',
    descripcion = 'Jaloma Agua de Rosas tónico facial 250 ml'
where sku = 'FC-84900204';

update public.productos
set nombre = 'Jaloma Agua de Arroz 250 ml',
    marca = 'Jaloma',
    presentacion = 'Spray 250 ml',
    descripcion = 'Jaloma Agua de Arroz tónico facial 250 ml'
where sku = 'FC-84900259';

update public.productos
set nombre = 'Adidas Power Booster spray 150 ml',
    marca = 'Adidas',
    presentacion = 'Aerosol 150 ml',
    descripcion = 'Adidas Power Booster antitranspirante spray 150 ml'
where sku = 'FC-03842420';

update public.productos
set nombre = 'Allegra D fexofenadina/fenilefrina 60/25 mg C/10',
    marca = 'Allegra',
    presentacion = 'Caja con 10 tabletas',
    concentracion = coalesce(nullif(btrim(concentracion), ''), '60/25 mg'),
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Fexofenadina / Fenilefrina'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas'),
    categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Alergia' else categoria end,
    descripcion = 'Allegra D 60/25 mg C/10'
where sku = 'FC-65006386';

update public.productos
set nombre = 'Xiomara Cera Mate 60 g',
    marca = 'Xiomara',
    presentacion = 'Tarro 60 g',
    descripcion = 'Xiomara Wax & Shine cera mate 60 g'
where sku = 'FC-46505283';

update public.productos
set nombre = 'Vitacilina Facial Melatonina',
    marca = 'Vitacilina',
    descripcion = 'Vitacilina Facial Melatonina crema de noche'
where sku = 'FC-50343102';

update public.productos
set nombre = 'Rexona Happy Morning roll-on 50 ml',
    marca = 'Rexona',
    presentacion = 'Roll-on 50 ml',
    descripcion = 'Rexona Happy Morning 72 h roll-on 50 ml'
where sku = 'FC-75075996';

update public.productos
set nombre = 'Savilé bicarbonato y limón spray 150 ml',
    marca = 'Savilé',
    presentacion = 'Aerosol 150 ml',
    descripcion = 'Savilé antitranspirante bicarbonato y limón spray 150 ml'
where sku = 'FC-06215528';

update public.productos
set nombre = 'Savilé bicarbonato y limón stick 45 g',
    marca = 'Savilé',
    presentacion = 'Barra 45 g',
    descripcion = 'Savilé antitranspirante bicarbonato y limón stick 45 g'
where sku = 'FC-75068639';

update public.productos
set nombre = 'Escudo antiséptico spray 200 ml',
    marca = 'Escudo',
    presentacion = 'Spray 200 ml',
    descripcion = 'Escudo solución antiséptica alcohol 70% spray 200 ml'
where sku = 'FC-25629442';

update public.productos
set nombre = 'Honey Keeper Kids Chamomile 3 en 1 414 ml',
    marca = 'Honey Keeper',
    presentacion = 'Frasco 414 ml',
    descripcion = 'The Honeykeeper Kids 3 en 1 Little Chamomile 414 ml'
where sku = 'FC-66022610';

update public.productos
set nombre = 'Honey Keeper Kids Lavender 3 en 1 414 ml',
    marca = 'Honey Keeper',
    presentacion = 'Frasco 414 ml',
    descripcion = 'The Honeykeeper Kids 3 en 1 Lavender Dreams 414 ml'
where sku = 'FC-66022627';

create temporary table tmp_foto_google (
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_google (sku, url, origen)
values
  ('FC-42478359',
   'https://www.farmacapital.mx/catalogo-propia/garnier-agua-micelar-carbon-400ml.jpg',
   'propia'),
  ('FC-84900204',
   'https://www.farmacapital.mx/catalogo-propia/jaloma-agua-de-rosas-250ml.jpg',
   'propia'),
  ('FC-84900259',
   'https://www.farmacapital.mx/catalogo-propia/jaloma-agua-de-arroz-250ml.jpg',
   'propia'),
  ('FC-03842420',
   'https://www.farmacapital.mx/catalogo-propia/adidas-power-booster-150ml-3616303842420.jpg',
   'propia'),
  ('FC-65006386',
   'https://www.farmacapital.mx/catalogo-propia/allegra-d-60-25-c10.jpg',
   'propia'),
  ('FC-46505283',
   'https://www.farmacapital.mx/catalogo-propia/xiomara-cera-mate-60g.jpg',
   'propia'),
  ('FC-50343102',
   'https://www.farmacapital.mx/catalogo-propia/vitacilina-facial-melatonina.jpg',
   'propia'),
  ('FC-75075996',
   'https://www.farmacapital.mx/catalogo-propia/rexona-happy-morning-rollon-50ml.jpg',
   'propia'),
  ('FC-06215528',
   'https://www.farmacapital.mx/catalogo-propia/savile-bicarbonato-limon-spray-150ml.jpg',
   'propia'),
  ('FC-75068639',
   'https://www.farmacapital.mx/catalogo-propia/savile-bicarbonato-limon-stick-45g.jpg',
   'propia'),
  ('FC-25629442',
   'https://www.farmacapital.mx/catalogo-propia/escudo-antiseptico-spray-200ml.jpg',
   'propia'),
  ('FC-66022610',
   'https://www.farmacapital.mx/catalogo-propia/honeykeeper-kids-chamomile-414ml.jpg',
   'propia'),
  ('FC-66022627',
   'https://www.farmacapital.mx/catalogo-propia/honeykeeper-kids-lavender-414ml.jpg',
   'propia');

create temporary table tmp_foto_google_match (
  producto_id bigint primary key,
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_google_match (producto_id, sku, url, origen)
select distinct on (p.id)
  p.id, m.sku, m.url, m.origen
from public.productos p
join tmp_foto_google m on p.sku = m.sku
order by p.id;

-- Sobrescribe también URLs rotas (cm-… / catalogo-propia 404).
update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_google_match m
where p.id = m.producto_id;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  m.producto_id,
  m.url,
  null,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = m.producto_id), 0) + 1,
  false,
  m.origen
from tmp_foto_google_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_google_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_google_match);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_google_match)
  and i.url in (select url from tmp_foto_google_match)
  and not i.es_principal;

commit;
