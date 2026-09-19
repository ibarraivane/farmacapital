-- Fotos faltantes / feas (19-sep-2026) — ligas que pasó el dueño + vitrina.
-- Packshots en public/catalogo-propia/. ORDEN: 1) merge/deploy  2) este SQL.
-- origen SOLO admite rappi | distribuidor | propia | gs1 | otro.
-- Idempotente: no duplica la misma URL. Reemplaza portada vacía, Fahorro
-- o una portada distinta de este lote (alcohol cortado, Cetilver con marca
-- de agua, Buscapina de espaldas, Desrotan/Secret de celular).
-- Match por EAN, SKU o nombre (sin ids fijos).

begin;

create temporary table tmp_foto_fal (
  ean text,
  sku text,
  name_ilike text,
  name_not_ilike text,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_fal (ean, sku, name_ilike, name_not_ilike, url, origen) values
  ('7501868901124', 'FC-68901124', '', '', 'https://www.farmacapital.mx/catalogo-propia/alcohol-etilico-dibar-azul-71-5-500-ml-7501868901124.jpg', 'propia'),
  ('7501349021419', 'FC-C721E8D7', '', '', 'https://www.farmacapital.mx/catalogo-propia/levofloxacino-amsa-500-mg-c-7-tabletas-7501349021419.jpg', 'distribuidor'),
  ('7501165011656', 'FC-65011656', '%buscapina%fem%', '', 'https://www.farmacapital.mx/catalogo-propia/buscapina-fem-hioscina-ibuprofeno-20-400-mg-c-10-7501165011656.jpg', 'distribuidor'),
  ('7502009748448', 'EQ-MAV392', '%cetilver%', '', 'https://www.farmacapital.mx/catalogo-propia/cetilver-pirfenidona-gel-8-tubo-10-g-7502009748448.jpg', 'distribuidor'),
  ('7500435129367', 'FC-35129367', '%secret%lavanda%', '', 'https://www.farmacapital.mx/catalogo-propia/secret-gel-invisible-lavanda-45-g-7500435129367.jpg', 'distribuidor'),
  ('7502227875568', 'FC-B3B8F9BB', '%desrotan%', '', 'https://www.farmacapital.mx/catalogo-propia/desrotan-fexofenadina-180-mg-c-10-7502227875568.jpg', 'distribuidor'),
  ('', '', '%almendras dulces%125%', '', 'https://www.farmacapital.mx/catalogo-propia/aceite-de-almendras-dulces-flor-de-aire-125-ml.jpg', 'distribuidor'),
  ('7501082780246', '', '%aceite%nuvel%250%', '', 'https://www.farmacapital.mx/catalogo-propia/aceite-para-bebe-nuvel-250-ml-7501082780246.jpg', 'distribuidor'),
  ('750108278024', '', '%aceite%nuvel%250%', '', 'https://www.farmacapital.mx/catalogo-propia/aceite-para-bebe-nuvel-250-ml-7501082780246.jpg', 'distribuidor'),
  ('7501108763475', '', '%advil%200%10%capsul%', '', 'https://www.farmacapital.mx/catalogo-propia/advil-ibuprofeno-200-mg-c-10-capsulas-7501108763475.jpg', 'distribuidor'),
  ('', '', '%ampigrin pfc%caps%', '', 'https://www.farmacapital.mx/catalogo-propia/ampigrin-pfc-capsulas-c-24.jpg', 'distribuidor'),
  ('7501349029965', '', '%betahistina%amsa%24%', '', 'https://www.farmacapital.mx/catalogo-propia/betahistina-amsa-24-mg-c-30-tabletas-7501349029965.jpg', 'distribuidor'),
  ('750134902996', '', '%betahistina%amsa%24%', '', 'https://www.farmacapital.mx/catalogo-propia/betahistina-amsa-24-mg-c-30-tabletas-7501349029965.jpg', 'distribuidor'),
  ('7501573907992', '', '%broxtorfan%adult%', '', 'https://www.farmacapital.mx/catalogo-propia/broxtorfan-adulto-ambroxol-dextrometorfano-jarabe-12-7501573907992.jpg', 'distribuidor'),
  ('7502211784180', 'FC-11784180', '%calaffler%', '', 'https://www.farmacapital.mx/catalogo-propia/calaffler-diclofenaco-gotas-15-mg-ml-loeffler-7502211784180.jpg', 'distribuidor'),
  ('', '', '%nula nasal%ped%', '', 'https://www.farmacapital.mx/catalogo-propia/canula-nasal-pediatrica-2-mm-x-1-80-m-sensi-medical.jpg', 'distribuidor'),
  ('', '', '%carnitina%naturex%', '', 'https://www.farmacapital.mx/catalogo-propia/carnitina-fibra-y-complejo-b-naturex-30-capsulas-560.jpg', 'distribuidor'),
  ('', '', '%teatrical%lanolin%400%', '%rosas%', 'https://www.farmacapital.mx/catalogo-propia/teatrical-crema-suavizante-con-lanolina-tarro-400-g.jpg', 'distribuidor'),
  ('', '', '%teatrical%rosas%400%', '', 'https://www.farmacapital.mx/catalogo-propia/teatrical-crema-suavizante-con-lanolina-y-rosas-tarr.jpg', 'distribuidor');

create temporary table tmp_foto_hit (
  producto_id bigint primary key,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_hit (producto_id, url, origen)
select distinct on (p.id)
  p.id,
  t.url,
  t.origen
from public.productos p
join tmp_foto_fal t
  on (
    (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
    or (t.sku <> '' and p.sku = t.sku)
    or (
      t.name_ilike <> ''
      and p.nombre ilike t.name_ilike
      and (t.name_not_ilike = '' or p.nombre not ilike t.name_not_ilike)
    )
  )
order by p.id, t.url;

update public.productos p
set imagen_url = h.url,
    imagen_mobile_url = h.url
from tmp_foto_hit h
where p.id = h.producto_id
  and (
    p.imagen_url is null
    or btrim(p.imagen_url) = ''
    or p.imagen_url ilike '%fahorro%'
    or p.imagen_url not like '%' || regexp_replace(h.url, '^.*/', '') || '%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  h.producto_id,
  h.url,
  'catalogo-propia/' || regexp_replace(h.url, '^.*/', ''),
  coalesce((select max(i.posicion) from public.producto_imagenes i
            where i.producto_id = h.producto_id), 0) + 1,
  false,
  h.origen
from tmp_foto_hit h
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = h.producto_id and i.url = h.url
);

update public.producto_imagenes i
set es_principal = false
from tmp_foto_hit h
where i.producto_id = h.producto_id
  and i.es_principal
  and i.url <> h.url;

update public.producto_imagenes i
set es_principal = true
from tmp_foto_hit h
where i.producto_id = h.producto_id
  and i.url = h.url
  and not i.es_principal;

commit;

select p.id, p.sku, p.codigo_barras, p.nombre, left(coalesce(p.imagen_url, ''), 110) as imagen
from public.productos p
where p.codigo_barras in ('7501868901124', '7501349021419', '7501165011656', '7502009748448', '7500435129367', '7502227875568', '7501082780246', '750108278024', '7501108763475', '7501349029965', '750134902996', '7501573907992', '7502211784180')
   or p.sku in ('FC-68901124', 'FC-C721E8D7', 'FC-65011656', 'EQ-MAV392', 'FC-35129367', 'FC-B3B8F9BB', 'FC-11784180')
   or p.nombre ilike '%cetilver%'
   or p.nombre ilike '%desrotan%'
   or p.nombre ilike '%buscapina%fem%'
   or p.nombre ilike '%calaffler%'
   or p.nombre ilike '%broxtorfan%'
   or p.nombre ilike '%teatrical%400%'
   or p.nombre ilike '%nula nasal%ped%'
   or p.nombre ilike '%carnitina%naturex%'
   or p.nombre ilike '%almendras dulces%'
   or p.nombre ilike '%aceite%nuvel%'
   or p.nombre ilike '%ampigrin pfc%'
   or p.nombre ilike '%betahistina%amsa%'
order by p.nombre;
