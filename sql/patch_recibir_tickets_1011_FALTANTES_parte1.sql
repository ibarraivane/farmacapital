-- =============================================================================
-- FALTANTES 10-nov (Benavides 7993605 ya cargado). Pegar TODO → Run.
-- Cityfarma S339687 · Equilibrio 451326 · Farmalive 16337 · F-42 28786 · FESA 1-5573418
-- Idempotente. Al final VERIFICACION con los 6 folios.
-- =============================================================================

-- ========== Cityfarma Iztapalapa S339687 ==========
-- Cityfarma Iztapalapa · folio S339687 · 2026-11-10 · total $3,211.17 · 18 renglones
-- 13 alta(s) stock 0. 5 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_cf_s339687 (
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

insert into _fc_cf_s339687 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
) values
  (1, '7501125116810', 'FC-25116810', 'Agrifen', 'AGRIFEN TAB C 10 PIS', 10, 16.11, 21, 'marca', 'Medicamentos', null, 'Tabletas', 'Agrifen', 'Pisa', 'Caja con 10 tabletas', 'Paracetamol / Fenilefrina / Clorfenamina', null, false, true, null),
  (2, '7500462746643', 'FC-62746643', 'Ajolotius pastillas', 'AJOLOTIUS C10 PAST M', 2, 18.11, 23, 'marca', 'Vitaminas', null, 'Pastillas', 'Ajolotius', 'Bioalimentos', 'Caja con 10 pastillas', null, null, false, true, null),
  (3, '7506452400267', 'FC-52400267', 'Ajolotius jarabe Elderberry', 'AJOLOTIUS JBE 250ML', 2, 69.92, 88, 'marca', 'Vitaminas', null, 'Jarabe', 'Ajolotius', 'Bioalimentos', 'Frasco 250 ml', null, null, false, true, null),
  (4, '7501349027343', 'FC-49027343', 'Amsafast orlistat 120 mg', 'AMSAFAST 120MG CAP C', 2, 87.10, 109, 'marca', 'Gastro', 'Obesidad', 'Cápsulas', 'Amsafast', 'AMSA', 'Caja con 21 cápsulas', 'Orlistat', '120 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/amsafast-120mg-c21.jpg'),
  (5, '7502211781059', 'FC-11781059', 'Bromicof solución infantil', 'BROMICOF SOL INF 100', 2, 13.95, 18, 'marca', 'Medicamentos', null, 'Solución', 'Bromicof', null, 'Frasco 100 ml', null, null, false, false, null),
  (6, '7501349027329', 'FC-49027329', 'Dexametasona 8 mg/2 ml', 'DEXAMETASONA 8MG 2ML', 10, 7.00, 12, 'generico', 'Medicamentos', null, 'Solución inyectable', 'AMSA', 'AMSA', 'Ampolleta 2 ml', 'Dexametasona', '8 mg/2 ml', true, false, null),
  (7, '7502009747274', 'FC-09747274', 'Dolver ibuprofeno 600 mg', 'DOLVER 600MG C 10 TA', 5, 17.53, 22, 'marca', 'Analgésico', null, 'Tabletas', 'Dolver', 'Maver', 'Caja con 10 tabletas', 'Ibuprofeno', '600 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/dolver-600mg-10tab-7502009747274.jpg'),
  (8, '7501300408556', 'FC-00408556', 'Dorixina Relax', 'DORIXINA RELAX C 20', 2, 320.00, 400, 'marca', 'Analgésico', null, 'Tabletas', 'Dorixina', 'Roemmers', 'Caja con 20 tabletas', 'Clonixinato de lisina / Ciclobenzaprina', '125 mg / 5 mg', true, false, null),
  (9, '7501034605115', 'FC-34605115', 'Jardianz empagliflozina 25 mg', 'JARDIANZ 25MG TAB C3', 1, 850.00, 1063, 'marca', 'Medicamentos', 'Diabetes', 'Tabletas', 'Jardianz', null, 'Caja con 30 tabletas', 'Empagliflozina', '25 mg', true, false, null),
  (10, '7503008344488', 'FC-08344488', 'Lactopram AD', 'LACTOPRAM AD C20 CA', 3, 27.33, 35, 'marca', 'Gastro', null, 'Cápsulas', 'Lactopram', null, 'Caja con 20 cápsulas', null, null, false, false, null),
  (11, '7503008344716', 'FC-08344716', 'Lafemme vitaminas', 'LAFEMME VITAMINAS ME', 2, 84.97, 107, 'marca', 'Vitaminas', null, 'Tabletas', 'Lafemme', null, 'Multivitamínico', null, null, false, false, null),
  (12, '7501007535487', 'FC-07535487', 'Motrin gotas pediátricas', 'MOTRIN GTS PED FSA-', 2, 113.76, 143, 'marca', 'Analgésico', 'Pediátrico', 'Gotas', 'Motrin', 'Kenvue', 'Frasco gotero', 'Ibuprofeno', null, false, false, null),
  (13, '7502001166028', 'FC-01166028', 'Neoderm-F crema', 'NEODERM-F CREMA ACE', 1, 25.30, 41, 'generico', 'Dermatología', null, 'Crema', 'Neoderm-F', 'Sons', 'Tubo', null, null, false, false, null),
  (14, '7506442700759', 'FC-42700759', 'Olmesartán 20 mg', 'OLMESARTAN 20MG C14', 1, 73.79, 119, 'generico', 'Medicamentos', 'Cardiovascular', 'Tabletas', 'Olmesartán', null, 'Caja con 14 tabletas', 'Olmesartán', '20 mg', true, false, null),
  (15, '7503000422658', 'FC-00422658', 'Pentiver ampicilina', 'PENTIVER AMPICILINA', 2, 24.58, 40, 'generico', 'Medicamentos', null, 'Cápsulas', 'Pentiver', null, 'Caja', 'Ampicilina', null, true, false, null),
  (16, '7501075723724', 'FC-75723724', 'Rovemax diosmina/hesperidina', 'ROVEMAX TAB C20 DIOS', 2, 59.95, 75, 'marca', 'Medicamentos', 'Circulación', 'Tabletas', 'Rovemax', 'Novag', 'Caja con 20 tabletas', 'Diosmina / Hesperidina', null, false, false, null),
  (17, '7501089810007', 'FC-89810007', 'Venastat gel fresco', 'VENASTAT GEL FRESCO', 1, 112.65, 141, 'marca', 'Medicamentos', 'Circulación', 'Gel', 'Venastat', null, 'Tubo', null, null, false, false, null),
  (18, '7502009744853', 'FC-09744853', 'Versalver 160 mg', 'VERSALVER 160MG C14', 2, 82.00, 103, 'marca', 'Medicamentos', null, 'Tabletas', 'Versalver', 'Maver', 'Caja con 14 tabletas', null, '160 mg', true, false, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Cityfarma Iztapalapa S339687 · 2026-11-10 · listo para pistola',
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
  from _fc_cf_s339687
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s339687
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
  codigo_barras = case
    when t.ean is not null then coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
    else p.codigo_barras
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s339687
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S339687',
  '2026-11-10',
  3211.17,
  'borrador',
  'Cityfarma Iztapalapa · orden S339687 · 10-nov-2026 16:59 · Jonathan Moreno · cliente Luis Angel Palillero · ALMACEN · TC $3,211.17 · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = 'S339687'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 3211.17,
  fecha = '2026-11-10',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Cityfarma Iztapalapa · orden S339687 · 10-nov-2026 16:59 · Jonathan Moreno · cliente Luis Angel Palillero · ALMACEN · TC $3,211.17 · cola Recibir',
  updated_at = now()
where folio = 'S339687'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S339687'
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
  coalesce(nullif(btrim(t.ean), ''), t.sku),
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
from _fc_cf_s339687 t
join public.recepciones r
  on r.folio = 'S339687'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = 'S339687'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_cf_s339687 t
order by t.linea;

commit;


-- ========== Equilibrio 451326 ==========
-- Equilibrio · folio 451326 · 2026-11-10 · total $202.63 · 2 renglones
-- Claves SON237/SON164 → EAN Sons. Costo = P.U. neto.
-- 2 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_eq_451326 (
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

insert into _fc_eq_451326 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
) values
  (1, '7502001165328', 'FC-01165328', 'Expicin ampicilina 500 mg', 'SON237 EXPICIN 20 CAPS 500 MG', 3, 32.43, 52, 'generico', 'Medicamentos', null, 'Cápsulas', 'Expicin', 'Sons', 'Caja con 20 cápsulas', 'Ampicilina', '500 mg', true, false, null),
  (2, '7502001163485', 'FC-01163485', 'Clotrimazol Dual', 'SON164 CLOTRIMAZOL DUAL 3 OVS 200MG 1CMA 10G', 2, 52.67, 85, 'generico', 'Medicamentos', null, 'Óvulos + crema', 'Clotrimazol Dual', 'Sons', '3 óvulos 200 mg + crema 1% 10 g', 'Clotrimazol', '200 mg / 1%', false, false, 'https://www.farmacapital.mx/catalogo-propia/clotrimazol-dual-sons.jpg');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Equilibrio 451326 · 2026-11-10 · listo para pistola',
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
  from _fc_eq_451326
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_eq_451326
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
  codigo_barras = case
    when t.ean is not null then coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
    else p.codigo_barras
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_eq_451326
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '451326',
  '2026-11-10',
  202.63,
  'borrador',
  'Equilibrio Iztapalapa 2 · ticket 451326 · 10-nov-2026 17:11 · cliente 307513 Luis Angel Palillero · costo neto tras descuento · ahorro ticket $1,067.37 · lote/cad del papel NO se guarda (MMAA de la caja) · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '451326'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 202.63,
  fecha = '2026-11-10',
  proveedor = 'Equilibrio',
  notas = 'Equilibrio Iztapalapa 2 · ticket 451326 · 10-nov-2026 17:11 · cliente 307513 Luis Angel Palillero · costo neto tras descuento · ahorro ticket $1,067.37 · lote/cad del papel NO se guarda (MMAA de la caja) · cola Recibir',
  updated_at = now()
where folio = '451326'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '451326'
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
  coalesce(nullif(btrim(t.ean), ''), t.sku),
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
from _fc_eq_451326 t
join public.recepciones r
  on r.folio = '451326'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '451326'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_eq_451326 t
order by t.linea;

commit;
