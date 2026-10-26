-- Diagnóstico Equilibrio 446466 (solo lectura). Pegar y Run; manda el resultado.
select 'productos' as tipo, sku, codigo_barras, left(nombre, 40) as nombre
from public.productos
where sku in ('EQ-AVT195', 'EQ-SER181', 'FC-24900809', 'FC-58215947')
   or codigo_barras in ('7506624900809', '7501258215947')
   or nombre ilike '%tusilen%'
   or nombre ilike '%ruquim%'
union all
select 'recepcion', r.folio || ' / ' || coalesce(i.codigo_escaneado, '-'),
       coalesce(i.pendiente_alta::text, ''),
       left(i.nombre_snapshot, 40)
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '446466'
order by 1, 2;
