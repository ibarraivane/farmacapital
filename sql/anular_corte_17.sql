-- Anula el corte fantasma 17 (Erika, 24-ago 15:19) y le devuelve el turno.
-- Requiere el parche de cadena ya aplicado.

begin;

update public.cortes_caja
   set anulado_at     = now(),
       anulado_por    = (select id from public.usuarios
                          where rol = 'admin' and eliminado_at is null
                          order by id limit 1),
       anulado_motivo = 'Corte disparado por error a las 15:19 sin sesion de caja abierta. Erika nunca abrio turno; el corte concilio $0 y la dejo fuera de la caja el resto del dia.'
 where id = 17
   and anulado_at is null;

insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
select u.id, u.nombre, 'anular_corte', 'cortes_caja', '17',
       jsonb_build_object('motivo', 'corte fantasma sin sesion', 'turno', 'vespertino')
from public.usuarios u
where u.rol = 'admin' and u.eliminado_at is null
order by u.id limit 1;

commit;

-- Verificación: Erika debe poder abrir vespertino.
select u.nombre,
       public.fn_turno_abrir_hoy(u.id) as puede_abrir,
       public.fn_empleado_ya_tuvo_turno_hoy(u.id, 'vespertino') as ya_vespertino
from public.usuarios u
where u.eliminado_at is null and u.rol = 'vendedor'
order by u.id;
