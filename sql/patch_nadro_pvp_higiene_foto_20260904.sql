-- Nadro 20260901: higiene de la foto sin PVP.
-- El alta solo actualizó costo en los que ya existían; el precio quedó en 0.
-- Márgen marca 25% sobre venta (mismo criterio del ticket).
-- Idempotente. Supabase → SQL Editor → Run.

begin;

create temporary table _fc_nadro_pvp_higiene (
  ean text primary key,
  sku text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  imagen text
) on commit drop;

insert into _fc_nadro_pvp_higiene
  (ean, sku, nombre, marca, presentacion, costo, precio, imagen)
values
  (
    '7506309873701', 'FC-09873701',
    'Pantene Rizos Definidos 2 en 1 100 ml',
    'Pantene', '100 ml', 17.56, 24,
    'https://www.farmacapital.mx/catalogo-propia/pantene-rizos-definidos-2en1-100ml.jpg'
  ),
  (
    '7506306256026', 'FC-06256026',
    'Dove Derma Care Hydra Alivio acondicionador 400 ml',
    'Dove', '400 ml', 56.91, 76,
    'https://www.farmacapital.mx/catalogo-propia/dove-derma-hydra-alivio-acond-400ml.jpg'
  ),
  (
    '7506306223134', 'FC-06223134',
    'Sedal Liso Perfecto acondicionador 300 ml',
    'Sedal', '300 ml', 38.48, 52,
    'https://www.farmacapital.mx/catalogo-propia/sedal-liso-perfecto-acond-300ml.jpg'
  ),
  (
    '7501022150818', 'FC-22150818',
    'Jabón Grisi Concha Nácar 125 g',
    'Grisi', '125 g', 22.92, 31,
    'https://www.farmacapital.mx/catalogo-propia/grisi-concha-nacar-jabon-125g.jpg'
  ),
  (
    '037836051227', 'FC-36051227',
    'Jabón líquido Grisi Concha Nácar 450 ml',
    'Grisi', '450 ml', 55.31, 74,
    'https://www.farmacapital.mx/catalogo-propia/grisi-concha-nacar-liq-450ml.jpg'
  ),
  (
    '7501022105191', 'FC-22105191',
    'Jabón Grisi Neutro 100 g',
    'Grisi', '100 g', 16.24, 22,
    'https://www.farmacapital.mx/catalogo-propia/grisi-neutro-jabon-100g.jpg'
  ),
  (
    '037836050282', 'FC-36050282',
    'Jabón líquido Grisi Neutro 450 ml',
    'Grisi', '450 ml', 55.31, 74,
    'https://www.farmacapital.mx/catalogo-propia/grisi-neutro-liq-450ml.jpg'
  );

-- Alta por si algún EAN no llegó a catálogo.
insert into public.productos (
  nombre, sku, codigo_barras, marca, presentacion, categoria, tipo,
  descripcion, costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.marca,
  t.presentacion,
  'Cuidado personal',
  'marca',
  'PVP Nadro 20260901 · higiene foto mostrador',
  t.costo,
  t.precio,
  t.imagen,
  t.imagen,
  0,
  1,
  true,
  false
from _fc_nadro_pvp_higiene t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Precio + costo + ficha (sí pisa PVP 0 / viejo).
update public.productos p
set
  costo = t.costo,
  precio = t.precio,
  nombre = t.nombre,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  categoria = coalesce(nullif(trim(p.categoria), ''), 'Cuidado personal'),
  tipo = coalesce(nullif(trim(p.tipo), ''), 'marca')
from _fc_nadro_pvp_higiene t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

commit;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  p.costo,
  p.precio,
  round(((p.precio - p.costo) / nullif(p.precio, 0)) * 100, 1) as margen_pct,
  left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
  '7506309873701',
  '7506306256026',
  '7506306223134',
  '7501022150818',
  '037836051227',
  '7501022105191',
  '037836050282'
)
order by p.nombre;
