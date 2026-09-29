-- Farmalive 12127 · B1 costos · despues de las B1-XX altas
-- Actualiza costo (y PVP solo si estaba en 0) desde el staging.
-- Requiere public._fc_fl_12127_staging (A1+A2).

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from (
  select distinct on (ean) ean, costo, precio, marca, presentacion, imagen
  from public._fc_fl_12127_staging
  order by ean, linea
) t
where p.codigo_barras = t.ean;

select count(*) as productos_con_costo_ticket
from public.productos p
join (
  select distinct ean from public._fc_fl_12127_staging
) t on p.codigo_barras = t.ean;
