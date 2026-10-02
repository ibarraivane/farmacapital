-- Nadro · factura 6090680530 · 2026-10-01 · 10 pzas · $777.49
-- Bepanthen = pomada regeneradora 5% 30 g EAN 7501008498798 (ficha Farmatodo/Fahorro).
-- Budesonida LGEN Dankel = Dankial-B 0.250 mg/2 mL C/5 EAN 7502256040517.
-- Derman 25 g EAN 354312225010 (no es el de 50 g).
-- Histiacil NF AD = EAN canónico 7501328979502 (OCR del papel confundía dígitos).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 2 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_nd_6090680530 (
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

insert into _fc_nd_6090680530 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501008498798', 'FC-08498798', 'Bepanthen pomada regeneradora 5%', 'BEPANTHEN 5% PIPEL REGENE 30G POM', 2, 63.25, 80, 'marca', 'Dermocosmético', 'Piel', 'Pomada', 'Bepanthen', 'Bayer OTC', 'Tubo 30 g', 'Dexpantenol', '5%', false, true, 'https://www.farmacapital.mx/catalogo-propia/bepanthen-regeneradora-30g-7501008498798.jpg', 'catalogo-propia/bepanthen-regeneradora-30g-7501008498798.jpg', null),
  (2, '7502256040517', 'FC-56040517', 'Dankial-B budesonida 0.250 mg/2 mL C/5', 'BUDESONIDA 250MG 5X2ML AMP LGEN', 3, 88.24, 142, 'generico', 'Respiratorio', null, 'Suspensión para nebulizar', 'Dankial-B', 'Dankel', 'Caja con 5 ampolletas de 2 mL', 'Budesonida', '0.250 mg/2 mL', true, false, 'https://www.farmacapital.mx/catalogo-propia/dankial-b-budesonida-0250-c5-7502256040517.jpg', 'catalogo-propia/dankial-b-budesonida-0250-c5-7502256040517.jpg', null),
  (3, '354312225010', 'FC-12225010', 'Derman crema antimicótica', 'DERMAN 25 G CRA', 2, 27.46, 35, 'marca', 'Dermocosmético', 'Antimicótico', 'Crema', 'Derman', 'Int. Comercio', 'Tubo 25 g', 'Ácido undecilénico / undecilenato de zinc', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/derman-crema-25g-354312225010.jpg', 'catalogo-propia/derman-crema-25g-354312225010.jpg', null),
  (4, '7501328979502', 'FC-28979502', 'Histiacil NF adulto jarabe', 'HISTIACIL-NF AD 150ML JBE', 3, 110.45, 139, 'marca', 'Respiratorio', null, 'Jarabe', 'Histiacil', 'Sanofi / Opella', 'Frasco 150 mL', 'Dextrometorfano / ambroxol', '225 mg / 225 mg por 100 mL', false, true, 'https://www.farmacapital.mx/catalogo-propia/histiacil-nf-adulto-150ml-7501328979502.jpg', 'catalogo-propia/histiacil-nf-adulto-150ml-7501328979502.jpg', null);

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
  'Alta Nadro 6090680530 · 2026-10-01 · listo para pistola',
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
  from _fc_nd_6090680530
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
  from _fc_nd_6090680530
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
  from _fc_nd_6090680530
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6090680530',
  '2026-10-01',
  777.49,
  'borrador',
  'Factura Nadro 6090680530 · 01-oct-2026 · UUID 2FCABA… · sucursal México Sur · Palillero · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '6090680530'
    and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 777.49,
  fecha = '2026-10-01',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6090680530 · 01-oct-2026 · UUID 2FCABA… · sucursal México Sur · Palillero · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '6090680530'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6090680530'
  and coalesce(r.proveedor, '') ilike '%nadro%'
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
from _fc_nd_6090680530 t
join public.recepciones r
  on r.folio = '6090680530'
 and coalesce(r.proveedor, '') ilike '%nadro%'
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
  'propia'
from _fc_nd_6090680530 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
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
where r.folio = '6090680530'
  and coalesce(r.proveedor, '') ilike '%nadro%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_nd_6090680530 t
order by t.linea;

commit;
