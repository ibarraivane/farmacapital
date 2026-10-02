-- Auditoría de discrepancias de stock (2-oct-2026).
-- Caso disparador: Bepanthen Protectora FC-08427330 con 30232 (debería ser 0).
-- Solo lectura. Pegar en Supabase → SQL Editor → Run.
--
-- Cómo se infla el número (el 30232 no es un conteo):
--   1) Concatenación JS/SQL: stock texto "30" (de 30 g) + 232 = "30232".
--   2) Recibir / pistola: la cantidad del renglón tomó el gramaje o un
--      escaneo extra, y se grabó un lote con esa cifra.
--   3) OCR de ticket: el parser pega el "30" del nombre como qty
--      (visto en Multiusos «Pomada Otc 30»).
--
-- productos.stock es caché: trg_sync_productos_stock = sum(lotes activos).
-- Si el catálogo dice 30232, hay lote(s) con esa suma.

-- 1) El caso: ficha + lotes + movimientos + recepción + ventas
select
  '1_ficha' as seccion,
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.presentacion,
  p.stock as stock_catalogo,
  p.updated_at,
  coalesce((
    select sum(l.cantidad_actual)
    from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0) as stock_lotes
from public.productos p
where p.sku = 'FC-08427330' or p.id = 445 or p.nombre ilike '%bepanthen%';

select
  '1_lotes' as seccion,
  l.id,
  l.numero_lote,
  l.cantidad_inicial,
  l.cantidad_actual,
  l.activo,
  l.fecha_caducidad,
  l.fecha_recepcion,
  l.created_at
from public.lotes l
where l.producto_id = 445
order by coalesce(l.cantidad_actual, 0) desc, l.id desc;

select
  '1_movimientos' as seccion,
  m.id,
  m.created_at,
  m.tipo,
  m.cantidad,
  m.motivo,
  m.usuario_id
from public.movimientos_inventario m
where m.producto_id = 445
order by m.id desc
limit 80;

select
  '1_recepcion' as seccion,
  r.folio,
  r.estado,
  r.proveedor,
  r.created_at,
  i.codigo_escaneado,
  i.cantidad,
  i.confirmado,
  left(i.nombre_snapshot, 60) as snap
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where i.producto_id = 445
   or i.codigo_escaneado in ('7501008427347', '7501008427330')
order by r.created_at desc;

select
  '1_ventas' as seccion,
  ped.id as pedido_id,
  ped.created_at,
  ped.folio,
  ped.estado,
  i.cantidad,
  i.precio_unitario
from public.pedido_items i
join public.pedidos ped on ped.id = i.pedido_id
where i.producto_id = 445
order by ped.created_at desc
limit 50;

-- 2) Catálogo vs lotes (el trigger debió dejar diferencia 0)
select
  '2_desfase_catalogo_lotes' as seccion,
  p.id,
  p.sku,
  left(p.nombre, 48) as nombre,
  p.stock as stock_catalogo,
  coalesce(s.lotes, 0) as stock_lotes,
  p.stock - coalesce(s.lotes, 0) as diferencia
from public.productos p
left join (
  select producto_id, sum(cantidad_actual) as lotes
  from public.lotes
  where coalesce(activo, true)
  group by producto_id
) s on s.producto_id = p.id
where coalesce(p.activo, true)
  and coalesce(p.stock, 0) is distinct from coalesce(s.lotes, 0)
order by abs(p.stock - coalesce(s.lotes, 0)) desc
limit 40;

-- 3) Stocks absurdos o gramaje concatenado (30 g → 30232)
select
  '3_sospechosos' as seccion,
  p.id,
  p.sku,
  left(p.nombre, 48) as nombre,
  p.presentacion,
  p.stock,
  p.updated_at,
  case
    when coalesce(p.stock, 0) > 500 then 'absurdo_>500'
    when p.presentacion ~* '([0-9]+)\s*(g|gr|ml)\y'
     and p.stock::text like (substring(p.presentacion from '([0-9]+)\s*(?:g|gr|ml)') || '%')
     and char_length(p.stock::text) > char_length(substring(p.presentacion from '([0-9]+)'))
      then 'concat_gramaje'
    else 'alto'
  end as senal
from public.productos p
where coalesce(p.activo, true)
  and coalesce(p.bajo_pedido, false) = false
  and (
    coalesce(p.stock, 0) > 500
    or (
      p.presentacion ~* '([0-9]+)\s*(g|gr|ml)\y'
      and p.stock::text like (substring(p.presentacion from '([0-9]+)\s*(?:g|gr|ml)') || '%')
      and char_length(p.stock::text) > char_length(substring(p.presentacion from '([0-9]+)'))
      and coalesce(p.stock, 0) >= 100
    )
  )
order by p.stock desc;

-- 4) Compras confirmadas − ventas vs stock (reconstrucción)
select
  '4_compras_menos_ventas' as seccion,
  p.id,
  p.sku,
  left(p.nombre, 48) as nombre,
  p.stock as stock_hoy,
  coalesce(c.comprado, 0) as comprado_confirmado,
  coalesce(v.vendido, 0) as vendido,
  coalesce(c.comprado, 0) - coalesce(v.vendido, 0) as esperado,
  p.stock - (coalesce(c.comprado, 0) - coalesce(v.vendido, 0)) as hueco
from public.productos p
left join (
  select i.producto_id, sum(i.cantidad) as comprado
  from public.recepcion_items i
  join public.recepciones r on r.id = i.recepcion_id
  where coalesce(i.confirmado, false)
    and coalesce(r.estado, '') not in ('cancelada', 'cancelado', 'anulada')
  group by i.producto_id
) c on c.producto_id = p.id
left join (
  select i.producto_id, sum(i.cantidad) as vendido
  from public.pedido_items i
  join public.pedidos ped on ped.id = i.pedido_id
  where coalesce(ped.estado::text, '') not in ('cancelado', 'anulado')
  group by i.producto_id
) v on v.producto_id = p.id
where coalesce(p.activo, true)
  and coalesce(p.bajo_pedido, false) = false
  and abs(p.stock - (coalesce(c.comprado, 0) - coalesce(v.vendido, 0))) >= 5
order by abs(p.stock - (coalesce(c.comprado, 0) - coalesce(v.vendido, 0))) desc
limit 60;

-- 5) Movimientos el día que se actualizó el Bepanthen (1-oct-2026 03:14 UTC)
select
  '5_movimientos_1oct' as seccion,
  m.created_at,
  p.sku,
  left(p.nombre, 40) as nombre,
  m.tipo,
  m.cantidad,
  m.motivo
from public.movimientos_inventario m
join public.productos p on p.id = m.producto_id
where m.created_at >= '2026-10-01 03:00:00+00'
  and m.created_at <  '2026-10-01 04:00:00+00'
order by m.created_at, m.id;
