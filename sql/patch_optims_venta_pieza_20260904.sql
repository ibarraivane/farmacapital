-- Palmolive Optims: se vende el sobre, no el exhibidor de 48.
-- EAN de la pieza (y del exhibidor en mayoreo): 7509546015699.
-- Costo Exprezo 75.30 / 48 = 1.57 · precio mostrador $3.
-- Idempotente: si ya tiene el EAN de pieza, no vuelve a multiplicar stock.

begin;

-- Lotes: 1 pack recibido → 48 sobres (solo si el producto aún figura como Pack).
update public.lotes l
   set cantidad_actual = case
         when coalesce(l.cantidad_actual, 0) between 1 and 5
              and p.nombre ilike '%Pack%48%'
           then l.cantidad_actual * 48
         else l.cantidad_actual
       end,
       costo_unitario = round((75.30 / 48)::numeric, 4)
  from public.productos p
 where l.producto_id = p.id
   and p.sku = 'FC-EXP-OPT48'
   and coalesce(p.codigo_barras, '') is distinct from '7509546015699';

update public.productos
   set nombre = 'Palmolive Optims Vital Keratina 2 en 1 sobre 10 ml',
       marca = 'Palmolive',
       presentacion = 'Sobre 10 ml',
       forma_farmaceutica = 'Sobre',
       categoria = 'Cuidado personal',
       tipo = 'marca',
       codigo_barras = '7509546015699',
       precio = 3,
       costo = round((75.30 / 48)::numeric, 2),
       venta_unidad = false,
       unidades_por_caja = 0,
       precio_unidad = 0,
       stock_unidades = 0,
       stock = case
         when coalesce(codigo_barras, '') is distinct from '7509546015699'
              and nombre ilike '%Pack%48%'
              and coalesce(stock, 0) between 1 and 5
           then stock * 48
         else stock
       end,
       descripcion = 'Sobre Palmolive Optims Vital Keratina shampoo 2 en 1 nivel 4, 10 ml. Se vende el sobre (no el exhibidor). Exhibidor 48 sobres · al recibir pack cargar 48 pzas (costo pack÷48). EAN pieza/exhibidor 7509546015699. Ticket Exprezo: Pack 48 sobres Shampoo Palmolive Optims 10 ml.'
 where sku = 'FC-EXP-OPT48';

-- Si el EAN ya estaba en otro SKU vacío/duplicado, no fallar en silencio:
-- el unique de codigo_barras lo reportaría; aquí solo tocamos FC-EXP-OPT48.

commit;

select sku, left(nombre, 56) as nombre, codigo_barras as ean,
       costo, precio, stock, venta_unidad, presentacion
  from public.productos
 where sku = 'FC-EXP-OPT48'
    or codigo_barras = '7509546015699';
