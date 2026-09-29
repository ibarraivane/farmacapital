-- Farmalive 12127 · PARTE B3 · galeria + limpiar staging (despues de B2)
-- Una fila por EAN (Sico viene 2 veces en el ticket; no duplicar foto).
-- es_principal=false al insertar (evita ux_producto_imagenes_una_principal).

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
  select distinct on (ean) *
  from public._fc_fl_12127_staging
  order by ean, linea
) t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

-- Si el producto no tenia principal, marca la nueva.
update public.producto_imagenes i
set es_principal = true
from public.productos p
join (
  select distinct on (ean) ean, imagen, foto_file, sku
  from public._fc_fl_12127_staging
  order by ean, linea
) t on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where i.producto_id = p.id
  and t.imagen is not null
  and (i.url = t.imagen or i.storage_path = t.foto_file)
  and not exists (
    select 1 from public.producto_imagenes x
    where x.producto_id = p.id and coalesce(x.es_principal, false)
  );

-- Diagnostico match
select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  case
    when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA'
    else 'OK'
  end as match
from public._fc_fl_12127_staging t
order by t.linea;

drop table if exists public._fc_fl_12127_staging;
