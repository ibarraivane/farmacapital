-- Fotos placeholder catálogo 2026-09-12
-- Causa: packshots Cityfarma CF080926 / Sahuayo 352582 existían en commits
-- previos pero no en CDN ni en imagen_url → cubo Package en tienda.
-- Adidas Citymark: 4/5 con packshot (Fresh Endurance 3616303842550 pendiente).
-- ORDEN: 1) merge/deploy public/catalogo-propia  2) pegar este SQL.
-- Galería: insert es_principal=false → degrada → marca (evita unique principal).
begin;

create temporary table _fc_fotos_ph (
  sku text,
  ean text,
  nombre_ilike text,
  archivo text not null
) on commit drop;

insert into _fc_fotos_ph (sku, ean, nombre_ilike, archivo) values
  ('FC-30000039', '8907730000039', '%Acetif%SI%', 'acetif-si-1000mg-100ml.jpg')
  ('FC-04908776', '7503004908776', '%Metformina%Alpharma%850%', 'metformina-alpharma-850-c30.jpg')
  ('EQ-SON164', '7502001163485', '%Clotrimazol%Dual%', 'clotrimazol-dual-sons.jpg')
  ('FC-26294254', '7502226294254', '%terbinafina%spray%', 'losil-s-terbinafina-spray.jpg')
  ('FC-09744440', '7502009744440', '%Valtrover%G%', 'valtrover-g-4mg-c10.jpg')
  ('FC-DE106642', '780083140939', '%Ampigrin%Infantil%', 'ampigrin-infantil-3amp.jpg')
  ('FC-49027343', '7501349027343', '%Amsafast%120%', 'amsafast-120mg-c21.jpg')
  ('FC-09747052', '7502009747052', '%Coriver%750%', 'coriver-750mg-c10.jpg')
  ('FC-49028036', '7501349028036', '%Mometasona%AMSA%', 'mometasona-amsa-18ml.jpg')
  ('FC-2001A890', '780083140922', '%Ampigrin%AD%', 'ampigrin-ad-3amp.jpg')
  ('EQ-SON033', '7502001160019', '%Busconet%', 'busconet-inyectable-5ml.jpg')
  ('EQ-NOV005', '75006433', '%Cirulan%', 'cirulan-gotas-20ml.jpg')
  ('FC-11705010', '013117050103', '%Affective%Predoblado%', 'affective-predoblado-10-013117050103.jpg')
  ('FC-11705414', '013117054149', null, 'chicolastic-classic-e4-14-013117054149.jpg')
  ('FC-11701087', '013117010879', null, 'chicolastic-classic-e2-14-013117010879.jpg')
  ('FC-11701268', '013117012682', null, 'chicolastic-classic-e1-14-013117012682.jpg')
  ('FC-11701174', '013117011746', null, 'chicolastic-classic-e5-14-013117011746.jpg')
  ('FC-11705314', '013117053142', null, 'chicolastic-classic-e3-14-013117053142.jpg')
  ('FC-43411449', '7501943411449', '%Kotex%Maxi%Nocturna%', 'kotex-maxi-nocturna-alas-10-7501943411449.jpg')
  ('FC-43418509', '7501943418509', '%Kotex%Nocturna%', 'kotex-nocturna-alas-8-7501943418509.jpg')
  ('FC-03440534', '3616303440534', '%ADIDAS%CONTROL%', 'adidas-control-150ml-3616303440534.jpg')
  ('FC-03441173', '3616303441173', '%ADIDAS%DYNAMIC%PULSE%', 'adidas-dynamic-pulse-150ml-3616303441173.jpg')
  ('FC-03441302', '3616303441302', '%ADIDAS%TEAMFORCE%', 'adidas-teamforce-150ml-3616303441302.jpg')
  ('FC-03842420', '3616303842420', '%ADIDAS%POWER%BOOSTER%', 'adidas-power-booster-150ml-3616303842420.jpg');

create temporary table _fc_fotos_match on commit drop as
select distinct p.id as producto_id, t.archivo
from public.productos p
join _fc_fotos_ph t on (
  (t.sku is not null and p.sku = t.sku)
  or (t.ean is not null and p.codigo_barras = t.ean)
  or (t.nombre_ilike is not null and p.nombre ilike t.nombre_ilike)
);

update public.productos p
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/' || m.archivo,
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/' || m.archivo
from _fc_fotos_match m
where p.id = m.producto_id
  and (
    p.imagen_url is null
    or btrim(p.imagen_url) = ''
    or p.imagen_url not like ('%/catalogo-propia/' || m.archivo || '%')
    or p.imagen_url !~* 'farmacapital\.mx/catalogo-propia/'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  m.producto_id,
  'https://www.farmacapital.mx/catalogo-propia/' || m.archivo,
  'catalogo-propia/' || m.archivo,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = m.producto_id), 0) + 1,
  false,
  'propia'
from _fc_fotos_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id
    and i.url like ('%/catalogo-propia/' || m.archivo || '%')
);

update public.producto_imagenes i
set es_principal = false
from _fc_fotos_match m
where i.producto_id = m.producto_id
  and i.es_principal
  and i.url not like ('%/catalogo-propia/' || m.archivo || '%');

update public.producto_imagenes i
set es_principal = true
from _fc_fotos_match m
where i.producto_id = m.producto_id
  and i.url like ('%/catalogo-propia/' || m.archivo || '%')
  and not i.es_principal;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  left(coalesce(p.imagen_url, ''), 78) as foto
from public.productos p
join _fc_fotos_match m on m.producto_id = p.id
order by p.nombre;

commit;
