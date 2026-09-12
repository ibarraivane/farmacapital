-- Fotos propias para placeholders del catálogo (Cityfarma CF080926, Sahuayo 352582, Adidas Citymark).
-- Requiere deploy de public/catalogo-propia/*.jpg (PR fotos-placeholder-catalogo).
-- Corrige: constraint ux_producto_imagenes_una_principal.
-- Formato: INSERT…SELECT UNION ALL (sin VALUES multilínea) para evitar 42601 en el SQL editor.

begin;

create temporary table tmp_foto_map (
  sku text,
  ean text,
  nombre_ilike text,
  archivo text not null
) on commit drop;

insert into tmp_foto_map (sku, ean, nombre_ilike, archivo)
select * from (
  select 'FC-30000039'::text, '8907730000039'::text, '%Acetif%SI%'::text, 'acetif-si-inyectable-8907730000039.jpg'::text
  union all select 'FC-11705010', '013117050103', '%Affective%Predoblado%', 'affective-predoblado-013117050103.jpg'
  union all select null, '3616303440534', '%Adidas%Control%Pulse%', 'adidas-control-150ml-3616303440534.jpg'
  union all select null, '3616303441173', '%Adidas%Dynamic%Pulse%', 'adidas-dynamic-pulse-150ml-3616303441173.jpg'
  union all select null, '3616303441302', '%Adidas%Teamforce%', 'adidas-teamforce-150ml-3616303441302.jpg'
  union all select null, '3616303842420', '%Adidas%Power%Booster%', 'adidas-power-booster-150ml-3616303842420.jpg'
  union all select 'FC-04908776', '7503004908776', '%Metformina%Alpharma%850%', 'metformina-alpharma-850-c30.jpg'
  union all select 'FC-13452183', '7502213452183', '%Ampigrin%', 'ampigrin-ampicilina-500mg-c14.jpg'
  union all select 'FC-10735130', '7501577351308', '%Amsafast%', 'amsafast-amoxicilina-500mg-c12.jpg'
  union all select 'FC-13452206', '7502213452206', '%Busconet%', 'busconet-butilhioscina-10mg-c10.jpg'
  union all select 'FC-15773512', '7501577351292', '%Cirulan%', 'cirulan-cinnarizina-75mg-c20.jpg'
  union all select 'FC-10634310', '7501343106343', '%Clotrimazol%Alpharma%crema%', 'clotrimazol-alpharma-crema-20g.jpg'
  union all select 'FC-10634294', '7501343106299', '%Coriver%', 'coriver-losartan-50mg-c30.jpg'
  union all select 'FC-10634303', '7501343106305', '%Losil%S%', 'losil-s-losartan-hidroclorotiazida-50-12-5-c30.jpg'
  union all select 'FC-15773511', '7501577351285', '%Mometasona%Alpharma%', 'mometasona-alpharma-spray-nasal.jpg'
  union all select 'FC-10634327', '7501343106329', '%Valtrover%', 'valtrover-valsartan-80mg-c14.jpg'
  union all select 'FC-22220345', '7502222034504', '%Chicolastic%E1%', 'chicolastic-e1-7502222034504.jpg'
  union all select 'FC-22220346', '7502222034603', '%Chicolastic%E2%', 'chicolastic-e2-7502222034603.jpg'
  union all select 'FC-22220347', '7502222034702', '%Chicolastic%E3%', 'chicolastic-e3-7502222034702.jpg'
  union all select 'FC-22220348', '7502222034801', '%Chicolastic%E4%', 'chicolastic-e4-7502222034801.jpg'
  union all select 'FC-22220349', '7502222034901', '%Chicolastic%E5%', 'chicolastic-e5-7502222034901.jpg'
  union all select 'FC-04374010', '7501007437402', '%Kotex%Nocturna%con%Alas%', 'kotex-nocturna-con-alas-16pz.jpg'
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
