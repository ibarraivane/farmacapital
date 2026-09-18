-- Diagnóstico + arreglo: corte matutino 17-sep-2026 (Cynthia).
-- El sistema dio $616 de efectivo; el cajón de ventas era $626.
-- $10 = recargo de Izzi. SOLO LECTURA hasta el bloque 4.
--
-- Cómo usarlo:
--   1) Corre las consultas 1–3 y mira el Izzi (comisión y método).
--   2) Si el Izzi quedó en efectivo con comisión < 10, corre el bloque 4.
--   3) Si el Izzi quedó en TARJETA y los $10 sí están en el cajón,
--      no corras el 4 a ciegas: el recargo no iba a sumar al efectivo.

-- 1) Corte de Cynthia
select
  c.id,
  u.nombre,
  c.turno,
  to_char(c.created_at at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI') as hora,
  c.fondo_inicial,
  c.efectivo_sistema,
  (c.fondo_inicial + c.efectivo_sistema) as esperado,
  c.efectivo_declarado,
  c.diferencia,
  c.total_tarjeta
from public.cortes_caja c
left join public.usuarios u on u.id = c.empleado_id
where c.anulado_at is null
  and (c.created_at at time zone 'America/Mexico_City')::date = date '2026-09-17'
order by c.created_at;

-- 2) Servicios del 17-sep: aquí se ve si Izzi llevó $0, $8 o $10
select
  to_char(ps.created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora,
  ps.folio,
  ps.proveedor,
  ps.categoria,
  ps.metodo_pago,
  ps.monto_servicio,
  ps.comision,
  ps.total_cobrado
from public.pagos_servicio ps
where (ps.created_at at time zone 'America/Mexico_City')::date = date '2026-09-17'
order by ps.created_at;

-- 3) Efectivo de servicios vs recargo (lo que el corte debió sumar)
select
  coalesce(sum(total_cobrado) filter (where metodo_pago = 'efectivo'), 0) as efectivo_servicios,
  coalesce(sum(comision) filter (where metodo_pago = 'efectivo'), 0) as recargo_en_efectivo,
  coalesce(sum(total_cobrado) filter (where metodo_pago = 'tarjeta'), 0) as tarjeta_servicios,
  coalesce(sum(comision) filter (where metodo_pago = 'tarjeta'), 0) as recargo_en_tarjeta
from public.pagos_servicio
where (created_at at time zone 'America/Mexico_City')::date = date '2026-09-17';

-- 4) ARREGLO: Izzi en efectivo con recargo corto → $10, y se recalcula el corte.
--    No toca el contado que ella declaró.
--    Idempotente: si ya está en $10, no hace nada.
do $$
declare
  v_ps     public.pagos_servicio%rowtype;
  v_corte  public.cortes_caja%rowtype;
  v_sesion public.caja_sesiones%rowtype;
  v_vent   jsonb;
  v_r      jsonb;
  v_inicio timestamptz;
begin
  select * into v_ps
  from public.pagos_servicio
  where (created_at at time zone 'America/Mexico_City')::date = date '2026-09-17'
    and proveedor ilike '%izzi%'
  order by created_at
  limit 1;

  if v_ps.id is null then
    raise notice 'No hay un pago Izzi el 17-sep. Revisa la consulta 2.';
    return;
  end if;

  if v_ps.metodo_pago is distinct from 'efectivo' then
    raise notice 'Izzi % está en % (no efectivo). Los $10 del recargo no entran al cajón de este ticket. No se altera el corte.',
      v_ps.folio, v_ps.metodo_pago;
    return;
  end if;

  if coalesce(v_ps.comision, 0) >= 10 then
    raise notice 'Izzi % ya tiene recargo %. Nada que sumar.', v_ps.folio, v_ps.comision;
    return;
  end if;

  update public.pagos_servicio
  set comision = 10,
      total_cobrado = round(monto_servicio + 10, 2)
  where id = v_ps.id;

  raise notice 'Izzi %: recargo % → 10. total_cobrado % → %',
    v_ps.folio, v_ps.comision, v_ps.total_cobrado, round(v_ps.monto_servicio + 10, 2);

  select c.* into v_corte
  from public.cortes_caja c
  left join public.usuarios u on u.id = c.empleado_id
  where c.anulado_at is null
    and c.turno = 'matutino'
    and (c.created_at at time zone 'America/Mexico_City')::date = date '2026-09-17'
    and (u.nombre ilike '%cynthia%' or u.nombre ilike '%cintia%')
  order by c.created_at desc
  limit 1;

  if v_corte.id is null then
    raise notice 'Ticket Izzi corregido. No se halló el corte de Cynthia para recalcular.';
    return;
  end if;

  select * into v_sesion
  from public.caja_sesiones
  where corte_id = v_corte.id
  order by id desc
  limit 1;

  v_vent := public.fn_ventana_corte(v_sesion.id, v_corte.created_at);
  v_inicio := (v_vent->>'inicio')::timestamptz;
  v_r := public.reconcile_cash_rango(v_inicio, v_corte.created_at);

  update public.cortes_caja
  set efectivo_sistema = coalesce((v_r->>'efectivo_sistema')::numeric, efectivo_sistema)
  where id = v_corte.id;

  raise notice 'Corte %: efectivo_sistema % → %',
    v_corte.id, v_corte.efectivo_sistema, coalesce((v_r->>'efectivo_sistema')::numeric, v_corte.efectivo_sistema);
end;
$$;
