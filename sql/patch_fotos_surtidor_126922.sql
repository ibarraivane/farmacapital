-- Fotos El Surtidor 126922 — DESPUÉS del deploy de catalogo-propia/
-- Idempotente. No pisa foto que ya esté. No toca stock ni costos.

begin;

update public.productos p
set
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), v.url),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), v.url)
from (values
  ('7501318612655', 'https://www.farmacapital.mx/catalogo-propia/aspirina-protect-100mg-c28.jpg'),
  ('7501868901131', 'https://www.farmacapital.mx/catalogo-propia/dibar-azul-1000ml.jpg'),
  ('7501868901124', 'https://www.farmacapital.mx/catalogo-propia/dibar-azul-500ml.jpg'),
  ('7501033954061', 'https://www.farmacapital.mx/catalogo-propia/ensure-singles-chocolate-237ml.jpg'),
  ('7501033954078', 'https://www.farmacapital.mx/catalogo-propia/ensure-singles-fresa-237ml.jpg'),
  ('7501033956317', 'https://www.farmacapital.mx/catalogo-propia/pediasure-plus-chocolate-237ml.jpg'),
  ('7501033956294', 'https://www.farmacapital.mx/catalogo-propia/pediasure-plus-vainilla-237ml.jpg'),
  ('7501019068713', 'https://www.farmacapital.mx/catalogo-propia/saba-diarios-largos-c16.jpg')
) as v(ean, url)
where p.id = public.fc_buscar_producto_escaneo(v.ean);

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  v.url,
  v.path,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from (values
  ('7501318612655', 'https://www.farmacapital.mx/catalogo-propia/aspirina-protect-100mg-c28.jpg', 'catalogo-propia/aspirina-protect-100mg-c28.jpg'),
  ('7501868901131', 'https://www.farmacapital.mx/catalogo-propia/dibar-azul-1000ml.jpg', 'catalogo-propia/dibar-azul-1000ml.jpg'),
  ('7501868901124', 'https://www.farmacapital.mx/catalogo-propia/dibar-azul-500ml.jpg', 'catalogo-propia/dibar-azul-500ml.jpg'),
  ('7501033954061', 'https://www.farmacapital.mx/catalogo-propia/ensure-singles-chocolate-237ml.jpg', 'catalogo-propia/ensure-singles-chocolate-237ml.jpg'),
  ('7501033954078', 'https://www.farmacapital.mx/catalogo-propia/ensure-singles-fresa-237ml.jpg', 'catalogo-propia/ensure-singles-fresa-237ml.jpg'),
  ('7501033956317', 'https://www.farmacapital.mx/catalogo-propia/pediasure-plus-chocolate-237ml.jpg', 'catalogo-propia/pediasure-plus-chocolate-237ml.jpg'),
  ('7501033956294', 'https://www.farmacapital.mx/catalogo-propia/pediasure-plus-vainilla-237ml.jpg', 'catalogo-propia/pediasure-plus-vainilla-237ml.jpg'),
  ('7501019068713', 'https://www.farmacapital.mx/catalogo-propia/saba-diarios-largos-c16.jpg', 'catalogo-propia/saba-diarios-largos-c16.jpg')
) as v(ean, url, path)
join public.productos p on p.id = public.fc_buscar_producto_escaneo(v.ean)
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = p.id and i.url = v.url
);

commit;
