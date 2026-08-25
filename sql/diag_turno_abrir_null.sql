-- ¿Por qué fn_turno_abrir_hoy da null para las dos? Solo lee.
-- La función devuelve null por exactamente tres razones. Esto dice cuál.

select
  u.id,
  u.nombre,
  u.rol,
  u.activo,
  u.turno                                as turno_columna,
  public.fn_turno_caja_de(u.id)          as turno_caja_de,   -- (1) ¿null?
  u.dia_descanso,
  public.fn_dia_idx_cdmx()               as dia_hoy,
  public.fn_es_descanso_hoy(u.id)        as es_descanso,      -- (2) ¿true?
  public.fn_cubre_ambos_hoy(u.id)        as cubre_ambos,
  public.fn_empleado_ya_tuvo_turno_hoy(u.id, 'matutino')   as ya_matutino,   -- (3)
  public.fn_empleado_ya_tuvo_turno_hoy(u.id, 'vespertino') as ya_vespertino, -- (3)
  public.fn_turno_abrir_hoy(u.id)        as resultado
from public.usuarios u
where u.eliminado_at is null
  and u.rol in ('vendedor', 'gerente')
order by u.id;

-- Reloj del servidor: confirma que "hoy" es lo que crees.
select (now() at time zone 'America/Mexico_City') as ahora_cdmx,
       (now() at time zone 'America/Mexico_City')::date as hoy_cdmx,
       public.fn_dia_idx_cdmx() as dia_idx;  -- 0=lun … 6=dom

-- Sesiones y cortes de HOY (lo que dispararía "ya tuvo turno")
select 'sesion' as tipo, s.id, u.nombre, s.turno, s.fecha, s.estado,
       (s.abierta_at at time zone 'America/Mexico_City')::text as cuando
from public.caja_sesiones s join public.usuarios u on u.id = s.empleado_id
where s.fecha = (now() at time zone 'America/Mexico_City')::date
union all
select 'corte', cc.id, u.nombre, cc.turno, cc.fecha,
       case when cc.anulado_at is null then 'vigente' else 'anulado' end,
       (cc.created_at at time zone 'America/Mexico_City')::text
from public.cortes_caja cc left join public.usuarios u on u.id = cc.empleado_id
where ((cc.created_at at time zone 'America/Mexico_City')::date)
      = (now() at time zone 'America/Mexico_City')::date;
