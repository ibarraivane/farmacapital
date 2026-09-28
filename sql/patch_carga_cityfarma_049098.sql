-- Cityfarma Iztapalapa · factura INV/2026/09/2057 · folio 049098 · 2026-09-28
-- CFDI Yalesa (DFY171116BKA). 16 renglones / 34 pzas.
-- Subtotal $6,431.19 + IVA 16% $133.85 = TOTAL $6,565.04.
-- Costo = Precio U de la factura (antes de IVA).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 12 alta(s) stock 0. 4 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_049098 (
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

insert into _fc_cf_049098 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '8429420084520', 'FC-20084520', 'Bexident Post colutorio 250 ml', 'BEXIDENT POST COLUT 250 ML', 1, 359.14, 449, 'marca', 'Cuidado personal', 'Bucal', 'Colutorio', 'Bexident', 'Isdin', 'Frasco 250 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/isdin-bexident-post-colutorio-250ml-8429420084520.jpg', 'catalogo-propia/isdin-bexident-post-colutorio-250ml-8429420084520.jpg', null),
  (2, '8429420084674', 'FC-20084674', 'Bexident Post gel tópico 25 ml', 'BEXIDENT POST GEL TOPICO 25ML', 1, 226.10, 283, 'marca', 'Cuidado personal', 'Bucal', 'Gel', 'Bexident', 'Isdin', 'Tubo 25 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/isdin-bexident-post-gel-25ml-8429420084674.jpg', 'catalogo-propia/isdin-bexident-post-gel-25ml-8429420084674.jpg', null),
  (3, '7501385491085', 'FC-85491085', 'Danzen serratiopeptidasa 10 mg C/20', 'DANZEN 10MG C20 TABS HORMONA', 1, 388.82, 487, 'marca', 'Medicamentos', null, 'Tableta', 'Danzen', 'Hormona', 'Caja con 20 tabletas', 'Serratiopeptidasa', '10 mg', true, true, null, null, null),
  (4, '7501298223711', 'FC-98223711', 'Dolo Neurobion C/10', 'DOLO NEUROBION TAB C 10', 3, 158.00, 198, 'marca', 'Vitaminas', null, 'Tableta', 'Neurobion', 'Probiomed', 'Caja con 10 tabletas', 'Diclofenaco / vitaminas B1 B6 B12', null, false, false, null, null, null),
  (5, '7501298223728', 'FC-98223728', 'Dolo Neurobion C/5', 'DOLO NEUROBION TAB C5', 3, 87.00, 109, 'marca', 'Vitaminas', null, 'Tableta', 'Neurobion', 'Probiomed', 'Caja con 5 tabletas', 'Diclofenaco / vitaminas B1 B6 B12', null, false, false, null, null, null),
  (6, '7501008497340', 'FC-84973401', 'Flanax naproxeno 550 mg C/12', 'FLANAX 550 C 12 TABS 162', 2, 176.38, 221, 'marca', 'Medicamentos', null, 'Tableta', 'Flanax', 'Bayer', 'Caja con 12 tabletas', 'Naproxeno', '550 mg', false, true, null, null, null),
  (7, '7502276040351', 'FC-6040351', 'Lotrimin Uno crema 1% 20 g', 'LOTRIMIN UNO CRA 1% 20G', 3, 70.24, 88, 'marca', 'Medicamentos', 'Dermatología', 'Crema', 'Lotrimin Uno', 'Bayer', 'Tubo 20 g', 'Bifonazol', '1%', false, true, null, null, null),
  (8, '7500435131834', 'FC-35131834', 'Pepto-Bismol masticable C/12', 'PEPTO BISMOL MAST C12TAB', 2, 48.92, 62, 'marca', 'Gastro', 'Antidiarreico', 'Tableta masticable', 'Pepto-Bismol', 'P&G', 'Caja con 12 tabletas', 'Subsalicilato de bismuto', null, false, false, null, null, null),
  (9, '7502240450230', 'FC-40450230', 'Rosel solución infantil 60 ml', 'ROSEL SOL INF 60ML', 3, 24.71, 31, 'marca', 'Medicamentos', 'Respiratorio', 'Solución', 'Rosel', 'Wermar', 'Frasco 60 ml', 'Paracetamol / amantadina / clorfenamina', '3 / 0.5 / 0.02 g / 60 ml', false, true, null, null, null),
  (10, '7501314703227', 'FC-14703227', 'Sies hidrosmina 200 mg C/20', 'SIES 200MG CAPS C20 HIDROSMINA', 2, 414.80, 519, 'marca', 'Medicamentos', null, 'Cápsula', 'Sies', 'Ferrer', 'Caja con 20 cápsulas', 'Hidrosmina', '200 mg', true, false, null, null, null),
  (11, '7501080912083', 'FC-80912083', 'Sterimar solución nasal 50 ml', 'STERIMAR SOLUCION C 50 ML', 2, 125.67, 158, 'marca', 'Medicamentos', 'Respiratorio', 'Spray nasal', 'Sterimar', 'Sofibel', 'Frasco 50 ml', null, null, false, false, null, null, null),
  (12, '7501088505430', 'FC-88505430', 'Synalar Simple fluocinolona 0.01% crema 20 g', 'SYNALAR SIMPLE 0.01% CRA 20GR', 2, 131.52, 165, 'marca', 'Medicamentos', 'Dermatología', 'Crema', 'Synalar', 'CHINOIN', 'Tubo 20 g', 'Fluocinolona acetónido', '0.01%', true, false, null, null, null),
  (13, '7501088505454', 'FC-88505454', 'Synalar Simple fluocinolona 0.025% crema 20 g', 'SYNALAR SIMPLE 0.025% CRA 20GR', 1, 181.36, 227, 'marca', 'Medicamentos', 'Dermatología', 'Crema', 'Synalar', 'CHINOIN', 'Tubo 20 g', 'Fluocinolona acetónido', '0.025%', true, false, null, null, null),
  (14, '7501065026439', 'FC-65026439', 'Tesalon benzonatato 100 mg C/20', 'TESALON 100MG C20TABS', 3, 145.37, 182, 'marca', 'Medicamentos', 'Respiratorio', 'Perla / tableta', 'Tesalon', 'GSK', 'Caja con 20', 'Benzonatato', '100 mg', false, false, null, null, null),
  (15, '3662042003059', 'FC-42003059', 'Thealoz Duo gotas 10 ml', 'THEALOZ DUO 10ML', 1, 537.23, 672, 'marca', 'Oftálmico', 'Sequedad ocular', 'Gotas oftálmicas', 'Thealoz Duo', 'Théa', 'Frasco 10 ml', 'Trehalosa / hialuronato de sodio', '3% / 0.15%', false, false, 'https://www.farmacapital.mx/catalogo-propia/thealoz-duo-gotas-10ml-3662042003059.jpg', 'catalogo-propia/thealoz-duo-gotas-10ml-3662042003059.jpg', null),
  (16, '7501037925579', 'FC-37925579', 'Trayenta linagliptina 5 mg C/30', 'TRAYENTA 5MG T30', 4, 372.00, 465, 'marca', 'Diabetes', null, 'Tableta', 'Trayenta', 'Boehringer Ingelheim', 'Caja con 30 tabletas', 'Linagliptina', '5 mg', true, false, null, null, null);

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
  'Alta Cityfarma Iztapalapa 049098 · 2026-09-28 · listo para pistola',
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
  from _fc_cf_049098
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
  from _fc_cf_049098
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
  from _fc_cf_049098
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  '049098',
  '2026-09-28',
  6565.04,
  'borrador',
  'Factura Cityfarma INV/2026/09/2057 · folio 049098 · 28-sep-2026 16:45 · Yalesa DFY171116BKA · cliente Palillero · tarjeta · subtotal $6,431.19 + IVA $133.85 = $6,565.04 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '049098'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 6565.04,
  fecha = '2026-09-28',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Factura Cityfarma INV/2026/09/2057 · folio 049098 · 28-sep-2026 16:45 · Yalesa DFY171116BKA · cliente Palillero · tarjeta · subtotal $6,431.19 + IVA $133.85 = $6,565.04 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '049098'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '049098'
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
from _fc_cf_049098 t
join public.recepciones r
  on r.folio = '049098'
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
from _fc_cf_049098 t
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
where r.folio = '049098'
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
from _fc_cf_049098 t
order by t.linea;

commit;
