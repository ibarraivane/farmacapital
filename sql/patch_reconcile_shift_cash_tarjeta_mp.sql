-- Corte de caja: reconciliar los 3 métodos de pago del turno, en hora local.
--
-- Problemas que corrige:
--   1. La función solo devolvía efectivo; tarjeta (BBVA) y MercadoPago quedaban
--      en $0.00 y había que capturarlos a mano en el corte.
--   2. Los rangos de turno se calculaban en UTC. Una venta a las 15:37 hora de
--      México (21:37 UTC) caía en "vespertino" en vez de "matutino".
--
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
    v_inicio := (p_fecha + time '08:00:00') at time zone 'America/Mexico_City';
    v_fin    := (p_fecha + time '15:59:59') at time zone 'America/Mexico_City';
  else
    v_inicio := (p_fecha + time '16:00:00') at time zone 'America/Mexico_City';
    v_fin    := (p_fecha + time '21:59:59') at time zone 'America/Mexico_City';
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
