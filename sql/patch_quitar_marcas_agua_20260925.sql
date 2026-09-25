-- Quita del inventario las fotos con marca de agua «Mayoreo Farmacéutico».
--
-- Revisadas el 25 sep 2026: las 592 de public/catalogo-propia/, las
-- portadas (Shopify, Storage, Firebase, VTEX, Fahorro) y la galería
-- que no es portada. Marca de agua legible:
--   · Cintapore piel 1.25 y 2.5 (Mayoreo Farmacéutico), es la portada.
--   · Cetilver gel, foto vieja de Rappi (GENDIFAR repetido). La
--     portada de catalogo-propia se queda.
-- Cintapore se queda sin foto. Cetilver conserva la portada limpia.
--
-- Pegar en el SQL editor. Idempotente.
-- Los JPG se borran del repo en el mismo cambio. Si este SQL corre
-- primero, la ficha deja de apuntar a la foto mientras el archivo
-- viejo sigue en el deploy actual.

begin;

update public.productos
set
  imagen_url = null,
  imagen_mobile_url = null,
  updated_at = now()
where sku in ('FMX-301139', 'FC-84500546')
  and (
    coalesce(imagen_url, '') like '%cintapore-piel-%'
    or coalesce(imagen_mobile_url, '') like '%cintapore-piel-%'
  );

delete from public.producto_imagenes i
using public.productos p
where i.producto_id = p.id
  and p.sku in ('FMX-301139', 'FC-84500546')
  and i.url like '%cintapore-piel-%';

-- Cetilver (EQ-MAV392): la portada limpia se queda.
-- La foto vieja de Rappi repite «GENDIFAR» en el fondo.
delete from public.producto_imagenes
where url = 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7502009748448/1.webp';

-- Tiene que devolver las dos filas con imagen vacía.
select id, sku, nombre, imagen_url
from public.productos
where sku in ('FMX-301139', 'FC-84500546')
order by sku;

commit;
