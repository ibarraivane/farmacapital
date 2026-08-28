-- Recargas: no guardar recargo en 0, y "hoy" en hora de México (no UTC).
-- Requiere sql/patch_pagos_servicio_compensacion_mp.sql (columnas nuevas).
-- Ejecutar en Supabase SQL Editor. Idempotente.
--
-- SUPERSEDED: no reaplicar este archivo. La regla "comisión no puede ser 0"
-- bloqueaba recargas "sin recargo". La función vigente está en
-- sql/patch_pagos_servicio_recarga_sin_recargo_20260826.sql.

begin;

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
  if v_com <= 0 then
    raise exception 'El recargo de farmacia es obligatorio. No se guarda en cero.';
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
  v_dia date;
  v_desde timestamptz;
  v_hasta timestamptz;
begin
  perform public.fn_require_empleado(p_session_token);
  -- Midnight Mexico as timestamptz. date_trunc(now() AT TIME ZONE ...)
  -- without the outer AT TIME ZONE was compared as UTC and colaba el día anterior.
  v_dia := (now() at time zone 'America/Mexico_City')::date;
  v_desde := (v_dia::timestamp) at time zone 'America/Mexico_City';
  v_hasta := ((v_dia + 1)::timestamp) at time zone 'America/Mexico_City';

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
        and ps.created_at < v_hasta
      order by ps.created_at desc
      limit greatest(1, least(coalesce(p_limite, 30), 100))
    ) q
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_pagos_servicio_dia(uuid, integer) to anon, authenticated;

commit;
