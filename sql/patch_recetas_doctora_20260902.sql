-- =============================================================================
-- FARMACAPITAL — Receta de consultorio (perfil DOCTORA)
-- Fecha: 2026-09-02
-- CORRE ESTE ARCHIVO (reemplaza al 20260901, que chocaba con public.recetas).
--
-- Por qué falló el anterior:
--   public.recetas YA EXISTE (bitácora POS / COFEPRIS) y NO tiene columna "estado".
--   CREATE TABLE IF NOT EXISTS no hizo nada → el índice sobre estado tronó (42703).
--
-- Este parche usa public.recetas_consultorio y NO toca public.recetas.
-- Idempotente. Correr entero en Supabase SQL Editor.
-- =============================================================================

begin;

alter table public.medicos
  add column if not exists institucion text;

alter table public.citas
  add column if not exists receta_id bigint,
  add column if not exists seguimiento_dias integer,
  add column if not exists seguimiento_nota text,
  add column if not exists seguimiento_fecha date;

comment on column public.citas.seguimiento_dias is
  'Días sugeridos para la próxima visita (C1). No agenda sola: solo recordatorio clínico.';
comment on column public.citas.seguimiento_fecha is
  'Fecha calculada = fecha de consulta + seguimiento_dias.';

create sequence if not exists public.receta_folio_seq;

create or replace function public.fn_siguiente_folio_receta()
returns text
language plpgsql
as $$
declare
  v_n bigint;
begin
  v_n := nextval('public.receta_folio_seq');
  return 'FC-RX-' || to_char(now(), 'YYYY') || '-' || lpad(v_n::text, 6, '0');
end;
$$;

create table if not exists public.recetas_consultorio (
  id                   bigserial primary key,
  folio                text not null unique,
  cita_id              bigint references public.citas(id) on delete set null,
  medico_id            bigint,
  medico_nombre        text not null,
  medico_cedula        text not null,
  medico_especialidad  text,
  medico_institucion   text,
  paciente_nombre      text,
  paciente_telefono    text,
  paciente_edad        text,
  paciente_sexo        text,
  diagnostico          text,
  notas                text,
  alergias_snapshot    text,
  medicamentos         jsonb not null default '[]'::jsonb,
  firma_modo           text not null default 'fisica',
  firma_data_url       text,
  estado               text not null default 'en_caja',
  seguimiento_dias     integer,
  seguimiento_nota     text,
  seguimiento_fecha    date,
  created_at           timestamptz not null default now(),
  impresa_at           timestamptz,
  surtida_at           timestamptz,
  pedido_surtido_id    bigint
);

create index if not exists recetas_consultorio_estado_idx
  on public.recetas_consultorio (estado, created_at desc);
create index if not exists recetas_consultorio_cita_idx
  on public.recetas_consultorio (cita_id);

comment on table public.recetas_consultorio is
  'Receta ordinaria del consultorio. Folio único. Cola POS: en_caja → impresa → surtida. Distinta de public.recetas (COFEPRIS/POS).';
comment on column public.recetas_consultorio.estado is
  'en_caja | impresa | surtida | cancelada';

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'citas_receta_consultorio_id_fkey'
  ) then
    alter table public.citas
      add constraint citas_receta_consultorio_id_fkey
      foreign key (receta_id) references public.recetas_consultorio(id) on delete set null;
  end if;
end $$;

alter table public.recetas_consultorio enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'recetas_consultorio'
      and policyname = 'recetas_consultorio_sin_acceso_directo'
  ) then
    create policy recetas_consultorio_sin_acceso_directo on public.recetas_consultorio
      for all using (false) with check (false);
  end if;
end $$;

revoke all on table public.recetas_consultorio from anon, authenticated;
grant usage, select on sequence public.receta_folio_seq to authenticated;
grant usage, select on sequence public.recetas_consultorio_id_seq to authenticated;

create or replace function public.empleado_emitir_receta(
  p_session_token uuid,
  p_cita_id       bigint,
  p_payload       jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor        bigint;
  v_cita         record;
  v_folio        text;
  v_id           bigint;
  v_nombre       text;
  v_cedula       text;
  v_meds         jsonb;
  v_firma_modo   text;
  v_dias         int;
  v_seg_fecha    date;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  select * into v_cita from public.citas where id = p_cita_id;
  if v_cita.id is null then
    return jsonb_build_object('success', false, 'error', 'Cita no encontrada');
  end if;

  v_nombre := nullif(trim(coalesce(p_payload->>'medico_nombre', '')), '');
  v_cedula := nullif(trim(coalesce(p_payload->>'medico_cedula', '')), '');
  if v_nombre is null then
    return jsonb_build_object('success', false, 'error', 'Falta el nombre del médico que prescribe.');
  end if;
  if v_cedula is null then
    return jsonb_build_object('success', false, 'error', 'Falta la cédula profesional (obligatoria en México).');
  end if;

  v_meds := coalesce(p_payload->'medicamentos', '[]'::jsonb);
  if jsonb_typeof(v_meds) <> 'array' or jsonb_array_length(v_meds) < 1 then
    return jsonb_build_object('success', false, 'error', 'Agrega al menos un medicamento.');
  end if;

  if coalesce(trim(coalesce(p_payload->>'diagnostico', v_cita.diagnostico, '')), '') = '' then
    return jsonb_build_object('success', false, 'error', 'Captura el diagnóstico antes de emitir la receta.');
  end if;

  v_firma_modo := case when p_payload->>'firma_modo' = 'digital' then 'digital' else 'fisica' end;
  if v_firma_modo = 'digital' and coalesce(trim(p_payload->>'firma_data_url'), '') = '' then
    return jsonb_build_object('success', false, 'error', 'Falta la firma digital o elige firma física.');
  end if;

  v_dias := nullif(p_payload->>'seguimiento_dias', '')::int;
  if v_dias is not null and v_dias > 0 then
    v_seg_fecha := coalesce(v_cita.fecha, current_date) + v_dias;
  end if;

  v_folio := public.fn_siguiente_folio_receta();

  insert into public.recetas_consultorio (
    folio, cita_id, medico_id, medico_nombre, medico_cedula,
    medico_especialidad, medico_institucion,
    paciente_nombre, paciente_telefono, paciente_edad, paciente_sexo,
    diagnostico, notas, alergias_snapshot, medicamentos,
    firma_modo, firma_data_url, estado,
    seguimiento_dias, seguimiento_nota, seguimiento_fecha
  ) values (
    v_folio,
    p_cita_id,
    nullif(p_payload->>'medico_id', '')::bigint,
    v_nombre,
    v_cedula,
    nullif(trim(coalesce(p_payload->>'medico_especialidad', '')), ''),
    nullif(trim(coalesce(p_payload->>'medico_institucion', '')), ''),
    coalesce(v_cita.nombre, p_payload->>'paciente_nombre'),
    coalesce(v_cita.telefono, p_payload->>'paciente_telefono'),
    nullif(trim(coalesce(p_payload->>'paciente_edad', '')), ''),
    nullif(trim(coalesce(p_payload->>'paciente_sexo', '')), ''),
    coalesce(nullif(trim(p_payload->>'diagnostico'), ''), v_cita.diagnostico),
    nullif(trim(coalesce(p_payload->>'notas', '')), ''),
    nullif(trim(coalesce(p_payload->>'alergias_snapshot', '')), ''),
    v_meds,
    v_firma_modo,
    nullif(p_payload->>'firma_data_url', ''),
    'en_caja',
    v_dias,
    nullif(trim(coalesce(p_payload->>'seguimiento_nota', '')), ''),
    v_seg_fecha
  )
  returning id into v_id;

  update public.citas set
    receta_id = v_id,
    medicamentos_prescritos = v_meds,
    diagnostico = coalesce(nullif(trim(p_payload->>'diagnostico'), ''), diagnostico),
    seguimiento_dias = coalesce(v_dias, seguimiento_dias),
    seguimiento_nota = coalesce(nullif(trim(coalesce(p_payload->>'seguimiento_nota', '')), ''), seguimiento_nota),
    seguimiento_fecha = coalesce(v_seg_fecha, seguimiento_fecha)
  where id = p_cita_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'emitir_receta', 'recetas_consultorio', v_id::text,
      jsonb_build_object('folio', v_folio, 'cita_id', p_cita_id)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'receta_id', v_id,
    'folio', v_folio,
    'estado', 'en_caja',
    'seguimiento_fecha', v_seg_fecha
  );
end;
$$;

create or replace function public.empleado_listar_recetas_por_surtir(
  p_session_token uuid,
  p_desde         date default (current_date - 2),
  p_hasta         date default current_date
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
    select jsonb_agg(to_jsonb(r) order by r.created_at desc)
    from public.recetas_consultorio r
    where r.estado in ('en_caja', 'impresa')
      and (r.created_at)::date >= coalesce(p_desde, current_date - 2)
      and (r.created_at)::date <= coalesce(p_hasta, current_date)
  ), '[]'::jsonb);
end;
$$;

create or replace function public.empleado_marcar_receta_impresa(
  p_session_token uuid,
  p_receta_id     bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_row   record;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select id, estado into v_row from public.recetas_consultorio where id = p_receta_id;
  if v_row.id is null then
    return jsonb_build_object('success', false, 'error', 'Receta no encontrada');
  end if;
  update public.recetas_consultorio
    set estado = case when estado = 'surtida' then estado else 'impresa' end,
        impresa_at = coalesce(impresa_at, now())
    where id = p_receta_id;
  return jsonb_build_object('success', true, 'estado', 'impresa');
end;
$$;

create or replace function public.empleado_marcar_receta_surtida(
  p_session_token uuid,
  p_receta_id     bigint,
  p_pedido_id     bigint default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_row   record;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select id into v_row from public.recetas_consultorio where id = p_receta_id;
  if v_row.id is null then
    return jsonb_build_object('success', false, 'error', 'Receta no encontrada');
  end if;
  update public.recetas_consultorio
    set estado = 'surtida',
        surtida_at = now(),
        pedido_surtido_id = coalesce(p_pedido_id, pedido_surtido_id)
    where id = p_receta_id;
  return jsonb_build_object('success', true, 'estado', 'surtida');
end;
$$;

create or replace function public.empleado_guardar_seguimiento_cita(
  p_session_token uuid,
  p_cita_id       bigint,
  p_dias          integer,
  p_nota          text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy     bigint;
  v_cita      record;
  v_seg_fecha date;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select id, fecha into v_cita from public.citas where id = p_cita_id;
  if v_cita.id is null then
    return jsonb_build_object('success', false, 'error', 'Cita no encontrada');
  end if;
  if p_dias is not null and p_dias > 0 then
    v_seg_fecha := coalesce(v_cita.fecha, current_date) + p_dias;
  else
    v_seg_fecha := null;
  end if;
  update public.citas set
    seguimiento_dias = p_dias,
    seguimiento_nota = nullif(trim(coalesce(p_nota, '')), ''),
    seguimiento_fecha = v_seg_fecha
  where id = p_cita_id;
  return jsonb_build_object('success', true, 'seguimiento_fecha', v_seg_fecha, 'seguimiento_dias', p_dias);
end;
$$;

grant execute on function public.fn_siguiente_folio_receta() to anon, authenticated;
grant execute on function public.empleado_emitir_receta(uuid, bigint, jsonb) to anon, authenticated;
grant execute on function public.empleado_listar_recetas_por_surtir(uuid, date, date) to anon, authenticated;
grant execute on function public.empleado_marcar_receta_impresa(uuid, bigint) to anon, authenticated;
grant execute on function public.empleado_marcar_receta_surtida(uuid, bigint, bigint) to anon, authenticated;
grant execute on function public.empleado_guardar_seguimiento_cita(uuid, bigint, integer, text) to anon, authenticated;

commit;
