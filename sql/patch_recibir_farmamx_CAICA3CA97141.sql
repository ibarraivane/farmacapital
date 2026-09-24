-- Farma MX (farmalmx / REINVEX INTEGRA) · Nota de caja CAICA3CA97141
-- Central de Abastos Iztapalapa · 18-sep-2026 · Yolanda Ventura Medina
-- 5 × Tromdex tabletas 10 mg C/30 · $91.80 · total $459.00 · IVA 0% (IVATRA00)
--
-- El renglón del ticket dice «10010-TI IVATRA00 TROMDEX…». IVATRA00 es la
-- clave de IVA, no el nombre. Ficha: RAAM Tromdex ezetimiba 10 mg,
-- caja con 30 tabletas. EAN 7502227875377 (Sanorim / Distrimedic).
-- Clave Farma MX 302490. Lote del papel: RTR098. El ticket imprime
-- caducidad 01/01/2028; no se guarda aquí. En Recibir se pone la MMAA
-- de la caja. Si la caja no trae fecha, el renglón se queda gris.
--
-- Costo $91.80. Precio $115 = recargo de marca +25% (91.80 × 1.25 = 114.75,
-- hacia arriba). Margen real 20.2%. No es «margen 25%».
-- Stock 0 hasta confirmar con pistola.
-- Foto: public/catalogo-propia/tromdex-ezetimiba-10mg-c30.jpg (tras deploy).
-- Fracción IV: requiere receta.
--
-- Idempotente. SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Tromdex ezetimiba 10 mg C/30 tabletas',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-27875377'
        and coalesce(p.codigo_barras, '') <> '7502227875377'
    ) then 'FC-ND-27875377'
    else 'FC-27875377'
  end,
  '7502227875377',
  'Medicamentos',
  'Colesterol',
  'marca',
  'Farma MX CAICA3CA97141 · clave 302490 · RAAM Tromdex ezetimiba 10 mg C/30 EAN 7502227875377 · registro 014M2016 SSA · no usar IVATRA00',
  'Tromdex',
  'Caja con 30 tabletas',
  'Ezetimiba',
  '10 mg',
  'Tableta',
  91.80,
  115,
  'https://www.farmacapital.mx/catalogo-propia/tromdex-ezetimiba-10mg-c30.jpg',
  'https://www.farmacapital.mx/catalogo-propia/tromdex-ezetimiba-10mg-c30.jpg',
  0,
  1,
  true,
  true
where public.fc_buscar_producto_escaneo('7502227875377') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7502227875377'
       or p.sku in ('FC-27875377', 'FC-ND-27875377', 'FMX-302490')
       or (
         p.nombre ilike '%tromdex%'
         and (
           coalesce(p.presentacion, '') ilike '%30%'
           or p.nombre ilike '%c/30%'
           or p.nombre ilike '%30 tab%'
         )
       )
  );

-- Si una carga vieja dejó FMX-302490 sin código, se le pega el EAN.
-- No pisa un código distinto ni un precio que ya tenga.
update public.productos p
set
  codigo_barras = '7502227875377',
  nombre = 'Tromdex ezetimiba 10 mg C/30 tabletas',
  marca = coalesce(nullif(btrim(p.marca), ''), 'Tromdex'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Caja con 30 tabletas'),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), 'Ezetimiba'),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '10 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Tableta'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Medicamentos'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Colesterol'),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'marca'),
  costo = case when coalesce(p.costo, 0) <= 0 then 91.80 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 0 then 115 else p.precio end,
  requiere_receta = true,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/tromdex-ezetimiba-10mg-c30.jpg'),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/tromdex-ezetimiba-10mg-c30.jpg'),
  activo = true
where (
    p.sku = 'FMX-302490'
    or (
      p.nombre ilike '%tromdex%'
      and (
        coalesce(p.presentacion, '') ilike '%30%'
        or p.nombre ilike '%c/30%'
        or p.nombre ilike '%30 tab%'
      )
    )
  )
  and coalesce(p.codigo_barras, '') in ('', '7502227875377')
  and public.fc_buscar_producto_escaneo('7502227875377') is null;

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/tromdex-ezetimiba-10mg-c30.jpg',
  'catalogo-propia/tromdex-ezetimiba-10mg-c30.jpg',
  0,
  true,
  'propia'
from public.productos p
where (
    p.codigo_barras = '7502227875377'
    or p.sku in ('FC-27875377', 'FC-ND-27875377', 'FMX-302490')
  )
  and (
    p.codigo_barras = '7502227875377'
    or p.nombre ilike '%tromdex%'
  )
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%tromdex-ezetimiba-10mg-c30%'
  );

insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
select
  p.id,
  'ultima_compra',
  'compra',
  91.80,
  date '2026-09-18',
  'Farma MX',
  100,
  'manual',
  'Farma MX CAICA3CA97141 · clave 302490 · 5 × $91.80 · lote RTR098 · ticket imprime cad 01/01/2028'
from public.productos p
where (
    p.codigo_barras = '7502227875377'
    or (
      p.sku in ('FC-27875377', 'FC-ND-27875377', 'FMX-302490')
      and p.nombre ilike '%tromdex%'
    )
  )
  and not exists (
    select 1 from public.producto_precios_referencia r
    where r.producto_id = p.id
      and r.fuente = 'ultima_compra'
      and r.precio = 91.80
      and r.fecha = date '2026-09-18'
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farma MX',
  'CAICA3CA97141',
  '2026-09-18',
  459.00,
  'borrador',
  'Farma MX CAICA3CA97141 · Central de Abastos Iztapalapa · 18-sep-2026 · Tromdex 10 mg C/30 × 5 · $91.80 · lote RTR098 · ticket cad 01/01/2028 · cola Recibir; stock al confirmar pistola y MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = 'CAICA3CA97141'
    and coalesce(proveedor, '') ilike '%farma mx%'
);

update public.recepciones
set
  total_ticket = 459.00,
  fecha = '2026-09-18',
  proveedor = 'Farma MX',
  notas = 'Farma MX CAICA3CA97141 · Central de Abastos Iztapalapa · 18-sep-2026 · Tromdex 10 mg C/30 × 5 · $91.80 · lote RTR098 · ticket cad 01/01/2028 · cola Recibir; stock al confirmar pistola y MMAA de la caja',
  updated_at = now()
where folio = 'CAICA3CA97141'
  and coalesce(proveedor, '') ilike '%farma mx%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'CAICA3CA97141'
  and coalesce(r.proveedor, '') ilike '%farma mx%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  '7502227875377',
  'Tromdex ezetimiba 10 mg C/30 tabletas',
  5,
  null,
  'RTR098',
  91.80,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.numero_lote is distinct from 'RTR098'
    )
  ),
  null
from public.recepciones r
left join lateral (
  select public.fc_buscar_producto_escaneo('7502227875377') as pid
) v on true
where r.folio = 'CAICA3CA97141'
  and coalesce(r.proveedor, '') ilike '%farma mx%'
  and r.estado = 'borrador';

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.costo,
  p.precio,
  p.stock,
  p.requiere_receta
from public.productos p
where p.codigo_barras = '7502227875377'
   or p.sku in ('FC-27875377', 'FC-ND-27875377', 'FMX-302490');

select
  r.id as recepcion_id,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = 'CAICA3CA97141'
  and coalesce(r.proveedor, '') ilike '%farma mx%'
group by r.id, r.folio, r.estado, r.total_ticket;

select
  i.codigo_escaneado as ean,
  i.nombre_snapshot,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  i.fecha_caducidad,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = 'CAICA3CA97141'
  and coalesce(r.proveedor, '') ilike '%farma mx%';
