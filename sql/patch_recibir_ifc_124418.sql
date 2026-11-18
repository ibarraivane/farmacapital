-- IFC F8 folio 124418. 18-sep-2026. Mayoreo $200.50. 10 piezas.
-- Codigos leidos de la caja (no del PDF). No suma stock.
-- Recargo sobre costo: marca +25% · generico +60%. Math.ceil.
-- Pegar TODO en Supabase → SQL Editor → Run.

begin;

-- Flor de Aire 125 ml. Botella: 7502280170501.
update public.productos set
  codigo_barras = '7502280170501',
  nombre = 'Aceite de almendras dulces Flor de Aire 125 ml',
  marca = 'Flor de Aire',
  presentacion = 'Botella 125 ml',
  forma_farmaceutica = 'Aceite',
  categoria = 'Cuidado personal',
  subcategoria = 'Piel',
  tipo = 'marca',
  costo = 24.00,
  precio = case when coalesce(precio, 0) <= 0 then 30 else precio end,
  descripcion = 'IFC 124418. EAN de la botella 7502280170501. Recargo marca +25%.',
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg'),
  imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg')
where (sku in ('FC-24163265', 'FC-28017051') or codigo_barras = '7502280170501')
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502280170501' and o.id <> productos.id
  );

-- Million Pauline. Digitos impresos 6972038406885. La caja dice 30 ml.
update public.productos set
  codigo_barras = '6972038406885',
  nombre = 'Million Pauline Vitamin E Velvet Mask 30 ml',
  marca = 'Million Pauline',
  presentacion = 'Sobre 30 ml',
  forma_farmaceutica = 'Mascarilla',
  categoria = 'Cuidado personal',
  subcategoria = 'Facial',
  tipo = 'marca',
  costo = 3.50,
  precio = 5,
  descripcion = 'IFC 124418. NO.M0152. EAN 6972038406885. Recargo marca +25%.',
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/million-pauline-vitamin-e-velvet-30ml.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/million-pauline-vitamin-e-velvet-30ml.jpg'
where (sku in ('FC-24163275', 'FC-03840685') or codigo_barras = '6972038406885')
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6972038406885' and o.id <> productos.id
  );

-- A352 en el ticket. La caja es Grenobil, no Jigott. EAN 6973345468900.
update public.productos set
  codigo_barras = '6973345468900',
  nombre = 'Grenobil mascarilla ampolla de aloe real 27 ml',
  marca = 'Grenobil',
  presentacion = 'Sobre 27 ml',
  forma_farmaceutica = 'Mascarilla',
  categoria = 'Cuidado personal',
  subcategoria = 'Facial',
  tipo = 'marca',
  costo = 4.00,
  precio = case when coalesce(precio, 0) <= 0 then 5 else precio end,
  descripcion = 'IFC 124418. Codigo de caja XIERMEI-A352. EAN 6973345468900. No es Jigott. Recargo marca +25%.',
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/grenobil-aloe-mascarilla-27ml.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/grenobil-aloe-mascarilla-27ml.jpg'
where (sku in ('FC-54128026', 'FC-34546890')
   or codigo_barras in ('8809541280269', '6973345468900'))
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6973345468900' and o.id <> productos.id
  );

-- A358. Grenobil perla. EAN 6973345468870.
update public.productos set
  codigo_barras = '6973345468870',
  nombre = 'Grenobil mascarilla ampolla de perla real 27 ml',
  marca = 'Grenobil',
  presentacion = 'Sobre 27 ml',
  forma_farmaceutica = 'Mascarilla',
  categoria = 'Cuidado personal',
  subcategoria = 'Facial',
  tipo = 'marca',
  costo = 4.00,
  precio = case when coalesce(precio, 0) <= 0 then 5 else precio end,
  descripcion = 'IFC 124418. Codigo de caja XIERMEI-A358. EAN 6973345468870. No es Jigott. Recargo marca +25%.',
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/grenobil-perla-mascarilla-27ml.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/grenobil-perla-mascarilla-27ml.jpg'
where (sku in ('FC-54128022', 'FC-34546870')
   or codigo_barras in ('8809541280221', '6973345468870'))
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6973345468870' and o.id <> productos.id
  );

-- El ticket decia FIGS × 2. Llegaron dos cajas distintas.
update public.productos set
  codigo_barras = '20250702003',
  nombre = 'Parches para acne hidrocoloide figuras',
  marca = null,
  presentacion = null,
  forma_farmaceutica = 'Parche',
  categoria = 'Cuidado personal',
  subcategoria = 'Piel',
  tipo = 'generico',
  costo = 16.50,
  precio = 27,
  descripcion = 'IFC 124418. Caja verde. Codigo de barras 20250702003. La caja no dice FIGS. No se inventa cuantos parches. Recargo generico +60%.',
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/parches-acne-hidrocoloide-702003.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/parches-acne-hidrocoloide-702003.jpg'
where (sku in ('FC-24163285', 'FC-07020003') or codigo_barras = '20250702003')
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '20250702003' and o.id <> productos.id
  );

-- Geli 83886 / lote Ja041026 es el Gelimedic de la foto. EAN 7503014119032.
update public.productos set
  nombre = 'Gelimedic jabon de azufre con miel 80 g',
  marca = 'Gelimedic',
  presentacion = 'Barra 80 g',
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Jabon'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
  subcategoria = coalesce(nullif(btrim(subcategoria), ''), 'Higiene'),
  tipo = 'marca',
  costo = 15.00,
  precio = case when coalesce(precio, 0) <= 0 then 19 else precio end,
  descripcion = 'IFC 124418. Codigo 83886. Lote Ja041026. CAD 08/2030. EAN 7503014119032.',
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/gelimedic-jabon-azufre-miel-80g.jpg'),
  imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/gelimedic-jabon-azufre-miel-80g.jpg')
where codigo_barras = '7503014119032' or sku = 'FC-14119032';

update public.productos
set activo = false
where sku = 'FC-IFC-83886' and coalesce(stock, 0) = 0;

update public.productos
set costo = 51.00,
    precio = case when coalesce(precio, 0) <= 0 then 64 else precio end
where codigo_barras = '7501022109786' or sku = 'FC-02109786';

update public.productos p
set sku = v.sku
from (
  values
    ('7502280170501', 'FC-28017051'),
    ('6972038406885', 'FC-03840685'),
    ('6973345468900', 'FC-34546890'),
    ('6973345468870', 'FC-34546870'),
    ('20250702003', 'FC-07020003'),
    ('20250702004', 'FC-07020004')
) as v(ean, sku)
where p.codigo_barras = v.ean
  and p.sku is distinct from v.sku
  and not exists (select 1 from public.productos o where o.sku = v.sku);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica, costo, precio,
  imagen_url, imagen_mobile_url, stock, stock_minimo, activo, requiere_receta
)
select v.nombre, v.sku, v.ean, v.cat, v.sub, v.tipo, v.descr,
  v.marca, v.pres, v.forma, v.costo, v.precio, v.foto, v.foto,
  0, 1, true, false
from (
  values
    ('Aceite de almendras dulces Flor de Aire 125 ml'::text, 'FC-28017051'::text, '7502280170501'::text,
     'Cuidado personal', 'Piel', 'marca',
     'IFC 124418. EAN de la botella 7502280170501. Recargo marca +25%.',
     'Flor de Aire'::text, 'Botella 125 ml'::text, 'Aceite', 24.00::numeric, 30::numeric,
     'https://www.farmacapital.mx/catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg'::text),
    ('Million Pauline Vitamin E Velvet Mask 30 ml', 'FC-03840685', '6972038406885',
     'Cuidado personal', 'Facial', 'marca',
     'IFC 124418. NO.M0152. EAN 6972038406885. Recargo marca +25%.',
     'Million Pauline', 'Sobre 30 ml', 'Mascarilla', 3.50, 5,
     'https://www.farmacapital.mx/catalogo-propia/million-pauline-vitamin-e-velvet-30ml.jpg'),
    ('Grenobil mascarilla ampolla de aloe real 27 ml', 'FC-34546890', '6973345468900',
     'Cuidado personal', 'Facial', 'marca',
     'IFC 124418. Codigo de caja XIERMEI-A352. EAN 6973345468900. No es Jigott. Recargo marca +25%.',
     'Grenobil', 'Sobre 27 ml', 'Mascarilla', 4.00, 5,
     'https://www.farmacapital.mx/catalogo-propia/grenobil-aloe-mascarilla-27ml.jpg'),
    ('Grenobil mascarilla ampolla de perla real 27 ml', 'FC-34546870', '6973345468870',
     'Cuidado personal', 'Facial', 'marca',
     'IFC 124418. Codigo de caja XIERMEI-A358. EAN 6973345468870. No es Jigott. Recargo marca +25%.',
     'Grenobil', 'Sobre 27 ml', 'Mascarilla', 4.00, 5,
     'https://www.farmacapital.mx/catalogo-propia/grenobil-perla-mascarilla-27ml.jpg'),
    ('Parches para acne hidrocoloide figuras', 'FC-07020003', '20250702003',
     'Cuidado personal', 'Piel', 'generico',
     'IFC 124418. Caja verde. Codigo 20250702003. La caja no dice FIGS. No se inventa cuantos parches. Recargo generico +60%.',
     null, null, 'Parche', 16.50, 27,
     'https://www.farmacapital.mx/catalogo-propia/parches-acne-hidrocoloide-702003.jpg'),
    ('Parches para acne hidrocoloide panda', 'FC-07020004', '20250702004',
     'Cuidado personal', 'Piel', 'generico',
     'IFC 124418. Caja azul. Codigo 20250702004. La caja no dice FIGS. No se inventa cuantos parches. Recargo generico +60%.',
     null, null, 'Parche', 16.50, 27,
     'https://www.farmacapital.mx/catalogo-propia/parches-acne-hidrocoloide-702004.jpg'),
    ('Jabon de azufre Grisi 100 g', 'FC-02109786', '7501022109786',
     'Cuidado personal', 'Higiene', 'marca',
     'IFC 124418. Codigo IFC 83278. EAN 7501022109786. Recargo marca +25%.',
     'Grisi', 'Barra 100 g', 'Jabon', 51.00, 64,
     'https://www.farmacapital.mx/catalogo-propia/grisi-jabon-azufre-100g.jpg')
) as v(nombre, sku, ean, cat, sub, tipo, descr, marca, pres, forma, costo, precio, foto)
where public.fc_buscar_producto_escaneo(v.ean) is null
  and not exists (
    select 1 from public.productos p
    where p.sku = v.sku or p.codigo_barras = v.ean
  );

-- Si la galería ya tiene la foto de Jigott, se cambia la URL. No se inserta otra en la posición 0.
update public.producto_imagenes i
set url = v.url,
    storage_path = v.path,
    origen = 'propia'
from (
  values
    ('6973345468900'::text, 'https://www.farmacapital.mx/catalogo-propia/grenobil-aloe-mascarilla-27ml.jpg', 'catalogo-propia/grenobil-aloe-mascarilla-27ml.jpg'),
    ('6973345468870', 'https://www.farmacapital.mx/catalogo-propia/grenobil-perla-mascarilla-27ml.jpg', 'catalogo-propia/grenobil-perla-mascarilla-27ml.jpg')
) as v(ean, url, path)
join public.productos p on p.codigo_barras = v.ean
where i.producto_id = p.id
  and i.url like '%jigott-%'
  and i.url is distinct from v.url;

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id, v.url, v.path,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  false,
  'propia'
from (
  values
    ('7502280170501'::text, 'https://www.farmacapital.mx/catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg', 'catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg'),
    ('6972038406885', 'https://www.farmacapital.mx/catalogo-propia/million-pauline-vitamin-e-velvet-30ml.jpg', 'catalogo-propia/million-pauline-vitamin-e-velvet-30ml.jpg'),
    ('6973345468900', 'https://www.farmacapital.mx/catalogo-propia/grenobil-aloe-mascarilla-27ml.jpg', 'catalogo-propia/grenobil-aloe-mascarilla-27ml.jpg'),
    ('6973345468870', 'https://www.farmacapital.mx/catalogo-propia/grenobil-perla-mascarilla-27ml.jpg', 'catalogo-propia/grenobil-perla-mascarilla-27ml.jpg'),
    ('20250702003', 'https://www.farmacapital.mx/catalogo-propia/parches-acne-hidrocoloide-702003.jpg', 'catalogo-propia/parches-acne-hidrocoloide-702003.jpg'),
    ('20250702004', 'https://www.farmacapital.mx/catalogo-propia/parches-acne-hidrocoloide-702004.jpg', 'catalogo-propia/parches-acne-hidrocoloide-702004.jpg'),
    ('7501022109786', 'https://www.farmacapital.mx/catalogo-propia/grisi-jabon-azufre-100g.jpg', 'catalogo-propia/grisi-jabon-azufre-100g.jpg'),
    ('7503014119032', 'https://www.farmacapital.mx/catalogo-propia/gelimedic-jabon-azufre-miel-80g.jpg', 'catalogo-propia/gelimedic-jabon-azufre-miel-80g.jpg')
) as v(ean, url, path)
join public.productos p on p.codigo_barras = v.ean
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = p.id and i.url = v.url
);

insert into public.fuentes_precio (id, nombre, tipo, metodo, notas)
values ('ultima_compra', 'Costo de compra', 'compra', 'manual', 'Costo de ticket.')
on conflict (id) do nothing;

insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
select p.id, 'ultima_compra', 'compra', v.costo, date '2026-09-18', 'IFC', 100, 'manual', v.nota
from (
  values
    ('7502280170501'::text, 24.00::numeric, 'IFC 124418 Flor de Aire'),
    ('6972038406885', 3.50, 'IFC 124418 Million Pauline'),
    ('6973345468900', 4.00, 'IFC 124418 Grenobil aloe'),
    ('6973345468870', 4.00, 'IFC 124418 Grenobil perla'),
    ('20250702003', 16.50, 'IFC 124418 parches figuras'),
    ('20250702004', 16.50, 'IFC 124418 parches panda'),
    ('7501022109786', 51.00, 'IFC 124418 Grisi 83278'),
    ('7503014119032', 15.00, 'IFC 124418 Gelimedic 83886')
) as v(ean, costo, nota)
join public.productos p on p.codigo_barras = v.ean
where not exists (
  select 1 from public.producto_precios_referencia r
  where r.producto_id = p.id and r.fuente = 'ultima_compra' and r.fecha = date '2026-09-18'
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select 'IFC F8 Tienda', '124418', '2026-09-18', 200.50, 'borrador',
  'IFC F8 124418. MAYOREO. 18-sep-2026 11:52. Cliente LUIS. 10 piezas. EAN de la caja.'
where not exists (
  select 1 from public.recepciones
  where folio = '124418' and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set total_ticket = 200.50, fecha = '2026-09-18', proveedor = 'IFC F8 Tienda',
  notas = 'IFC F8 124418. MAYOREO. 18-sep-2026 11:52. Cliente LUIS. 10 piezas. EAN de la caja.',
  updated_at = now()
where folio = '124418' and coalesce(proveedor, '') ilike '%ifc%' and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id and r.folio = '124418'
  and coalesce(r.proveedor, '') ilike '%ifc%' and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select r.id, v.pid, t.ean, t.nombre, t.qty, t.cad, t.lote, t.costo,
  (v.pid is null), 'pdf', false,
  (v.pid is not null and exists (
    select 1 from public.lotes l
    where l.producto_id = v.pid and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) > 0
  )),
  null
from (
  values
    (1, '7502280170501'::text, 'Aceite de almendras dulces Flor de Aire 125 ml'::text, 1, 24.00::numeric, null::text, null::date),
    (2, '6972038406885', 'Million Pauline Vitamin E Velvet Mask 30 ml', 1, 3.50, null, null),
    (3, '6973345468900', 'Grenobil mascarilla ampolla de aloe real 27 ml', 1, 4.00, null, null),
    (4, '6973345468870', 'Grenobil mascarilla ampolla de perla real 27 ml', 1, 4.00, null, null),
    (5, '20250702003', 'Parches para acne hidrocoloide figuras', 1, 16.50, null, null),
    (6, '20250702004', 'Parches para acne hidrocoloide panda', 1, 16.50, null, null),
    (7, '7501022109786', 'Jabon de azufre Grisi 100 g', 2, 51.00, null, null),
    (8, '7503014119032', 'Gelimedic jabon de azufre con miel 80 g', 2, 15.00, 'Ja041026', date '2030-08-31')
) as t(linea, ean, nombre, qty, costo, lote, cad)
join public.recepciones r on r.folio = '124418' and coalesce(r.proveedor, '') ilike '%ifc%' and r.estado = 'borrador'
left join lateral (
  select public.fc_buscar_producto_escaneo(t.ean) as pid
) v on true
order by t.linea;

commit;

select r.folio, r.estado, r.total_ticket, count(i.*) as renglones, sum(i.cantidad) as piezas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '124418' and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.folio, r.estado, r.total_ticket;

select i.codigo_escaneado as ean, i.nombre_snapshot, i.cantidad, i.costo_estimado,
  i.numero_lote, i.fecha_caducidad,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '124418' and coalesce(r.proveedor, '') ilike '%ifc%'
order by i.id;
