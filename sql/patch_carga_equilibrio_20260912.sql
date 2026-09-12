-- Equilibrio · foto 12-sep-2026 · caja Iztapalapa 2.
-- Folio no venía en el recorte: usamos 20260912.
-- Total $950.72 · 7 renglones / 21 pzas.
-- Costo = P.U. del ticket. Lote de fábrica sí. Caducidad NO:
-- Recibir pide MMAA de la caja. 0000 es inválido.
-- Fichas: Sufarmed / DISA / FarmaSmart / Sanorim (EAN verificados).
-- Fotos en public/catalogo-propia/ (URLs tras deploy Vercel).
-- SIN bloques dollar-quote. Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq20260912 (
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
  receta boolean not null,
  marca text,
  presentacion text,
  principio text,
  concentracion text,
  forma text,
  subcat text,
  imagen text,
  lote text
) on commit drop;

insert into _fc_eq20260912 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, receta,
  marca, presentacion, principio, concentracion, forma, subcat, imagen, lote
) values
  (1, '7502227871058', 'EQ-RAM014',
   'Fermig Sumatriptán 100 mg C/2 RAAM',
   'RAM014 FERMIG 2 TAB 100 MG',
   2, 62.07, 100, 'generico', 'Medicamentos', true,
   'RAAM', 'Caja con 2 tabletas', 'Sumatriptán', '100 mg', 'Tableta',
   'Neurología', null, 'RFR356'),
  (2, '7502227871065', 'EQ-RAM015',
   'Fermig Sumatriptán 50 mg C/2 RAAM',
   'RAM015 FERMIG 2 TAB 50 MG',
   2, 49.30, 79, 'generico', 'Medicamentos', true,
   'RAAM', 'Caja con 2 tabletas', 'Sumatriptán', '50 mg', 'Tableta',
   'Neurología', 'https://www.farmacapital.mx/catalogo-propia/fermig-sumatriptan-50-2-raam.png', 'RFR354'),
  (3, '7501075714173', 'EQ-NOV038',
   'Prontol Metoprolol 100 mg C/20 Novag',
   'NOV038 PRONTOL 20 TAB 100 MG',
   4, 9.98, 16, 'generico', 'Hipertensión', true,
   'Novag', 'Caja con 20 tabletas', 'Metoprolol', '100 mg', 'Tableta',
   'Cardiovascular', 'https://www.farmacapital.mx/catalogo-propia/prontol-metoprolol-100-20-novag.webp', '670106'),
  (4, '7502009749322', 'EQ-MAV394',
   'Coniax Citicolina 500 mg C/10 Maver',
   'MAV394 CONIAX 10 COMP 500 MG',
   3, 121.98, 196, 'marca', 'Medicamentos', true,
   'Maver', 'Caja con 10 comprimidos', 'Citicolina', '500 mg', 'Comprimido',
   'Neurología', 'https://www.farmacapital.mx/catalogo-propia/coniax-citicolina-500-10-maver.jpg', '263274'),
  (5, '7501349014190', 'EQ-AMS147',
   'Ácido alendrónico 10 mg C/30 AMSA',
   'AMS147 ACIDO ALENDRONICO 30 TAB 10 MG',
   4, 25.93, 42, 'generico', 'Medicamentos', true,
   'AMSA', 'Caja con 30 tabletas', 'Ácido alendrónico', '10 mg', 'Tableta',
   'Osteoporosis', 'https://www.farmacapital.mx/catalogo-propia/acido-alendronico-10-30-amsa.jpg', 'U25T260'),
  (6, '7502247373495', 'EQ-LAN057',
   'Bacat Atorvastatina 20 mg C/30 Landsteiner',
   'LAN057 BACAT 30 TAB 20 MG',
   5, 39.54, 64, 'generico', 'Medicamentos', true,
   'Landsteiner', 'Caja con 30 tabletas', 'Atorvastatina', '20 mg', 'Tableta',
   'Cardiovascular', 'https://www.farmacapital.mx/catalogo-propia/bacat-atorvastatina-20-30-landsteiner.webp', 'L26G0409'),
  (7, '7501836006028', 'FC-36006028',
   'Virindrez Infantil oximetazolina 0.025% 20 mL',
   'LIF161 VIRINDREZ INFANTIL 1 ATOM 25 MG/20 ML',
   1, 20.70, 34, 'marca', 'Medicamentos', false,
   'Liferpal MD', 'Frasco atomizador 20 mL', 'Oximetazolina', '0.025%', 'Solución nasal',
   'Respiratorio', null, '26C079');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'EQ-' || t.ean
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcat,
  t.tipo,
  'Alta Equilibrio 20260912 · foto ticket · listo para pistola',
  t.marca,
  t.presentacion,
  t.principio,
  t.concentracion,
  t.forma,
  t.costo,
  t.precio,
  t.imagen,
  t.imagen,
  0,
  1,
  true,
  t.receta
from (
  select distinct on (ean) *
  from _fc_eq20260912
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
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcat),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_eq20260912
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '20260912',
  '2026-09-12',
  950.72,
  'borrador',
  'Ticket Equilibrio térmico · caja Iztapalapa 2 · foto 12-sep-2026 · folio no en recorte · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '20260912' and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 950.72,
  fecha = '2026-09-12',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio térmico · caja Iztapalapa 2 · foto 12-sep-2026 · folio no en recorte · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja',
  updated_at = now()
where folio = '20260912'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20260912'
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
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_eq20260912 t
join public.recepciones r
  on r.folio = '20260912'
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

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '20260912' and coalesce(r.proveedor, '') ilike '%equilibrio%'
order by i.id;
