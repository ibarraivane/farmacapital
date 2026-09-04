-- Palmolive Optims sobre 10 ml: foto de pieza + (opcional) precio.
-- DESPUÉS de que Vercel publique este commit (los JPG viven en
-- public/catalogo-propia/). Si corres el SQL antes, las URLs 404.
--
-- Foto principal: par 2x1 de sobres (lo que se ve en mostrador).
-- Secundaria: exhibidor de 48 (referencia de compra).
-- Precio: se deja en $3 (ver notas de margen abajo). No inventa stock.

-- Margen a $3 (costo 75.30/48 ≈ 1.57):
--   utilidad $1.43 · margen ~48% · markup ~91%
-- Referencias: Básicos tira 24 ≈ $2.80/sobre; L'miau par 2x1 $4.
-- $3 es precio de mostrador sano. Si quieres más utilidad: $4 → ~61%.

begin;

update public.productos
   set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/palmolive-optims-sobre-10ml.jpg',
       imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/palmolive-optims-sobre-10ml.jpg',
       -- refuerzo por si el patch de pieza aún no corrió del todo
       precio = coalesce(nullif(precio, 0), 3),
       costo = coalesce(nullif(costo, 0), round((75.30 / 48)::numeric, 2))
 where sku = 'FC-EXP-OPT48'
    or codigo_barras = '7509546015699';

-- Galería: pieza primero, exhibidor después.
with p as (
  select id
    from public.productos
   where sku = 'FC-EXP-OPT48'
      or codigo_barras = '7509546015699'
   order by case when sku = 'FC-EXP-OPT48' then 0 else 1 end
   limit 1
)
update public.producto_imagenes gi
   set es_principal = false
  from p
 where gi.producto_id = p.id
   and gi.es_principal;

with p as (
  select id
    from public.productos
   where sku = 'FC-EXP-OPT48'
      or codigo_barras = '7509546015699'
   order by case when sku = 'FC-EXP-OPT48' then 0 else 1 end
   limit 1
),
fotos(url, storage_path, posicion, es_principal) as (
  values
    (
      'https://www.farmacapital.mx/catalogo-propia/palmolive-optims-sobre-10ml.jpg',
      'catalogo-propia/palmolive-optims-sobre-10ml.jpg',
      0,
      true
    ),
    (
      'https://www.farmacapital.mx/catalogo-propia/palmolive-optims-exhibidor-48.jpg',
      'catalogo-propia/palmolive-optims-exhibidor-48.jpg',
      1,
      false
    )
)
insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id, f.url, f.storage_path, f.posicion, f.es_principal, 'propia'
  from p
 cross join fotos f
on conflict (producto_id, url) do update
   set storage_path = excluded.storage_path,
       posicion = excluded.posicion,
       es_principal = excluded.es_principal,
       origen = excluded.origen;

-- Asegura una sola principal (la del sobre).
with p as (
  select id
    from public.productos
   where sku = 'FC-EXP-OPT48'
      or codigo_barras = '7509546015699'
   order by case when sku = 'FC-EXP-OPT48' then 0 else 1 end
   limit 1
)
update public.producto_imagenes gi
   set es_principal = (gi.url like '%palmolive-optims-sobre-10ml.jpg')
  from p
 where gi.producto_id = p.id;

commit;

select p.sku, left(p.nombre, 48) as nombre, p.codigo_barras as ean,
       p.costo, p.precio, p.imagen_url,
       round(((p.precio - p.costo) / nullif(p.precio, 0)) * 100, 1) as margen_pct
  from public.productos p
 where p.sku = 'FC-EXP-OPT48'
    or p.codigo_barras = '7509546015699';
