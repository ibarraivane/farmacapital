-- IFC F8 Tienda · folio 125445 · 2026-09-24
-- Códigos IFC del ticket NO son EAN GS1 (salvo Tensolastic 7501048690909).
-- Altas stock 0. Pegar en Supabase → SQL Editor → Run.

begin;

-- FC-IFC-1570818 | Mercurio magnesia calcinada C/50
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio magnesia calcinada C/50',
  'FC-IFC-1570818',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · MERCURIO MAGNESIA CALCINADA C/50 1570818 06AGO25',
  55.50, 70, 0, 1, true, false,
  'Mercurio',
  'C/50',
  'Polvo',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-1570818') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-1570818');

update public.productos set
  costo = 55.50,
  precio = case when coalesce(precio, 0) <= 0 then 70 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/50'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-1570818'
;

-- FC-IFC-ESPEJITO | Espejito redondo económico
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Espejito redondo económico',
  'FC-IFC-ESPEJITO',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · ESPEJITO REDONDO ECONOMICO',
  6.00, 8, 0, 1, true, false,
  null,
  'Pieza',
  'Accesorio',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-ESPEJITO') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-ESPEJITO');

update public.productos set
  costo = 6.00,
  precio = case when coalesce(precio, 0) <= 0 then 8 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), null),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Pieza'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Accesorio'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-ESPEJITO'
;

-- FC-IFC-PARCHE-ACNE | Parches para acné hidrocoloide
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Parches para acné hidrocoloide',
  'FC-IFC-PARCHE-ACNE',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · PARCHES P/ACNE FIGS HIDROCOLOIDE',
  16.50, 21, 0, 1, true, false,
  null,
  'Pieza',
  'Parche',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-PARCHE-ACNE') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-PARCHE-ACNE');

update public.productos set
  costo = 16.50,
  precio = case when coalesce(precio, 0) <= 0 then 21 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), null),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Pieza'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Parche'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-PARCHE-ACNE'
;

-- FC-IFC-82912 | Benzal Wash líquido 240 mL
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Benzal Wash líquido 240 mL',
  'FC-IFC-82912',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · BENZAL WASH LIQUIDO 240ML R101100 82912',
  102.50, 129, 0, 1, true, false,
  'Benzal',
  '240 mL',
  'Jabón líquido',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-82912') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-82912');

update public.productos set
  costo = 102.50,
  precio = case when coalesce(precio, 0) <= 0 then 129 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Benzal'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '240 mL'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Jabón líquido'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-82912'
;

-- FC-IFC-1490724 | Mercurio rosa de Castilla C/50
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio rosa de Castilla C/50',
  'FC-IFC-1490724',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · MERCURIO ROSA DE CASTILLA C/50 1490724 83490',
  75.00, 94, 0, 1, true, false,
  'Mercurio',
  'C/50',
  'Polvo',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-1490724') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-1490724');

update public.productos set
  costo = 75.00,
  precio = case when coalesce(precio, 0) <= 0 then 94 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/50'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-1490724'
;

-- FC-IFC-1330723 | Mercurio almidón cajita C/10
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio almidón cajita C/10',
  'FC-IFC-1330723',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · MERCURIO ALMIDON CAJITA C/10 1330723 83125',
  91.50, 115, 0, 1, true, false,
  'Mercurio',
  'C/10',
  'Polvo',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-1330723') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-1330723');

update public.productos set
  costo = 91.50,
  precio = case when coalesce(precio, 0) <= 0 then 115 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/10'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-1330723'
;

-- FC-IFC-1660824 | Mercurio anís estrella C/25
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio anís estrella C/25',
  'FC-IFC-1660824',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · MERCURIO ANIS ESTRELLA C/25 1660824 83521',
  131.00, 164, 0, 1, true, false,
  'Mercurio',
  'C/25',
  'Polvo',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-1660824') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-1660824');

update public.productos set
  costo = 131.00,
  precio = case when coalesce(precio, 0) <= 0 then 164 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/25'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-1660824'
;

-- FC-578F060C | Mercurio bórax polvo (EAN 3311000003739) — YA EN CATÁLOGO.
-- No crear FC-IFC-1400724 (duplicado sin EAN del ticket 125445). Ver
-- sql/patch_merge_mercurio_borax_ifc_1400724.sql
update public.productos set
  costo = case when coalesce(costo, 0) <= 0 then 53.00 else costo end,
  precio = case when coalesce(precio, 0) <= 0 then 85 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/50'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
  principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Bórax'),
  venta_unidad = true,
  unidades_por_caja = 50,
  precio_unidad = case when coalesce(precio_unidad, 0) <= 0 then 7 else precio_unidad end,
  codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '3311000003739'),
  activo = true
where sku = 'FC-578F060C'
;

-- FC-IFC-PULEFIN100 | Lima de uñas Pulefin C/100
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Lima de uñas Pulefin C/100',
  'FC-IFC-PULEFIN100',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · LIMA UNAS PULEFIN C/100',
  94.50, 119, 0, 1, true, false,
  'Pulefin',
  'C/100',
  'Lima',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-PULEFIN100') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-PULEFIN100');

update public.productos set
  costo = 94.50,
  precio = case when coalesce(precio, 0) <= 0 then 119 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Pulefin'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/100'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Lima'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-PULEFIN100'
;

-- FC-IFC-82943 | Mercurio pomada manzana C/25
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio pomada manzana C/25',
  'FC-IFC-82943',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · MERCURIO POMADA MANZANA C/25 2530123 82943',
  9.50, 12, 0, 1, true, false,
  'Mercurio',
  'C/25',
  'Pomada',
  'https://www.farmacapital.mx/catalogo-propia/mercurio-pomada-manzana-50g.jpg'
where public.fc_buscar_producto_escaneo('FC-IFC-82943') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-82943');

update public.productos set
  costo = 9.50,
  precio = case when coalesce(precio, 0) <= 0 then 12 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/25'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Pomada'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/mercurio-pomada-manzana-50g.jpg')
where sku = 'FC-IFC-82943'
;

commit;
