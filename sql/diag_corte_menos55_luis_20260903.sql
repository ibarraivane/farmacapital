-- ============================================================
-- DIAGNÓSTICO: pantalla -$55 vs venta de Luis ($55)
-- Fechas: 3-sep-2026 (y margen 2–4 sep). SOLO LECTURA.
--
-- Hipótesis del dueño: la venta de Luis (suerox limón + venda $35 = $55)
-- pudo ser DESPUÉS del corte que mostró faltante -$55.
--
-- Pegar en Supabase → SQL Editor. No modifica nada.
-- ============================================================

-- ── 1. Cortes con diferencia cerca de -55 (o cualquier dif ≠ 0) ──
select
  c.id,
  coalesce(u.nombre, '(sin usuario)') as quien_corto,
  c.turno,
  c.fecha,
  to_char(c.created_at at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI') as hora_corte_cdmx,
  c.fondo_inicial,
  c.efectivo_sistema,
  (c.fondo_inicial + c.efectivo_sistema) as esperado,
  c.efectivo_declarado,
  c.diferencia,
  case
    when c.diferencia = 0 then 'cuadrado'
    when c.diferencia > 0 then 'sobrante'
    else 'faltante'
  end as tipo,
  c.diferencia_revisada,
  c.anulado_at is not null as anulado,
  c.notas
from public.cortes_caja c
left join public.usuarios u on u.id = c.empleado_id
where (c.created_at at time zone 'America/Mexico_City')::date
        between date '2026-09-02' and date '2026-09-04'
   or c.fecha between date '2026-09-02' and date '2026-09-04'
order by c.created_at;


-- ── 2. Ventana del corte (si quedó en audit_log al registrar) ──
select
  a.created_at at time zone 'America/Mexico_City' as cuando_cdmx,
  a.accion,
  a.registro_id as corte_id,
  a.detalle->>'ventana_inicio' as ventana_inicio,
  a.detalle->>'ventana_fin'    as ventana_fin,
  a.detalle->>'diferencia'     as diferencia,
  a.detalle->>'efectivo_sistema' as efectivo_sistema,
  a.detalle->>'efectivo_declarado' as efectivo_declarado,
  a.detalle->>'fondo_inicial'  as fondo_inicial
from public.audit_log a
where a.tabla = 'cortes_caja'
  and a.accion in ('corte_caja', 'anular_corte')
  and (a.created_at at time zone 'America/Mexico_City')::date
        between date '2026-09-02' and date '2026-09-04'
order by a.created_at;


-- ── 3. Ventas de Luis (~$55 o texto suero/venda) el 3-sep ───────
select
  to_char(p.created_at at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS') as hora_venta_cdmx,
  p.id as pedido,
  coalesce(u.nombre, '—') as atendio,
  p.metodo_pago,
  p.total,
  coalesce(p.monto_credito, 0) as credito,
  (p.total - coalesce(p.monto_credito, 0)) as neto,
  (
    select string_agg(coalesce(pr.nombre, i.nombre_snapshot, '?') || ' ×' || i.cantidad, ' | ')
    from public.pedido_items i
    left join public.productos pr on pr.id = i.producto_id
    where i.pedido_id = p.id
  ) as items
from public.pedidos p
left join public.usuarios u on u.id = p.atendido_por
where p.estado = 'completado'
  and (p.created_at at time zone 'America/Mexico_City')::date
        between date '2026-09-02' and date '2026-09-04'
  and (
    coalesce(u.nombre, '') ilike '%luis%'
    or abs(p.total - 55) < 0.02
    or exists (
      select 1
      from public.pedido_items i
      left join public.productos pr on pr.id = i.producto_id
      where i.pedido_id = p.id
        and (
          coalesce(pr.nombre, i.nombre_snapshot, '') ilike '%suer%'
          or coalesce(pr.nombre, i.nombre_snapshot, '') ilike '%venda%'
          or coalesce(pr.nombre, i.nombre_snapshot, '') ilike '%elastic%'
        )
    )
  )
order by p.created_at;


-- ── 4. CRUCE: ¿la venta de ~$55 fue ANTES o DESPUÉS del corte -55? ──
-- Por cada corte con faltante cerca de 55, compara con ventas ~55 de Luis.
with cortes as (
  select
    c.id,
    c.created_at as corte_at,
    c.diferencia,
    c.efectivo_sistema,
    c.efectivo_declarado,
    c.fondo_inicial,
    coalesce(u.nombre, '?') as quien_corto
  from public.cortes_caja c
  left join public.usuarios u on u.id = c.empleado_id
  where c.anulado_at is null
    and c.diferencia < 0
    and abs(c.diferencia + 55) < 1   -- faltante ≈ 55
    and (c.created_at at time zone 'America/Mexico_City')::date
          between date '2026-09-02' and date '2026-09-04'
),
ventas as (
  select
    p.id as pedido,
    p.created_at as venta_at,
    p.total,
    p.metodo_pago,
    coalesce(u.nombre, '?') as atendio,
    (
      select string_agg(left(coalesce(pr.nombre, i.nombre_snapshot, '?'), 40), ' | ')
      from public.pedido_items i
      left join public.productos pr on pr.id = i.producto_id
      where i.pedido_id = p.id
    ) as items
  from public.pedidos p
  left join public.usuarios u on u.id = p.atendido_por
  where p.estado = 'completado'
    and (p.created_at at time zone 'America/Mexico_City')::date
          between date '2026-09-02' and date '2026-09-04'
    and (
      coalesce(u.nombre, '') ilike '%luis%'
      or abs(p.total - 55) < 0.02
      or exists (
        select 1
        from public.pedido_items i
        left join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
          and (
            coalesce(pr.nombre, i.nombre_snapshot, '') ilike '%suer%'
            or coalesce(pr.nombre, i.nombre_snapshot, '') ilike '%venda%'
          )
      )
    )
)
select
  c.id as corte_id,
  c.quien_corto,
  to_char(c.corte_at at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS') as hora_corte,
  c.diferencia as dif_corte,
  v.pedido,
  v.atendio,
  v.metodo_pago,
  v.total as total_venta,
  v.items,
  to_char(v.venta_at at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS') as hora_venta,
  case
    when v.venta_at is null then 'sin venta ~55 encontrada'
    when v.venta_at <= c.corte_at then 'ANTES o EN el corte → SÍ pudo causar el -55'
    else 'DESPUÉS del corte → NO explica el -55 (entra al siguiente periodo)'
  end as veredicto,
  round((extract(epoch from (v.venta_at - c.corte_at))/60.0)::numeric, 1)
    as minutos_venta_menos_corte
from cortes c
left join ventas v on true
order by c.corte_at, v.venta_at;


-- ── 4b. Respuesta en una fila (pega esto si solo quieres el veredicto) ──
with corte as (
  select c.*
  from public.cortes_caja c
  where c.anulado_at is null
    and c.diferencia < 0
    and abs(c.diferencia + 55) < 1
    and (c.created_at at time zone 'America/Mexico_City')::date
          between date '2026-09-02' and date '2026-09-04'
  order by abs(c.diferencia + 55), c.created_at
  limit 1
),
venta_luis as (
  select p.*
  from public.pedidos p
  left join public.usuarios u on u.id = p.atendido_por
  where p.estado = 'completado'
    and (p.created_at at time zone 'America/Mexico_City')::date
          between date '2026-09-02' and date '2026-09-04'
    and abs(p.total - 55) < 0.02
  order by
    case when coalesce(u.nombre, '') ilike '%luis%' then 0 else 1 end,
    abs(extract(epoch from (p.created_at - (select created_at from corte))))
  limit 1
)
select
  (select id from corte) as corte_id,
  to_char((select created_at from corte) at time zone 'America/Mexico_City',
          'YYYY-MM-DD HH24:MI') as hora_corte,
  (select diferencia from corte) as dif_corte,
  (select id from venta_luis) as pedido_55,
  to_char((select created_at from venta_luis) at time zone 'America/Mexico_City',
          'YYYY-MM-DD HH24:MI') as hora_venta_55,
  case
    when (select id from corte) is null then
      'No hay corte con faltante ≈ $55 en esas fechas'
    when (select id from venta_luis) is null then
      'Hay corte -55 pero no hay venta de $55 en pedidos'
    when (select created_at from venta_luis) <= (select created_at from corte) then
      'ANTES del corte: el sistema ya sumaba esos $55; si no estaban en el cajón contado → faltante -55'
    else
      'DESPUÉS del corte: esa venta NO explica el -55 de la pantalla (pertenece al siguiente periodo)'
  end as respuesta;


-- ── 5. Efectivo del 3-sep por hora (para ver si faltan $55 en el cajón contado) ──
select
  to_char(p.created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora,
  coalesce(u.nombre, '—') as atendio,
  p.id as pedido,
  p.total,
  (p.total - coalesce(p.monto_credito, 0)) as efectivo_neto,
  (
    select string_agg(left(coalesce(pr.nombre, i.nombre_snapshot, '?'), 40), ' | ')
    from public.pedido_items i
    left join public.productos pr on pr.id = i.producto_id
    where i.pedido_id = p.id
  ) as items
from public.pedidos p
left join public.usuarios u on u.id = p.atendido_por
where p.estado = 'completado'
  and p.metodo_pago = 'efectivo'
  and (p.created_at at time zone 'America/Mexico_City')::date = date '2026-09-03'
order by p.created_at;


-- ── 6. Lectura rápida ─────────────────────────────────────────
-- Si 4b dice DESPUÉS del corte:
--   El -55 de la pantalla NO es la venta de Luis. Buscar otras $55
--   de efectivo en la ventana del corte, o un conteo corto.
-- Si dice ANTES del corte:
--   El sistema ya contaba esos $55; al declarar de menos, salió faltante.
--   En la libreta de René esos $55 se sumaron después → cuadra con el relato.
