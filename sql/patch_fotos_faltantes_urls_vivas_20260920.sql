-- FIX 20-sep-2026: el SQL de 19-sep ya se pegó, pero las URLs
-- https://www.farmacapital.mx/catalogo-propia/<archivo>.jpg NO existen en
-- producción (el PR #288 sigue abierto). Vercel responde index.html 200
-- y la tarjeta queda vacía.
-- Este parche FORZA URLs vivas (jsDelivr del commit 7576424). Pegar YA.
-- No espera merge. No toca stock ni precio.
-- origen SOLO admite rappi | distribuidor | propia | gs1 | otro.

begin;

create temporary table tmp_foto_viva (
  ean text,
  sku text,
  name_ilike text,
  name_not_ilike text,
  archivo text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_viva (ean, sku, name_ilike, name_not_ilike, archivo, url, origen) values
  ('7501868901124', 'FC-68901124', '', '', 'alcohol-etilico-dibar-azul-71-5-500-ml-7501868901124.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/alcohol-etilico-dibar-azul-71-5-500-ml-7501868901124.jpg', 'propia'),
  ('7501349021419', 'FC-C721E8D7', '', '', 'levofloxacino-amsa-500-mg-c-7-tabletas-7501349021419.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/levofloxacino-amsa-500-mg-c-7-tabletas-7501349021419.jpg', 'distribuidor'),
  ('7501165011656', 'FC-65011656', '%buscapina%fem%', '', 'buscapina-fem-hioscina-ibuprofeno-20-400-mg-c-10-7501165011656.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/buscapina-fem-hioscina-ibuprofeno-20-400-mg-c-10-7501165011656.jpg', 'distribuidor'),
  ('7502009748448', 'EQ-MAV392', '%cetilver%', '', 'cetilver-pirfenidona-gel-8-tubo-10-g-7502009748448.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/cetilver-pirfenidona-gel-8-tubo-10-g-7502009748448.jpg', 'distribuidor'),
  ('7500435129367', 'FC-35129367', '%secret%lavanda%', '', 'secret-gel-invisible-lavanda-45-g-7500435129367.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/secret-gel-invisible-lavanda-45-g-7500435129367.jpg', 'distribuidor'),
  ('7502227875568', 'FC-B3B8F9BB', '%desrotan%', '', 'desrotan-fexofenadina-180-mg-c-10-7502227875568.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/desrotan-fexofenadina-180-mg-c-10-7502227875568.jpg', 'distribuidor'),
  ('', '', '%almendras dulces%125%', '', 'aceite-de-almendras-dulces-flor-de-aire-125-ml.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/aceite-de-almendras-dulces-flor-de-aire-125-ml.jpg', 'distribuidor'),
  ('7501082780246', '', '%aceite%nuvel%250%', '', 'aceite-para-bebe-nuvel-250-ml-7501082780246.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/aceite-para-bebe-nuvel-250-ml-7501082780246.jpg', 'distribuidor'),
  ('750108278024', '', '%aceite%nuvel%250%', '', 'aceite-para-bebe-nuvel-250-ml-7501082780246.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/aceite-para-bebe-nuvel-250-ml-7501082780246.jpg', 'distribuidor'),
  ('7501108763475', '', '%advil%200%10%capsul%', '', 'advil-ibuprofeno-200-mg-c-10-capsulas-7501108763475.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/advil-ibuprofeno-200-mg-c-10-capsulas-7501108763475.jpg', 'distribuidor'),
  ('', '', '%ampigrin pfc%caps%', '', 'ampigrin-pfc-capsulas-c-24.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/ampigrin-pfc-capsulas-c-24.jpg', 'distribuidor'),
  ('7501349029965', '', '%betahistina%amsa%24%', '', 'betahistina-amsa-24-mg-c-30-tabletas-7501349029965.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/betahistina-amsa-24-mg-c-30-tabletas-7501349029965.jpg', 'distribuidor'),
  ('750134902996', '', '%betahistina%amsa%24%', '', 'betahistina-amsa-24-mg-c-30-tabletas-7501349029965.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/betahistina-amsa-24-mg-c-30-tabletas-7501349029965.jpg', 'distribuidor'),
  ('7501573907992', '', '%broxtorfan%adult%', '', 'broxtorfan-adulto-ambroxol-dextrometorfano-jarabe-12-7501573907992.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/broxtorfan-adulto-ambroxol-dextrometorfano-jarabe-12-7501573907992.jpg', 'distribuidor'),
  ('7502211784180', 'FC-11784180', '%calaffler%', '', 'calaffler-diclofenaco-gotas-15-mg-ml-loeffler-7502211784180.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/calaffler-diclofenaco-gotas-15-mg-ml-loeffler-7502211784180.jpg', 'distribuidor'),
  ('', '', '%nula nasal%ped%', '', 'canula-nasal-pediatrica-2-mm-x-1-80-m-sensi-medical.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/canula-nasal-pediatrica-2-mm-x-1-80-m-sensi-medical.jpg', 'distribuidor'),
  ('', '', '%carnitina%naturex%', '', 'carnitina-fibra-y-complejo-b-naturex-30-capsulas-560.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/carnitina-fibra-y-complejo-b-naturex-30-capsulas-560.jpg', 'distribuidor'),
  ('', '', '%teatrical%lanolin%400%', '%rosas%', 'teatrical-crema-suavizante-con-lanolina-tarro-400-g.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/teatrical-crema-suavizante-con-lanolina-tarro-400-g.jpg', 'distribuidor'),
  ('', '', '%teatrical%rosas%400%', '', 'teatrical-crema-suavizante-con-lanolina-y-rosas-tarr.jpg', 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/teatrical-crema-suavizante-con-lanolina-y-rosas-tarr.jpg', 'distribuidor');

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
join tmp_foto_viva t
  on (
    (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
    or (t.sku <> '' and p.sku = t.sku)
    or (
      t.name_ilike <> ''
      and p.nombre ilike t.name_ilike
      and (t.name_not_ilike = '' or p.nombre not ilike t.name_not_ilike)
    )
    or (p.imagen_url ilike '%' || t.archivo)
    or exists (
      select 1 from public.producto_imagenes i
      where i.producto_id = p.id and i.url ilike '%' || t.archivo
    )
  )
order by p.id, t.url;

-- FORZAR: pisa la URL rota de catalogo-propia en producción.
update public.productos p
set imagen_url = h.url,
    imagen_mobile_url = h.url
from tmp_foto_hit h
where p.id = h.producto_id
  and coalesce(p.imagen_url, '') is distinct from h.url;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  h.producto_id,
  h.url,
  null,
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

select p.id, p.sku, p.codigo_barras, left(p.nombre, 56) as nombre,
       left(coalesce(p.imagen_url, ''), 140) as imagen
from public.productos p
join tmp_foto_hit h on h.producto_id = p.id
order by p.nombre;

commit;
