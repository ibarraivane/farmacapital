-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Equilibrio folio 452626 · 21-nov-2026 · $858.58 · 7 renglones / 20 pzas
-- Pedido online Iztapalapa 2 · cliente 307513 Palillero.
-- Merge a GitHub NO crea la tarjeta. Este Run sí.
-- Sin bloques dollar-quote. Sin galería extra. Idempotente en borrador.
-- Al final: VERIFICACION con folio 452626 en borrador.
-- Luego: tablet Recibir → recargar → tarjeta Equilibrio 452626.
-- =============================================================================

-- Equilibrio · ticket 452626 · 2026-11-21 · Total $858.58
-- (subtotal P.U. $826.52 + IVA $32.06 Eucalin+Lumboxen) · 7 renglones / 20 pzas.
-- Costo = P.U. ticket. Lote de fábrica sí. Caducidad NO: MMAA de la caja. 0000 inválido.
-- 2 altas stock 0 (SAN014 Eucalin 240 · MAV097 Flexiver 7.5). Resto: solo costo / ficha.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.

begin;

create temp table _fc_eq_452626 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text,
  lote text
) on commit drop;

insert into _fc_eq_452626 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '7502009749698', 'FC-09749698', 'Bromhexina/oxeladina', 'MAV414 BROMHE/OXELAD 1 JBE 60/120MG/100/120', 5, 70.81, 89, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Maver', 'Maver', 'Frasco 225 ml', 'Bromhexina / oxeladina', '60 mg/100 ml / 120 mg/100 ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/verxolin-bromhexina-oxeladina-maver-7502009749698.jpg', '265229'),
  (2, '714908100013', 'FC-08100013', 'Eucalin miel y propóleo', 'SAN013 EUCALIN 1 JBE 120 ML', 2, 42.54, 54, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Eucalin', 'Salud Natural', 'Frasco 120 ml', 'Propóleo / gordolobo / sauco / eucalipto / mirra', null, false, true, 'https://www.farmacapital.mx/catalogo-propia/eucalin-miel-120ml.jpg', '26540223'),
  (3, '714908100051', 'FC-08100051', 'Eucalin miel y propóleo', 'SAN014 EUCALIN 1 JBE 240 ML', 1, 72.17, 91, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Eucalin', 'Salud Natural', 'Frasco 240 ml', 'Propóleo / gordolobo / sauco / eucalipto / mirra', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/eucalin-miel-120ml.jpg', '26540153'),
  (4, '7501825300175', 'EQ-DEG011', 'Convifer con hierro', 'DEG011 CONVIFER C/HIERRO 1 SOL 3/2.1MG/110', 1, 33.58, 54, 'generico', 'Medicamentos', 'Vitaminas', 'Solucion oral', 'Convifer', 'Degasa', 'Frasco 110 ml', 'Ciproheptadina / vitaminas / hierro', '3 / 2.1 mg', true, true, null, '367AA'),
  (5, '7502009740466', 'FC-09740466', 'Flexiver 7.5 mg', 'MAV097 FLEXIVER 14 TAB 7.5 MG', 3, 8.36, 11, 'marca', 'Medicamentos', 'Muscular', 'Tabletas', 'Flexiver', 'Maver', 'Caja con 14 tabletas', 'Meloxicam', '7.5 mg', true, false, null, '264120'),
  (6, '7502004401508', 'EQ-OFF009', 'Dexne otico', 'OFF009 DEXNE OTICO 1 GOT 1/3.5/15/10 ML', 5, 42.69, 69, 'generico', 'Medicamentos', 'Otico', 'Gotas oticas', 'Dexne', 'Offene', 'Frasco gotero 10 ml', 'Dexametasona / neomicina / lidocaina', '1 / 3.5 / 15 mg', true, true, null, '261055'),
  (7, '7502009749209', 'FC-09749209', 'Lumboxen parche', 'MAV400 LUMBOXEN 1 BOL C/1 PCHE 03/1.20/1/9%', 3, 14.37, 18, 'marca', 'Medicamentos', 'Muscular', 'Parche', 'Lumboxen', 'Maver', 'Bolsa con 1 parche', 'Capsaicina / alcanfor / mentol / salicilato de metilo', null, false, true, null, '20260331');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Equilibrio 452626 · 2026-11-21 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (ean) *
  from _fc_eq_452626
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (ean) *
  from _fc_eq_452626
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_eq_452626
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '452626',
  '2026-11-21',
  858.58,
  'borrador',
  'Ticket Equilibrio folio 452626 · cliente 307513 Luis Angel · 21-nov-2026 · pedido online Iztapalapa 2 · 20 pzas · $858.58 · lote de fabrica en renglon; MMAA de la caja · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '452626'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 858.58,
  fecha = '2026-11-21',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio folio 452626 · cliente 307513 Luis Angel · 21-nov-2026 · pedido online Iztapalapa 2 · 20 pzas · $858.58 · lote de fabrica en renglon; MMAA de la caja · cola Recibir',
  updated_at = now()
where folio = '452626'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '452626'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and (t.lote is null or l.numero_lote is distinct from t.lote)
    )
  ),
  null
from _fc_eq_452626 t
join public.recepciones r
  on r.folio = '452626'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

-- VERIFICACION
select
  r.proveedor,
  r.folio,
  r.estado,
  r.fecha,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '452626'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.proveedor, r.folio, r.estado, r.fecha, r.total_ticket;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 56) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '452626' and coalesce(r.proveedor, '') ilike '%equilibrio%'
order by i.id;
