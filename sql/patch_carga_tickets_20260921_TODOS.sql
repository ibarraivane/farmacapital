-- ═══════════════════════════════════════════════════════════════
-- TICKETS 21-SEP-2026 · PEGAR EN SUPABASE (uno por uno o todo)
-- Ver LEERME_tickets_20260921.md
-- ═══════════════════════════════════════════════════════════════


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_equilibrio_445246.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
from _fc_eq_445246 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_eq_445246 t
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
from _fc_eq_445246 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

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


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_cityfarma_s324509.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Cityfarma Iztapalapa · orden S324509 · 2026-09-21 16:52
-- Ticket térmico. Subtotal $2,663.37 + IVA 16% $191.74 = $2,855.11.
-- Erbitrax C/28 EAN 7502211783787 · Vessel Due-F 8020030091252 alta.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 3 alta(s) stock 0. 5 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s324509 (
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

insert into _fc_cf_s324509 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '4015630082988', 'FC-30082988', 'Accu-Chek Active glucómetro', 'ACCU CHEK EQ ACTIVE', 1, 499.99, 625, 'marca', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 'Accu-Chek', 'Roche', '1 pieza', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/medidor-accu-chek-active-4015630082988.jpg', 'medidor-accu-chek-active-4015630082988.jpg', null),
  (2, '4015630018277', 'FC-30018277', 'Accu-Chek Softclix lancetas C/25', 'ACCU CHEK SOFTCLIX C', 2, 72.42, 91, 'marca', 'Dispositivo médico', 'Lancetas', 'Lancetas', 'Accu-Chek', 'Roche', 'Caja con 25 lancetas', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/lanceta-accu-chek-softclix-25pzas-4015630018277.jpg', 'lanceta-accu-chek-softclix-25pzas-4015630018277.jpg', null),
  (3, '799192067426', 'FC-92067426', 'Accu-Chek Instant kit 50 tiras + 25 lancetas', 'ACCU-CHEK EQ INSTANT', 1, 681.33, 852, 'marca', 'Dispositivo médico', 'Diagnóstico', 'Kit', 'Accu-Chek', 'Roche', 'Kit glucómetro', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/glucometro-accu-check-instant-kit-con-50-tiras-y-799192067426.jpg', 'glucometro-accu-check-instant-kit-con-50-tiras-y-799192067426.jpg', null),
  (4, '7502211783787', 'FC-11783787', 'Erbitrax-T terbinafina 250 mg C/28', 'ERBITRAX T 250MG C28', 2, 112.50, 180, 'generico', 'Medicamentos', null, 'Tableta', 'Erbitrax-T', 'Loeffler', 'Caja con 28 tabletas', 'Terbinafina', '250 mg', true, false, null, null, null),
  (5, '7501165009486', 'FC-65009486', 'Lactacyd Pro-Bio shampoo íntimo 200 mL', 'LACTACYD PRO BIO SH', 1, 63.95, 80, 'marca', 'Cuidado personal', 'Higiene íntima', 'Shampoo', 'Lactacyd', 'Sanofi', 'Frasco 200 mL', null, null, false, false, null, null, null),
  (6, '7501065008459', 'FL-5008459', 'Theraflu TD rojo resfriado severo C/10', 'THERAFLU TD ROJO C10', 2, 170.23, 213, 'marca', 'Medicamentos', 'Resfriado', 'Sobres', 'Theraflu', 'Haleon', 'Caja con 10 sobres', null, null, false, true, null, null, null),
  (7, '7501065008473', 'FC-5008473', 'Theraflu TD limón resfriado severo C/10', 'THERAFLU VERDE C10 S', 2, 161.77, 203, 'marca', 'Medicamentos', 'Resfriado', 'Sobres', 'Theraflu', 'Haleon', 'Caja con 10 sobres', null, null, false, true, null, null, null),
  (8, '8020030091252', 'FC-30091252', 'Vessel Due-F sulodexida 250 LRU C/50', 'VESSEL DUE F 250 CAP', 1, 576.00, 922, 'generico', 'Medicamentos', null, 'Cápsula', 'Vessel Due-F', 'AlfaSigma', 'Caja con 50 cápsulas', 'Sulodexida', '250 LRU', true, false, null, null, null);

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
  'Alta Cityfarma Iztapalapa S324509 · 2026-09-21 · listo para pistola',
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
from _fc_cf_s324509 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cf_s324509 t
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
from _fc_cf_s324509 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S324509',
  '2026-09-21',
  2855.11,
  'borrador',
  'Ticket Cityfarma S324509 · 21-sep-2026 · foto térmica · Pendiente de pago $2,855.11 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'S324509'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 2855.11,
  fecha = '2026-09-21',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S324509 · 21-sep-2026 · foto térmica · Pendiente de pago $2,855.11 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'S324509'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S324509'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
from _fc_cf_s324509 t
join public.recepciones r
  on r.folio = 'S324509'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
from _fc_cf_s324509 t
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
where r.folio = 'S324509'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_cf_s324509 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_farmalive_14173.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Farmalive · ticket 14173 · 2026-09-21 17:25 · Club Iztapalapa 1
-- Total $1,538.69 · 19 artículos / 39 unidades.
-- Ticket trunca Suerox a 12 dígitos; pistola = EAN 650…2 del catálogo.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 6 alta(s) stock 0. 13 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_14173 (
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

insert into _fc_fl_14173 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7506306215689', 'FC-06215689', 'Ego Alfa Control caída gel 200 mL', 'GEL EGO ALFA CONT CAIDA 200 ML | UNILEVER', 3, 17.21, 22, 'marca', 'Cuidado personal', 'Capilar', 'Gel', 'Ego', 'Unilever', 'Frasco 200 mL', null, null, false, false, null, null, null),
  (2, '7501033956331', 'FC-33950063', 'Pediasure Plus líquido fresa 237 mL', 'PEDIASURE PLUS LIQ FRESA 237 ML | ABBOTT', 2, 46.08, 58, 'marca', 'Suplemento', null, 'Líquido', 'Pediasure', 'Abbott', 'Frasco 237 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/pediasure-plus-vainilla-237ml.jpg', 'pediasure-plus-vainilla-237ml.jpg', null),
  (3, '7501033956317', 'FC-33951008', 'Pediasure Plus líquido chocolate 237 mL', 'PEDIASURE PLUS LIQ CHOCOLATE 237 ML | ABBOTT', 2, 46.08, 58, 'marca', 'Suplemento', null, 'Líquido', 'Pediasure', 'Abbott', 'Frasco 237 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/pediasure-plus-chocolate-237ml.jpg', 'pediasure-plus-chocolate-237ml.jpg', null),
  (4, '7501033956294', 'FC-33950209', 'Pediasure Plus líquido vainilla 237 mL', 'PEDIASURE PLUS LIQ VAINILLA 237 ML | ABBOTT', 2, 46.08, 58, 'marca', 'Suplemento', null, 'Líquido', 'Pediasure', 'Abbott', 'Frasco 237 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/pediasure-plus-vainilla-237ml.jpg', 'pediasure-plus-vainilla-237ml.jpg', null),
  (5, '7501033954085', 'FC-33954085', 'Ensure líquido vainilla 237 mL', 'ENSURE LIQ VAINILLA 237 ML | ABBOTT', 4, 42.63, 54, 'marca', 'Suplemento', null, 'Líquido', 'Ensure', 'Abbott', 'Frasco 237 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/ensure-singles-fresa-237ml.jpg', 'ensure-singles-fresa-237ml.jpg', null),
  (6, '7501033954061', 'FC-33954061', 'Ensure líquido chocolate 237 mL', 'ENSURE LIQ CHOCOLATE 237 ML | ABBOTT', 4, 42.63, 54, 'marca', 'Suplemento', null, 'Líquido', 'Ensure', 'Abbott', 'Frasco 237 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/ensure-singles-chocolate-237ml.jpg', 'ensure-singles-chocolate-237ml.jpg', null),
  (7, '7501019006647', 'FC-19006647', 'Saba buenas noches delgada C/10', 'TOA SANIT SABA U DELGADA NOCT C/A 10 | SCA', 2, 29.83, 38, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toallas', 'Saba', 'SCA', 'Paquete 10 toallas', null, null, false, false, null, null, null),
  (8, '6502400744552', 'FC-40074455', 'Suerox 8 iones uva mora azul 630 mL', 'SUEROX 8 IONES UVA MORA AZUL 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (9, '6502400322571', 'FC-00322571', 'Suerox 8 iones manzana 630 mL', 'SUEROX 8 IONES MANZANA 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (10, '6502400721471', 'FC-00721471', 'Suerox Vitamins naranja-mango 630 mL', 'SUEROX VITAMINS NARANJA-MANGO 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (11, '6502400322712', 'FC-40032271', 'Suerox 8 iones uva 630 mL', 'SUEROX 8 IONES UVA 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (12, '6502400721541', 'FC-00721541', 'Suerox Vitamins manzana y limón 630 mL', 'SUEROX VITAMINS MANZANA V-LIMON 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (13, '7500435231237', 'FC-35231237', 'Head & Shoulders anti comezón shampoo 375 mL', 'SHAM HEAD & S ANTI-COMEZON 375 ML | PG PERF', 1, 86.07, 108, 'marca', 'Cuidado personal', 'Capilar', 'Shampoo', 'Head & Shoulders', 'P&G', 'Frasco 375 mL', null, null, false, true, null, null, null),
  (14, '7500435162586', 'FC-35162586', 'Head & Shoulders protección caída shampoo 650 mL', 'SHAM HEAD & S PROT CAIDA 650 ML | PG PERF', 1, 123.03, 154, 'marca', 'Cuidado personal', 'Capilar', 'Shampoo', 'Head & Shoulders', 'P&G', 'Frasco 650 mL', null, null, false, false, null, null, null),
  (15, '7500435249348', 'FC-35249348', 'Head & Shoulders anti resequedad shampoo 375 mL', 'SHAM HEAD & S ANTI RESEQUEDAD 375 ML | PG PERF', 1, 86.07, 108, 'marca', 'Cuidado personal', 'Capilar', 'Shampoo', 'Head & Shoulders', 'P&G', 'Frasco 375 mL', null, null, false, false, null, null, null),
  (16, '7891051037878', 'FC-51037878', 'Oral-B Complete enjuague bucal 250 mL', 'ENJ BUCAL ORAL B COMPLET 250 ML | PG PERF', 2, 47.75, 60, 'marca', 'Cuidado personal', 'Higiene bucal', 'Enjuague', 'Oral-B', 'P&G', 'Botella 250 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/oral-b-enjuague-complet-250ml.jpg', 'oral-b-enjuague-complet-250ml.jpg', null),
  (17, '7500435231244', 'FC-35231244', 'Head & Shoulders anti comezón shampoo 180 mL', 'SHAM HEAD & S ANTI-COMEZON 180 ML | PG PERF', 2, 39.43, 50, 'marca', 'Cuidado personal', 'Capilar', 'Shampoo', 'Head & Shoulders', 'P&G', 'Frasco 180 mL', null, null, false, true, null, null, null),
  (18, '7503003406181', 'FC-03406181', 'Cinta micropore Quirmex blanca 2.5 cm × 10 m', 'CINTA MICROPOR QUIRMEX BCO 2.5CMX10M | QUIRMEX', 2, 16.83, 22, 'marca', 'Botiquín', 'Material de curación', 'Cinta', 'Quirmex', 'Quirmex', 'Rollo 2.5 cm × 10 m', null, null, false, false, null, null, null),
  (19, '7506022301789', 'FC-22301789', 'Jeringa Sensimedical 3 mL azul C/100', 'JERINGA SENSIMEDICAL 3 ML AZUL C/100 | JAYOR', 1, 159.50, 200, 'marca', 'Botiquín', 'Material médico', 'Jeringas', 'Sensimedical', 'Jayor', 'Caja 100 jeringas 3 mL', null, null, false, false, null, null, null);

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
  'Alta Farmalive 14173 · 2026-09-21 · listo para pistola',
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
from _fc_fl_14173 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_fl_14173 t
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
from _fc_fl_14173 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '14173',
  '2026-09-21',
  1538.69,
  'borrador',
  'Ticket Farmalive 14173 · Club Iztapalapa 1 · 21-sep-2026 · precio neto (2–7% desc.) · Suerox EAN canónico 650…2 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '14173'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 1538.69,
  fecha = '2026-09-21',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 14173 · Club Iztapalapa 1 · 21-sep-2026 · precio neto (2–7% desc.) · Suerox EAN canónico 650…2 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '14173'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '14173'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
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
from _fc_fl_14173 t
join public.recepciones r
  on r.folio = '14173'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
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
from _fc_fl_14173 t
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
where r.folio = '14173'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_fl_14173 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_mas_farmacias_48165.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Distribuidora Mas Farmacias · folio 48165 · 2026-09-21 17:17
-- Ticket imprimió 007502211783671 → EAN 7502211783671 (Erbitrax C/40).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 1 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_mf_48165 (
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

insert into _fc_mf_48165 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502211783671', 'FC-11783671', 'Erbitrax-T terbinafina 250 mg C/40', 'ERBITRAX 250MG 40TAB', 4, 161.62, 259, 'generico', 'Medicamentos', null, 'Tableta', 'Erbitrax-T', 'Loeffler', 'Caja con 40 tabletas', 'Terbinafina', '250 mg', true, false, null, null, null);

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
  'Alta Distribuidora Mas Farmacias 48165 · 2026-09-21 · listo para pistola',
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
from _fc_mf_48165 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_mf_48165 t
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
from _fc_mf_48165 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Distribuidora Mas Farmacias',
  '48165',
  '2026-09-21',
  646.50,
  'borrador',
  'Ticket Distribuidora Mas Farmacias 48165 · Central de Abastos · 21-sep-2026 · tarjeta $646.50 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '48165'
    and coalesce(proveedor, '') ilike '%mas farmacias%'
);

update public.recepciones
set
  total_ticket = 646.50,
  fecha = '2026-09-21',
  proveedor = 'Distribuidora Mas Farmacias',
  notas = 'Ticket Distribuidora Mas Farmacias 48165 · Central de Abastos · 21-sep-2026 · tarjeta $646.50 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '48165'
  and coalesce(proveedor, '') ilike '%mas farmacias%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '48165'
  and coalesce(r.proveedor, '') ilike '%mas farmacias%'
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
from _fc_mf_48165 t
join public.recepciones r
  on r.folio = '48165'
 and coalesce(r.proveedor, '') ilike '%mas farmacias%'
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
from _fc_mf_48165 t
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
where r.folio = '48165'
  and coalesce(r.proveedor, '') ilike '%mas farmacias%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_mf_48165 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_surtidor_132862.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- El Surtidor de su Farmacia · venta 132862 · 2026-09-21 17:07
-- Costo = total renglón / qty (después del 75% desc.).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 0 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_sur132862 (
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

insert into _fc_sur132862 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502004401409', 'EQ-OFF008', 'Dexne nasal fenilefrina/dexametasona/neomicina gotas 10 mL', 'DEXNE GTS NASAL', 2, 41.25, 66, 'generico', 'Medicamentos', null, 'Gotas nasales', 'Dexne', 'Offenbach', 'Frasco gotero 10 mL', 'Fenilefrina / dexametasona / neomicina', null, true, true, null, null, null),
  (2, '7502004401508', 'EQ-OFF009', 'Dexne ótico dexametasona/neomicina/lidocaína gotas 10 mL', 'DEXNE GTS OT 10ML DEXAMETASONA+NEOM+LIDO', 3, 46.50, 75, 'generico', 'Medicamentos', null, 'Gotas óticas', 'Dexne', 'Offenbach', 'Frasco gotero 10 mL', 'Dexametasona / neomicina / lidocaína', null, true, true, null, null, null);

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
  'Alta El Surtidor de su Farmacia 132862 · 2026-09-21 · listo para pistola',
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
from _fc_sur132862 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_sur132862 t
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
from _fc_sur132862 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'El Surtidor de su Farmacia',
  '132862',
  '2026-09-21',
  222.00,
  'borrador',
  'Ticket El Surtidor venta 132862 · Bodega F48 · 21-sep-2026 · 75% desc. Dexne · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '132862'
    and coalesce(proveedor, '') ilike '%surtidor%'
);

update public.recepciones
set
  total_ticket = 222.00,
  fecha = '2026-09-21',
  proveedor = 'El Surtidor de su Farmacia',
  notas = 'Ticket El Surtidor venta 132862 · Bodega F48 · 21-sep-2026 · 75% desc. Dexne · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '132862'
  and coalesce(proveedor, '') ilike '%surtidor%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '132862'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
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
from _fc_sur132862 t
join public.recepciones r
  on r.folio = '132862'
 and coalesce(r.proveedor, '') ilike '%surtidor%'
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
from _fc_sur132862 t
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
where r.folio = '132862'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_sur132862 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_surtidor_132821.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- El Surtidor de su Farmacia · venta 132821 · 2026-09-21
-- Lysol chico 354 g EAN 7501409601018 · grande 475 g 7501058796882.
-- Sin lote ni caducidad. No inventar 0000.
-- 1 alta(s) stock 0. 1 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_sur132821 (
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

insert into _fc_sur132821 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501409601018', 'FC-09601018', 'Lysol desinfectante Crisp Linen 354 g', 'SPRAY LYSOL CHICO 354GR', 2, 100.01, 126, 'marca', 'Higiene', 'Desinfectante', 'Aerosol', 'Lysol', 'Reckitt', 'Aerosol 354 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/lysol-crisp-linen-354g.jpg', 'lysol-crisp-linen-354g.jpg', null),
  (2, '7501058796882', 'FC-58796882', 'Lysol desinfectante Crisp Linen 475 g', 'SPRAY LYSOL GRANDE 475GR', 4, 130.00, 163, 'marca', 'Higiene', 'Desinfectante', 'Aerosol', 'Lysol', 'Reckitt', 'Aerosol 475 g', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/lysol-crisp-linen-475g.jpg', 'lysol-crisp-linen-475g.jpg', null);

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
  'Alta El Surtidor de su Farmacia 132821 · 2026-09-21 · listo para pistola',
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
from _fc_sur132821 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_sur132821 t
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
from _fc_sur132821 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'El Surtidor de su Farmacia',
  '132821',
  '2026-09-21',
  720.01,
  'borrador',
  'Ticket El Surtidor venta 132821 · Bodega F48 · 21-sep-2026 · Lysol 354 g / 475 g · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '132821'
    and coalesce(proveedor, '') ilike '%surtidor%'
);

update public.recepciones
set
  total_ticket = 720.01,
  fecha = '2026-09-21',
  proveedor = 'El Surtidor de su Farmacia',
  notas = 'Ticket El Surtidor venta 132821 · Bodega F48 · 21-sep-2026 · Lysol 354 g / 475 g · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '132821'
  and coalesce(proveedor, '') ilike '%surtidor%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '132821'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
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
from _fc_sur132821 t
join public.recepciones r
  on r.folio = '132821'
 and coalesce(r.proveedor, '') ilike '%surtidor%'
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
from _fc_sur132821 t
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
where r.folio = '132821'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_sur132821 t
order by t.linea;

commit;

