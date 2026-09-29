-- Farmalive 12127 · B3 · fotos + limpiar staging (despues de B2)
-- DISTINCT ON ean; es_principal=false (evita ux_producto_imagenes_*).

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  false,
  'propia'
from (
  select distinct on (ean) ean, sku, imagen, foto_file
  from public._fc_fl_12127_staging
  order by ean, linea
) t
join public.productos p
  on p.codigo_barras = t.ean
  or p.sku = t.sku
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

update public.producto_imagenes i
set es_principal = true
from public.productos p
join (
  select distinct on (ean) ean, sku, imagen, foto_file
  from public._fc_fl_12127_staging
  order by ean, linea
) t on p.codigo_barras = t.ean or p.sku = t.sku
where i.producto_id = p.id
  and t.imagen is not null
  and (i.url = t.imagen or i.storage_path = t.foto_file)
  and not exists (
    select 1 from public.producto_imagenes x
    where x.producto_id = p.id and coalesce(x.es_principal, false)
  );

select count(*) as con_foto
from public.productos p
join (
  select distinct ean from public._fc_fl_12127_staging where imagen is not null
) t on p.codigo_barras = t.ean;

drop table if exists public._fc_fl_12127_staging;
