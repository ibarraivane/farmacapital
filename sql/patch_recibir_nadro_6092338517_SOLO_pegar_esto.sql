-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Nadro · factura 6092338517 · 15-nov-2026 → cola Recibir.
-- Merge a GitHub NO lo crea. Sin bloques dollar-quote. Sin producto_imagenes.
-- Caducidad null: MMAA de la caja. No inventar 0000.
-- Al final: VERIFICACION con folio 6092338517 en borrador.
-- Luego: tablet Recibir → recargar → aparece la tarjeta Nadro.
-- =============================================================================


-- ========== Nadro 6092338517 ==========
-- Nadro · folio 6092338517 · 2026-11-15 · total $1,350.91 · 11 renglones
-- Factura impresa FARMACAPITAL (LA CAPS). Valor unitario = costo (sin IVA en renglón).
-- EANs y ficha desde iNadro (no del OCR borroso). Fotos en catalogo-propia/.
-- Altas stock 0. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_nd6092338517 (
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
  imagen text
) on commit drop;

insert into _fc_nd6092338517 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
) values
  (1, '7506306246874', 'FC-06246874',
   'Sedal Hidratación Anti-nudos',
   'ACOND SEDAL HIDRATACION 620 ML',
   1, 40.13, 51, 'marca', 'Cuidado personal',
   'Cabello', 'Acondicionador', 'Sedal', 'Unilever',
   '620 ml', null, null, false, false,
   'https://www.farmacapital.mx/catalogo-propia/sedal-hidratacion-acondicionador-620-7506306246874.jpg'),
  (2, '7501318612655', 'FC-18612655',
   'Aspirina Protect 100 mg',
   'ASPIRINA PROTECT 100MG 28 TAB',
   2, 150.23, 188, 'marca', 'Medicamentos',
   'Cardiovascular', 'Tabletas', 'Aspirina', 'Bayer',
   'Caja con 28 tabletas', 'Ácido acetilsalicílico', '100 mg', false, false,
   'https://www.farmacapital.mx/catalogo-propia/aspirina-protect-100mg-28-7501318612655.jpg'),
  (3, '7501417010253', 'FC-17010253',
   'Carbonato de magnesio',
   'CARBONATO-MAG PANES 7 G',
   3, 25.06, 32, 'marca', 'Suplementos',
   null, 'Pan', 'Coyoacán Química', 'Coyoquimex',
   'Pan 7 g', 'Carbonato de magnesio', null, false, false,
   'https://www.farmacapital.mx/catalogo-propia/carbonato-magnesio-pan-7g-7501417010253.jpg'),
  (4, '7501349028586', 'FC-49028586',
   'Combedi DL',
   'DICLOF/LIDOC/COMPB S.I. 5MG LGEN',
   1, 38.91, 63, 'generico', 'Medicamentos',
   'Analgésico', 'Solución inyectable', 'Combedi', 'AMSA',
   '3 dosis (6 ampolletas + 3 jeringas)', 'Diclofenaco / lidocaína / complejo B', null, true, false,
   'https://www.farmacapital.mx/catalogo-propia/diclofenaco-lidocaina-complejo-b-amsa-7501349028586.jpg'),
  (5, '7506306245990', 'FC-06245990',
   'Zest Aqua',
   'JBN ZEST AQUA FRESCO 135 G',
   1, 12.67, 16, 'marca', 'Cuidado personal',
   'Higiene', 'Jabón en barra', 'Zest', 'Unilever',
   '135 g', null, null, false, false,
   'https://www.farmacapital.mx/catalogo-propia/zest-aqua-fresco-135-7506306245990.jpg'),
  (6, '7506306246096', 'FC-06246096',
   'Zest Men Hinojo y sales marinas',
   'JBN ZEST MEN HINOJO SAL MAR 135G',
   1, 12.67, 16, 'marca', 'Cuidado personal',
   'Higiene', 'Jabón en barra', 'Zest', 'Unilever',
   '135 g', null, null, false, false,
   'https://www.farmacapital.mx/catalogo-propia/zest-men-hinojo-sal-mar-135-7506306246096.jpg'),
  (7, '7506306246058', 'FC-06246058',
   'Zest Neutro Suave Balance',
   'JBN ZEST NEUTRO SVE BALANC 135 G',
   1, 12.67, 16, 'marca', 'Cuidado personal',
   'Higiene', 'Jabón en barra', 'Zest', 'Unilever',
   '135 g', null, null, false, false,
   'https://www.farmacapital.mx/catalogo-propia/zest-neutro-suave-balance-135-7506306246058.jpg'),
  (8, '7506306246010', 'FC-06246010',
   'Zest Pepino y sábila',
   'JBN ZEST PEPINO SABILA RENO 135G',
   1, 12.67, 16, 'marca', 'Cuidado personal',
   'Higiene', 'Jabón en barra', 'Zest', 'Unilever',
   '135 g', null, null, false, false,
   'https://www.farmacapital.mx/catalogo-propia/zest-pepino-sabila-135-7506306246010.jpg'),
  (9, '7501361606205', 'FC-61606205',
   'Sinuberase',
   'SINUBERASE 12 CAPS',
   2, 193.72, 243, 'marca', 'Medicamentos',
   'Gastro', 'Cápsulas', 'Sinuberase', 'Sanofi',
   'Caja con 12 cápsulas', 'Esporas de Bacillus clausii', '2 billones UFC', false, false,
   'https://www.farmacapital.mx/catalogo-propia/sinuberase-12-caps-7501361606205.jpg'),
  (10, '7501159580014', 'FC-59580014',
   'Sinuberase',
   'SINUBERASE CPR 48',
   2, 169.09, 212, 'marca', 'Medicamentos',
   'Gastro', 'Comprimidos', 'Sinuberase', 'Sanofi',
   'Caja con 48 comprimidos', 'Bacillus coagulans', null, false, false,
   'https://www.farmacapital.mx/catalogo-propia/sinuberase-48-comp-7501159580014.jpg'),
  (11, '7501349029019', 'FC-49029019',
   'Tiamina / piridoxina / cianocobalamina 100/50/10 mg',
   'TIA/PIRI/CI 100MG S.I. 5AMP LGEN',
   2, 46.68, 75, 'generico', 'Medicamentos',
   'Vitaminas', 'Solución inyectable', 'Combedi', 'AMSA',
   '5 ampolletas + 5 jeringas', 'Tiamina / piridoxina / cianocobalamina', '100/50/10 mg', true, false,
   'https://www.farmacapital.mx/catalogo-propia/combedi-tiamina-piridoxina-cianocobalamina-5amp-7501349029019.jpg');

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
  'Alta Nadro 6092338517 · 2026-11-15 · listo para pistola',
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
  from _fc_nd6092338517
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
  end
from (
  select distinct on (ean) *
  from _fc_nd6092338517
  order by ean, linea
) t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
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
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_nd6092338517
  order by ean, linea
) t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6092338517',
  '2026-11-15',
  1350.91,
  'borrador',
  'Factura Nadro 6092338517 · 15-nov-2026 · FARMACAPITAL (LA CAPS) · 11 renglones · Sedal · Aspirina Protect · Carbonato Mag · Combedi DL · Zest x4 · Sinuberase 12/48 · Combedi B iny · total $1,350.91 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '6092338517'
    and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 1350.91,
  fecha = '2026-11-15',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6092338517 · 15-nov-2026 · FARMACAPITAL (LA CAPS) · 11 renglones · Sedal · Aspirina Protect · Carbonato Mag · Combedi DL · Zest x4 · Sinuberase 12/48 · Combedi B iny · total $1,350.91 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '6092338517'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6092338517'
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
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_nd6092338517 t
join public.recepciones r
  on r.folio = '6092338517'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select public.fc_buscar_producto_escaneo(t.ean) as pid
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
where r.folio = '6092338517'
  and coalesce(r.proveedor, '') ilike '%nadro%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  case
    when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA'
    else 'OK'
  end as match
from _fc_nd6092338517 t
order by t.linea;

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
where r.folio = '6092338517'
  and coalesce(r.proveedor, '') ilike '%nadro%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;
