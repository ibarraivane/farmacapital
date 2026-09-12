-- Solo diagnóstico. No modifica nada.
-- Pegar en Supabase → SQL Editor → Run y revisar si hay filas.

select id, proveedor, folio, fecha, total_ticket, estado, left(coalesce(notas,''), 80) as notas
from public.recepciones
where folio = 'S321781'
   or folio ilike '%321781%'
   or coalesce(notas,'') ilike '%S321781%';

select i.id, i.codigo_escaneado, left(i.nombre_snapshot, 48) as nombre, i.cantidad, i.confirmado, i.pendiente_alta
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = 'S321781';

select sku, codigo_barras, left(nombre, 48) as nombre, stock, costo, precio
from public.productos
where codigo_barras in ('7501871720620', '7501471800265');
