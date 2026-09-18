-- Fotos lote capturas tienda (2026-09-18).
-- Packshots en public/catalogo-propia/. ORDEN: 1) merge/deploy  2) este SQL.
-- origen SOLO admite rappi | distribuidor | propia | gs1 | otro.
-- Idempotente: no duplica la misma URL. Reemplaza portada vacía,
-- Fahorro, o una portada distinta de este lote (Trojan lifestyle, etc.).
-- Match por EAN o SKU (sin ids fijos: los de Equilibrio/internos varían).

begin;

create temporary table tmp_foto_cap (
  ean text,
  sku text,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_cap (ean, sku, url, origen) values
  ('2008500100013', 'FC-00100013', 'https://www.farmacapital.mx/catalogo-propia/cubrebocas-tricapa-desechable-negro-c-100-2008500100013.jpg', 'propia'),
  ('2008550100018', '', 'https://www.farmacapital.mx/catalogo-propia/dona-bolsa-ijj-10-c-12-2008550100018.jpg', 'distribuidor'),
  ('2008490100017', '', 'https://www.farmacapital.mx/catalogo-propia/copa-lavaojos-de-vidrio-2008490100017.jpg', 'distribuidor'),
  ('7501300422750', '', 'https://www.farmacapital.mx/catalogo-propia/dorixina-forte-clonixinato-de-lisina-250-mg-c-20-7501300422750.jpg', 'distribuidor'),
  ('7501573925071', '', 'https://www.farmacapital.mx/catalogo-propia/dosteril-lisinopril-10-mg-c-30-tabletas-7501573925071.jpg', 'distribuidor'),
  ('7502009740176', 'EQ-MAV028', 'https://www.farmacapital.mx/catalogo-propia/dolxen-naproxeno-250-mg-c-20-maver-7502009740176.jpg', 'distribuidor'),
  ('7501300420824', '', 'https://www.farmacapital.mx/catalogo-propia/dolac-ketorolaco-sublingual-30-mg-c-6-7501300420824.jpg', 'distribuidor'),
  ('7501075711011', 'EQ-NOV007', 'https://www.farmacapital.mx/catalogo-propia/debisor-10-mg-c-20-novag-7501075711011.jpg', 'distribuidor'),
  ('7501836003140', 'FC-36003140', 'https://www.farmacapital.mx/catalogo-propia/contraxen-carisoprodol-naproxeno-200-250-mg-c-30-7501836003140.jpg', 'distribuidor'),
  ('7502009749322', 'EQ-MAV394', 'https://www.farmacapital.mx/catalogo-propia/coniax-citicolina-500-mg-c-10-maver-7502009749322.jpg', 'distribuidor'),
  ('75065102', '', 'https://www.farmacapital.mx/catalogo-propia/savile-desodorante-manzanilla-stick-45-g-75065102.jpg', 'distribuidor'),
  ('7506306215511', '', 'https://www.farmacapital.mx/catalogo-propia/savile-desodorante-sabila-y-nacar-spray-150-ml-7506306215511.jpg', 'distribuidor'),
  ('7506306209763', '', 'https://www.farmacapital.mx/catalogo-propia/savile-desodorante-manzanilla-spray-150-ml-7506306209763.jpg', 'distribuidor'),
  ('78924345', '', 'https://www.farmacapital.mx/catalogo-propia/rexona-women-bamboo-roll-on-50-ml-78924345.jpg', 'distribuidor'),
  ('7500435141796', '', 'https://www.farmacapital.mx/catalogo-propia/old-spice-mar-profundo-spray-150-ml-7500435141796.jpg', 'distribuidor'),
  ('7509546060477', '', 'https://www.farmacapital.mx/catalogo-propia/lady-speed-stick-powder-fresh-roll-on-50-ml-7509546060477.jpg', 'distribuidor'),
  ('7509546071275', '', 'https://www.farmacapital.mx/catalogo-propia/lady-speed-stick-powder-fresh-spray-60-g-7509546071275.jpg', 'distribuidor'),
  ('7506309864822', '', 'https://www.farmacapital.mx/catalogo-propia/gillette-arctic-ice-spray-150-ml-7506309864822.jpg', 'distribuidor'),
  ('7702018913954', '', 'https://www.farmacapital.mx/catalogo-propia/gillette-cool-wave-roll-on-60-g-7702018913954.jpg', 'distribuidor'),
  ('7501080950139', 'FC-80950139', 'https://www.farmacapital.mx/catalogo-propia/condones-trojan-pro-tech-c-3-7501080950139.jpg', 'distribuidor');

-- Coniax: el ticket Equilibrio a veces llega sin EAN
update public.productos
set codigo_barras = '7502009749322'
where sku = 'EQ-MAV394'
  and (codigo_barras is null or btrim(codigo_barras) = '');

update public.productos p
set imagen_url = t.url,
    imagen_mobile_url = t.url
from tmp_foto_cap t
where (
    (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
    or (t.sku <> '' and p.sku = t.sku)
  )
  and (
    p.imagen_url is null
    or btrim(p.imagen_url) = ''
    or p.imagen_url ilike '%fahorro%'
    or p.imagen_url not like '%' || regexp_replace(t.url, '^.*/', '') || '%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.url,
  'catalogo-propia/' || regexp_replace(t.url, '^.*/', ''),
  coalesce((select max(i.posicion) from public.producto_imagenes i
            where i.producto_id = p.id), 0) + 1,
  false,
  t.origen
from tmp_foto_cap t
join public.productos p
  on (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
  or (t.sku <> '' and p.sku = t.sku)
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = p.id and i.url = t.url
);

update public.producto_imagenes i
set es_principal = false
from tmp_foto_cap t, public.productos p
where i.producto_id = p.id
  and i.es_principal
  and i.url not in (select url from tmp_foto_cap)
  and (
    (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
    or (t.sku <> '' and p.sku = t.sku)
  );

update public.producto_imagenes i
set es_principal = true
where i.url in (select url from tmp_foto_cap)
  and not i.es_principal;

commit;

select p.id, p.sku, p.codigo_barras, p.nombre, left(coalesce(p.imagen_url, ''), 100) as imagen
from public.productos p
where p.codigo_barras in ('2008500100013', '2008550100018', '2008490100017', '7501300422750', '7501573925071', '7502009740176', '7501300420824', '7501075711011', '7501836003140', '7502009749322', '75065102', '7506306215511', '7506306209763', '78924345', '7500435141796', '7509546060477', '7509546071275', '7506309864822', '7702018913954', '7501080950139')
   or p.sku in ('FC-00100013', 'EQ-MAV028', 'EQ-NOV007', 'FC-36003140', 'EQ-MAV394', 'FC-80950139')
order by p.nombre;
