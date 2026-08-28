-- Compensación Mercado Pago en recargas / pago de servicios.
-- MP publica 1% acreditado en tu saldo (no en el cajón) al completar la recarga.
-- Ejecutar en Supabase SQL Editor. Idempotente.

begin;

alter table public.pagos_servicio
  add column if not exists compensacion_mp numeric(12, 2) not null default 0
    check (compensacion_mp >= 0);

alter table public.pagos_servicio
  add column if not exists costo_liquidacion numeric(12, 2);

alter table public.pagos_servicio
  add column if not exists fuente_liquidacion text;

alter table public.pagos_servicio
  add column if not exists referencia_externa text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'pagos_servicio_fuente_liquidacion_chk'
      and conrelid = 'public.pagos_servicio'::regclass
  ) then
    alter table public.pagos_servicio
      add constraint pagos_servicio_fuente_liquidacion_chk
      check (fuente_liquidacion is null or fuente_liquidacion in ('saldo_mp', 'point_launcher', 'otro'));
  end if;
end
$$;

-- Histórico: 1% oficial. El débito de Actividad es el monto bruto.
update public.pagos_servicio
set
  compensacion_mp = round(monto_servicio * 0.01, 2),
  costo_liquidacion = coalesce(costo_liquidacion, monto_servicio),
  fuente_liquidacion = coalesce(fuente_liquidacion, 'saldo_mp')
where compensacion_mp = 0
   or costo_liquidacion is null
   or fuente_liquidacion is null;

create or replace function public.registrar_pago_servicio_pos(
  p_session_token    uuid,
  p_proveedor        text,
  p_categoria        text,
  p_referencia       text,
  p_monto_servicio   numeric,
  p_comision         numeric,
  p_metodo_pago      text,
  p_liquidado_point  boolean default false,
  p_notas            text default null,
  p_cliente_id       bigint default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_id bigint;
  v_folio text;
  v_monto numeric;
  v_com numeric;
  v_total numeric;
  v_metodo text;
  v_comp numeric;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if coalesce(btrim(p_proveedor), '') = '' then
    raise exception 'Proveedor requerido';
  end if;
  if coalesce(btrim(p_categoria), '') = '' then
    raise exception 'Categoría requerida';
  end if;

  v_monto := round(coalesce(p_monto_servicio, 0)::numeric, 2);
  v_com := round(coalesce(p_comision, 0)::numeric, 2);
  if v_monto <= 0 then
    raise exception 'Monto del servicio debe ser mayor a 0';
  end if;
  if v_com < 0 then
    raise exception 'Comisión inválida';
  end if;

  v_total := round(v_monto + v_com, 2);
  v_comp := round(v_monto * 0.01, 2);
  v_metodo := lower(btrim(coalesce(p_metodo_pago, '')));
  if v_metodo not in ('efectivo', 'tarjeta') then
    raise exception 'metodo_pago inválido (efectivo o tarjeta)';
  end if;

  if p_cliente_id is not null and not exists (
    select 1 from public.clientes c where c.id = p_cliente_id and c.eliminado_at is null
  ) then
    raise exception 'Cliente no encontrado';
  end if;

  insert into public.pagos_servicio (
    folio, categoria, proveedor, referencia,
    monto_servicio, comision, total_cobrado, metodo_pago,
    liquidado_point, notas, cliente_id, atendido_por,
    compensacion_mp, costo_liquidacion, fuente_liquidacion
  ) values (
    'PENDING',
    lower(btrim(p_categoria)),
    btrim(p_proveedor),
    nullif(btrim(coalesce(p_referencia, '')), ''),
    v_monto,
    v_com,
    v_total,
    v_metodo,
    coalesce(p_liquidado_point, false),
    nullif(btrim(coalesce(p_notas, '')), ''),
    p_cliente_id,
    v_actor,
    v_comp,
    v_monto,
    'saldo_mp'
  )
  returning id into v_id;

  v_folio := 'SRV-' || to_char(now() at time zone 'America/Mexico_City', 'YYYYMMDD') || '-' || lpad(v_id::text, 6, '0');
  update public.pagos_servicio set folio = v_folio where id = v_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'pago_servicio_pos',
      'pagos_servicio',
      v_id::text,
      jsonb_build_object(
        'folio', v_folio,
        'proveedor', p_proveedor,
        'total', v_total,
        'metodo', v_metodo,
        'compensacion_mp', v_comp
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'id', v_id,
    'folio', v_folio,
    'total_cobrado', v_total,
    'comision', v_com,
    'compensacion_mp', v_comp
  );
end;
$$;

grant execute on function public.registrar_pago_servicio_pos(
  uuid, text, text, text, numeric, numeric, text, boolean, text, bigint
) to anon, authenticated;

create or replace function public.empleado_listar_pagos_servicio_dia(
  p_session_token uuid,
  p_limite        integer default 30
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_desde timestamptz;
begin
  perform public.fn_require_empleado(p_session_token);
  v_desde := date_trunc('day', now() at time zone 'America/Mexico_City');

  return coalesce((
    select jsonb_agg(row order by row->>'created_at' desc)
    from (
      select jsonb_build_object(
        'id', ps.id,
        'folio', ps.folio,
        'proveedor', ps.proveedor,
        'categoria', ps.categoria,
        'referencia', ps.referencia,
        'monto_servicio', ps.monto_servicio,
        'comision', ps.comision,
        'compensacion_mp', ps.compensacion_mp,
        'costo_liquidacion', ps.costo_liquidacion,
        'fuente_liquidacion', ps.fuente_liquidacion,
        'referencia_externa', ps.referencia_externa,
        'total_cobrado', ps.total_cobrado,
        'metodo_pago', ps.metodo_pago,
        'liquidado_point', ps.liquidado_point,
        'created_at', ps.created_at
      ) as row
      from public.pagos_servicio ps
      where ps.created_at >= v_desde
      order by ps.created_at desc
      limit greatest(1, least(coalesce(p_limite, 30), 100))
    ) q
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_pagos_servicio_dia(uuid, integer) to anon, authenticated;

create or replace function public.empleado_listar_pagos_servicio_rango(
  p_session_token uuid,
  p_desde         timestamptz default null,
  p_hasta         timestamptz default null,
  p_limite        integer default 300
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_lim int;
begin
  perform public.fn_require_empleado(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limite, 300), 800));

  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select jsonb_build_object(
        'id', ps.id,
        'folio', ps.folio,
        'proveedor', ps.proveedor,
        'categoria', ps.categoria,
        'referencia', ps.referencia,
        'monto_servicio', ps.monto_servicio,
        'comision', ps.comision,
        'compensacion_mp', ps.compensacion_mp,
        'costo_liquidacion', ps.costo_liquidacion,
        'fuente_liquidacion', ps.fuente_liquidacion,
        'referencia_externa', ps.referencia_externa,
        'total_cobrado', ps.total_cobrado,
        'metodo_pago', ps.metodo_pago,
        'liquidado_point', ps.liquidado_point,
        'notas', ps.notas,
        'created_at', ps.created_at,
        'atendido_por', ps.atendido_por,
        'atendido_por_nombre', u.nombre
      ) as row_js,
      ps.created_at as ord
      from public.pagos_servicio ps
      left join public.usuarios u on u.id = ps.atendido_por
      where (p_desde is null or ps.created_at >= p_desde)
        and (p_hasta is null or ps.created_at <= p_hasta)
      order by ps.created_at desc
      limit v_lim
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_pagos_servicio_rango(uuid, timestamptz, timestamptz, integer)
  to anon, authenticated;

create or replace function public.empleado_resumen_pagos_servicio_rango(
  p_session_token uuid,
  p_desde         timestamptz,
  p_hasta         timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_empleado(p_session_token);

  return (
    select jsonb_build_object(
      'operaciones', count(*)::int,
      'total_cobrado', coalesce(sum(ps.total_cobrado), 0),
      'total_comision', coalesce(sum(ps.comision), 0),
      'total_compensacion_mp', coalesce(sum(ps.compensacion_mp), 0),
      'total_utilidad', coalesce(sum(ps.comision + ps.compensacion_mp), 0),
      'total_costo_liquidacion', coalesce(sum(coalesce(ps.costo_liquidacion, ps.monto_servicio)), 0),
      'efectivo', coalesce(sum(ps.total_cobrado) filter (where ps.metodo_pago = 'efectivo'), 0),
      'tarjeta', coalesce(sum(ps.total_cobrado) filter (where ps.metodo_pago = 'tarjeta'), 0)
    )
    from public.pagos_servicio ps
    where ps.created_at >= p_desde
      and ps.created_at <= p_hasta
  );
end;
$$;

grant execute on function public.empleado_resumen_pagos_servicio_rango(uuid, timestamptz, timestamptz)
  to anon, authenticated;

-- Conciliación: suma de costo_liquidacion del día vs débitos de recarga en Actividad MP.
create or replace function public.empleado_conciliar_pagos_servicio_dia(
  p_session_token uuid,
  p_fecha         date default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dia date;
  v_inicio timestamptz;
  v_fin timestamptz;
begin
  perform public.fn_require_empleado(p_session_token);
  v_dia := coalesce(p_fecha, (now() at time zone 'America/Mexico_City')::date);
  v_inicio := (v_dia::timestamp) at time zone 'America/Mexico_City';
  v_fin := ((v_dia + 1)::timestamp) at time zone 'America/Mexico_City';

  return (
    select jsonb_build_object(
      'fecha', v_dia,
      'operaciones', count(*)::int,
      'costo_liquidacion', coalesce(sum(coalesce(ps.costo_liquidacion, ps.monto_servicio)), 0),
      'compensacion_mp', coalesce(sum(ps.compensacion_mp), 0),
      'comision_farmacia', coalesce(sum(ps.comision), 0),
      'utilidad', coalesce(sum(ps.comision + ps.compensacion_mp), 0),
      'efectivo', coalesce(sum(ps.total_cobrado) filter (where ps.metodo_pago = 'efectivo'), 0),
      'tarjeta', coalesce(sum(ps.total_cobrado) filter (where ps.metodo_pago = 'tarjeta'), 0)
    )
    from public.pagos_servicio ps
    where ps.created_at >= v_inicio
      and ps.created_at < v_fin
  );
end;
$$;

grant execute on function public.empleado_conciliar_pagos_servicio_dia(uuid, date)
  to anon, authenticated;

create or replace function public.admin_editar_pago_servicio(
  p_session_token  uuid,
  p_id             bigint,
  p_metodo_pago    text default null,
  p_notas          text default null,
  p_referencia     text default null,
  p_monto_servicio numeric default null,
  p_comision       numeric default null,
  p_atendido_por   bigint default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_monto numeric;
  v_com numeric;
  v_prev_atendido bigint;
  v_comp numeric;
begin
  v_actor := public.fn_require_admin(p_session_token);

  select monto_servicio, comision, atendido_por, compensacion_mp
  into v_monto, v_com, v_prev_atendido, v_comp
  from public.pagos_servicio
  where id = p_id;
  if not found then
    raise exception 'Pago de servicio % no encontrado', p_id;
  end if;

  if p_atendido_por is not null then
    if not exists (
      select 1 from public.usuarios u
      where u.id = p_atendido_por
        and coalesce(u.activo, false)
        and u.eliminado_at is null
    ) then
      raise exception 'Usuario vendedor inválido o inactivo (id %)', p_atendido_por;
    end if;
  end if;

  if p_monto_servicio is not null then
    v_monto := round(p_monto_servicio::numeric, 2);
    if v_monto <= 0 then
      raise exception 'Monto del servicio debe ser mayor a 0';
    end if;
    v_comp := round(v_monto * 0.01, 2);
  end if;
  if p_comision is not null then
    v_com := round(p_comision::numeric, 2);
    if v_com < 0 then
      raise exception 'Comisión inválida';
    end if;
  end if;
  if p_metodo_pago is not null and lower(btrim(p_metodo_pago)) not in ('efectivo', 'tarjeta') then
    raise exception 'metodo_pago inválido';
  end if;

  update public.pagos_servicio set
    metodo_pago = coalesce(nullif(lower(btrim(p_metodo_pago)), ''), metodo_pago),
    notas = case when p_notas is null then notas else nullif(btrim(p_notas), '') end,
    referencia = case when p_referencia is null then referencia else nullif(btrim(p_referencia), '') end,
    monto_servicio = v_monto,
    comision = v_com,
    total_cobrado = round(v_monto + v_com, 2),
    compensacion_mp = coalesce(v_comp, round(v_monto * 0.01, 2)),
    costo_liquidacion = v_monto,
    fuente_liquidacion = coalesce(fuente_liquidacion, 'saldo_mp'),
    atendido_por = coalesce(p_atendido_por, atendido_por)
  where id = p_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'editar_pago_servicio', 'pagos_servicio', p_id::text,
      jsonb_build_object(
        'metodo', p_metodo_pago,
        'total', v_monto + v_com,
        'compensacion_mp', coalesce(v_comp, round(v_monto * 0.01, 2)),
        'atendido_por_anterior', v_prev_atendido,
        'atendido_por_nuevo', coalesce(p_atendido_por, v_prev_atendido)
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'atendido_por', coalesce(p_atendido_por, v_prev_atendido));
end;
$$;

grant execute on function public.admin_editar_pago_servicio(uuid, bigint, text, text, text, numeric, numeric, bigint)
  to anon, authenticated;

commit;
