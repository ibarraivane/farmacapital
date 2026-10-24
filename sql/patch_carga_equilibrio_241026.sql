-- Equilibrio · ticket 241026 · 2026-10-24 · cliente 307513 Palillero · foto sin folio de factura · Total $1,126.53 · 10 renglones / 27 pzas. Claves EQF → EAN ficha/Levic/mayoreo. Lote de fábrica sí. Caducidad NO: MMAA de la caja. 0000 inválido.
-- 4 alta(s) stock 0. 6 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_241026 (
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

insert into _fc_eq_241026 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502223112445', 'EQ-QUM052', 'Quimikan benzocaína 200 mg/mL', 'QUM052 QUIMIKAN 1 SOL C/ APLI 10 ML 200MG/ 1 ML', 2, 71.10, 114, 'generico', 'Medicamentos', null, 'Solución bucal', 'Quimikan', 'Quimpharma', 'Frasco 10 mL con aplicador', 'Benzocaína', '200 mg/mL', false, true, null, null, '26FS34'),
  (2, '7502216790896', 'EQ-ULT284', 'Vildagliptina/metformina 50/500 mg', 'ULT284 VILDAGLIPTINA METFORMINA 30COMP', 1, 158.27, 254, 'generico', 'Medicamentos', 'Diabetes', 'Comprimido', 'Ultra', 'Ultra', 'Caja con 30 comprimidos', 'Vildagliptina / metformina', '50/500 mg', true, false, null, null, '6GM172A'),
  (3, '7501349020139', 'FC-LV-AMS495', 'Fluconazol 100 mg', 'AMS495 FLUCONAZOL 10 CAP 100 MG', 3, 19.18, 31, 'generico', 'Medicamentos', null, 'Cápsula', 'AMSA', 'AMSA', 'Caja con 10 cápsulas', 'Fluconazol', '100 mg', true, true, null, null, 'U26A296'),
  (4, '7502209858190', 'EQ-AVT202', 'Cidorix clopidogrel 75 mg', 'AVT202 CIDORIX 14 TAB 75 MG', 4, 22.51, 37, 'generico', 'Medicamentos', 'Cardiovascular', 'Tableta', 'Cidorix', 'Avitus', 'Caja con 14 tabletas', 'Clopidogrel', '75 mg', true, false, null, null, 'SD26119'),
  (5, '7501349022126', 'EQ-AMS404', 'Metamizol sódico 1 g/2 ml', 'AMS404 METAMIZOL SODICO 3 AMP 1G/2ML', 5, 20.06, 33, 'generico', 'Medicamentos', 'Dolor', 'Solución inyectable', 'AMSA', 'AMSA', 'Caja con 3 ampolletas de 2 ml', 'Metamizol sódico', '1 g/2 ml', true, false, null, null, 'B26E508'),
  (6, '7502001165328', 'EQ-SON237', 'Expicin ampicilina 500 mg', 'SON237 EXPICIN 20 CAPS 500 MG', 3, 31.52, 51, 'generico', 'Medicamentos', 'Antibiótico', 'Cápsula', 'Expicin', 'Son''s', 'Caja con 20 cápsulas', 'Ampicilina', '500 mg', true, true, null, null, 'B2608303'),
  (7, '7502009745614', 'FC-492D652F', 'Cefalver cefalexina 1 g', 'MAV260 CEFALVER 12 TAB 1 G', 3, 62.49, 100, 'generico', 'Medicamentos', 'Antibiótico', 'Tableta', 'Cefalver', 'Maver', 'Caja con 12 tabletas', 'Cefalexina', '1 g', true, true, null, null, '260969'),
  (8, '7502209858183', 'EQ-AVT203', 'Cidorix clopidogrel 75 mg', 'AVT203 CIDORIX 28 TAB 75 MG', 4, 18.77, 31, 'generico', 'Medicamentos', 'Cardiovascular', 'Tableta', 'Cidorix', 'Avitus', 'Caja con 28 tabletas', 'Clopidogrel', '75 mg', true, true, null, null, 'SD25083'),
  (9, '7502216790490', 'EQ-ULT285', 'Vildagliptina/metformina 50/850 mg', 'ULT285 VILDAGLIPTINA METFORMINA 30 COMP', 1, 172.28, 276, 'generico', 'Medicamentos', 'Diabetes', 'Comprimido', 'Ultra', 'Ultra', 'Caja con 30 comprimidos', 'Vildagliptina / metformina', '50/850 mg', true, false, null, null, '6GM021A'),
  (10, '7500831405888', 'FC-31405888', 'Plusgel antiácido 200/200/20 mg', 'COL083 PLUS GEL 50 TAB 200/200/20 MG', 1, 48.79, 79, 'generico', 'Medicamentos', 'Antiácido', 'Tableta masticable', 'Plusgel', 'Collins', 'Frasco con 50 tabletas masticables', 'Hidróxido de aluminio / hidróxido de magnesio / dimeticona', '200/200/20 mg', false, true, null, null, '26142071');

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
  'Alta Equilibrio 241026 · 2026-10-24 · listo para pistola',
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
  from _fc_eq_241026
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
  from _fc_eq_241026
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
  from _fc_eq_241026
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '241026',
  '2026-10-24',
  1126.53,
  'borrador',
  'Ticket Equilibrio folio 241026 (foto sin encabezado; cliente 307513 Luis Angel) · 24-oct-2026 · 27 pzas · $1,126.53 · lote de fábrica en renglón; MMAA de la caja · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '241026'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 1126.53,
  fecha = '2026-10-24',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio folio 241026 (foto sin encabezado; cliente 307513 Luis Angel) · 24-oct-2026 · 27 pzas · $1,126.53 · lote de fábrica en renglón; MMAA de la caja · cola Recibir',
  updated_at = now()
where folio = '241026'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '241026'
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
from _fc_eq_241026 t
join public.recepciones r
  on r.folio = '241026'
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
from _fc_eq_241026 t
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
where r.folio = '241026'
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
from _fc_eq_241026 t
order by t.linea;

commit;
