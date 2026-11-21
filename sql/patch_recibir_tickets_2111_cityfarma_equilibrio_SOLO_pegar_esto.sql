-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Cityfarma S343254 · 21-nov-2026 · $9,289.81 · 25 renglones / 149 pzas
-- + Equilibrio 452626 · $858.58 · 7 renglones / 20 pzas
-- + Equilibrio 452628 · Delaphil · $67.42 · 1 renglon / 2 pzas
-- Merge a GitHub NO crea las tarjetas. Sin dollar-quote. Caducidad null.
-- (452626 también en PR #563; este archivo deja los 3 listos en un solo Run.)
-- =============================================================================

rollback;

-- ========== Cityfarma S343254 ==========
-- Cityfarma Iztapalapa · folio S343254 · 2026-11-21 · total $9,289.81
-- 25 renglones / 149 pzas. Costo = P.U. ticket.
-- Theraflu verde: EAN canonico 7501065008473.
-- SIN dollar-quote. Idempotente en borrador. MMAA de la caja.

begin;

create temp table _fc_cf_s343254 (
  linea integer primary key,
  ean text,
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
  imagen text
) on commit drop;

insert into _fc_cf_s343254 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
) values
  (1, '7500462746643', 'FC-62746643', 'Ajolotius pastillas menta', 'AJOLOTIUS C10 PAST M', 5, 17.92, 23, 'marca', 'Vitaminas', null, 'Pastillas', 'Ajolotius', 'Bioalimentos', 'Caja con 10 pastillas', null, null, false, true, null),
  (2, '7506452400014', 'FC-52400014', 'Ajolotius pastillas propoleo', 'AJOLOTIUS PROPOLEO P', 5, 17.98, 23, 'marca', 'Vitaminas', null, 'Pastillas', 'Ajolotius', 'Bioalimentos', 'Caja con 10 pastillas', null, null, false, false, null),
  (3, '7506331301142', 'FC-31301142', 'Autevazen 500 mg', 'AUTEYAZEN 500MG C50', 3, 83.52, 105, 'marca', 'Medicamentos', null, 'Capsulas', 'Autevazen', null, 'Caja con 50 capsulas', null, '500 mg', true, true, null),
  (4, '8429420084674', 'FC-20084674', 'Bexident Post gel', 'BEXIDENT POST GEL 10', 2, 262.28, 328, 'marca', 'Cuidado personal', 'Bucal', 'Gel', 'Bexident', 'Isdin', 'Tubo 25 ml', null, null, false, true, null),
  (5, '7502211781059', 'FC-11781059', 'Bromicof solucion infantil', 'BROMICOF SOL INF 100', 10, 13.95, 18, 'marca', 'Medicamentos', 'Respiratorio', 'Solucion', 'Bromicof', 'Loeffler', 'Frasco 100 ml', null, null, false, true, null),
  (6, '714706100307', 'FC-70100307', 'Broncolin etiqueta azul', 'BRONCOLIN JBE 140 ML', 10, 60.68, 76, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Broncolin', 'Broncolin', 'Frasco 140 ml', null, null, false, true, null),
  (7, '714706910609', 'FC-06910609', 'Broncolin etiqueta verde', 'BRONCOLIN JBE 140ML', 10, 70.20, 88, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Broncolin', 'Broncolin', 'Frasco 140 ml', null, null, false, true, null),
  (8, '7502009743627', 'FC-09743627', 'Cefalexina suspension 250 mg/5 ml', 'CEFALEXINA SUSP 250M', 3, 21.46, 35, 'generico', 'Medicamentos', null, 'Suspension', 'Cefalexina', 'Maver', 'Frasco 100 ml', 'Cefalexina', '250 mg/5 ml', true, false, null),
  (9, '7501868900684', 'FC-68900684', 'Dibar tela adhesiva 10 cm', 'DIBAR TEL ADH 10CMX1', 1, 287.11, 359, 'marca', 'Botiquin', null, 'Tela adhesiva', 'Dibar', 'Dibar', 'Rollo 10 cm', null, null, false, false, null),
  (10, '7502009746246', 'FC-09746246', 'Erispan compuesto 5/0.25 mg', 'ERISPAN COMP TAB C20', 10, 16.61, 21, 'marca', 'Medicamentos', null, 'Tabletas', 'Erispan', 'Maver', 'Caja con 20 tabletas', 'Loratadina / betametasona', '5 mg / 0.25 mg', true, false, null),
  (11, '5000174003963', 'FC-74003963', 'Fixodent Fresh', 'FIXODENT FRESH PAST', 5, 89.20, 112, 'marca', 'Cuidado personal', 'Higiene bucal', 'Adhesivo', 'Fixodent', 'P&G', 'Tubo', null, null, false, true, null),
  (12, '7502009740466', 'FC-09740466', 'Flexiver 7.5 mg', 'FLEXIVER 7.5MG C14 T', 3, 8.19, 11, 'marca', 'Medicamentos', 'Muscular', 'Tabletas', 'Flexiver', 'Maver', 'Caja con 14 tabletas', 'Meloxicam', '7.5 mg', true, true, null),
  (13, '7501075713176', 'FC-75713176', 'Lamblit 500 mg', 'LAMBLIT 500 MG C 30', 5, 18.28, 23, 'marca', 'Medicamentos', null, 'Tabletas', 'Lamblit', null, 'Caja con 30 tabletas', null, '500 mg', true, true, null),
  (14, '008400009197', 'FC-00009197', 'Olopatadina 0.2%', 'OLOPATADINA 0.2% SOL', 1, 122.73, 197, 'generico', 'Medicamentos', 'Oftalmico', 'Gotas oftalmicas', 'Olopatadina', null, 'Frasco gotero', 'Olopatadina', '0.2%', true, false, null),
  (15, '7501537103484', 'FC-37103484', 'Oxolbrul adulto', 'OXOLBRUL AD DEXTROME', 10, 19.76, 32, 'generico', 'Medicamentos', 'Respiratorio', 'Solucion oral', 'Oxolbrul', 'Brudifarma', 'Frasco 120 ml', 'Ambroxol / dextrometorfano', '225/225 mg/100 ml', false, true, null),
  (16, '7502208894977', 'FC-08894977', 'Portem 750 mg', 'PORTEM PARACETAMOL 7', 15, 7.80, 13, 'generico', 'Analgesico', null, 'Tabletas', 'Portem', 'Bruluagsa', 'Caja con 10 tabletas', 'Paracetamol', '750 mg', false, false, null),
  (17, '7501075723724', 'FC-75723724', 'Rovemax diosmina/hesperidina', 'ROVEMAX TAB C20 DIOS', 5, 59.95, 75, 'marca', 'Medicamentos', 'Circulacion', 'Tabletas', 'Rovemax', 'Novag', 'Caja con 20 tabletas', 'Diosmina / Hesperidina', null, true, true, null),
  (18, '7501125100130', 'FMX-503320', 'Solucion CS 0.9%', 'SOL CS 1000ML PLAS P', 5, 41.69, 67, 'generico', 'Hidratacion', null, 'Solucion intravenosa', 'Solucion CS', 'PiSA', 'Bolsa 1000 ml', 'Cloruro de sodio', '0.9%', true, true, null),
  (19, '7501125100123', 'FC-25100123', 'Solucion CS 0.9%', 'SOL CS 500ML', 10, 25.92, 42, 'generico', 'Hidratacion', null, 'Solucion intravenosa', 'Solucion CS', 'PiSA', 'Bolsa 500 ml', 'Cloruro de sodio', '0.9%', true, true, null),
  (20, '736085405422', 'FC-54054221', 'Splash Tears', 'SPLASH TEARS SOL OFT', 2, 137.67, 173, 'marca', 'Medicamentos', 'Oftalmico', 'Solucion oftalmica', 'Splash Tears', 'Sophia', 'Frasco 15 ml', 'Hipromelosa', null, false, true, null),
  (21, '7501349029729', 'FC-49029729', 'Telmisartan/hidroclorotiazida', 'TELMISARTAN HIDROCLO', 10, 42.74, 69, 'generico', 'Medicamentos', null, 'Tabletas', 'AMSA', 'AMSA', 'Caja', 'Telmisartan / Hidroclorotiazida', null, true, true, null),
  (22, '7501349029736', 'FC-49029736', 'Telmisartan/hidroclorotiazida', 'TELMISARTAN HIDROCLO', 5, 84.33, 135, 'generico', 'Medicamentos', null, 'Tabletas', 'AMSA', 'AMSA', 'Caja', 'Telmisartan / Hidroclorotiazida', null, true, false, null),
  (23, '7501065008473', 'FC-5008473', 'Theraflu TD limon resfriado severo', 'THERAFLU VERDE C10 S', 12, 164.85, 207, 'marca', 'Medicamentos', 'Resfriado', 'Sobres', 'Theraflu', 'Haleon', 'Caja con 10 sobres', null, null, false, true, null),
  (24, '7501318685499', 'FC-18685499', 'Xarelto 10 mg', 'XARELTO 10MG C30 TAB', 1, 800.00, 1000, 'marca', 'Medicamentos', null, 'Tabletas', 'Xarelto', 'Bayer', 'Caja con 30 tabletas', 'Rivaroxaban', '10 mg', true, false, null),
  (25, '7501318606191', 'FC-18606191', 'Xarelto 15 mg', 'XARELTO 15MG C 28 CO', 1, 700.00, 875, 'marca', 'Medicamentos', null, 'Tabletas', 'Xarelto', 'Bayer', 'Caja con 28 comprimidos', 'Rivaroxaban', '15 mg', true, false, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Cityfarma S343254 · 2026-11-21 · listo para pistola',
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s343254
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s343254
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre else p.nombre end,
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s343254
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma',
  'S343254',
  '2026-11-21',
  9289.81,
  'borrador',
  'Cityfarma S343254 · 21-nov-2026 · 149 pzas · $9,289.81 · cola Recibir; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = 'S343254' and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 9289.81,
  fecha = '2026-11-21',
  proveedor = 'Cityfarma',
  notas = 'Cityfarma S343254 · 21-nov-2026 · 149 pzas · $9,289.81 · cola Recibir; MMAA de la caja',
  updated_at = now()
where folio = 'S343254'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S343254'
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
  coalesce(t.ean, t.sku),
  t.snap,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_cf_s343254 t
join public.recepciones r
  on r.folio = 'S343254'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

-- ========== Equilibrio 452626 ==========
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

-- ========== Equilibrio 452628 ==========
-- Equilibrio · ticket 452628 · 2026-11-21 · Total $67.42 · 1 renglon / 2 pzas
-- DEN074 Delaphil 5 mg C/14 · P.U. 33.71 · lote 26F008
-- EAN 7506476200126 / EQ-DEN074. Caducidad null: MMAA de la caja.

begin;

create temp table _fc_eq_452628 (
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
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  lote text
) on commit drop;

insert into _fc_eq_452628 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  forma, marca, laboratorio, presentacion, principio_activo, concentracion,
  receta, ya, lote
) values
  (1, '7506476200126', 'EQ-DEN074', 'Delaphil 5 mg', 'DEN074 DELAPHIL 14 TAB 5 MG', 2, 33.71, 54, 'generico', 'Medicamentos',
   'Tabletas', 'Delaphil', 'DLP Pharma', 'Caja con 14 tabletas', 'Tadalafil', '5 mg',
   true, true, '26F008');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio
)
select
  t.nombre, t.sku, t.ean, t.categoria, t.tipo,
  'Alta Equilibrio 452628 · 2026-11-21 · listo para pistola',
  t.costo, t.precio, 0, 1, true, t.receta,
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion, t.laboratorio
from _fc_eq_452628 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma)
from _fc_eq_452628 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '452628',
  '2026-11-21',
  67.42,
  'borrador',
  'Ticket Equilibrio folio 452628 · Delaphil 5 mg x2 · $67.42 · lote 26F008; MMAA de la caja · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '452628' and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 67.42,
  fecha = '2026-11-21',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio folio 452628 · Delaphil 5 mg x2 · $67.42 · lote 26F008; MMAA de la caja · cola Recibir',
  updated_at = now()
where folio = '452628'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '452628'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id, v.pid, t.ean, t.snap, t.qty, null, t.lote, t.costo, (v.pid is null),
  'pdf', false, false, null
from _fc_eq_452628 t
join public.recepciones r
  on r.folio = '452628'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true;

commit;

-- VERIFICACION
select proveedor, folio, estado, fecha, total_ticket,
  count(i.*) as renglones, coalesce(sum(i.cantidad),0) as piezas,
  count(*) filter (where not coalesce(i.confirmado,false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where (r.folio = 'S343254' and coalesce(r.proveedor,'') ilike '%cityfarma%')
   or (r.folio in ('452626', '452628') and coalesce(r.proveedor,'') ilike '%equilibrio%')
group by r.id, r.proveedor, r.folio, r.estado, r.fecha, r.total_ticket
order by r.folio;
