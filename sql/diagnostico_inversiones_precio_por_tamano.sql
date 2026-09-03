-- Diagnóstico: ¿hay más productos donde el tamaño grande sale más barato que el chico?
-- Solo SELECT. No cambia nada. Correr en Supabase y revisar el resultado.
--
-- Criterio: misma forma (o nombre de línea) + marca, con ml/g distintos,
-- y PVP del grande < PVP del chico.

with base as (
  select
    p.id,
    p.sku,
    p.nombre,
    p.marca,
    p.presentacion,
    p.forma_farmaceutica,
    p.precio,
    p.costo,
    case
      when coalesce(p.presentacion, '') ~* '([0-9]+(?:[.,][0-9]+)?)\s*m(?:l|ls)\b'
        then replace((regexp_match(coalesce(p.presentacion, ''), '([0-9]+(?:[.,][0-9]+)?)\s*m(?:l|ls)\b', 'i'))[1], ',', '.')::numeric
      when coalesce(p.nombre, '') ~* '([0-9]+(?:[.,][0-9]+)?)\s*m(?:l|ls)\b'
        then replace((regexp_match(coalesce(p.nombre, ''), '([0-9]+(?:[.,][0-9]+)?)\s*m(?:l|ls)\b', 'i'))[1], ',', '.')::numeric
      when coalesce(p.presentacion, '') ~* '([0-9]+(?:[.,][0-9]+)?)\s*(?:gramos|gr|g)\b'
        then replace((regexp_match(coalesce(p.presentacion, ''), '([0-9]+(?:[.,][0-9]+)?)\s*(?:gramos|gr|g)\b', 'i'))[1], ',', '.')::numeric
      else null
    end as cantidad,
    case
      when coalesce(p.presentacion, p.nombre, '') ~* 'm(?:l|ls)\b' then 'ml'
      when coalesce(p.presentacion, p.nombre, '') ~* '(?:gramos|gr|g)\b' then 'g'
      else null
    end as unidad,
    lower(coalesce(nullif(btrim(p.forma_farmaceutica), ''), p.nombre)) as linea
  from public.productos p
  where coalesce(p.activo, true)
    and coalesce(p.precio, 0) > 0
),
pares as (
  select
    a.sku as sku_chico,
    a.nombre as nombre_chico,
    a.presentacion as pres_chico,
    a.cantidad as cant_chico,
    a.precio as precio_chico,
    a.costo as costo_chico,
    b.sku as sku_grande,
    b.nombre as nombre_grande,
    b.presentacion as pres_grande,
    b.cantidad as cant_grande,
    b.precio as precio_grande,
    b.costo as costo_grande,
    a.marca,
    a.unidad
  from base a
  join base b
    on a.id < b.id
   and a.unidad = b.unidad
   and a.unidad is not null
   and a.cantidad is not null
   and b.cantidad is not null
   and b.cantidad > a.cantidad * 1.08
   and b.precio + 0.01 < a.precio
   and (
     -- misma marca + forma parecida
     (
       lower(coalesce(a.marca, '')) <> ''
       and lower(coalesce(a.marca, '')) = lower(coalesce(b.marca, ''))
       and (
         lower(coalesce(a.forma_farmaceutica, '')) = lower(coalesce(b.forma_farmaceutica, ''))
         or a.linea ilike '%agua%oxigen%' and b.linea ilike '%agua%oxigen%'
         or a.linea ilike '%alcohol%' and b.linea ilike '%alcohol%'
       )
     )
     -- o línea agua oxigenada aunque la marca diga Protec/Dermocleen/Degasa
     or (
       a.linea ilike '%agua%oxigen%'
       and b.linea ilike '%agua%oxigen%'
     )
   )
)
select *
from pares
order by (precio_chico - precio_grande) desc, marca, cant_chico;
