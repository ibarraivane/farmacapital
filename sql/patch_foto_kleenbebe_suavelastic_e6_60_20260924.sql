-- Foto catalogo-propia · correr DESPUÉS del deploy de Vercel.
-- Archivo:
--   public/catalogo-propia/kleenbebe-suavelastic-etapa6-xj-60-7501943414235.jpg
-- Packshot del frente, mismo EAN 7501943414235 (60 pañales, etapa 6).
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-etapa6-xj-60-7501943414235.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-etapa6-xj-60-7501943414235.jpg'
where (codigo_barras = '7501943414235' or sku in ('FC-43414235', 'FC-ND-43414235'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/kleenbebe-suavelastic-etapa6-xj-60%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-etapa6-xj-60-7501943414235.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501943414235' or p.sku in ('FC-43414235', 'FC-ND-43414235'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/kleenbebe-suavelastic-etapa6-xj-60%'
  );

commit;

select
  sku,
  codigo_barras,
  nombre,
  left(coalesce(imagen_url, ''), 120) as imagen
from public.productos
where codigo_barras = '7501943414235'
   or sku in ('FC-43414235', 'FC-ND-43414235');
