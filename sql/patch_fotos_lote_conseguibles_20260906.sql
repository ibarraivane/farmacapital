-- Lote fotos conseguibles 2026-09-06 (Open Facts / ficha marca / mayoreo).
-- Correr DESPUÉS del deploy de Vercel (JPGs en public/catalogo-propia/).
-- Solo SKUs con packshot verificado vs presentación/EAN en inventario.
begin;

-- FC-40013805 | 650240013805 | Alliviax desinflamatorio 550 mg 10 tabletas
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/alliviax-550mg-10tab.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/alliviax-550mg-10tab.jpg'
where sku = 'FC-40013805' and codigo_barras = '650240013805'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/alliviax-550mg-10tab%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/alliviax-550mg-10tab.jpg',
  'catalogo-propia/alliviax-550mg-10tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-40013805'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/alliviax-550mg-10tab%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/alliviax-550mg-10tab%')
where i.producto_id = (select id from public.productos where sku = 'FC-40013805' limit 1);

-- FC-070839 | 650240070839 | Alliviax Garganta C/8 tabletas
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/alliviax-garganta-8tab.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/alliviax-garganta-8tab.jpg'
where sku = 'FC-070839' and codigo_barras = '650240070839'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/alliviax-garganta-8tab%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/alliviax-garganta-8tab.jpg',
  'catalogo-propia/alliviax-garganta-8tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-070839'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/alliviax-garganta-8tab%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/alliviax-garganta-8tab%')
where i.producto_id = (select id from public.productos where sku = 'FC-070839' limit 1);

-- FC-70600709 | 7501070600709 | Syncol 500/25/15 mg 12 comprimidos
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/syncol-12-comp.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/syncol-12-comp.jpg'
where sku = 'FC-70600709' and codigo_barras = '7501070600709'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/syncol-12-comp%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/syncol-12-comp.jpg',
  'catalogo-propia/syncol-12-comp.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-70600709'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/syncol-12-comp%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/syncol-12-comp%')
where i.producto_id = (select id from public.productos where sku = 'FC-70600709' limit 1);

-- FC-01246730 | 75916565 | Vicks Vaporub pomada 12 g
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/vicks-vaporub-12g.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/vicks-vaporub-12g.jpg'
where sku = 'FC-01246730' and codigo_barras = '75916565'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/vicks-vaporub-12g%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/vicks-vaporub-12g.jpg',
  'catalogo-propia/vicks-vaporub-12g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-01246730'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/vicks-vaporub-12g%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/vicks-vaporub-12g%')
where i.producto_id = (select id from public.productos where sku = 'FC-01246730' limit 1);

-- FC-12225140 | 354312225140 | Vitacilina ungüento 16 g
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/vitacilina-unguento-16g.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/vitacilina-unguento-16g.jpg'
where sku = 'FC-12225140' and codigo_barras = '354312225140'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/vitacilina-unguento-16g%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/vitacilina-unguento-16g.jpg',
  'catalogo-propia/vitacilina-unguento-16g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-12225140'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/vitacilina-unguento-16g%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/vitacilina-unguento-16g%')
where i.producto_id = (select id from public.productos where sku = 'FC-12225140' limit 1);

-- FC-75073107 | 75073107 | Rexona Woman Clinical Classic stick 46 g
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/rexona-clinical-classic-stick-46g.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/rexona-clinical-classic-stick-46g.jpg'
where sku = 'FC-75073107' and codigo_barras = '75073107'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/rexona-clinical-classic-stick-46g%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/rexona-clinical-classic-stick-46g.jpg',
  'catalogo-propia/rexona-clinical-classic-stick-46g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-75073107'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/rexona-clinical-classic-stick-46g%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/rexona-clinical-classic-stick-46g%')
where i.producto_id = (select id from public.productos where sku = 'FC-75073107' limit 1);

-- FC-09740442 | 7502009740442 | Klarix Claritromicina 250 mg 10 tabletas
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/klarix-claritromicina-250mg-10tab.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/klarix-claritromicina-250mg-10tab.jpg'
where sku = 'FC-09740442' and codigo_barras = '7502009740442'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/klarix-claritromicina-250mg-10tab%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/klarix-claritromicina-250mg-10tab.jpg',
  'catalogo-propia/klarix-claritromicina-250mg-10tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-09740442'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/klarix-claritromicina-250mg-10tab%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/klarix-claritromicina-250mg-10tab%')
where i.producto_id = (select id from public.productos where sku = 'FC-09740442' limit 1);

-- FC-68900264 | 7501868900264 | Alcohol Etilico Rojo 96°
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/dibar-alcohol-96-125ml.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/dibar-alcohol-96-125ml.jpg'
where sku = 'FC-68900264' and codigo_barras = '7501868900264'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/dibar-alcohol-96-125ml%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/dibar-alcohol-96-125ml.jpg',
  'catalogo-propia/dibar-alcohol-96-125ml.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-68900264'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/dibar-alcohol-96-125ml%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/dibar-alcohol-96-125ml%')
where i.producto_id = (select id from public.productos where sku = 'FC-68900264' limit 1);

-- FC-54354677 | 4005900036742 | Desodorante Nivea Men
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/nivea-men-black-white-rollon.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/nivea-men-black-white-rollon.jpg'
where sku = 'FC-54354677' and codigo_barras = '4005900036742'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/nivea-men-black-white-rollon%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/nivea-men-black-white-rollon.jpg',
  'catalogo-propia/nivea-men-black-white-rollon.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-54354677'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/nivea-men-black-white-rollon%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/nivea-men-black-white-rollon%')
where i.producto_id = (select id from public.productos where sku = 'FC-54354677' limit 1);

-- FC-75005092 | 0608875005092 | Heinz pouch papilla manzana 113 g
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/heinz-pouch-manzana-113g.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/heinz-pouch-manzana-113g.jpg'
where sku = 'FC-75005092' and codigo_barras = '0608875005092'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/heinz-pouch-manzana-113g%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/heinz-pouch-manzana-113g.jpg',
  'catalogo-propia/heinz-pouch-manzana-113g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-75005092'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/heinz-pouch-manzana-113g%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/heinz-pouch-manzana-113g%')
where i.producto_id = (select id from public.productos where sku = 'FC-75005092' limit 1);

-- FC-75784054 | 3337875784054 | CeraVe gel limpiador contra imperfecciones 236 ml
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/cerave-gel-imperfecciones-236ml.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/cerave-gel-imperfecciones-236ml.jpg'
where sku = 'FC-75784054' and codigo_barras = '3337875784054'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/cerave-gel-imperfecciones-236ml%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/cerave-gel-imperfecciones-236ml.jpg',
  'catalogo-propia/cerave-gel-imperfecciones-236ml.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-75784054'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/cerave-gel-imperfecciones-236ml%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/cerave-gel-imperfecciones-236ml%')
where i.producto_id = (select id from public.productos where sku = 'FC-75784054' limit 1);

-- FC-05809248 | 7506205809248 | Enfagrow Premium etapa 3 lata 800 g
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/enfagrow-premium-etapa3-800g.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/enfagrow-premium-etapa3-800g.jpg'
where sku = 'FC-05809248' and codigo_barras = '7506205809248'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/enfagrow-premium-etapa3-800g%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/enfagrow-premium-etapa3-800g.jpg',
  'catalogo-propia/enfagrow-premium-etapa3-800g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-05809248'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/enfagrow-premium-etapa3-800g%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/enfagrow-premium-etapa3-800g%')
where i.producto_id = (select id from public.productos where sku = 'FC-05809248' limit 1);

commit;

select sku, nombre, codigo_barras, left(coalesce(imagen_url,''), 90) as foto
from public.productos
where sku in ('FC-40013805','FC-070839','FC-70600709','FC-01246730','FC-12225140','FC-75073107','FC-09740442','FC-68900264','FC-54354677','FC-75005092','FC-75784054','FC-05809248')
order by sku;
