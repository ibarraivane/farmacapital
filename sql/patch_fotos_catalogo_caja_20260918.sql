-- ============================================================================
-- Fotos de vitrina (Adidas mal, cajas vacías, Fahorro oculto, cubrebocas negro)
--
-- PRIMERO: merge/deploy de este PR (los JPG viven en public/catalogo-propia/).
-- DESPUÉS: pegar TODO en Supabase → SQL Editor → Run.
--
-- Galería: inserta es_principal=false y luego rota
-- (evita ux_producto_imagenes_una_principal). Idempotente. No usa Fahorro.
-- ============================================================================

begin;

create temp table _fc_foto_caja (
  sku  text,
  ean  text,
  file text not null
) on commit drop;

insert into _fc_foto_caja (sku, ean, file) values
  ('FC-03441302', '3616303441302', 'adidas-teamforce-150ml-3616303441302.jpg'),
  ('FC-03441173', '3616303441173', 'adidas-dynamic-pulse-150ml-3616303441173.jpg'),
  ('FC-65065322', '7501065065322', 'advil-12horas-600mg-c6-7501065065322.jpg'),
  ('FC-65013767', '7501065013767', 'advil-200mg-c12-7501065013767.jpg'),
  ('FC-89100101', '7501868910010', 'dibar-algodon-plisado-200g-7501868910010.jpg'),
  ('FC-D5AC44CA', '7503001007113', 'amifarin-500mg-20caps-7503001007113.jpg'),
  ('EQ-LAN057',   '7502247373495', 'bacat-atorvastatina-20mg-c30-7502247373495.jpg'),
  ('FC-85103015', '6195851030154', 'bebin-super-toallitas-40-6195851030154.jpg'),
  ('FC-85800198', '6195858001980', 'bebin-super-toallitas-80-6195858001980.jpg'),
  ('FC-49028296', '7501349028296', 'bicalutamida-amsa-50mg-c14-7501349028296.jpg'),
  ('FC-90910182', '7501390910182', 'biotrefon-l-12sobres-7501390910182.jpg'),
  ('EQ-RAM141',   '7502227876428', 'breflumar-5mg-7502227876428.jpg'),
  ('FC-IFC-82084', null,           'brocha-tinte-peine-cola.jpg'),
  ('FC-46007083', '7509546007083', 'colgate-total12-clean-mint-50ml-7509546007083.jpg'),
  ('FC-46000350', '7509546000350', 'colgate-triple-accion-150ml-7509546000350.jpg'),
  ('FC-84500522', '7506484500522', 'micropore-blanca-2.5x5-3m.jpg'),
  ('FC-84500607', '7506484500607', 'micropore-blanca-2.5x5-3m.jpg'),
  ('FMX-301138',  null,            'micropore-blanca-2.5x5-3m.jpg'),
  ('FMX-301139',  '7506484500539', 'cintapore-piel-1.25x5.jpg'),
  ('FMX-301135',  '7506484500515', 'micropore-blanca-1.25x5-3m.jpg'),
  ('FC-84500546', '7506484500546', 'cintapore-piel-2.5x5.jpg'),
  ('FC-95337454', '7506295337454', 'clearblue-digital-semanas-7506295337454.jpg'),
  ('EQ-BIO212',   '7501573909958', 'colchicina-biomep-1mg-c30-7501573909958.jpg'),
  ('FC-85171118', '7501685171118', 'sico-invisible-c3-7501685171113.jpg'),
  ('FC-00100013', '2008500100013', 'cubrebocas-tricapa-negro.jpg');

create temp table _fc_foto_match (
  producto_id bigint primary key,
  url text not null,
  file text not null
) on commit drop;

insert into _fc_foto_match (producto_id, url, file)
select distinct on (p.id)
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/' || t.file,
  t.file
from public.productos p
join _fc_foto_caja t
  on (t.sku is not null and p.sku = t.sku)
  or (t.ean is not null and nullif(btrim(p.codigo_barras), '') = t.ean)
order by p.id, t.file;

update public.productos p
set
  imagen_url = m.url,
  imagen_mobile_url = m.url
from _fc_foto_match m
where p.id = m.producto_id
  and coalesce(p.imagen_url, '') is distinct from m.url;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  m.producto_id,
  m.url,
  'catalogo-propia/' || m.file,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = m.producto_id), 0) + 1,
  false,
  'propia'
from _fc_foto_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from _fc_foto_match)
  and i.es_principal
  and i.url not in (
    select m.url from _fc_foto_match m where m.producto_id = i.producto_id
  );

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from _fc_foto_match)
  and i.es_principal is distinct from true
  and i.url in (
    select m.url from _fc_foto_match m where m.producto_id = i.producto_id
  );

select
  p.id,
  p.sku,
  left(p.nombre, 48) as nombre,
  left(p.imagen_url, 80) as foto
from public.productos p
join _fc_foto_match m on m.producto_id = p.id
order by p.sku;

notify pgrst, 'reload schema';

commit;
