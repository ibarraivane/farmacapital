-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Folio 15341570: estaba como Cityfarma / Farma City → Farmaceuticos Tenorio
-- No toca renglones ni EANs. Solo proveedor + notas. Idempotente.
-- Sin dollar-quote.
-- =============================================================================

begin;

update public.recepciones
set
  proveedor = 'Farmaceuticos Tenorio',
  notas = 'Farmaceuticos Tenorio · folio 15341570 · 17-nov-2026 10:37 · 28 renglones · total $6,982.85 · cola Recibir; stock al confirmar pistola · MMAA de la caja',
  updated_at = now()
where folio = '15341570'
  and estado = 'borrador'
  and (
    coalesce(proveedor, '') ilike '%cityfarma%'
    or coalesce(proveedor, '') ilike '%farma city%'
    or coalesce(proveedor, '') ilike '%tenorio%'
    or coalesce(proveedor, '') = ''
  );

-- VERIFICACION
select id, folio, proveedor, estado, total_ticket, left(notas, 120) as notas
from public.recepciones
where folio = '15341570'
order by id;

select
  r.folio,
  r.proveedor,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '15341570'
group by r.id, r.folio, r.proveedor;

commit;
