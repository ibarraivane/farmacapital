-- Equilibrio térmico · foto 05-sep-2026 · cliente 307513 Palillero.
-- Folio no venía en el recorte: usamos 20260905.
-- Subtotal $2,598.57 + IVA $10.31 (solo jabón Grisi) = $2,608.88.
-- 14 renglones / 45 pzas. 5 altas (stock 0). El resto ya estaba: solo costo, no PVP.
-- Costo = P.U. del ticket (antes de IVA). Lote de fábrica sí. Caducidad NO:
-- Recibir pide MMAA de la caja. 0000 es inválido.
-- Fichas desde Visoti/Levic + FarmaSmart/DISA, no el código del ticket.
-- SIN bloques dollar-quote. Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq20260905 (
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

insert into _fc_eq20260905 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, receta,
  marca, presentacion, principio, concentracion, forma, subcat, imagen, lote
) values
  (1, '7502274791064', 'EQ-SOF040',
   'Vixgoplisol Levetiracetam 1000 mg C/30 Solfrán',
   'SOF040 VIXGOPLISOL 30 TAB 1000 MG',
   3, 112.05, 180, 'generico', 'Medicamentos', true,
   'Solfrán', 'Caja con 30 tabletas', 'Levetiracetam', '1000 mg', 'Tableta',
   'Neurología',
   'https://www.farmacapital.mx/catalogo-propia/vixgoplisol-1000-30-solfran.jpg',
   '60550'),
  (2, '7501022105191', 'FC-22105191',
   'Jabón Grisi Neutro 100 g',
   'GSI003 JABON NEUTRO 1 PZAS 100 G',
   5, 12.89, 22, 'marca', 'Cuidado personal', false,
   'Grisi', 'Barra 100 g', null, null, 'Jabón',
   'Higiene',
   'https://www.farmacapital.mx/catalogo-propia/grisi-neutro-jabon-100g.jpg',
   'L26D0389'),
  (3, '7501349020542', 'EQ-AMS425',
   'Irbesartán 300 mg C/28 AMSA',
   'AMS425 IRBESARTAN 28 TAB 300 MG',
   5, 151.28, 243, 'generico', 'Hipertensión', true,
   'AMSA', 'Caja con 28 tabletas', 'Irbesartán', '300 mg', 'Tableta',
   'Cardiovascular',
   'https://www.farmacapital.mx/catalogo-propia/irbesartan-300-28-amsa.jpg',
   'U26E330'),
  (4, '7501075720365', 'EQ-NOV132',
   'Danovag Omeprazol 20 mg C/14 Novag',
   'NOV132 DANOVAG 14 CAPS 20 MG',
   5, 13.99, 23, 'generico', 'Medicamentos', false,
   'Novag', 'Caja con 14 cápsulas', 'Omeprazol', '20 mg', 'Cápsula',
   'Gastro',
   'https://www.farmacapital.mx/catalogo-propia/danovag-omeprazol-20-14-novag.jpg',
   '130076'),
  (5, '7501349020535', 'EQ-AMS424',
   'Irbesartán 300 mg C/14 AMSA',
   'AMS424 IRBESARTAN 14 TAB 300 MG',
   3, 77.69, 125, 'generico', 'Hipertensión', true,
   'AMSA', 'Caja con 14 tabletas', 'Irbesartán', '300 mg', 'Tableta',
   'Cardiovascular', null, 'U26E329'),
  (6, '7502009748868', 'EQ-MAV373',
   'Budimin 20 tabletas 1 mg',
   'MAV373 BUDIMIN 20 TAB 1 MG',
   4, 31.29, 51, 'marca', 'Medicamentos', true,
   'Maver', 'Caja con 20 tabletas', 'Bumetanida', '1 mg', 'Tableta',
   'Cardiovascular', null, '257237'),
  (7, '7502227872697', 'EQ-RAM147',
   'Preslopin Amlodipino 5 mg C/30 RAAM',
   'RAM147 PRESLOPIN 30 TAB 5 MG',
   3, 10.61, 17, 'generico', 'Hipertensión', true,
   'RAAM', 'Caja con 30 tabletas', 'Amlodipino', '5 mg', 'Tableta',
   'Cardiovascular',
   'https://www.farmacapital.mx/catalogo-propia/preslopin-amlodipino-5-30-raam.jpg',
   'RPR527'),
  (8, '7502001162426', 'EQ-SON175',
   'Ardosons 20 cápsulas 215/25/0.75 mg',
   'SON175 ARDOSONS 20 CAPS 215/25/0.75 MG',
   2, 60.34, 97, 'marca', 'Medicamentos', true,
   'Son''s', 'Caja con 20 cápsulas', 'Indometacina / Betametasona / Metocarbamol',
   '215/25/0.75 mg', 'Cápsula', 'Dolor', null, '26051258'),
  (9, '7502009741425', 'EQ-MAV137',
   'Fasiclor 500 mg C/15 cápsulas Maver',
   'MAV137 FASICLOR 15 CAPS 500 MG',
   3, 137.93, 221, 'marca', 'Medicamentos', true,
   'Maver', 'Caja con 15 cápsulas', 'Cefaclor', '500 mg', 'Cápsula',
   'Antibiótico', null, '255648'),
  (10, '7502009748868', 'EQ-MAV373',
   'Budimin 20 tabletas 1 mg',
   'MAV373 BUDIMIN 20 TAB 1 MG',
   1, 31.29, 51, 'marca', 'Medicamentos', true,
   'Maver', 'Caja con 20 tabletas', 'Bumetanida', '1 mg', 'Tableta',
   'Cardiovascular', null, '264273'),
  (11, '7501075722543', 'EQ-NOV163',
   'Pabesorag 28 tabletas 150/12.5 mg',
   'NOV163 PABESORAG 28 TAB 150/12.5 MG',
   2, 60.48, 97, 'marca', 'Hipertensión', true,
   'Novag', 'Caja con 28 tabletas', 'Irbesartán / Hidroclorotiazida',
   '150/12.5 mg', 'Tableta', 'Cardiovascular', null, 'B10436'),
  (12, '780083144296', 'EQ-COL146',
   'Collifrin Infantil oximetazolina 0.025% 20 mL',
   'COL146 COLLIFRIN INFANTIL 1 SOL 25MG/20 ML',
   2, 31.28, 40, 'marca', 'Medicamentos', false,
   'Collins', 'Frasco 20 mL', 'Oximetazolina', '0.025%', 'Solución nasal',
   'Respiratorio',
   'https://www.farmacapital.mx/catalogo-propia/collifrin-infantil-oximetazolina-20ml.jpg',
   '26140942'),
  (13, '7502216804814', 'EQ-AVI027',
   'Amlodipino 5 mg C/100 Avivia',
   'AVI027 AMLODIPINO 100 TAB 5 MG',
   3, 32.52, 53, 'generico', 'Hipertensión', true,
   'Avivia', 'Caja con 100 tabletas', 'Amlodipino', '5 mg', 'Tableta',
   'Cardiovascular', null, '5MM301A'),
  (14, '0780083144302', 'EQ-COL145',
   'Collifrin Adulto oximetazolina 0.05% 20 mL',
   'COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML',
   4, 33.68, 54, 'marca', 'Medicamentos', false,
   'Collins', 'Frasco 20 mL', 'Oximetazolina', '0.05%', 'Solución nasal',
   'Respiratorio', null, '26140881');

-- Una fila por EAN para el catálogo (Budimin va dos veces en el ticket).
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
  'Alta Equilibrio 20260905 · foto ticket · listo para pistola',
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
  from _fc_eq20260905
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existía: costo de este ticket. PVP solo si está en 0. No pisa foto buena.
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
  from _fc_eq20260905
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select
  v.pid,
  t.imagen,
  0,
  true,
  'distribuidor'
from (
  select distinct on (ean) *
  from _fc_eq20260905
  order by ean, linea
) t
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
where t.imagen is not null
  and v.pid is not null
  and not exists (
    select 1 from public.producto_imagenes x
    where x.producto_id = v.pid and x.url = t.imagen
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '20260905',
  '2026-09-05',
  2608.88,
  'borrador',
  'Ticket Equilibrio térmico · cliente 307513 · foto 05-sep-2026 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '20260905' and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 2608.88,
  fecha = '2026-09-05',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio térmico · cliente 307513 · foto 05-sep-2026 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja'
where folio = '20260905'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20260905'
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
from _fc_eq20260905 t
join public.recepciones r
  on r.folio = '20260905'
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
where r.folio = '20260905' and coalesce(r.proveedor, '') ilike '%equilibrio%'
order by i.id;
