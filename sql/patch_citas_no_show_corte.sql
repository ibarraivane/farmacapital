-- FarmaCapital — Al corte: marcar no-show las citas sin pago cuya hora ya pasó.
-- No borra el registro (queda historial). Si sí se atendió tarde, POS puede reabrir cobro.
-- Ejecutar en Supabase → SQL Editor → Run. Idempotente.

begin;

create or replace function public.empleado_marcar_citas_no_show_corte(
  p_session_token uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_n     int := 0;
  v_ahora timestamp;
begin
  v_actor := public.fn_require_empleado(p_session_token);
  v_ahora := timezone('America/Mexico_City', now());

  update public.citas c
     set estado = 'no_asistio'
   where coalesce(c.estado, '') not in ('cancelada', 'no_asistio', 'completada', 'en_consulta', 'pagada')
     and coalesce(c.pago_estado, '') is distinct from 'pagada'
     and c.pedido_consulta_id is null
     and c.fecha is not null
     and (
       (c.fecha::timestamp
         + coalesce(c.hora::time, time '00:00')
         + interval '10 minutes') < v_ahora
     );

  get diagnostics v_n = row_count;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'citas_no_show_corte', 'citas', null,
      jsonb_build_object('marcadas', v_n)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'marcadas', v_n);
end;
$$;

grant execute on function public.empleado_marcar_citas_no_show_corte(uuid)
  to anon, authenticated;

create or replace function public.empleado_reabrir_cita_cobro(
  p_session_token uuid,
  p_cita_id       bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_n     int;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if p_cita_id is null then
    raise exception 'Cita requerida';
  end if;

  update public.citas
     set estado = 'agendada'
   where id = p_cita_id
     and coalesce(estado, '') in ('no_asistio', 'cancelada')
     and coalesce(pago_estado, '') is distinct from 'pagada'
     and pedido_consulta_id is null;

  get diagnostics v_n = row_count;
  if v_n = 0 then
    raise exception 'No se puede reabrir esta cita (ya está pagada o no está anulada)';
  end if;

  return jsonb_build_object('success', true, 'cita_id', p_cita_id);
end;
$$;

grant execute on function public.empleado_reabrir_cita_cobro(uuid, bigint)
  to anon, authenticated;

commit;
