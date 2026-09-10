-- IFC F8 Tienda · folio 123443 (2026-09-10) — altas de catálogo.
-- SIN bloques dollar-quote. Stock = 0; entra al escanear en Recibir.
-- Sin EAN público (códigos IFC del ticket no son GS1). codigo_barras = null.
-- Ligar EAN de la caja al escanear / editar ficha.
-- TODO foto: FC-IFC-82084 brocha tinte (falta packshot de la pieza).
-- Orden: 1) este archivo  2) patch_recepcion_ifc_123443.sql
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.

begin;

-- FC-IFC-82084 | Brocha para tinte con peine de cola
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Brocha para tinte con peine de cola',
  'FC-IFC-82084',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 123443 · Farma Centre · BROCHA TINTE C/PEINE DE COLA SK2220 82084 · falta EAN de caja',
  5.50, 9.00, 0, 1, true, false,
  null,
  'Pieza',
  'Accesorio',
  null
where not exists (select 1 from public.productos where sku = 'FC-IFC-82084');

update public.productos set
  costo = 5.50,
  precio = case when coalesce(precio, 0) <= 0 then 9.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), null),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Pieza'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Accesorio'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-82084';

-- FC-IFC-83947 | Guantes de nitrilo negro mediano C/100
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Guantes de nitrilo negro mediano C/100',
  'FC-IFC-83947',
  null,
  'Botiquín',
  'marca',
  'Ticket IFC 123443 · Farma Centre · GUANTE NITRILO NEGRO MEDIANO C/100 PZS 052025 83947 · falta EAN de caja',
  104.00, 167.00, 0, 1, true, false,
  null,
  'C/100',
  'Guante',
  'https://www.farmacapital.mx/catalogo-propia/guantes-nitrilo-negro-c100.jpg'
where not exists (select 1 from public.productos where sku = 'FC-IFC-83947');

update public.productos set
  costo = 104.00,
  precio = case when coalesce(precio, 0) <= 0 then 167.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), null),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/100'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Guante'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Botiquín'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/guantes-nitrilo-negro-c100.jpg')
where sku = 'FC-IFC-83947';

-- FC-IFC-83490 | Guantes de nitrilo azul chico C/100
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Guantes de nitrilo azul chico C/100',
  'FC-IFC-83490',
  null,
  'Botiquín',
  'marca',
  'Ticket IFC 123443 · Farma Centre · GUANTE NITRILO CHICO AZUL C/100 07202595 83490 · falta EAN de caja',
  92.00, 148.00, 0, 1, true, false,
  null,
  'C/100',
  'Guante',
  'https://www.farmacapital.mx/catalogo-propia/guantes-nitrilo-azul-c100.jpg'
where not exists (select 1 from public.productos where sku = 'FC-IFC-83490');

update public.productos set
  costo = 92.00,
  precio = case when coalesce(precio, 0) <= 0 then 148.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), null),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/100'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Guante'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Botiquín'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/guantes-nitrilo-azul-c100.jpg')
where sku = 'FC-IFC-83490';

-- FC-IFC-82912P | Venda Stick cohesiva 3 pulg × 4.5 m piel
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Venda Stick cohesiva 3 pulg × 4.5 m piel',
  'FC-IFC-82912P',
  null,
  'Botiquín',
  'marca',
  'Ticket IFC 123443 · Farma Centre · VENDA STICK 3P X 4.5 MTS PIEL 7CM 221206+2 82912 · falta EAN de caja',
  45.00, 72.00, 0, 1, true, false,
  'Stick',
  '3" × 4.5 m',
  'Venda',
  'https://www.farmacapital.mx/catalogo-propia/venda-cohesiva-stick.png'
where not exists (select 1 from public.productos where sku = 'FC-IFC-82912P');

update public.productos set
  costo = 45.00,
  precio = case when coalesce(precio, 0) <= 0 then 72.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Stick'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '3" × 4.5 m'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Venda'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Botiquín'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/venda-cohesiva-stick.png')
where sku = 'FC-IFC-82912P';

-- FC-IFC-82912A | Venda Stick cohesiva 3 pulg × 4.5 m azul
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Venda Stick cohesiva 3 pulg × 4.5 m azul',
  'FC-IFC-82912A',
  null,
  'Botiquín',
  'marca',
  'Ticket IFC 123443 · Farma Centre · VENDA STICK 3P X 4.5 MTS AZUL 7CM 221205-1 82912 · falta EAN de caja',
  47.50, 76.00, 0, 1, true, false,
  'Stick',
  '3" × 4.5 m',
  'Venda',
  'https://www.farmacapital.mx/catalogo-propia/venda-cohesiva-stick.png'
where not exists (select 1 from public.productos where sku = 'FC-IFC-82912A');

update public.productos set
  costo = 47.50,
  precio = case when coalesce(precio, 0) <= 0 then 76.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Stick'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '3" × 4.5 m'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Venda'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Botiquín'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/venda-cohesiva-stick.png')
where sku = 'FC-IFC-82912A';

-- FC-IFC-83613 | Venditas adhesivas redondas Jayor C/100
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Venditas adhesivas redondas Jayor C/100',
  'FC-IFC-83613',
  null,
  'Botiquín',
  'marca',
  'Ticket IFC 123443 · Farma Centre · JAYOR VENDITAS ADHESIVAS REDONDAS C/100 15L24 83613 · falta EAN de caja',
  52.50, 84.00, 0, 1, true, false,
  'Jayor',
  'C/100',
  'Vendita',
  'https://www.farmacapital.mx/catalogo-propia/venditas-adhesivas-redondas-c100.jpg'
where not exists (select 1 from public.productos where sku = 'FC-IFC-83613');

update public.productos set
  costo = 52.50,
  precio = case when coalesce(precio, 0) <= 0 then 84.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Jayor'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/100'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Vendita'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Botiquín'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/venditas-adhesivas-redondas-c100.jpg')
where sku = 'FC-IFC-83613';

-- FC-IFC-83552 | Venda Stick cohesiva 2 pulg × 4.5 m rojo
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Venda Stick cohesiva 2 pulg × 4.5 m rojo',
  'FC-IFC-83552',
  null,
  'Botiquín',
  'marca',
  'Ticket IFC 123443 · Farma Centre · VENDA STICK 2P X 4.5 MTS ROJO 5CM 240306-1 83552 · falta EAN de caja',
  29.50, 48.00, 0, 1, true, false,
  'Stick',
  '2" × 4.5 m',
  'Venda',
  'https://www.farmacapital.mx/catalogo-propia/venda-cohesiva-stick.png'
where not exists (select 1 from public.productos where sku = 'FC-IFC-83552');

update public.productos set
  costo = 29.50,
  precio = case when coalesce(precio, 0) <= 0 then 48.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Stick'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '2" × 4.5 m'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Venda'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Botiquín'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/venda-cohesiva-stick.png')
where sku = 'FC-IFC-83552';

-- FC-IFC-83125 | Guantes de nitrilo azul grande C/100
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Guantes de nitrilo azul grande C/100',
  'FC-IFC-83125',
  null,
  'Botiquín',
  'marca',
  'Ticket IFC 123443 · Farma Centre · GUANTE NITRILO GRANDE AZUL C/100 07202595 83125 · falta EAN de caja',
  92.00, 148.00, 0, 1, true, false,
  null,
  'C/100',
  'Guante',
  'https://www.farmacapital.mx/catalogo-propia/guantes-nitrilo-azul-c100.jpg'
where not exists (select 1 from public.productos where sku = 'FC-IFC-83125');

update public.productos set
  costo = 92.00,
  precio = case when coalesce(precio, 0) <= 0 then 148.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), null),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/100'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Guante'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Botiquín'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/guantes-nitrilo-azul-c100.jpg')
where sku = 'FC-IFC-83125';

-- FC-IFC-83368 | Gel sanitizante Dibar 50 ml
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Gel sanitizante Dibar 50 ml',
  'FC-IFC-83368',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 123443 · Farma Centre · DIBAR GEL SANITIZANTE 50 ML C/24 1C056C05 83368 · falta EAN de caja',
  11.50, 19.00, 0, 1, true, false,
  'Dibar',
  '50 ml',
  'Gel',
  'https://www.farmacapital.mx/catalogo-propia/dibar-gel-sanitizante-50ml.jpg'
where not exists (select 1 from public.productos where sku = 'FC-IFC-83368');

update public.productos set
  costo = 11.50,
  precio = case when coalesce(precio, 0) <= 0 then 19.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Dibar'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '50 ml'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Gel'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/dibar-gel-sanitizante-50ml.jpg')
where sku = 'FC-IFC-83368';

commit;

select sku, codigo_barras as ean, left(nombre, 48) as nombre, costo, precio, stock,
  left(coalesce(imagen_url, '(sin foto)'), 64) as foto
from public.productos
where sku in ('FC-IFC-82084', 'FC-IFC-83947', 'FC-IFC-83490', 'FC-IFC-82912P', 'FC-IFC-82912A', 'FC-IFC-83613', 'FC-IFC-83552', 'FC-IFC-83125', 'FC-IFC-83368')
order by sku;
