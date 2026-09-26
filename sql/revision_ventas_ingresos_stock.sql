-- Revisión a mano: lo que entró, lo que se vendió y lo que dice el stock.
--
-- No modifica nada. Pegar en Supabase → SQL Editor → Run.
-- Abajo a la derecha, Download CSV. Arriba quedan los que no cuadran.
--
-- Cómo leer cada fila
--   ingreso     piezas de tickets ya confirmados (cada renglón una vez)
--   vendido     piezas de pedidos que no están cancelados
--   devuelto    piezas que volvieron al anaquel en una devolución aprobada
--   debe_haber  ingreso − vendido + devuelto
--   stock       lo que dice el sistema hoy
--   diferencia  stock − debe_haber
--               0  cuadra
--               +  el sistema tiene de más (copia de ticket o reintegro)
--               −  el sistema tiene de menos
--   de_mas_en_lotes  lo que se creó en lotes por encima del ticket.
--               Una venta no mueve este número: si es mayor que 0, el
--               lote se cargó de más.
--   revision    el texto para filtrar en la hoja.
--
-- El conteo del anaquel lo anotas tú al lado. Esta hoja no lo trae.
-- Pedidos cancelados no cuentan como venta.

with ventas as (
  select i.producto_id, sum(i.cantidad)::integer as vendido
  from public.pedido_items i
  join public.pedidos p on p.id = i.pedido_id
  where coalesce(p.estado::text, '') not in ('cancelado', 'anulado', 'cancelada')
  group by i.producto_id
),
devuelto as (
  select di.producto_id, sum(di.cantidad)::integer as devuelto
  from public.devolucion_items di
  join public.devoluciones d on d.id = di.devolucion_id
  where d.estado = 'aprobada'
    and coalesce(di.es_entrada, false)
    and di.producto_id is not null
  group by di.producto_id
),
ingresos as (
  select i.producto_id, sum(i.cantidad)::integer as ingreso
  from public.recepcion_items i
  join public.recepciones r on r.id = i.recepcion_id
  where i.producto_id is not null
    and coalesce(i.confirmado, false)
    and coalesce(r.estado::text, '') not in ('cancelada', 'cancelado', 'anulada')
  group by i.producto_id
),
lotes as (
  select
    l.producto_id,
    sum(coalesce(l.cantidad_inicial, 0))::integer as posteado,
    coalesce(sum(l.cantidad_actual) filter (
      where coalesce(l.activo, true)
        and l.numero_lote like 'REINTEGRO-%'
    ), 0)::integer as piezas_en_reintegro
  from public.lotes l
  group by l.producto_id
),
copias as (
  select producto_id, count(*)::integer as lotes_repetidos
  from (
    select l.producto_id, l.numero_lote
    from public.lotes l
    where coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
      and nullif(btrim(l.numero_lote), '') is not null
    group by l.producto_id, l.numero_lote
    having count(*) > 1
  ) d
  group by producto_id
),
fila as (
  select
    p.sku,
    p.nombre,
    p.codigo_barras as ean,
    coalesce(i.ingreso, 0) as ingreso,
    coalesce(v.vendido, 0) as vendido,
    coalesce(dv.devuelto, 0) as devuelto,
    coalesce(i.ingreso, 0) - coalesce(v.vendido, 0) + coalesce(dv.devuelto, 0) as debe_haber,
    coalesce(p.stock, 0) as stock,
    coalesce(p.stock_unidades, 0) as piezas_sueltas,
    coalesce(p.stock, 0)
      - (coalesce(i.ingreso, 0) - coalesce(v.vendido, 0) + coalesce(dv.devuelto, 0)) as diferencia,
    coalesce(l.posteado, 0) as entro_a_lotes,
    coalesce(l.posteado, 0) - coalesce(i.ingreso, 0) as de_mas_en_lotes,
    coalesce(l.piezas_en_reintegro, 0) as piezas_en_reintegro,
    coalesce(c.lotes_repetidos, 0) as lotes_repetidos,
    case
      when coalesce(i.ingreso, 0) = 0
        and (coalesce(p.stock, 0) > 0 or coalesce(v.vendido, 0) > 0)
        then 'sin ticket en historia'
      when coalesce(p.stock, 0)
        - (coalesce(i.ingreso, 0) - coalesce(v.vendido, 0) + coalesce(dv.devuelto, 0)) > 0
        or coalesce(l.posteado, 0) - coalesce(i.ingreso, 0) > 0
        or coalesce(c.lotes_repetidos, 0) > 0
        or coalesce(l.piezas_en_reintegro, 0) > 0
        then 'sistema de mas'
      when coalesce(p.stock, 0)
        - (coalesce(i.ingreso, 0) - coalesce(v.vendido, 0) + coalesce(dv.devuelto, 0)) < 0
        then 'sistema de menos'
      else 'cuadra'
    end as revision
  from public.productos p
  left join ventas v on v.producto_id = p.id
  left join devuelto dv on dv.producto_id = p.id
  left join ingresos i on i.producto_id = p.id
  left join lotes l on l.producto_id = p.id
  left join copias c on c.producto_id = p.id
  where coalesce(p.activo, true)
     or coalesce(p.stock, 0) <> 0
)
select *
from fila
where ingreso <> 0
   or vendido <> 0
   or devuelto <> 0
   or stock <> 0
   or entro_a_lotes <> 0
order by
  case revision
    when 'sistema de mas' then 0
    when 'sistema de menos' then 1
    when 'sin ticket en historia' then 2
    else 3
  end,
  abs(diferencia) desc,
  de_mas_en_lotes desc,
  sku;
