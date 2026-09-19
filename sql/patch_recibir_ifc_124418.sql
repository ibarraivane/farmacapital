-- IFC F8 Tienda · CJ 01 Fol 124418 · 18/09/2026 11:52 · cliente LUIS.
-- MAYOREO. Total $200.50 · 7 productos / 10 piezas. No suma stock.
-- La nota no trae lote ni caducidad: se quedan en null. No inventar 0000.
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
--
-- Precios = P.U. cobrado (suma de importes = TOTAL VENTA). No se quita IVA.
-- Recargo sobre costo: marca +25% · genérico +60%. Math.ceil.
-- fuente de costo = ultima_compra (equilibrio/ifc no están en fuentes_precio).
--
-- 1) FLOR DE AIRE ACEITE DE ALMENDRAS 125ML · 1 × $24.00
--    Ficha flordeaire.com: botella 125 ml, uso tópico. Sin EAN en la página.
--    Marca: precio $30 = 24 × 1.25.
--    SKU FC-24163265 (reloj: no hay EAN ni código IFC).
--
-- 2) MASCARILLA FACIAL 30 ML VITAMINA-E · 1 × $3.50
--    Sin marca ni EAN en la nota. No se inventa laboratorio.
--    Genérico: precio $6 = 3.50 × 1.60 = 5.60, hacia arriba.
--    SKU FC-24163275. Foto pendiente.
--
-- 3) MASCARILLA CAPSULA 27ML (A352) ALOE REAL · 1 × $4.00
--    Jigott Aloe Real Ampoule Mask 27 ml. EAN 8809541280269.
--    A352 es código IFC, no el nombre. Marca: precio $5.
--    SKU FC-54128026.
--
-- 4) MASCARILLA CAPSULA 27ML (A358) PERLA REAL · 1 × $4.00
--    Jigott Pearl Real Ampoule Mask 27 ml. EAN 8809541280221.
--    A358 es código IFC. Marca: precio $5.
--    SKU FC-54128022.
--
-- 5) PARCHES P/ACNE FIGS HIDROCOLOIDE · 2 × $16.50 = $33.00
--    No hay ficha ni EAN. No se inventa cuántos parches trae el empaque.
--    Marca FIGS: precio $21 = 16.50 × 1.25 = 20.63, hacia arriba.
--    SKU FC-24163285. Foto pendiente.
--
-- 6) GRISI JABON AZUFRE 100G · código IFC 83278 · 2 × $51.00 = $102.00
--    EAN 7501022109786 (dermojabón azufre Grisi 100 g).
--    Marca: precio $64 = 51 × 1.25 = 63.75, hacia arriba.
--    SKU FC-02109786.
--
-- 7) GELI JABON AZUFRE 80G · JA041026 · código IFC 83886 · 2 × $15.00 = $30.00
--    El ticket no dice «con miel». No se liga el EAN 7503014119032
--    de Gelimedic azufre con miel 80 g: puede ser otro jabón.
--    Marca Geli: precio $19 = 15 × 1.25 = 18.75, hacia arriba.
--    SKU FC-IFC-83886. Foto pendiente. Ligar EAN de la caja al escanear.

begin;

-- ── 1 Flor de Aire ───────────────────────────────────────────────────

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Aceite de almendras dulces Flor de Aire 125 ml',
  'FC-24163265',
  null,
  'Cuidado personal',
  'Piel',
  'marca',
  'IFC 124418 · FLOR DE AIRE ACEITE DE ALMENDRAS 125ML · ficha flordeaire.com botella 125 ml · sin EAN · recargo marca +25%',
  'Flor de Aire',
  'Botella 125 ml',
  'Aceite',
  24.00,
  30,
  'https://www.farmacapital.mx/catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg',
  'https://www.farmacapital.mx/catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg',
  0, 1, true, false
where public.fc_buscar_producto_escaneo('FC-24163265') is null
  and not exists (select 1 from public.productos p where p.sku = 'FC-24163265');

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg',
  'catalogo-propia/flor-de-aire-aceite-almendras-125ml.jpg',
  0, true, 'propia'
from public.productos p
where p.sku = 'FC-24163265'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%flor-de-aire-aceite-almendras-125ml%'
  );

-- ── 2 Vitamina E (sin marca) ─────────────────────────────────────────

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  presentacion, forma_farmaceutica,
  costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  'Mascarilla facial vitamina E 30 ml',
  'FC-24163275',
  null,
  'Cuidado personal',
  'Facial',
  'generico',
  'IFC 124418 · MASCARILLA FACIAL 30 ML VITAMINA-E · sin marca ni EAN en la nota · foto pendiente · recargo genérico +60%',
  '30 ml',
  'Mascarilla',
  3.50,
  6,
  0, 1, true, false
where public.fc_buscar_producto_escaneo('FC-24163275') is null
  and not exists (select 1 from public.productos p where p.sku = 'FC-24163275');

-- ── 3 Jigott Aloe Real ───────────────────────────────────────────────

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Mascarilla Jigott Aloe Real ampolleta 27 ml',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-54128026'
        and coalesce(p.codigo_barras, '') <> '8809541280269'
    ) then 'FC-ND-54128026'
    else 'FC-54128026'
  end,
  '8809541280269',
  'Cuidado personal',
  'Facial',
  'marca',
  'IFC 124418 · (A352) ALOE REAL · Jigott Aloe Real Ampoule Mask 27 ml · EAN 8809541280269 · recargo marca +25%',
  'Jigott',
  'Sobre 27 ml',
  'Mascarilla',
  4.00,
  5,
  'https://www.farmacapital.mx/catalogo-propia/jigott-aloe-real-ampoule-27ml.jpg',
  'https://www.farmacapital.mx/catalogo-propia/jigott-aloe-real-ampoule-27ml.jpg',
  0, 1, true, false
where public.fc_buscar_producto_escaneo('8809541280269') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '8809541280269'
       or p.sku in ('FC-54128026', 'FC-ND-54128026')
  );

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/jigott-aloe-real-ampoule-27ml.jpg',
  'catalogo-propia/jigott-aloe-real-ampoule-27ml.jpg',
  0, true, 'propia'
from public.productos p
where p.codigo_barras = '8809541280269'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%jigott-aloe-real-ampoule-27ml%'
  );

-- ── 4 Jigott Pearl Real ──────────────────────────────────────────────

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Mascarilla Jigott Pearl Real ampolleta 27 ml',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-54128022'
        and coalesce(p.codigo_barras, '') <> '8809541280221'
    ) then 'FC-ND-54128022'
    else 'FC-54128022'
  end,
  '8809541280221',
  'Cuidado personal',
  'Facial',
  'marca',
  'IFC 124418 · (A358) PERLA REAL · Jigott Pearl Real Ampoule Mask 27 ml · EAN 8809541280221 · recargo marca +25%',
  'Jigott',
  'Sobre 27 ml',
  'Mascarilla',
  4.00,
  5,
  'https://www.farmacapital.mx/catalogo-propia/jigott-pearl-real-ampoule-27ml.jpg',
  'https://www.farmacapital.mx/catalogo-propia/jigott-pearl-real-ampoule-27ml.jpg',
  0, 1, true, false
where public.fc_buscar_producto_escaneo('8809541280221') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '8809541280221'
       or p.sku in ('FC-54128022', 'FC-ND-54128022')
  );

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/jigott-pearl-real-ampoule-27ml.jpg',
  'catalogo-propia/jigott-pearl-real-ampoule-27ml.jpg',
  0, true, 'propia'
from public.productos p
where p.codigo_barras = '8809541280221'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%jigott-pearl-real-ampoule-27ml%'
  );

-- ── 5 FIGS ───────────────────────────────────────────────────────────

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, forma_farmaceutica,
  costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  'Parches para acné FIGS hidrocoloide',
  'FC-24163285',
  null,
  'Cuidado personal',
  'Piel',
  'marca',
  'IFC 124418 · PARCHES P/ACNE FIGS HIDROCOLOIDE · sin ficha ni EAN · no se inventa el número de parches · foto pendiente · recargo marca +25%',
  'FIGS',
  'Parche',
  16.50,
  21,
  0, 1, true, false
where public.fc_buscar_producto_escaneo('FC-24163285') is null
  and not exists (select 1 from public.productos p where p.sku = 'FC-24163285');

-- ── 6 Grisi ──────────────────────────────────────────────────────────

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Jabón de azufre Grisi 100 g',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-02109786'
        and coalesce(p.codigo_barras, '') <> '7501022109786'
    ) then 'FC-ND-02109786'
    else 'FC-02109786'
  end,
  '7501022109786',
  'Cuidado personal',
  'Higiene',
  'marca',
  'IFC 124418 · GRISI JABON AZUFRE 100G · código IFC 83278 · EAN 7501022109786 · recargo marca +25%',
  'Grisi',
  'Barra 100 g',
  'Jabón',
  51.00,
  64,
  'https://www.farmacapital.mx/catalogo-propia/grisi-jabon-azufre-100g.jpg',
  'https://www.farmacapital.mx/catalogo-propia/grisi-jabon-azufre-100g.jpg',
  0, 1, true, false
where public.fc_buscar_producto_escaneo('7501022109786') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501022109786'
       or p.sku in ('FC-02109786', 'FC-ND-02109786')
  );

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/grisi-jabon-azufre-100g.jpg',
  'catalogo-propia/grisi-jabon-azufre-100g.jpg',
  0, true, 'propia'
from public.productos p
where p.codigo_barras = '7501022109786'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%grisi-jabon-azufre-100g%'
  );

-- ── 7 Geli ───────────────────────────────────────────────────────────

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica,
  costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  'Jabón de azufre Geli 80 g',
  'FC-IFC-83886',
  null,
  'Cuidado personal',
  'Higiene',
  'marca',
  'IFC 124418 · GELI JABON AZUFRE 80G · código IFC 83886 JA041026 · no se liga EAN Gelimedic 7503014119032 (ese dice con miel) · foto pendiente · recargo marca +25%',
  'Geli',
  'Barra 80 g',
  'Jabón',
  15.00,
  19,
  0, 1, true, false
where public.fc_buscar_producto_escaneo('FC-IFC-83886') is null
  and not exists (select 1 from public.productos p where p.sku = 'FC-IFC-83886');

-- ── Costo de compra ──────────────────────────────────────────────────

insert into public.fuentes_precio (id, nombre, tipo, metodo, notas)
values (
  'ultima_compra', 'Costo de compra', 'compra', 'manual',
  'Primera compra (quién + precio). Recibir solo lo pisa si el ticket es más barato.'
)
on conflict (id) do nothing;

insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
select p.id, 'ultima_compra', 'compra', v.costo, date '2026-09-18', 'IFC', 100, 'manual', v.notas
from (
  values
    (null::text, 'FC-24163265'::text, 24.00::numeric, 'IFC 124418 · Flor de Aire 125 ml · 1 × $24.00'),
    (null, 'FC-24163275', 3.50, 'IFC 124418 · mascarilla vitamina E 30 ml · 1 × $3.50'),
    ('8809541280269', 'FC-54128026', 4.00, 'IFC 124418 · Jigott Aloe Real 27 ml · 1 × $4.00'),
    ('8809541280221', 'FC-54128022', 4.00, 'IFC 124418 · Jigott Pearl Real 27 ml · 1 × $4.00'),
    (null, 'FC-24163285', 16.50, 'IFC 124418 · parches FIGS · 2 × $16.50'),
    ('7501022109786', 'FC-02109786', 51.00, 'IFC 124418 · Grisi azufre 100 g · código 83278 · 2 × $51.00'),
    (null, 'FC-IFC-83886', 15.00, 'IFC 124418 · Geli azufre 80 g · código 83886 · 2 × $15.00')
) as v(ean, sku, costo, notas)
join public.productos p on (
  (v.ean is not null and p.codigo_barras = v.ean)
  or (v.ean is null and p.sku = v.sku)
)
where not exists (
  select 1 from public.producto_precios_referencia r
  where r.producto_id = p.id
    and r.fuente = 'ultima_compra'
    and r.precio = v.costo
    and r.fecha = date '2026-09-18'
);

-- ── Recepción ────────────────────────────────────────────────────────

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '124418',
  '2026-09-18',
  200.50,
  'borrador',
  'IFC F8 Tienda · folio 124418 · MAYOREO · 18-sep-2026 11:52 · cliente LUIS · 10 piezas · cola Recibir; MMAA de la caja · Flor de Aire, vitamina E, FIGS y Geli sin EAN: ligar el de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '124418' and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 200.50,
  fecha = '2026-09-18',
  proveedor = 'IFC F8 Tienda',
  notas = 'IFC F8 Tienda · folio 124418 · MAYOREO · 18-sep-2026 11:52 · cliente LUIS · 10 piezas · cola Recibir; MMAA de la caja · Flor de Aire, vitamina E, FIGS y Geli sin EAN: ligar el de la caja',
  updated_at = now()
where folio = '124418'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '124418'
  and coalesce(r.proveedor, '') ilike '%ifc%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(btrim(t.ean), ''),
  t.nombre,
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
from (
  values
    (1, null::text, 'FC-24163265'::text, 'Aceite de almendras dulces Flor de Aire 125 ml'::text, 1, 24.00::numeric),
    (2, null, 'FC-24163275', 'Mascarilla facial vitamina E 30 ml', 1, 3.50),
    (3, '8809541280269', 'FC-54128026', 'Mascarilla Jigott Aloe Real ampolleta 27 ml', 1, 4.00),
    (4, '8809541280221', 'FC-54128022', 'Mascarilla Jigott Pearl Real ampolleta 27 ml', 1, 4.00),
    (5, null, 'FC-24163285', 'Parches para acné FIGS hidrocoloide', 2, 16.50),
    (6, '7501022109786', 'FC-02109786', 'Jabón de azufre Grisi 100 g', 2, 51.00),
    (7, null, 'FC-IFC-83886', 'Jabón de azufre Geli 80 g', 2, 15.00)
) as t(linea, ean, sku, nombre, qty, costo)
join public.recepciones r
  on r.folio = '124418'
 and coalesce(r.proveedor, '') ilike '%ifc%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

select r.proveedor, r.folio, r.estado, r.total_ticket,
       count(i.*) as renglones,
       sum(i.cantidad) as piezas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '124418' and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;

select i.codigo_escaneado as ean, i.nombre_snapshot, i.cantidad, i.costo_estimado,
       case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '124418' and coalesce(r.proveedor, '') ilike '%ifc%'
order by i.id;
