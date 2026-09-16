-- Packshots oficiales (16-sep-2026)
-- 1) Reemplaza fotos improvisadas (celular / Open Facts) de Orbit 4's,
--    Clorets Plus 4's y Halls Yerbabuena. Mismo path + ?v=2 (cache).
-- 2) Faltantes con packshot de frente por EAN (Fahorro): Skittles,
--    Nórdiko Original, Lysol Crisp Linen, Honey Keeper gel 200 ml.
--
-- ORDEN: 1) merge/deploy de public/catalogo-propia/  2) pegar este SQL.
-- Galería: inserta es_principal=false y luego rota la principal
-- (evita ux_producto_imagenes_una_principal).
-- origen: propia (JPG en CDN FarmaCapital).
-- Idempotente: no duplica la misma URL.

begin;

create temporary table tmp_foto_pack (
  sku text,
  ean text,
  url text not null,
  forzar boolean not null default true
) on commit drop;

insert into tmp_foto_pack (sku, ean, url, forzar)
values
  -- reemplazo improvisada → packshot pieza de mostrador
  ('FC-LV-CLORETS40', '75068011',
   'https://www.farmacapital.mx/catalogo-propia/clorets-plus-4s.jpg?v=2',
   true),
  ('FC-LV-ORBITFRE40', '75038762',
   'https://www.farmacapital.mx/catalogo-propia/orbit-fresa-4s.jpg?v=2',
   true),
  ('FC-LV-ORBITHB40', '75038823',
   'https://www.farmacapital.mx/catalogo-propia/orbit-hierbabuena-4s.jpg?v=2',
   true),
  ('FC-LV-HALLSY12', '7622210267832',
   'https://www.farmacapital.mx/catalogo-propia/halls-yerbabuena-pack.jpg?v=2',
   true),
  ('7622210267832', '7622210267832',
   'https://www.farmacapital.mx/catalogo-propia/halls-yerbabuena-pack.jpg?v=2',
   true),

  -- faltantes (EAN exacto Fahorro)
  ('FC-LV-HALLSX12', null,
   'https://www.farmacapital.mx/catalogo-propia/halls-extra-strong.jpg',
   true),
  ('FC-LV-SKITTLES24', '7502226816944',
   'https://www.farmacapital.mx/catalogo-propia/skittles-original-22g.jpg',
   true),
  ('FC-40071775', '650240071775',
   'https://www.farmacapital.mx/catalogo-propia/nordiko-original-130g.jpg',
   false),
  ('FC-58752796', '7501058752796',
   'https://www.farmacapital.mx/catalogo-propia/lysol-crisp-linen-475g.jpg',
   false),
  ('FC-67923654', '7506267923654',
   'https://www.farmacapital.mx/catalogo-propia/honey-keeper-gel-manzanilla-200ml.jpg',
   false);

create temporary table tmp_foto_match (
  producto_id bigint primary key,
  url text not null
) on commit drop;

insert into tmp_foto_match (producto_id, url)
select distinct on (p.id)
  p.id,
  m.url
from public.productos p
join tmp_foto_pack m
  on (
    (m.sku is not null and p.sku = m.sku)
    or (m.ean is not null and nullif(btrim(p.codigo_barras), '') = m.ean)
  )
where m.forzar
   or p.imagen_url is null
   or btrim(p.imagen_url) = ''
order by p.id, m.url;

-- 1) Portada
update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_match m
where p.id = m.producto_id;

-- 2) Insertar como NO principal
insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  m.producto_id,
  m.url,
  regexp_replace(m.url, '^https://www\.farmacapital\.mx/', ''),
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = m.producto_id), 0) + 1,
  false,
  'propia'
from tmp_foto_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id
    and (i.url = m.url or i.url like regexp_replace(m.url, '\?v=\d+$', '') || '%')
);

-- 3) Rotar principal
update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_match);

update public.producto_imagenes i
set es_principal = true,
    posicion = 0
where i.producto_id in (select producto_id from tmp_foto_match)
  and i.url in (select url from tmp_foto_match)
  and not i.es_principal;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  left(p.imagen_url, 88) as foto
from public.productos p
join tmp_foto_match m on m.producto_id = p.id
order by p.sku;

commit;
