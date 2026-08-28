-- Diagnóstico: por qué Erika no puede abrir caja.
-- Pegar TODO en Supabase → SQL Editor → Run. Solo lee, no cambia nada.

with erika as (
  select id, nombre, rol, turno, dia_descanso, activo
  from public.usuarios
  where eliminado_at is null and nombre ilike '%erika%'
  order by id limit 1
)
select
  e.id, e.nombre, e.rol, e.turno            as turno_asignado,
  e.dia_descanso,
  public.fn_dia_idx_cdmx()                  as dia_hoy_idx,
  (now() at time zone 'America/Mexico_City') as ahora_cdmx,
  public.fn_es_descanso_hoy(e.id)           as es_descanso,
  public.fn_cubre_ambos_hoy(e.id)           as cubre_ambos,
  public.fn_turno_abrir_hoy(e.id)           as turno_que_puede_abrir,
  public.fn_empleado_ya_tuvo_turno_hoy(e.id, 'matutino')   as ella_ya_matutino,
  public.fn_empleado_ya_tuvo_turno_hoy(e.id, 'vespertino') as ella_ya_vespertino,
  public.fn_farmacia_ya_corte_turno_hoy('matutino')        as farmacia_ya_corte_mat,
  public.fn_farmacia_ya_corte_turno_hoy('vespertino')      as farmacia_ya_corte_vesp
from erika e;

-- Sesiones de caja de los últimos 3 días
select s.id, s.empleado_id, u.nombre, s.turno, s.fecha, s.estado,
       s.abierta_at, s.cerrada_at, s.corte_id
from public.caja_sesiones s
join public.usuarios u on u.id = s.empleado_id
where s.fecha >= ((now() at time zone 'America/Mexico_City')::date - 3)
order by s.fecha desc, s.abierta_at desc;

-- Cortes de los últimos 3 días (ojo a fecha vs created_at)
select cc.id, cc.empleado_id, u.nombre, cc.turno, cc.fecha,
       cc.created_at,
       (cc.created_at at time zone 'America/Mexico_City')::date as fecha_cdmx_calculada,
       cc.hora_cierre
from public.cortes_caja cc
left join public.usuarios u on u.id = cc.empleado_id
where cc.fecha >= ((now() at time zone 'America/Mexico_City')::date - 3)
   or cc.created_at >= (now() - interval '3 days')
order by cc.created_at desc;
