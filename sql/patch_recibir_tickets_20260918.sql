-- Tres notas del 18-sep-2026. Cola Recibir, borrador. No suma stock.
-- Caducidad del papel NO se guarda: en Recibir se pone la MMAA de la caja.
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
--
-- 1) Equilibrio 444851 · Iztapalapa 2 · cliente 307513
--    ULT178 LOSARTAN 30 TAB 50 MG · Ultra · 10 × $12.45 = $124.50 · IVA 0
--    EAN 7502216803657 (iFarma / Emerita). Lote del papel 5KM255A.
--    Genérico: precio $20 = recargo +60% (12.45 × 1.60 = 19.92, hacia arriba).
--    El POS lista $792.91 y «ahorró» $7,804.60; el costo es el P.U. cobrado.
--
-- 2) El Surtidor 131164 · Bodega F48 C · SOLTRIM SOL 120ML · 3 pzas
--    Lista $96 · 70% · neto $28.80 · total $86.40 · IVA 0
--    EAN del ticket 7501537179045. Ficha Bruluart: suspensión
--    trimetoprima/sulfametoxazol 40/200 mg por 5 ml, frasco 120 ml.
--    (Sufarmed publica 7501537102067 para esa misma presentación.
--    Aquí manda el código impreso en la nota.)
--    Genérico: precio $47 = recargo +60% (28.80 × 1.60 = 46.08, hacia arriba).
--    Requiere receta.
--
-- 3) Farma Mayoreo 305016 · Central · total $129.72
--    P.U. ya trae IVA (2×30.90 + 2×33.96 = total). Impuestos $17.88 aparte.
--    7506313000513 MADRID ACEITE DE · el térmico corta el nombre.
--      No se inventa si es almendras, ricino ni los ml. Foto pendiente.
--      Marca: precio $39 = recargo +25% (30.90 × 1.25 = 38.63, hacia arriba).
--    7501082780246 Aceite para bebé Nuvel 250 ml (Klyns / Sanborns).
--      Marca: precio $43 = recargo +25% (33.96 × 1.25 = 42.45, hacia arriba).
--      Foto pendiente.
--    Lote del papel en los dos: 2712-017. El papel dice cad 31/12/2029.

begin;

-- ── Equilibrio · Losartán Ultra ──────────────────────────────────────

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Losartán potásico 50 mg C/30 Ultra',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-16803657'
        and coalesce(p.codigo_barras, '') <> '7502216803657'
    ) then 'FC-ND-16803657'
    else 'FC-16803657'
  end,
  '7502216803657',
  'Medicamentos',
  'Cardiovascular',
  'generico',
  'Equilibrio 444851 · clave ULT178 · Ultra Losartán 50 mg C/30 EAN 7502216803657 · recargo genérico +60%',
  'Ultra',
  'Caja con 30 tabletas',
  'Losartán potásico',
  '50 mg',
  'Tableta',
  12.45,
  20,
  'https://www.farmacapital.mx/catalogo-propia/losartan-ultra-50mg-c30.jpg',
  'https://www.farmacapital.mx/catalogo-propia/losartan-ultra-50mg-c30.jpg',
  0, 1, true, true
where public.fc_buscar_producto_escaneo('7502216803657') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7502216803657'
       or p.sku in ('FC-16803657', 'FC-ND-16803657', 'EQ-ULT178')
  );

update public.productos p
set
  codigo_barras = '7502216803657',
  nombre = 'Losartán potásico 50 mg C/30 Ultra',
  marca = coalesce(nullif(btrim(p.marca), ''), 'Ultra'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Caja con 30 tabletas'),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), 'Losartán potásico'),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '50 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Tableta'),
  costo = case when coalesce(p.costo, 0) <= 0 then 12.45 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 0 then 20 else p.precio end,
  requiere_receta = true,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/losartan-ultra-50mg-c30.jpg'),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/losartan-ultra-50mg-c30.jpg')
where p.sku = 'EQ-ULT178'
  and coalesce(p.codigo_barras, '') in ('', '7502216803657')
  and public.fc_buscar_producto_escaneo('7502216803657') is null;

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/losartan-ultra-50mg-c30.jpg',
  'catalogo-propia/losartan-ultra-50mg-c30.jpg',
  0, true, 'propia'
from public.productos p
where p.codigo_barras = '7502216803657'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%losartan-ultra-50mg-c30%'
  );

-- ── El Surtidor · Soltrim ────────────────────────────────────────────

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Soltrim trimetoprima/sulfametoxazol 40/200 mg/5 ml suspensión 120 ml',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-537179045'
        and coalesce(p.codigo_barras, '') <> '7501537179045'
    ) then 'FC-ND-537179045'
    else 'FC-537179045'
  end,
  '7501537179045',
  'Medicamentos',
  'Antibiótico',
  'generico',
  'El Surtidor 131164 · Bruluart Soltrim susp 120 ml EAN 7501537179045 · 3 × $28.80 (lista $96 − 70%) · recargo genérico +60%',
  'Soltrim',
  'Caja con frasco 120 ml',
  'Trimetoprima / sulfametoxazol',
  '40 mg / 200 mg por 5 ml',
  'Suspensión',
  28.80,
  47,
  'https://www.farmacapital.mx/catalogo-propia/soltrim-susp-40-200-120ml.jpg',
  'https://www.farmacapital.mx/catalogo-propia/soltrim-susp-40-200-120ml.jpg',
  0, 1, true, true
where public.fc_buscar_producto_escaneo('7501537179045') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501537179045'
       or p.sku in ('FC-537179045', 'FC-ND-537179045')
  );

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/soltrim-susp-40-200-120ml.jpg',
  'catalogo-propia/soltrim-susp-40-200-120ml.jpg',
  0, true, 'propia'
from public.productos p
where p.codigo_barras = '7501537179045'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%soltrim-susp-40-200-120ml%'
  );

-- ── Farma Mayoreo · aceites ──────────────────────────────────────────

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, forma_farmaceutica,
  costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  'Aceite Madrid',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-313000513'
        and coalesce(p.codigo_barras, '') <> '7506313000513'
    ) then 'FC-ND-313000513'
    else 'FC-313000513'
  end,
  '7506313000513',
  'Cuidado personal',
  'Piel',
  'marca',
  'Farma Mayoreo 305016 · térmico «MADRID ACEITE DE» EAN 7506313000513 · el nombre viene cortado: no se inventa tipo ni ml · foto pendiente · P.U. $30.90 ya con IVA · recargo marca +25%',
  'Madrid',
  'Aceite',
  30.90,
  39,
  0, 1, true, false
where public.fc_buscar_producto_escaneo('7506313000513') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7506313000513'
       or p.sku in ('FC-313000513', 'FC-ND-313000513')
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica,
  costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  'Aceite para bebé Nuvel 250 ml',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-082780246'
        and coalesce(p.codigo_barras, '') <> '7501082780246'
    ) then 'FC-ND-082780246'
    else 'FC-082780246'
  end,
  '7501082780246',
  'Cuidado personal',
  'Bebé',
  'marca',
  'Farma Mayoreo 305016 · Nuvel aceite para bebé 250 ml EAN 7501082780246 · Klyns/Sanborns · foto pendiente · P.U. $33.96 ya con IVA · recargo marca +25%',
  'Nuvel',
  'Frasco 250 ml',
  'Aceite',
  33.96,
  43,
  0, 1, true, false
where public.fc_buscar_producto_escaneo('7501082780246') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501082780246'
       or p.sku in ('FC-082780246', 'FC-ND-082780246')
  );

insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
select p.id, v.fuente, 'compra', v.costo, v.fecha, v.nombre_fuente, 100, 'manual', v.notas
from (
  values
    ('7502216803657'::text, 'equilibrio'::text, 12.45::numeric, date '2026-09-18', 'Equilibrio'::text,
     'Equilibrio 444851 · ULT178 · 10 × $12.45'),
    ('7501537179045', 'surtidor', 28.80, date '2026-09-18', 'El Surtidor',
     'El Surtidor 131164 · 3 × $28.80 (lista $96 − 70%)'),
    ('7506313000513', 'farmamayoreo', 30.90, date '2026-09-18', 'Farma Mayoreo',
     'Farma Mayoreo 305016 · P.U. $30.90 con IVA · lote 2712-017'),
    ('7501082780246', 'farmamayoreo', 33.96, date '2026-09-18', 'Farma Mayoreo',
     'Farma Mayoreo 305016 · P.U. $33.96 con IVA · lote 2712-017')
) as v(ean, fuente, costo, fecha, nombre_fuente, notas)
join public.productos p on p.codigo_barras = v.ean
where not exists (
  select 1 from public.producto_precios_referencia r
  where r.producto_id = p.id
    and r.fuente = v.fuente
    and r.precio = v.costo
    and r.fecha = v.fecha
);

-- ── Recepciones ──────────────────────────────────────────────────────

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select v.proveedor, v.folio, v.fecha, v.total, 'borrador', v.notas
from (
  values
    ('Equilibrio'::text, '444851'::text, '2026-09-18'::date, 124.50::numeric,
     'Equilibrio 444851 · Iztapalapa 2 · 18-sep-2026 · Losartán Ultra 50 mg C/30 × 10 · $12.45 · lote 5KM255A · papel cad 01/10/2027 · cola Recibir; MMAA de la caja',
     '%equilibrio%'::text),
    ('El Surtidor', '131164', '2026-09-18'::date, 86.40,
     'El Surtidor 131164 · F48 C · 18-sep-2026 · Soltrim susp 120 ml × 3 · neto $28.80 · cola Recibir; MMAA de la caja',
     '%surtidor%'),
    ('Farma Mayoreo', '305016', '2026-09-18'::date, 129.72,
     'Farma Mayoreo 305016 · 18-sep-2026 · aceite Madrid × 2 · Nuvel bebé 250 ml × 2 · P.U. con IVA · lote 2712-017 · papel cad 31/12/2029 · cola Recibir; MMAA de la caja',
     '%farma mayoreo%')
) as v(proveedor, folio, fecha, total, notas, prov)
where not exists (
  select 1 from public.recepciones r
  where r.folio = v.folio
    and coalesce(r.proveedor, '') ilike v.prov
);

update public.recepciones r
set total_ticket = v.total, fecha = v.fecha, proveedor = v.proveedor, notas = v.notas, updated_at = now()
from (
  values
    ('Equilibrio'::text, '444851'::text, '2026-09-18'::date, 124.50::numeric,
     'Equilibrio 444851 · Iztapalapa 2 · 18-sep-2026 · Losartán Ultra 50 mg C/30 × 10 · $12.45 · lote 5KM255A · papel cad 01/10/2027 · cola Recibir; MMAA de la caja',
     '%equilibrio%'::text),
    ('El Surtidor', '131164', '2026-09-18'::date, 86.40,
     'El Surtidor 131164 · F48 C · 18-sep-2026 · Soltrim susp 120 ml × 3 · neto $28.80 · cola Recibir; MMAA de la caja',
     '%surtidor%'),
    ('Farma Mayoreo', '305016', '2026-09-18'::date, 129.72,
     'Farma Mayoreo 305016 · 18-sep-2026 · aceite Madrid × 2 · Nuvel bebé 250 ml × 2 · P.U. con IVA · lote 2712-017 · papel cad 31/12/2029 · cola Recibir; MMAA de la caja',
     '%farma mayoreo%')
) as v(proveedor, folio, fecha, total, notas, prov)
where r.folio = v.folio
  and coalesce(r.proveedor, '') ilike v.prov
  and r.estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.estado = 'borrador'
  and (
    (r.folio = '444851' and coalesce(r.proveedor, '') ilike '%equilibrio%')
    or (r.folio = '131164' and coalesce(r.proveedor, '') ilike '%surtidor%')
    or (r.folio = '305016' and coalesce(r.proveedor, '') ilike '%farma mayoreo%')
  );

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  public.fc_buscar_producto_escaneo(t.ean),
  t.ean,
  t.nombre,
  t.qty,
  null,
  t.lote,
  t.costo,
  (public.fc_buscar_producto_escaneo(t.ean) is null),
  'pdf',
  false,
  (
    public.fc_buscar_producto_escaneo(t.ean) is not null
    and t.lote is not null
    and exists (
      select 1 from public.lotes l
      where l.producto_id = public.fc_buscar_producto_escaneo(t.ean)
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from (
  values
    ('444851'::text, '%equilibrio%'::text, '7502216803657'::text,
     'Losartán potásico 50 mg C/30 Ultra'::text, 10, '5KM255A'::text, 12.45::numeric),
    ('131164', '%surtidor%', '7501537179045',
     'Soltrim trimetoprima/sulfametoxazol 40/200 mg/5 ml suspensión 120 ml', 3, null, 28.80),
    ('305016', '%farma mayoreo%', '7506313000513',
     'Aceite Madrid', 2, '2712-017', 30.90),
    ('305016', '%farma mayoreo%', '7501082780246',
     'Aceite para bebé Nuvel 250 ml', 2, '2712-017', 33.96)
) as t(folio, prov, ean, nombre, qty, lote, costo)
join public.recepciones r
  on r.folio = t.folio
 and coalesce(r.proveedor, '') ilike t.prov
 and r.estado = 'borrador';

commit;

select r.proveedor, r.folio, r.estado, r.total_ticket,
       count(i.*) as renglones,
       sum(i.cantidad) as piezas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where (r.folio = '444851' and coalesce(r.proveedor, '') ilike '%equilibrio%')
   or (r.folio = '131164' and coalesce(r.proveedor, '') ilike '%surtidor%')
   or (r.folio = '305016' and coalesce(r.proveedor, '') ilike '%farma mayoreo%')
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.folio;

select r.folio, i.codigo_escaneado as ean, i.nombre_snapshot, i.cantidad,
       i.costo_estimado, i.numero_lote,
       case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio in ('444851', '131164', '305016')
order by r.folio, i.id;
