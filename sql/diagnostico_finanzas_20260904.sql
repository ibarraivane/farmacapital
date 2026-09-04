-- =============================================================================
-- FARMACAPITAL — Diagnóstico Finanzas · 4 sep 2026
-- Sólo lectura. No modifica nada. Pegar en Supabase → SQL Editor.
-- Correr CONSULTA POR CONSULTA y guardar los resultados.
--
-- Lo que mide cada una (no te las saltes):
--   1. Qué tablas financieras existen y de cuándo a cuándo tienen datos.
--   2. Desde qué fecha fondo_inicial es de fiar (los cortes viejos valen 0).
--   3. Cómo se comporta total_general GENERATED cuando el fondo es 0.
--   4. COMPUERTA: % de lo VENDIDO con costo real capturado.
--      Si cobertura_algun_costo < 80% → DETENTE. Capturar costos, no programar.
--   5. Cobertura de costo en catálogo y en lotes vivos (el stock, no la venta).
--   6. Qué % de renglones vendidos trae lote_id y costo de lote.
--   7. Brecha diaria pedidos vs. cortes (el control de descuadre).
--   8. Promos: SUM(renglones) vs. pedidos.total.
--   9. Qué gastos derivados ya se podrían calcular (nómina, merma, CxP, servicios).
--
-- Relacionado: docs/CURSOR_FINANZAS_PROMPT.md · docs/finanzas-maqueta.html
-- =============================================================================


-- ── 1. Mapa: qué hay, cuántas filas, de cuándo a cuándo ─────────────────────
-- `gastos` y `proyecto_capex` no existen hoy (el handoff lo dice).
-- El bloque 1a lista las que sí; el 1b confirma que las otras no están.
-- Si 1a truena por una tabla, esa tabla no está en este proyecto — anótalo.

select 'pedidos'           as tabla, count(*) as filas, min(created_at)::text as desde, max(created_at)::text as hasta from public.pedidos
union all select 'pedido_items',     count(*), null, null from public.pedido_items
union all select 'productos',        count(*), min(created_at)::text, max(created_at)::text from public.productos
union all select 'lotes',            count(*), min(created_at)::text, max(created_at)::text from public.lotes
union all select 'cortes_caja',      count(*), min(fecha)::text,      max(fecha)::text      from public.cortes_caja
union all select 'caja_sesiones',    count(*), min(created_at)::text, max(created_at)::text from public.caja_sesiones
union all select 'devoluciones',     count(*), min(created_at)::text, max(created_at)::text from public.devoluciones
union all select 'devolucion_items', count(*), null, null from public.devolucion_items
union all select 'nomina_empleados', count(*), min(periodo_inicio)::text, max(periodo_fin)::text from public.nomina_empleados
union all select 'compras',          count(*), min(created_at)::text, max(created_at)::text from public.compras
union all select 'recepciones',      count(*), min(created_at)::text, max(created_at)::text from public.recepciones
union all select 'pagos_servicio',   count(*), min(created_at)::text, max(created_at)::text from public.pagos_servicio
order by 1;

-- 1b. Las que el módulo va a CREAR. Tienen que salir cero filas.
--     Si `gastos` ya aparece, no la vuelvas a crear: extiende.
select table_name
from information_schema.tables
where table_schema = 'public'
  and table_name in ('gastos', 'proyecto_capex');


-- ── 2. fondo_inicial: ¿desde cuándo el dato existe de verdad? ────────────────
-- fondo_inicial se agregó con default 0 (patch_corte_ciego_fondo_denominaciones).
-- Los cortes de los meses previos quedaron en 0. total_general los sobreestima
-- por el tamaño del fondo. El flujo de caja tiene que CORTAR en la fecha
-- en que el fondo deja de ser 0 de forma estable — no imputar.
--
-- Lee: primer corte con fondo > 0, último con fondo = 0, patrón por mes,
-- y el tamaño típico del fondo cuando sí lo capturan (para saber de cuánto
-- es la sobreestimación histórica).

select
  count(*)                                                        as cortes_vigentes,
  count(*) filter (where coalesce(fondo_inicial, 0) = 0)          as fondo_cero,
  count(*) filter (where coalesce(fondo_inicial, 0) > 0)          as fondo_positivo,
  min(fecha) filter (where coalesce(fondo_inicial, 0) > 0)        as primera_fecha_fondo_ok,
  max(fecha) filter (where coalesce(fondo_inicial, 0) = 0)        as ultima_fecha_fondo_cero,
  round(avg(fondo_inicial) filter (where fondo_inicial > 0), 2)   as fondo_promedio_cuando_hay,
  round(percentile_cont(0.5) within group (order by fondo_inicial)
        filter (where fondo_inicial > 0), 2)                      as fondo_mediana_cuando_hay,
  min(fecha)                                                      as primer_corte,
  max(fecha)                                                      as ultimo_corte
from public.cortes_caja
where anulado_at is null;

-- 2b. Por mes: para ver si después del primer fondo>0 volvieron a dejar 0.
select
  to_char(fecha, 'YYYY-MM')                                       as mes,
  count(*)                                                        as cortes,
  count(*) filter (where coalesce(fondo_inicial, 0) = 0)          as fondo_cero,
  count(*) filter (where coalesce(fondo_inicial, 0) > 0)          as fondo_ok,
  round(avg(fondo_inicial) filter (where fondo_inicial > 0), 2)   as fondo_promedio,
  round(sum(total_general), 2)                                    as suma_total_general
from public.cortes_caja
where anulado_at is null
group by 1
order by 1;


-- ── 3. total_general GENERATED vs. la misma cuenta hecha a mano ─────────────
-- Confirma la fórmula:
--   (efectivo_declarado - fondo_inicial) + tarjeta + spei + mercadopago
-- y mide cuánto inflan los cortes con fondo = 0. Si "sobreestima_si_fondo_fuera"
-- es grande, ese es el sesgo de usar la historia completa en el flujo de caja.
--
-- "fondo_tipico_ok" = mediana de los cortes que SÍ tienen fondo. Es una
-- cota del error, no un número para imputar. No lo uses en el P&L.

with params as (
  select coalesce(
    percentile_cont(0.5) within group (order by fondo_inicial)
      filter (where fondo_inicial > 0),
    0
  ) as fondo_tipico_ok
  from public.cortes_caja
  where anulado_at is null
)
select
  count(*)                                                        as cortes,
  count(*) filter (where abs(
      coalesce(c.total_general, 0)
      - (
          (coalesce(c.efectivo_declarado, 0) - coalesce(c.fondo_inicial, 0))
          + coalesce(c.total_tarjeta, 0)
          + coalesce(c.total_spei, 0)
          + coalesce(c.total_mercadopago, 0)
        )
    ) > 0.01)                                                     as filas_que_no_cuadran_con_la_formula,
  round(sum(c.total_general), 2)                                  as suma_total_general,
  round(sum(c.efectivo_declarado), 2)                             as suma_declarado,
  round(sum(c.fondo_inicial), 2)                                  as suma_fondo_capturado,
  round(sum(c.total_general) filter (where c.fondo_inicial = 0), 2)
                                                                  as total_general_solo_fondo_cero,
  round(
    count(*) filter (where c.fondo_inicial = 0) * p.fondo_tipico_ok
  , 2)                                                            as sobreestima_si_fondo_fuera_la_mediana,
  p.fondo_tipico_ok
from public.cortes_caja c
cross join params p
where c.anulado_at is null
group by p.fondo_tipico_ok;


-- ── 4. COMPUERTA — % de lo VENDIDO con costo real capturado ─────────────────
-- Universo = pedido_items de pedidos completados. El mismo que el P&L.
--
-- "Costo real capturado" = hay un número > 0 en el lote de esa línea
-- o, si no hay lote, en productos.costo. Un 0 o un null NO cuenta.
-- No uses el 0.55. No imputes.
--
--   cobertura_algun_costo  → la compuerta. < 80% = ALTO. Detente.
--   cobertura_lote         → la buena. Si es mucho menor, el P&L se
--                            va a reescribir cada vez que Recibir pise
--                            productos.costo.
--
-- También parte el ingreso para que veas si el agujero es plata o piezas.

select
  count(*)                                                        as renglones_vendidos,
  count(*) filter (where coalesce(l.costo_unitario, 0) > 0)       as renglones_con_costo_lote,
  count(*) filter (where coalesce(pr.costo, 0) > 0)               as renglones_con_costo_catalogo,
  count(*) filter (
    where coalesce(l.costo_unitario, pr.costo, 0) > 0
  )                                                               as renglones_con_algun_costo,
  round(sum(x.precio_unitario * x.cantidad), 2)                   as ingreso_vendido,
  round(sum(x.precio_unitario * x.cantidad)
        filter (where coalesce(l.costo_unitario, 0) > 0), 2)      as ingreso_con_costo_lote,
  round(sum(x.precio_unitario * x.cantidad)
        filter (where coalesce(l.costo_unitario, pr.costo, 0) > 0), 2)
                                                                  as ingreso_con_algun_costo,
  round(
    100.0 * sum(x.precio_unitario * x.cantidad)
              filter (where coalesce(l.costo_unitario, 0) > 0)
    / nullif(sum(x.precio_unitario * x.cantidad), 0)
  , 1)                                                            as cobertura_lote_pct,
  round(
    100.0 * sum(x.precio_unitario * x.cantidad)
              filter (where coalesce(l.costo_unitario, pr.costo, 0) > 0)
    / nullif(sum(x.precio_unitario * x.cantidad), 0)
  , 1)                                                            as cobertura_algun_costo_pct,
  case
    when coalesce(sum(x.precio_unitario * x.cantidad), 0) = 0
      then 'SIN VENTAS — no hay de qué hablar'
    when (
      100.0 * sum(x.precio_unitario * x.cantidad)
                filter (where coalesce(l.costo_unitario, pr.costo, 0) > 0)
      / nullif(sum(x.precio_unitario * x.cantidad), 0)
    ) < 80
      then 'ALTO — cobertura < 80%. DETENTE. Capturar costos. Un P&L ahora infla el margen.'
    when (
      100.0 * sum(x.precio_unitario * x.cantidad)
                filter (where coalesce(l.costo_unitario, 0) > 0)
      / nullif(sum(x.precio_unitario * x.cantidad), 0)
    ) < 80
      then 'AMBAR — hay costo de catálogo pero poco costo de lote. El P&L se reescribe al actualizar productos.costo.'
    else 'OK — se puede armar P&L. Sigue con las preguntas de la Parte 6.'
  end                                                             as veredicto
from public.pedido_items x
join public.pedidos  p  on p.id = x.pedido_id
join public.productos pr on pr.id = x.producto_id
left join public.lotes l on l.id = x.lote_id
where p.estado::text = 'completado';

-- 4b. Dónde duele: categorías con más ingreso sin costo. Para saber qué capturar.
select
  coalesce(nullif(trim(pr.categoria), ''), 'Sin categoría')       as categoria,
  count(*)                                                        as renglones,
  round(sum(x.precio_unitario * x.cantidad), 2)                   as ingreso,
  round(sum(x.precio_unitario * x.cantidad)
        filter (where coalesce(l.costo_unitario, pr.costo, 0) <= 0), 2)
                                                                  as ingreso_sin_costo,
  round(
    100.0 * sum(x.precio_unitario * x.cantidad)
              filter (where coalesce(l.costo_unitario, pr.costo, 0) > 0)
    / nullif(sum(x.precio_unitario * x.cantidad), 0)
  , 1)                                                            as cobertura_pct
from public.pedido_items x
join public.pedidos  p  on p.id = x.pedido_id
join public.productos pr on pr.id = x.producto_id
left join public.lotes l on l.id = x.lote_id
where p.estado::text = 'completado'
group by 1
having sum(x.precio_unitario * x.cantidad)
       filter (where coalesce(l.costo_unitario, pr.costo, 0) <= 0) > 0
order by ingreso_sin_costo desc nulls last
limit 20;


-- ── 5. Cobertura en catálogo y lotes vivos (el stock, no lo vendido) ────────
-- Distinto de la 4. Aquí: ¿qué tan lleno está el maestro?
-- Recibir pisa productos.costo. Un catálogo al 95% no salva ventas viejas
-- si esas líneas no tenían lote_id.

select
  (select count(*) from public.productos where coalesce(activo, true))          as productos_activos,
  (select count(*) from public.productos
    where coalesce(activo, true) and coalesce(costo, 0) > 0)                    as productos_con_costo,
  round(
    100.0 * (select count(*) from public.productos
              where coalesce(activo, true) and coalesce(costo, 0) > 0)
    / nullif((select count(*) from public.productos where coalesce(activo, true)), 0)
  , 1)                                                                          as productos_con_costo_pct,
  (select count(*) from public.lotes
    where coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0)          as lotes_vivos,
  (select count(*) from public.lotes
    where coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0
      and coalesce(costo_unitario, 0) > 0)                                      as lotes_vivos_con_costo,
  round(
    100.0 * (select count(*) from public.lotes
              where coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0
                and coalesce(costo_unitario, 0) > 0)
    / nullif((select count(*) from public.lotes
               where coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0), 0)
  , 1)                                                                          as lotes_vivos_con_costo_pct,
  (select round(sum(cantidad_actual * costo_unitario), 2) from public.lotes
    where coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0
      and coalesce(costo_unitario, 0) > 0)                                      as valor_inventario_a_costo_parcial;


-- ── 6. ¿Cuántos renglones vendidos traen lote_id? ───────────────────────────
-- Las ventas por pieza (modo_venta='unidad') guardan lote_id = null
-- (patch_precio_exclusivo_caducidad_20260824.sql:431-435).
-- Sin lote no hay costo histórico. modo_venta NO se persiste.

select
  count(*)                                                        as renglones,
  count(*) filter (where x.lote_id is not null)                   as con_lote_id,
  count(*) filter (where x.lote_id is null)                       as sin_lote_id,
  count(*) filter (
    where x.lote_id is not null and coalesce(l.costo_unitario, 0) > 0
  )                                                               as con_lote_y_costo,
  count(*) filter (
    where x.lote_id is not null and coalesce(l.costo_unitario, 0) <= 0
  )                                                               as con_lote_sin_costo,
  round(100.0 * count(*) filter (where x.lote_id is not null)
        / nullif(count(*), 0), 1)                                 as con_lote_id_pct,
  round(sum(x.precio_unitario * x.cantidad)
        filter (where x.lote_id is null), 2)                      as ingreso_sin_lote_id
from public.pedido_items x
join public.pedidos p on p.id = x.pedido_id
left join public.lotes l on l.id = x.lote_id
where p.estado::text = 'completado';


-- ── 7. Brecha diaria: pedidos (P&L) vs. cortes (flujo) ──────────────────────
-- §2.5 del handoff: NO mezclar. Esta diferencia ES el control de descuadre.
-- Un día con corte y sin pedidos (o al revés) no se “ajusta”: se enseña.
--
-- Cortes anulados fuera. Pedidos solo completados.
-- pagos_servicio y consultas pueden explicar parte del hueco (preguntas 2 y 3).

with peds as (
  select
    (p.created_at at time zone 'America/Mexico_City')::date as dia,
    round(sum(p.total), 2)                                  as ventas_pedidos,
    count(*)                                                as tickets,
    round(sum(p.total) filter (where p.tipo::text = 'consulta'), 2)
                                                            as ventas_consulta,
    round(sum(p.total) filter (where p.tipo::text = 'online'), 2)
                                                            as ventas_online
  from public.pedidos p
  where p.estado::text = 'completado'
  group by 1
),
cortes as (
  select
    fecha                                                   as dia,
    round(sum(total_general), 2)                            as total_cortes,
    count(*)                                                as n_cortes,
    count(*) filter (where coalesce(fondo_inicial, 0) = 0)  as cortes_fondo_cero,
    round(sum(fondo_inicial), 2)                            as suma_fondo
  from public.cortes_caja
  where anulado_at is null
  group by 1
),
serv as (
  select
    (created_at at time zone 'America/Mexico_City')::date   as dia,
    round(sum(total_cobrado), 2)                            as servicios_cobrados,
    round(sum(comision), 2)                                 as servicios_comision
  from public.pagos_servicio
  group by 1
)
select
  coalesce(p.dia, c.dia, s.dia)                             as dia,
  coalesce(p.ventas_pedidos, 0)                             as ventas_pedidos,
  coalesce(c.total_cortes, 0)                               as total_cortes,
  coalesce(p.ventas_pedidos, 0) - coalesce(c.total_cortes, 0)
                                                            as brecha_pedidos_menos_cortes,
  coalesce(p.tickets, 0)                                    as tickets,
  coalesce(c.n_cortes, 0)                                   as n_cortes,
  coalesce(c.cortes_fondo_cero, 0)                          as cortes_fondo_cero,
  coalesce(p.ventas_consulta, 0)                            as ventas_consulta,
  coalesce(p.ventas_online, 0)                              as ventas_online,
  coalesce(s.servicios_cobrados, 0)                         as servicios_cobrados,
  case
    when c.dia is null then 'SIN CORTE'
    when p.dia is null then 'CORTE SIN PEDIDOS'
    when abs(coalesce(p.ventas_pedidos, 0) - coalesce(c.total_cortes, 0)) <= 1
      then 'CUADRA'
    when coalesce(c.cortes_fondo_cero, 0) > 0
      then 'DESCUADRE (hay corte con fondo 0)'
    else 'DESCUADRE'
  end                                                       as nota
from peds p
full outer join cortes c on c.dia = p.dia
full outer join serv   s on s.dia = coalesce(p.dia, c.dia)
order by 1 desc
limit 45;


-- ── 8. Promos / precio pisado: SUM(items) vs. pedidos.total ─────────────────
-- create_sale_transaction descarta el precio del carrito y pone el de
-- catálogo (create_sale_transaction.sql:443-450). Con promo,
-- SUM(renglones) > total del ticket. El margen por renglón se infla.
-- Umbral 0.05 para no ahogarse en centavos.

select
  count(*)                                                        as tickets_completados,
  count(*) filter (where abs(coalesce(i.suma_renglones, 0) - p.total) > 0.05)
                                                                  as tickets_desalineados,
  round(sum(p.total), 2)                                          as suma_totales,
  round(sum(i.suma_renglones), 2)                                 as suma_renglones,
  round(sum(i.suma_renglones) - sum(p.total), 2)                  as renglones_menos_totales,
  round(avg(i.suma_renglones - p.total)
        filter (where abs(coalesce(i.suma_renglones, 0) - p.total) > 0.05), 2)
                                                                  as desfase_promedio_cuando_hay
from public.pedidos p
left join (
  select pedido_id, sum(precio_unitario * cantidad) as suma_renglones
  from public.pedido_items
  group by 1
) i on i.pedido_id = p.id
where p.estado::text = 'completado';

-- 8b. Los 15 tickets con más desfase (para ver si es promo o basura).
select
  p.id,
  p.created_at at time zone 'America/Mexico_City'                 as cuando,
  p.tipo,
  p.metodo_pago,
  p.total                                                         as total_ticket,
  round(i.suma_renglones, 2)                                      as suma_renglones,
  round(i.suma_renglones - p.total, 2)                            as desfase
from public.pedidos p
join (
  select pedido_id, sum(precio_unitario * cantidad) as suma_renglones
  from public.pedido_items
  group by 1
) i on i.pedido_id = p.id
where p.estado::text = 'completado'
  and abs(i.suma_renglones - p.total) > 0.05
order by abs(i.suma_renglones - p.total) desc
limit 15;


-- ── 9. Gastos derivados que YA se podrían calcular ──────────────────────────
-- No hay tabla gastos. Esto es el inventario de lo que el job derivado
-- encontraría el día 1 — y de lo que seguiría en cero (pregunta 4 y 8).
-- compras.estado='pendiente' es CxP, NO un gasto del P&L.
-- recepciones.total_ticket es mercancía que entró, NO un gasto del P&L.

select
  jsonb_build_object(
    'nomina_filas',
      (select count(*) from public.nomina_empleados),
    'nomina_neto_pagado',
      (select round(sum(neto_pagar), 2) from public.nomina_empleados
        where coalesce(pagado, false)),
    'nomina_neto_pendiente',
      (select round(sum(neto_pagar), 2) from public.nomina_empleados
        where not coalesce(pagado, false)),
    'nomina_primera',
      (select min(periodo_inicio)::text from public.nomina_empleados),
    'nomina_ultima',
      (select max(periodo_fin)::text from public.nomina_empleados),
    'compras_filas',
      (select count(*) from public.compras),
    'compras_pendientes_cxp',
      (select round(sum(total), 2) from public.compras
        where estado::text = 'pendiente'),
    'recepciones_confirmadas',
      (select count(*) from public.recepciones
        where estado::text = 'confirmada'),
    'recepciones_total_ticket_confirmadas',
      (select round(sum(total_ticket), 2) from public.recepciones
        where estado::text = 'confirmada'),
    'pagos_servicio_filas',
      (select count(*) from public.pagos_servicio),
    'pagos_servicio_cobrado',
      (select round(sum(total_cobrado), 2) from public.pagos_servicio),
    'pagos_servicio_comision',
      (select round(sum(comision), 2) from public.pagos_servicio),
    'merma_lotes_vencidos_piezas',
      (select coalesce(sum(cantidad_actual), 0) from public.lotes
        where coalesce(activo, true)
          and coalesce(cantidad_actual, 0) > 0
          and fecha_caducidad is not null
          and fecha_caducidad < current_date),
    'merma_lotes_vencidos_a_costo',
      (select round(sum(cantidad_actual * costo_unitario), 2) from public.lotes
        where coalesce(activo, true)
          and coalesce(cantidad_actual, 0) > 0
          and fecha_caducidad is not null
          and fecha_caducidad < current_date
          and coalesce(costo_unitario, 0) > 0),
    'tabla_gastos_existe',
      exists (
        select 1 from information_schema.tables
        where table_schema = 'public' and table_name = 'gastos'
      ),
    'aviso',
      'Compras y recepciones NO van al P&L. Nómina vacía + utilidad operativa = el mismo pecado del 0.55 al revés.'
  ) as derivados_disponibles;
