-- F-42 84416 · Johnson's: EAN del ticket OCR era 7891010258699 (check digit MAL).
-- Caja real: 7891010258689 (Johnson's Baby shampoo fragancia prolongada).
-- VAL caja 01/28 → MMAA 0128 (no 0629).
-- No toca cantidad ni costo (1 × 87.02).

-- Producto
update public.productos
set
  codigo_barras = '7891010258689',
  sku = case
    when sku in ('FC-10258699', 'FC-10258689') then 'FC-10258689'
    else sku
  end,
  nombre = 'Johnson''s Baby shampoo fragancia prolongada 400 ml',
  marca = coalesce(nullif(btrim(marca), ''), 'Johnson''s'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Frasco 400 ml'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Shampoo')
where sku in ('FC-10258699', 'FC-10258689')
   or codigo_barras in ('7891010258699', '7891010258689')
   or nombre ilike '%Johnsons Kids 2 En 1 400%'
   or nombre ilike '%JOHNSONS KIDS 2 EN 1 400%';

-- Si quedó huérfano con SKU viejo y el nuevo ya existe, solo alinear barcode del viejo no:
-- Renombrar SKU solo si destino libre
update public.productos
set sku = 'FC-10258689'
where sku = 'FC-10258699'
  and codigo_barras = '7891010258689'
  and not exists (select 1 from public.productos p2 where p2.sku = 'FC-10258689' and p2.id <> productos.id);

-- Renglón Recibir F-42
update public.recepcion_items i
set
  codigo_escaneado = '7891010258689',
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo('7891010258689'),
    public.fc_buscar_producto_escaneo('FC-10258689'),
    public.fc_buscar_producto_escaneo('FC-10258699'),
    i.producto_id
  ),
  nombre_snapshot = 'Johnson''s Baby shampoo fragancia prolongada 400 ml',
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '84416'
  and r.estado = 'borrador'
  and (
    coalesce(i.codigo_escaneado, '') in ('7891010258699', '7891010258689', 'FC-10258699', 'FC-10258689')
    or i.nombre_snapshot ilike '%Kids 2 En 1 400%'
    or i.nombre_snapshot ilike '%JOHNSONS KIDS 2 EN 1%'
    or i.nombre_snapshot ilike '%fragancia prolongada%'
  );

select
  p.sku,
  p.codigo_barras,
  left(p.nombre, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.codigo_escaneado
from public.productos p
left join public.recepciones r
  on r.folio = '84416' and r.estado = 'borrador'
left join public.recepcion_items i
  on i.recepcion_id = r.id
 and (
   i.codigo_escaneado = '7891010258689'
   or i.producto_id = p.id
 )
where p.sku in ('FC-10258689', 'FC-10258699')
   or p.codigo_barras in ('7891010258689', '7891010258699');
