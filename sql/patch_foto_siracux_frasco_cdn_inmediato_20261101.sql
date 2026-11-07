-- ============================================================================
-- HOTFIX foto Siracux Adulto — packshot del FRASCO (no la caja)
-- 2026-11-01
--
-- Problema: el POS usaba imagen_url de Rappi (caja blanca/azul). En
-- mostrador tienen el frasco azul Maver y no lo reconocían en pantalla.
--
-- Fuente: packshot Sufarmed del mismo EAN 7502009745393 (frasco 120 mL,
-- Adulto, oxeladina/ambroxol). No es la foto del celular del mostrador.
--
-- Pegar TODO en Supabase → SQL Editor → Run. Sale YA, sin esperar merge.
-- Después del deploy de catalogo-propia, correr:
--   sql/patch_foto_siracux_catalogo_propia_20261101.sql
-- ============================================================================

begin;

update public.productos
set
  imagen_url = 'https://sufarmed.com/sufarmed/1420-thickbox_default/siracux-adto-jbe-200-225-g-fco-120-ml.jpg',
  imagen_mobile_url = 'https://sufarmed.com/sufarmed/1420-thickbox_default/siracux-adto-jbe-200-225-g-fco-120-ml.jpg'
where id = 850
   or sku = 'FC-09745393'
   or codigo_barras = '7502009745393';

-- Galería: dejar solo el frasco como principal
delete from public.producto_imagenes i
using public.productos p
where i.producto_id = p.id
  and (
    p.id = 850
    or p.sku = 'FC-09745393'
    or p.codigo_barras = '7502009745393'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  'https://sufarmed.com/sufarmed/1420-thickbox_default/siracux-adto-jbe-200-225-g-fco-120-ml.jpg',
  null,
  1,
  true,
  'distribuidor'
from public.productos p
where p.id = 850
   or p.sku = 'FC-09745393'
   or p.codigo_barras = '7502009745393';

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.stock,
  left(p.imagen_url, 100) as foto,
  (
    select count(*) from public.producto_imagenes i where i.producto_id = p.id
  ) as fotos_galeria
from public.productos p
where p.id = 850
   or p.sku = 'FC-09745393'
   or p.codigo_barras = '7502009745393';
