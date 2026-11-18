-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Nadro factura 6092422484 · 17-nov-2026 · CFDI $774.92 · 7 renglones
-- UUID 6BE91D10-5527-42F2-B7EF-0AC66CA2313F · PUE efectivo · La Capu
--
-- EANs canónicos (CFDI OCR mal en 2):
--   Aliren → 7501300420541 (no …0641)
--   Bromhexina/oxeladina Maver → 7502009749698 (no …0749898 / «GUAIF»)
-- Caducidad null (MMAA de la caja). Sin dollar-quote. Sin producto_imagenes.
-- Idempotente mientras el ticket siga en borrador.
-- =============================================================================

begin;

create temp table _fc_nd6092422484 (
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
  marca text,
  presentacion text,
  forma text,
  laboratorio text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  alta_nueva boolean not null,
  imagen text
) on commit drop;

insert into _fc_nd6092422484
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion,
   receta, alta_nueva, imagen)
values
  (1, '7501300420541', 'FC-00420541',
   'Aliren 50/3/300 mg',
   'ALIKAN 500/300MG CAPS 24',
   1, 126.25, 158, 'marca', 'Medicamentos', 'Respiratorio',
   'Aliren', 'Caja con 24 capsulas', 'Capsulas', 'Siegfried Rhein',
   'Amantadina / clorfenamina / paracetamol', '50/3/300 mg',
   false, false,
   'https://www.farmacapital.mx/catalogo-propia/aliren-50-3-300-c24-7501300420541.jpg'),
  (2, '7502009749698', 'FC-09749698',
   'Bromhexina/oxeladina',
   'BROMHEXINA/GUAIF 60/120MG/100ML LGEN',
   2, 81.44, 131, 'marca', 'Medicamentos', 'Respiratorio',
   'Maver', 'Frasco 225 ml', 'Jarabe', 'Maver',
   'Bromhexina / oxeladina', '60 mg/100 ml / 120 mg/100 ml',
   false, false,
   'https://www.farmacapital.mx/catalogo-propia/verxolin-bromhexina-oxeladina-maver-7502009749698.jpg'),
  (3, '7502211783275', 'FC-11783275',
   'Erbitrax 1%',
   'ERITRAX 1/100G CRA1% TBO15G/LGEN',
   1, 25.32, 41, 'generico', 'Dermatologia', null,
   'Erbitrax', 'Tubo 15 g', 'Crema', 'Loeffler',
   'Terbinafina', '1%',
   false, true, null),
  (4, '7502231321778', 'FC-31321778',
   'Olopatadina 2 mg/ml',
   'OLOPATADINA 2.0MG/ML SOL LGEN',
   1, 132.72, 213, 'generico', 'Medicamentos', 'Oftalmico',
   'Olopatadina', 'Frasco gotero 5 ml', 'Gotas oftalmicas', 'Micromex',
   'Olopatadina', '2 mg/ml',
   true, true, null),
  (5, '7502211783282', 'FC-11783282',
   'Erbitrax 1%',
   'TERBINAFINA CRA 1% TB 30 G LGEN',
   1, 32.39, 52, 'generico', 'Dermatologia', null,
   'Erbitrax', 'Tubo 30 g', 'Crema', 'Loeffler',
   'Terbinafina', '1%',
   false, false, null),
  (6, '7590002012475', 'FC-02012475',
   'Vicks VapoRub',
   'VAPORUB REG UNG 100 G',
   1, 185.09, 232, 'marca', 'Botiquin', 'Respiratorio',
   'Vicks', 'Tarro 100 g', 'Unguento', 'Procter & Gamble',
   'Alcanfor / mentol / eucalipto', null,
   false, false, null),
  (7, '7590002012468', 'FC-02012468',
   'Vicks VapoRub 50 g',
   'VAPORUB REG UNG 50 G',
   1, 110.27, 138, 'marca', 'Botiquin', 'Respiratorio',
   'Vicks', 'Tarro 50 g', 'Unguento', 'Procter & Gamble',
   'Alcanfor / mentol / eucalipto', null,
   false, false, null);

-- Altas nuevas (solo si el EAN / SKU no existen).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, subcategoria, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (select 1 from public.productos x where x.sku = t.sku)
      then t.sku
    when not exists (
      select 1 from public.productos x
      where x.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
  end,
  t.ean,
  t.categoria,
  t.tipo,
  'Alta Nadro 6092422484 · 17-nov-2026 · listo para pistola',
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
  t.subcategoria,
  t.imagen,
  t.imagen
from _fc_nd6092422484 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  );

-- Ficha de mostrador (marca real; no LGEN).
update public.productos p set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  categoria = coalesce(nullif(trim(p.categoria), ''), t.categoria),
  tipo = coalesce(nullif(trim(p.tipo), ''), t.tipo),
  requiere_receta = t.receta,
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean),
  updated_at = now()
from _fc_nd6092422484 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end,
  updated_at = now()
from _fc_nd6092422484 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6092422484',
  '2026-11-17',
  774.92,
  'borrador',
  'Factura Nadro 6092422484 · 17-nov-2026 · CFDI $774.92 · UUID 6BE91D10… · PUE efectivo · La Capu · EAN canonicos Aliren/Bromhex · cola Recibir; stock al confirmar pistola · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '6092422484' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 774.92,
  fecha = '2026-11-17',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6092422484 · 17-nov-2026 · CFDI $774.92 · UUID 6BE91D10… · PUE efectivo · La Capu · EAN canonicos Aliren/Bromhex · cola Recibir; stock al confirmar pistola · MMAA de la caja',
  updated_at = now()
where folio = '6092422484'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6092422484'
  and coalesce(r.proveedor, '') ilike '%nadro%'
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
  t.snap,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_nd6092422484 t
join public.recepciones r
  on r.folio = '6092422484'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(p2.codigo_barras), '') = t.ean
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
  ) as pid
) v on true
order by t.linea;

-- VERIFICACION
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
where r.folio = '6092422484'
  and coalesce(r.proveedor, '') ilike '%nadro%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as snap,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 40) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6092422484'
  and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;

commit;
