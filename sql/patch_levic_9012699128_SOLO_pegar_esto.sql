-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase - SQL Editor - Run
-- Levic folio A 9012699128 · 16-nov-2026 · hoja 1 de 2 · $582.13 (IVA 0%)
-- 5 renglones / 11 pzas visibles. Falta hoja 2: total provisional = suma hoja 1.
-- Merge a GitHub NO crea la tarjeta. Este Run si.
-- Sin bloques dollar-quote. Sin galeria extra. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. 0000 invalido.
-- Luego: tablet Recibir - recargar - tarjeta Levic 9012699128.
-- =============================================================================

-- Levic · F. Interno A 9012699128 · CFDI 6E1D1BA1-7C86-4E90-8787-8B08E8B45856
-- Emision 2026-11-16T13:55:40 · PUE efectivo · receptor LUIS ANGEL PALILLERO VENTURA
-- Costo = Precio neto. Lote de fabrica en el papel. Caducidad NO se escribe.
-- Nombres de mostrador (ficha), no del codigo del ticket.
-- Productos ya en catalogo (BIO108/GEP030/LOE135/MAV300/MAV414). Altas solo si faltan.

begin;

create temp table _fc_rx_levic9012699128 (
  linea integer primary key,
  clave text not null,
  ean text,
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
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  stock_minimo integer not null,
  lote text,
  imagen text
) on commit drop;

insert into _fc_rx_levic9012699128 (
  linea, clave, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  forma, marca, presentacion, principio_activo, concentracion, receta,
  stock_minimo, lote, imagen
) values
  (1, 'BIO108', '7501573903260', 'FC-73903260',
   'Bromhexina Adulto 160 mg/100 mL',
   'BIO108 BROMHEXINA AD 1 SUSP 160MG/100 ML',
   2, 16.98, 28, 'generico', 'Medicamentos', 'Suspension', 'Biomep',
   'Frasco 100 mL con vaso dosificador', 'Bromhexina', '160 mg/100 mL', true, 2,
   'LF2604', null),
  (2, 'GEP030', '7502227426982', 'FC-27427392',
   'ML-PRIM metocarbamol/ibuprofeno 375/200 mg',
   'GEP030 ML-PRIM 12 CAPS 375MG/200MG',
   3, 47.93, 60, 'marca', 'Medicamentos', 'Capsulas', 'ML-PRIM',
   'Caja con 12 capsulas', 'Metocarbamol / Ibuprofeno', '375 mg / 200 mg', true, 2,
   '261550', null),
  (3, 'LOE135', '7502211783954', 'EQ-LOE135',
   'Rosanil nitazoxanida 500 mg',
   'LOE135 ROSANIL 7 TAB 500 MG',
   2, 53.15, 86, 'generico', 'Medicamentos', 'Tabletas', 'Rosanil',
   'Caja con 7 tabletas', 'Nitazoxanida', '500 mg', true, 2,
   'R2604375', null),
  (4, 'MAV300', '7502009746321', 'EQ-MAV300',
   'Nisolver prednisolona 1 mg/mL',
   'MAV300 NISOLVER 1 SOL 100 ML',
   3, 73.74, 93, 'marca', 'Medicamentos', 'Solucion oral', 'Nisolver',
   'Frasco 100 mL', 'Prednisolona', '1 mg/mL', true, 2,
   '263224',
   'https://www.farmacapital.mx/catalogo-propia/nisolver-prednisolona-1mg-ml-100ml-7502009746321.jpg'),
  (5, 'MAV414', '7502009749698', 'FC-09749698',
   'Bromhexina/oxeladina',
   'MAV414 BROMHE/OXELAD 1 JBE 60/120MG/100/120 ML',
   1, 76.86, 97, 'marca', 'Medicamentos', 'Jarabe', 'Maver',
   'Frasco 225 ml', 'Bromhexina / oxeladina', '60 mg/100 ml / 120 mg/100 ml', true, 2,
   '265229',
   'https://www.farmacapital.mx/catalogo-propia/verxolin-bromhexina-oxeladina-maver-7502009749698.jpg');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, replace(t.sku, 'EQ-', '')), 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  t.tipo,
  'Factura Levic 9012699128 · clave ' || t.clave || ' · lote ' || coalesce(t.lote, 'caja'),
  t.costo,
  t.precio,
  0,
  t.stock_minimo,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.imagen,
  t.imagen
from _fc_rx_levic9012699128 t
where coalesce(
        public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
        public.fc_buscar_producto_escaneo(t.sku)
      ) is null;

update public.productos p
set
  costo = t.costo,
  stock_minimo = greatest(coalesce(p.stock_minimo, 0), t.stock_minimo),
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), nullif(t.ean, '')),
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end
from _fc_rx_levic9012699128 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
  public.fc_buscar_producto_escaneo(t.sku)
);

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_rx_levic9012699128 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Levic',
  '9012699128',
  '2026-11-16',
  582.13,
  'borrador',
  'Factura Levic A 9012699128 · CFDI 6E1D1BA1-7C86-4E90-8787-8B08E8B45856 · hoja 1 de 2 (falta hoja 2; total provisional $582.13) · PUE efectivo · cola Recibir; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '9012699128' and coalesce(proveedor, '') ilike '%levic%'
);

update public.recepciones
set
  total_ticket = 582.13,
  fecha = '2026-11-16',
  proveedor = 'Levic',
  notas = 'Factura Levic A 9012699128 · CFDI 6E1D1BA1-7C86-4E90-8787-8B08E8B45856 · hoja 1 de 2 (falta hoja 2; total provisional $582.13) · PUE efectivo · cola Recibir; MMAA de la caja',
  updated_at = now()
where folio = '9012699128'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012699128'
  and coalesce(r.proveedor, '') ilike '%levic%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  coalesce(nullif(t.ean, ''), t.sku),
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
from _fc_rx_levic9012699128 t
join public.recepciones r
  on r.folio = '9012699128'
 and coalesce(r.proveedor, '') ilike '%levic%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
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
where r.folio = '9012699128'
  and coalesce(r.proveedor, '') ilike '%levic%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 56) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '9012699128' and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;

commit;

-- ========== VERIFICACION FINAL ==========
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '9012699128'
  and coalesce(r.proveedor, '') ilike '%levic%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;
