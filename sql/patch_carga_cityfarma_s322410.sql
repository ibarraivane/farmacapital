-- Cityfarma Iztapalapa · orden S322410 · 2026-09-12 15:21
-- Ticket térmico Central de Abastos. Pendiente de pago $1916.97 (IVA 0%).
-- P.U. = costo. Sin lote ni caducidad: MMAA de la caja. No inventar 0000.
-- Allegra 180 y Sedalmerck ya estaban: solo costo (+ foto si faltaba).
-- 7 altas stock 0. Nombres de ficha, no del ticket.
-- Fotos en public/catalogo-propia/ (URLs tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s322410 (
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

insert into _fc_cf_s322410 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file
) values

  (1, '7501165001725', 'FC-16500172', 'Allegra fexofenadina 180 mg C/10',
   'ALLEGRA 180 MG C 10', 2, 348.98, 419,
   'marca', 'Alergia', 'Antihistamínico',
   'Tableta', 'Allegra', 'Sanofi',
   'Caja con 10 tabletas', 'Fexofenadina', '180 mg',
   false, true,
   'https://www.farmacapital.mx/catalogo-propia/allegra-fexofenadina-180-10.jpg', 'catalogo-propia/allegra-fexofenadina-180-10.jpg'),
  (2, '7501165006386', 'FC-65006386', 'Allegra D fexofenadina/fenilefrina 60/25 mg C/10',
   'ALLEGRA D 60 25MG C', 1, 302.23, 363,
   'marca', 'Alergia', 'Antihistamínico',
   'Tableta', 'Allegra', 'Sanofi',
   'Caja con 10 tabletas', 'Fexofenadina + fenilefrina', '60/25 mg',
   false, false,
   'https://www.farmacapital.mx/catalogo-propia/allegra-d-60-25-10.jpg', 'catalogo-propia/allegra-d-60-25-10.jpg'),
  (3, '7501165006171', 'FC-65006171', 'Allegra suspensión 6 mg/mL 150 mL',
   'ALLEGRA SUSP 150ML', 1, 324.07, 389,
   'marca', 'Alergia', 'Antihistamínico',
   'Suspensión', 'Allegra', 'Sanofi',
   'Frasco 150 mL', 'Fexofenadina', '6 mg/mL',
   false, false,
   'https://www.farmacapital.mx/catalogo-propia/allegra-suspension-150ml.jpg', 'catalogo-propia/allegra-suspension-150ml.jpg'),
  (4, '7501300420824', 'FC-00420824', 'Dolac ketorolaco sublingual 30 mg C/6',
   'DOLAC SUBL C/6 30MG', 1, 136.28, 219,
   'marca', 'Analgésicos', 'Antiinflamatorio',
   'Tableta sublingual', 'Dolac', 'Pisa',
   'Caja con 6 tabletas', 'Ketorolaco', '30 mg',
   true, false,
   'https://www.farmacapital.mx/catalogo-propia/dolac-ketorolaco-sublingual-30-6.jpg', 'catalogo-propia/dolac-ketorolaco-sublingual-30-6.jpg'),
  (5, '7501349027060', 'FC-49027060', 'Fexofenadina 120 mg C/10 AMSA',
   'FEXOFENADINA 120MG C', 2, 34.51, 56,
   'generico', 'Alergia', 'Antihistamínico',
   'Tableta', 'AMSA', 'AMSA',
   'Caja con 10 tabletas', 'Fexofenadina', '120 mg',
   false, false,
   'https://www.farmacapital.mx/catalogo-propia/fexofenadina-120-amsa-10.jpg', 'catalogo-propia/fexofenadina-120-amsa-10.jpg'),
  (6, '7501349025059', 'FC-49025059', 'Fexofenadina 180 mg C/10 AMSA',
   'FEXOFENADINA 180MG C', 2, 47.89, 77,
   'generico', 'Alergia', 'Antihistamínico',
   'Tableta', 'AMSA', 'AMSA',
   'Caja con 10 tabletas', 'Fexofenadina', '180 mg',
   false, false,
   'https://www.farmacapital.mx/catalogo-propia/fexofenadina-180-amsa-10.png', 'catalogo-propia/fexofenadina-180-amsa-10.png'),
  (7, '7500435230445', 'FC-35230445', 'NyQuil Z difenhidramina 25 mg C/10',
   'NYQUIL Z 25MG 10CAPS', 1, 103.85, 167,
   'marca', 'Respiratorio', 'Sueño / resfriado',
   'Cápsula', 'NyQuil', 'Procter & Gamble',
   'Caja con 10 cápsulas', 'Difenhidramina', '25 mg',
   false, false,
   'https://www.farmacapital.mx/catalogo-propia/nyquil-z-difenhidramina-25-10.jpg', 'catalogo-propia/nyquil-z-difenhidramina-25-10.jpg'),
  (8, '7502208895219', 'FC-08895219', 'Portem AS paracetamol/cafeína 500/50 mg C/20',
   'PORTEM AS PARACETAMO', 3, 15.26, 25,
   'marca', 'Analgésicos', 'Analgésico',
   'Tableta', 'Portem AS', 'Bruluagsa',
   'Caja con 20 tabletas', 'Paracetamol + cafeína', '500/50 mg',
   false, false,
   'https://www.farmacapital.mx/catalogo-propia/portem-as-paracetamol-cafeina-500-50-20.jpg', 'catalogo-propia/portem-as-paracetamol-cafeina-500-50-20.jpg'),
  (9, '7501298281209', 'FC-8281209', 'Sedalmerck C/20 tabletas',
   'SEDALMERCK C 20 TABS', 2, 71.00, 114,
   'marca', 'Analgésicos', 'Analgésico',
   'Tableta', 'Sedalmerck', 'P&G Health',
   'Caja con 20 tabletas', 'Paracetamol + cafeína + fenilefrina', '500/50/5 mg',
   false, true,
   'https://www.farmacapital.mx/catalogo-propia/sedalmerck-20.jpg', 'catalogo-propia/sedalmerck-20.jpg');

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
  'Alta Cityfarma S322410 · 2026-09-12 · listo para pistola',
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
from _fc_cf_s322410 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cf_s322410 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_cf_s322410 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S322410',
  '2026-09-12',
  1916.97,
  'borrador',
  'Ticket Cityfarma S322410 · 2026-09-12 15:21 · pendiente de pago · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'S322410' and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1916.97,
  fecha = '2026-09-12',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S322410 · 2026-09-12 15:21 · pendiente de pago · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'S322410'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S322410'
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
from _fc_cf_s322410 t
join public.recepciones r
  on r.folio = 'S322410'
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
  ), -1) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'distribuidor'
from _fc_cf_s322410 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes x
    where x.producto_id = p.id and x.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = 'S322410' and coalesce(r.proveedor, '') ilike '%cityfarma%'
order by i.id;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, '(sin foto)'), 64) as foto
from public.productos p
where p.codigo_barras in ('7501165001725', '7501165006386', '7501165006171', '7501300420824', '7501349027060', '7501349025059', '7500435230445', '7502208895219', '7501298281209')
order by p.sku;
