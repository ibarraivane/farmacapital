-- ============================================================================
-- FARMA CAPITAL — Lote mayoristas 17-sep-2026 (DermaPharma / Birdman / ON / Promexsa)
-- Generado por scripts/alta-bajo-pedido-desde-fichas.js
-- desde docs/fichas_lote_mayoristas_20260917.json
-- 10 SKUs. Ancla = lista Fahorro (SKU = EAN). Stock 0. Sin lote ni caducidad.
-- Fotos en public/catalogo-propia/ → URL farmacapital.mx DESPUÉS del deploy.
-- Si el EAN ya existe CON stock: no se marca bajo_pedido.
-- ============================================================================

begin;

do $$
begin
  if not exists (
    select 1
      from information_schema.columns
     where table_schema = 'public'
       and table_name = 'productos'
       and column_name = 'bajo_pedido'
  ) then
    raise exception 'Primero corre sql/patch_bajo_pedido_20260916.sql (falta productos.bajo_pedido)';
  end if;
end
$$;

create temp table _fc_vitrina_bp (
  ean text primary key,
  sku text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  precio numeric(12,2) not null,
  imagen_url text not null,
  descripcion text not null
) on commit drop;

insert into _fc_vitrina_bp values
  ('3337875890021', 'FC-75890021', 'La Roche-Posay Mela B3 suero antimanchas 30 ml', 'La Roche-Posay', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 1467::numeric, 'https://www.farmacapital.mx/catalogo-propia/lrp-mela-b3-serum-30ml.jpg', 'DermaPharma vende la línea. Ficha Fahorro SKU=EAN 3337875890021 · lista $1,467'),
  ('3337875761031', 'FC-75761031', 'La Roche-Posay Anthelios Age Correct FPS 50+ 50 ml', 'La Roche-Posay', '50 ml', 'Cuidado personal', 'Dermatología', 'Crema', 998::numeric, 'https://www.farmacapital.mx/catalogo-propia/lrp-anthelios-age-correct-50ml.jpg', 'DermaPharma / Nadro pedible. Fahorro SKU=EAN 3337875761031 · $998'),
  ('8429420248977', 'FC-20248977', 'Isdin Fotoprotector Fusion Water Magic FPS 50 50 ml', 'Isdin', '50 ml', 'Cuidado personal', 'Dermatología', 'Fluido', 784::numeric, 'https://www.farmacapital.mx/catalogo-propia/isdin-fusion-water-magic-50ml.jpg', 'DermaPharma. Fahorro SKU=EAN 8429420248977 · lista $784'),
  ('8429420160750', 'FC-20160750', 'Isdin FotoUltra 100 Active Unify 50 ml', 'Isdin', '50 ml', 'Cuidado personal', 'Dermatología', 'Fluido', 813::numeric, 'https://www.farmacapital.mx/catalogo-propia/isdin-fotoultra-100-active-unify-50ml.jpg', 'DermaPharma. Fahorro SKU=EAN 8429420160750 · $813'),
  ('8429420244191', 'FC-20244191', 'Isdin FotoUltra Age Repair Fusion Water Color FPS 50 50 ml', 'Isdin', '50 ml', 'Cuidado personal', 'Dermatología', 'Fluido', 792::numeric, 'https://www.farmacapital.mx/catalogo-propia/isdin-age-repair-fusion-water-color-50ml.jpg', 'DermaPharma. Fahorro SKU=EAN 8429420244191 · $792'),
  ('7503025737355', 'FC-25737355', 'Birdman creatina monohidratada 450 g', 'Birdman', '450 g', 'Suplemento', 'Nutrición deportiva', 'Polvo', 584::numeric, 'https://www.farmacapital.mx/catalogo-propia/birdman-creatina-450g.jpg', 'Birdman B2B / Fahorro SKU=EAN 7503025737355 · lista $584 · ficha mx.birdman.com'),
  ('7503037273377', 'FC-37273377', 'Birdman Fitmingo proteína vegetal moka 510 g', 'Birdman', '510 g', 'Suplemento', 'Nutrición deportiva', 'Polvo', 604::numeric, 'https://www.farmacapital.mx/catalogo-propia/birdman-fitmingo-moka-510g.jpg', 'Birdman B2B / Fahorro SKU=EAN 7503037273377 · lista $604'),
  ('7503037273940', 'FC-37273940', 'Birdman creatina Electrolyte Refresher Golden Peach 300 g', 'Birdman', '300 g', 'Suplemento', 'Nutrición deportiva', 'Polvo', 482::numeric, 'https://www.farmacapital.mx/catalogo-propia/birdman-creatina-electrolyte-peach-300g.jpg', 'Birdman B2B / Fahorro SKU=EAN 7503037273940 · lista $482'),
  ('748927054804', 'FC-27054804', 'Optimum Nutrition Gold Standard 100% Whey vainilla 907 g', 'Optimum Nutrition', '907 g', 'Suplemento', 'Nutrición deportiva', 'Polvo', 1253::numeric, 'https://www.farmacapital.mx/catalogo-propia/on-gold-standard-whey-vainilla-907g.jpg', 'Suplementos Mayoreo / Fahorro SKU=EAN 748927054804 · lista $1,253'),
  ('7798031060140', 'FC-31060140', 'Nebucor nebulizador P-103', 'Nebucor', '1 pieza', 'Dispositivo médico', 'Respiratorio', 'Aparato', 890::numeric, 'https://www.farmacapital.mx/catalogo-propia/nebucor-nebulizador-p103.jpg', 'Promexsa / Fahorro SKU=EAN 7798031060140 · $890 · incluye mascarillas adulto e infantil');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria, imagen_url,
  bajo_pedido
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  'marca',
  t.descripcion,
  null,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.presentacion,
  t.forma,
  t.subcategoria,
  t.imagen_url,
  true
from _fc_vitrina_bp t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean
  );

update public.productos p
   set bajo_pedido = true,
       activo = true,
       marca = coalesce(nullif(trim(p.marca), ''), t.marca),
       presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
       imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen_url),
       precio = case when coalesce(p.precio, 0) <= 0.01 then t.precio else p.precio end
  from _fc_vitrina_bp t
 where (p.codigo_barras = t.ean or p.id = public.fc_buscar_producto_escaneo(t.ean))
   and coalesce(p.stock, 0) = 0;

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id, t.imagen_url, 1, true, 'distribuidor'
  from _fc_vitrina_bp t
  join public.productos p
    on p.codigo_barras = t.ean
    or p.id = public.fc_buscar_producto_escaneo(t.ean)
 where coalesce(p.bajo_pedido, false) = true
   and not exists (
     select 1 from public.producto_imagenes i
      where i.producto_id = p.id
        and i.url = t.imagen_url
   );

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.categoria,
  p.subcategoria,
  p.precio,
  p.stock,
  p.bajo_pedido,
  left(p.imagen_url, 80) as imagen
from public.productos p
where p.codigo_barras in (
  '3337875890021',
  '3337875761031',
  '8429420248977',
  '8429420160750',
  '8429420244191',
  '7503025737355',
  '7503037273377',
  '7503037273940',
  '748927054804',
  '7798031060140'
)
order by p.categoria, p.subcategoria nulls first, p.nombre;
