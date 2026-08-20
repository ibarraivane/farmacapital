-- FARMAX — Reasignar vendedor (atendido_por) desde Dashboard → Transacciones
-- Ejecutar en Supabase SQL Editor.
-- atendido_por → usuarios.id (POS, Mi Día, RRHH comisiones, gráficas por empleado).

begin;

drop function if exists public.admin_editar_pedido(uuid, bigint, text, text, text);

create or replace function public.admin_editar_pedido(
  p_session_token uuid,
  p_pedido_id     bigint,
  p_estado        text default null,
  p_metodo_pago   text default null,
  p_notas         text default null,
  p_atendido_por  bigint default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_prev_atendido bigint;
  v_prev_nombre text;
  v_new_nombre text;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  select atendido_por into v_prev_atendido
  from public.pedidos
  where id = p_pedido_id;
  if not found then
    raise exception 'Pedido % no encontrado', p_pedido_id;
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

  update public.pedidos set
    estado       = coalesce(p_estado, estado),
    metodo_pago  = coalesce(p_metodo_pago, metodo_pago),
    notas        = coalesce(p_notas, notas),
    atendido_por = coalesce(p_atendido_por, atendido_por)
  where id = p_pedido_id;

  select nombre into v_prev_nombre from public.usuarios where id = v_prev_atendido;
  select nombre into v_new_nombre from public.usuarios where id = coalesce(p_atendido_por, v_prev_atendido);

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'editar_pedido', 'pedidos', p_pedido_id::text,
      jsonb_build_object(
        'estado', p_estado,
        'metodo_pago', p_metodo_pago,
        'atendido_por_anterior', v_prev_atendido,
        'atendido_por_anterior_nombre', v_prev_nombre,
        'atendido_por_nuevo', coalesce(p_atendido_por, v_prev_atendido),
        'atendido_por_nuevo_nombre', v_new_nombre
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'atendido_por', coalesce(p_atendido_por, v_prev_atendido));
end;
$$;

grant execute on function public.admin_editar_pedido(uuid, bigint, text, text, text, bigint)
  to anon, authenticated;

drop function if exists public.admin_editar_pago_servicio(uuid, bigint, text, text, text, numeric, numeric);

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
begin
  v_actor := public.fn_require_admin(p_session_token);

  select monto_servicio, comision, atendido_por
  into v_monto, v_com, v_prev_atendido
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
