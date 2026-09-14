-- NO SUBIR costos. La versión anterior de este archivo estaba al revés.
--
-- Error: se tomó la columna CSV `precio_unitario` como costo de UNA pieza.
-- En Bodega F-42 77827 esa columna es el IMPORTE del renglón cuando qty > 1.
--   Escudo Rosa: 2 pzas, importe $8.96 → unitario $4.48. No $8.97.
--   Sedal Rizos 135 ml: 2 pzas, importe $18.16 → unitario $9.08. No $18.17.
-- El subtotal del CSV (importe × qty otra vez) no se usa.
--
-- Si alguien corrió la versión que infló el costo, esto lo devuelve.
-- Idempotente: solo pisa si el costo sigue en el valor multiplicado.

begin;

-- Escudo Rosa 110 g · 2 × $4.48 = $8.96
update public.productos
   set costo = 4.48
 where sku = 'FC-43489004'
   and activo = true
   and costo >= 8.90
   and costo <= 9.10;
update public.lotes
   set costo_unitario = 4.48
 where producto_id = (select id from public.productos where sku = 'FC-43489004' limit 1)
   and costo_unitario >= 8.90
   and costo_unitario <= 9.10;

-- Grisi Neutro 150 g · 3 × $6.96 = $20.87
update public.productos
   set costo = 6.96
 where sku = 'FC-22105207'
   and activo = true
   and costo >= 20.50
   and costo <= 21.20;
update public.lotes
   set costo_unitario = 6.96
 where producto_id = (select id from public.productos where sku = 'FC-22105207' limit 1)
   and costo_unitario >= 20.50
   and costo_unitario <= 21.20;

-- Escudo Antibacterial Frescura 110 g · 2 × $7.23 = $14.45
update public.productos
   set costo = 7.23
 where sku = 'FC-25605514'
   and activo = true
   and costo >= 14.20
   and costo <= 14.70;
update public.lotes
   set costo_unitario = 7.23
 where producto_id = (select id from public.productos where sku = 'FC-25605514' limit 1)
   and costo_unitario >= 14.20
   and costo_unitario <= 14.70;

-- Dove barra blanca 135 g · 2 × $15.10 = $30.21
update public.productos
   set costo = 15.10
 where sku = 'FC-38891190'
   and activo = true
   and costo >= 29.90
   and costo <= 30.50;
update public.lotes
   set costo_unitario = 15.10
 where producto_id = (select id from public.productos where sku = 'FC-38891190' limit 1)
   and costo_unitario >= 29.90
   and costo_unitario <= 30.50;

-- Pert crema oliva aguacate 100 ml · 2 × $7.40 = $14.80
update public.productos
   set costo = 7.40
 where sku = 'FC-20500171'
   and activo = true
   and costo >= 14.50
   and costo <= 15.10;
update public.lotes
   set costo_unitario = 7.40
 where producto_id = (select id from public.productos where sku = 'FC-20500171' limit 1)
   and costo_unitario >= 14.50
   and costo_unitario <= 15.10;

-- Sedal Rizos 135 ml · 2 × $9.08 = $18.16
update public.productos
   set costo = 9.08
 where sku = 'FC-56342227'
   and activo = true
   and costo >= 17.90
   and costo <= 18.40;
update public.lotes
   set costo_unitario = 9.08
 where producto_id = (select id from public.productos where sku = 'FC-56342227' limit 1)
   and costo_unitario >= 17.90
   and costo_unitario <= 18.40;

-- Nivea Milk 400+100 · qty 1; no se multiplica. Solo deshace el alza errónea.
update public.productos
   set costo = 22.30
 where sku = 'FC-54558682'
   and activo = true
   and costo >= 85.00
   and costo <= 86.50;
update public.lotes
   set costo_unitario = 22.30
 where producto_id = (select id from public.productos where sku = 'FC-54558682' limit 1)
   and costo_unitario >= 85.00
   and costo_unitario <= 86.50;

-- Kotex nocturna C/5 · 2 × $5.01 = $10.01
update public.productos
   set costo = 5.01
 where sku = 'FC-43427754'
   and activo = true
   and costo >= 9.80
   and costo <= 10.20;
update public.lotes
   set costo_unitario = 5.01
 where producto_id = (select id from public.productos where sku = 'FC-43427754' limit 1)
   and costo_unitario >= 9.80
   and costo_unitario <= 10.20;

-- Kotex regular C/10 · 2 × $10.61 = $21.21
update public.productos
   set costo = 10.61
 where sku = 'FC-17360604'
   and activo = true
   and costo >= 20.90
   and costo <= 21.50;
update public.lotes
   set costo_unitario = 10.61
 where producto_id = (select id from public.productos where sku = 'FC-17360604' limit 1)
   and costo_unitario >= 20.90
   and costo_unitario <= 21.50;

-- Claris desmaquillantes C/40 · 2 × $9.43 = $18.86
update public.productos
   set costo = 9.43
 where sku = 'FC-21012303'
   and activo = true
   and costo >= 18.60
   and costo <= 19.10;
update public.lotes
   set costo_unitario = 9.43
 where producto_id = (select id from public.productos where sku = 'FC-21012303' limit 1)
   and costo_unitario >= 18.60
   and costo_unitario <= 19.10;

-- Saba Invisible C/10 · 2 × $10.17 = $20.34
update public.productos
   set costo = 10.17
 where sku = 'FC-19006371'
   and activo = true
   and costo >= 20.10
   and costo <= 20.60;
update public.lotes
   set costo_unitario = 10.17
 where producto_id = (select id from public.productos where sku = 'FC-19006371' limit 1)
   and costo_unitario >= 20.10
   and costo_unitario <= 20.60;

-- Ego Force roll-on · 2 × $11.95 = $23.90
update public.productos
   set costo = 11.95
 where sku = 'FC-75064938'
   and activo = true
   and costo >= 23.60
   and costo <= 24.20;
update public.lotes
   set costo_unitario = 11.95
 where producto_id = (select id from public.productos where sku = 'FC-75064938' limit 1)
   and costo_unitario >= 23.60
   and costo_unitario <= 24.20;

-- Palmolive Neutro-Bal 120 g · 2 × $13.07 = $26.14
update public.productos
   set costo = 13.07
 where sku = 'FC-46683133'
   and activo = true
   and costo >= 25.90
   and costo <= 26.40;
update public.lotes
   set costo_unitario = 13.07
 where producto_id = (select id from public.productos where sku = 'FC-46683133' limit 1)
   and costo_unitario >= 25.90
   and costo_unitario <= 26.40;

-- Gel X-Treme Titan · 2 × $11.31 = $22.61
update public.productos
   set costo = 11.31
 where sku = 'FC-99425580'
   and activo = true
   and costo >= 22.30
   and costo <= 22.90;
update public.lotes
   set costo_unitario = 11.31
 where producto_id = (select id from public.productos where sku = 'FC-99425580' limit 1)
   and costo_unitario >= 22.30
   and costo_unitario <= 22.90;

-- Gel Moco de Gorila · 2 × $14.15 = $28.30
update public.productos
   set costo = 14.15
 where sku = 'FC-99428024'
   and activo = true
   and costo >= 28.00
   and costo <= 28.60;
update public.lotes
   set costo_unitario = 14.15
 where producto_id = (select id from public.productos where sku = 'FC-99428024' limit 1)
   and costo_unitario >= 28.00
   and costo_unitario <= 28.60;

-- Nivea Pearl spray 150 ml · 2 × $32.37 = $64.73
update public.productos
   set costo = 32.37
 where sku = 'FC-08837311'
   and activo = true
   and costo >= 64.40
   and costo <= 65.10;
update public.lotes
   set costo_unitario = 32.37
 where producto_id = (select id from public.productos where sku = 'FC-08837311' limit 1)
   and costo_unitario >= 64.40
   and costo_unitario <= 65.10;

-- Dove tono uniforme spray · 2 × $32.14 = $64.28
update public.productos
   set costo = 32.14
 where sku = 'FC-06241206'
   and activo = true
   and costo >= 64.00
   and costo <= 64.60;
update public.lotes
   set costo_unitario = 32.14
 where producto_id = (select id from public.productos where sku = 'FC-06241206' limit 1)
   and costo_unitario >= 64.00
   and costo_unitario <= 64.60;

-- Cepillo Acción Mayor Alcance · 2 × $13.50 = $27.00
update public.productos
   set costo = 13.50
 where sku = 'FC-86472048'
   and activo = true
   and costo >= 26.70
   and costo <= 27.30;
update public.lotes
   set costo_unitario = 13.50
 where producto_id = (select id from public.productos where sku = 'FC-86472048' limit 1)
   and costo_unitario >= 26.70
   and costo_unitario <= 27.30;

-- Cepillo Oral-B Indicator · 2 × $15.51 = $31.02
update public.productos
   set costo = 15.51
 where sku = 'FC-86494262'
   and activo = true
   and costo >= 30.70
   and costo <= 31.30;
update public.lotes
   set costo_unitario = 15.51
 where producto_id = (select id from public.productos where sku = 'FC-86494262' limit 1)
   and costo_unitario >= 30.70
   and costo_unitario <= 31.30;

commit;
