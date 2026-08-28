-- ============================================================
-- RASTREO de las dos diferencias grandes. Sólo lee, no modifica.
--
--   18/8 → sobrante +$267.03  (fondo $0 + ventas $235.97 = $235.97
--                              esperado, contaron $503.00)
--   19/8 → faltante −$87.11   (fondo $623 + ventas $252.11 = $875.11
--                              esperado, contaron $788.00)
--   Y un hueco de +$120.00 entre el cierre del 18 y la apertura del 19.
--
-- Pegar en Supabase → SQL Editor.
-- ============================================================


-- ── A. ¿Hubo sesión de apertura real, o se tecleó el fondo? ────
-- Si abrio/cerro salen null o no hay fila, el fondo se capturó a
-- mano en el corte y nadie contó el cajón al abrir. Esa es la
-- explicación más probable del sobrante de $267 del 18/8:
-- abrieron con "fondo $0" habiendo cambio en el cajón.
select
  c.id as corte_id, c.fecha, c.turno,
  coalesce(u.nombre,'(sin usuario)') as cajero,
  c.fondo_inicial, c.efectivo_declarado, c.efectivo_sistema, c.diferencia,
  c.hora_apertura, c.hora_cierre,
  s.id as sesion_id,
  (s.abierta_at at time zone 'America/Mexico_City') as apertura_real,
  (s.cerrada_at at time zone 'America/Mexico_City') as cierre_real,
  s.fondo_contado    as fondo_contado_en_apertura,
  s.denominaciones   as piezas_apertura,
  s.nota_apertura,
  c.denominaciones   as piezas_cierre
from public.cortes_caja c
left join public.usuarios u      on u.id = c.empleado_id
left join public.caja_sesiones s on s.corte_id = c.id
where c.fecha between date '2026-08-15' and date '2026-08-19'
order by c.fecha, c.hora_cierre;


-- ── B. Todas las ventas del 18 y 19, minuto a minuto ──────────
-- Para ver si hay ventas registradas fuera de la ventana del turno,
-- o huecos largos sin ninguna venta que expliquen dinero suelto.
select
  (p.created_at at time zone 'America/Mexico_City')::date as dia,
  to_char(p.created_at at time zone 'America/Mexico_City','HH24:MI') as hora,
  case
    when (p.created_at at time zone 'America/Mexico_City')::time < time '15:30'
    then 'matutino' else 'vespertino'
  end as turno,
  p.id as pedido, p.tipo, p.metodo_pago, p.estado, p.total,
  coalesce(u.nombre,'—') as atendio
from public.pedidos p
left join public.usuarios u on u.id = p.atendido_por
where (p.created_at at time zone 'America/Mexico_City')::date
      between date '2026-08-18' and date '2026-08-19'
order by p.created_at;


-- ── C. Pedidos NO completados (cancelados, pendientes) ────────
-- reconcile_shift_cash sólo suma estado='completado'. Si una venta
-- se cobró en efectivo pero quedó en otro estado, el dinero está en
-- el cajón y el sistema no lo espera → sobrante.
select
  (created_at at time zone 'America/Mexico_City')::date as dia,
  to_char(created_at at time zone 'America/Mexico_City','HH24:MI') as hora,
  id, tipo, metodo_pago, estado, total
from public.pedidos
where estado is distinct from 'completado'
  and (created_at at time zone 'America/Mexico_City')::date
      between date '2026-08-15' and date '2026-08-19'
order by created_at;


-- ── D. Pagos de servicio del 18 y 19 ──────────────────────────
-- Estos NUNCA entraron al corte viejo. El efectivo de un pago de
-- servicio está físicamente en el cajón sin que el sistema lo
-- espere → sobrante. Candidato fuerte para los $267 del 18/8.
select
  (created_at at time zone 'America/Mexico_City')::date as dia,
  to_char(created_at at time zone 'America/Mexico_City','HH24:MI') as hora,
  folio, categoria, proveedor, metodo_pago,
  monto_servicio, comision, total_cobrado, liquidado_point
from public.pagos_servicio
where (created_at at time zone 'America/Mexico_City')::date
      between date '2026-08-15' and date '2026-08-19'
order by created_at;

-- Y el total, para compararlo directo contra las diferencias.
select
  (created_at at time zone 'America/Mexico_City')::date as dia,
  sum(total_cobrado) filter (where metodo_pago='efectivo') as efectivo_no_contado,
  sum(total_cobrado) filter (where metodo_pago='tarjeta')  as tarjeta_no_contada,
  count(*) as operaciones
from public.pagos_servicio
where (created_at at time zone 'America/Mexico_City')::date
      between date '2026-08-15' and date '2026-08-19'
group by 1 order by 1;


-- ── E. El hueco de $120: ¿se movió algo entre el 18 y el 19? ──
-- Todo lo que registró el sistema entre el cierre del 18 (22:04)
-- y la apertura del 19. Si sale vacío, los $120 entraron al cajón
-- sin pasar por ningún módulo.
select
  (created_at at time zone 'America/Mexico_City') as cuando,
  'pedido' as origen, id::text as ref, metodo_pago, estado, total
from public.pedidos
where created_at between
      (date '2026-08-18' + time '22:00') at time zone 'America/Mexico_City'
  and (date '2026-08-19' + time '12:00') at time zone 'America/Mexico_City'
union all
select
  (created_at at time zone 'America/Mexico_City'),
  'pago_servicio', folio, metodo_pago, '—', total_cobrado
from public.pagos_servicio
where created_at between
      (date '2026-08-18' + time '22:00') at time zone 'America/Mexico_City'
  and (date '2026-08-19' + time '12:00') at time zone 'America/Mexico_City'
order by cuando;


-- ── F. Bitácora de caja del período ───────────────────────────
-- Aperturas, cortes y quién los hizo, tal como quedaron en audit_log.
select
  (created_at at time zone 'America/Mexico_City') as cuando,
  usuario_nombre, accion, registro_id, detalle
from public.audit_log
where accion in ('abrir_caja','corte_caja')
  and created_at >= (date '2026-08-15') at time zone 'America/Mexico_City'
order by created_at;
