-- Diagnóstico: ¿por qué Nadro 6091110421 no sale en Recibir?
-- Pegar en Supabase → SQL Editor → Run.

-- 1) ¿Existe la recepción? ¿En qué estado?
select
  r.id,
  r.proveedor,
  r.folio,
  r.fecha,
  r.total_ticket,
  r.estado,
  r.updated_at,
  left(coalesce(r.notas, ''), 80) as notas
from public.recepciones r
where r.folio = '6091110421'
   or r.folio ilike '%6091110421%'
order by r.id desc;

-- 2) ¿Tiene renglones? (sin renglones / todos confirmados → NO sale en Recibir)
select
  r.id as recepcion_id,
  r.estado,
  count(i.id) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar,
  count(*) filter (where i.pendiente_alta) as pendientes_alta,
  count(*) filter (where i.producto_id is null) as sin_producto
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '6091110421'
group by r.id, r.estado;

-- 3) Detalle de renglones (si hay recepción)
select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.confirmado,
  i.pendiente_alta,
  i.producto_id,
  p.sku,
  left(p.nombre, 40) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6091110421'
order by i.id;

-- Recibir solo lista estado en (borrador, pendiente_alta, pendiente_caducidad)
-- CON al menos 1 renglón sin confirmar (o verde sin MMAA de anaquel).
