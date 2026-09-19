-- 19-sep-2026. Rosa abrio la caja con el perfil de Cinthia.
-- Raquel ya abrio despues y conto lo que Cinthia dejo en el cajon.
--
-- Esto:
--   1) Anula el corte de Cinthia de hoy. No lo borra. No reabre esa sesion.
--   2) Pasa a Raquel los pedidos y pagos de servicio de esa ventana.
--   3) Quita la sesion cerrada del nombre de Cinthia, para que no le cuente
--      como turno trabajado. Sigue cerrada: no puede haber dos cajas abiertas.
--
-- No toca fondo_contado ni abierta_at de Raquel. Ese conteo ya trae el
-- efectivo de esas ventas. Si se recorre la hora, el corte las suma otra vez.
--
-- Pegar TODO en Supabase SQL Editor y Run.
-- Si sale "division by zero", no coincidio el caso y no cambio nada.
-- La ultima linea tiene que ser: order by s.abierta_at;

begin;

select 1 / (
  select case
    when (
      (select count(*)
         from public.usuarios u
        where u.eliminado_at is null
          and u.nombre ilike '%raquel%') = 1
      and (select count(*)
             from public.usuarios u
            where u.eliminado_at is null
              and u.nombre not ilike '%raquel%'
              and (u.nombre ilike '%cinth%'
                   or u.nombre ilike '%cynth%'
                   or u.nombre ilike '%cintia%')) = 1
      and (select count(*)
             from public.cortes_caja c
             join public.usuarios u on u.id = c.empleado_id
            where c.anulado_at is null
              and c.turno = 'matutino'
              and u.eliminado_at is null
              and u.nombre not ilike '%raquel%'
              and (u.nombre ilike '%cinth%'
                   or u.nombre ilike '%cynth%'
                   or u.nombre ilike '%cintia%')
              and c.created_at >= (timestamp '2026-09-19' at time zone 'America/Mexico_City')
              and c.created_at <  (timestamp '2026-09-20' at time zone 'America/Mexico_City')) = 1
      and (select count(*)
             from public.caja_sesiones s
             join public.usuarios u on u.id = s.empleado_id
            where s.estado = 'abierta'
              and u.eliminado_at is null
              and u.nombre ilike '%raquel%') = 1
      and (select count(*)
             from public.caja_sesiones s
             join public.usuarios u on u.id = s.empleado_id
            where s.estado = 'cerrada'
              and s.fecha = date '2026-09-19'
              and s.turno = 'matutino'
              and u.eliminado_at is null
              and u.nombre not ilike '%raquel%'
              and (u.nombre ilike '%cinth%'
                   or u.nombre ilike '%cynth%'
                   or u.nombre ilike '%cintia%')) = 1
      and (
        select bool_and(sr.abierta_at > sc.abierta_at)
          from public.caja_sesiones sr
          join public.usuarios ur on ur.id = sr.empleado_id
          join public.caja_sesiones sc
            on sc.estado = 'cerrada'
           and sc.fecha = date '2026-09-19'
           and sc.turno = 'matutino'
          join public.usuarios uc on uc.id = sc.empleado_id
         where sr.estado = 'abierta'
           and ur.eliminado_at is null
           and ur.nombre ilike '%raquel%'
           and uc.eliminado_at is null
           and uc.nombre not ilike '%raquel%'
           and (uc.nombre ilike '%cinth%'
                or uc.nombre ilike '%cynth%'
                or uc.nombre ilike '%cintia%')
      ) is true
    ) then 1
    else 0
  end
);

with cin as (
  select u.id
    from public.usuarios u
   where u.eliminado_at is null
     and u.nombre not ilike '%raquel%'
     and (u.nombre ilike '%cinth%'
          or u.nombre ilike '%cynth%'
          or u.nombre ilike '%cintia%')
),
raq as (
  select u.id
    from public.usuarios u
   where u.eliminado_at is null
     and u.nombre ilike '%raquel%'
),
cor as (
  select c.id
    from public.cortes_caja c
    join cin on cin.id = c.empleado_id
   where c.anulado_at is null
     and c.turno = 'matutino'
     and c.created_at >= (timestamp '2026-09-19' at time zone 'America/Mexico_City')
     and c.created_at <  (timestamp '2026-09-20' at time zone 'America/Mexico_City')
),
ses_c as (
  select s.id, s.abierta_at
    from public.caja_sesiones s
    join cin on cin.id = s.empleado_id
   where s.estado = 'cerrada'
     and s.fecha = date '2026-09-19'
     and s.turno = 'matutino'
),
ses_r as (
  select s.abierta_at
    from public.caja_sesiones s
    join raq on raq.id = s.empleado_id
   where s.estado = 'abierta'
),
ped as (
  update public.pedidos p
     set atendido_por = (select id from raq)
   where p.atendido_por = (select id from cin)
     and p.created_at >= (timestamp '2026-09-19' at time zone 'America/Mexico_City')
     and p.created_at <  (select abierta_at from ses_r)
  returning p.id
),
pag as (
  update public.pagos_servicio ps
     set atendido_por = (select id from raq)
   where ps.atendido_por = (select id from cin)
     and ps.created_at >= (timestamp '2026-09-19' at time zone 'America/Mexico_City')
     and ps.created_at <  (select abierta_at from ses_r)
  returning ps.id
),
anu as (
  update public.cortes_caja c
     set anulado_at = now(),
         anulado_por = (
           select u.id
             from public.usuarios u
            where u.rol = 'admin'
              and u.eliminado_at is null
            order by u.id
            limit 1
         ),
         anulado_motivo = '19-sep-2026: Rosa abrio con el perfil de Cinthia. El corte no cuenta. Las ventas de esa ventana pasan a Raquel. No se reabre esta sesion: Raquel ya tiene la caja con el fondo que dejo Cinthia.'
   where c.id = (select id from cor)
     and c.anulado_at is null
  returning c.id
),
ses_mov as (
  update public.caja_sesiones s
     set empleado_id = (select id from raq),
         corte_id = null,
         nota_apertura = concat_ws(
           ' ',
           nullif(btrim(s.nota_apertura), ''),
           '19-sep-2026: abierta con el perfil de Cinthia. Corte anulado. Queda a nombre de Raquel y cerrada. El fondo de la caja abierta no se toco.'
         )
   where s.id = (select id from ses_c)
     and s.empleado_id = (select id from cin)
     and s.estado = 'cerrada'
  returning s.id
)
select
  (select count(*) from ped) as pedidos_pasados,
  (select count(*) from pag) as servicios_pasados,
  (select id from anu) as corte_anulado,
  (select id from ses_mov) as sesion_reasignada,
  1 / (
    case
      when (select count(*) from anu) = 1
       and (select count(*) from ses_mov) = 1
      then 1
      else 0
    end
  ) as ok;

insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
select actor.id,
       actor.nombre,
       'anular_corte',
       'cortes_caja',
       c.id::text,
       jsonb_build_object(
         'motivo', 'Rosa abrio con el perfil de Cinthia. Ventas de esa ventana a Raquel. Fondo de Raquel intacto.',
         'corte_id', c.id,
         'turno', c.turno,
         'empleado_corte', c.empleado_id,
         'fecha', '2026-09-19'
       )::text
  from public.cortes_caja c
  join (
    select id, nombre
      from (
        select 1 as prio, u.id, u.nombre
          from public.usuarios u
         where u.rol = 'admin'
           and u.eliminado_at is null
        union all
        select 2, u.id, u.nombre
          from public.usuarios u
         where u.eliminado_at is null
           and u.nombre ilike '%raquel%'
      ) z
     order by prio, id
     limit 1
  ) actor on true
 where c.anulado_at is not null
   and c.anulado_motivo like '19-sep-2026: Rosa abrio con el perfil de Cinthia%'
   and c.created_at >= (timestamp '2026-09-19' at time zone 'America/Mexico_City')
   and c.created_at <  (timestamp '2026-09-20' at time zone 'America/Mexico_City');

commit;

select u.nombre,
       count(*) as tickets,
       round(coalesce(sum(p.total), 0), 2) as total
  from public.pedidos p
  join public.usuarios u on u.id = p.atendido_por
 where p.created_at >= (timestamp '2026-09-19' at time zone 'America/Mexico_City')
   and p.created_at <  (timestamp '2026-09-20' at time zone 'America/Mexico_City')
   and (u.nombre ilike '%raquel%'
        or u.nombre ilike '%cinth%'
        or u.nombre ilike '%cynth%'
        or u.nombre ilike '%cintia%')
 group by u.nombre
 order by u.nombre;

select u.nombre,
       c.id as corte_id,
       c.turno,
       case when c.anulado_at is null then 'vigente' else 'anulado' end as corte
  from public.cortes_caja c
  join public.usuarios u on u.id = c.empleado_id
 where c.created_at >= (timestamp '2026-09-19' at time zone 'America/Mexico_City')
   and c.created_at <  (timestamp '2026-09-20' at time zone 'America/Mexico_City')
   and (u.nombre ilike '%raquel%'
        or u.nombre ilike '%cinth%'
        or u.nombre ilike '%cynth%'
        or u.nombre ilike '%cintia%')
 order by c.id;

select u.nombre,
       s.id as sesion_id,
       s.turno,
       s.estado,
       s.fondo_contado,
       s.corte_id,
       to_char(s.abierta_at at time zone 'America/Mexico_City', 'HH24:MI') as abrio
  from public.caja_sesiones s
  join public.usuarios u on u.id = s.empleado_id
 where (s.fecha = date '2026-09-19' or s.estado = 'abierta')
   and (u.nombre ilike '%raquel%'
        or u.nombre ilike '%cinth%'
        or u.nombre ilike '%cynth%'
        or u.nombre ilike '%cintia%')
 order by s.abierta_at;
