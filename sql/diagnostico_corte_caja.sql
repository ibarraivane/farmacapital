-- ============================================================
-- DIAGNÓSTICO DEL CORTE DE CAJA — FarmaCapital
-- Sólo lee. No modifica nada. Pegar en Supabase → SQL Editor.
-- Correr consulta por consulta y guardar los resultados.
-- ============================================================


-- ── 1. ¿Qué versión de reconcile_shift_cash está viva? ────────
-- Si vespertino termina en 21:59:59 → está la versión VIEJA y se
-- están perdiendo las ventas de 22:00 a 22:30 (Erika cierra 22:04).
-- Si matutino empieza en 08:00 → se pierde lo vendido antes de las 8.
select
  'matutino'   as turno,
  public.reconcile_shift_cash('matutino',   date '2026-08-19') as rangos_y_totales
union all
select
  'vespertino',
  public.reconcile_shift_cash('vespertino', date '2026-08-19');


-- ── 2. ¿Hay overloads viejos de registrar_corte_caja? ─────────
-- Debe salir UNA sola fila (13 argumentos). Si salen dos o tres,
-- hay versiones viejas conviviendo y PostgREST puede llamar la que no es.
select
  p.oid::regprocedure                  as firma,
  pg_get_function_arguments(p.oid)     as argumentos
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in ('registrar_corte_caja','reconcile_shift_cash',
                    'empleado_totales_electronicos_turno')
order by p.proname, p.oid::regprocedure::text;


-- ── 3. TODOS los métodos de pago que existen en pedidos ───────
-- reconcile_shift_cash sólo suma metodo_pago = 'tarjeta' y
-- ('mercadopago','mercadopago_point'). Cualquier otro valor que
-- aparezca aquí es dinero que NO se está sumando en ningún corte.
select
  coalesce(metodo_pago,'(null)') as metodo_pago,
  coalesce(estado,'(null)')      as estado,
  count(*)                       as ventas,
  sum(total)                     as monto,
  min(created_at at time zone 'America/Mexico_City') as primera,
  max(created_at at time zone 'America/Mexico_City') as ultima
from public.pedidos
where created_at >= now() - interval '30 days'
group by 1,2
order by monto desc nulls last;


-- ── 4. El constraint de metodo_pago, para saber qué acepta ────
select conname, pg_get_constraintdef(oid) as definicion
from pg_constraint
where conrelid = 'public.pedidos'::regclass
  and contype = 'c';


-- ── 5. Ventas con TARJETA del 18 y 19, hora por hora ──────────
-- Compara la suma real contra lo que quedó guardado en el corte
-- (18/8 vesp = $64.00, 19/8 mat = $63.43, 19/8 vesp = $0.00).
-- Si aquí sale más, ese es el faltante de tarjeta.
select
  (created_at at time zone 'America/Mexico_City')::date as dia,
  case
    when (created_at at time zone 'America/Mexico_City')::time < time '15:30'
    then 'matutino' else 'vespertino'
  end as turno_por_horario,
  metodo_pago,
  count(*)   as ventas,
  sum(total) as monto,
  string_agg(
    to_char(created_at at time zone 'America/Mexico_City','HH24:MI') ||
    ' $' || round(total,2)::text, ' · ' order by created_at
  ) as detalle
from public.pedidos
where estado = 'completado'
  and metodo_pago not in ('efectivo')
  and (created_at at time zone 'America/Mexico_City')::date
      between date '2026-08-18' and date '2026-08-19'
group by 1,2,3
order by 1,2,3;


-- ── 6. Ventas que caen FUERA de la ventana del corte ──────────
-- Si la versión vieja de reconcile está viva (08:00-15:59 / 16:00-21:59),
-- todo lo que salga aquí es dinero huérfano: no lo cuenta ningún turno.
select
  (created_at at time zone 'America/Mexico_City')::date as dia,
  to_char(created_at at time zone 'America/Mexico_City','HH24:MI') as hora,
  metodo_pago,
  total
from public.pedidos
where estado = 'completado'
  and created_at >= now() - interval '14 days'
  and (
       (created_at at time zone 'America/Mexico_City')::time <  time '08:00'
    or (created_at at time zone 'America/Mexico_City')::time >= time '22:00'
    or ((created_at at time zone 'America/Mexico_City')::time >= time '15:30'
        and (created_at at time zone 'America/Mexico_City')::time < time '16:00')
  )
order by created_at;


-- ── 7. PAGOS DE SERVICIO cobrados con tarjeta ────────────────
-- Esta tabla NO entra en reconcile_shift_cash. Si hay filas aquí
-- con metodo_pago='tarjeta', ese dinero jamás se precargó en el
-- corte y había que capturarlo a mano.
select
  fecha_local, metodo_pago,
  count(*) as operaciones,
  sum(total_cobrado) as cobrado,
  sum(comision)      as comision_farmacia
from (
  select (created_at at time zone 'America/Mexico_City')::date as fecha_local,
         metodo_pago, total_cobrado, comision
  from public.pagos_servicio
  where created_at >= now() - interval '30 days'
) s
group by 1,2
order by 1 desc, 2;


-- ── 8. Consultas de doctora cobradas: ¿con qué método? ───────
select
  (created_at at time zone 'America/Mexico_City')::date as dia,
  metodo_pago, estado, count(*), sum(total)
from public.pedidos
where tipo = 'consulta'
  and created_at >= now() - interval '30 days'
group by 1,2,3
order by 1 desc;


-- ── 9. La cadena del fondo: hueco de $120 del 19/8 ───────────
-- El fondo con el que abre un turno debería ser lo que declaró el
-- anterior. Cualquier fila con hueco <> 0 es dinero que entró o
-- salió del cajón sin registro.
select
  fecha, turno, cajero,
  fondo_inicial,
  lag(efectivo_declarado) over (order by fecha, hora_cierre) as declarado_del_anterior,
  fondo_inicial - lag(efectivo_declarado) over (order by fecha, hora_cierre) as hueco,
  efectivo_declarado, efectivo_sistema, diferencia
from (
  select c.fecha, c.hora_cierre, c.turno,
         coalesce(u.nombre,'(sin usuario)') as cajero,
         c.fondo_inicial, c.efectivo_declarado, c.efectivo_sistema, c.diferencia
  from public.cortes_caja c
  left join public.usuarios u on u.id = c.empleado_id
) t
order by fecha, hora_cierre;


-- ── 10. Cortes cuyo empleado_id no existe en usuarios ────────
-- Explica el cajero "—" del corte del 15/8.
select c.id, c.fecha, c.turno, c.empleado_id
from public.cortes_caja c
left join public.usuarios u on u.id = c.empleado_id
where u.id is null;


-- ── 11. Sesiones de caja: ¿coinciden con los cortes? ─────────
-- Aquí se ve la hora REAL de apertura y si alguien cerró tarde
-- (Mary cerró matutino a las 18:51 del 19/8).
select s.id, s.fecha, s.turno,
       coalesce(u.nombre,'(sin usuario)') as empleado,
       (s.abierta_at at time zone 'America/Mexico_City') as abrio,
       (s.cerrada_at at time zone 'America/Mexico_City') as cerro,
       s.fondo_contado, s.estado, s.corte_id
from public.caja_sesiones s
left join public.usuarios u on u.id = s.empleado_id
order by s.abierta_at desc
limit 30;
