-- SOLO DIAGNÓSTICO — no escribe nada.
-- Pedido Nadro folio 1658128647824-01 (y faltantes -FALT si existen).
-- Pegar en Supabase → SQL Editor → Run.
--
-- Cómo leerlo:
--   0 filas del folio original     → nunca se cargó; usa patch_recepcion_nadro_1658128647824_corroborar.sql
--   estado = borrador, 50 renglones → vivo en Recibir
--   estado = descuadre/confirmada   → ya se recibió; NO aparece en pedidos vivos
--     (si renglones < 50 → faltan cajas; usa patch_..._faltantes.sql)
--   folio ...-FALT en borrador      → esos faltantes ya están listos para pistola

select
  r.id,
  r.folio,
  r.estado,
  r.fecha,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where coalesce(i.confirmado, false)) as confirmados,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola,
  left(coalesce(r.notas, ''), 80) as notas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%nadro%'
  and r.folio in ('1658128647824-01', '1658128647824-01-FALT')
group by r.id, r.folio, r.estado, r.fecha, r.total_ticket, r.notas
order by r.id;
