-- =============================================================================
-- FARMA CAPITAL — Diagnóstico de cobertura de lotes ANTES de recibir mercancía
-- Solo lectura. No modifica nada. Pegar entero en Supabase → SQL Editor.
-- Objetivo: saber si todo el inventario está anclado a un lote con caducidad
--           real, para que al entrar el lote nuevo la diferencia tenga sentido.
-- =============================================================================

-- ── 1) RESUMEN GENERAL ───────────────────────────────────────────────────────
select
  (select count(*) from public.productos where coalesce(activo,true))                        as productos_activos,
  (select count(*) from public.productos where coalesce(activo,true) and stock > 0)          as productos_con_stock,
  (select count(*) from public.lotes    where coalesce(activo,true) and cantidad_actual > 0) as lotes_vivos,
  (select count(*) from public.lotes    where coalesce(activo,true) and cantidad_actual > 0
                                          and fecha_caducidad is null)                        as lotes_vivos_SIN_caducidad,
  (select count(*) from public.lotes    where coalesce(activo,true) and cantidad_actual > 0
                                          and fecha_caducidad < current_date)                 as lotes_vivos_VENCIDOS,
  (select count(*) from public.productos p
     where coalesce(p.activo,true) and p.stock > 0
       and not exists (select 1 from public.lotes l
                       where l.producto_id = p.id
                         and coalesce(l.activo,true) and coalesce(l.cantidad_actual,0) > 0)) as productos_CON_stock_SIN_lote;

-- ── 2) ¿Cuántos lotes son "sintéticos"? (creados por backfill, no por compra) ─
-- Estos existen solo para que el stock viejo tuviera dónde vivir. Casi siempre
-- y en FEFO se venden PRIMERO (nulls first, patch_recepcion_fefo_caducidad_20260821).
select
  case
    when numero_lote like 'SIN-LOTE-%' then 'SIN-LOTE (backfill)'
    when numero_lote like 'SYNC-%'     then 'SYNC (venta sin lote)'
    when numero_lote like 'INV-%'      then 'INV (caducidad manual)'
    when numero_lote like 'RX-%'       then 'RX (recepción sin folio)'
    else 'LOTE REAL (capturado)'
  end as origen,
  count(*)                                              as lotes,
  sum(cantidad_actual)                                  as piezas,
  count(*) filter (where fecha_caducidad is null)       as sin_caducidad
from public.lotes
where coalesce(activo,true) and coalesce(cantidad_actual,0) > 0
group by 1
order by piezas desc;

-- ── 3) PROBLEMA A: stock sin ningún lote ────────────────────────────────────
-- El POS les inventa un lote SYNC al vender. Hay que asignarles caducidad.
select p.sku, p.nombre, p.stock, p.costo
from public.productos p
where coalesce(p.activo,true) and p.stock > 0
  and not exists (
    select 1 from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo,true) and coalesce(l.cantidad_actual,0) > 0)
order by p.stock desc;

-- ── 4) PROBLEMA B: lotes con piezas pero SIN fecha de caducidad ─────────────
-- Estos son los que FEFO vende primero (stock ciego). Hay que ponerles fecha de la caja.
select p.sku, p.nombre, l.id as lote_id, l.numero_lote, l.cantidad_actual, l.costo_unitario
from public.lotes l
join public.productos p on p.id = l.producto_id
where coalesce(l.activo,true) and coalesce(l.cantidad_actual,0) > 0
  and l.fecha_caducidad is null
order by l.cantidad_actual desc;

-- ── 5) PROBLEMA C: lotes ya vencidos que siguen sumando al stock ────────────
-- productos.stock los cuenta (el trigger no filtra fecha), pero el POS no los
-- deja vender → "stock insuficiente" con existencia en pantalla.
select p.sku, p.nombre, l.id as lote_id, l.numero_lote,
       l.fecha_caducidad, l.cantidad_actual,
       (current_date - l.fecha_caducidad) as dias_vencido
from public.lotes l
join public.productos p on p.id = l.producto_id
where coalesce(l.activo,true) and coalesce(l.cantidad_actual,0) > 0
  and l.fecha_caducidad < current_date
order by l.fecha_caducidad;

-- ── 6) DESAJUSTE productos.stock vs suma de lotes ───────────────────────────
-- Debería salir 0 filas. Si sale algo, el trigger de resync se saltó un caso.
select p.sku, p.nombre, p.stock as stock_cacheado,
       coalesce((select sum(l.cantidad_actual) from public.lotes l
                 where l.producto_id = p.id and coalesce(l.activo,true)),0) as suma_lotes
from public.productos p
where coalesce(p.activo,true)
  and p.stock <> coalesce((select sum(l.cantidad_actual) from public.lotes l
                           where l.producto_id = p.id and coalesce(l.activo,true)),0)
order by abs(p.stock - coalesce((select sum(l.cantidad_actual) from public.lotes l
                                 where l.producto_id = p.id and coalesce(l.activo,true)),0)) desc;

-- ── 7) Productos que YA tienen 2+ lotes vivos (el caso que viene hoy) ───────
-- Sirve como referencia visual de cómo se va a ver el inventario multi-lote.
select p.sku, p.nombre,
       count(l.id)                     as lotes_vivos,
       sum(l.cantidad_actual)          as piezas_totales,
       min(l.fecha_caducidad)          as caduca_primero,
       max(l.fecha_caducidad)          as caduca_ultimo
from public.productos p
join public.lotes l on l.producto_id = p.id
where coalesce(l.activo,true) and coalesce(l.cantidad_actual,0) > 0
group by p.id, p.sku, p.nombre
having count(l.id) > 1
order by lotes_vivos desc, piezas_totales desc;
