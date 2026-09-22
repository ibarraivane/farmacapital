-- Equilibrio · ticket 445246 · 2026-09-21 · sucursal Iztapalapa 2
-- Pedido online. Total $1,612.20 · 12 renglones / 42 pzas.
-- Claves EQF → EAN Levic/ficha. Postday 2 comp = 7501249605634.
-- Lote de fábrica sí. Caducidad NO: MMAA de la caja. 0000 inválido.
-- 4 alta(s) stock 0. 8 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_445246 (
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

insert into _fc_eq_445246 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502216806474', 'EQ-ULT230', 'Levonorgestrel 1.5 mg tableta', 'ULT230 LEVONORGESTREL 1 TAB 1.5 MG', 5, 15.61, 25, 'generico', 'Medicamentos', null, 'Tableta', 'Ultra', 'Ultra', 'Caja con 1 tableta', 'Levonorgestrel', '1.5 mg', false, true, null, null, '6EH152A'),
  (2, '785118754259', 'FC-18754259', 'Supratex levodropropizina jarabe 120 mL', 'MAI157 SUPRATEX 1 JBE 600 MG 120 ML', 3, 41.30, 67, 'generico', 'Medicamentos', null, 'Jarabe', 'Supratex', 'MAVI', 'Frasco 120 mL', 'Levodropropizina', '600 mg/100 mL', false, true, null, null, '6B0201'),
  (3, '7502213042325', 'EQ-HIS075', 'Terfhicid nitrofurantoína 100 mg C/40', 'HIS075 TERFHICID 40 CAPS 100 MG', 3, 46.05, 74, 'generico', 'Medicamentos', null, 'Cápsula', 'Terfhicid', 'Farmacéutica Hispanoamericana', 'Caja con 40 cápsulas', 'Nitrofurantoína', '100 mg', true, true, null, null, '6F719'),
  (4, '7501249605634', 'FC-49605634', 'Postday levonorgestrel 0.75 mg C/2', 'IFA002 POSTDAY 2 COMP 0.75 MG', 9, 48.57, 78, 'generico', 'Medicamentos', null, 'Tableta', 'Postday', 'IFA Celtics', 'Caja con 2 tabletas', 'Levonorgestrel', '0.75 mg', true, false, null, null, '2510245'),
  (5, '7501125100116', 'FC-25100116', 'Solución CS Pisa cloruro de sodio 0.9% 250 mL', 'PIS103 SOLUCION CLORURO DE SODIO 0.9%/250 ML', 3, 26.50, 43, 'generico', 'Medicamentos', null, 'Solución', 'CS Pisa', 'Pisa', 'Frasco 250 mL', 'Cloruro de sodio', '0.9%', false, true, null, null, 'P26E310'),
  (6, '7503003406327', 'FC-03406327', 'Algodón plisado Quirmex 50 g', 'QIR002 ALGODON PLISADO 1 BOL 50 G', 3, 8.23, 11, 'marca', 'Botiquín', 'Material de curación', 'Algodón', 'Quirmex', 'Quirmex', 'Bolsa 50 g', null, null, false, false, null, null, 'A3361326'),
  (7, '7502009740992', 'FC-5F30F9D4', 'Clamoxin amoxicilina/clavulánico 500/125 mg C/10', 'MAV111 CLAMOXIN 10 TAB 500/125 MG', 2, 48.51, 78, 'generico', 'Medicamentos', null, 'Tableta', 'Clamoxin', 'MAVI', 'Caja con 10 tabletas', 'Amoxicilina / ácido clavulánico', '500/125 mg', true, true, null, null, '262922'),
  (8, '7502226291857', 'FC-26291857', 'Doxiciclina Alpharma 100 mg C/10', 'ALP0559 DOXICICLINA 10 TAB 100 MG', 3, 29.08, 47, 'generico', 'Medicamentos', null, 'Tableta', 'Alpharma', 'Alpharma', 'Caja con 10 tabletas', 'Doxiciclina', '100 mg', true, false, null, null, '2511579'),
  (9, '7502009745836', 'EQ-MAV266', 'Berniver mupirocina 2% ungüento 15 g', 'MAV266 BERNIVER 2% 1 UNG 15 G', 3, 76.79, 123, 'generico', 'Medicamentos', null, 'Ungüento', 'Berniver', 'Maver', 'Tubo 15 g', 'Mupirocina', '2%', false, true, null, null, '260074'),
  (10, '7502004401454', 'EQ-OFF010', 'Dexne oftálmico dexametasona/neomicina gotas 5 mL', 'OFF010 DEXNE OFTALMICO 1 GOT 500/100MG/5 ML', 2, 33.74, 54, 'generico', 'Medicamentos', null, 'Gotas oftálmicas', 'Dexne', 'Offenbach', 'Frasco gotero 5 mL', 'Dexametasona / neomicina', '500/100 mg/5 mL', true, true, null, null, '265030'),
  (11, '7501342803807', 'EQ-BEA368', 'Nifedipino 30 mg C/30 LP', 'BEA368 NIFEDIPINO 30 COMP 30 MG', 5, 39.23, 63, 'generico', 'Medicamentos', null, 'Tableta', 'Be Advance', 'Be Advance', 'Caja con 30 comprimidos LP', 'Nifedipino', '30 mg', true, true, null, null, '6EN186A'),
  (12, '7501249605634', 'FC-49605634', 'Postday levonorgestrel 0.75 mg C/2', 'IFA002 POSTDAY 2 COMP 0.75 MG', 1, 48.57, 78, 'generico', 'Medicamentos', null, 'Tableta', 'Postday', 'IFA Celtics', 'Caja con 2 tabletas', 'Levonorgestrel', '0.75 mg', true, false, null, null, '2603328');

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
  'Alta Equilibrio 445246 · 2026-09-21 · listo para pistola',
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
  from _fc_eq_445246
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
  from _fc_eq_445246
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
  from _fc_eq_445246
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '445246',
  '2026-09-21',
  1612.20,
  'borrador',
  'Ticket Equilibrio 445246 · Iztapalapa 2 · pedido online · cliente 307513 Palillero · 21-sep-2026 · lote de fábrica en papel · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '445246'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 1612.20,
  fecha = '2026-09-21',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 445246 · Iztapalapa 2 · pedido online · cliente 307513 Palillero · 21-sep-2026 · lote de fábrica en papel · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '445246'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '445246'
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
from _fc_eq_445246 t
join public.recepciones r
  on r.folio = '445246'
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
  'propia'
from _fc_eq_445246 t
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
where r.folio = '445246'
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
from _fc_eq_445246 t
order by t.linea;

commit;
