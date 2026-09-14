-- Costos partidos por la cantidad del ticket (Bodega F-42 77827).
-- Escudo Rosa NO costó $4.48: el renglón es 2 × $8.965 = $17.93.
-- Un parche OCR volvió a dividir el unitario entre las piezas.
-- Idempotente: solo pisa si el costo catálogo sigue en el valor partido.

begin;

-- Escudo Rosa 110 g · ticket 2 × $8.965
update public.productos
   set costo = 8.97
 where sku = 'FC-43489004'
   and activo = true
   and costo > 0
   and costo <= 5.00;
update public.lotes
   set costo_unitario = 8.97
 where producto_id = (select id from public.productos where sku = 'FC-43489004' limit 1)
   and costo_unitario <= 5.00;

-- Grisi Neutro 150 g · ticket 3 × $20.87
update public.productos
   set costo = 20.87
 where sku = 'FC-22105207'
   and activo = true
   and costo > 0
   and costo <= 8.00;
update public.lotes
   set costo_unitario = 20.87
 where producto_id = (select id from public.productos where sku = 'FC-22105207' limit 1)
   and costo_unitario <= 8.00;

-- Escudo Antibacterial Frescura 110 g · ticket 2 × $14.45
update public.productos
   set costo = 14.45
 where sku = 'FC-25605514'
   and activo = true
   and costo > 0
   and costo <= 8.00;
update public.lotes
   set costo_unitario = 14.45
 where producto_id = (select id from public.productos where sku = 'FC-25605514' limit 1)
   and costo_unitario <= 8.00;

-- Escudo Azul Rey 135 g · ticket 2 × $14.775 (catálogo $13.65)
update public.productos
   set costo = 14.78
 where sku = 'FC-25652716'
   and activo = true
   and costo > 0
   and costo < 14.70;
update public.lotes
   set costo_unitario = 14.78
 where producto_id = (select id from public.productos where sku = 'FC-25652716' limit 1)
   and costo_unitario < 14.70;

-- Dove barra blanca 135 g · ticket 2 × $30.205
update public.productos
   set costo = 30.21
 where sku = 'FC-38891190'
   and activo = true
   and costo > 0
   and costo <= 16.00;
update public.lotes
   set costo_unitario = 30.21
 where producto_id = (select id from public.productos where sku = 'FC-38891190' limit 1)
   and costo_unitario <= 16.00;

-- Pert crema oliva aguacate 100 ml · ticket 2 × $14.80
update public.productos
   set costo = 14.80
 where sku = 'FC-20500171'
   and activo = true
   and costo > 0
   and costo <= 8.00;
update public.lotes
   set costo_unitario = 14.80
 where producto_id = (select id from public.productos where sku = 'FC-20500171' limit 1)
   and costo_unitario <= 8.00;

-- Sedal Rizos 135 ml · ticket 2 × $18.165 (el $9.08 del catálogo es la mitad)
update public.productos
   set costo = 18.17
 where sku = 'FC-56342227'
   and activo = true
   and costo > 0
   and costo <= 10.00;
update public.lotes
   set costo_unitario = 18.17
 where producto_id = (select id from public.productos where sku = 'FC-56342227' limit 1)
   and costo_unitario <= 10.00;

-- Nivea Milk 400 ml + 100 ml · ticket 1 × $85.87 (catálogo $22.30)
update public.productos
   set costo = 85.87
 where sku = 'FC-54558682'
   and activo = true
   and costo > 0
   and costo <= 30.00;
update public.lotes
   set costo_unitario = 85.87
 where producto_id = (select id from public.productos where sku = 'FC-54558682' limit 1)
   and costo_unitario <= 30.00;

-- Kotex nocturna C/5 · ticket 2 × $10.01
update public.productos
   set costo = 10.01
 where sku = 'FC-43427754'
   and activo = true
   and costo > 0
   and costo <= 6.00;
update public.lotes
   set costo_unitario = 10.01
 where producto_id = (select id from public.productos where sku = 'FC-43427754' limit 1)
   and costo_unitario <= 6.00;

-- Kotex regular C/10 · ticket 2 × $21.21
update public.productos
   set costo = 21.21
 where sku = 'FC-17360604'
   and activo = true
   and costo > 0
   and costo <= 12.00;
update public.lotes
   set costo_unitario = 21.21
 where producto_id = (select id from public.productos where sku = 'FC-17360604' limit 1)
   and costo_unitario <= 12.00;

-- Claris desmaquillantes C/40 · ticket 2 × $18.86
update public.productos
   set costo = 18.86
 where sku = 'FC-21012303'
   and activo = true
   and costo > 0
   and costo <= 10.00;
update public.lotes
   set costo_unitario = 18.86
 where producto_id = (select id from public.productos where sku = 'FC-21012303' limit 1)
   and costo_unitario <= 10.00;

-- Saba Invisible C/10 · ticket 2 × $20.34
update public.productos
   set costo = 20.34
 where sku = 'FC-19006371'
   and activo = true
   and costo > 0
   and costo <= 11.00;
update public.lotes
   set costo_unitario = 20.34
 where producto_id = (select id from public.productos where sku = 'FC-19006371' limit 1)
   and costo_unitario <= 11.00;

-- Ego Force roll-on · ticket 2 × $23.895
update public.productos
   set costo = 23.90
 where sku = 'FC-75064938'
   and activo = true
   and costo > 0
   and costo <= 13.00;
update public.lotes
   set costo_unitario = 23.90
 where producto_id = (select id from public.productos where sku = 'FC-75064938' limit 1)
   and costo_unitario <= 13.00;

-- Palmolive Neutro-Bal 120 g · ticket 2 × $26.14
update public.productos
   set costo = 26.14
 where sku = 'FC-46683133'
   and activo = true
   and costo > 0
   and costo <= 14.00;
update public.lotes
   set costo_unitario = 26.14
 where producto_id = (select id from public.productos where sku = 'FC-46683133' limit 1)
   and costo_unitario <= 14.00;

-- Gel X-Treme Titan · ticket 2 × $22.61
update public.productos
   set costo = 22.61
 where sku = 'FC-99425580'
   and activo = true
   and costo > 0
   and costo <= 12.00;
update public.lotes
   set costo_unitario = 22.61
 where producto_id = (select id from public.productos where sku = 'FC-99425580' limit 1)
   and costo_unitario <= 12.00;

-- Gel Moco de Gorila · ticket 2 × $28.30
update public.productos
   set costo = 28.30
 where sku = 'FC-99428024'
   and activo = true
   and costo > 0
   and costo <= 15.00;
update public.lotes
   set costo_unitario = 28.30
 where producto_id = (select id from public.productos where sku = 'FC-99428024' limit 1)
   and costo_unitario <= 15.00;

-- Nivea Pearl spray 150 ml · ticket 2 × $64.73
update public.productos
   set costo = 64.73
 where sku = 'FC-08837311'
   and activo = true
   and costo > 0
   and costo <= 35.00;
update public.lotes
   set costo_unitario = 64.73
 where producto_id = (select id from public.productos where sku = 'FC-08837311' limit 1)
   and costo_unitario <= 35.00;

-- Dove tono uniforme spray · ticket 2 × $64.28
update public.productos
   set costo = 64.28
 where sku = 'FC-06241206'
   and activo = true
   and costo > 0
   and costo <= 35.00;
update public.lotes
   set costo_unitario = 64.28
 where producto_id = (select id from public.productos where sku = 'FC-06241206' limit 1)
   and costo_unitario <= 35.00;

-- Cepillo Acción Mayor Alcance · ticket 2 × $27.00
update public.productos
   set costo = 27.00
 where sku = 'FC-86472048'
   and activo = true
   and costo > 0
   and costo <= 15.00;
update public.lotes
   set costo_unitario = 27.00
 where producto_id = (select id from public.productos where sku = 'FC-86472048' limit 1)
   and costo_unitario <= 15.00;

-- Cepillo Oral-B Indicator · ticket 2 × $31.02
update public.productos
   set costo = 31.02
 where sku = 'FC-86494262'
   and activo = true
   and costo > 0
   and costo <= 17.00;
update public.lotes
   set costo_unitario = 31.02
 where producto_id = (select id from public.productos where sku = 'FC-86494262' limit 1)
   and costo_unitario <= 17.00;

commit;
