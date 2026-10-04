-- Fotos de caja que mandó el dueño el 02-oct-2026 (5 productos).
-- Quedaron en el PR #416, sin merge, y el SQL apuntaba mal:
--   Aktyzar C/14 iba a un SKU nuevo FC-74792207 que no existe.
--   Broxtorfan adulto no tiene ficha (el infantil es EQ-BIO188).
-- Este parche engancha cada foto al producto que sí está en catálogo.
-- No toca: Omeprazol Aktyzar C/120 (FC-82200016), Cefalver 250 (EQ-MAV008),
-- Amikacina de 1 ampolleta, Broxtorfan infantil (EQ-BIO188),
-- ni el EAN 7502274792207 (hoy está en el LGEN FC-16792555).
-- ORDEN: 1) merge/deploy de los JPG  2) este SQL.
-- Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temporary table tmp_foto_caja (
  sku text primary key,
  url text not null
) on commit drop;

insert into tmp_foto_caja (sku, url) values
  ('EQ-SOF066', 'https://www.farmacapital.mx/catalogo-propia/aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207.jpg'),
  ('FC-C721E8D7', 'https://www.farmacapital.mx/catalogo-propia/levofloxacino-amsa-500-mg-c-7-tabletas-7501349021419-caja-20261002.jpg'),
  ('FC-11294615', 'https://www.farmacapital.mx/catalogo-propia/amikacina-amsa-500-mg-2ml-c-2-ampolletas-7501349021488.jpg'),
  ('EQ-MAV007', 'https://www.farmacapital.mx/catalogo-propia/cefalver-cefalexina-susp-125mg-5ml-90ml-7503000422610.jpg');

create temporary table tmp_foto_hit (
  producto_id bigint primary key,
  url text not null
) on commit drop;

insert into tmp_foto_hit (producto_id, url)
select p.id, t.url
from public.productos p
join tmp_foto_caja t on p.sku = t.sku;

-- Broxtorfan adulto: solo si ya hay ficha con ese EAN, el nombre «adulto»,
-- o la foto con marca de agua. Nunca el infantil EQ-BIO188.
insert into tmp_foto_hit (producto_id, url)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/broxtorfan-adulto-ambroxol-dextrometorfano-jarabe-120ml-7501573907992-caja-20261002.jpg'
from public.productos p
where p.sku <> 'EQ-BIO188'
  and (
    p.codigo_barras = '7501573907992'
    or (p.nombre ilike '%broxtorfan%' and p.nombre ilike '%adult%')
    or coalesce(p.imagen_url, '') ilike '%broxtorfan-adulto-ambroxol-dextrometorfano-jarabe-12-7501573907992%'
  )
on conflict (producto_id) do nothing;

update public.productos p
set imagen_url = h.url,
    imagen_mobile_url = h.url
from tmp_foto_hit h
where p.id = h.producto_id
  and coalesce(p.imagen_url, '') is distinct from h.url;

update public.producto_imagenes i
set es_principal = false
from tmp_foto_hit h
where i.producto_id = h.producto_id
  and i.es_principal
  and i.url is distinct from h.url;

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select h.producto_id,
       h.url,
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = h.producto_id), 0) + 1,
       true,
       'propia'
from tmp_foto_hit h
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = h.producto_id and i.url = h.url
);

update public.producto_imagenes i
set es_principal = true
from tmp_foto_hit h
where i.producto_id = h.producto_id
  and i.url = h.url
  and not i.es_principal;

commit;

select p.id, p.sku, p.nombre, p.presentacion, p.stock,
       left(coalesce(p.imagen_url, ''), 130) as imagen
from public.productos p
where p.sku in ('EQ-SOF066', 'FC-C721E8D7', 'FC-11294615', 'EQ-MAV007', 'EQ-BIO188', 'EQ-MAV008', 'FC-82200016')
order by p.sku;
