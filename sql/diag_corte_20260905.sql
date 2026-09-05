-- ============================================================
-- DIAGNÓSTICO corte matutino 5-sep-2026 — SOLO LECTURA
--
-- Captura tablet: sistema $214 · detalle 4 ventas $134 · faltante $23
-- René: «Lo conté mal» · «No deja cerrar la sesión»
-- El hueco $80 suele ser una recarga (Telcel $80) que el corte suma
-- al efectivo y el detalle no listaba.
-- ============================================================

select
  c.id,
  coalesce(u.nombre, '(sin usuario)') as cajero,
  c.turno,
  c.fecha,
  to_char(c.created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora_corte,
  c.fondo_inicial,
  c.efectivo_sistema,
  (c.fondo_inicial + c.efectivo_sistema) as esperado,
  c.efectivo_declarado,
  c.diferencia,
  c.total_general,
  c.notas,
  c.anulado_at is not null as anulado
from public.cortes_caja c
left join public.usuarios u on u.id = c.empleado_id
where (c.created_at at time zone 'America/Mexico_City')::date = date '2026-09-05'
order by c.created_at;

select
  to_char(p.created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora,
  p.id as folio,
  coalesce(u.nombre, '—') as atendio,
  p.estado,
  p.metodo_pago,
  p.total,
  coalesce(p.monto_credito, 0) as credito
from public.pedidos p
left join public.usuarios u on u.id = p.atendido_por
where (p.created_at at time zone 'America/Mexico_City')::date = date '2026-09-05'
order by p.created_at;

select
  to_char(created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora,
  folio, proveedor, categoria, metodo_pago,
  monto_servicio, comision, total_cobrado
from public.pagos_servicio
where (created_at at time zone 'America/Mexico_City')::date = date '2026-09-05'
order by created_at;

-- Hueco típico: efectivo sistema vs suma de tickets de producto
select
  (select round(coalesce(sum(total - coalesce(monto_credito, 0)), 0), 2)
     from public.pedidos
    where estado = 'completado' and metodo_pago = 'efectivo'
      and (created_at at time zone 'America/Mexico_City')::date = date '2026-09-05'
  ) as efectivo_pedidos,
  (select round(coalesce(sum(total_cobrado), 0), 2)
     from public.pagos_servicio
    where metodo_pago = 'efectivo'
      and (created_at at time zone 'America/Mexico_City')::date = date '2026-09-05'
  ) as efectivo_servicios;
