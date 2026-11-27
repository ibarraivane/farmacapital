-- ============================================================================
-- Foto Siracux Adulto → catalogo-propia (tras deploy de Vercel)
-- 2026-11-01
--
-- Archivo:
--   public/catalogo-propia/siracux-adulto-oxeladina-ambroxol-120ml-7502009745393.jpg
-- Fuente: packshot Sufarmed EAN 7502009745393 (frasco azul Adulto 120 mL).
-- Corre DESPUÉS del merge/deploy. Sustituye el hotlink Sufarmed del hotfix.
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/siracux-adulto-oxeladina-ambroxol-120ml-7502009745393.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/siracux-adulto-oxeladina-ambroxol-120ml-7502009745393.jpg'
where (
    id = 850
    or sku = 'FC-09745393'
    or codigo_barras = '7502009745393'
  )
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/siracux-adulto-oxeladina-ambroxol-120ml-7502009745393%'
  );

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
  'https://www.farmacapital.mx/catalogo-propia/siracux-adulto-oxeladina-ambroxol-120ml-7502009745393.jpg',
  null,
  1,
  true,
  'propia'
from public.productos p
where p.id = 850
   or p.sku = 'FC-09745393'
   or p.codigo_barras = '7502009745393';

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  left(p.imagen_url, 120) as foto
from public.productos p
where p.id = 850
   or p.sku = 'FC-09745393'
   or p.codigo_barras = '7502009745393';
