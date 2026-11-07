-- =============================================================================
-- PEGAR SOLO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Pharmaton Complete Kids jarabe 100 ml · EAN 3664798064704 · SKU FC-98064704
--
-- Piezas físicas 2 (caja + frasco suelto). Mismo producto:
--   - Caja con barras 3664798064704
--   - Frasco sin barras: «No etiquetado para su venta individual»
--   - Mismo lote 5KLP98DR · cad 05.2027 → 2027-05-31
--
-- PVP ancla $312 (Nadro precio público $311.60). Sin costo de compra.
-- Si ya estaba en vitrina bajo pedido: baja de bajo_pedido y recibe stock.
-- Sin do $$. Sin producto_imagenes en este txn.
-- Foto propia tras deploy: patch_fotos_pharmaton_complete_kids_3664798064704.sql
-- =============================================================================

-- 0) Estado actual
select
  'ANTES' as momento,
  p.id,
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 50) as nombre,
  p.precio,
  p.stock,
  p.bajo_pedido,
  left(coalesce(p.imagen_url, ''), 80) as imagen
from public.productos p
where p.codigo_barras = '3664798064704'
   or p.sku in ('FC-98064704', 'FC-ND-98064704')
order by p.id;

-- 1) Alta si no existe (stock 0; el lote se recibe abajo)
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica,
  principio_activo, concentracion, imagen_url, imagen_mobile_url, bajo_pedido
)
select
  'Pharmaton Complete Kids',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-98064704'
        and coalesce(p.codigo_barras, '') <> '3664798064704'
    ) then 'FC-ND-98064704'
    else 'FC-98064704'
  end,
  '3664798064704',
  'Vitaminas',
  'Multivitamínico / suplemento',
  'marca',
  'Alta mostrador 2026-11-07 · Opella/Sanofi · jarabe 100 ml con lisina + vitaminas y minerales · sabor frutas · niños >4 años · EAN caja 3664798064704 · frasco suelto sin barras (no etiquetado venta individual) · lote 5KLP98DR cad 05.2027 · PVP ancla Nadro $312 · sin costo de compra',
  null,
  312,
  0,
  1,
  true,
  false,
  'Pharmaton',
  'Opella',
  'Frasco 100 ml',
  'Jarabe',
  'Lisina + vitaminas y minerales',
  null,
  'https://nadro.vtexassets.com/arquivos/ids/218372/3664798064704_01.jpg',
  'https://nadro.vtexassets.com/arquivos/ids/218372/3664798064704_01.jpg',
  false
where not exists (
  select 1 from public.productos
  where codigo_barras = '3664798064704'
     or sku in ('FC-98064704', 'FC-ND-98064704')
);

-- 2) Ficha canónica (también si ya venía de vitrina bajo pedido)
update public.productos
set
  codigo_barras = '3664798064704',
  nombre = 'Pharmaton Complete Kids',
  marca = 'Pharmaton',
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Opella'),
  presentacion = 'Frasco 100 ml',
  forma_farmaceutica = 'Jarabe',
  principio_activo = 'Lisina + vitaminas y minerales',
  subcategoria = 'Multivitamínico / suplemento',
  categoria = 'Vitaminas',
  tipo = 'marca',
  requiere_receta = false,
  activo = true,
  stock_minimo = greatest(coalesce(stock_minimo, 0), 1),
  bajo_pedido = false,
  precio = case when coalesce(precio, 0) <= 1 then 312 else precio end,
  imagen_url = coalesce(
    nullif(btrim(imagen_url), ''),
    'https://nadro.vtexassets.com/arquivos/ids/218372/3664798064704_01.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(imagen_mobile_url), ''),
    'https://nadro.vtexassets.com/arquivos/ids/218372/3664798064704_01.jpg'
  ),
  descripcion = case
    when coalesce(btrim(descripcion), '') = ''
      or descripcion ilike '%bajo pedido%'
      or descripcion ilike '%nadro i22%'
    then 'Alta mostrador 2026-11-07 · Opella/Sanofi · jarabe 100 ml con lisina + vitaminas y minerales · sabor frutas · niños >4 años · EAN caja 3664798064704 · frasco suelto sin barras (no etiquetado venta individual) · lote 5KLP98DR cad 05.2027 · PVP ancla Nadro $312 · sin costo de compra'
    else descripcion
  end
where codigo_barras = '3664798064704'
   or sku in ('FC-98064704', 'FC-ND-98064704');

-- 3) Recibir lote 5KLP98DR ×2 si aún no está
select
  f.lote_id,
  f.stock_nuevo
from public.productos p
cross join lateral public.receive_merchandise_lote(
  p.id,
  2,
  '5KLP98DR',
  '2027-05-31'::date,
  null::numeric,
  null::text,
  null::bigint
) f
where (p.codigo_barras = '3664798064704' or p.sku in ('FC-98064704', 'FC-ND-98064704'))
  and not exists (
    select 1
    from public.lotes l
    where l.producto_id = p.id
      and l.numero_lote = '5KLP98DR'
      and coalesce(l.activo, true)
  );

-- 4) Sync stock desde lotes + salir de bajo pedido
update public.productos p
set
  stock = coalesce((
    select sum(l.cantidad_actual)
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
  ), 0),
  bajo_pedido = false
where p.codigo_barras = '3664798064704'
   or p.sku in ('FC-98064704', 'FC-ND-98064704');

-- 5) Verificación
select
  'DESPUES' as momento,
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.forma_farmaceutica,
  p.principio_activo,
  p.precio,
  p.costo,
  p.stock,
  p.bajo_pedido,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual,
  left(coalesce(p.imagen_url, ''), 100) as imagen
from public.productos p
left join public.lotes l
  on l.producto_id = p.id
 and coalesce(l.activo, true)
where p.codigo_barras = '3664798064704'
   or p.sku in ('FC-98064704', 'FC-ND-98064704')
order by p.id, l.id;
