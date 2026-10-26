-- Farmalive 12790: Recibir muestra el ticket pero no deja guardar el MMAA.
-- El alta dejó el estado en pendiente_alta (o pendiente_caducidad).
-- Las funciones de pistola solo aceptan borrador, y por eso salen
-- «ya no está en borrador» y «esta recepcion ya esta cerrada».
-- Esto lo regresa a borrador. No toca renglones verdes, lotes ni stock.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Recargar Recibir y seguir escaneando. No tocar Cerrar hasta que no queden grises.

begin;

update public.recepciones r
set
  estado = 'borrador',
  cerrado_en = null,
  updated_at = now()
where coalesce(r.proveedor, '') ilike '%farmalive%'
  and regexp_replace(coalesce(r.folio, ''), '\D', '', 'g') in ('12790', '127790', '127900')
  and r.estado is distinct from 'borrador'
  and exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id
      and not coalesce(i.confirmado, false)
  );

select
  r.folio,
  r.estado,
  count(*) as renglones,
  count(*) filter (where coalesce(i.confirmado, false)) as verdes,
  count(*) filter (where not coalesce(i.confirmado, false)) as faltan
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%farmalive%'
  and regexp_replace(coalesce(r.folio, ''), '\D', '', 'g') in ('12790', '127790', '127900')
group by r.folio, r.estado;

commit;
