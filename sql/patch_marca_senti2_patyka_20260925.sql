-- Senti2 es el distribuidor. Los 31 activos con marca Senti2 tienen
-- código 3700591…, prefijo de Patyka. No toca imagen_url ni el nombre:
-- en varios el texto del catálogo no coincide con la ficha oficial
-- (ver docs/REPORTE_imagenes_candidatas_20260924.md).
--
-- Pegar en el SQL editor. Idempotente.

begin;

update public.productos
set marca = 'Patyka',
    updated_at = now()
where marca = 'Senti2'
  and codigo_barras like '3700591%';

-- Tiene que devolver una sola fila: Patyka, 31.
select marca, count(*) as n
from public.productos
where codigo_barras like '3700591%'
group by marca
order by marca;

commit;
