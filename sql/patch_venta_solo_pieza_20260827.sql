-- FarmaCapital — productos que se venden sueltos, no por caja.
-- El flag venta_unidad les abría "Caja $X" + "1 unidad $Y" cuando
-- el precio de caja era casi el de una pieza (pote Jaloma, chupón,
-- jeringa C/1). No toca cajas reales (Alka-Seltzer, Dolo C/3, Saba).
-- No inventa caducidad: solo ajusta cantidades y el modo de venta.

begin;

-- Jaloma pomada labios: pote exhibidor de 60, se cobra $6 la pieza.
update public.lotes
   set cantidad_actual = 60,
       costo_unitario = round((10.5 / 60)::numeric, 4)
 where id = 858
   and producto_id = 733
   and cantidad_actual = 1;

update public.productos
   set venta_unidad = false,
       unidades_por_caja = 0,
       precio_unidad = 0,
       stock_unidades = 0,
       precio = 6
 where id = 733
   and sku = 'FC-4391156';

-- Chupón Ternura: 18 pzas, $6 c/u.
update public.lotes
   set cantidad_actual = 18,
       costo_unitario = round((61.02 / 18)::numeric, 4)
 where id = 419
   and producto_id = 283
   and cantidad_actual = 1;

update public.productos
   set venta_unidad = false,
       unidades_por_caja = 0,
       precio_unidad = 0,
       stock_unidades = 0,
       precio = 6
 where id = 283
   and sku = 'FC-26462078';

-- Aguja SensiMedical C/1: se vende la aguja, no la caja de 100.
update public.lotes
   set cantidad_actual = 100
 where id = 1356
   and producto_id = 1121
   and cantidad_actual = 1;

update public.productos
   set venta_unidad = false,
       unidades_por_caja = 0,
       precio_unidad = 0,
       stock_unidades = 0,
       precio = 1
 where id = 1121
   and sku = 'FMX-504321';

-- Jeringa insulina 1 mL: 99 piezas a $6.
update public.lotes
   set cantidad_actual = 99
 where id = 1373
   and producto_id = 1135
   and cantidad_actual = 1;

update public.productos
   set venta_unidad = false,
       unidades_por_caja = 0,
       precio_unidad = 0,
       stock_unidades = 0,
       precio = 6
 where id = 1135
   and sku = 'FC-22300881';

-- Jeringa 20 mL: reintegro activo, 50 piezas a $6. No toca fecha.
update public.lotes
   set cantidad_actual = 50
 where id = 1538
   and producto_id = 1138
   and cantidad_actual = 1;

update public.productos
   set venta_unidad = false,
       unidades_por_caja = 0,
       precio_unidad = 0,
       stock_unidades = 0,
       precio = 6
 where id = 1138
   and sku = 'FMX-307658';

-- Jeringa 5 mL: 97 piezas a $3.
update public.lotes
   set cantidad_actual = 97
 where id = 1377
   and producto_id = 1139
   and cantidad_actual = 1;

update public.productos
   set venta_unidad = false,
       unidades_por_caja = 0,
       precio_unidad = 0,
       stock_unidades = 0,
       precio = 3
 where id = 1139
   and sku = 'FMX-506389';

-- Quirmex venda: 12 rollos, se cobra $6 el rollo (no caja de 12).
update public.productos
   set venta_unidad = false,
       unidades_por_caja = 0,
       precio_unidad = 0,
       stock_unidades = 0,
       precio = 6
 where id = 374
   and sku = 'FC-3406723';

commit;

select id, sku, nombre, precio, venta_unidad, unidades_por_caja, stock, stock_unidades
  from public.productos
 where id in (733, 283, 1121, 1135, 1138, 1139, 374)
 order by id;
