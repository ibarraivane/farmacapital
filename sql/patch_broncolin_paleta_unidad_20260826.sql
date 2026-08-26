-- FarmaCapital — Broncolin se vende suelta, no el bote.
-- YA APLICADO en producción vía API (26 ago 2026).
--
-- 1) Nombre y ficha: Broncolin Paleta, 10 g, $6.
-- 2) Stock: el bote abierto (48 pzas restantes) pasa a piezas.
-- 3) EAN de la paleta (747589705123). El del bote C/50 queda en descripción.
-- 4) Foto de la paleta como principal; el vitrolero queda de segunda.

begin;

update public.productos
   set nombre = 'Broncolin Paleta',
       denominacion_distintiva = 'Broncolin Paleta',
       presentacion = '1 paleta 10 g',
       forma_farmaceutica = 'Paleta',
       precio = 6,
       costo = 2.25,
       venta_unidad = false,
       unidades_por_caja = 0,
       precio_unidad = 0,
       stock_unidades = 0,
       codigo_barras = '747589705123',
       imagen_url = 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/702/paleta.png',
       imagen_mobile_url = 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/702/paleta.png',
       descripcion = 'Paleta Broncolin con miel de abeja y extractos herbales. Sabores mixtos, 10 g. Se vende suelta. EAN pieza 747589705123 · EAN bote C/50 714706903205.'
 where id = 702
   and sku = 'FC-06903205';

update public.lotes
   set cantidad_actual = 48,
       costo_unitario = 2.25
 where id = 827
   and producto_id = 702;

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas)
values
  (702, 'ultima_compra', 'compra', 2.25, current_date, 'Farmalive', 100, 'manual',
   'bote 112.70 / 50 paletas · se vende suelta');

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
values
  (702, 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/702/paleta.png',
   '702/paleta.png', 1, true, 'propia'),
  (702, 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/702/desktop.jpg',
   '702/desktop.jpg', 2, false, 'propia')
on conflict (producto_id, url) do update
   set posicion = excluded.posicion,
       es_principal = excluded.es_principal,
       storage_path = excluded.storage_path;

commit;

select sku, nombre, precio, costo, stock, codigo_barras, presentacion
  from public.productos where id = 702;
