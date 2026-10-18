-- Vanart Veinte y Teatrical células madre · Señora Yolanda · 18-oct-2026
-- No estaban en el catálogo. 5 piezas de cada uno. Costo $18.
-- Venta $23 = techo de costo x 1.25 (marca).
-- El código de la etiqueta es de 12 dígitos. En catálogo queda el de 13,
-- igual que el resto de Genomma (6502400…). La pistola acepta los dos.
-- Caducidad: último día del mes impreso. Lote de la botella.
-- Idempotente: si el SKU ya está, no suma otras 5.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

select x.*
from (
  select 1
  where not exists (
    select 1 from public.productos
    where codigo_barras in ('6502400078552', '650240078552')
       or sku = 'FC-00078552'
  )
) g
cross join lateral public.create_producto_with_lote(
  jsonb_build_object(
    'nombre', 'Vanart Veinte',
    'sku', 'FC-00078552',
    'codigo_barras', '6502400078552',
    'categoria', 'Higiene',
    'tipo', 'marca',
    'descripcion', 'Senora Yolanda 18-oct-2026. Shampoo Veinte, 5 beneficios, frasco 180 mL. 5 piezas a costo 18. Etiqueta 650240078552. Lote 5268000405, caduca sep 2027.',
    'costo', 18,
    'precio', 23,
    'stock_minimo', 1,
    'activo', true,
    'requiere_receta', false,
    'marca', 'Vanart',
    'presentacion', 'Frasco 180 mL',
    'forma_farmaceutica', 'Shampoo',
    'laboratorio', 'Genomma Lab'
  ),
  5,
  '5268000405',
  '2027-09-30'::date,
  18,
  null::bigint
) x;

select x.*
from (
  select 1
  where not exists (
    select 1 from public.productos
    where codigo_barras in ('6502400032202', '650240032202')
       or sku = 'FC-00032202'
  )
) g
cross join lateral public.create_producto_with_lote(
  jsonb_build_object(
    'nombre', 'Teatrical células madre',
    'sku', 'FC-00032202',
    'codigo_barras', '6502400032202',
    'categoria', 'Cuidado personal',
    'tipo', 'marca',
    'descripcion', 'Senora Yolanda 18-oct-2026. Crema corporal humectante, células madre, frasco 75 mL. 5 piezas a costo 18. Etiqueta 650240032202. Lote 6133010505, caduca may 2028.',
    'costo', 18,
    'precio', 23,
    'stock_minimo', 1,
    'activo', true,
    'requiere_receta', false,
    'marca', 'Teatrical',
    'presentacion', 'Frasco 75 mL',
    'forma_farmaceutica', 'Crema',
    'laboratorio', 'Genomma Lab'
  ),
  5,
  '6133010505',
  '2028-05-31'::date,
  18,
  null::bigint
) x;

update public.productos
set
  marca = coalesce(nullif(trim(marca), ''), 'Vanart'),
  presentacion = coalesce(nullif(trim(presentacion), ''), 'Frasco 180 mL'),
  forma_farmaceutica = coalesce(nullif(trim(forma_farmaceutica), ''), 'Shampoo'),
  laboratorio = coalesce(nullif(trim(laboratorio), ''), 'Genomma Lab'),
  categoria = coalesce(nullif(trim(categoria), ''), 'Higiene'),
  imagen_url = coalesce(
    nullif(trim(imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/vanart-veinte-shampoo-180ml-6502400078552.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(trim(imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/vanart-veinte-shampoo-180ml-6502400078552.jpg'
  )
where sku = 'FC-00078552'
   or codigo_barras in ('6502400078552', '650240078552');

update public.productos
set
  marca = coalesce(nullif(trim(marca), ''), 'Teatrical'),
  presentacion = coalesce(nullif(trim(presentacion), ''), 'Frasco 75 mL'),
  forma_farmaceutica = coalesce(nullif(trim(forma_farmaceutica), ''), 'Crema'),
  laboratorio = coalesce(nullif(trim(laboratorio), ''), 'Genomma Lab'),
  categoria = coalesce(nullif(trim(categoria), ''), 'Cuidado personal'),
  imagen_url = coalesce(
    nullif(trim(imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/teatrical-celulas-madre-75ml-6502400032202.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(trim(imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/teatrical-celulas-madre-75ml-6502400032202.jpg'
  )
where sku = 'FC-00032202'
   or codigo_barras in ('6502400032202', '650240032202');

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  p.imagen_url,
  case
    when p.sku = 'FC-00078552' then 'catalogo-propia/vanart-veinte-shampoo-180ml-6502400078552.jpg'
    else 'catalogo-propia/teatrical-celulas-madre-75ml-6502400032202.jpg'
  end,
  1,
  true,
  'propia'
from public.productos p
where p.sku in ('FC-00078552', 'FC-00032202')
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
where p.sku in ('FC-00078552', 'FC-00032202')
   or p.codigo_barras in ('6502400078552', '6502400032202', '650240078552', '650240032202')
order by p.sku;

commit;
