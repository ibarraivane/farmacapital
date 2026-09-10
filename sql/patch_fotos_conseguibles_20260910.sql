-- Fotos conseguibles 2026-09-10 (Farmatodo / Levic / Open Facts / catalogo-propia).
-- catalogo-propia: ya en el CDN de Vercel (lote 06-sep + gomas/papillas de este pase).
-- Farmatodo: gruporfp.vteximg.com.br por EAN exacto (igual que Nadro 30-ago).
-- Levic: visoti.mx/imagenes/Grande/{clave}.webp
-- Idempotente: no pisa una foto distinta; no duplica la misma URL.
begin;

-- FC-68900264 | 7501868900264 | Alcohol Etilico Rojo 96° · catalogo-propia
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


-- FC-LV-ORBITHB40 | 75038823 | Orbit 4's Hierbabuena · openproductsfacts
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/orbit-hierbabuena-4s.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/orbit-hierbabuena-4s.jpg'
where sku = 'FC-LV-ORBITHB40' and codigo_barras = '75038823'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/orbit-hierbabuena-4s%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/orbit-hierbabuena-4s.jpg',
  'catalogo-propia/orbit-hierbabuena-4s.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-LV-ORBITHB40'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/orbit-hierbabuena-4s%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/orbit-hierbabuena-4s%')
where i.producto_id = (select id from public.productos where sku = 'FC-LV-ORBITHB40' limit 1);


-- FC-LV-CLORETS40 | 75068011 | Clorets Plus 4's · openfoodfacts
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/clorets-plus-4s.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/clorets-plus-4s.jpg'
where sku = 'FC-LV-CLORETS40' and codigo_barras = '75068011'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/clorets-plus-4s%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/clorets-plus-4s.jpg',
  'catalogo-propia/clorets-plus-4s.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-LV-CLORETS40'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/clorets-plus-4s%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/clorets-plus-4s%')
where i.producto_id = (select id from public.productos where sku = 'FC-LV-CLORETS40' limit 1);


-- FC-LV-ORBITFRE40 | 75038762 | Orbit 4's Fresa · openfoodfacts
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/orbit-fresa-4s.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/orbit-fresa-4s.jpg'
where sku = 'FC-LV-ORBITFRE40' and codigo_barras = '75038762'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/orbit-fresa-4s%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/orbit-fresa-4s.jpg',
  'catalogo-propia/orbit-fresa-4s.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-LV-ORBITFRE40'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/orbit-fresa-4s%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/orbit-fresa-4s%')
where i.producto_id = (select id from public.productos where sku = 'FC-LV-ORBITFRE40' limit 1);


-- 7622210267832 | 7622210267832 | Halls Yerbabuena pack · openfoodfacts
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/halls-yerbabuena-pack.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/halls-yerbabuena-pack.jpg'
where sku = '7622210267832' and codigo_barras = '7622210267832'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/halls-yerbabuena-pack%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/halls-yerbabuena-pack.jpg',
  'catalogo-propia/halls-yerbabuena-pack.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = '7622210267832'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/halls-yerbabuena-pack%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/halls-yerbabuena-pack%')
where i.producto_id = (select id from public.productos where sku = '7622210267832' limit 1);


-- FC-01246730 | 75916565 | Vicks Vaporub pomada 12 g · catalogo-propia
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


-- FC-40013805 | 650240013805 | Alliviax desinflamatorio 550 mg 10 tabletas · catalogo-propia
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


-- FC-54354677 | 4005900036742 | Desodorante Nivea Men · catalogo-propia
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


-- EQ-AMS318 | 7501349028159 | Losartan AMSA 30 comprimidos 50 mg · farmatodo (copia propia)
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/losartan-amsa-50mg-30comp.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/losartan-amsa-50mg-30comp.jpg'
where sku = 'EQ-AMS318' and codigo_barras = '7501349028159'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/losartan-amsa-50mg-30comp%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/losartan-amsa-50mg-30comp.jpg',
  'catalogo-propia/losartan-amsa-50mg-30comp.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'EQ-AMS318'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/losartan-amsa-50mg-30comp%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/losartan-amsa-50mg-30comp%')
where i.producto_id = (select id from public.productos where sku = 'EQ-AMS318' limit 1);


-- FC-7D1D9857 | sin-ean | Acetilsalicilico · catalogo-propia
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab.jpg'
where sku = 'FC-7D1D9857'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab.jpg',
  'catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-7D1D9857'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab%')
where i.producto_id = (select id from public.productos where sku = 'FC-7D1D9857' limit 1);


-- FC-40007651 | 650240007651 | BIO ELCTRO · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005561/650240007651_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005561/650240007651_01.jpg'
where sku = 'FC-40007651' and codigo_barras = '650240007651'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%650240007651%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7005561/650240007651_01.jpg',
  'distribuidor/bio-electro-24tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-40007651'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%650240007651%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%650240007651%')
where i.producto_id = (select id from public.productos where sku = 'FC-40007651' limit 1);


-- EQ-BIO002 | 7501573900535 | Biomesina 10 tab 10 mg · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006919/7501573900535_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006919/7501573900535_01.jpg'
where sku = 'EQ-BIO002' and codigo_barras = '7501573900535'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501573900535%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7006919/7501573900535_01.jpg',
  'distribuidor/biomesina-10mg-10tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'EQ-BIO002'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501573900535%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501573900535%')
where i.producto_id = (select id from public.productos where sku = 'EQ-BIO002' limit 1);


-- FC-070839 | 650240070839 | Alliviax Garganta C/ 6tabletas · farmatodo
-- Farmatodo etiqueta este EAN como Alliviax 550 mg C/6 (la presentación local también dice 550 mg).
-- El nombre «Garganta» conviene revisarlo en mostrador.
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7011624/650240070839_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7011624/650240070839_01.jpg'
where sku = 'FC-070839' and codigo_barras = '650240070839'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%650240070839%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7011624/650240070839_01.jpg',
  'distribuidor/alliviax-550mg-6tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-070839'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%650240070839%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%650240070839%')
where i.producto_id = (select id from public.productos where sku = 'FC-070839' limit 1);


-- FC-12225133 | 354312225133 | Vitacilina ungüento 28 g · farmatodo (copia propia)
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/vitacilina-unguento-28g.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/vitacilina-unguento-28g.jpg'
where sku = 'FC-12225133' and codigo_barras = '354312225133'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/vitacilina-unguento-28g%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/vitacilina-unguento-28g.jpg',
  'catalogo-propia/vitacilina-unguento-28g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-12225133'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/vitacilina-unguento-28g%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/vitacilina-unguento-28g%')
where i.producto_id = (select id from public.productos where sku = 'FC-12225133' limit 1);


-- FC-40053634 | 650240053634 | Alli Triple 50/.25/50/50 mg 6 tabletas · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005558/0650240053634_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005558/0650240053634_01.jpg'
where sku = 'FC-40053634' and codigo_barras = '650240053634'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%650240053634%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7005558/0650240053634_01.jpg',
  'distribuidor/alli-triple-6tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-40053634'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%650240053634%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%650240053634%')
where i.producto_id = (select id from public.productos where sku = 'FC-40053634' limit 1);


-- FC-46029825 | 7509546029825 | DESOD NEUTRO B R-ON 65 ML · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6997354/7509546029825_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6997354/7509546029825_01.jpg'
where sku = 'FC-46029825' and codigo_barras = '7509546029825'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7509546029825%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6997354/7509546029825_01.jpg',
  'distribuidor/neutro-balance-clear-rollon-65ml.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-46029825'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7509546029825%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7509546029825%')
where i.producto_id = (select id from public.productos where sku = 'FC-46029825' limit 1);


-- FC-58651129 | 7501058651129 | Gerber Junior pouch frutas mixtas 95 g · openfoodfacts
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/gerber-junior-frutas-mixtas-95g.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/gerber-junior-frutas-mixtas-95g.jpg'
where sku = 'FC-58651129' and codigo_barras = '7501058651129'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/gerber-junior-frutas-mixtas-95g%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/gerber-junior-frutas-mixtas-95g.jpg',
  'catalogo-propia/gerber-junior-frutas-mixtas-95g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-58651129'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/gerber-junior-frutas-mixtas-95g%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/gerber-junior-frutas-mixtas-95g%')
where i.producto_id = (select id from public.productos where sku = 'FC-58651129' limit 1);


-- FC-75005092 | 0608875005092 | Heinz pouch papilla manzana 113 g · catalogo-propia
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


-- FC-75073107 | 75073107 | Rexona Woman Clinical Classic stick 46 g · catalogo-propia
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


-- FC-75102421 | 7506475102421 | Gerber Etapa 2 manzana 100 g · openfoodfacts
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/gerber-etapa2-manzana-100g.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/gerber-etapa2-manzana-100g.jpg'
where sku = 'FC-75102421' and codigo_barras = '7506475102421'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/gerber-etapa2-manzana-100g%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/gerber-etapa2-manzana-100g.jpg',
  'catalogo-propia/gerber-etapa2-manzana-100g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-75102421'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/gerber-etapa2-manzana-100g%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/gerber-etapa2-manzana-100g%')
where i.producto_id = (select id from public.productos where sku = 'FC-75102421' limit 1);


-- FC-75102452 | 7506475102452 | Gerber Etapa 2 pera 100 g · openfoodfacts
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/gerber-etapa2-pera-100g.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/gerber-etapa2-pera-100g.jpg'
where sku = 'FC-75102452' and codigo_barras = '7506475102452'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/gerber-etapa2-pera-100g%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/gerber-etapa2-pera-100g.jpg',
  'catalogo-propia/gerber-etapa2-pera-100g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-75102452'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/gerber-etapa2-pera-100g%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/gerber-etapa2-pera-100g%')
where i.producto_id = (select id from public.productos where sku = 'FC-75102452' limit 1);


-- EQ-BEA367 | 7501342803548 | Losartan beadvance 60 tab 50 mg · levic
update public.productos
set imagen_url = 'https://visoti.mx/imagenes/Grande/BEA367.webp',
    imagen_mobile_url = 'https://visoti.mx/imagenes/Grande/BEA367.webp'
where sku = 'EQ-BEA367' and codigo_barras = '7501342803548'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%losartan-beadvance-50mg-60tab%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://visoti.mx/imagenes/Grande/BEA367.webp',
  'distribuidor/losartan-beadvance-50mg-60tab.webp',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'EQ-BEA367'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%losartan-beadvance-50mg-60tab%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%losartan-beadvance-50mg-60tab%')
where i.producto_id = (select id from public.productos where sku = 'EQ-BEA367' limit 1);


-- EQ-INN022 | 008400005656 | Optimila-H Grin gotas 15 mL · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7000242/008400005656_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7000242/008400005656_01.jpg'
where sku = 'EQ-INN022' and codigo_barras = '008400005656'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%008400005656%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7000242/008400005656_01.jpg',
  'distribuidor/optimila-h-grin-15ml.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'EQ-INN022'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%008400005656%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%008400005656%')
where i.producto_id = (select id from public.productos where sku = 'EQ-INN022' limit 1);


-- EQ-MAV102 | 7502009740794 | Lincover lincomicina 16 cáps 500 mg · levic
update public.productos
set imagen_url = 'https://visoti.mx/imagenes/Grande/MAV102.webp',
    imagen_mobile_url = 'https://visoti.mx/imagenes/Grande/MAV102.webp'
where sku = 'EQ-MAV102' and codigo_barras = '7502009740794'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%lincover-lincomicina-500mg-16caps%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://visoti.mx/imagenes/Grande/MAV102.webp',
  'distribuidor/lincover-lincomicina-500mg-16caps.webp',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'EQ-MAV102'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%lincover-lincomicina-500mg-16caps%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%lincover-lincomicina-500mg-16caps%')
where i.producto_id = (select id from public.productos where sku = 'EQ-MAV102' limit 1);


-- EQ-MAV204 | 7502009744358 | Alderan Losartán 15 tab 100 mg · farmatodo (copia propia)
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/alderan-losartan-100mg-15tab.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/alderan-losartan-100mg-15tab.jpg'
where sku = 'EQ-MAV204' and codigo_barras = '7502009744358'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/alderan-losartan-100mg-15tab%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/alderan-losartan-100mg-15tab.jpg',
  'catalogo-propia/alderan-losartan-100mg-15tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'EQ-MAV204'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/alderan-losartan-100mg-15tab%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/alderan-losartan-100mg-15tab%')
where i.producto_id = (select id from public.productos where sku = 'EQ-MAV204' limit 1);


-- EQ-SON084 | 7502001161597 | Lisonin 1 amp 300 mg/1 ml · levic
update public.productos
set imagen_url = 'https://visoti.mx/imagenes/Grande/SON084.webp',
    imagen_mobile_url = 'https://visoti.mx/imagenes/Grande/SON084.webp'
where sku = 'EQ-SON084' and codigo_barras = '7502001161597'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%lisonin-300mg-1ml%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://visoti.mx/imagenes/Grande/SON084.webp',
  'distribuidor/lisonin-300mg-1ml.webp',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'EQ-SON084'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%lisonin-300mg-1ml%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%lisonin-300mg-1ml%')
where i.producto_id = (select id from public.productos where sku = 'EQ-SON084' limit 1);


-- FC-09740442 | 7502009740442 | Klarix Claritromicina 250 mg 10 tabletas · catalogo-propia
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


-- FC-12225140 | 354312225140 | Vitacilina ungüento 16 g · catalogo-propia
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


-- FC-16792760 | 7502216792760 | Omeprazol 20 mg 30 cápsulas LGEN · farmatodo (copia propia)
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/omeprazol-20mg-30caps-ultra.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/omeprazol-20mg-30caps-ultra.jpg'
where sku = 'FC-16792760' and codigo_barras = '7502216792760'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/omeprazol-20mg-30caps-ultra%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/omeprazol-20mg-30caps-ultra.jpg',
  'catalogo-propia/omeprazol-20mg-30caps-ultra.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-16792760'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/omeprazol-20mg-30caps-ultra%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/omeprazol-20mg-30caps-ultra%')
where i.producto_id = (select id from public.productos where sku = 'FC-16792760' limit 1);


-- FC-16804708 | 7502216804708 | Irbesartán 150 mg frasco 28 tabletas LGEN · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006755/7502216804708_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006755/7502216804708_01.jpg'
where sku = 'FC-16804708' and codigo_barras = '7502216804708'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7502216804708%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7006755/7502216804708_01.jpg',
  'distribuidor/irbesartan-150mg-28tab-avivia.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-16804708'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7502216804708%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7502216804708%')
where i.producto_id = (select id from public.productos where sku = 'FC-16804708' limit 1);


-- FC-24028827 | 7891024028827 | ENJ BUC COLGATE TOTAL12 CLEAN 60ML · farmatodo (copia propia)
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/colgate-total12-enjuague-60ml.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/colgate-total12-enjuague-60ml.jpg'
where sku = 'FC-24028827' and codigo_barras = '7891024028827'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/colgate-total12-enjuague-60ml%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/colgate-total12-enjuague-60ml.jpg',
  'catalogo-propia/colgate-total12-enjuague-60ml.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-24028827'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/colgate-total12-enjuague-60ml%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/colgate-total12-enjuague-60ml%')
where i.producto_id = (select id from public.productos where sku = 'FC-24028827' limit 1);


-- FC-25195105 | 7501125195105 | Cefuroxima 750 mg FA + ampolleta 5 ml · farmatodo (copia propia)
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/cefuroxima-750mg-amp-amsa.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/cefuroxima-750mg-amp-amsa.jpg'
where sku = 'FC-25195105' and codigo_barras = '7501125195105'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/cefuroxima-750mg-amp-amsa%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/cefuroxima-750mg-amp-amsa.jpg',
  'catalogo-propia/cefuroxima-750mg-amp-amsa.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-25195105'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/cefuroxima-750mg-amp-amsa%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/cefuroxima-750mg-amp-amsa%')
where i.producto_id = (select id from public.productos where sku = 'FC-25195105' limit 1);


-- FC-35911024 | 7501035911024 | C D COLGATE MFP 125ML · farmatodo (copia propia)
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/colgate-mfp-familiar-125ml.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/colgate-mfp-familiar-125ml.jpg'
where sku = 'FC-35911024' and codigo_barras = '7501035911024'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/colgate-mfp-familiar-125ml%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/colgate-mfp-familiar-125ml.jpg',
  'catalogo-propia/colgate-mfp-familiar-125ml.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-35911024'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/colgate-mfp-familiar-125ml%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/colgate-mfp-familiar-125ml%')
where i.producto_id = (select id from public.productos where sku = 'FC-35911024' limit 1);


-- FC-41751594 | 7501417515949 | Bocasan Premium enjuague bucal polvo menta 24 sobres 1.75 g · catalogo-propia
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/bocasan-premium-24-sobres.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/bocasan-premium-24-sobres.jpg'
where sku = 'FC-41751594' and codigo_barras = '7501417515949'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/bocasan-premium-24-sobres%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/bocasan-premium-24-sobres.jpg',
  'catalogo-propia/bocasan-premium-24-sobres.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-41751594'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/bocasan-premium-24-sobres%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/bocasan-premium-24-sobres%')
where i.producto_id = (select id from public.productos where sku = 'FC-41751594' limit 1);


-- FC-46029139 | 7509546029139 | DESOD SPEED S 24/7COOL-NIG STIK 85G · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6997353/7509546029139_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6997353/7509546029139_01.jpg'
where sku = 'FC-46029139' and codigo_barras = '7509546029139'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7509546029139%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6997353/7509546029139_01.jpg',
  'distribuidor/speed-stick-cool-night-85g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-46029139'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7509546029139%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7509546029139%')
where i.producto_id = (select id from public.productos where sku = 'FC-46029139' limit 1);


-- FC-46674018 | 7509546674018 | C D COLGATE LUMIN WHIT CARBON 66ML · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7009212/7509546674018_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7009212/7509546674018_01.jpg'
where sku = 'FC-46674018' and codigo_barras = '7509546674018'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7509546674018%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7009212/7509546674018_01.jpg',
  'distribuidor/colgate-luminous-white-carbon-66ml.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-46674018'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7509546674018%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7509546674018%')
where i.producto_id = (select id from public.productos where sku = 'FC-46674018' limit 1);


-- FC-49022768 | 7501349022768 | Cefalotina 1 g solución inyectable FA 5 ml LGEN · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006368/7501349022768_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006368/7501349022768_01.jpg'
where sku = 'FC-49022768' and codigo_barras = '7501349022768'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501349022768%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7006368/7501349022768_01.jpg',
  'distribuidor/cefalotina-1g-im-amsa.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-49022768'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501349022768%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501349022768%')
where i.producto_id = (select id from public.productos where sku = 'FC-49022768' limit 1);


-- FC-65011649 | 7501165011649 | Buscapina 10 mg 24 grageas · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005636/7501165011649_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005636/7501165011649_01.jpg'
where sku = 'FC-65011649' and codigo_barras = '7501165011649'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501165011649%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7005636/7501165011649_01.jpg',
  'distribuidor/buscapina-10mg-24tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-65011649'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501165011649%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501165011649%')
where i.producto_id = (select id from public.productos where sku = 'FC-65011649' limit 1);


-- FC-65628121 | 7501065628121 | POMADA DE LA CAMPANA 19 g · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7007910/7501065628121_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7007910/7501065628121_01.jpg'
where sku = 'FC-65628121' and codigo_barras = '7501065628121'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501065628121%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7007910/7501065628121_01.jpg',
  'distribuidor/pomada-la-campana-19g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-65628121'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501065628121%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501065628121%')
where i.producto_id = (select id from public.productos where sku = 'FC-65628121' limit 1);


-- FC-65628145 | 7501065628145 | POMADA DE LA CAMPANA · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6998918/7501065628145_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6998918/7501065628145_01.jpg'
where sku = 'FC-65628145' and codigo_barras = '7501065628145'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501065628145%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6998918/7501065628145_01.jpg',
  'distribuidor/pomada-la-campana-35g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-65628145'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501065628145%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501065628145%')
where i.producto_id = (select id from public.productos where sku = 'FC-65628145' limit 1);


-- FC-68541491 | 7502268541491 | Electrolife Zero uva 625 ml · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7010029/7502268541491_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7010029/7502268541491_01.jpg'
where sku = 'FC-68541491' and codigo_barras = '7502268541491'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7502268541491%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7010029/7502268541491_01.jpg',
  'distribuidor/electrolife-zero-uva-625ml.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-68541491'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7502268541491%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7502268541491%')
where i.producto_id = (select id from public.productos where sku = 'FC-68541491' limit 1);


-- FC-78924338 | 78924338 | DESOD REXONA WOM POW R-ON 53G · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6997300/78924338_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6997300/78924338_01.jpg'
where sku = 'FC-78924338' and codigo_barras = '78924338'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%78924338%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6997300/78924338_01.jpg',
  'distribuidor/rexona-woman-powder-rollon.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-78924338'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%78924338%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%78924338%')
where i.producto_id = (select id from public.productos where sku = 'FC-78924338' limit 1);


-- FC-B25B4654 | sin-ean | Cina (Ciprofloxacino) · catalogo-propia
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/cina-levofloxacino-750mg-7tab.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/cina-levofloxacino-750mg-7tab.jpg'
where sku = 'FC-B25B4654'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/cina-levofloxacino-750mg-7tab%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/cina-levofloxacino-750mg-7tab.jpg',
  'catalogo-propia/cina-levofloxacino-750mg-7tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-B25B4654'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/cina-levofloxacino-750mg-7tab%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/cina-levofloxacino-750mg-7tab%')
where i.producto_id = (select id from public.productos where sku = 'FC-B25B4654' limit 1);


-- EQ-AMS349 | 7501349021808 | Cefotaxima IM 500 mg/2 ml · levic
update public.productos
set imagen_url = 'https://visoti.mx/imagenes/Grande/AMS349.webp',
    imagen_mobile_url = 'https://visoti.mx/imagenes/Grande/AMS349.webp'
where sku = 'EQ-AMS349' and codigo_barras = '7501349021808'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%eq-ams349%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://visoti.mx/imagenes/Grande/AMS349.webp',
  'distribuidor/eq-ams349.webp',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'EQ-AMS349'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%eq-ams349%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%eq-ams349%')
where i.producto_id = (select id from public.productos where sku = 'EQ-AMS349' limit 1);


-- EQ-SON083 | 7502001161627 | Lisonin 1 amp 600 mg/2 ml · levic
update public.productos
set imagen_url = 'https://visoti.mx/imagenes/Grande/SON083.webp',
    imagen_mobile_url = 'https://visoti.mx/imagenes/Grande/SON083.webp'
where sku = 'EQ-SON083' and codigo_barras = '7502001161627'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%eq-son083%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://visoti.mx/imagenes/Grande/SON083.webp',
  'distribuidor/eq-son083.webp',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'EQ-SON083'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%eq-son083%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%eq-son083%')
where i.producto_id = (select id from public.productos where sku = 'EQ-SON083' limit 1);


-- EQ-VAL129 | 7501122961901 | Eldoquin crema 4% 30 g · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7002313/7501122961901_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7002313/7501122961901_01.jpg'
where sku = 'EQ-VAL129' and codigo_barras = '7501122961901'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501122961901%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7002313/7501122961901_01.jpg',
  'distribuidor/eldoquin-crema-4-30-g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'EQ-VAL129'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501122961901%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501122961901%')
where i.producto_id = (select id from public.productos where sku = 'EQ-VAL129' limit 1);


-- FC-00450210 | 7501300450210 | Bactrim F 800/160 mg 15 tabletas · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7008711/7501300450210_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7008711/7501300450210_01.jpg'
where sku = 'FC-00450210' and codigo_barras = '7501300450210'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501300450210%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7008711/7501300450210_01.jpg',
  'distribuidor/bactrim-f-800-160-mg-15-tabletas.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-00450210'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501300450210%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501300450210%')
where i.producto_id = (select id from public.productos where sku = 'FC-00450210' limit 1);


-- FC-00450227 | 7501300450227 | Bactrim 200/40 mg suspensión 100 ml · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7009810/7501300450227_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7009810/7501300450227_01.jpg'
where sku = 'FC-00450227' and codigo_barras = '7501300450227'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501300450227%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7009810/7501300450227_01.jpg',
  'distribuidor/bactrim-200-40-mg-suspension-100-ml.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-00450227'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501300450227%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501300450227%')
where i.producto_id = (select id from public.productos where sku = 'FC-00450227' limit 1);


-- FC-00631702 | 4005800631702 | Eucerin pH5 pomada labial · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7251341/4005800631702_02.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7251341/4005800631702_02.jpg'
where sku = 'FC-00631702' and codigo_barras = '4005800631702'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%4005800631702%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7251341/4005800631702_02.jpg',
  'distribuidor/eucerin-ph5-pomada-labial.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-00631702'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%4005800631702%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%4005800631702%')
where i.producto_id = (select id from public.productos where sku = 'FC-00631702' limit 1);


-- FC-00948670 | 4005900948670 | Labello Caring Beauty Red 4.8 g · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7093326/4005900948670_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7093326/4005900948670_01.jpg'
where sku = 'FC-00948670' and codigo_barras = '4005900948670'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%4005900948670%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7093326/4005900948670_01.jpg',
  'distribuidor/labello-caring-beauty-red-4-8-g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-00948670'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%4005900948670%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%4005900948670%')
where i.producto_id = (select id from public.productos where sku = 'FC-00948670' limit 1);


-- FC-05809248 | 7506205809248 | Enfagrow Premium etapa 3 lata 800 g · catalogo-propia
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


-- FC-07532363 | 7501007532363 | DRAMAMINE · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005254/7501007532363_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005254/7501007532363_01.jpg'
where sku = 'FC-07532363' and codigo_barras = '7501007532363'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501007532363%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7005254/7501007532363_01.jpg',
  'distribuidor/dramamine-50mg-24tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-07532363'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501007532363%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501007532363%')
where i.producto_id = (select id from public.productos where sku = 'FC-07532363' limit 1);


-- FC-08498866 | 7501008498866 | Flanax 550 mg 6 tabletas · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005759/7501008498866_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005759/7501008498866_01.jpg'
where sku = 'FC-08498866' and codigo_barras = '7501008498866'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501008498866%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7005759/7501008498866_01.jpg',
  'distribuidor/flanax-550mg-6tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-08498866'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501008498866%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501008498866%')
where i.producto_id = (select id from public.productos where sku = 'FC-08498866' limit 1);


-- FC-08499092 | 7501008499092 | Flanax Nocto 220/25 mg 20 comprimidos · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7008801/7501008499092_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7008801/7501008499092_01.jpg'
where sku = 'FC-08499092' and codigo_barras = '7501008499092'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501008499092%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7008801/7501008499092_01.jpg',
  'distribuidor/flanax-nocto-20comp.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-08499092'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501008499092%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501008499092%')
where i.producto_id = (select id from public.productos where sku = 'FC-08499092' limit 1);


-- FC-08499412 | 7501008499412 | Flanax 660 mg 8 tabletas · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7010589/7501008499412_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7010589/7501008499412_01.jpg'
where sku = 'FC-08499412' and codigo_barras = '7501008499412'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501008499412%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7010589/7501008499412_01.jpg',
  'distribuidor/flanax-660mg-8tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-08499412'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501008499412%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501008499412%')
where i.producto_id = (select id from public.productos where sku = 'FC-08499412' limit 1);


-- FC-18001071 | 7702018001071 | GILLETTTE  MACH 3 · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996586/7702018001071_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996586/7702018001071_01.jpg'
where sku = 'FC-18001071' and codigo_barras = '7702018001071'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7702018001071%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996586/7702018001071_01.jpg',
  'distribuidor/gillette-mach3.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-18001071'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7702018001071%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7702018001071%')
where i.producto_id = (select id from public.productos where sku = 'FC-18001071' limit 1);


-- FC-18874729 | 7702018874729 | GILLETTE PRESTOBARBA 3 · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996595/7702018874729_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996595/7702018874729_01.jpg'
where sku = 'FC-18874729' and codigo_barras = '7702018874729'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7702018874729%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996595/7702018874729_01.jpg',
  'distribuidor/gillette-prestobarba3-hombre.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-18874729'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7702018874729%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7702018874729%')
where i.producto_id = (select id from public.productos where sku = 'FC-18874729' limit 1);


-- FC-18874781 | 7702018874781 | GILLETTE PRESTOBARBA 3 · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996596/7702018874781_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996596/7702018874781_01.jpg'
where sku = 'FC-18874781' and codigo_barras = '7702018874781'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7702018874781%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996596/7702018874781_01.jpg',
  'distribuidor/gillette-prestobarba3-mujer.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-18874781'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7702018874781%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7702018874781%')
where i.producto_id = (select id from public.productos where sku = 'FC-18874781' limit 1);


-- FC-19006104 | 7501019006104 | SABA INTIMA REGULAR 10 TOALLAS · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996377/7501019006104_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996377/7501019006104_01.jpg'
where sku = 'FC-19006104' and codigo_barras = '7501019006104'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501019006104%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996377/7501019006104_01.jpg',
  'distribuidor/saba-intima-regular-10.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-19006104'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501019006104%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501019006104%')
where i.producto_id = (select id from public.productos where sku = 'FC-19006104' limit 1);


-- FC-19006296 | 7501019006296 | SABA ULTRA INVISLE 10 TOALLAS · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996325/7501019006296_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996325/7501019006296_01.jpg'
where sku = 'FC-19006296' and codigo_barras = '7501019006296'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501019006296%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996325/7501019006296_01.jpg',
  'distribuidor/saba-ultra-invisible-10.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-19006296'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501019006296%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501019006296%')
where i.producto_id = (select id from public.productos where sku = 'FC-19006296' limit 1);


-- FC-19006418 | 7501019006418 | SABA INVISIBLE DELGADA 14 TOALLAS 0429 · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996380/7501019006418_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996380/7501019006418_01.jpg'
where sku = 'FC-19006418' and codigo_barras = '7501019006418'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501019006418%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996380/7501019006418_01.jpg',
  'distribuidor/saba-invisible-delgada-14.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-19006418'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501019006418%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501019006418%')
where i.producto_id = (select id from public.productos where sku = 'FC-19006418' limit 1);


-- FC-19006692 | 7501019006692 | SABA BUENAS NOCHES 24 TOALLAS NOCTURNA · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996348/7501019006692_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996348/7501019006692_01.jpg'
where sku = 'FC-19006692' and codigo_barras = '7501019006692'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501019006692%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996348/7501019006692_01.jpg',
  'distribuidor/saba-buenas-noches-24.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-19006692'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501019006692%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501019006692%')
where i.producto_id = (select id from public.productos where sku = 'FC-19006692' limit 1);


-- FC-19031144 | 7501019031144 | SABA REGULAR AMORE 8 TOALLAS · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996387/7501019031144_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996387/7501019031144_01.jpg'
where sku = 'FC-19031144' and codigo_barras = '7501019031144'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501019031144%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996387/7501019031144_01.jpg',
  'distribuidor/saba-regular-amore-8.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-19031144'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501019031144%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501019031144%')
where i.producto_id = (select id from public.productos where sku = 'FC-19031144' limit 1);


-- FC-19032424 | 7501019032424 | Tampones Saba compactos super · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996318/7501019032424_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996318/7501019032424_01.jpg'
where sku = 'FC-19032424' and codigo_barras = '7501019032424'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501019032424%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996318/7501019032424_01.jpg',
  'distribuidor/saba-tampones-compactos.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-19032424'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501019032424%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501019032424%')
where i.producto_id = (select id from public.productos where sku = 'FC-19032424' limit 1);


-- FC-19050473 | 7501019050473 | Toalla húmeda Tena adulto EG · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996396/7501019050473_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996396/7501019050473_01.jpg'
where sku = 'FC-19050473' and codigo_barras = '7501019050473'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501019050473%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996396/7501019050473_01.jpg',
  'distribuidor/tena-toallas-humedas-40.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-19050473'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501019050473%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501019050473%')
where i.producto_id = (select id from public.productos where sku = 'FC-19050473' limit 1);


-- FC-21440013 | 7502321440013 | Buscapina Duo 10/500 mg 10 tabletas · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7013247/7502321440013_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7013247/7502321440013_01.jpg'
where sku = 'FC-21440013' and codigo_barras = '7502321440013'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7502321440013%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7013247/7502321440013_01.jpg',
  'distribuidor/buscapina-duo-10tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-21440013'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7502321440013%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7502321440013%')
where i.producto_id = (select id from public.productos where sku = 'FC-21440013' limit 1);


-- FC-24183182 | 7891024183182 | HILO DENT COLGATE ENCERA 25M · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996867/7891024183182_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996867/7891024183182_01.jpg'
where sku = 'FC-24183182' and codigo_barras = '7891024183182'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7891024183182%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996867/7891024183182_01.jpg',
  'distribuidor/colgate-hilo-dental-25m.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-24183182'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7891024183182%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7891024183182%')
where i.producto_id = (select id from public.productos where sku = 'FC-24183182' limit 1);


-- FC-25108709 | 3614225108709 | KOLESTON NEGRO 20 · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996890/3614225108709_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996890/3614225108709_01.jpg'
where sku = 'FC-25108709' and codigo_barras = '3614225108709'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%3614225108709%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996890/3614225108709_01.jpg',
  'distribuidor/koleston-negro-20.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-25108709'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%3614225108709%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%3614225108709%')
where i.producto_id = (select id from public.productos where sku = 'FC-25108709' limit 1);


-- FC-27286000 | 7501027286000 | DESOD OBAO OCEAN R-ON 65G · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6997336/7501027286000_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6997336/7501027286000_01.jpg'
where sku = 'FC-27286000' and codigo_barras = '7501027286000'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501027286000%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6997336/7501027286000_01.jpg',
  'distribuidor/obao-ocean-rollon-65g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-27286000'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501027286000%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501027286000%')
where i.producto_id = (select id from public.productos where sku = 'FC-27286000' limit 1);


-- FC-35129367 | 7500435129367 | DESOD SECRET PH-BALAN STICK GEL 45G · openfoodfacts
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/secret-ph-balanced-lavender-45g.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/secret-ph-balanced-lavender-45g.jpg'
where sku = 'FC-35129367' and codigo_barras = '7500435129367'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/secret-ph-balanced-lavender-45g%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/secret-ph-balanced-lavender-45g.jpg',
  'catalogo-propia/secret-ph-balanced-lavender-45g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-35129367'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/secret-ph-balanced-lavender-45g%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/secret-ph-balanced-lavender-45g%')
where i.producto_id = (select id from public.productos where sku = 'FC-35129367' limit 1);


-- FC-42302463 | 070942302463 | CEP DENT GUM GO-BET MICROFINO C/6 · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996680/070942302463_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996680/070942302463_01.jpg'
where sku = 'FC-42302463' and codigo_barras = '070942302463'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%070942302463%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996680/070942302463_01.jpg',
  'distribuidor/gum-gobet-microfino.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-42302463'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%070942302463%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%070942302463%')
where i.producto_id = (select id from public.productos where sku = 'FC-42302463' limit 1);


-- FC-42303460 | 070942303460 | CEP DENT GUM TRAV-LER INTERDENTA 0.8 · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7007976/0070942303460_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7007976/0070942303460_01.jpg'
where sku = 'FC-42303460' and codigo_barras = '070942303460'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%070942303460%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7007976/0070942303460_01.jpg',
  'distribuidor/gum-trav-ler-0-8mm.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-42303460'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%070942303460%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%070942303460%')
where i.producto_id = (select id from public.productos where sku = 'FC-42303460' limit 1);


-- FC-46057545 | 7509546057545 | DESOD LADYSS PRO 5EN1 STICK 45G ABRIL27 · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6997357/7509546057545_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6997357/7509546057545_01.jpg'
where sku = 'FC-46057545' and codigo_barras = '7509546057545'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7509546057545%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6997357/7509546057545_01.jpg',
  'distribuidor/lady-speed-stick-pro5-45g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-46057545'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7509546057545%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7509546057545%')
where i.producto_id = (select id from public.productos where sku = 'FC-46057545' limit 1);


-- FC-46073774 | 7509546073774 | DESOD STEFANO SPAZ SPY 113G · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/5133231/7509546073774_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/5133231/7509546073774_01.jpg'
where sku = 'FC-46073774' and codigo_barras = '7509546073774'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7509546073774%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/5133231/7509546073774_01.jpg',
  'distribuidor/stefano-spazio-spray-113g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-46073774'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7509546073774%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7509546073774%')
where i.producto_id = (select id from public.productos where sku = 'FC-46073774' limit 1);


-- FC-49013223 | 7501349013223 | Deflazacort 30 mg 10 tabletas LGEN · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7007529/7501349013223_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7007529/7501349013223_01.jpg'
where sku = 'FC-49013223' and codigo_barras = '7501349013223'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501349013223%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7007529/7501349013223_01.jpg',
  'distribuidor/deflazacort-30mg-10tab-amsa.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-49013223'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501349013223%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501349013223%')
where i.producto_id = (select id from public.productos where sku = 'FC-49013223' limit 1);


-- FC-49026377 | 7501349026377 | Gentamicina 160 mg solución inyectable 2 ml AMSA · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006395/7501349026377_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006395/7501349026377_01.jpg'
where sku = 'FC-49026377' and codigo_barras = '7501349026377'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501349026377%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7006395/7501349026377_01.jpg',
  'distribuidor/gentamicina-160mg-amp-amsa.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-49026377'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501349026377%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501349026377%')
where i.producto_id = (select id from public.productos where sku = 'FC-49026377' limit 1);


-- FC-49028234 | 7501349028234 | Omeprazol 40 mg solución inyectable ampolleta LGEN · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006849/7501349028234_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006849/7501349028234_01.jpg'
where sku = 'FC-49028234' and codigo_barras = '7501349028234'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501349028234%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7006849/7501349028234_01.jpg',
  'distribuidor/omeprazol-40mg-iny-amsa.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-49028234'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501349028234%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501349028234%')
where i.producto_id = (select id from public.productos where sku = 'FC-49028234' limit 1);


-- FC-49029613 | 7501349029613 | Combedi DX Complejo B / Dexametasona 6 amp AMSA · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7007039/7501349029613_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7007039/7501349029613_01.jpg'
where sku = 'FC-49029613' and codigo_barras = '7501349029613'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501349029613%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7007039/7501349029613_01.jpg',
  'distribuidor/combedi-dx-amsa.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-49029613'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501349029613%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501349029613%')
where i.producto_id = (select id from public.productos where sku = 'FC-49029613' limit 1);


-- FC-50342570 | 7502250342570 | VITACILINA SERUM VITAMINA C · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7013593/7502250342570_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7013593/7502250342570_01.jpg'
where sku = 'FC-50342570' and codigo_barras = '7502250342570'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7502250342570%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7013593/7502250342570_01.jpg',
  'distribuidor/vitacilina-serum-vitc-30ml.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-50342570'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7502250342570%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7502250342570%')
where i.producto_id = (select id from public.productos where sku = 'FC-50342570' limit 1);


-- FC-52906158 | 7509552906158 | DESOD OBAO FRESQUISSIMA R-ON 65G · openfoodfacts
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/obao-fresquissima-rollon-65g.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/obao-fresquissima-rollon-65g.jpg'
where sku = 'FC-52906158' and codigo_barras = '7509552906158'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/obao-fresquissima-rollon-65g%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/obao-fresquissima-rollon-65g.jpg',
  'catalogo-propia/obao-fresquissima-rollon-65g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'propia'
from public.productos p where p.sku = 'FC-52906158'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/obao-fresquissima-rollon-65g%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/obao-fresquissima-rollon-65g%')
where i.producto_id = (select id from public.productos where sku = 'FC-52906158' limit 1);


-- FC-54503637 | 7501054503637 | Labello Med Protection 4.8 g · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996612/7501054503637_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996612/7501054503637_01.jpg'
where sku = 'FC-54503637' and codigo_barras = '7501054503637'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501054503637%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996612/7501054503637_01.jpg',
  'distribuidor/labello-med-protection-4-8g.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-54503637'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501054503637%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501054503637%')
where i.producto_id = (select id from public.productos where sku = 'FC-54503637' limit 1);


-- FC-56729917 | 7502256729917 | Oxímetro Inhala Care pulso dedo FS10E · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7008724/7502256729917_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7008724/7502256729917_01.jpg'
where sku = 'FC-56729917' and codigo_barras = '7502256729917'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7502256729917%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7008724/7502256729917_01.jpg',
  'distribuidor/oximetro-inhala-care-fs10e.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-56729917'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7502256729917%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7502256729917%')
where i.producto_id = (select id from public.productos where sku = 'FC-56729917' limit 1);


-- FC-58715913 | 7501058715913 | Picot Plus 9 sobres efervescentes · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005153/7501058715913_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7005153/7501058715913_01.jpg'
where sku = 'FC-58715913' and codigo_barras = '7501058715913'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501058715913%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7005153/7501058715913_01.jpg',
  'distribuidor/picot-plus-9-sobres.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-58715913'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501058715913%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501058715913%')
where i.producto_id = (select id from public.productos where sku = 'FC-58715913' limit 1);


-- FC-70600709 | 7501070600709 | Syncol 500/25/15 mg 12 comprimidos · catalogo-propia
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


-- FC-75784054 | 3337875784054 | CeraVe gel limpiador contra imperfecciones 236 ml · catalogo-propia
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


-- FC-82790481 | 7501082790481 | TAS DESMAQ NUVEL HIDRATANTES C25 · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7010638/7501082790481_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7010638/7501082790481_01.jpg'
where sku = 'FC-82790481' and codigo_barras = '7501082790481'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501082790481%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7010638/7501082790481_01.jpg',
  'distribuidor/nuvel-toallitas-hidratantes-25.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-82790481'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501082790481%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501082790481%')
where i.producto_id = (select id from public.productos where sku = 'FC-82790481' limit 1);


-- FC-93888302 | 7501493888302 | Doxiciclina 100 mg 10 cápsulas Ken LGEN · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006411/7501493888302_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006411/7501493888302_01.jpg'
where sku = 'FC-93888302' and codigo_barras = '7501493888302'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501493888302%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7006411/7501493888302_01.jpg',
  'distribuidor/kenciclen-doxiciclina-100mg-10caps.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-93888302'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501493888302%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501493888302%')
where i.producto_id = (select id from public.productos where sku = 'FC-93888302' limit 1);


-- FC-16792555 | 7502216792555 | Omeprazol 20 mg 14 cápsulas LGEN · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006866/7502216792555_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7006866/7502216792555_01.jpg'
where sku = 'FC-16792555' and codigo_barras = '7502216792555'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7502216792555%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7006866/7502216792555_01.jpg',
  'distribuidor/omeprazol-20mg-14caps-ultra.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-16792555'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7502216792555%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7502216792555%')
where i.producto_id = (select id from public.productos where sku = 'FC-16792555' limit 1);


-- FC-16798878 | 7502216798878 | Pioglitazona 30 mg 7 tabletas LGEN · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7007361/7502216798878_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/7007361/7502216798878_01.jpg'
where sku = 'FC-16798878' and codigo_barras = '7502216798878'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7502216798878%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/7007361/7502216798878_01.jpg',
  'distribuidor/pioglitazona-30mg-7tab-ultra.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-16798878'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7502216798878%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7502216798878%')
where i.producto_id = (select id from public.productos where sku = 'FC-16798878' limit 1);


-- FC-19068911 | 7501019068911 | Panty protector Saba largo 28 · farmatodo
update public.productos
set imagen_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996302/7501019068911_01.jpg',
    imagen_mobile_url = 'https://gruporfp.vteximg.com.br/arquivos/ids/6996302/7501019068911_01.jpg'
where sku = 'FC-19068911' and codigo_barras = '7501019068911'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%7501019068911%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://gruporfp.vteximg.com.br/arquivos/ids/6996302/7501019068911_01.jpg',
  'distribuidor/saba-pantiprotector-largo-28.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true, 'distribuidor'
from public.productos p where p.sku = 'FC-19068911'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%7501019068911%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%7501019068911%')
where i.producto_id = (select id from public.productos where sku = 'FC-19068911' limit 1);


select sku, codigo_barras, left(nombre, 48) as nombre, left(imagen_url, 90) as foto
from public.productos
where sku in ('FC-68900264', 'FC-LV-ORBITHB40', 'FC-LV-CLORETS40', 'FC-LV-ORBITFRE40', '7622210267832', 'FC-01246730', 'FC-40013805', 'FC-54354677', 'EQ-AMS318', 'FC-7D1D9857', 'FC-40007651', 'EQ-BIO002', 'FC-070839', 'FC-12225133', 'FC-40053634', 'FC-46029825', 'FC-58651129', 'FC-75005092', 'FC-75073107', 'FC-75102421', 'FC-75102452', 'EQ-BEA367', 'EQ-INN022', 'EQ-MAV102', 'EQ-MAV204', 'EQ-SON084', 'FC-09740442', 'FC-12225140', 'FC-16792760', 'FC-16804708', 'FC-24028827', 'FC-25195105', 'FC-35911024', 'FC-41751594', 'FC-46029139', 'FC-46674018', 'FC-49022768', 'FC-65011649', 'FC-65628121', 'FC-65628145', 'FC-68541491', 'FC-78924338', 'FC-B25B4654', 'EQ-AMS349', 'EQ-SON083', 'EQ-VAL129', 'FC-00450210', 'FC-00450227', 'FC-00631702', 'FC-00948670', 'FC-05809248', 'FC-07532363', 'FC-08498866', 'FC-08499092', 'FC-08499412', 'FC-18001071', 'FC-18874729', 'FC-18874781', 'FC-19006104', 'FC-19006296', 'FC-19006418', 'FC-19006692', 'FC-19031144', 'FC-19032424', 'FC-19050473', 'FC-21440013', 'FC-24183182', 'FC-25108709', 'FC-27286000', 'FC-35129367', 'FC-42302463', 'FC-42303460', 'FC-46057545', 'FC-46073774', 'FC-49013223', 'FC-49026377', 'FC-49028234', 'FC-49029613', 'FC-50342570', 'FC-52906158', 'FC-54503637', 'FC-56729917', 'FC-58715913', 'FC-70600709', 'FC-75784054', 'FC-82790481', 'FC-93888302', 'FC-16792555', 'FC-16798878', 'FC-19068911')
order by sku;

commit;
