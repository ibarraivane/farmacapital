-- IFC F8 Tienda · folio 125448 · 2026-09-24
-- Códigos IFC del ticket NO son EAN GS1 (salvo Tensolastic 7501048690909).
-- Altas stock 0. Pegar en Supabase → SQL Editor → Run.

begin;

-- FC-IFC-83733 | Dibar venda cohesiva 7.5 cm colores C/24
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Dibar venda cohesiva 7.5 cm colores C/24',
  'FC-IFC-83733',
  null,
  'Botiquín',
  'marca',
  'Ticket IFC 125448 · DIBAR VENDA 7.5 CM COLORES C/24 5C025C02 83733',
  318.00, 398, 0, 1, true, false,
  'Dibar',
  'Paquete C/24',
  'Venda',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-83733') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-83733');

update public.productos set
  costo = 318.00,
  precio = case when coalesce(precio, 0) <= 0 then 398 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Dibar'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Paquete C/24'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Venda'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-83733'
;

-- FC-48690909 | Venda elástica Protec Tensolastic Plus 7 cm × 5 m
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Venda elástica Protec Tensolastic Plus 7 cm × 5 m',
  'FC-48690909',
  '7501048690909',
  'Botiquín',
  'marca',
  'Ticket IFC 125448 · PROTEC VENDA TENSOLASTIC PLUS 7CMX5M 2A301071 83217',
  21.50, 27, 0, 1, true, false,
  'Protec',
  '7 cm × 5 m',
  'Venda',
  null
where public.fc_buscar_producto_escaneo('7501048690909') is null
  and not exists (select 1 from public.productos where sku = 'FC-48690909');

update public.productos set
  costo = 21.50,
  precio = case when coalesce(precio, 0) <= 0 then 27 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Protec'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '7 cm × 5 m'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Venda'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-48690909'
   or codigo_barras = '7501048690909';

commit;
