-- IFC F8 folio 124418. 18-sep-2026. Mayoreo $200.50. 7 productos, 10 piezas.
-- Borrador. No suma stock. Sin lote ni caducidad. Pegar TODO y Run.
-- Costo en ultima_compra. Marca +25%. Vitamina E generico +60%.

begin;

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
    ('Aceite de almendras dulces Flor de Aire 125 ml'::text, 'FC-24163265'::text, null::text,
     'Cuidado personal', 'Piel', 'marca',
     'IFC 124418. Flor de Aire 125 ml. Sin EAN. Recargo marca +25%.',
     'Flor de Aire'::text, 'Botella 125 ml'::text, 'Aceite', 24.00::numeric, 30.00::numeric,
     'https://www.farmacapital.mx/catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg'::text),
    ('Mascarilla facial vitamina E 30 ml', 'FC-24163275', null,
     'Cuidado personal', 'Facial', 'generico',
     'IFC 124418. Sin marca ni EAN. Foto pendiente. Recargo generico +60%.',
     null, '30 ml', 'Mascarilla', 3.50, 6.00, null),
    ('Mascarilla Jigott Aloe Real ampolleta 27 ml', 'FC-54128026', '8809541280269',
     'Cuidado personal', 'Facial', 'marca',
     'IFC 124418. A352 es codigo IFC. Jigott Aloe Real 27 ml. Recargo marca +25%.',
     'Jigott', 'Sobre 27 ml', 'Mascarilla', 4.00, 5.00,
     'https://www.farmacapital.mx/catalogo-propia/jigott-aloe-real-ampoule-27ml.jpg'),
    ('Mascarilla Jigott Pearl Real ampolleta 27 ml', 'FC-54128022', '8809541280221',
     'Cuidado personal', 'Facial', 'marca',
     'IFC 124418. A358 es codigo IFC. Jigott Pearl Real 27 ml. Recargo marca +25%.',
     'Jigott', 'Sobre 27 ml', 'Mascarilla', 4.00, 5.00,
     'https://www.farmacapital.mx/catalogo-propia/jigott-pearl-real-ampoule-27ml.jpg'),
    ('Parches para acne FIGS hidrocoloide', 'FC-24163285', null,
     'Cuidado personal', 'Piel', 'marca',
     'IFC 124418. Sin EAN. No se inventa cuantos parches. Foto pendiente. Recargo marca +25%.',
     'FIGS', null, 'Parche', 16.50, 21.00, null),
    ('Jabon de azufre Grisi 100 g', 'FC-02109786', '7501022109786',
     'Cuidado personal', 'Higiene', 'marca',
     'IFC 124418. Codigo IFC 83278. EAN 7501022109786. Recargo marca +25%.',
     'Grisi', 'Barra 100 g', 'Jabon', 51.00, 64.00,
     'https://www.farmacapital.mx/catalogo-propia/grisi-jabon-azufre-100g.jpg'),
    ('Jabon de azufre Geli 80 g', 'FC-IFC-83886', null,
     'Cuidado personal', 'Higiene', 'marca',
     'IFC 124418. Codigo 83886. No se liga Gelimedic 7503014119032 (ese dice con miel). Foto pendiente.',
     'Geli', 'Barra 80 g', 'Jabon', 15.00, 19.00, null)
) as v(nombre, sku, ean, cat, sub, tipo, descr, marca, pres, forma, costo, precio, foto)
where public.fc_buscar_producto_escaneo(coalesce(v.ean, v.sku)) is null
  and not exists (
    select 1 from public.productos p
    where p.sku = v.sku or (v.ean is not null and p.codigo_barras = v.ean)
  );

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id, v.url, v.path, 0, true, 'propia'
from (
  values
    ('FC-24163265'::text, null::text, 'https://www.farmacapital.mx/catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg', 'catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg'),
    ('FC-54128026', '8809541280269', 'https://www.farmacapital.mx/catalogo-propia/jigott-aloe-real-ampoule-27ml.jpg', 'catalogo-propia/jigott-aloe-real-ampoule-27ml.jpg'),
    ('FC-54128022', '8809541280221', 'https://www.farmacapital.mx/catalogo-propia/jigott-pearl-real-ampoule-27ml.jpg', 'catalogo-propia/jigott-pearl-real-ampoule-27ml.jpg'),
    ('FC-02109786', '7501022109786', 'https://www.farmacapital.mx/catalogo-propia/grisi-jabon-azufre-100g.jpg', 'catalogo-propia/grisi-jabon-azufre-100g.jpg')
) as v(sku, ean, url, path)
join public.productos p on p.sku = v.sku or (v.ean is not null and p.codigo_barras = v.ean)
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
    (null::text, 'FC-24163265'::text, 24.00::numeric, 'IFC 124418 Flor de Aire'),
    (null, 'FC-24163275', 3.50, 'IFC 124418 vitamina E'),
    ('8809541280269', 'FC-54128026', 4.00, 'IFC 124418 Jigott Aloe'),
    ('8809541280221', 'FC-54128022', 4.00, 'IFC 124418 Jigott Pearl'),
    (null, 'FC-24163285', 16.50, 'IFC 124418 FIGS'),
    ('7501022109786', 'FC-02109786', 51.00, 'IFC 124418 Grisi 83278'),
    (null, 'FC-IFC-83886', 15.00, 'IFC 124418 Geli 83886')
) as v(ean, sku, costo, nota)
join public.productos p on (v.ean is not null and p.codigo_barras = v.ean) or (v.ean is null and p.sku = v.sku)
where not exists (
  select 1 from public.producto_precios_referencia r
  where r.producto_id = p.id and r.fuente = 'ultima_compra' and r.precio = v.costo and r.fecha = date '2026-09-18'
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select 'IFC F8 Tienda', '124418', '2026-09-18', 200.50, 'borrador',
  'IFC F8 124418. MAYOREO. 18-sep-2026 11:52. Cliente LUIS. 10 piezas. MMAA de la caja. Sin EAN: Flor de Aire, vitamina E, FIGS, Geli.'
where not exists (
  select 1 from public.recepciones
  where folio = '124418' and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set total_ticket = 200.50, fecha = '2026-09-18', proveedor = 'IFC F8 Tienda',
  notas = 'IFC F8 124418. MAYOREO. 18-sep-2026 11:52. Cliente LUIS. 10 piezas. MMAA de la caja. Sin EAN: Flor de Aire, vitamina E, FIGS, Geli.',
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
select r.id, v.pid, nullif(btrim(t.ean), ''), t.nombre, t.qty, null, null, t.costo,
  (v.pid is null), 'pdf', false,
  (v.pid is not null and exists (
    select 1 from public.lotes l
    where l.producto_id = v.pid and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) > 0
  )),
  null
from (
  values
    (1, null::text, 'FC-24163265'::text, 'Aceite de almendras dulces Flor de Aire 125 ml'::text, 1, 24.00::numeric),
    (2, null, 'FC-24163275', 'Mascarilla facial vitamina E 30 ml', 1, 3.50),
    (3, '8809541280269', 'FC-54128026', 'Mascarilla Jigott Aloe Real ampolleta 27 ml', 1, 4.00),
    (4, '8809541280221', 'FC-54128022', 'Mascarilla Jigott Pearl Real ampolleta 27 ml', 1, 4.00),
    (5, null, 'FC-24163285', 'Parches para acne FIGS hidrocoloide', 2, 16.50),
    (6, '7501022109786', 'FC-02109786', 'Jabon de azufre Grisi 100 g', 2, 51.00),
    (7, null, 'FC-IFC-83886', 'Jabon de azufre Geli 80 g', 2, 15.00)
) as t(linea, ean, sku, nombre, qty, costo)
join public.recepciones r on r.folio = '124418' and coalesce(r.proveedor, '') ilike '%ifc%' and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null then public.fc_buscar_producto_escaneo(t.ean) end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

select r.folio, r.estado, r.total_ticket, count(i.*) as renglones, sum(i.cantidad) as piezas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '124418' and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.folio, r.estado, r.total_ticket;

select i.codigo_escaneado as ean, i.nombre_snapshot, i.cantidad, i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '124418' and coalesce(r.proveedor, '') ilike '%ifc%'
order by i.id;
