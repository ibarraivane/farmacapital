-- Nuevo horario de FarmaCapital: abre 8:00, cierra 22:30, en dos turnos.
--
--   Matutino    8:00 – 15:30
--   Vespertino 15:00 – 22:30
--
-- El traslape de 15:00 a 15:30 es de PERSONAL (relevo), no de caja: una venta
-- no puede pertenecer a dos turnos, así que la frontera del dinero se traza a
-- las 15:30, cuando el matutino cuenta y entrega.
--
-- Los rangos cubren el día completo a propósito (00:00–15:29:59 y 15:30–23:59:59):
-- si alguien vende a las 7:50 abriendo o a las 22:40 cerrando, la venta cae en
-- un turno en vez de perderse en un hueco.
--
-- Espejo de src/constants/turnos.js — si cambia uno, cambia el otro.
-- Ejecutar en Supabase SQL Editor.

drop function if exists public.reconcile_shift_cash(text, date);

create function public.reconcile_shift_cash(
  p_turno text,
  p_fecha date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_inicio timestamptz;
  v_fin    timestamptz;
  v_efectivo    numeric := 0;
  v_tarjeta     numeric := 0;
  v_mercadopago numeric := 0;
begin
  -- Turnos en HORA LOCAL de México, no UTC.
  if p_turno = 'matutino' then
    v_inicio := (p_fecha + time '00:00:00') at time zone 'America/Mexico_City';
    v_fin    := (p_fecha + time '15:29:59.999') at time zone 'America/Mexico_City';
  else
    v_inicio := (p_fecha + time '15:30:00') at time zone 'America/Mexico_City';
    v_fin    := (p_fecha + time '23:59:59.999') at time zone 'America/Mexico_City';
  end if;

  select
    coalesce(sum(total) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total) filter (where metodo_pago = 'tarjeta'), 0),
    coalesce(sum(total) filter (where metodo_pago in ('mercadopago','mercadopago_point')), 0)
  into v_efectivo, v_tarjeta, v_mercadopago
  from public.pedidos
  where estado = 'completado'
    and created_at between v_inicio and v_fin;

  return jsonb_build_object(
    'efectivo_sistema', v_efectivo,
    'tarjeta',          v_tarjeta,
    'mercadopago',      v_mercadopago,
    'rango_inicio',     v_inicio,
    'rango_fin',        v_fin
  );
end;
$$;

grant execute on function public.reconcile_shift_cash(text, date) to anon, authenticated;


-- registrar_corte_caja guardaba hora_apertura 08:00 / 16:00. Ahora 08:00 / 15:00,
-- que es cuando entra físicamente cada persona.
create or replace function public.registrar_corte_caja(
  p_session_token      uuid,
  p_turno              text,
  p_efectivo_declarado numeric,
  p_efectivo_sistema   numeric,
  p_tarjeta            numeric,
  p_mercadopago        numeric,
  p_diferencia         numeric,
  p_total_general      numeric,
  p_spei               numeric default 0,
  p_notas              text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_nombre   text;
  v_corte_id bigint;
  v_ahora    timestamp;
  v_apertura time;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  select nombre into v_nombre from public.usuarios where id = v_actor_id;

  v_ahora    := now() at time zone 'America/Mexico_City';
  v_apertura := case when p_turno = 'matutino' then time '08:00' else time '15:00' end;

  -- diferencia y total_general son GENERATED: las calcula Postgres.
  insert into public.cortes_caja (
    turno, empleado_id, fecha, hora_apertura, hora_cierre,
    efectivo_declarado, efectivo_sistema,
    total_tarjeta, total_spei, total_mercadopago,
    notas
  ) values (
    p_turno, v_actor_id, v_ahora::date, v_apertura, v_ahora::time,
    coalesce(p_efectivo_declarado, 0), coalesce(p_efectivo_sistema, 0),
    coalesce(p_tarjeta, 0), coalesce(p_spei, 0), coalesce(p_mercadopago, 0),
    p_notas
  ) returning id into v_corte_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id, v_nombre,
      'corte_caja', 'cortes_caja', v_corte_id::text,
      jsonb_build_object('turno', p_turno, 'diferencia', p_diferencia, 'total', p_total_general)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'corte_id', v_corte_id);
end;
$$;

grant execute on function public.registrar_corte_caja(uuid, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text) to anon, authenticated;


-- Verificación: los rangos no deben traslaparse ni dejar hueco.
select 'matutino'   as turno, public.reconcile_shift_cash('matutino',   current_date) as r
union all
select 'vespertino' as turno, public.reconcile_shift_cash('vespertino', current_date);
