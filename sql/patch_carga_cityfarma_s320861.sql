-- Cityfarma Iztapalapa · orden S320861 · 2026-09-04 16:50
-- Ticket térmico Central de Abastos. P.U. ya trae IVA (suma renglones = $1383.55).
-- El ticket imprime Total $0.00; se usa la suma de renglones (igual que 6315912).
-- 4 altas stock 0. 2 ya estaban (Neo-Melubrina, Tylenol C/10): solo costo, no PVP.
-- Tylenol C/10 se renombra si quedó como 'Tylenol' para no confundirlo con el C/20.
-- Neo-Melubrina: si la forma dice Inyectable, se corrige a Jarabe.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s320861 (
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

insert into _fc_cf_s320861 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file
) values
  (1, '7502227426067', 'FC-27426067', 'Carticap For glucosamina/condroitina C/60', 'CARTICAP FOR C60 CAP', 4, 77.58, 125, 'marca', 'Vitaminas', 'Articulaciones', 'Cápsulas', 'Carticap', 'GELPHARMA', 'Caja con 60 cápsulas', 'Glucosamina + condroitina + vitamina C + manganeso', '300/200/30/20 mg', false, false, 'https://www.farmacapital.mx/catalogo-propia/carticap-for-c60.jpg', 'catalogo-propia/carticap-for-c60.jpg'),
  (2, '7501369200108', 'FC-69200108', 'Estomaquil Exper3 suspensión 240 ml', 'ESTOMAQUIL EXPER3 SU', 2, 84.34, 135, 'marca', 'Gastro', 'Antiácido', 'Suspensión', 'Estomaquil', 'LAB HIGIA', 'Frasco 240 ml', 'Carbonato de calcio + hidróxido de magnesio + subsalicilato de bismuto', '2.67/1.67/1 g/100 ml', false, false, 'https://www.farmacapital.mx/catalogo-propia/estomaquil-exper3-240ml.jpg', 'catalogo-propia/estomaquil-exper3-240ml.jpg'),
  (3, '7501165000315', 'FC-50003151', 'Neo-Melubrina jarabe infantil 250 mg/5 ml 100 ml', 'NEO MELUBRINA JBE', 2, 110.86, 178, 'marca', 'Analgésico', null, 'Jarabe', 'Neo-Melubrina', 'OPELLA', 'Frasco 100 ml con pipeta o vaso dosificador', 'Metamizol sódico', '250 mg/5 ml', false, true, 'https://www.farmacapital.mx/catalogo-propia/neo-melubrina-jarabe-100ml.jpg', 'catalogo-propia/neo-melubrina-jarabe-100ml.jpg'),
  (4, '7501086453221', 'FC-86453221', 'Oral-B enjuague bucal Gingivitis 350 ml', 'ORAL B ENJBUC GINGIV', 2, 180.01, 289, 'marca', 'Cuidado personal', 'Higiene bucal', 'Enjuague', 'Oral-B', 'P&G', 'Frasco 350 ml', 'Clorhexidina', '0.12%', false, false, 'https://www.farmacapital.mx/catalogo-propia/oral-b-enjuague-gingivitis-350ml.jpg', 'catalogo-propia/oral-b-enjuague-gingivitis-350ml.jpg'),
  (5, '7501007535432', 'FC-75354321', 'Tylenol paracetamol 500 mg C/10', 'TYLENOL 500MG C10 PA', 3, 47.49, 76, 'marca', 'Analgésico', null, 'Tabletas', 'Tylenol', 'KENVUE', 'Caja con 10 tabletas', 'Paracetamol', '500 mg', false, true, null, null),
  (6, '7501100088095', 'FC-10008809', 'Tylenol paracetamol 500 mg C/20', 'TYLENOL 500MG C20 TA', 2, 90.17, 145, 'marca', 'Analgésico', null, 'Tabletas', 'Tylenol', 'KENVUE', 'Caja con 20 tabletas', 'Paracetamol', '500 mg', false, false, 'https://www.farmacapital.mx/catalogo-propia/tylenol-500mg-c20.jpg', 'catalogo-propia/tylenol-500mg-c20.jpg');

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
  'Alta Cityfarma S320861 · 2026-09-04 · listo para pistola',
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
from _fc_cf_s320861 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cf_s320861 t
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
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_cf_s320861 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Tylenol C/10: el nombre corto choca con el C/20 nuevo.
update public.productos p
set nombre = t.nombre,
    presentacion = t.presentacion,
    forma_farmaceutica = t.forma,
    categoria = t.categoria
from _fc_cf_s320861 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7501007535432'
  and (
    p.nombre ~* '^tylenol$'
    or length(trim(p.nombre)) <= 10
  );

-- Neo-Melubrina jarabe mal clasificada como inyectable.
update public.productos p
set forma_farmaceutica = t.forma,
    presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
    nombre = case
      when p.nombre ~* 'inyect' then t.nombre
      else p.nombre
    end
from _fc_cf_s320861 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7501165000315'
  and (
    coalesce(p.forma_farmaceutica, '') ~* 'inyect'
    or p.nombre ~* 'inyect'
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S320861',
  '2026-09-04',
  1383.55,
  'borrador',
  'Ticket Cityfarma S320861 · 2026-09-04 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'S320861' and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1383.55,
  fecha = '2026-09-04',
  proveedor = 'Cityfarma Iztapalapa'
where folio = 'S320861'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S320861'
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
from _fc_cf_s320861 t
join public.recepciones r
  on r.folio = 'S320861'
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
from _fc_cf_s320861 t
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
where r.folio = 'S320861' and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
  '7502227426067',
  '7501369200108',
  '7501165000315',
  '7501086453221',
  '7501007535432',
  '7501100088095'
)
order by p.nombre;
