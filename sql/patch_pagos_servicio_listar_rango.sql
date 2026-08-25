-- Listar recargas / pagos de servicio por rango (Dashboard → Transacciones).
-- Idempotente. El POS ya registra en pagos_servicio; este RPC los lee por fechas.

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

create or replace function public.admin_editar_pago_servicio(
  p_session_token  uuid,
  p_id             bigint,
  p_metodo_pago    text default null,
  p_notas          text default null,
  p_referencia     text default null,
  p_monto_servicio numeric default null,
  p_comision       numeric default null
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
begin
  v_actor := public.fn_require_admin(p_session_token);

  select monto_servicio, comision into v_monto, v_com
  from public.pagos_servicio
  where id = p_id;
  if not found then
    raise exception 'Pago de servicio % no encontrado', p_id;
  end if;

  if p_monto_servicio is not null then
    v_monto := round(p_monto_servicio::numeric, 2);
    if v_monto <= 0 then
      raise exception 'Monto del servicio debe ser mayor a 0';
    end if;
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
    total_cobrado = round(v_monto + v_com, 2)
  where id = p_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'editar_pago_servicio', 'pagos_servicio', p_id::text,
      jsonb_build_object('metodo', p_metodo_pago, 'total', v_monto + v_com)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_editar_pago_servicio(uuid, bigint, text, text, text, numeric, numeric)
  to anon, authenticated;

create or replace function public.admin_eliminar_pago_servicio(
  p_session_token uuid,
  p_id            bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);
  delete from public.pagos_servicio where id = p_id;
  if not found then
    raise exception 'Pago de servicio % no encontrado', p_id;
  end if;
  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'eliminar_pago_servicio', 'pagos_servicio', p_id::text,
      '{}'::jsonb
    );
  exception when others then null;
  end;
  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_eliminar_pago_servicio(uuid, bigint) to anon, authenticated;
