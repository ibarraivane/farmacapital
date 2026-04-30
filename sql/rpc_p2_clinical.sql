-- ============================================================
-- FARMAX — P2: Lecturas clínicas / agenda / badge cortes vía RPC
-- ============================================================
-- Ejecutar en Supabase después de refactor_fase6b_rpcs_auth.sql
-- (requiere public.fn_require_empleado).
-- ============================================================

begin;

-- ── Consultorio: cita activa en sala ──────────────────────────────────────────

create or replace function public.empleado_obtener_cita_en_consulta_hoy(
  p_session_token uuid,
  p_fecha date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_row jsonb;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select to_jsonb(c) into v_row
  from public.citas c
  where (c.estado)::text = 'en_consulta'
    and (c.fecha)::date = p_fecha
  limit 1;
  return v_row;
end;
$$;


create or replace function public.empleado_listar_citas_previas_completadas(
  p_session_token uuid,
  p_telefono text,
  p_limite int default 5
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_lim int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limite, 5), 20));
  return coalesce((
    select jsonb_agg(to_jsonb(t) order by t.fecha desc, t.created_at desc nulls last)
    from (
      select *
      from public.citas c
      where trim(coalesce(c.telefono, '')) = trim(coalesce(p_telefono, ''))
        and (c.estado)::text = 'completada'
      order by c.fecha desc, c.created_at desc nulls last
      limit v_lim
    ) t
  ), '[]'::jsonb);
end;
$$;


-- ── Catálogo consultorio ────────────────────────────────────────────────────

create or replace function public.empleado_listar_procedimientos_medicos(
  p_session_token uuid,
  p_solo_activos boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  return coalesce((
    select jsonb_agg(to_jsonb(p) order by p.nombre nulls last)
    from public.procedimientos_medicos p
    where not p_solo_activos or coalesce(p.activo, true)
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_listar_medicos_consultorio(
  p_session_token uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  return coalesce((
    select jsonb_agg(to_jsonb(m) order by m.nombre nulls last)
    from public.medicos m
  ), '[]'::jsonb);
end;
$$;


-- ── Agenda (rango mensual / KPI / slot / una fila) ────────────────────────────

create or replace function public.empleado_agenda_listar_citas_rango_fecha(
  p_session_token uuid,
  p_fecha_desde date,
  p_fecha_hasta date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  return coalesce((
    select jsonb_agg(to_jsonb(c) order by c.fecha, c.hora nulls last)
    from public.citas c
    where (c.fecha)::date >= p_fecha_desde
      and (c.fecha)::date <= p_fecha_hasta
      and (c.estado)::text <> 'cancelada'
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_agenda_kpi_citas_periodo(
  p_session_token uuid,
  p_fecha_desde date,
  p_fecha_hasta date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'id', c.id,
        'estado', c.estado,
        'ingreso_doctor', c.ingreso_doctor,
        'duracion_consulta_segundos', c.duracion_consulta_segundos,
        'procedimientos_realizados', c.procedimientos_realizados,
        'medicamentos_prescritos', c.medicamentos_prescritos,
        'fecha', c.fecha
      )
      order by c.fecha, c.id
    )
    from public.citas c
    where (c.fecha)::date >= p_fecha_desde
      and (c.fecha)::date <= p_fecha_hasta
      and (c.estado)::text <> 'cancelada'
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_obtener_cita_agenda_por_id(
  p_session_token uuid,
  p_cita_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_row jsonb;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select to_jsonb(c) into v_row
  from public.citas c
  where c.id = p_cita_id
  limit 1;
  return v_row;
end;
$$;


create or replace function public.empleado_agenda_contar_slot_ocupado(
  p_session_token uuid,
  p_fecha date,
  p_hora text
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_n int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::int into v_n
  from public.citas c
  where (c.fecha)::date = p_fecha
    and (
      trim(both from coalesce(c.hora::text, '')) = trim(both from coalesce(p_hora, ''))
      or left(trim(both from coalesce(c.hora::text, '')), 5) = left(trim(both from coalesce(p_hora, '')), 5)
    )
    and (c.estado)::text <> 'cancelada';
  return coalesce(v_n, 0);
end;
$$;


-- ── Badge sidebar: cortes con diferencia ────────────────────────────────────

create or replace function public.empleado_contar_cortes_con_diferencia(
  p_session_token uuid
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_n int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::int into v_n
  from public.cortes_caja cc
  where cc.diferencia is not null
    and cc.diferencia <> 0;
  return coalesce(v_n, 0);
end;
$$;


grant execute on function public.empleado_obtener_cita_en_consulta_hoy(uuid, date) to anon, authenticated;
grant execute on function public.empleado_listar_citas_previas_completadas(uuid, text, int) to anon, authenticated;
grant execute on function public.empleado_listar_procedimientos_medicos(uuid, boolean) to anon, authenticated;
grant execute on function public.empleado_listar_medicos_consultorio(uuid) to anon, authenticated;
grant execute on function public.empleado_agenda_listar_citas_rango_fecha(uuid, date, date) to anon, authenticated;
grant execute on function public.empleado_agenda_kpi_citas_periodo(uuid, date, date) to anon, authenticated;
grant execute on function public.empleado_obtener_cita_agenda_por_id(uuid, bigint) to anon, authenticated;
grant execute on function public.empleado_agenda_contar_slot_ocupado(uuid, date, text) to anon, authenticated;
grant execute on function public.empleado_contar_cortes_con_diferencia(uuid) to anon, authenticated;

commit;
