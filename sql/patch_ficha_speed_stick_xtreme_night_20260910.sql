-- City Mark 20260905 renglón gris: DESOD SPEED S XTREM 48H CRA30G S N
-- EAN 7501033204920 = tubo de 30 g (no hay SKU aparte de “paquete”).
-- City Mark facturó 6 × $14.383 (inner S/6). Recibir se queda en 6 pzas.
--
-- Este patch:
--   1) Limpia ficha (nombre/marca/categoría/PVP). No toca stock ni MMAA.
--   2) Actualiza el snapshot del renglón gris para que Recibir no muestre
--      el código del ticket.
--
-- PVP $25 = ancla Fahorro / La Comer / Rappi (~$25.50). Costo City Mark $14.38.
-- EAN del tubo (foto mostrador): 7501033204920. Foto de la pieza en
-- public/catalogo-propia/speed-stick-xtreme-night-crema-30g.jpg
-- Fahorro mientras corre el deploy; después:
--   sql/patch_fotos_speed_stick_xtreme_night_20260910.sql
-- Idempotente. SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set
  nombre = 'Speed Stick Xtreme Night antitranspirante en crema 30 g',
  marca = 'Speed Stick',
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Colgate-Palmolive'),
  presentacion = 'Tubo 30 g',
  forma_farmaceutica = 'Crema',
  subcategoria = 'Desodorante',
  categoria = 'Higiene',
  tipo = 'marca',
  precio = 25.00,
  descripcion = 'Ficha Fahorro / Chedraui · EAN 7501033204920 · Speed Stick Xtreme Night crema 30 g · City Mark 20260905 6 pzas a $14.383 · PVP ancla Fahorro $25.50',
  imagen_url = case
    when imagen_url is null
      or btrim(imagen_url) = ''
      or imagen_url like '%DESOD SPEED%'
      then 'https://production-media.fahorro.com/media/catalog/product/7/5/7501033204920.jpg'
    else imagen_url
  end,
  activo = true
where codigo_barras = '7501033204920'
   or sku = 'FC-33204920';

update public.recepcion_items i
set nombre_snapshot = 'Speed Stick Xtreme Night crema 30 g'
from public.recepciones r
where r.id = i.recepcion_id
  and r.folio = '20260905'
  and coalesce(r.proveedor, '') ilike '%city mark%'
  and (
    i.codigo_escaneado = '7501033204920'
    or i.producto_id in (
      select p.id from public.productos p
      where p.codigo_barras = '7501033204920' or p.sku = 'FC-33204920'
    )
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.categoria,
  p.tipo,
  p.costo,
  p.precio,
  p.stock,
  p.imagen_url is not null as tiene_foto
from public.productos p
where p.codigo_barras = '7501033204920'
   or p.sku = 'FC-33204920';

select
  i.id,
  i.codigo_escaneado as ean,
  i.nombre_snapshot,
  i.cantidad,
  i.costo_estimado,
  i.confirmado,
  i.fecha_caducidad
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '20260905'
  and coalesce(r.proveedor, '') ilike '%city mark%'
  and i.codigo_escaneado = '7501033204920';
