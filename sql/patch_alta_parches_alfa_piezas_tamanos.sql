-- ============================================================================
-- Parches Alfa Medical blancos · piezas por tamaño (caja abierta)
--
-- En línea NO hay EAN de fábrica por tamaño. Alfa Medical solo vende
-- la caja mixta C/10 con EAN 7503014279552 (4 de 10×10 + 6 de 6×8).
--
-- Modelo FarmaCapital:
--   1) CAJA sellada  → FC-14279552 / 7503014279552  (Recibir / pistola)
--   2) PIEZA grande  → sticker INTERNO 2008101000019 / FC-01000019
--   3) PIEZA chica   → sticker INTERNO 2008068000015 / FC-68000015
--
-- Prefijo 20 = código de tienda (como cubrebocas / rastrillo). Pegar sticker.
-- NO inventar un 750… de GS1.
--
-- Costo pieza = 53.15 / 10 = $5.32 · marca +25% → PVP $7 c/u
-- Stock pieza 0 hasta que abras una caja.
--
-- Al abrir 1 caja en mostrador (manual en Inventario / Lotes):
--   caja  FC-14279552  −1
--   gran  FC-01000019  +4
--   chic  FC-68000015  +6
--
-- Requiere haber corrido antes (o el mismo día):
--   sql/patch_alta_parches_alfa_medical_7503014279552.sql
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- Pieza GRANDE 10×10 cm
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta,
  disponible, visible_tienda
)
select
  'Parche adhesivo blanco 10×10 cm',
  'FC-01000019',
  '2008101000019',
  'Botiquín',
  'Material de curación',
  'marca',
  'Pieza suelta · tamaño grande 10×10 cm · sale de caja Alfa Medical C/10 (EAN 7503014279552: 4 grandes + 6 chicos) · sticker INTERNO 2008101000019 · pegar en mostrador',
  'Alfa Medical',
  '1 parche 10×10 cm',
  'Parche adhesivo',
  5.32,
  7,
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg',
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg',
  0,
  4,
  true,
  false,
  'inmediato',
  true
where public.fc_buscar_producto_escaneo('2008101000019') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '2008101000019'
       or p.sku = 'FC-01000019'
  );

-- Pieza CHICA 6×8 cm
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta,
  disponible, visible_tienda
)
select
  'Parche adhesivo blanco 6×8 cm',
  'FC-68000015',
  '2008068000015',
  'Botiquín',
  'Material de curación',
  'marca',
  'Pieza suelta · tamaño chico 6×8 cm · sale de caja Alfa Medical C/10 (EAN 7503014279552: 4 grandes + 6 chicos) · sticker INTERNO 2008068000015 · pegar en mostrador',
  'Alfa Medical',
  '1 parche 6×8 cm',
  'Parche adhesivo',
  5.32,
  7,
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg',
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg',
  0,
  6,
  true,
  false,
  'inmediato',
  true
where public.fc_buscar_producto_escaneo('2008068000015') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '2008068000015'
       or p.sku = 'FC-68000015'
  );

-- Completar ficha si ya existían (sin pisar costo/PVP/stock/foto buena).
update public.productos p
set
  nombre = 'Parche adhesivo blanco 10×10 cm',
  marca = 'Alfa Medical',
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), '1 parche 10×10 cm'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Parche adhesivo'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Botiquín'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Material de curación'),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'marca'),
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), '2008101000019'),
  costo = case when coalesce(p.costo, 0) <= 0 then 5.32 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 0 then 7 else p.precio end,
  requiere_receta = false,
  activo = true,
  visible_tienda = true,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  imagen_url = coalesce(
    nullif(btrim(p.imagen_url), ''),
    'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(p.imagen_mobile_url), ''),
    'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg'
  )
where p.codigo_barras = '2008101000019'
   or p.sku = 'FC-01000019';

update public.productos p
set
  nombre = 'Parche adhesivo blanco 6×8 cm',
  marca = 'Alfa Medical',
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), '1 parche 6×8 cm'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Parche adhesivo'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Botiquín'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Material de curación'),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'marca'),
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), '2008068000015'),
  costo = case when coalesce(p.costo, 0) <= 0 then 5.32 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 0 then 7 else p.precio end,
  requiere_receta = false,
  activo = true,
  visible_tienda = true,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  imagen_url = coalesce(
    nullif(btrim(p.imagen_url), ''),
    'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(p.imagen_mobile_url), ''),
    'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg'
  )
where p.codigo_barras = '2008068000015'
   or p.sku = 'FC-68000015';

-- Nota en la caja: enlaza a las piezas internas.
update public.productos p
set
  nombre = 'Parches adhesivos blancos caja C/10',
  presentacion = 'Caja 10 parches (4 de 10×10 cm + 6 de 6×8 cm)',
  descripcion = 'Caja sellada Alfa Medical · EAN fábrica 7503014279552. '
    || 'Al abrir: −1 caja → +4 piezas FC-01000019 (10×10) + +6 piezas FC-68000015 (6×8). '
    || 'Stickers internos 2008101000019 / 2008068000015.'
where p.codigo_barras = '7503014279552'
   or p.sku in ('FC-14279552', 'FC-ND-14279552');

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg',
  'catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg',
  1,
  true,
  'distribuidor'
from public.productos p
where p.sku in ('FC-01000019', 'FC-68000015')
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%parches-adhesivos-alfa-medical-blancos-c10%'
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  p.activo
from public.productos p
where p.codigo_barras in ('7503014279552', '2008101000019', '2008068000015')
   or p.sku in ('FC-14279552', 'FC-ND-14279552', 'FC-01000019', 'FC-68000015')
order by
  case p.sku
    when 'FC-14279552' then 1
    when 'FC-ND-14279552' then 1
    when 'FC-01000019' then 2
    when 'FC-68000015' then 3
    else 9
  end,
  p.sku;
