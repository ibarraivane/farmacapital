-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Quitar de Recibir: Tienda Accu-Chek Softclix · folio 20260917
--
-- Motivo (08-nov-2026): el pedido se canceló; nunca llegará.
-- NO toca stock ni lotes (nunca se recibió). Solo saca la tarjeta de la cola.
-- Idempotente. Sin bloques dollar-quote.
-- =============================================================================

begin;

-- Antes
select
  r.id,
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '20260917'
  and coalesce(r.proveedor, '') ilike '%accu-chek%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;

-- Borrar renglones (solo si sigue abierto)
delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20260917'
  and coalesce(r.proveedor, '') ilike '%accu-chek%'
  and r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad', 'parcial', 'abierto');

-- Cerrar encabezado sin sumar stock (check: borrador|confirmada|descuadre|pendiente_*)
update public.recepciones r
set
  estado = 'confirmada',
  cerrado_en = coalesce(r.cerrado_en, now()),
  notas = trim(both from concat_ws(' · ',
    nullif(btrim(r.notas), ''),
    'Cancelado 08-nov-2026: pedido Accu-Chek Softclix no llegó; quitado de Recibir'
  )),
  updated_at = now()
where r.folio = '20260917'
  and coalesce(r.proveedor, '') ilike '%accu-chek%'
  and r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad', 'parcial', 'abierto');

commit;

-- VERIFICACION: confirmada / 0 renglones y NO en cola viva
select
  r.id,
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  r.cerrado_en,
  left(r.notas, 160) as notas,
  count(i.*) as renglones
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '20260917'
  and coalesce(r.proveedor, '') ilike '%accu-chek%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket, r.cerrado_en, r.notas;

select
  r.proveedor,
  r.folio,
  r.estado
from public.recepciones r
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and coalesce(r.proveedor, '') ilike '%accu%'
order by r.updated_at desc;
