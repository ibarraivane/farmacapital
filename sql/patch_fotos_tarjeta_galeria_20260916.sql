-- Tarjeta de categoría vs ficha (16-sep-2026)
-- La rejilla usa solo es_principal. En 54 productos esa URL es
-- catalogo-propia/… que aún no está en el CDN (Vercel sirve index.html
-- y la tarjeta muestra la caja vacía). Al entrar, la ficha carga toda
-- la galería (Rappi) y sí se ve el packshot.
--
-- Este parche pone como principal + imagen_url la primera foto de
-- galería que YA carga. Se ve al pegar, sin esperar Vercel.
-- El código de tienda también prueba la galería si la principal falla.
--
-- Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temporary table tmp_foto_tarjeta (
  sku text,
  ean text,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_tarjeta (sku, ean, url, origen)
values
  ('FC-93037806', '7791293037806', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7791293037806/1.png', 'rappi'),
  ('FC-93025919', '7791293025919', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7791293025919/1.jpg', 'rappi'),
  ('FC-93022567', '7791293022567', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7791293022567/1.jpg', 'rappi'),
  ('FC-75076009', '75076009', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/75076009/1.jpg', 'rappi'),
  ('FC-93025797', '7791293025797', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7791293025797/1.jpg', 'rappi'),
  ('FC-93038223', '7791293038223', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7791293038223/1.png', 'rappi'),
  ('FC-75062897', '75062897', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/75062897/1.png', 'rappi'),
  ('FC-93025865', '7791293025865', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7791293025865/1.jpg', 'rappi'),
  ('FC-75062927', '75062927', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/75062927/1.png', 'rappi'),
  ('FC-75069223', '75069223', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/75082819/1.jpg', 'rappi'),
  ('FC-75001865', '75001865', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/75001865/1.jpg', 'rappi'),
  ('FC-42270027', '42270027', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/42270027/1.jpg', 'rappi'),
  ('FC-09498091', '7896009498091', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7896009498091/1.jpg', 'rappi'),
  ('FC-31976394', '7702031976394', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7702031976394/1.jpg', 'rappi'),
  ('FC-31887928', '7702031887928', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7702031887928/1.jpg', 'rappi'),
  ('FC-10974329', '7891010974329', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7891010974329/1.jpg', 'rappi'),
  ('FC-40171550', '7794640171550', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7794640171550/1.jpg', 'rappi'),
  ('FC-16800803', '7501943474994', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501943474895/1.jpg', 'rappi'),
  ('FC-98223704', '7501298223704', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501298223704/1.jpg', 'rappi'),
  ('FC-23273451', '7506022327338', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7506022326737/1.jpg', 'rappi'),
  ('FC-23272151', '7506022327208', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7506022300782/1.jpg', 'rappi'),
  ('FC-08443026', '7501008443026', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501008443026/1.png', 'rappi'),
  ('FC-98217659', '7501298217659', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501298217659/1.jpg', 'rappi'),
  ('FC-73629981', '7501017362998', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501017362998/1.png', 'rappi'),
  ('FC-50608272', '75029650608272', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/785811314606/1.jpg', 'rappi'),
  ('FC-80596011', '3664798059601', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/3664798059601/1.jpg', 'rappi'),
  ('FC-00721471', '6502400721471', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/650240072147/1.png', 'rappi'),
  ('FC-54558682', '7501054558682', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/4005808802838/1.png', 'rappi'),
  ('FC-8062229', '3664798062229', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/3664798062229/1.jpg', 'rappi'),
  ('FC-8497593', '7501008497593', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501008497593/1.png', 'rappi'),
  ('FC-00753067', '020800753067', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/020800753067/1.jpg', 'rappi'),
  ('FC-053610', '650240053610', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/650240053634/1.png', 'rappi'),
  ('FC-7048853', '7891317048853', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7891317048822/1.jpg', 'rappi'),
  ('FC-007206', '6910021007206', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/6910021007206/1.png', 'rappi'),
  ('FC-03476594', '7702003476594', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7702003476594/1.jpg', 'rappi'),
  ('FC-42003469', '070942003469', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/070942003469/1.png', 'rappi'),
  ('FC-42303194', '070942303194', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/070942303194/1.jpg', 'rappi'),
  ('FC-42507240', '070942507240', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/070942507240/1.png', 'rappi'),
  ('FC-103521', '7501537103521', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7506375209206/1.jpg', 'rappi'),
  ('FC-50003314', '714706800900', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/714706800900/1.jpg', 'rappi'),
  ('FC-22300775', '7506022300775', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7506022300751/1.png', 'rappi'),
  ('EQ-AMS234', null, 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501349022935/1.jpg', 'rappi'),
  ('FC-30042152', '7501300421524', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501300421524/1.jpg', 'rappi'),
  ('FC-79807468', '3664798074680', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/3664798044591/1.jpg', 'rappi'),
  ('FC-28951141', '7501289511414', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501289511414/1.jpg', 'rappi'),
  ('FC-51037878', '7891051037878', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7891051037878/1.jpg', 'rappi'),
  ('FC-08006033', '020800600330', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/020800600330/1.jpg', 'rappi'),
  ('FC-43454743', '7501943454743', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501943454743/1.png', 'rappi'),
  ('FC-46504569', '7501846504569', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501846504569/1.jpg', 'rappi'),
  ('FC-46506181', '7501846506181', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501846506181/1.jpg', 'rappi'),
  ('FC-46501100', '7501846501100', 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501846501100/1.png', 'rappi'),
  ('FC-LV-SKITTLES24', '7502226816944', 'https://production-media.fahorro.com/media/catalog/product/7/5/7502226816944_1.jpg', 'distribuidor');

create temporary table tmp_foto_tarjeta_match (
  producto_id bigint primary key,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_tarjeta_match (producto_id, url, origen)
select distinct on (p.id)
  p.id,
  m.url,
  m.origen
from public.productos p
join tmp_foto_tarjeta m
  on (
    (m.sku is not null and p.sku = m.sku)
    or (m.ean is not null and nullif(btrim(p.codigo_barras), '') = m.ean)
  )
order by p.id, m.url;

update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_tarjeta_match m
where p.id = m.producto_id;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  m.producto_id,
  m.url,
  null,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = m.producto_id), 0) + 1,
  false,
  m.origen
from tmp_foto_tarjeta_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_tarjeta_match)
  and i.es_principal
  and i.url not in (
    select m.url from tmp_foto_tarjeta_match m where m.producto_id = i.producto_id
  );

update public.producto_imagenes i
set posicion = (
  select coalesce(max(x.posicion), 0) + 1
  from public.producto_imagenes x
  where x.producto_id = i.producto_id
)
where i.producto_id in (select producto_id from tmp_foto_tarjeta_match)
  and i.posicion = 0
  and i.url not in (
    select m.url from tmp_foto_tarjeta_match m where m.producto_id = i.producto_id
  );

update public.producto_imagenes i
set es_principal = true,
    posicion = 0
where i.producto_id in (select producto_id from tmp_foto_tarjeta_match)
  and i.url in (
    select m.url from tmp_foto_tarjeta_match m where m.producto_id = i.producto_id
  );

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  left(p.imagen_url, 96) as foto
from public.productos p
join tmp_foto_tarjeta_match m on m.producto_id = p.id
order by p.sku;

commit;
