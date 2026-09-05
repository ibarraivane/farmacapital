-- SOLO DIAGNÓSTICO — no escribe nada.
-- Pedido Nadro folio 1658128647824-01 (confirmación 1092336039).
-- Pegar en Supabase → SQL Editor → Run y mirar el resultado.
--
-- Cómo leerlo:
--   0 filas          → FALTA cargar. Pega patch_recepcion_nadro_1658128647824_corroborar.sql
--   estado = borrador y renglones = 50 → YA está en Recibir (refresca la app).
--   estado = borrador y renglones = 0 → quedó rota (vuelve a pegar el patch).
--   estado = confirmado/cerrado       → YA recibida; no debe salir en pedidos vivos.

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
  and r.folio = '1658128647824-01'
group by r.id, r.folio, r.estado, r.fecha, r.total_ticket, r.notas
order by r.id;
