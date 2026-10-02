-- Fotos caja mostrador (02-oct-2026).
-- Packshots en public/catalogo-propia/. ORDEN: 1) merge/deploy  2) este SQL.
-- origen: propia (fotos de caja del dueño; reemplazan Nadro/marca de agua).
-- Idempotente: no duplica la misma URL. Reemplaza portada vacía, Fahorro,
-- Nadro/Visoti, o una portada distinta de este lote.
-- Match por EAN o SKU (sin ids fijos).

begin;

create temporary table tmp_foto_caja (
  ean text,
  sku text,
  name_ilike text,
  name_not_ilike text,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_caja (ean, sku, name_ilike, name_not_ilike, url, origen) values
  (
    '7501349021419', 'FC-C721E8D7', '', '',
    'https://www.farmacapital.mx/catalogo-propia/levofloxacino-amsa-500-mg-c-7-tabletas-7501349021419-caja-20261002.jpg',
    'propia'
  ),
  (
    '7502274792207', 'FC-74792207', '', '',
    'https://www.farmacapital.mx/catalogo-propia/aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207.jpg',
    'propia'
  ),
  (
    '7501349021488', 'FC-11294615', '', '',
    'https://www.farmacapital.mx/catalogo-propia/amikacina-amsa-500-mg-2ml-c-2-ampolletas-7501349021488.jpg',
    'propia'
  ),
  (
    '7501573907992', '', '%broxtorfan%adult%', '',
    'https://www.farmacapital.mx/catalogo-propia/broxtorfan-adulto-ambroxol-dextrometorfano-jarabe-120ml-7501573907992-caja-20261002.jpg',
    'propia'
  ),
  (
    '7503000422610', 'EQ-MAV007', '%cefalver%125%', '%250%',
    'https://www.farmacapital.mx/catalogo-propia/cefalver-cefalexina-susp-125mg-5ml-90ml-7503000422610.jpg',
    'propia'
  );

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
join tmp_foto_caja t
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
    or p.imagen_url ilike '%nadro%'
    or p.imagen_url ilike '%visoti%'
    or p.imagen_url ilike '%distribuidor/nadro%'
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
where p.codigo_barras in (
        '7501349021419', '7502274792207', '7501349021488',
        '7501573907992', '7503000422610'
      )
   or p.sku in ('FC-C721E8D7', 'FC-74792207', 'FC-11294615', 'EQ-MAV007')
   or p.nombre ilike '%broxtorfan%adult%'
order by p.nombre;
