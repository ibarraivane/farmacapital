-- IFC F8 Tienda · folio 123816 (2026-09-12) — altas de catálogo.
-- SIN bloques dollar-quote. Stock = 0; entra al escanear en Recibir.
-- Sin EAN público (códigos IFC del ticket no son GS1). codigo_barras = null.
-- Aceite almendras ya existe (FC-D4AC123B): solo actualiza costo.
-- Fotos Curtis Lady en catalogo-propia/.
-- Orden: 1) este archivo  2) patch_recepcion_ifc_123816.sql
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.

begin;

-- FC-IFC-PINZACH | Pinza tijera Lady Curtis chica
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Pinza tijera Lady Curtis chica',
  'FC-IFC-PINZACH',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 123816 · Farma Centre · PINZA DEPILAR LADY CHICA · falta EAN de caja',
  7.50, 12.00, 0, 1, true, false,
  'Curtis',
  'Chica',
  'Accesorio',
  'https://www.farmacapital.mx/catalogo-propia/pinza-lady-curtis-chica.jpg'
where not exists (select 1 from public.productos where sku = 'FC-IFC-PINZACH');

update public.productos set
  costo = 7.50,
  precio = case when coalesce(precio, 0) <= 0 then 12.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Curtis'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Chica'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Accesorio'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/pinza-lady-curtis-chica.jpg')
where sku = 'FC-IFC-PINZACH';

-- FC-IFC-PINZAGR | Pinza tijera Lady Curtis grande
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Pinza tijera Lady Curtis grande',
  'FC-IFC-PINZAGR',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 123816 · Farma Centre · PINZA DEPILAR LADY GRANDE · falta EAN de caja',
  8.00, 13.00, 0, 1, true, false,
  'Curtis',
  'Grande',
  'Accesorio',
  'https://www.farmacapital.mx/catalogo-propia/pinza-lady-curtis-grande.jpg'
where not exists (select 1 from public.productos where sku = 'FC-IFC-PINZAGR');

update public.productos set
  costo = 8.00,
  precio = case when coalesce(precio, 0) <= 0 then 13.00 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Curtis'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Grande'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Accesorio'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/pinza-lady-curtis-grande.jpg')
where sku = 'FC-IFC-PINZAGR';

-- FC-D4AC123B | Mercurio Aceite Almendras (ya existía)
update public.productos set
  costo = 8.50,
  precio = case when coalesce(precio, 0) <= 0 then 14.00 else precio end
where sku = 'FC-D4AC123B';

commit;

select sku, codigo_barras as ean, left(nombre, 48) as nombre, costo, precio, stock,
  left(coalesce(imagen_url, '(sin foto)'), 64) as foto
from public.productos
where sku in ('FC-IFC-PINZACH', 'FC-IFC-PINZAGR', 'FC-D4AC123B')
order by sku;
