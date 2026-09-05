-- ============================================================
-- DIAGNÓSTICO corte matutino 5-sep-2026 — SOLO LECTURA
--
-- Tablet: sistema $214 · 4 ventas $134 · faltante $23
-- Día calendario (ya corrido): pedidos $134 + servicios $50 = $184
-- Hueco: $214 − $184 = $30. Ese $30 es de DESPUÉS del corte previo y
-- ANTES de abrir hoy. Ya iba en el fondo; el sistema lo volvió a sumar
-- (patch_corte_ventana_sesion_20260905.sql lo corta).
-- ============================================================

-- 1. Cortes del 5-sep
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
  public.fn_corte_previo_at(c.created_at) as ventana_desde,
  c.created_at as ventana_hasta,
  c.notas,
  c.anulado_at is not null as anulado
from public.cortes_caja c
left join public.usuarios u on u.id = c.empleado_id
where (c.created_at at time zone 'America/Mexico_City')::date = date '2026-09-05'
order by c.created_at;

-- 2. Lo que el corte debió sumar (ventana real, no el día)
select
  c.id as corte_id,
  public.reconcile_cash_rango(
    public.fn_corte_previo_at(c.created_at),
    c.created_at
  ) as desglose_ventana
from public.cortes_caja c
where c.anulado_at is null
  and (c.created_at at time zone 'America/Mexico_City')::date = date '2026-09-05'
order by c.created_at;

-- 3. Pedidos del 5-sep
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

-- 4. Recargas / servicios del 5-sep (el $50)
select
  to_char(created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora,
  folio, proveedor, categoria, metodo_pago,
  monto_servicio, comision, total_cobrado
from public.pagos_servicio
where (created_at at time zone 'America/Mexico_City')::date = date '2026-09-05'
order by created_at;

-- 5. Movimientos DESPUÉS del corte previo y ANTES del 5-sep 00:00
--    Ahí debería estar el $30 que el día no ve y el corte sí.
with primer_corte as (
  select created_at
  from public.cortes_caja
  where anulado_at is null
    and (created_at at time zone 'America/Mexico_City')::date = date '2026-09-05'
  order by created_at
  limit 1
),
previo as (
  select public.fn_corte_previo_at((select created_at from primer_corte)) as desde
),
dia as (
  select ('2026-09-05'::timestamp) at time zone 'America/Mexico_City' as medianoche
)
select 'pedido' as tipo,
  to_char(p.created_at at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI') as cuando,
  p.id::text as folio,
  p.metodo_pago,
  (p.total - coalesce(p.monto_credito, 0)) as monto,
  p.estado
from public.pedidos p, previo, dia
where p.estado = 'completado'
  and p.created_at > previo.desde
  and p.created_at <= dia.medianoche
union all
select 'servicio',
  to_char(ps.created_at at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI'),
  ps.folio,
  ps.metodo_pago,
  ps.total_cobrado,
  null
from public.pagos_servicio ps, previo, dia
where ps.created_at > previo.desde
  and ps.created_at <= dia.medianoche
union all
select 'devolucion',
  to_char(d.created_at at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI'),
  d.id::text,
  d.estado,
  coalesce(d.monto_efectivo_ingreso, 0) - coalesce(d.monto_efectivo, 0),
  d.estado
from public.devoluciones d, previo, dia
where d.estado = 'aprobada'
  and d.created_at > previo.desde
  and d.created_at <= dia.medianoche
order by 2;

-- 6. Día vs sistema
select
  134.00::numeric as pedidos_dia,
  50.00::numeric  as servicios_dia,
  (134 + 50)::numeric as suma_dia,
  214.00::numeric as sistema_corte,
  (214 - 134 - 50)::numeric as hueco_30;
