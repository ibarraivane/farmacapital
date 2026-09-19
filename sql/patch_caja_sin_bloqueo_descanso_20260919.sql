-- El dia de descanso ya no impide abrir caja.
-- Los dias libres cambian: el plan de RH se queda, pero no bloquea al vendedor.
-- Pegar TODO en Supabase SQL Editor y Run.
-- Sigue haciendo falta tener turno (matutino o vespertino).
-- Si ya cerro los dos turnos de hoy, tampoco reabre.

begin;

create or replace function public.fn_turno_abrir_hoy(p_user_id bigint)
returns text
language plpgsql
volatile
set search_path = public, pg_temp
as $$
declare
  v_asignado text;
  v_ahora    timestamp;
  v_minutos  int;
  v_fecha    date;
  v_ya_mat   boolean;
  v_ya_vesp  boolean;
  v_reloj    text;
begin
  -- Sigue haciendo falta tener algún turno en RH (mat o vesp), pero ya no
  -- obliga a abrir solo ese.
  v_asignado := public.fn_turno_caja_de(p_user_id);
  if v_asignado is null then
    return null;
  end if;

  v_ahora   := now() at time zone 'America/Mexico_City';
  v_fecha   := v_ahora::date;
  v_minutos := (extract(hour from v_ahora)::int * 60)
             + extract(minute from v_ahora)::int;
  v_reloj   := case
                 when v_minutos < (15 * 60 + 30) then 'matutino'
                 else 'vespertino'
               end;

  v_ya_mat  := public.fn_empleado_ya_tuvo_turno_hoy(p_user_id, 'matutino',   v_fecha);
  v_ya_vesp := public.fn_empleado_ya_tuvo_turno_hoy(p_user_id, 'vespertino', v_fecha);

  if v_ya_mat and v_ya_vesp then
    return null;
  end if;

  -- Cadena del mismo día: cortó uno → le toca el otro.
  if v_ya_mat and not v_ya_vesp then
    return 'vespertino';
  end if;
  if v_ya_vesp and not v_ya_mat then
    return 'matutino';
  end if;

  -- Primera apertura del día: manda el reloj.
  -- Vespertina a las 9:00 → matutino. Matutina a las 16:00 → vespertino.
  return v_reloj;
end;
$$;

grant execute on function public.fn_turno_abrir_hoy(bigint) to anon, authenticated;

create or replace function public.empleado_jornada_hoy(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id        bigint;
  v_descanso       boolean;
  v_ambos_rh       boolean;
  v_ambos_efectivo boolean;
  v_abrir          text;
  v_habitual       text;
  v_fecha          date;
  v_corte          record;
  v_ocupada        text;
  v_turnos         jsonb;
  v_cobertura      boolean;
begin
  v_user_id  := public.fn_require_empleado(p_session_token);
  v_descanso := coalesce(public.fn_es_descanso_hoy(v_user_id), false);
  v_ambos_rh := coalesce(public.fn_cubre_ambos_hoy(v_user_id), false);
  v_abrir    := public.fn_turno_abrir_hoy(v_user_id);
  v_habitual := public.fn_turno_caja_de(v_user_id);
  v_fecha    := (now() at time zone 'America/Mexico_City')::date;

  select coalesce(
    (
      select jsonb_agg(t.turno order by t.turno)
      from (
        select distinct s.turno
        from public.caja_sesiones s
        where s.empleado_id = v_user_id
          and s.fecha = v_fecha
          and s.turno in ('matutino', 'vespertino')
      ) t
    ),
    '[]'::jsonb
  ) into v_turnos;

  v_cobertura := (v_abrir is not null and v_habitual is not null and v_abrir is distinct from v_habitual)
    or (
      v_habitual is not null
      and jsonb_array_length(v_turnos) >= 1
      and not exists (
        select 1
        from jsonb_array_elements_text(v_turnos) x(turno)
        where x.turno = v_habitual
      )
    );

  v_ambos_efectivo := v_ambos_rh or jsonb_array_length(v_turnos) > 1;

  select cc.id, cc.turno,
         to_char(cc.created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora
    into v_corte
  from public.cortes_caja cc
  where cc.empleado_id = v_user_id
    and cc.anulado_at is null
    and ((cc.created_at at time zone 'America/Mexico_City')::date) = v_fecha
  order by cc.created_at desc
  limit 1;

  select u.nombre into v_ocupada
  from public.caja_sesiones s
  join public.usuarios u on u.id = s.empleado_id
  where s.estado = 'abierta'
    and s.empleado_id <> v_user_id
  limit 1;

  return jsonb_build_object(
    'dia_idx_hoy',      public.fn_dia_idx_cdmx(),
    'dia_descanso',     (select dia_descanso from public.usuarios where id = v_user_id),
    'es_descanso',      v_descanso,
    'cubre_ambos',      v_ambos_efectivo,
    'cobertura',        (v_cobertura or v_ambos_efectivo),
    'turno_habitual',   v_habitual,
    'turno_abrir',      v_abrir,
    'turnos_hoy',       v_turnos,
    'caja_ocupada_por', v_ocupada,
    'mi_corte_id',      v_corte.id,
    'mi_corte_turno',   v_corte.turno,
    'mi_corte_hora',    v_corte.hora,
    'ya_cerro_turno',   (
      v_abrir is null
      and jsonb_array_length(v_turnos) >= 1
    )
  );
end;
$$;

grant execute on function public.empleado_jornada_hoy(uuid) to anon, authenticated;

create or replace function public.abrir_sesion_caja(
  p_session_token uuid,
  p_denominaciones jsonb,
  p_nota text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
  v_nombre text;
  v_ahora timestamp;
  v_minutos int;
  v_turno text;
  v_asignado text;
  v_fondo numeric;
  v_id bigint;
  v_ocupada text;
  v_hora text;
  v_sesion public.caja_sesiones%rowtype;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol, nombre into v_rol, v_nombre from public.usuarios where id = v_user_id;

  -- Ya la tiene abierta: reanudar, no volver a contar el fondo.
  select * into v_sesion
  from public.caja_sesiones
  where empleado_id = v_user_id and estado = 'abierta'
  limit 1;
  if v_sesion.id is not null then
    return jsonb_build_object(
      'success', true, 'abierta', true, 'reanudada', true,
      'id', v_sesion.id, 'turno', v_sesion.turno,
      'fondo_contado', v_sesion.fondo_contado,
      'abierta_at', v_sesion.abierta_at,
      'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id)
    );
  end if;

  -- El cajón es uno solo.
  select u.nombre into v_ocupada
  from public.caja_sesiones s
  join public.usuarios u on u.id = s.empleado_id
  where s.estado = 'abierta'
  limit 1;
  if v_ocupada is not null then
    return jsonb_build_object(
      'success', false,
      'motivo', 'caja_ocupada',
      'error', format('%s todavía tiene la caja abierta. En cuanto haga su corte, abres la tuya.', v_ocupada)
    );
  end if;

  v_ahora   := now() at time zone 'America/Mexico_City';
  v_minutos := (extract(hour from v_ahora)::int * 60) + extract(minute from v_ahora)::int;
  v_asignado := public.fn_turno_caja_de(v_user_id);

  if coalesce(v_rol, '') = 'vendedor' then
    if v_asignado is null then
      return jsonb_build_object(
        'success', false, 'motivo', 'sin_turno',
        'error', 'RH debe asignarte un turno (matutino o vespertino) antes de abrir caja.'
      );
    end if;

    v_turno := public.fn_turno_abrir_hoy(v_user_id);

    if v_turno is null then
      select to_char(cc.created_at at time zone 'America/Mexico_City', 'HH24:MI')
        into v_hora
      from public.cortes_caja cc
      where cc.empleado_id = v_user_id
        and cc.anulado_at is null
        and ((cc.created_at at time zone 'America/Mexico_City')::date) = v_ahora::date
      order by cc.created_at desc
      limit 1;

      return jsonb_build_object(
        'success', false,
        'motivo', 'ya_cerro',
        'error', case
          when v_hora is not null then
            format('Ya cerraste tu turno de hoy: hiciste el corte a las %s. Si fue por error, pide a gerencia que lo anule.', v_hora)
          else
            'Ya cerraste tu turno de hoy. Si fue por error, pide a gerencia que anule el corte.'
        end
      );
    end if;
  else
    v_turno := coalesce(
      public.fn_turno_abrir_hoy(v_user_id),
      v_asignado,
      case when v_minutos < (15 * 60 + 30) then 'matutino' else 'vespertino' end
    );
  end if;

  v_fondo := public.fn_sumar_denominaciones(p_denominaciones);

  insert into public.caja_sesiones (
    empleado_id, turno, fecha, fondo_contado, denominaciones, nota_apertura, abierta_at, estado
  ) values (
    v_user_id, v_turno, v_ahora::date, v_fondo,
    coalesce(p_denominaciones, '{}'::jsonb),
    nullif(btrim(coalesce(p_nota, '')), ''),
    now(), 'abierta'
  ) returning id into v_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_user_id, v_nombre, 'abrir_caja', 'caja_sesiones', v_id::text,
      jsonb_build_object('turno', v_turno, 'fondo', v_fondo,
                         'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id)));
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true, 'abierta', true, 'reanudada', false,
    'id', v_id, 'turno', v_turno, 'fondo_contado', v_fondo,
    'abierta_at', now(),
    'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id)
  );
end;
$$;

grant execute on function public.abrir_sesion_caja(uuid, jsonb, text) to anon, authenticated;

commit;
