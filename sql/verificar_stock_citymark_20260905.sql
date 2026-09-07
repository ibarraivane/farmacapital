-- City Mark 20260905 — ¿entró el stock? Solo lectura.
-- Pegar en Supabase → SQL Editor → Run.
-- Stock 0 + sin lote = el alta existe, pero Recibir aún no escaneó MMAA.

select
  p.codigo_barras as ean,
  p.sku,
  left(p.nombre, 52) as nombre,
  p.marca,
  p.stock as stock_producto,
  coalesce((
    select sum(l.cantidad_actual)
    from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0) as stock_lotes,
  (
    select min(l.fecha_caducidad)
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
      and l.fecha_caducidad is not null
  ) as caducidad_mas_proxima
from public.productos p
where p.codigo_barras in (
  '7891010245160','761318132592','761318128335','761318020639','7502221187575',
  '7506306215511','7506306215528','7506306209763','75065102','75068639',
  '75068622','75064891','7501082736021','7506309864839','7501027286000',
  '7506309864822','7501027286017','7501082731071','7506306251847','7509546029139',
  '7500435141796','7509552906158','7509552844825','7509546071275','78924338',
  '7506306226852','7500435129367','7506306209862','7791293025919','7509546057545',
  '7509546015514','7506306209855','7509546029153','78924345','7509546060477',
  '7506339349146','7501027250612','7501082790481','7502221012303','7509546029825',
  '7501022107201','7509546007083','037836007279','037836084508','759684900204',
  '7509546651743','7501056330378','759684900259','814266022627','7509546694702',
  '7509546073774','7509546078434','7506267917516','7509546655055','3600542478359',
  '7501035911024','7509546068909','7506425629442','7702018913954','7500435168991',
  '7509546698137','78926523','7509546674018','7509546000350','7509546654997',
  '814266022610','7500435169035','7891024028827','3616303440534','7506267923654',
  '7896015592837','3616303441173','759684900280','7891024027363','3616303842550',
  '3616303441302','3616303842420','7891024183182','070942302463','759684313295',
  '75075996','7509552780956','070942303460','7501033204920'
)
order by
  coalesce((
    select sum(l.cantidad_actual)
    from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0) desc,
  p.nombre;

-- Recibir: renglones del ticket vs anaquel
select
  i.codigo_escaneado as ean,
  left(coalesce(p.nombre, i.nombre_snapshot), 48) as nombre,
  i.cantidad as qty_ticket,
  i.confirmado,
  i.pendiente_alta,
  i.fecha_caducidad,
  i.lote_id is not null as en_anaquel,
  p.stock
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '20260905'
  and coalesce(r.proveedor, '') ilike '%city mark%'
order by i.pendiente_alta desc, (i.lote_id is null) desc, i.id;

select
  count(*) as renglones,
  count(*) filter (where not i.pendiente_alta) as en_catalogo,
  count(*) filter (where i.pendiente_alta) as siguen_sin_alta,
  count(*) filter (where i.lote_id is not null) as con_stock,
  count(*) filter (where i.confirmado and i.lote_id is null) as verde_sin_lote
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '20260905'
  and coalesce(r.proveedor, '') ilike '%city mark%';
