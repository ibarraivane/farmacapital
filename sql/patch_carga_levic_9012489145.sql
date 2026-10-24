-- Levic · folio A 9012489145 · 2026-10-18 · CFDI 4.0
-- Entrega a FarmaCapital. 2 pzas · total $558.72 (IVA 0%).
-- Costo = precio neto. MAV352 Dexal susp EAN 7502009747335 · WES008 Fossin EAN 7501300450012.
-- Lote de fábrica sí. Caducidad del papel NO (MMAA de la caja). 0000 inválido.
-- 2 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_lv_9012489145 (
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

insert into _fc_lv_9012489145 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502009747335', 'FC-09747335', 'Dexal ceftibuteno', 'MAV352 DEXAL 1 SUSP 30 ML', 1, 166.22, 208, 'marca', 'Medicamentos', 'Antibiótico', 'Suspensión', 'Dexal', 'Maver', 'Frasco polvo para 30 mL', 'Ceftibuteno', '36 mg/mL', true, false, 'https://www.farmacapital.mx/catalogo-propia/dexal-ceftibuteno-suspension-30ml-7502009747335.jpg', 'catalogo-propia/dexal-ceftibuteno-suspension-30ml-7502009747335.jpg', '256898'),
  (2, '7501300450012', 'FC-30045001', 'Fossin fosfomicina 500 mg', 'WES008 FOSSIN 12 CAPS 500 MG', 1, 392.50, 491, 'marca', 'Medicamentos', 'Antibiótico', 'Cápsula', 'Fossin', 'Weser Pharma', 'Caja con 12 cápsulas', 'Fosfomicina', '500 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/fossin-fosfomicina-500mg-12caps-7501300450012.jpg', 'catalogo-propia/fossin-fosfomicina-500mg-12caps-7501300450012.jpg', '261380');

-- Una fila por EAN (mismo producto con 2 lotes no debe insertar 2 veces el SKU).
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
  'Alta Levic 9012489145 · 2026-10-18 · listo para pistola',
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
  from _fc_lv_9012489145
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (ean) *
  from _fc_lv_9012489145
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
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_lv_9012489145
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Levic',
  '9012489145',
  '2026-10-18',
  558.72,
  'borrador',
  'Factura Levic A 9012489145 · 18-oct-2026 · UUID 4F8597D0-76C7-4026-B18F-C43769D9EE39 · 2 renglones / 2 pzas · $558.72 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '9012489145'
    and coalesce(proveedor, '') ilike '%levic%'
);

update public.recepciones
set
  total_ticket = 558.72,
  fecha = '2026-10-18',
  proveedor = 'Levic',
  notas = 'Factura Levic A 9012489145 · 18-oct-2026 · UUID 4F8597D0-76C7-4026-B18F-C43769D9EE39 · 2 renglones / 2 pzas · $558.72 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '9012489145'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012489145'
  and coalesce(r.proveedor, '') ilike '%levic%'
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
from _fc_lv_9012489145 t
join public.recepciones r
  on r.folio = '9012489145'
 and coalesce(r.proveedor, '') ilike '%levic%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

-- Una foto por (producto, url): tickets con 2 renglones del mismo EAN
-- (promo 2+1) no deben insertar dos veces la misma URL.
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
  'propia'
from (
  select distinct on (ean, imagen) *
  from _fc_lv_9012489145
  where imagen is not null
  order by ean, imagen, linea
) t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where not exists (
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
where r.folio = '9012489145'
  and coalesce(r.proveedor, '') ilike '%levic%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_lv_9012489145 t
order by t.linea;

commit;
