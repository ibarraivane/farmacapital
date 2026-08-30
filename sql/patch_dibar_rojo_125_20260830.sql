-- ============================================================================
-- Alcohol Dibar ROJO 96° 125 ml — la foto de mostrador era esta talla,
-- no la de 500 ml (id 340).
--
-- DESPUÉS del deploy de Vercel (public/catalogo-propia/dibar-rojo-125ml.jpg).
-- No toca stock, caducidad ni activo. El POS no cambia.
-- ============================================================================

begin;

-- Quitar la foto del 500 ml rojo (SKU equivocado)
update public.productos
   set imagen_url = null,
       imagen_mobile_url = null
 where id = 340
   and sku = 'FC-68990023'
   and imagen_url like '%dibar-rojo-500ml.jpg';

delete from public.producto_imagenes
 where producto_id = 340
   and url like '%dibar-rojo-500ml.jpg';

-- Ponerla en el 125 ml rojo
update public.productos
   set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/dibar-rojo-125ml.jpg',
       imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/dibar-rojo-125ml.jpg'
 where id = 337
   and sku = 'FC-68900264';

update public.producto_imagenes
   set es_principal = false
 where producto_id = 337
   and es_principal;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select 337,
       'https://www.farmacapital.mx/catalogo-propia/dibar-rojo-125ml.jpg',
       'catalogo-propia/dibar-rojo-125ml.jpg',
       coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = 337), 0) + 1,
       true,
       'propia'
where not exists (
  select 1 from public.producto_imagenes
   where producto_id = 337
     and url = 'https://www.farmacapital.mx/catalogo-propia/dibar-rojo-125ml.jpg'
);

update public.producto_imagenes
   set es_principal = true
 where producto_id = 337
   and url = 'https://www.farmacapital.mx/catalogo-propia/dibar-rojo-125ml.jpg';

commit;

select id, sku, nombre, presentacion, imagen_url
  from public.productos
 where id in (337, 340)
 order by id;
