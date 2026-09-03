-- ============================================================
-- DIAGNÓSTICO corte 2-sep-2026 (Rene / Erika) — SOLO LECTURA
--
-- Contexto WhatsApp Team FarmaCap:
--   Rene cerró el sistema ANTES de contar (dedazo) → faltante en pantalla.
--   Libreta: fondo $2,777.50 + ventas listadas $331.00 = $3,108.50
--   Saldo escrito / Erika: $3,118.50  (hay $10 de más vs la suma de renglones)
--
-- Pegar en Supabase → SQL Editor. No modifica nada.
-- ============================================================

-- ── 1. Cortes de hoy (vigentes y anulados) ───────────────────
select
  c.id,
  coalesce(u.nombre, '(sin usuario)') as cajero,
  c.turno,
  c.fecha,
  to_char(c.created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora_corte,
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
  c.total_tarjeta,
  c.total_mercadopago,
  c.total_spei,
  c.total_general,
  c.notas,
  c.anulado_at is not null as anulado,
  c.anulado_motivo,
  c.diferencia_revisada
from public.cortes_caja c
left join public.usuarios u on u.id = c.empleado_id
where c.fecha = date '2026-09-02'
   or (c.created_at at time zone 'America/Mexico_City')::date = date '2026-09-02'
order by c.created_at;

-- ── 2. Sesiones de caja (quién abrió / cerró / quién está abierto) ──
select
  s.id as sesion_id,
  u.nombre,
  s.turno,
  s.fecha,
  s.estado,
  s.fondo_contado,
  s.corte_id,
  (s.abierta_at at time zone 'America/Mexico_City') as abierta_cdmx,
  (s.cerrada_at at time zone 'America/Mexico_City') as cerrada_cdmx
from public.caja_sesiones s
join public.usuarios u on u.id = s.empleado_id
where s.fecha >= date '2026-09-01'
order by s.abierta_at desc;

-- ── 3. Ventas en efectivo de hoy (lo que el sistema debió esperar) ──
select
  to_char(p.created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora,
  p.id as pedido,
  coalesce(u.nombre, '—') as atendio,
  p.metodo_pago,
  p.total,
  coalesce(p.monto_credito, 0) as credito,
  (p.total - coalesce(p.monto_credito, 0)) as efectivo_neto
from public.pedidos p
left join public.usuarios u on u.id = p.atendido_por
where p.estado = 'completado'
  and (p.created_at at time zone 'America/Mexico_City')::date = date '2026-09-02'
order by p.created_at;

-- Totales por método hoy
select
  coalesce(metodo_pago, '(null)') as metodo,
  count(*) as ventas,
  round(sum(total)::numeric, 2) as monto,
  round(sum(total - coalesce(monto_credito, 0))
        filter (where metodo_pago = 'efectivo')::numeric, 2) as efectivo_neto
from public.pedidos
where estado = 'completado'
  and (created_at at time zone 'America/Mexico_City')::date = date '2026-09-02'
group by 1
order by monto desc nulls last;

-- ── 4. Pagos de servicio hoy (recargas Telcel, etc.) ─────────
select
  to_char(created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora,
  folio, categoria, proveedor, metodo_pago,
  monto_servicio, comision, total_cobrado
from public.pagos_servicio
where (created_at at time zone 'America/Mexico_City')::date = date '2026-09-02'
order by created_at;

-- ── 5. Ventana reconcile desde el corte previo ───────────────
-- Si el corte de Rene se guardó sin contar, efectivo_sistema aquí
-- es lo que el sistema esperaba en el cajón (además del fondo).
select public.reconcile_cash_rango(
  public.fn_corte_previo_at(
    coalesce(
      (select created_at from public.cortes_caja
        where anulado_at is null
          and (created_at at time zone 'America/Mexico_City')::date = date '2026-09-02'
        order by created_at limit 1),
      now()
    )
  ),
  coalesce(
    (select created_at from public.cortes_caja
      where anulado_at is null
        and (created_at at time zone 'America/Mexico_City')::date = date '2026-09-02'
      order by created_at limit 1),
    now()
  )
) as totales_hasta_primer_corte_hoy;

-- ── 6. Cuadre contra la libreta ───────────────────────────────
-- Libreta: fondo 2777.50 | listado 331.00 | saldo escrito 3118.50
-- Aritmética: 2777.50 + 331.00 = 3108.50  → faltan $10 en el listado
--             o sobran $10 en el cajón / en el saldo escrito.
select
  2777.50::numeric as fondo_libreta,
  331.00::numeric  as ventas_listadas,
  (2777.50 + 331.00)::numeric as saldo_aritmetico,
  3118.50::numeric as saldo_escrito_y_erika,
  (3118.50 - (2777.50 + 331.00))::numeric as hueco_10;
