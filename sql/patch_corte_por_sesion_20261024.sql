-- ============================================================
-- Corte por sesión, no «un matutino por farmacia»
-- 24-oct-2026. Idempotente. Pegar en Supabase SQL Editor.
--
-- Caso: Cinthia abre y corta matutino; luego Iván abre caja.
-- Antes el UI bloqueaba el segundo corte porque
-- empleado_corte_turno_en_fecha devolvía el # de Cinthia a admin.
--
-- Regla: si tienes caja abierta, ese cajón aún no corta.
-- Sin sesión, solo tu propio corte del turno bloquea.
-- Admin puede ver el último corte ajeno (previo_*) para anularlo
-- si fue error — sin impedir guardar el suyo tras abrir.
-- ============================================================

begin;

create or replace function public.empleado_corte_turno_en_fecha(
  p_session_token uuid,
  p_fecha date,
  p_turno text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
  v_turno text;
  v_id bigint;
  v_previo_id bigint;
  v_previo_nombre text;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;

  v_turno := p_turno;
  if coalesce(v_rol, '') = 'vendedor' then
    v_turno := coalesce(public.fn_turno_caja_de(v_user_id), p_turno);
  end if;

  -- Cajón abierto = este turno aún no cierra. El corte de quien salió
  -- antes (mismo rótulo matutino/vespertino) no cuenta como «ya corté».
  if exists (
    select 1
    from public.caja_sesiones s
    where s.empleado_id = v_user_id
      and s.estado = 'abierta'
  ) then
    return jsonb_build_object(
      'existe', false,
      'id', null,
      'sesion_abierta', true
    );
  end if;

  select cc.id into v_id
  from public.cortes_caja cc
  where cc.empleado_id = v_user_id
    and cc.turno = v_turno
    and cc.anulado_at is null
    and ((cc.created_at at time zone 'America/Mexico_City')::date) = p_fecha
  order by cc.created_at desc
  limit 1;

  if v_id is not null then
    return jsonb_build_object(
      'existe', true,
      'id', v_id,
      'propio', true
    );
  end if;

  -- Gerencia: último corte ajeno del turno, solo para anular si fue error.
  if coalesce(v_rol, '') in ('admin', 'gerente') then
    select cc.id, u.nombre
      into v_previo_id, v_previo_nombre
    from public.cortes_caja cc
    left join public.usuarios u on u.id = cc.empleado_id
    where cc.turno = v_turno
      and cc.anulado_at is null
      and ((cc.created_at at time zone 'America/Mexico_City')::date) = p_fecha
    order by cc.created_at desc
    limit 1;

    if v_previo_id is not null then
      return jsonb_build_object(
        'existe', false,
        'id', null,
        'previo_id', v_previo_id,
        'previo_nombre', v_previo_nombre
      );
    end if;
  end if;

  return jsonb_build_object('existe', false, 'id', null);
end;
$$;

grant execute on function public.empleado_corte_turno_en_fecha(uuid, date, text) to anon, authenticated;

notify pgrst, 'reload schema';

commit;
