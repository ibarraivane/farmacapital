-- FarmaCapital — Fase A: admin_flujo_caja_bundle
-- 2026-09-04. Idempotente. Requiere sql/patch_finanzas_gastos_20260904.sql.
--
-- Fórmulas (reconstruidas del brief Fase A + Parte 8; el markdown no trae Parte 9):
--   piso = GREATEST(finanzas_fecha_inicio, 2026-08-18)
--   ENTRÓ = SUM(cortes_caja.total_general) vigentes del período, fecha >= piso
--   SALIÓ = SUM(gastos.monto del período)
--         + SUM(pagos_servicio.costo_liquidacion del período)
--         − gastos con origen = 'pagos_servicio' (evita doble conteo)
--   QUEDÓ = ENTRÓ − SALIÓ
--   EN CAJA HOY = saldo_inicial + cortes(piso..hoy) − gastos(piso..hoy) − liquidación(piso..hoy)
--
-- Si falta fecha_inicio o saldo_inicial: configurado=false, sin inventar números.
-- Completitud de captura NO es opcional.

begin;

create or replace function public.admin_flujo_caja_bundle(
  p_session_token uuid,
  p_desde         date,
  p_hasta         date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_piso_fondo     date := date '2026-08-18';
  v_hoy            date := (now() at time zone 'America/Mexico_City')::date;
  v_cfg_inicio     text;
  v_cfg_saldo      text;
  v_cfg_sin        text;
  v_fecha_inicio   date;
  v_saldo_inicial  numeric;
  v_piso           date;
  v_desde          date;
  v_hasta          date;
  v_faltan         text[] := array[]::text[];
  v_recortado      boolean := false;
  v_sin_compra     boolean := false;
  v_mes            text;
  v_entro          numeric := 0;
  v_gastos_all     numeric := 0;
  v_gastos_dup     numeric := 0;
  v_medicamento    numeric := 0;
  v_nomina         numeric := 0;
  v_otros          numeric := 0;
  v_liq            numeric := 0;
  v_salio          numeric := 0;
  v_quedo          numeric := 0;
  v_entro_hoy      numeric := 0;
  v_gastos_hoy     numeric := 0;
  v_gastos_dup_hoy numeric := 0;
  v_liq_hoy        numeric := 0;
  v_en_caja        numeric := 0;
  v_comp_30        numeric := 0;
  v_tiene_nomina   boolean := false;
  v_tiene_renta    boolean := false;
  v_tiene_prov     boolean := false;
  v_incompleta     boolean := true;
  v_falt_captura   text[] := array[]::text[];
  v_lunes_nomina   date;
  v_mes_desde      date;
  v_mes_hasta      date;
  v_cub_cob        numeric := 0;
  v_cub_liq        numeric := 0;
  v_cub_comp       numeric := 0;
  v_cub_com        numeric := 0;
  v_semanas        jsonb := '[]'::jsonb;
  v_gastos_json    jsonb := '[]'::jsonb;
  v_alertas        jsonb := '[]'::jsonb;
begin
  perform public.fn_require_admin(p_session_token);

  select
    max(valor) filter (where clave = 'finanzas_fecha_inicio'),
    max(valor) filter (where clave = 'finanzas_saldo_inicial'),
    max(valor) filter (where clave = 'finanzas_sin_compra_meses')
  into v_cfg_inicio, v_cfg_saldo, v_cfg_sin
  from public.configuracion
  where clave in ('finanzas_fecha_inicio', 'finanzas_saldo_inicial', 'finanzas_sin_compra_meses');

  v_cfg_inicio := trim(coalesce(v_cfg_inicio, ''));
  v_cfg_saldo := trim(coalesce(v_cfg_saldo, ''));
  v_cfg_sin := trim(coalesce(v_cfg_sin, ''));

  if v_cfg_inicio = '' then
    v_faltan := array_append(v_faltan, 'finanzas_fecha_inicio');
  else
    begin
      v_fecha_inicio := v_cfg_inicio::date;
    exception when others then
      v_faltan := array_append(v_faltan, 'finanzas_fecha_inicio');
    end;
  end if;

  if v_cfg_saldo = '' then
    v_faltan := array_append(v_faltan, 'finanzas_saldo_inicial');
  else
    begin
      v_saldo_inicial := v_cfg_saldo::numeric;
      if v_saldo_inicial is null then
        v_faltan := array_append(v_faltan, 'finanzas_saldo_inicial');
      end if;
    exception when others then
      v_faltan := array_append(v_faltan, 'finanzas_saldo_inicial');
    end;
  end if;

  if coalesce(array_length(v_faltan, 1), 0) > 0 then
    return jsonb_build_object(
      'configurado', false,
      'faltan', to_jsonb(v_faltan),
      'piso_fondo', v_piso_fondo,
      'fecha_inicio', v_fecha_inicio,
      'saldo_inicial', v_saldo_inicial,
      'hoy', v_hoy,
      'mensaje',
        'Falta poner la fecha de inicio y el saldo inicial en Metas y Precios → Finanzas. '
        || 'Hasta entonces no se calcula el flujo: un saldo inventado mentiría igual que el 0.55.'
    );
  end if;

  v_piso := greatest(v_fecha_inicio, v_piso_fondo);
  v_recortado := v_fecha_inicio < v_piso_fondo;

  v_hasta := least(coalesce(p_hasta, v_hoy), v_hoy);
  v_desde := coalesce(p_desde, v_piso);
  if v_desde < v_piso then
    v_desde := v_piso;
  end if;
  if v_hasta < v_desde then
    v_hasta := v_desde;
  end if;

  v_mes := to_char(v_hasta, 'YYYY-MM');
  v_sin_compra := (',' || replace(v_cfg_sin, ' ', '') || ',') like ('%,' || v_mes || ',%');
  v_mes_desde := date_trunc('month', v_hasta)::date;
  v_mes_hasta := (date_trunc('month', v_hasta)::date + interval '1 month - 1 day')::date;
  v_lunes_nomina := date_trunc('week', v_hasta)::date;

  -- Período
  select coalesce(sum(c.total_general), 0)
    into v_entro
  from public.cortes_caja c
  where c.anulado_at is null
    and c.fecha >= v_desde
    and c.fecha <= v_hasta;

  select
    coalesce(sum(g.monto), 0),
    coalesce(sum(g.monto) filter (where g.origen = 'pagos_servicio'), 0),
    coalesce(sum(g.monto) filter (where g.categoria = 'compra_inventario'), 0),
    coalesce(sum(g.monto) filter (where g.categoria = 'nomina'), 0),
    coalesce(sum(g.monto) filter (
      where g.categoria not in ('compra_inventario', 'nomina')
        and g.origen is distinct from 'pagos_servicio'
    ), 0)
  into v_gastos_all, v_gastos_dup, v_medicamento, v_nomina, v_otros
  from public.gastos g
  where g.eliminado_at is null
    and g.fecha >= v_desde
    and g.fecha <= v_hasta;

  select coalesce(sum(coalesce(ps.costo_liquidacion, ps.monto_servicio)), 0)
    into v_liq
  from public.pagos_servicio ps
  where (ps.created_at at time zone 'America/Mexico_City')::date >= v_desde
    and (ps.created_at at time zone 'America/Mexico_City')::date <= v_hasta;

  -- Cubetas del período (mismas columnas que empleado_conciliar_pagos_servicio_dia)
  select
    coalesce(sum(ps.total_cobrado), 0),
    coalesce(sum(coalesce(ps.costo_liquidacion, ps.monto_servicio)), 0),
    coalesce(sum(ps.compensacion_mp), 0),
    coalesce(sum(ps.comision), 0)
  into v_cub_cob, v_cub_liq, v_cub_comp, v_cub_com
  from public.pagos_servicio ps
  where (ps.created_at at time zone 'America/Mexico_City')::date >= v_desde
    and (ps.created_at at time zone 'America/Mexico_City')::date <= v_hasta;

  v_salio := (v_gastos_all - v_gastos_dup) + v_liq;
  v_quedo := v_entro - v_salio;

  -- Desde piso hasta hoy (EN CAJA HOY)
  select coalesce(sum(c.total_general), 0)
    into v_entro_hoy
  from public.cortes_caja c
  where c.anulado_at is null
    and c.fecha >= v_piso
    and c.fecha <= v_hoy;

  select
    coalesce(sum(g.monto), 0),
    coalesce(sum(g.monto) filter (where g.origen = 'pagos_servicio'), 0)
  into v_gastos_hoy, v_gastos_dup_hoy
  from public.gastos g
  where g.eliminado_at is null
    and g.fecha >= v_piso
    and g.fecha <= v_hoy;

  select coalesce(sum(coalesce(ps.costo_liquidacion, ps.monto_servicio)), 0)
    into v_liq_hoy
  from public.pagos_servicio ps
  where (ps.created_at at time zone 'America/Mexico_City')::date >= v_piso
    and (ps.created_at at time zone 'America/Mexico_City')::date <= v_hoy;

  v_en_caja := v_saldo_inicial + v_entro_hoy - (v_gastos_hoy - v_gastos_dup_hoy) - v_liq_hoy;

  -- Comprometido a 30 días: último monto recurrente por categoría (proxy honesto, no CxP)
  select coalesce(sum(x.monto), 0)
    into v_comp_30
  from (
    select distinct on (g.categoria) g.monto
    from public.gastos g
    where g.eliminado_at is null
      and g.es_recurrente
      and g.fecha >= (v_hoy - 60)
      and g.fecha <= v_hoy
    order by g.categoria, g.fecha desc, g.id desc
  ) x;

  -- Completitud: nómina en la semana del hasta; renta y proveedor en el mes
  select exists(
    select 1 from public.gastos g
    where g.eliminado_at is null
      and g.categoria = 'nomina'
      and g.fecha >= v_lunes_nomina
      and g.fecha <= v_lunes_nomina + 6
  ) into v_tiene_nomina;

  select exists(
    select 1 from public.gastos g
    where g.eliminado_at is null
      and g.categoria = 'renta'
      and g.fecha >= v_mes_desde
      and g.fecha <= v_mes_hasta
  ) into v_tiene_renta;

  select exists(
    select 1 from public.gastos g
    where g.eliminado_at is null
      and g.categoria = 'compra_inventario'
      and g.fecha >= v_mes_desde
      and g.fecha <= v_mes_hasta
  ) into v_tiene_prov;

  if not v_tiene_nomina then
    v_falt_captura := array_append(v_falt_captura, 'nomina');
  end if;
  if not v_tiene_renta then
    v_falt_captura := array_append(v_falt_captura, 'renta');
  end if;
  if not v_tiene_prov and not v_sin_compra then
    v_falt_captura := array_append(v_falt_captura, 'proveedor');
  end if;
  v_incompleta := coalesce(array_length(v_falt_captura, 1), 0) > 0;

  select coalesce(jsonb_agg(to_jsonb(s) order by s.semana), '[]'::jsonb)
    into v_semanas
  from (
    select
      gs::date as semana,
      round(coalesce((
        select sum(c.total_general)
        from public.cortes_caja c
        where c.anulado_at is null
          and c.fecha >= greatest(gs::date, v_desde)
          and c.fecha <= least(gs::date + 6, v_hasta)
      ), 0)::numeric, 2) as entro,
      round(coalesce((
        select sum(g.monto)
        from public.gastos g
        where g.eliminado_at is null
          and g.categoria = 'compra_inventario'
          and g.fecha >= greatest(gs::date, v_desde)
          and g.fecha <= least(gs::date + 6, v_hasta)
      ), 0)::numeric, 2) as medicamento,
      round(coalesce((
        select sum(g.monto)
        from public.gastos g
        where g.eliminado_at is null
          and g.categoria = 'nomina'
          and g.fecha >= greatest(gs::date, v_desde)
          and g.fecha <= least(gs::date + 6, v_hasta)
      ), 0)::numeric, 2) as nomina,
      round((
        coalesce((
          select sum(g.monto)
          from public.gastos g
          where g.eliminado_at is null
            and g.categoria not in ('compra_inventario', 'nomina')
            and g.origen is distinct from 'pagos_servicio'
            and g.fecha >= greatest(gs::date, v_desde)
            and g.fecha <= least(gs::date + 6, v_hasta)
        ), 0)
        + coalesce((
          select sum(coalesce(ps.costo_liquidacion, ps.monto_servicio))
          from public.pagos_servicio ps
          where (ps.created_at at time zone 'America/Mexico_City')::date
                  >= greatest(gs::date, v_desde)
            and (ps.created_at at time zone 'America/Mexico_City')::date
                  <= least(gs::date + 6, v_hasta)
        ), 0)
      )::numeric, 2) as gastos
    from generate_series(
      date_trunc('week', v_desde)::date,
      date_trunc('week', v_hasta)::date,
      interval '7 days'
    ) as gs
  ) s;

  -- QUEDÓ semanal = ENTRÓ − medicamento − nómina − gastos
  v_semanas := (
    select coalesce(jsonb_agg(
      s || jsonb_build_object(
        'quedo', round((
          coalesce((s->>'entro')::numeric, 0)
          - coalesce((s->>'medicamento')::numeric, 0)
          - coalesce((s->>'nomina')::numeric, 0)
          - coalesce((s->>'gastos')::numeric, 0)
        ), 2)
      ) order by (s->>'semana')::date
    ), '[]'::jsonb)
    from jsonb_array_elements(v_semanas) s
  );

  select coalesce(jsonb_agg(to_jsonb(x) order by x.fecha desc, x.id desc), '[]'::jsonb)
    into v_gastos_json
  from (
    select
      g.id,
      g.fecha,
      g.categoria,
      g.concepto,
      g.monto,
      g.origen,
      g.proveedor,
      g.afecta_pl,
      g.es_recurrente,
      g.notas
    from public.gastos g
    where g.eliminado_at is null
      and g.fecha >= v_desde
      and g.fecha <= v_hasta
  ) x;

  v_alertas := jsonb_build_array(
    jsonb_build_object(
      'tipo', 'completitud',
      'nivel', case when v_incompleta then 'ambar' else 'ok' end,
      'texto', case
        when v_incompleta then
          'Captura incompleta (' || array_to_string(v_falt_captura, ', ')
          || ') — no es que hayas gastado $0.'
        else
          'Captura del período completa: hay nómina, renta y pago a proveedor (o marcaste “sin compra”).'
      end
    ),
    jsonb_build_object(
      'tipo', 'medicamento',
      'nivel', 'info',
      'texto',
        'Comprar medicamento no es pérdida. Sale en Flujo (el dinero ya no está) '
        || 'y no entra al P&L: es cambio de dinero por activo. El costo se reconoce al vender.'
    ),
    jsonb_build_object(
      'tipo', 'cubetas',
      'nivel', 'info',
      'texto',
        'Dos cubetas: el cobro de recargas ya va en el corte (cajón). '
        || 'Hay que restar costo_liquidacion del saldo MP el mismo día. '
        || 'Una sola cubeta “en caja” infla el disponible con el pass-through. '
        || 'En caja hoy no es dinero libre: descuenta lo comprometido a 30 días si lo capturaste como recurrente.'
    )
  );

  return jsonb_build_object(
    'configurado', true,
    'piso_fondo', v_piso_fondo,
    'fecha_inicio', v_fecha_inicio,
    'piso_aplicado', v_piso,
    'recortado_por_fondo', v_recortado,
    'saldo_inicial', round(v_saldo_inicial, 2),
    'desde', v_desde,
    'hasta', v_hasta,
    'hoy', v_hoy,
    'entro', round(v_entro, 2),
    'salio', jsonb_build_object(
      'total', round(v_salio, 2),
      'gastos', round(v_gastos_all - v_gastos_dup, 2),
      'medicamento', round(v_medicamento, 2),
      'nomina', round(v_nomina, 2),
      'otros_gastos', round(v_otros, 2),
      'liquidacion_mp', round(v_liq, 2)
    ),
    'quedo', round(v_quedo, 2),
    'en_caja_hoy', round(v_en_caja, 2),
    'comprometido_30d', round(v_comp_30, 2),
    'cubetas', jsonb_build_object(
      'cajon_cobrado_servicios', round(v_cub_cob, 2),
      'saldo_mp_liquidacion', round(v_cub_liq, 2),
      'saldo_mp_compensacion', round(v_cub_comp, 2),
      'comision_farmacia', round(v_cub_com, 2),
      'utilidad_servicios', round(v_cub_com + v_cub_comp, 2)
    ),
    'completitud', jsonb_build_object(
      'tiene_nomina', v_tiene_nomina,
      'tiene_renta', v_tiene_renta,
      'tiene_proveedor', v_tiene_prov,
      'sin_compra', v_sin_compra,
      'incompleta', v_incompleta,
      'faltantes', to_jsonb(v_falt_captura),
      'mes', v_mes
    ),
    'alertas', v_alertas,
    'semanas', v_semanas,
    'gastos', v_gastos_json
  );
end;
$$;

grant execute on function public.admin_flujo_caja_bundle(uuid, date, date)
  to anon, authenticated;

commit;
