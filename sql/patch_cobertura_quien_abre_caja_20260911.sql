-- FarmaCapital — 11-sep-2026
-- Cobertura sin pedir permiso a RH:
--   Quien entra, abre caja y corta, trabaja ESE turno.
--   El perfil (matutino/vespertino) es la costumbre de la semana, no un candado.
--
-- Caso de hoy: vendedora vespertina cubre también la mañana.
-- Antes: en la mañana el sistema le ofrece abrir MATUTINO; al corte puede
-- abrir VESPERTINO. Mi Día suma metas de los turnos que sí abrió.
--
-- Idempotente. Pegar en Supabase SQL Editor.

begin;

-- Turno que puede abrir AHORA = el del reloj / la cadena del día,
-- no solo el del perfil. Así cubre sin marcar descanso de la compañera.
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
  if public.fn_es_descanso_hoy(p_user_id) then
    return null;
  end if;

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

  -- Ya hizo los dos (cobertura completa o doble jornada).
  if v_ya_mat and v_ya_vesp then
    return null;
  end if;

  -- Cadena del mismo día: cortó uno → le toca el otro (cubre ambos de facto).
  if v_ya_mat and not v_ya_vesp then
    return 'vespertino';
  end if;
  if v_ya_vesp and not v_ya_mat then
    return 'matutino';
  end if;

  -- Primera apertura del día: manda el reloj (quien está, abre).
  -- Vespertina a las 9:00 → matutino. Matutina a las 16:00 → vespertino.
  return v_reloj;
end;
$$;

grant execute on function public.fn_turno_abrir_hoy(bigint) to anon, authenticated;

-- Jornada: exponer qué turnos ya abrió hoy + si está en cobertura.
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

  -- Cobertura puntual: abrió / le ofrecen un turno ≠ habitual.
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

  -- Ambos turnos: RH lo marcó, o ya encadenó los dos hoy.
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
      and not v_descanso
      and jsonb_array_length(v_turnos) >= 1
    )
  );
end;
$$;

grant execute on function public.empleado_jornada_hoy(uuid) to anon, authenticated;

commit;

-- Después de pegar: que la vendedora cierre sesión, vuelva a entrar,
-- abra caja (si está en la mañana le debe ofrecer MATUTINO aunque su
-- perfil sea vespertino) y revise Mi Día.
