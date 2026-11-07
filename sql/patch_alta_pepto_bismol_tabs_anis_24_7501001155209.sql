-- ============================================================================
-- FARMACAPITAL — Pepto-Bismol tabletas masticables sabor anís 24
-- EAN 7501001155209 · P&G · SKU FC-01155209
--
-- Empaque (fotos mostrador): tira colgante rosa/amarilla, 6 sobres × 4 tabs.
-- Blister: «Cada tableta contiene: Subsalicilato de Bismuto 262.4 mg»
-- Reg. No. 091M88 SSA VI · Procter & Gamble Manufacturing México.
-- Distinto de FC-00753067 (suspensión 118 ml · EAN 020800753067).
--
-- Ficha oficial: peptobismol.com.mx/es-mx/productos/pepto-bismol-tabletas-sabor-anis/
-- Ancla retail (sin ticket de costo): ~$99–$122 (Gi / HEB). Precio $105 hasta
-- que Recibir ponga costo; marca +25% sobre costo (no uses margen/0.75).
--
-- Stock 0: no inventar piezas. El blister de la foto trae lote 21013704 y
-- caducidad 06/25 (jun-2025) — ya vencida; no recibir ese lote a venta.
--
-- Foto: packshot Pepto MX → public/catalogo-propia/
--       pepto-bismol-tabletas-masticables-anis-24-7501001155209.png
-- URL: jsDelivr del commit (inmediato) + /catalogo-propia/ tras deploy.
-- ORDEN: 1) merge/deploy  2) pegar este SQL en Supabase → Run.
-- SIN bloques $$. Pegar TODO.
-- ============================================================================

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  laboratorio, costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Pepto-Bismol sabor anís',
  'FC-01155209',
  '7501001155209',
  'Digestivo',
  'Antiácido / antidiarreico',
  'marca',
  'Pepto-Bismol tabletas masticables sabor anís · subsalicilato de bismuto 262.4 mg · 24 tabs (6 sobres × 4) · P&G · Reg. 091M88 SSA VI · EAN 7501001155209 · ancla retail $105 sin ticket de costo',
  'Pepto-Bismol',
  '24 tabletas masticables',
  'Subsalicilato de bismuto',
  '262.4 mg',
  'Tabletas masticables',
  'Procter & Gamble',
  null,
  105,
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@92e29aa/public/catalogo-propia/pepto-bismol-tabletas-masticables-anis-24-7501001155209.png',
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@92e29aa/public/catalogo-propia/pepto-bismol-tabletas-masticables-anis-24-7501001155209.png',
  0,
  2,
  true,
  false
where public.fc_buscar_producto_escaneo('7501001155209') is null
  and public.fc_buscar_producto_escaneo('FC-01155209') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501001155209'
       or p.sku = 'FC-01155209'
  );

-- Completa ficha si ya existía sin pisar foto/costo/precio buenos.
update public.productos p
set
  nombre = 'Pepto-Bismol sabor anís',
  marca = 'Pepto-Bismol',
  presentacion = '24 tabletas masticables',
  principio_activo = 'Subsalicilato de bismuto',
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '262.4 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Tabletas masticables'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Digestivo'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Antiácido / antidiarreico'),
  tipo = 'marca',
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'Procter & Gamble'),
  requiere_receta = false,
  activo = true,
  codigo_barras = '7501001155209',
  precio = case when coalesce(p.precio, 0) <= 1 then 105 else p.precio end,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''),
    'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@92e29aa/public/catalogo-propia/pepto-bismol-tabletas-masticables-anis-24-7501001155209.png'),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''),
    'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@92e29aa/public/catalogo-propia/pepto-bismol-tabletas-masticables-anis-24-7501001155209.png'),
  descripcion = trim(both ' ·' from concat_ws(
    ' · ',
    nullif(trim(both ' ·' from coalesce(p.descripcion, '')), ''),
    'Pepto-Bismol tabs anís 24 · EAN 7501001155209'
  ))
where p.codigo_barras = '7501001155209'
   or p.sku = 'FC-01155209';

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@92e29aa/public/catalogo-propia/pepto-bismol-tabletas-masticables-anis-24-7501001155209.png',
  'catalogo-propia/pepto-bismol-tabletas-masticables-anis-24-7501001155209.png',
  0,
  true,
  'propia'
from public.productos p
where (p.codigo_barras = '7501001155209' or p.sku = 'FC-01155209')
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%pepto-bismol-tabletas-masticables-anis-24-7501001155209%'
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.principio_activo,
  p.concentracion,
  p.costo,
  p.precio,
  p.stock,
  p.activo,
  left(p.imagen_url, 90) as foto
from public.productos p
where p.codigo_barras = '7501001155209'
   or p.sku = 'FC-01155209'
order by p.sku;
