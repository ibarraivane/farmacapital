-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivos:
--   public/catalogo-propia/dove-tono-uniforme-calendula-150ml.jpg
--   public/catalogo-propia/lysol-crisp-linen-354g.jpg
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/dove-tono-uniforme-calendula-150ml.jpg'
where (codigo_barras = '7506306241152' or sku in ('FC-06241152', 'FC-ND-06241152'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/dove-tono-uniforme-calendula%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/lysol-crisp-linen-354g.jpg'
where (codigo_barras = '7501058796882' or sku in ('FC-58796882', 'FC-ND-58796882'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/lysol-crisp-linen-354g%'
  );

-- Galería principal si la tabla existe y no hay esa URL
insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/dove-tono-uniforme-calendula-150ml.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7506306241152' or p.sku in ('FC-06241152', 'FC-ND-06241152'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/dove-tono-uniforme-calendula%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/lysol-crisp-linen-354g.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501058796882' or p.sku in ('FC-58796882', 'FC-ND-58796882'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/lysol-crisp-linen-354g%'
  );

commit;

select
  sku,
  codigo_barras,
  nombre,
  left(coalesce(imagen_url, ''), 100) as imagen
from public.productos
where codigo_barras in ('7506306241152', '7501058796882')
   or sku in ('FC-06241152', 'FC-58796882', 'FC-ND-06241152', 'FC-ND-58796882')
order by nombre;
