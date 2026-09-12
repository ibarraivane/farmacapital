-- Diagnóstico: por qué Rosa Raquel no puede abrir caja.
-- Pegar TODO en Supabase → SQL Editor → Run. Solo lee, no cambia nada.

-- 1) Perfil(es) de acceso (lo que lee el POS) vs empleado(s) de nómina
select
  'usuario' as tipo,
  u.id,
  u.nombre,
  u.rol,
  u.activo,
  u.turno              as turno_en_usuarios,
  u.dia_descanso,
  u.telefono,
  u.eliminado_at
from public.usuarios u
where u.eliminado_at is null
  and u.nombre ilike '%rosa%'
order by u.id;

select
  'empleado' as tipo,
  e.id,
  e.nombre,
  e.rol,
  e.estado,
  e.turno              as turno_en_empleados,
  e.usuario_id,
  e.telefono
from public.empleados e
where e.nombre ilike '%rosa%'
order by e.id;

-- 2) Lo que la caja lee HOY (fuente de verdad del botón Abrir)
select
  u.id,
  u.nombre,
  u.turno                                   as turno_columna,
  public.fn_turno_caja_de(u.id)             as turno_habitual_fn,
  public.fn_es_descanso_hoy(u.id)           as es_descanso,
  public.fn_cubre_ambos_hoy(u.id)           as cubre_ambos,
  public.fn_turno_abrir_hoy(u.id)           as turno_abrir_hoy,
  public.fn_dia_idx_cdmx()                  as dia_hoy_idx,
  (now() at time zone 'America/Mexico_City') as ahora_cdmx
from public.usuarios u
where u.eliminado_at is null
  and u.nombre ilike '%rosa%';

-- 3) Si el empleado tiene turno pero el usuario no → no está ligado / no se sincronizó
select
  e.id as empleado_id,
  e.nombre as empleado,
  e.turno as turno_empleado,
  e.usuario_id,
  u.id as usuario_id_match,
  u.nombre as usuario,
  u.turno as turno_usuario,
  case
    when e.usuario_id is null and u.id is null then 'Sin perfil de acceso (Usuarios)'
    when e.usuario_id is null and u.id is not null then 'Empleado sin usuario_id; hay usuario homónimo'
    when u.turno is null and e.turno in ('matutino','vespertino') then 'Turno solo en nómina; falta en usuarios.turno (sección Turnos de caja en RH)'
    when u.turno is null then 'usuarios.turno vacío — por eso sale «Falta asignar turno en RH»'
    else 'OK en DB; si el POS sigue bloqueado, que cierre sesión y vuelva a entrar (sesión vieja)'
  end as diagnostico
from public.empleados e
left join public.usuarios u
  on u.eliminado_at is null
 and (
   u.id = e.usuario_id
   or lower(trim(u.nombre)) = lower(trim(e.nombre))
 )
where e.nombre ilike '%rosa%';
