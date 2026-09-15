-- Equilibrio · ticket 444555 · 2026-09-15 09:20 · sucursal Iztapalapa 2
-- Pedido online. Total $477.49. Claves NAT0220/NOV138/BMI092 → EAN Levic/Gremfar.
-- Lote de fábrica sí. Caducidad NO: Recibir pide MMAA de la caja. 0000 inválido.
-- Naturex y Novakosid ya estaban; Colagener-3 alta nueva.
-- 1 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_444555 (
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
  foto_file text,
  lote text
) on commit drop;

insert into _fc_eq_444555 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502009741524', 'FC-9741524', 'Naturex colágeno hidrolizado 700 mg C/60', 'NAT0220 COLAGENO 60 TAB 71.42/1.42/700 MG', 2, 38.03, 48, 'marca', 'Vitaminas', 'Colágeno', 'Tabletas', 'Naturex', 'Naturex', 'Caja con 60 tabletas de 700 mg', 'Colágeno hidrolizado', '700 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/naturex-colageno-700mg-c60-7502009741524.jpg', 'catalogo-propia/naturex-colageno-700mg-c60-7502009741524.jpg', '262618'),
  (2, '7501075723137', 'FC-75723137', 'Novakosid senósidos A-B 8.6 mg C/20', 'NOV138 NOVAKOSID 20 TAB 8.6 MG', 10, 13.65, 18, 'marca', 'Gastro', 'Laxante', 'Tabletas', 'Novakosid', 'Novag', 'Caja con 20 tabletas', 'Senósidos A-B', '8.6 mg', false, true, null, null, '540286'),
  (3, '7502266031116', 'FC-66031116', 'Colagener-3 pepino-limón polvo 150 g', 'BMI092 COLAGENER-3 SOB 150 G', 2, 108.95, 137, 'marca', 'Vitaminas', 'Colágeno', 'Polvo', 'Biomiral', 'Biomiral', 'Bolsa doypack 150 g (30 porciones de 5 g)', 'Colágeno hidrolizado + magnesio + vitamina C + biotina', '3 g colágeno / 5 g', false, false, 'https://www.farmacapital.mx/catalogo-propia/colagener-3-pepino-limon-150g-7502266031116.jpg', 'catalogo-propia/colagener-3-pepino-limon-150g-7502266031116.jpg', '26E002');

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
  'Alta Equilibrio 444555 · 2026-09-15 · listo para pistola',
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
from _fc_eq_444555 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_eq_444555 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
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
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_eq_444555 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '444555',
  '2026-09-15',
  477.49,
  'borrador',
  'Ticket Equilibrio 444555 · Iztapalapa 2 · 15-sep-2026 · foto térmica · cliente 307513 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '444555'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 477.49,
  fecha = '2026-09-15',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 444555 · Iztapalapa 2 · 15-sep-2026 · foto térmica · cliente 307513 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '444555'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '444555'
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
  t.nombre,
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
    )
  ),
  null
from _fc_eq_444555 t
join public.recepciones r
  on r.folio = '444555'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'catalogo-propia'
from _fc_eq_444555 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

-- Diagnóstico
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '444555'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_eq_444555 t
order by t.linea;

commit;
