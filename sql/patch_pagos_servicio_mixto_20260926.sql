-- Pago mixto en recargas / pagos de servicio (efectivo + tarjeta).
-- Ejecutar en Supabase SQL Editor antes o junto al deploy del front.
--
-- Qué hace:
--   1) Columnas pagos_servicio.monto_efectivo / monto_tarjeta
--   2) Permite metodo_pago = 'mixto'
--   3) registrar_pago_servicio_pos acepta los montos mixtos
--   4) Listados y resumen incluyen el desglose
--   5) El corte (reconcile_cash_rango) suma cada pata al cajón correcto
--   6) Flujo de caja: cajón / tarjeta de servicios parten el mixto

begin;

alter table public.pagos_servicio
  add column if not exists monto_efectivo numeric not null default 0;

alter table public.pagos_servicio
  add column if not exists monto_tarjeta numeric not null default 0;

comment on column public.pagos_servicio.monto_efectivo is
  'Parte cobrada en efectivo cuando metodo_pago = mixto (o 0).';
comment on column public.pagos_servicio.monto_tarjeta is
  'Parte cobrada con tarjeta/Point cuando metodo_pago = mixto (o 0).';

do $$
declare
  cname text;
begin
  for cname in
    select con.conname
    from pg_constraint con
    where con.conrelid = 'public.pagos_servicio'::regclass
      and con.contype = 'c'
      and pg_get_constraintdef(con.oid) ilike '%metodo_pago%'
  loop
    execute format('alter table public.pagos_servicio drop constraint %I', cname);
  end loop;
end $$;

alter table public.pagos_servicio
  add constraint pagos_servicio_metodo_pago_check
  check (metodo_pago in ('efectivo', 'tarjeta', 'mixto'));

-- Helper: cuánto de un pago de servicio va al cajón / a tarjeta.
create or replace function public.fn_pago_servicio_efectivo(
  p_metodo text,
  p_total numeric,
  p_monto_efectivo numeric default 0
)
returns numeric
language sql
immutable
as $$
  select case lower(btrim(coalesce(p_metodo, '')))
    when 'mixto' then round(coalesce(p_monto_efectivo, 0)::numeric, 2)
    when 'efectivo' then round(coalesce(p_total, 0)::numeric, 2)
    else 0::numeric
  end;
$$;

create or replace function public.fn_pago_servicio_tarjeta(
  p_metodo text,
  p_total numeric,
  p_monto_tarjeta numeric default 0
)
returns numeric
language sql
immutable
as $$
  select case lower(btrim(coalesce(p_metodo, '')))
    when 'mixto' then round(coalesce(p_monto_tarjeta, 0)::numeric, 2)
    when 'tarjeta' then round(coalesce(p_total, 0)::numeric, 2)
    else 0::numeric
  end;
$$;

grant execute on function public.fn_pago_servicio_efectivo(text, numeric, numeric)
  to anon, authenticated;
grant execute on function public.fn_pago_servicio_tarjeta(text, numeric, numeric)
  to anon, authenticated;

-- Firma nueva: montos mixtos opcionales al final.
drop function if exists public.registrar_pago_servicio_pos(
  uuid, text, text, text, numeric, numeric, text, boolean, text, bigint
);

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
  p_cliente_id       bigint default null,
  p_monto_efectivo   numeric default null,
  p_monto_tarjeta    numeric default null
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
  v_cat text;
  v_ef numeric := 0;
  v_tar numeric := 0;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if coalesce(btrim(p_proveedor), '') = '' then
    raise exception 'Proveedor requerido';
  end if;
  if coalesce(btrim(p_categoria), '') = '' then
    raise exception 'Categoría requerida';
  end if;

  v_cat := lower(btrim(p_categoria));
  v_monto := round(coalesce(p_monto_servicio, 0)::numeric, 2);
  if v_monto <= 0 then
    raise exception 'Monto del servicio debe ser mayor a 0';
  end if;

  if v_cat = 'recarga' then
    v_com := 0;
  else
    v_com := public.fn_recargo_catalogo_servicio(p_proveedor, v_cat, p_comision);
    if v_com <= 0 then
      raise exception 'El recargo de farmacia es obligatorio en recibos. No se guarda en cero.';
    end if;
  end if;

  v_total := round(v_monto + v_com, 2);
  v_comp := round(v_monto * 0.01, 2);
  v_metodo := lower(btrim(coalesce(p_metodo_pago, '')));
  if v_metodo not in ('efectivo', 'tarjeta', 'mixto') then
    raise exception 'metodo_pago inválido (efectivo, tarjeta o mixto)';
  end if;

  if v_metodo = 'mixto' then
    v_ef := round(coalesce(p_monto_efectivo, 0)::numeric, 2);
    v_tar := round(coalesce(p_monto_tarjeta, 0)::numeric, 2);
    if v_ef <= 0 or v_tar <= 0 then
      raise exception 'Pago mixto requiere monto_efectivo y monto_tarjeta mayores a 0';
    end if;
    if round(v_ef + v_tar, 2) <> v_total then
      raise exception 'En mixto, efectivo + tarjeta debe igualar el total cobrado';
    end if;
  else
    v_ef := 0;
    v_tar := 0;
  end if;

  if p_cliente_id is not null and not exists (
    select 1 from public.clientes c where c.id = p_cliente_id and c.eliminado_at is null
  ) then
    raise exception 'Cliente no encontrado';
  end if;

  insert into public.pagos_servicio (
    folio, categoria, proveedor, referencia,
    monto_servicio, comision, total_cobrado, metodo_pago,
    monto_efectivo, monto_tarjeta,
    liquidado_point, notas, cliente_id, atendido_por,
    compensacion_mp, costo_liquidacion, fuente_liquidacion
  ) values (
    'PENDING',
    v_cat,
    btrim(p_proveedor),
    nullif(btrim(coalesce(p_referencia, '')), ''),
    v_monto,
    v_com,
    v_total,
    v_metodo,
    v_ef,
    v_tar,
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
        'comision', v_com,
        'metodo', v_metodo,
        'monto_efectivo', v_ef,
        'monto_tarjeta', v_tar,
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
    'compensacion_mp', v_comp,
    'metodo_pago', v_metodo,
    'monto_efectivo', v_ef,
    'monto_tarjeta', v_tar
  );
end;
$$;

grant execute on function public.registrar_pago_servicio_pos(
  uuid, text, text, text, numeric, numeric, text, boolean, text, bigint, numeric, numeric
) to anon, authenticated;

-- Listado del día: incluir desglose mixto.
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
  v_hasta timestamptz;
begin
  perform public.fn_require_empleado(p_session_token);
  v_desde := date_trunc('day', now() at time zone 'America/Mexico_City')
             at time zone 'America/Mexico_City';
  v_hasta := v_desde + interval '1 day';

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
        'monto_efectivo', coalesce(ps.monto_efectivo, 0),
        'monto_tarjeta', coalesce(ps.monto_tarjeta, 0),
        'liquidado_point', ps.liquidado_point,
        'created_at', ps.created_at
      ) as row
      from public.pagos_servicio ps
      where ps.created_at >= v_desde
        and ps.created_at < v_hasta
      order by ps.created_at desc
      limit greatest(1, least(coalesce(p_limite, 30), 100))
    ) q
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_pagos_servicio_dia(uuid, integer)
  to anon, authenticated;

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
        'total_cobrado', ps.total_cobrado,
        'metodo_pago', ps.metodo_pago,
        'monto_efectivo', coalesce(ps.monto_efectivo, 0),
        'monto_tarjeta', coalesce(ps.monto_tarjeta, 0),
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
      'efectivo', coalesce(sum(
        public.fn_pago_servicio_efectivo(ps.metodo_pago, ps.total_cobrado, ps.monto_efectivo)
      ), 0),
      'tarjeta', coalesce(sum(
        public.fn_pago_servicio_tarjeta(ps.metodo_pago, ps.total_cobrado, ps.monto_tarjeta)
      ), 0)
    )
    from public.pagos_servicio ps
    where ps.created_at >= p_desde
      and ps.created_at <= p_hasta
  );
end;
$$;

grant execute on function public.empleado_resumen_pagos_servicio_rango(uuid, timestamptz, timestamptz)
  to anon, authenticated;

-- Corte: partir mixto de servicios igual que en ventas.
create or replace function public.reconcile_cash_rango(
  p_inicio timestamptz,
  p_fin    timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_ef_pedidos   numeric := 0;
  v_tar_pedidos  numeric := 0;
  v_mp_pedidos   numeric := 0;
  v_spei_pedidos numeric := 0;
  v_ef_mixto     numeric := 0;
  v_tar_mixto    numeric := 0;
  v_ef_serv      numeric := 0;
  v_tar_serv     numeric := 0;
  v_dev_ef numeric := 0;
  v_dev_in numeric := 0;
  v_dev_tar numeric := 0;
  v_dev_cred numeric := 0;
begin
  if p_inicio is null or p_fin is null or p_fin <= p_inicio then
    return jsonb_build_object(
      'efectivo_sistema', 0, 'tarjeta', 0, 'mercadopago', 0, 'spei', 0,
      'efectivo_pedidos', 0, 'efectivo_servicios', 0,
      'efectivo_devoluciones', 0, 'efectivo_cambios_ingreso', 0,
      'credito_otorgado', 0, 'tarjeta_pedidos', 0, 'tarjeta_servicios', 0,
      'tarjeta_cambios', 0, 'rango_inicio', p_inicio, 'rango_fin', p_fin,
      'vacio', true
    );
  end if;

  select
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'tarjeta'),  0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago in ('mercadopago','mercadopago_point')), 0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'spei'),     0),
    coalesce(sum(coalesce(monto_efectivo, 0)) filter (where metodo_pago = 'mixto'), 0),
    coalesce(sum(coalesce(monto_tarjeta, 0)) filter (where metodo_pago = 'mixto'), 0)
  into v_ef_pedidos, v_tar_pedidos, v_mp_pedidos, v_spei_pedidos, v_ef_mixto, v_tar_mixto
  from public.pedidos
  where estado = 'completado'
    and created_at > p_inicio
    and created_at <= p_fin;

  v_ef_pedidos := v_ef_pedidos + v_ef_mixto;
  v_tar_pedidos := v_tar_pedidos + v_tar_mixto;

  select
    coalesce(sum(public.fn_pago_servicio_efectivo(metodo_pago, total_cobrado, monto_efectivo)), 0),
    coalesce(sum(public.fn_pago_servicio_tarjeta(metodo_pago, total_cobrado, monto_tarjeta)), 0)
  into v_ef_serv, v_tar_serv
  from public.pagos_servicio
  where created_at > p_inicio
    and created_at <= p_fin;

  select
    coalesce(sum(monto_efectivo), 0),
    coalesce(sum(monto_efectivo_ingreso), 0),
    coalesce(sum(monto_tarjeta_ingreso), 0),
    coalesce(sum(monto_credito), 0)
  into v_dev_ef, v_dev_in, v_dev_tar, v_dev_cred
  from public.devoluciones
  where estado = 'aprobada'
    and created_at > p_inicio
    and created_at <= p_fin;

  return jsonb_build_object(
    'efectivo_sistema',   v_ef_pedidos + v_ef_serv - v_dev_ef + v_dev_in,
    'tarjeta',            v_tar_pedidos + v_tar_serv + v_dev_tar,
    'mercadopago',        v_mp_pedidos,
    'spei',               v_spei_pedidos,
    'efectivo_pedidos',   v_ef_pedidos,
    'efectivo_servicios', v_ef_serv,
    'efectivo_devoluciones', v_dev_ef,
    'efectivo_cambios_ingreso', v_dev_in,
    'credito_otorgado',   v_dev_cred,
    'tarjeta_pedidos',    v_tar_pedidos,
    'tarjeta_servicios',  v_tar_serv,
    'tarjeta_cambios',    v_dev_tar,
    'rango_inicio',       p_inicio,
    'rango_fin',          p_fin,
    'vacio',              false
  );
end;
$$;

grant execute on function public.reconcile_cash_rango(timestamptz, timestamptz)
  to anon, authenticated;

-- Admin editar: permite mixto con montos (mantiene atendido_por).
drop function if exists public.admin_editar_pago_servicio(uuid, bigint, text, text, text, numeric, numeric);
drop function if exists public.admin_editar_pago_servicio(uuid, bigint, text, text, text, numeric, numeric, bigint);
drop function if exists public.admin_editar_pago_servicio(uuid, bigint, text, text, text, numeric, numeric, numeric, numeric);

create or replace function public.admin_editar_pago_servicio(
  p_session_token  uuid,
  p_id             bigint,
  p_metodo_pago    text default null,
  p_notas          text default null,
  p_referencia     text default null,
  p_monto_servicio numeric default null,
  p_comision       numeric default null,
  p_atendido_por   bigint default null,
  p_monto_efectivo numeric default null,
  p_monto_tarjeta  numeric default null
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
  v_total numeric;
  v_metodo text;
  v_ef numeric;
  v_tar numeric;
  v_cat text;
  v_prev_atendido bigint;
  v_comp numeric;
begin
  v_actor := public.fn_require_admin(p_session_token);

  select monto_servicio, comision, metodo_pago, monto_efectivo, monto_tarjeta, categoria, atendido_por, compensacion_mp
    into v_monto, v_com, v_metodo, v_ef, v_tar, v_cat, v_prev_atendido, v_comp
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

  if p_metodo_pago is not null then
    v_metodo := lower(btrim(p_metodo_pago));
    if v_metodo not in ('efectivo', 'tarjeta', 'mixto') then
      raise exception 'metodo_pago inválido (efectivo, tarjeta o mixto)';
    end if;
  end if;

  if p_monto_servicio is not null then
    v_monto := round(p_monto_servicio::numeric, 2);
    if v_monto <= 0 then raise exception 'monto_invalido'; end if;
    v_comp := round(v_monto * 0.01, 2);
  end if;
  if p_comision is not null then
    v_com := round(p_comision::numeric, 2);
    if v_com < 0 then raise exception 'comision_invalida'; end if;
  end if;

  if lower(coalesce(v_cat, '')) = 'recarga' then
    v_com := 0;
  elsif v_com <= 0 then
    raise exception 'El recargo de farmacia es obligatorio en recibos.';
  end if;

  v_total := round(v_monto + v_com, 2);

  if v_metodo = 'mixto' then
    v_ef := round(coalesce(p_monto_efectivo, v_ef, 0)::numeric, 2);
    v_tar := round(coalesce(p_monto_tarjeta, v_tar, 0)::numeric, 2);
    if v_ef <= 0 or v_tar <= 0 or round(v_ef + v_tar, 2) <> v_total then
      raise exception 'Pago mixto requiere monto_efectivo y monto_tarjeta que sumen el total';
    end if;
  else
    v_ef := 0;
    v_tar := 0;
  end if;

  update public.pagos_servicio set
    metodo_pago = v_metodo,
    notas = case when p_notas is null then notas else nullif(btrim(p_notas), '') end,
    referencia = case when p_referencia is null then referencia else nullif(btrim(p_referencia), '') end,
    monto_servicio = v_monto,
    comision = v_com,
    total_cobrado = v_total,
    monto_efectivo = v_ef,
    monto_tarjeta = v_tar,
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
        'metodo', v_metodo,
        'total', v_total,
        'monto_efectivo', v_ef,
        'monto_tarjeta', v_tar,
        'atendido_por_anterior', v_prev_atendido,
        'atendido_por_nuevo', coalesce(p_atendido_por, v_prev_atendido)
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'id', p_id, 'atendido_por', coalesce(p_atendido_por, v_prev_atendido));
end;
$$;

grant execute on function public.admin_editar_pago_servicio(
  uuid, bigint, text, text, text, numeric, numeric, bigint, numeric, numeric
) to anon, authenticated;

commit;
