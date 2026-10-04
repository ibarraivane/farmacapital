-- Cityfarma · S327411 · 2026-09-30 17:22 · Pasillo E-F 44A
-- 43 piezas / 13 productos · pendiente $4,165.25 (= subtotal + IVA 16%).
-- Costo = P.U. unitario del ticket. Pasta Lassar EAN 7501417006133 (check digit).
-- Piezas ticket (suma qty): 43. Total $4165.25.
-- 0 alta(s) stock 0. 13 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): ninguno.
-- Costo = P.U. unitario del ticket (NUNCA el importe del renglón).
-- Caducidad NO del papel: MMAA de la caja. No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s327411 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,4) not null,
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

insert into _fc_cf_s327411 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501349014190', 'EQ-AMS147', 'Ácido alendrónico AMSA 10 mg C/30', 'ACIDO ALENDRONICO 70', 5, 23.87, 39, 'generico', 'Medicamentos', null, 'Tableta', 'AMSA', 'AMSA', 'Caja con 30 tabletas', 'Ácido alendrónico', '10 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/alendronico-10-7501349014190.jpg', 'catalogo-propia/alendronico-10-7501349014190.jpg', null),
  (2, '7501300450227', 'FC-00450227', 'Bactrim suspensión 200/40 mg 100 ml', 'BACTRIM SUSP 200/40M', 3, 185.63, 233, 'marca', 'Medicamentos', null, 'Suspensión', 'Bactrim', 'Roche', 'Frasco 100 ml', 'Sulfametoxazol / trimetoprima', '200/40 mg/5 ml', true, true, null, null, null),
  (3, '7501008427330', 'FC-08427330', 'Bepanthen pomada 100 g', 'BEPANTHEN 100GR POM', 2, 131.67, 165, 'marca', 'Dermocosmético', 'Piel', 'Pomada', 'Bepanthen', 'Bayer', 'Tubo 100 g', 'Dexpantenol', null, false, true, null, null, null),
  (4, '7501008427347', 'FC-08427347', 'Bepanthen pomada 30 g', 'BEPANTHEN 30GR', 3, 64.37, 81, 'marca', 'Dermocosmético', 'Piel', 'Pomada', 'Bepanthen', 'Bayer', 'Tubo 30 g', 'Dexpantenol', null, false, true, null, null, null),
  (5, '7506022331502', 'EQ-JAY263', 'Diflosensi dapagliflozina 10 mg C/28', 'DIFLOSENSI 10MG C28', 4, 298.91, 479, 'generico', 'Medicamentos', null, 'Tableta', 'Diflosensi', null, 'Caja con 28 tabletas', 'Dapagliflozina', '10 mg', true, true, null, null, null),
  (6, '7501390912599', 'FC-90912599', 'Lactiflora Fem probiótico', 'LACTIFLORA FEM PROBI', 1, 362.93, 454, 'marca', 'Vitaminas', null, 'Cápsula', 'Lactiflora', null, 'Caja', null, null, false, true, null, null, null),
  (7, '7501109902866', 'FC-09902866', 'Motrin Infantil suspensión 20 ml', 'MOTRIN INF SUSP 20M', 2, 184.49, 231, 'marca', 'Medicamentos', null, 'Suspensión', 'Motrin', 'Johnson & Johnson', 'Frasco 20 ml', 'Ibuprofeno', null, false, true, null, null, null),
  (8, '7501417006133', 'FC-17006133', 'Pasta de Lassar óxido de zinc 145 g', 'PASTA LASSAR 145G DO', 4, 43.46, 55, 'marca', 'Cuidado personal', 'Piel', 'Pasta', 'Pasta de Lassar', null, 'Tarro 145 g', 'Óxido de zinc', null, false, true, 'https://www.farmacapital.mx/catalogo-propia/pasta-de-lassar-145g.jpg', 'catalogo-propia/pasta-de-lassar-145g.jpg', null),
  (9, '7501314704156', 'FC-14704156', 'Senosiain adulto C/10', 'SENOSIAIN AD C 10', 4, 58.74, 74, 'marca', 'Medicamentos', null, 'Supositorio', 'Senosiain', 'Senosiain', 'Caja con 10', null, null, false, true, null, null, null),
  (10, '7501314704187', 'FC-14704187', 'Senosiain bebé C/10', 'SENOSIAIN BEBE C 10', 4, 58.74, 74, 'marca', 'Medicamentos', null, 'Supositorio', 'Senosiain', 'Senosiain', 'Caja con 10', null, null, false, true, null, null, null),
  (11, '7501314704163', 'FC-14704163', 'Senosiain niño C/10', 'SENOSIAIN NIÑO C 10', 4, 58.74, 74, 'marca', 'Medicamentos', null, 'Supositorio', 'Senosiain', 'Senosiain', 'Caja con 10', null, null, false, true, null, null, null),
  (12, '785118754259', 'FC-18754259', 'Supratex levodropropizina jarabe 120 ml', 'SUPRATEX JBE 120ML L', 2, 41.52, 67, 'generico', 'Medicamentos', null, 'Jarabe', 'Supratex', 'MAVI', 'Frasco 120 ml', 'Levodropropizina', '600 mg/100 ml', false, true, null, null, null),
  (13, '650240052545', 'FC-00525451', 'XL-3 antigripal C/10', 'XL3 C10 ANTIGRIPAL', 5, 28.65, 46, 'generico', 'Medicamentos', null, 'Tableta', 'XL-3', 'Genomma Lab', 'Caja con 10 tabletas', 'Paracetamol + fenilefrina + clorfenamina', null, false, true, null, null, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when nullif(btrim(t.ean), '') is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  nullif(btrim(t.ean), ''),
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Cityfarma S327411 · 2026-09-30 · listo para pistola',
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
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_cf_s327411
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where (
    nullif(btrim(t.ean), '') is null
    or public.fc_buscar_producto_escaneo(t.ean) is null
  )
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_cf_s327411
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
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
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(
    nullif(trim(p.codigo_barras), ''),
    nullif(btrim(t.ean), '')
  )
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_cf_s327411
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.proveedores (nombre, activo)
select 'Cityfarma', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('Cityfarma')
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma',
  'S327411',
  '2026-09-30',
  4165.25,
  'borrador',
  'Cityfarma S327411 · 30-sep-2026 · Luis Angel · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = 'S327411'
    and coalesce(proveedor, '') ilike '%Cityfarma%'
);

update public.recepciones
set
  total_ticket = 4165.25,
  fecha = '2026-09-30',
  proveedor = 'Cityfarma',
  notas = 'Cityfarma S327411 · 30-sep-2026 · Luis Angel · MMAA de la caja',
  updated_at = now()
where folio = 'S327411'
  and coalesce(proveedor, '') ilike '%Cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S327411'
  and coalesce(r.proveedor, '') ilike '%Cityfarma%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(btrim(t.ean), ''),
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
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_cf_s327411 t
join public.recepciones r
  on r.folio = 'S327411'
 and coalesce(r.proveedor, '') ilike '%Cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) end,
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
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_cf_s327411
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
join public.productos p on p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
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
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = 'S327411'
  and coalesce(r.proveedor, '') ilike '%Cityfarma%'
order by i.id;
