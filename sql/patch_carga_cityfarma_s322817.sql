-- =============================================================================
-- ESTE es el archivo para Supabase (SQL). NO pegues scripts/generar_carga_*.py
-- Archivo: sql/patch_carga_cityfarma_s322817.sql
-- Pegar TODO abajo en Supabase → SQL Editor → Run.
-- =============================================================================
-- Cityfarma Iztapalapa · orden S322817 · 2026-09-14 17:30
-- Ticket térmico Central de Abastos. P.U. ya trae IVA (total impreso $3940.28).
-- 23 renglones · 21 altas stock 0 · 2 ya en catálogo.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- Nombres de ficha (YZA/Fahorro/Kenvue), no del ticket.
-- Fotos en public/catalogo-propia/ (tras deploy). Pendientes: 7506494600311, 7501573925071, 7503003738671, 7503045798022, 7502009749469, 7501258208550.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.

begin;

create temp table _fc_cf_s322817 (
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
  imagen text
) on commit drop;

insert into _fc_cf_s322817 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, imagen
) values
  (1, '7503004908875', 'FC-04908875', 'Acarbosa Alpharma 50 mg C/30 tabletas', 'ACARBOSA 50MG C30TAB', 1, 45.20, 73, 'generico', 'Diabetes', null, 'Tableta', 'Alpharma', 'ALPHARMA', 'Caja con 30 tabletas', 'Acarbosa', '50 mg', true, 'https://www.farmacapital.mx/catalogo-propia/acarbosa-alpharma-50mg-30tab-7503004908875.jpg'),
  (2, '7501349028296', 'FC-49028296', 'Bicalutamida AMSA 50 mg C/14 tabletas', 'BICALUTAMIDA 50MG C1', 2, 134.52, 216, 'generico', 'Medicamentos', 'Oncología', 'Tableta', 'AMSA', 'AMSA', 'Caja con 14 tabletas', 'Bicalutamida', '50 mg', true, 'https://www.farmacapital.mx/catalogo-propia/bicalutamida-50mg-14tab-7501349028296.jpg'),
  (3, '7501390910182', 'FC-90910182', 'Biotrefón L cobamamida 1000 mcg polvo C/12 sobres', 'BIOTREFON L C12 SOBR', 1, 298.69, 478, 'marca', 'Vitaminas', null, 'Polvo oral', 'Biotrefón L', 'ITALMEX', 'Caja con 12 sobres', 'Cobamamida', '1000 mcg', false, 'https://www.farmacapital.mx/catalogo-propia/biotrefon-l-1000mcg-12sobres-7501390910182.jpg'),
  (4, '7501478317421', 'FC-78317421', 'Bocetix levocetirizina 0.5 mg/ml solución oral 150 ml', 'BOCETIX LEVOCETIRIZI', 2, 66.70, 107, 'marca', 'Respiratorio', 'Antihistamínico', 'Solución oral', 'Bocetix', 'VITAE', 'Frasco 150 ml', 'Levocetirizina', '0.5 mg/ml', false, 'https://www.farmacapital.mx/catalogo-propia/bocetix-levocetirizina-150ml.jpg'),
  (5, '7502009743993', 'FC-09743993', 'Carnitina +B Naturex L-carnitina C/30 cápsulas', 'CARNITINA 500MG C30', 2, 55.16, 89, 'marca', 'Vitaminas', 'Suplemento', 'Cápsula', 'Naturex', 'NATUREX', 'Frasco con 30 cápsulas', 'L-carnitina', '500 mg', false, 'https://www.farmacapital.mx/catalogo-propia/carnitina-naturex-500mg-30cap-7502009743993.jpg'),
  (6, '7506494600311', 'FC-94600311', 'Cloropiramina 25 mg tabletas', 'CLOROPIRAMINA 25MG C', 1, 40.24, 65, 'generico', 'Respiratorio', 'Antihistamínico', 'Tableta', 'Cloropiramina', null, null, 'Cloropiramina', '25 mg', true, null),
  (7, '7501836003140', 'FC-36003140', 'Contraxen carisoprodol 200 mg / naproxeno 250 mg C/30 cápsulas', 'CONTRAXEN 200MG/2500', 2, 78.80, 127, 'marca', 'Analgésico', 'Relajante muscular', 'Cápsula', 'Contraxen', 'LIFERPAL MD', 'Caja con 30 cápsulas', 'Carisoprodol / Naproxeno', '200 mg / 250 mg', true, 'https://www.farmacapital.mx/catalogo-propia/contraxen-200-250mg-30cap-7501836003140.jpg'),
  (8, '7501075711011', 'FC-75711011', 'Debisor dinitrato de isosorbida 10 mg C/20 tabletas', 'DEBISOR 10MG C20 TA', 3, 8.94, 15, 'marca', 'Cardiovascular', null, 'Tableta', 'Debisor', 'NOVAG', 'Caja con 20 tabletas', 'Dinitrato de isosorbida', '10 mg', true, 'https://www.farmacapital.mx/catalogo-propia/debisor-isosorbida-10mg-20tab-7501075711011.jpg'),
  (9, '7501300422750', 'FC-00422750', 'Dorixina Forte clonixinato de lisina 250 mg C/20 comprimidos', 'DORIXINA FTE 250MG C', 1, 239.40, 384, 'marca', 'Analgésico', null, 'Comprimido', 'Dorixina Forte', 'SIEGFRIED RHEIN', 'Caja con 20 comprimidos', 'Clonixinato de lisina', '250 mg', true, 'https://www.farmacapital.mx/catalogo-propia/dorixina-forte-250mg-20comp-7501300422750.jpg'),
  (10, '7501573925071', 'FC-73925071', 'Dosteril lisinopril 10 mg C/30 tabletas', 'DOSTERIL 10MG C30 TA', 4, 18.46, 30, 'marca', 'Cardiovascular', null, 'Tableta', 'Dosteril', 'BIOMEP', 'Caja con 30 tabletas', 'Lisinopril', '10 mg', true, null),
  (11, '75004996', 'FC-75004996', 'Espavén Pediátrico dimeticona 100 mg/ml gotas 30 ml', 'ESPAVEN PED GTS 15', 1, 175.97, 282, 'marca', 'Gastro', 'Antiflatulento', 'Gotas orales', 'Espavén', 'BAUSCH HEALTH', 'Frasco gotero 30 ml', 'Dimeticona', '100 mg/ml', false, 'https://www.farmacapital.mx/catalogo-propia/espaven-pediatrico-gotas-30ml-75004996.jpg'),
  (12, '3664798073256', 'FC-98073256', 'Histiacil GR3 ambroxol 20 mg pastillas limón C/18', 'HISTIACIL GR3 AMBROX', 1, 109.51, 176, 'marca', 'Respiratorio', null, 'Pastilla bucal', 'Histiacil', 'SANOFI', 'Caja con 18 pastillas', 'Ambroxol', '20 mg', false, 'https://www.farmacapital.mx/catalogo-propia/histiacil-gr3-ambroxol-limon-18-3664798073256.jpg'),
  (13, '7891317048860', 'FC-17048860', 'Melox Plus Cereza tabletas masticables C/30', 'MELOX PLUS C30 TABS', 1, 94.86, 152, 'marca', 'Gastro', 'Antiácido', 'Tableta masticable', 'Melox Plus', 'EUROFARMA', 'Caja con 30 tabletas', 'Aluminio / Magnesio / Simeticona', '200/200/25 mg', false, 'https://www.farmacapital.mx/catalogo-propia/melox-plus-cereza-30tab-7891317048860.jpg'),
  (14, '7501109902637', 'FC-09902637', 'Motrin Pediátrico ibuprofeno 40 mg/ml gotas 15 ml', 'MOTRIN GTS PEDIATR', 1, 117.88, 189, 'marca', 'Analgésico', 'Pediátrico', 'Suspensión oral', 'Motrin', 'KENVUE', 'Frasco 15 ml + pipeta', 'Ibuprofeno', '40 mg/ml', false, 'https://www.farmacapital.mx/catalogo-propia/motrin-pediatrico-gotas-15ml-7501109902637.jpg'),
  (15, '7501109902866', 'FC-09902866', 'Motrin Infantil ibuprofeno suspensión 120 ml', 'MOTRIN INF SUSP 20M', 2, 184.49, 296, 'marca', 'Analgésico', 'Pediátrico', 'Suspensión oral', 'Motrin', 'KENVUE', 'Frasco 120 ml', 'Ibuprofeno', '100 mg/5 ml', false, 'https://www.farmacapital.mx/catalogo-propia/motrin-infantil-susp-120ml-7501109902866.jpg'),
  (16, '7506295337454', 'FC-95337454', 'Clearblue Digital prueba de embarazo con indicador de semanas', 'PBA EMB CLEAR BLUE D', 2, 191.15, 306, 'marca', 'Pruebas', 'Embarazo', 'Prueba diagnóstica', 'Clearblue', 'SPD / P&G', 'Caja con 1 prueba', null, null, false, 'https://www.farmacapital.mx/catalogo-propia/clearblue-digital-embarazo-7506295337454.jpg'),
  (17, '7502009744341', 'FC-09744341', 'Prilver ramipril 5 mg C/16 tabletas', 'PRILVER 5MG C16 TABS', 3, 38.86, 63, 'marca', 'Cardiovascular', null, 'Tableta', 'Prilver', 'MAVER', 'Caja con 16 tabletas', 'Ramipril', '5 mg', true, 'https://www.farmacapital.mx/catalogo-propia/prilver-ramipril-5mg-16tab-7502009744341.jpg'),
  (18, '7501168810713', 'FC-68810713', 'Salofalk mesalazina 500 mg C/40 tabletas', 'SALOFALK 500 MG C 40', 1, 446.06, 714, 'marca', 'Gastro', null, 'Tableta', 'Salofalk', 'FARMASA', 'Caja con 40 tabletas', 'Mesalazina', '500 mg', true, 'https://www.farmacapital.mx/catalogo-propia/salofalk-mesalazina-500mg-40tab-7501168810713.jpg'),
  (19, '7503003738671', 'FC-03738671', 'Sepia itraconazol 33.3 mg / secnidazol 166.6 mg C/16 cápsulas', 'SEPIA 33 3 166 6MG', 1, 96.59, 155, 'marca', 'Ginecología', null, 'Cápsula', 'Sepia', 'WERMAR', 'Caja con 16 cápsulas', 'Itraconazol / Secnidazol', '33.3 mg / 166.6 mg', true, null),
  (20, '7503045798022', 'FC-45798022', 'Dinaglix-Duo sitagliptina 50 mg / metformina 500 mg C/28', 'SITAGLIPTINA METFORM', 1, 98.27, 158, 'marca', 'Diabetes', null, 'Comprimido', 'Dinaglix-Duo', 'MAVER', 'Caja con 28 comprimidos', 'Sitagliptina / Metformina', '50 mg / 500 mg', true, null),
  (21, '7502009749469', 'FC-09749469', 'Tribenósido 5% / lidocaína 2% crema rectal 30 g', 'TRIBENOSIDO/LIDOCAIN', 2, 78.00, 125, 'generico', 'Gastro', 'Proctología', 'Crema rectal', 'Maver', 'MAVER', 'Tubo 30 g', 'Tribenósido / Lidocaína', '5% / 2%', true, null),
  (22, '7501065054043', 'FC-65054043', 'Tums Extra surtido 750 mg C/3 (3 rollos × 8)', 'TUMS SURT C3', 4, 39.44, 64, 'marca', 'Gastro', 'Antiácido', 'Tableta masticable', 'Tums', 'HALEON', '3 rollos × 8 tabletas', 'Carbonato de calcio', '750 mg', false, 'https://www.farmacapital.mx/catalogo-propia/tums-extra-surtido-c3-7501065054043.jpg'),
  (23, '7501258208550', 'FC-58208550', 'Valaciclovir Serral 500 mg C/10 tabletas', 'VALACICLOVIR 500MG T', 1, 224.98, 360, 'generico', 'Medicamentos', 'Antiviral', 'Tableta', 'Serral', 'SERRAL', 'Caja con 10 tabletas', 'Valaciclovir', '500 mg', true, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
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
  t.tipo,
  'Alta Cityfarma S322817 · 2026-09-14 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_cf_s322817 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo solo si el ticket es más barato (o no había). PVP solo si está en 0.
update public.productos p
set
  costo = case
    when coalesce(p.costo, 0) <= 0 then t.costo
    when t.costo < p.costo then t.costo
    else p.costo
  end,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cf_s322817 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    coalesce(p.costo, 0) <= 0
    or t.costo < p.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha / foto si faltan (no pisa lo que ya esté).
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
from _fc_cf_s322817 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S322817',
  '2026-09-14',
  3940.28,
  'borrador',
  'Ticket Cityfarma S322817 · 2026-09-14 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'S322817' and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 3940.28,
  fecha = '2026-09-14',
  proveedor = 'Cityfarma Iztapalapa',
  estado = 'borrador',
  notas = 'Ticket Cityfarma S322817 · 2026-09-14 · cola Recibir; stock al confirmar pistola'
where folio = 'S322817'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad');

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S322817'
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
from _fc_cf_s322817 t
join public.recepciones r
  on r.folio = 'S322817'
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
  (producto_id, url, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from _fc_cf_s322817 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  r.id, r.proveedor, r.folio, r.estado, r.total_ticket,
  (select count(*) from public.recepcion_items i where i.recepcion_id = r.id) as renglones
from public.recepciones r
where r.folio = 'S322817'
order by r.id desc;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'EN CATALOGO' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = 'S322817' and coalesce(r.proveedor, '') ilike '%cityfarma%'
order by i.id;

select
  p.sku, p.codigo_barras as ean, left(p.nombre, 52) as nombre,
  p.marca, p.costo, p.precio, p.stock, left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
  '7503004908875',
  '7501349028296',
  '7501390910182',
  '7501478317421',
  '7502009743993',
  '7506494600311',
  '7501836003140',
  '7501075711011',
  '7501300422750',
  '7501573925071',
  '75004996',
  '3664798073256',
  '7891317048860',
  '7501109902637',
  '7501109902866',
  '7506295337454',
  '7502009744341',
  '7501168810713',
  '7503003738671',
  '7503045798022',
  '7502009749469',
  '7501065054043',
  '7501258208550'
)
order by p.nombre;
