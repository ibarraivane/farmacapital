-- Nómina: semana de pago sábado–viernes, depósito el viernes.
-- No toca horarios, turno de caja ni abrir/cerrar caja.
-- Solo lee caja_sesiones para mostrar "Abrió caja" y proponer Trabajo
-- si ese día ya hubo sesión (igual que antes; el rango ahora es sáb–vie).
--
-- Requiere sql/patch_rh_pago_semanal_20260822.sql ya aplicado.
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.

begin;

comment on column public.empleados.salario_semanal is
  'Pago de una semana completa sábado–viernes (se deposita el viernes). Diario = este monto / 7. No define horario ni permiso de caja.';

comment on table public.rh_pagos_semana is
  'Pago de la semana sábado–viernes. Un registro por empleado y sábado. No abre ni cierra caja.';

-- Pagos ya guardados con inicio en martes (martes + 3 = viernes) pasan al sábado de esa misma semana.
update public.rh_pagos_semana p
   set semana_inicio = p.semana_inicio - 3
 where extract(dow from p.semana_inicio)::int = 2
   and p.semana_fin = p.semana_inicio + 3
   and not exists (
     select 1
       from public.rh_pagos_semana o
      where o.empleado_id = p.empleado_id
        and o.id <> p.id
        and o.semana_inicio = p.semana_inicio - 3
   );


create or replace function public.fn_rh_sabado_semana(p_fecha date)
returns date
language sql
immutable
as $$
  -- 0=domingo … 6=sábado. El sábado abre la semana que se paga el viernes.
  select p_fecha - (
    case extract(dow from p_fecha)::int
      when 6 then 0
      when 0 then 1
      when 1 then 2
      when 2 then 3
      when 3 then 4
      when 4 then 5
      else 6
    end
  );
$$;


create or replace function public.rh_semana_empleado(
  p_session_token uuid,
  p_empleado_id   bigint,
  p_fecha         date default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_fecha   date;
  v_sabado  date;
  v_viernes date;
  v_hoy     date;
  v_emp     public.empleados%rowtype;
  v_uid     bigint;
  v_semanal numeric;
  v_diario  numeric;
  v_dias    jsonb;
  v_pago    jsonb;
  v_trabajo int;
  v_hasta   int;
begin
  perform public.fn_require_admin(p_session_token);

  if p_empleado_id is null then
    raise exception 'Empleado requerido';
  end if;

  select * into v_emp from public.empleados where id = p_empleado_id;
  if not found then
    raise exception 'Empleado no encontrado';
  end if;

  v_fecha   := coalesce(p_fecha, public.fn_rh_hoy_mexico());
  v_sabado  := public.fn_rh_sabado_semana(v_fecha);
  v_viernes := v_sabado + 6;
  v_hoy     := public.fn_rh_hoy_mexico();
  v_uid     := v_emp.usuario_id;
  v_semanal := coalesce(v_emp.salario_semanal, 0);
  v_diario  := round(v_semanal / 7.0, 2);

  -- Lectura de caja: no inserta, no cierra y no cambia el permiso de abrir.
  if v_uid is not null then
    insert into public.rh_asistencia (empleado_id, fecha, estado, origen)
    select p_empleado_id, cs.fecha, 'trabajo', 'caja'
      from public.caja_sesiones cs
     where cs.empleado_id = v_uid
       and cs.fecha between v_sabado and v_viernes
    on conflict (empleado_id, fecha) do nothing;
  end if;

  select coalesce(jsonb_agg(row_js order by fecha), '[]'::jsonb)
    into v_dias
    from (
      select d.fecha,
             jsonb_build_object(
               'fecha', d.fecha,
               'estado', a.estado,
               'origen', a.origen,
               'abrio_caja', exists (
                 select 1 from public.caja_sesiones cs
                  where v_uid is not null
                    and cs.empleado_id = v_uid
                    and cs.fecha = d.fecha
               )
             ) as row_js
        from generate_series(v_sabado::timestamp, v_viernes::timestamp, interval '1 day') gs
        cross join lateral (select gs::date as fecha) d
        left join public.rh_asistencia a
          on a.empleado_id = p_empleado_id and a.fecha = d.fecha
    ) q;

  select count(*)::int into v_trabajo
    from public.rh_asistencia
   where empleado_id = p_empleado_id
     and fecha between v_sabado and v_viernes
     and estado = 'trabajo';

  select count(*)::int into v_hasta
    from public.rh_asistencia
   where empleado_id = p_empleado_id
     and fecha between v_sabado and least(v_hoy, v_viernes)
     and estado = 'trabajo';

  select jsonb_build_object(
           'id', p.id,
           'dias_pagados', p.dias_pagados,
           'bruto', p.bruto,
           'imss_monto', p.imss_monto,
           'neto', p.neto,
           'aplicar_imss', p.aplicar_imss,
           'folio_spei', p.folio_spei,
           'clave_rastreo', p.clave_rastreo,
           'pagado_en', p.pagado_en,
           'notas', p.notas
         )
    into v_pago
    from public.rh_pagos_semana p
   where p.empleado_id = p_empleado_id
     and p.semana_inicio = v_sabado;

  return jsonb_build_object(
    'empleado_id', p_empleado_id,
    'nombre', v_emp.nombre,
    'salario_semanal', v_semanal,
    'diario', v_diario,
    'semana_inicio', v_sabado,
    'semana_fin', v_viernes,
    'hoy', v_hoy,
    'dias', v_dias,
    'dias_trabajo', v_trabajo,
    'dias_trabajo_hasta_hoy', v_hasta,
    'bruto', case when v_trabajo >= 7 then v_semanal else round(v_diario * v_trabajo, 2) end,
    'bruto_hasta_hoy', case when v_hasta >= 7 then v_semanal else round(v_diario * v_hasta, 2) end,
    'pago', v_pago
  );
end;
$$;

grant execute on function public.rh_semana_empleado(uuid, bigint, date)
  to anon, authenticated;


create or replace function public.rh_registrar_pago(
  p_session_token  uuid,
  p_empleado_id    bigint,
  p_fecha          date default null,
  p_hasta          date default null,
  p_aplicar_imss   boolean default false,
  p_folio_spei     text default null,
  p_clave_rastreo  text default null,
  p_notas          text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor   bigint;
  v_fecha   date;
  v_sabado  date;
  v_viernes date;
  v_hasta   date;
  v_semanal numeric;
  v_diario  numeric;
  v_dias    int;
  v_bruto   numeric;
  v_imss    numeric;
  v_neto    numeric;
  v_id      bigint;
  v_banco   text;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_empleado_id is null then
    raise exception 'Empleado requerido';
  end if;

  v_fecha   := coalesce(p_fecha, public.fn_rh_hoy_mexico());
  v_sabado  := public.fn_rh_sabado_semana(v_fecha);
  v_viernes := v_sabado + 6;
  v_hasta   := least(coalesce(p_hasta, v_viernes), v_viernes);
  if v_hasta < v_sabado then
    v_hasta := v_sabado;
  end if;

  select salario_semanal, coalesce(banco, '') || coalesce(cuenta_mascara, '')
    into v_semanal, v_banco
    from public.empleados
   where id = p_empleado_id;
  if not found then
    raise exception 'Empleado no encontrado';
  end if;

  v_semanal := coalesce(v_semanal, 0);
  if v_semanal <= 0 then
    raise exception 'Falta el salario semanal (sábado–viernes) de este empleado';
  end if;

  v_diario := round(v_semanal / 7.0, 2);

  select count(*)::int into v_dias
    from public.rh_asistencia
   where empleado_id = p_empleado_id
     and fecha between v_sabado and v_hasta
     and estado = 'trabajo';

  if v_dias <= 0 then
    raise exception 'No hay días trabajados para pagar en esta semana';
  end if;

  v_bruto := case when v_dias >= 7 then v_semanal else round(v_diario * v_dias, 2) end;
  v_imss  := case when coalesce(p_aplicar_imss, false) then round(v_bruto * 0.02375, 2) else 0 end;
  v_neto  := round(v_bruto - v_imss, 2);

  if exists (
    select 1 from public.rh_pagos_semana
     where empleado_id = p_empleado_id and semana_inicio = v_sabado
  ) then
    raise exception 'Ya hay un pago registrado para esta semana';
  end if;

  insert into public.rh_pagos_semana (
    empleado_id, semana_inicio, semana_fin, dias_pagados,
    salario_semanal, diario, bruto, aplicar_imss, imss_monto, neto,
    folio_spei, clave_rastreo, banco_destino, pagado_en, notas, created_by
  ) values (
    p_empleado_id, v_sabado, v_viernes, v_dias,
    v_semanal, v_diario, v_bruto, coalesce(p_aplicar_imss, false), v_imss, v_neto,
    nullif(trim(p_folio_spei), ''),
    nullif(trim(p_clave_rastreo), ''),
    nullif(v_banco, ''),
    now(),
    nullif(trim(p_notas), ''),
    v_actor
  )
  returning id into v_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'rh_pago_semana', 'rh_pagos_semana', v_id::text,
      jsonb_build_object(
        'empleado_id', p_empleado_id,
        'semana', v_sabado,
        'dias', v_dias,
        'neto', v_neto,
        'imss', coalesce(p_aplicar_imss, false)
      )
    );
  exception when others then null;
  end;

  return public.rh_semana_empleado(p_session_token, p_empleado_id, v_sabado);
end;
$$;

grant execute on function public.rh_registrar_pago(uuid, bigint, date, date, boolean, text, text, text)
  to anon, authenticated;

revoke all on function public.fn_rh_sabado_semana(date) from public, anon, authenticated;

notify pgrst, 'reload schema';

commit;
