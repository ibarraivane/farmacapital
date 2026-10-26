-- Fotos catalogo-propia · Nadro 6091017798 · corrida DESPUÉS del deploy de Vercel.
-- Packshots desde iNadro (no placeholder genérico).
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/gelubrin-ibuprofeno-400mg-c10-7503008344785.jpg',
    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/gelubrin-ibuprofeno-400mg-c10-7503008344785.jpg')
where (codigo_barras = '7503008344785' or sku in ('EQ-PGE033')
       or (codigo_barras = substr('7503008344785', 2) and '7503008344785' like '0%' and length('7503008344785') = 13))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/gelubrin-ibuprofeno-400mg-c1%'
  );

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/gelubrin-ibuprofeno-400mg-c10-7503008344785.jpg',
       'catalogo-propia/gelubrin-ibuprofeno-400mg-c10-7503008344785.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and coalesce(i.es_principal, false)
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7503008344785' or p.sku in ('EQ-PGE033')
       or (p.codigo_barras = substr('7503008344785', 2) and '7503008344785' like '0%' and length('7503008344785') = 13))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = 'https://www.farmacapital.mx/catalogo-propia/gelubrin-ibuprofeno-400mg-c10-7503008344785.jpg' or i.storage_path = 'catalogo-propia/gelubrin-ibuprofeno-400mg-c10-7503008344785.jpg')
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/leukoplast-hypafix-10cmx2m-4042809591446.jpg',
    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/leukoplast-hypafix-10cmx2m-4042809591446.jpg')
where (codigo_barras = '4042809591446' or sku in ('FC-09591446', 'FC-ND-09591446')
       or (codigo_barras = substr('4042809591446', 2) and '4042809591446' like '0%' and length('4042809591446') = 13))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/leukoplast-hypafix-10cmx2m-4%'
  );

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/leukoplast-hypafix-10cmx2m-4042809591446.jpg',
       'catalogo-propia/leukoplast-hypafix-10cmx2m-4042809591446.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and coalesce(i.es_principal, false)
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '4042809591446' or p.sku in ('FC-09591446', 'FC-ND-09591446')
       or (p.codigo_barras = substr('4042809591446', 2) and '4042809591446' like '0%' and length('4042809591446') = 13))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = 'https://www.farmacapital.mx/catalogo-propia/leukoplast-hypafix-10cmx2m-4042809591446.jpg' or i.storage_path = 'catalogo-propia/leukoplast-hypafix-10cmx2m-4042809591446.jpg')
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/crostox-rosuvastatina-10mg-c30-0785120755459.jpg',
    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/crostox-rosuvastatina-10mg-c30-0785120755459.jpg')
where (codigo_barras = '0785120755459' or sku in ('FC-20755459', 'FC-ND-20755459')
       or (codigo_barras = substr('0785120755459', 2) and '0785120755459' like '0%' and length('0785120755459') = 13))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/crostox-rosuvastatina-10mg-c%'
  );

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/crostox-rosuvastatina-10mg-c30-0785120755459.jpg',
       'catalogo-propia/crostox-rosuvastatina-10mg-c30-0785120755459.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and coalesce(i.es_principal, false)
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '0785120755459' or p.sku in ('FC-20755459', 'FC-ND-20755459')
       or (p.codigo_barras = substr('0785120755459', 2) and '0785120755459' like '0%' and length('0785120755459') = 13))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = 'https://www.farmacapital.mx/catalogo-propia/crostox-rosuvastatina-10mg-c30-0785120755459.jpg' or i.storage_path = 'catalogo-propia/crostox-rosuvastatina-10mg-c30-0785120755459.jpg')
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/crostox-rosuvastatina-20mg-c30-0785120755466.jpg',
    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/crostox-rosuvastatina-20mg-c30-0785120755466.jpg')
where (codigo_barras = '0785120755466' or sku in ('EQ-MAI163')
       or (codigo_barras = substr('0785120755466', 2) and '0785120755466' like '0%' and length('0785120755466') = 13))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/crostox-rosuvastatina-20mg-c%'
  );

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/crostox-rosuvastatina-20mg-c30-0785120755466.jpg',
       'catalogo-propia/crostox-rosuvastatina-20mg-c30-0785120755466.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and coalesce(i.es_principal, false)
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '0785120755466' or p.sku in ('EQ-MAI163')
       or (p.codigo_barras = substr('0785120755466', 2) and '0785120755466' like '0%' and length('0785120755466') = 13))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = 'https://www.farmacapital.mx/catalogo-propia/crostox-rosuvastatina-20mg-c30-0785120755466.jpg' or i.storage_path = 'catalogo-propia/crostox-rosuvastatina-20mg-c30-0785120755466.jpg')
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/synalar-s-crema-0.025-20g-7501088505454.jpg',
    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/synalar-s-crema-0.025-20g-7501088505454.jpg')
where (codigo_barras = '7501088505454' or sku in ('FC-88505454', 'FC-ND-88505454')
       or (codigo_barras = substr('7501088505454', 2) and '7501088505454' like '0%' and length('7501088505454') = 13))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/synalar-s-crema-0%'
  );

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/synalar-s-crema-0.025-20g-7501088505454.jpg',
       'catalogo-propia/synalar-s-crema-0.025-20g-7501088505454.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and coalesce(i.es_principal, false)
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501088505454' or p.sku in ('FC-88505454', 'FC-ND-88505454')
       or (p.codigo_barras = substr('7501088505454', 2) and '7501088505454' like '0%' and length('7501088505454') = 13))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = 'https://www.farmacapital.mx/catalogo-propia/synalar-s-crema-0.025-20g-7501088505454.jpg' or i.storage_path = 'catalogo-propia/synalar-s-crema-0.025-20g-7501088505454.jpg')
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/telmisartan-hidro-80-12.5-c28-7501349029736.jpg',
    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/telmisartan-hidro-80-12.5-c28-7501349029736.jpg')
where (codigo_barras = '7501349029736' or sku in ('FC-49029736', 'FC-ND-49029736')
       or (codigo_barras = substr('7501349029736', 2) and '7501349029736' like '0%' and length('7501349029736') = 13))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/telmisartan-hidro-80-12%'
  );

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/telmisartan-hidro-80-12.5-c28-7501349029736.jpg',
       'catalogo-propia/telmisartan-hidro-80-12.5-c28-7501349029736.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and coalesce(i.es_principal, false)
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501349029736' or p.sku in ('FC-49029736', 'FC-ND-49029736')
       or (p.codigo_barras = substr('7501349029736', 2) and '7501349029736' like '0%' and length('7501349029736') = 13))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = 'https://www.farmacapital.mx/catalogo-propia/telmisartan-hidro-80-12.5-c28-7501349029736.jpg' or i.storage_path = 'catalogo-propia/telmisartan-hidro-80-12.5-c28-7501349029736.jpg')
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/telmisartan-40mg-c28-7501349025844.jpg',
    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/telmisartan-40mg-c28-7501349025844.jpg')
where (codigo_barras = '7501349025844' or sku in ('FC-49025844')
       or (codigo_barras = substr('7501349025844', 2) and '7501349025844' like '0%' and length('7501349025844') = 13))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/telmisartan-40mg-c28-7501349%'
  );

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/telmisartan-40mg-c28-7501349025844.jpg',
       'catalogo-propia/telmisartan-40mg-c28-7501349025844.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and coalesce(i.es_principal, false)
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501349025844' or p.sku in ('FC-49025844')
       or (p.codigo_barras = substr('7501349025844', 2) and '7501349025844' like '0%' and length('7501349025844') = 13))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = 'https://www.farmacapital.mx/catalogo-propia/telmisartan-40mg-c28-7501349025844.jpg' or i.storage_path = 'catalogo-propia/telmisartan-40mg-c28-7501349025844.jpg')
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/terramicina-oft-ung-10g-5415062392317.jpg',
    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/terramicina-oft-ung-10g-5415062392317.jpg')
where (codigo_barras = '5415062392317' or sku in ('FC-62392317', 'FC-ND-62392317')
       or (codigo_barras = substr('5415062392317', 2) and '5415062392317' like '0%' and length('5415062392317') = 13))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/terramicina-oft-ung-10g-5415%'
  );

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/terramicina-oft-ung-10g-5415062392317.jpg',
       'catalogo-propia/terramicina-oft-ung-10g-5415062392317.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and coalesce(i.es_principal, false)
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '5415062392317' or p.sku in ('FC-62392317', 'FC-ND-62392317')
       or (p.codigo_barras = substr('5415062392317', 2) and '5415062392317' like '0%' and length('5415062392317') = 13))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = 'https://www.farmacapital.mx/catalogo-propia/terramicina-oft-ung-10g-5415062392317.jpg' or i.storage_path = 'catalogo-propia/terramicina-oft-ung-10g-5415062392317.jpg')
  );

commit;
