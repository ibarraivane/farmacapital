-- Cityfarma Iztapalapa · venta CF080926 · 2026-09-08 16:37
-- Ticket térmico Central de Abastos. Cliente 307513 Luis Ángel Palillero.
-- Total $1,648.69 (SUB $1,635.26 + IVA $13.43). 16 renglones / 37 pzas.
-- 9 altas stock 0. 7 ya estaban: solo costo (PVP si estaba en 0).
-- Ampigrin Infantil: corrige nombre si quedó como Infamid.
-- Clotrimazol Dual: corrige typo Clotrinazol.
-- Sin lote ni caducidad en la cola (MMAA de la caja). No inventar 0000.
-- CSV guarda lote/cad del ticket solo para auditoría.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_cf080926 (
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
  foto_file text
) on commit drop;

insert into _fc_cf_cf080926 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file
) values
  (1, '8907730000039', 'FC-30000039', 'Acetif SI paracetamol solución inyectable 1000 mg/100 ml', 'NOV133 ACETIF SI 1 SOL INY 1000MG/100 ML', 2, 65.23, 105, 'marca', 'Analgésico', 'Inyectable', 'Solución inyectable', 'Acetif SI', 'NOVAG', 'Frasco 100 ml', 'Paracetamol', '1000 mg/100 ml', true, false, 'https://www.farmacapital.mx/catalogo-propia/acetif-si-1000mg-100ml.jpg', 'catalogo-propia/acetif-si-1000mg-100ml.jpg'),
  (2, '7503004908776', 'FC-04908776', 'Metformina Alpharma 850 mg C/30', 'ALP0191 METFORMINA 30 TAB 850 MG', 2, 18.40, 30, 'generico', 'Diabetes', null, 'Tabletas', 'Alpharma', 'ALPHARMA', 'Caja con 30 tabletas', 'Metformina', '850 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/metformina-alpharma-850-c30.jpg', 'catalogo-propia/metformina-alpharma-850-c30.jpg'),
  (3, '7501836003621', 'FC-36003621', 'Precicol hioscina/paracetamol gotas 20 ml', 'LIF162 PRECICOL 1 GOT 20 ML', 2, 36.31, 59, 'marca', 'Gastro', 'Antiespasmódico', 'Gotas', 'Precicol', 'LIFERPAL', 'Frasco gotero 20 ml', 'Butilhioscina + paracetamol', '2 mg/100 mg/ml', false, true, null, null),
  (4, '7502001163485', 'EQ-SON164', 'Clotrimazol Dual óvulos 200 mg C/3 + crema 1% 10 g', 'SON164 CLOTRIMAZOL DUAL 3 OVS 200MG 1CMA 10G', 2, 48.98, 79, 'generico', 'Ginecología', 'Antimicótico', 'Óvulos + crema', 'Son''s', 'QUIMICA SON''S', 'Caja con 3 óvulos y tubo 10 g', 'Clotrimazol', '200 mg / 1%', false, true, 'https://www.farmacapital.mx/catalogo-propia/clotrimazol-dual-sons.jpg', 'catalogo-propia/clotrimazol-dual-sons.jpg'),
  (5, '7502226294254', 'FC-26294254', 'Losil-S terbinafina spray 1% 30 ml', 'ALP0568 TERBINAFINA 1 SPRAY 1%/30 ML', 1, 35.28, 57, 'generico', 'Dermatología', 'Antimicótico', 'Spray', 'Losil-S', 'ALPHARMA', 'Frasco atomizador 30 ml', 'Terbinafina', '1%', false, false, 'https://www.farmacapital.mx/catalogo-propia/losil-s-terbinafina-spray.jpg', 'catalogo-propia/losil-s-terbinafina-spray.jpg'),
  (6, '7502009744440', 'FC-09744440', 'Valtrover G montelukast granulado 4 mg C/10', 'MAV207 VALTROVER G 10 SOB 4 MG', 2, 55.10, 89, 'marca', 'Respiratorio', 'Antiasmático', 'Granulado', 'Valtrover G', 'MAVER', 'Caja con 10 sobres', 'Montelukast', '4 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/valtrover-g-4mg-c10.jpg', 'catalogo-propia/valtrover-g-4mg-c10.jpg'),
  (7, '780083140939', 'FC-DE106642', 'Ampigrin Infantil ampicilina 250 mg 3 amp', 'COL008 AMPIGRIN INF 3 AMP 250/200/100/30MG/3 ML', 2, 72.22, 116, 'marca', 'Antibiótico', 'Inyectable', 'Solución inyectable', 'Ampigrin', 'COLLINS', 'Caja con 3 frascos ámpula + 3 diluyentes 3 ml', 'Ampicilina + metamizol + guaifenesina + lidocaína', '250/200/100/30 mg/3 ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/ampigrin-infantil-3amp.jpg', 'catalogo-propia/ampigrin-infantil-3amp.jpg'),
  (8, '7501349027343', 'FC-49027343', 'Amsafast orlistat 120 mg C/21', 'AMS277 AMSAFAST 21 CAPS 120 MG', 3, 95.63, 154, 'marca', 'Gastro', 'Obesidad', 'Cápsulas', 'Amsafast', 'AMSA', 'Caja con 21 cápsulas', 'Orlistat', '120 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/amsafast-120mg-c21.jpg', 'catalogo-propia/amsafast-120mg-c21.jpg'),
  (9, '7502009747052', 'FC-09747052', 'Coriver paracetamol 750 mg C/10', 'MAV344 CORIVER 10 TAB 750 MG', 5, 7.71, 13, 'marca', 'Analgésico', null, 'Tabletas', 'Coriver', 'MAVER', 'Caja con 10 tabletas', 'Paracetamol', '750 mg', false, false, 'https://www.farmacapital.mx/catalogo-propia/coriver-750mg-c10.jpg', 'catalogo-propia/coriver-750mg-c10.jpg'),
  (10, '7502259892403', 'FC-9892403', 'Naturex citrato de magnesio y lecitina de soya C/30', 'NAT0617 CITRATO DE MAGNESIO 30 CAP 1.82G C/U', 2, 48.68, 78, 'marca', 'Vitaminas', 'Minerales', 'Cápsulas', 'Naturex', 'NATUREX', 'Caja con 30 cápsulas', 'Citrato de magnesio + lecitina de soya', '1.82 g', false, true, null, null),
  (11, '7501349028036', 'FC-49028036', 'Mometasona AMSA suspensión nasal 0.05% 18 ml', 'AMS336 MOMETASONA 1 SUSP .05G/18 ML', 1, 109.63, 176, 'generico', 'Respiratorio', 'Nasal', 'Suspensión nasal', 'AMSA', 'AMSA', 'Frasco nebulizador 18 ml (140 dosis)', 'Furoato de mometasona', '50 mcg/dosis', true, false, 'https://www.farmacapital.mx/catalogo-propia/mometasona-amsa-18ml.jpg', 'catalogo-propia/mometasona-amsa-18ml.jpg'),
  (12, '7503000422511', 'FC-00422511', 'Bactiver sulfametoxazol/trimetoprima susp. 120 ml', 'MAV003 BACTIVER 1 SUSP 40/200/5/120 ML', 3, 20.85, 34, 'marca', 'Antibiótico', null, 'Suspensión', 'Bactiver', 'MAVER', 'Frasco 120 ml', 'Sulfametoxazol + trimetoprima', '200/40 mg/5 ml', true, true, null, null),
  (13, '780083140922', 'FC-2001A890', 'Ampigrin AD ampicilina/dicloxacilina 3 amp', 'COL009 AMPIGRIN AD 3 AMP 500/500/100/30MG/3 ML', 2, 79.44, 128, 'marca', 'Antibiótico', 'Inyectable', 'Solución inyectable', 'Ampigrin', 'COLLINS', 'Caja con 3 frascos ámpula + 3 diluyentes 3 ml', 'Ampicilina + dicloxacilina + guaifenesina + clorfenamina', '500/500/100/30 mg/3 ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/ampigrin-ad-3amp.jpg', 'catalogo-propia/ampigrin-ad-3amp.jpg'),
  (14, '7502001160019', 'EQ-SON033', 'Busconet butilhioscina/metamizol inyectable 5 ml', 'SON033 BUSCONET 1 FA 250/20MG/5ML', 3, 32.10, 52, 'marca', 'Gastro', 'Antiespasmódico', 'Solución inyectable', 'Busconet', 'QUIMICA SON''S', 'Caja con 1 ampolleta 5 ml', 'Butilhioscina + metamizol sódico', '20 mg / 2.5 g / 5 ml', true, false, 'https://www.farmacapital.mx/catalogo-propia/busconet-inyectable-5ml.jpg', 'catalogo-propia/busconet-inyectable-5ml.jpg'),
  (15, '7501349020337', 'FC-49020337', 'Sulindaco AMSA 200 mg C/20', 'AMS502 SULINDACO 20 TAB 200 MG', 3, 47.34, 76, 'generico', 'Analgésico', 'AINE', 'Tabletas', 'AMSA', 'AMSA', 'Caja con 20 tabletas', 'Sulindaco', '200 mg', true, true, null, null),
  (16, '75006433', 'EQ-NOV005', 'Cirulan metoclopramida solución oral 400 mg / 20 ml', 'NOV005 CIRULAN 1 GOT 400MG/1/20 ML', 2, 14.38, 24, 'marca', 'Gastro', null, 'Gotas', 'Cirulan', 'NOVAG', 'Frasco gotero 20 ml', 'Metoclopramida', '4 mg/ml', true, false, 'https://www.farmacapital.mx/catalogo-propia/cirulan-gotas-20ml.jpg', 'catalogo-propia/cirulan-gotas-20ml.jpg');

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
    ) then 'FC-CF-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Cityfarma CF080926 · 2026-09-08 · listo para pistola',
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
from _fc_cf_cf080926 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cf_cf080926 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_cf_cf080926 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Ampigrin Infantil: el catálogo lo tenía mal como Infamid.
update public.productos p
set
  nombre = t.nombre,
  marca = t.marca,
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  concentracion = t.concentracion,
  laboratorio = t.laboratorio,
  categoria = t.categoria,
  subcategoria = t.subcategoria
from _fc_cf_cf080926 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '780083140939'
  and (
    p.nombre ~* 'infamid'
    or p.nombre ~* 'metamizol.*dexametasona'
    or p.nombre ~* 'ampigrim'
  );

-- Clotrimazol Dual: typo Clotrinazol.
update public.productos p
set
  nombre = t.nombre,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = t.presentacion
from _fc_cf_cf080926 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7502001163485'
  and p.nombre ~* 'clotrinazol';

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'CF080926',
  '2026-09-08',
  1648.69,
  'borrador',
  'Ticket Cityfarma CF080926 · 2026-09-08 · cliente 307513 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'CF080926' and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1648.69,
  fecha = '2026-09-08',
  proveedor = 'Cityfarma Iztapalapa'
where folio = 'CF080926'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'CF080926'
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
  null,
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
from _fc_cf_cf080926 t
join public.recepciones r
  on r.folio = 'CF080926'
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
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from _fc_cf_cf080926 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = 'CF080926' and coalesce(r.proveedor, '') ilike '%cityfarma%'
order by i.id;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 52) as nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
  '8907730000039',
  '7503004908776',
  '7501836003621',
  '7502001163485',
  '7502226294254',
  '7502009744440',
  '780083140939',
  '7501349027343',
  '7502009747052',
  '7502259892403',
  '7501349028036',
  '7503000422511',
  '780083140922',
  '7502001160019',
  '7501349020337',
  '75006433'
)
order by p.nombre;
