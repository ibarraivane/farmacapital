-- Fotos Ketorolaco beadvance 30 mg C/4 sublingual — 2026-10-04.
-- Packshot FarmaSmart BEA433 → public/catalogo-propia/.
-- ORDEN: 1) merge/deploy  2) este SQL.
-- origen SOLO admite rappi | distribuidor | propia | gs1 | otro.
-- Idempotente: no duplica la misma URL.

begin;

create temporary table tmp_foto_keto_bea (
  ean text,
  sku text,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_keto_bea (ean, sku, url, origen) values
  (
    '7501342804644',
    'FC-42804644',
    'https://www.farmacapital.mx/catalogo-propia/ketorolaco-beadvance-30mg-4tab-sublingual.jpg',
    'propia'
  );

update public.productos p
set imagen_url = t.url,
    imagen_mobile_url = t.url
from tmp_foto_keto_bea t
where (
    (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
    or (t.sku <> '' and p.sku in (t.sku, 'FC-ND-42804644', 'EQ-BEA433'))
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
from tmp_foto_keto_bea t
join public.productos p
  on (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
  or (t.sku <> '' and p.sku in (t.sku, 'FC-ND-42804644', 'EQ-BEA433'))
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = p.id and i.url = t.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (
  select p.id from public.productos p
  join tmp_foto_keto_bea t
    on (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
    or (t.sku <> '' and p.sku in (t.sku, 'FC-ND-42804644', 'EQ-BEA433'))
);

update public.producto_imagenes i
set es_principal = true
from public.productos p
join tmp_foto_keto_bea t
  on (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
  or (t.sku <> '' and p.sku in (t.sku, 'FC-ND-42804644', 'EQ-BEA433'))
where i.producto_id = p.id
  and i.url = t.url;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  left(p.imagen_url, 96) as foto,
  (
    select count(*) from public.producto_imagenes i where i.producto_id = p.id
  ) as galeria
from public.productos p
where p.codigo_barras = '7501342804644'
   or p.sku in ('FC-42804644', 'FC-ND-42804644', 'EQ-BEA433');
