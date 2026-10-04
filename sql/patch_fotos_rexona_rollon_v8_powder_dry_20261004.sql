-- Fotos Rexona roll-on 30 ml (V8 + Powder Dry) — 2026-10-04.
-- Packshots en public/catalogo-propia/. ORDEN: 1) merge/deploy  2) este SQL.
-- origen SOLO admite rappi | distribuidor | propia | gs1 | otro.
-- Idempotente: no duplica la misma URL.

begin;

create temporary table tmp_foto_rexona_ro (
  ean text,
  sku text,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_rexona_ro (ean, sku, url, origen) values
  (
    '78930841',
    'FC-78930841',
    'https://www.farmacapital.mx/catalogo-propia/rexona-men-v8-roll-on-30-ml-78930841.jpg',
    'propia'
  ),
  (
    '78924239',
    'FC-78924239',
    'https://www.farmacapital.mx/catalogo-propia/rexona-powder-dry-roll-on-30-ml-78924239.jpg',
    'propia'
  );

update public.productos p
set imagen_url = t.url,
    imagen_mobile_url = t.url
from tmp_foto_rexona_ro t
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
from tmp_foto_rexona_ro t
join public.productos p
  on (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
  or (t.sku <> '' and p.sku = t.sku)
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = p.id and i.url = t.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (
  select p.id from public.productos p
  join tmp_foto_rexona_ro t
    on (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
    or (t.sku <> '' and p.sku = t.sku)
);

update public.producto_imagenes i
set es_principal = true
from public.productos p
join tmp_foto_rexona_ro t
  on (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
  or (t.sku <> '' and p.sku = t.sku)
where i.producto_id = p.id
  and i.url = t.url;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.imagen_url,
  (select count(*) from public.producto_imagenes i where i.producto_id = p.id) as n_imgs
from public.productos p
where p.codigo_barras in ('78930841', '78924239')
   or p.sku in ('FC-78930841', 'FC-78924239')
order by p.codigo_barras;
