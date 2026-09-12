-- Parte 3/3 del backfill marca + principio_activo
-- Pegar TODO en Supabase → SQL Editor → Run
-- Luego corre la parte siguiente.

begin;

-- ===== C) Patrón Marca (PA) en vivo =====
update public.productos p
set
  marca = coalesce(
    nullif(btrim(p.marca), ''),
    nullif(btrim((regexp_match(p.nombre, '^([A-Za-zÁÉÍÓÚÑáéíóúñ][A-Za-zÁÉÍÓÚÑáéíóúñ0-9\-]{2,})\s*\('))[1]), '')
  ),
  denominacion_distintiva = coalesce(
    nullif(btrim(p.denominacion_distintiva), ''),
    nullif(btrim((regexp_match(p.nombre, '^([A-Za-zÁÉÍÓÚÑáéíóúñ][A-Za-zÁÉÍÓÚÑáéíóúñ0-9\-]{2,})\s*\('))[1]), '')
  ),
  principio_activo = coalesce(
    nullif(btrim(p.principio_activo), ''),
    nullif(btrim((regexp_match(p.nombre, '\(([^\)]+)\)'))[1]), '')
  ),
  denominacion_generica = coalesce(
    nullif(btrim(p.denominacion_generica), ''),
    nullif(btrim((regexp_match(p.nombre, '\(([^\)]+)\)'))[1]), '')
  )
where p.nombre ~ '^[A-Za-zÁÉÍÓÚÑáéíóúñ][A-Za-zÁÉÍÓÚÑáéíóúñ0-9\-]{2,}\s*\([^\)]+\)'
  and (
    p.marca is null or btrim(p.marca) = ''
    or p.principio_activo is null or btrim(p.principio_activo) = ''
  )
  -- no usar la molécula como marca
  and lower((regexp_match(p.nombre, '^([A-Za-zÁÉÍÓÚÑáéíóúñ][A-Za-zÁÉÍÓÚÑáéíóúñ0-9\-]{2,})\s*\('))[1])
      !~ '(cilina|micina|statina|prazol|dipino|sartan|pril|xetina|zolam|mab|nib|cyclina|floxacino|dronato)$';

commit;

commit;

-- ===== Diagnóstico post-corrida =====
select
  count(*) as total,
  count(*) filter (where marca is not null and btrim(marca) <> '') as con_marca,
  count(*) filter (where principio_activo is not null and btrim(principio_activo) <> '') as con_pa,
  count(*) filter (where (marca is null or btrim(marca) = '')
                    and (principio_activo is null or btrim(principio_activo) = '')) as sin_ambos
from public.productos
where coalesce(activo, true);

select sku, codigo_barras as ean, left(nombre, 60) as nombre, marca, principio_activo
from public.productos
where coalesce(activo, true)
  and (marca is null or btrim(marca) = '')
  and (principio_activo is null or btrim(principio_activo) = '')
order by nombre
limit 50;
