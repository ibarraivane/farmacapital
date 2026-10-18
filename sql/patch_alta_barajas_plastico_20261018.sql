-- Barajas de plástico · 18-oct-2026
-- Dos cajas distintas, 4 piezas cada una. Costo $25. Venta $45.
-- Naipe española Good Luck, EAN 6922698031286, SKU FC-98031286.
-- Baraja póker: la caja no trae código. SKU FC-1792288033226.
-- Lote S/L, sin caducidad. El stock lo deja el lote (4).
-- Idempotente: si el SKU ya está, no suma otras 4.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

select x.*
from (
  select 1
  where not exists (
    select 1 from public.productos
    where codigo_barras = '6922698031286'
       or sku = 'FC-98031286'
  )
) g
cross join lateral public.create_producto_with_lote(
  jsonb_build_object(
    'nombre', 'Naipe española',
    'sku', 'FC-98031286',
    'codigo_barras', '6922698031286',
    'categoria', 'Minisuper',
    'tipo', 'marca',
    'descripcion', 'Alta 18-oct-2026. Caja negra Good Luck. 4 piezas a costo 25 y venta 45.',
    'costo', 25,
    'precio', 45,
    'stock_minimo', 1,
    'activo', true,
    'requiere_receta', false,
    'marca', 'Good Luck',
    'presentacion', 'Baraja 100% plástico'
  ),
  4,
  'S/L',
  null::date,
  25,
  null::bigint
) x;

select x.*
from (
  select 1
  where not exists (
    select 1 from public.productos
    where sku = 'FC-1792288033226'
  )
) g
cross join lateral public.create_producto_with_lote(
  jsonb_build_object(
    'nombre', 'Baraja póker',
    'sku', 'FC-1792288033226',
    'categoria', 'Minisuper',
    'tipo', 'generico',
    'descripcion', 'Alta 18-oct-2026. Caja amarilla, liston Plastico y Poker. Sin codigo en la foto. 4 piezas a costo 25 y venta 45.',
    'costo', 25,
    'precio', 45,
    'stock_minimo', 1,
    'activo', true,
    'requiere_receta', false,
    'presentacion', 'Plástico'
  ),
  4,
  'S/L',
  null::date,
  25,
  null::bigint
) x;

update public.productos
set
  marca = coalesce(nullif(trim(marca), ''), 'Good Luck'),
  presentacion = coalesce(nullif(trim(presentacion), ''), 'Baraja 100% plástico'),
  categoria = coalesce(nullif(trim(categoria), ''), 'Minisuper'),
  imagen_url = coalesce(
    nullif(trim(imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/naipe-espanola-good-luck-6922698031286.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(trim(imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/naipe-espanola-good-luck-6922698031286.jpg'
  )
where codigo_barras = '6922698031286'
   or sku = 'FC-98031286';

update public.productos
set
  presentacion = coalesce(nullif(trim(presentacion), ''), 'Plástico'),
  categoria = coalesce(nullif(trim(categoria), ''), 'Minisuper'),
  imagen_url = coalesce(
    nullif(trim(imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/baraja-poker-plastico.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(trim(imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/baraja-poker-plastico.jpg'
  )
where sku = 'FC-1792288033226';

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  p.imagen_url,
  case
    when p.sku = 'FC-98031286' then 'catalogo-propia/naipe-espanola-good-luck-6922698031286.jpg'
    else 'catalogo-propia/baraja-poker-plastico.jpg'
  end,
  1,
  true,
  'propia'
from public.productos p
where p.sku in ('FC-98031286', 'FC-1792288033226')
  and coalesce(p.imagen_url, '') <> ''
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url = p.imagen_url
  );

select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  l.numero_lote,
  l.cantidad_actual,
  l.fecha_caducidad
from public.productos p
left join public.lotes l
  on l.producto_id = p.id
 and coalesce(l.activo, true)
where p.sku in ('FC-98031286', 'FC-1792288033226')
   or p.codigo_barras = '6922698031286'
order by p.sku;

commit;
