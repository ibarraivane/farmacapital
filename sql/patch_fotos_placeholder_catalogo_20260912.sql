-- Fotos propias para placeholders del catálogo (Cityfarma CF080926, Sahuayo 352582, Adidas Citymark).
-- Requiere deploy de public/catalogo-propia/*.jpg (PR fotos-placeholder-catalogo).
-- Corrige: constraint ux_producto_imagenes_una_principal.
-- Formato: INSERT…SELECT UNION ALL (sin VALUES multilínea) para evitar 42601 en el SQL editor.
-- Sin updated_at en productos (no existe en prod).

begin;

create temporary table tmp_foto_map (
  sku text,
  ean text,
  nombre_ilike text,
  archivo text not null
) on commit drop;

insert into tmp_foto_map (sku, ean, nombre_ilike, archivo)
select * from (
  select 'FC-30000039'::text, '8907730000039'::text, '%Acetif%SI%'::text, 'acetif-si-1000mg-100ml.jpg'::text
  union all select 'FC-04908776', '7503004908776', '%Metformina%Alpharma%850%', 'metformina-alpharma-850-c30.jpg'
  union all select 'EQ-SON164', '7502001163485', '%Clotrimazol%Dual%', 'clotrimazol-dual-sons.jpg'
  union all select 'FC-26294254', '7502226294254', '%terbinafina%spray%', 'losil-s-terbinafina-spray.jpg'
  union all select 'FC-09744440', '7502009744440', '%Valtrover%G%', 'valtrover-g-4mg-c10.jpg'
  union all select 'FC-DE106642', '780083140939', '%Ampigrin%Infantil%', 'ampigrin-infantil-3amp.jpg'
  union all select 'FC-49027343', '7501349027343', '%Amsafast%120%', 'amsafast-120mg-c21.jpg'
  union all select 'FC-09747052', '7501349028036', '%Coriver%750%', 'coriver-750mg-c10.jpg'
  union all select 'FC-49028036', null, '%Mometasona%AMSA%', 'mometasona-amsa-18ml.jpg'
  union all select 'FC-2001A890', '780083140922', '%Ampigrin%AD%', 'ampigrin-ad-3amp.jpg'
  union all select 'EQ-SON033', '7502001160019', '%Busconet%', 'busconet-inyectable-5ml.jpg'
  union all select 'EQ-NOV005', '75006433', '%Cirulan%', 'cirulan-gotas-20ml.jpg'
  union all select 'FC-11705010', '013117050103', '%Affective%Predoblado%', 'affective-predoblado-10-013117050103.jpg'
  union all select 'FC-11705414', '013117054149', null, 'chicolastic-classic-e4-14-013117054149.jpg'
  union all select 'FC-11701087', '013117010879', null, 'chicolastic-classic-e2-14-013117010879.jpg'
  union all select 'FC-11701268', '013117012682', null, 'chicolastic-classic-e1-14-013117012682.jpg'
  union all select 'FC-11701174', '013117011746', null, 'chicolastic-classic-e5-14-013117011746.jpg'
  union all select 'FC-11705314', '013117053142', null, 'chicolastic-classic-e3-14-013117053142.jpg'
  union all select 'FC-43411449', '7501943411449', '%Kotex%Maxi%Nocturna%', 'kotex-maxi-nocturna-alas-10-7501943411449.jpg'
  union all select 'FC-43418509', '7501943418509', '%Kotex%Nocturna%', 'kotex-nocturna-alas-8-7501943418509.jpg'
  union all select 'FC-03440534', '3616303440534', '%ADIDAS%CONTROL%', 'adidas-control-150ml-3616303440534.jpg'
  union all select 'FC-03441173', '3616303441173', '%ADIDAS%DYNAMIC%PULSE%', 'adidas-dynamic-pulse-150ml-3616303441173.jpg'
  union all select 'FC-03441302', '3616303441302', '%ADIDAS%TEAMFORCE%', 'adidas-teamforce-150ml-3616303441302.jpg'
  union all select 'FC-03842420', '3616303842420', '%ADIDAS%POWER%BOOSTER%', 'adidas-power-booster-150ml-3616303842420.jpg'
) as t(sku, ean, nombre_ilike, archivo);

create temporary table tmp_foto_match (
  producto_id bigint primary key,
  archivo text not null,
  url text not null
) on commit drop;

insert into tmp_foto_match (producto_id, archivo, url)
select distinct on (p.id)
  p.id,
  m.archivo,
  'https://www.farmacapital.mx/catalogo-propia/' || m.archivo
from productos p
join tmp_foto_map m
  on (
    (m.sku is not null and p.sku = m.sku)
    or (m.ean is not null and nullif(btrim(p.codigo_barras), '') = m.ean)
    or (m.nombre_ilike is not null and p.nombre ilike m.nombre_ilike)
  )
order by p.id, m.archivo;

-- 1) Portada en productos
update productos p
set
  imagen_url = m.url,
  imagen_mobile_url = m.url
from tmp_foto_match m
where p.id = m.producto_id;

-- 2) Insertar propia como NO principal (evita choque con otra principal)
insert into producto_imagenes (producto_id, storage_path, posicion, es_principal, origen)
select
  m.producto_id,
  m.url,
  coalesce((select max(pi.posicion) from producto_imagenes pi where pi.producto_id = m.producto_id), 0) + 1,
  false,
  'propia'
from tmp_foto_match m
where not exists (
  select 1
  from producto_imagenes pi
  where pi.producto_id = m.producto_id
    and pi.storage_path = m.url
);

-- 3) Bajar cualquier principal actual
update producto_imagenes pi
set es_principal = false
from tmp_foto_match m
where pi.producto_id = m.producto_id
  and pi.es_principal = true;

-- 4) Subir la propia a principal
update producto_imagenes pi
set es_principal = true,
    posicion = 0
from tmp_foto_match m
where pi.producto_id = m.producto_id
  and pi.storage_path = m.url;

-- Diagnóstico (antes del commit; las temp se dropean al cerrar la tx)
select
  (select count(*) from tmp_foto_map) as filas_mapa,
  (select count(*) from tmp_foto_match) as productos_matcheados;

select
  p.id,
  p.sku,
  p.codigo_barras,
  left(p.nombre, 60) as nombre,
  p.imagen_url
from productos p
join tmp_foto_match m on m.producto_id = p.id
order by p.sku nulls last, p.id;

commit;
