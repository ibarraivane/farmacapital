-- RH: nómina semanal martes–viernes. Sin IMSS/ISR por defecto.
-- Erika esta semana: $1,133.32 (SPEI folio 6349011488).
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.

begin;

-- ── Columnas en ficha ───────────────────────────────────────────────────────

alter table public.empleados
  add column if not exists salario_semanal numeric(12,2) not null default 0;

alter table public.empleados
  add column if not exists banco text;

alter table public.empleados
  add column if not exists cuenta_mascara text;

comment on column public.empleados.salario_semanal is
  'Pago de una semana completa martes–viernes. Diario = este monto / 4.';

-- Erika (usuario 10). Mary se deja en 0: no inventar su semanal.
update public.empleados
   set salario_semanal = 1133.32,
       banco = coalesce(nullif(banco, ''), 'Azteca'),
       cuenta_mascara = coalesce(nullif(cuenta_mascara, ''), '·8003')
 where usuario_id = 10
   and salario_semanal = 0;


-- ── Bitácora por día ────────────────────────────────────────────────────────

create table if not exists public.rh_asistencia (
  id          bigserial primary key,
  empleado_id bigint not null references public.empleados(id) on delete cascade,
  fecha       date not null,
  estado      text not null check (estado in ('trabajo', 'falta', 'descanso')),
  origen      text not null default 'manual' check (origen in ('manual', 'caja')),
  notas       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (empleado_id, fecha)
);

create index if not exists rh_asistencia_emp_fecha_idx
  on public.rh_asistencia (empleado_id, fecha);

comment on table public.rh_asistencia is
  'Día trabajado / falta / descanso. Sirve para pagar el viernes o liquidar a hoy.';

alter table public.rh_asistencia enable row level security;
revoke all on public.rh_asistencia from anon, authenticated;


-- ── Pagos de la semana ──────────────────────────────────────────────────────

create table if not exists public.rh_pagos_semana (
  id               bigserial primary key,
  empleado_id      bigint not null references public.empleados(id) on delete cascade,
  semana_inicio    date not null,
  semana_fin       date not null,
  dias_pagados     integer not null,
  salario_semanal  numeric(12,2) not null,
  diario           numeric(12,2) not null,
  bruto            numeric(12,2) not null,
  aplicar_imss     boolean not null default false,
  imss_monto       numeric(12,2) not null default 0,
  neto             numeric(12,2) not null,
  folio_spei       text,
  clave_rastreo    text,
  banco_origen     text,
  banco_destino    text,
  pagado_en        timestamptz,
  notas            text,
  created_by       bigint references public.usuarios(id) on delete set null,
  created_at       timestamptz not null default now(),
  unique (empleado_id, semana_inicio)
);

create index if not exists rh_pagos_semana_emp_idx
  on public.rh_pagos_semana (empleado_id, semana_inicio desc);

comment on table public.rh_pagos_semana is
  'Pago de la semana martes–viernes. Un registro por empleado y martes.';

alter table public.rh_pagos_semana enable row level security;
revoke all on public.rh_pagos_semana from anon, authenticated;


-- ── Helpers ─────────────────────────────────────────────────────────────────

create or replace function public.fn_rh_martes_semana(p_fecha date)
returns date
language sql
immutable
as $$
  select p_fecha - (
    case extract(dow from p_fecha)::int
      when 0 then 5
      when 1 then 6
      when 2 then 0
      when 3 then 1
      when 4 then 2
      when 5 then 3
      else 4
    end
  );
$$;

create or replace function public.fn_rh_hoy_mexico()
returns date
language sql
stable
as $$
  select (timezone('America/Mexico_City', now()))::date;
$$;


-- ── Semana de un empleado ───────────────────────────────────────────────────

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
  v_martes  date;
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
  v_martes  := public.fn_rh_martes_semana(v_fecha);
  v_viernes := v_martes + 3;
  v_hoy     := public.fn_rh_hoy_mexico();
  v_uid     := v_emp.usuario_id;
  v_semanal := coalesce(v_emp.salario_semanal, 0);
  v_diario  := round(v_semanal / 4.0, 2);

  if v_uid is not null then
    insert into public.rh_asistencia (empleado_id, fecha, estado, origen)
    select p_empleado_id, cs.fecha, 'trabajo', 'caja'
      from public.caja_sesiones cs
     where cs.empleado_id = v_uid
       and cs.fecha between v_martes and v_viernes
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
        from generate_series(v_martes::timestamp, v_viernes::timestamp, interval '1 day') gs
        cross join lateral (select gs::date as fecha) d
        left join public.rh_asistencia a
          on a.empleado_id = p_empleado_id and a.fecha = d.fecha
    ) q;

  select count(*)::int into v_trabajo
    from public.rh_asistencia
   where empleado_id = p_empleado_id
     and fecha between v_martes and v_viernes
     and estado = 'trabajo';

  select count(*)::int into v_hasta
    from public.rh_asistencia
   where empleado_id = p_empleado_id
     and fecha between v_martes and least(v_hoy, v_viernes)
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
     and p.semana_inicio = v_martes;

  return jsonb_build_object(
    'empleado_id', p_empleado_id,
    'nombre', v_emp.nombre,
    'salario_semanal', v_semanal,
    'diario', v_diario,
    'semana_inicio', v_martes,
    'semana_fin', v_viernes,
    'hoy', v_hoy,
    'dias', v_dias,
    'dias_trabajo', v_trabajo,
    'dias_trabajo_hasta_hoy', v_hasta,
    'bruto', round(v_diario * v_trabajo, 2),
    'bruto_hasta_hoy', round(v_diario * v_hasta, 2),
    'pago', v_pago
  );
end;
$$;

grant execute on function public.rh_semana_empleado(uuid, bigint, date)
  to anon, authenticated;


-- ── Marcar un día ───────────────────────────────────────────────────────────

create or replace function public.rh_marcar_dia(
  p_session_token uuid,
  p_empleado_id   bigint,
  p_fecha         date,
  p_estado        text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_estado text;
begin
  perform public.fn_require_admin(p_session_token);

  if p_empleado_id is null or p_fecha is null then
    raise exception 'Empleado y fecha requeridos';
  end if;

  v_estado := lower(trim(coalesce(p_estado, '')));
  if v_estado not in ('trabajo', 'falta', 'descanso') then
    raise exception 'Estado inválido';
  end if;

  if not exists (select 1 from public.empleados where id = p_empleado_id) then
    raise exception 'Empleado no encontrado';
  end if;

  insert into public.rh_asistencia (empleado_id, fecha, estado, origen, updated_at)
  values (p_empleado_id, p_fecha, v_estado, 'manual', now())
  on conflict (empleado_id, fecha) do update
    set estado = excluded.estado,
        origen = 'manual',
        updated_at = now();

  return public.rh_semana_empleado(p_session_token, p_empleado_id, p_fecha);
end;
$$;

grant execute on function public.rh_marcar_dia(uuid, bigint, date, text)
  to anon, authenticated;


-- ── Registrar pago (viernes o liquidar a hoy) ───────────────────────────────

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
  v_martes  date;
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
  v_martes  := public.fn_rh_martes_semana(v_fecha);
  v_viernes := v_martes + 3;
  v_hasta   := least(coalesce(p_hasta, v_viernes), v_viernes);
  if v_hasta < v_martes then
    v_hasta := v_martes;
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
    raise exception 'Falta el salario semanal (martes–viernes) de este empleado';
  end if;

  v_diario := round(v_semanal / 4.0, 2);

  select count(*)::int into v_dias
    from public.rh_asistencia
   where empleado_id = p_empleado_id
     and fecha between v_martes and v_hasta
     and estado = 'trabajo';

  if v_dias <= 0 then
    raise exception 'No hay días trabajados para pagar en esta semana';
  end if;

  v_bruto := round(v_diario * v_dias, 2);
  v_imss  := case when coalesce(p_aplicar_imss, false) then round(v_bruto * 0.02375, 2) else 0 end;
  v_neto  := round(v_bruto - v_imss, 2);

  if exists (
    select 1 from public.rh_pagos_semana
     where empleado_id = p_empleado_id and semana_inicio = v_martes
  ) then
    raise exception 'Ya hay un pago registrado para esta semana';
  end if;

  insert into public.rh_pagos_semana (
    empleado_id, semana_inicio, semana_fin, dias_pagados,
    salario_semanal, diario, bruto, aplicar_imss, imss_monto, neto,
    folio_spei, clave_rastreo, banco_destino, pagado_en, notas, created_by
  ) values (
    p_empleado_id, v_martes, v_viernes, v_dias,
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
        'semana', v_martes,
        'dias', v_dias,
        'neto', v_neto,
        'imss', coalesce(p_aplicar_imss, false)
      )
    );
  exception when others then null;
  end;

  return public.rh_semana_empleado(p_session_token, p_empleado_id, v_martes);
end;
$$;

grant execute on function public.rh_registrar_pago(uuid, bigint, date, date, boolean, text, text, text)
  to anon, authenticated;


-- ── Salario semanal (ficha o panel de nómina) ───────────────────────────────

create or replace function public.rh_set_salario_semanal(
  p_session_token    uuid,
  p_empleado_id      bigint,
  p_salario_semanal  numeric
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);

  if p_empleado_id is null then
    raise exception 'Empleado requerido';
  end if;
  if p_salario_semanal is null or p_salario_semanal < 0 then
    raise exception 'Salario semanal inválido';
  end if;

  update public.empleados
     set salario_semanal = round(p_salario_semanal, 2)
   where id = p_empleado_id;
  if not found then
    raise exception 'Empleado no encontrado';
  end if;

  return jsonb_build_object('success', true, 'salario_semanal', round(p_salario_semanal, 2));
end;
$$;

grant execute on function public.rh_set_salario_semanal(uuid, bigint, numeric)
  to anon, authenticated;

revoke all on function public.fn_rh_martes_semana(date) from public, anon, authenticated;
revoke all on function public.fn_rh_hoy_mexico() from public, anon, authenticated;


-- ── Crear / editar ficha: aceptar salario_semanal ───────────────────────────

drop function if exists public.admin_actualizar_empleado(uuid, bigint, text, text, text, text, numeric);
drop function if exists public.admin_actualizar_empleado(uuid, bigint, text, text, text, text, numeric, numeric);

create or replace function public.admin_actualizar_empleado(
  p_session_token      uuid,
  p_empleado_id        bigint,
  p_nombre             text,
  p_telefono           text default null,
  p_rol                text default 'vendedor',
  p_turno              text default 'matutino',
  p_salario_quincenal  numeric default 0,
  p_salario_semanal    numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_turno text;
  v_tel   text;
  v_n     int;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_empleado_id is null then
    raise exception 'Empleado requerido';
  end if;
  if coalesce(trim(p_nombre), '') = '' then
    raise exception 'El nombre es obligatorio';
  end if;

  v_turno := lower(trim(coalesce(p_turno, 'matutino')));
  if v_turno not in ('matutino', 'vespertino') then
    raise exception 'Turno inválido';
  end if;

  v_tel := public.fn_tel_empleado(p_telefono);

  update public.empleados
     set nombre = trim(p_nombre),
         telefono = v_tel,
         rol = coalesce(nullif(trim(p_rol), ''), rol),
         turno = v_turno,
         salario_quincenal = coalesce(p_salario_quincenal, salario_quincenal),
         salario_semanal = coalesce(p_salario_semanal, salario_semanal)
   where id = p_empleado_id;

  get diagnostics v_n = row_count;
  if v_n = 0 then
    raise exception 'Empleado no encontrado';
  end if;

  begin
    perform public.fn_sync_turno_caja(null, p_empleado_id, v_turno);
  exception when others then null;
  end;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'editar_empleado', 'empleados', p_empleado_id::text,
      jsonb_build_object('nombre', p_nombre, 'turno', v_turno)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'empleado_id', p_empleado_id);
end;
$$;

grant execute on function public.admin_actualizar_empleado(uuid, bigint, text, text, text, text, numeric, numeric)
  to anon, authenticated;


drop function if exists public.admin_crear_empleado(uuid, text, text, text, text, numeric);
drop function if exists public.admin_crear_empleado(uuid, text, text, text, text, numeric, numeric);

create or replace function public.admin_crear_empleado(
  p_session_token      uuid,
  p_nombre             text,
  p_telefono           text default null,
  p_rol                text default 'vendedor',
  p_turno              text default 'matutino',
  p_salario_quincenal  numeric default 0,
  p_salario_semanal    numeric default 0
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_new_id bigint;
  v_turno text;
  v_tel text;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if coalesce(trim(p_nombre), '') = '' then
    raise exception 'El nombre es obligatorio';
  end if;

  v_turno := lower(trim(coalesce(p_turno, 'matutino')));
  if v_turno not in ('matutino', 'vespertino') then
    raise exception 'Turno inválido';
  end if;

  v_tel := public.fn_tel_empleado(p_telefono);

  insert into public.empleados(
    nombre, telefono, rol, turno, salario_quincenal, salario_semanal, estado
  ) values (
    trim(p_nombre), v_tel,
    p_rol, v_turno,
    coalesce(p_salario_quincenal, 0),
    coalesce(p_salario_semanal, 0),
    true
  )
  returning id into v_new_id;

  begin
    perform public.fn_sync_turno_caja(null, v_new_id, v_turno);
  exception when others then null;
  end;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,
            (select nombre from public.usuarios where id = v_actor),
            'crear_empleado', 'empleados', v_new_id::text,
            jsonb_build_object('nombre', p_nombre, 'rol', p_rol, 'turno', v_turno));
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'empleado_id', v_new_id);
end;
$$;

grant execute on function public.admin_crear_empleado(uuid, text, text, text, text, numeric, numeric)
  to anon, authenticated;


-- ── Semilla: semana 18–21 ago Erika, SPEI ya enviado ────────────────────────

insert into public.rh_asistencia (empleado_id, fecha, estado, origen)
select e.id, d, 'trabajo', 'caja'
  from public.empleados e
  cross join unnest(array[
    date '2026-08-18', date '2026-08-19',
    date '2026-08-20', date '2026-08-21'
  ]) as d
 where e.usuario_id = 10
on conflict (empleado_id, fecha) do nothing;

insert into public.rh_pagos_semana (
  empleado_id, semana_inicio, semana_fin, dias_pagados,
  salario_semanal, diario, bruto, aplicar_imss, imss_monto, neto,
  folio_spei, clave_rastreo, banco_origen, banco_destino,
  pagado_en, notas
)
select
  e.id,
  date '2026-08-18', date '2026-08-21', 4,
  1133.32, 283.33, 1133.32, false, 0, 1133.32,
  '6349011488',
  'MBAN01002608240099188572',
  'BBVA',
  'Azteca ·8003',
  timestamptz '2026-08-24 00:56:00-06',
  'SPEI semana 18–21 ago. Semana completa.'
from public.empleados e
where e.usuario_id = 10
on conflict (empleado_id, semana_inicio) do nothing;

notify pgrst, 'reload schema';

commit;
