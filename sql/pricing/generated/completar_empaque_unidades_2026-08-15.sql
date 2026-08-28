-- Estructura el empaque en `unidades_por_caja` a partir del texto de `presentacion`.
-- Generado por scripts/completar_empaque_unidades.py
--
-- Para qué sirve: sin piezas por empaque, comparar nuestro precio contra la
-- competencia da brechas falsas (una caja de 80 aspirinas contra un paquete de 20
-- se ve como +450% cuando por tableta es +38%).
--
-- Incluye 626 productos (certeza alta y media)
-- El WHERE evita sobrescribir un dato ya capturado a mano.

BEGIN;

UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-00170941' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 60 WHERE sku = 'FC-00204798' AND coalesce(unidades_por_caja, 0) = 0;  -- 60 x pieza
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-00322571' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-00323011' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-00422511' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-00661391' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-00701992' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 75 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-007206' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-00721471' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 630 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-00721541' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 630 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-00740024' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 15 g
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-00744481' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-00753067' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 118 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-00942760' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-00E8A9C7' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 125 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-01015141' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 56.7 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-01163983' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-01165321' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 16 WHERE sku = 'FC-01165953' AND coalesce(unidades_por_caja, 0) = 0;  -- 16 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-01246730' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 12 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-01303454' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-01303464' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-013340' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-02012468' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-02012475' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-0211225' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-022543CD' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-0287855' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 240 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-03388008' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-03405381' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 18 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-03430721' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 28 g
UPDATE public.productos SET unidades_por_caja = 15 WHERE sku = 'FC-03738879' AND coalesce(unidades_por_caja, 0) = 0;  -- 15 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-04908738' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 35 g
UPDATE public.productos SET unidades_por_caja = 28 WHERE sku = 'FC-04D83B46' AND coalesce(unidades_por_caja, 0) = 0;  -- 28 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-053610' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-05965071' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06134531' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 20 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06209862' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06213906' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06217461' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06226739' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06226852' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06230507' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 135 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06234062' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 300 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06237407' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 190 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06241206' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06244795' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06245686' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06247327' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 15 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06247468' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06248045' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06248052' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06249226' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 700 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06249240' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 700 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06249776' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 180 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06249783' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 180 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-06257597' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 16 WHERE sku = 'FC-06910487' AND coalesce(unidades_por_caja, 0) = 0;  -- 16 x pieza
UPDATE public.productos SET unidades_por_caja = 16 WHERE sku = 'FC-06910906' AND coalesce(unidades_por_caja, 0) = 0;  -- 16 x pieza
UPDATE public.productos SET unidades_por_caja = 16 WHERE sku = 'FC-06910913' AND coalesce(unidades_por_caja, 0) = 0;  -- 16 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-07457796' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-07457826' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-07502441' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 75 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-07528939' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-07535494' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-07F04F88' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-08100013' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-08344488' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 60 WHERE sku = 'FC-08344501' AND coalesce(unidades_por_caja, 0) = 0;  -- 60 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-08344716' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 2 WHERE sku = 'FC-08421321' AND coalesce(unidades_por_caja, 0) = 0;  -- 2 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-08426944' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 40 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-08427330' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 30 g
UPDATE public.productos SET unidades_por_caja = 80 WHERE sku = 'FC-08491074' AND coalesce(unidades_por_caja, 0) = 0;  -- 80 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-08498798' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 30 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-08802838' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-08837311' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-08895196' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-08DB70CB' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-09498091' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 90 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-09745027' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-09745584' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 125 ml
UPDATE public.productos SET unidades_por_caja = 4 WHERE sku = 'FC-09747366' AND coalesce(unidades_por_caja, 0) = 0;  -- 4 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-09749209' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-09839202' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 g
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-0ACC5B6A' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-0BDE9283' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 15 g
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-1041884' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 2 WHERE sku = 'FC-10631207' AND coalesce(unidades_por_caja, 0) = 0;  -- 2 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-10974329' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-11165726' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 28 g
UPDATE public.productos SET unidades_por_caja = 2 WHERE sku = 'FC-11294615' AND coalesce(unidades_por_caja, 0) = 0;  -- 2 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-12225027' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-12250181' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 45 g
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-127F5753' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-13071164' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-1321B34F' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-14121782' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 80 g
UPDATE public.productos SET unidades_por_caja = 4 WHERE sku = 'FC-14377180' AND coalesce(unidades_por_caja, 0) = 0;  -- 4 x pieza
UPDATE public.productos SET unidades_por_caja = 4 WHERE sku = 'FC-14377197' AND coalesce(unidades_por_caja, 0) = 0;  -- 4 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-14704156' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-14704163' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-14704187' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-14980350' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 75 ml
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-14980596' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-14982514' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-14983153' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 75 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-14983726' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 75 ml
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-14985348' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 5 WHERE sku = 'FC-14985805' AND coalesce(unidades_por_caja, 0) = 0;  -- 5 x pieza
UPDATE public.productos SET unidades_por_caja = 60 WHERE sku = 'FC-16803800' AND coalesce(unidades_por_caja, 0) = 0;  -- 60 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-17360604' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-17376CAE' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 6 WHERE sku = 'FC-174824A0' AND coalesce(unidades_por_caja, 0) = 0;  -- 6 x pieza
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-1751468C' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-1812D26D' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-19006371' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-1CF27DC9' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-1DA570E3' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-1DAD5EF1' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 118 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-1FBF5206' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 60 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-1FEA2FB7' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-1FFBB505' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-2001A890' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-2005DD57' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-20500171' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-20500201' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-20501673' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-20501765' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 80 ml
UPDATE public.productos SET unidades_por_caja = 40 WHERE sku = 'FC-21012303' AND coalesce(unidades_por_caja, 0) = 0;  -- 40 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-21042481' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-22105207' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-22111352' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 125 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-22130063' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-22133286' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-22150092' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 125 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-22150221' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 90 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-22150801' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 125 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-2225010' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 25 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-22322395' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-22B18244' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-23001331' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 28 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-23111387' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-23272151' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-23273451' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-24004581' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-24227339' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-24511629' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 105 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-24511636' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 105 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-24511711' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 105 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-25104268' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 625 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-25104411' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 625 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-25104688' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 625 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-25149221' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 625 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-25605514' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 110 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-25652716' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 135 g
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-25E452B6' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 14 WHERE sku = 'FC-262F2A30' AND coalesce(unidades_por_caja, 0) = 0;  -- 14 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-26462078' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-26EA40A4' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-27250612' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 65 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-27286017' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 65 g
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-27427392' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-27512574' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 240 ml
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-27875568' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-28979502' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-28A424E5' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-29003221' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-2E5B7248' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 60 g
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-2E79C2D8' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-2EDC6E3B' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 5 WHERE sku = 'FC-30133021' AND coalesce(unidades_por_caja, 0) = 0;  -- 5 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-30622622' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-31144302' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 20 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-31244486' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-31405888' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-31887928' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-31976394' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-32911454' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 202 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33950063' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 236 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33950070' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 236 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33950100' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 236 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33950209' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 237 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33951008' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 236 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33954078' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 237 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33954740' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 500 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33956126' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 237 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33956133' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 237 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33956140' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 237 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33956775' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 500 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-33961373' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 500 ml
UPDATE public.productos SET unidades_por_caja = 100 WHERE sku = 'FC-34064021' AND coalesce(unidades_por_caja, 0) = 0;  -- 100 x pieza
UPDATE public.productos SET unidades_por_caja = 150 WHERE sku = 'FC-34067851' AND coalesce(unidades_por_caja, 0) = 0;  -- 150 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-347A49C7' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35020008' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 375 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35020077' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 180 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35155847' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35155922' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35168991' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 210 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35169035' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 210 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35231237' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 375 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35231244' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 180 ml
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-35246309' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35469151' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-357D4A17' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35908116' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35908130' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35908147' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35911208' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 221 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-35919129' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-36003621' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 20 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-36032776' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-36033735' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-36040450' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 80 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-36041259' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 90 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-36041273' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-36041297' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 90 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-36041341' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 90 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-36041389' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 90 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-36041402' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 500 ml
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-3676D5DC' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 6 WHERE sku = 'FC-369D1689' AND coalesce(unidades_por_caja, 0) = 0;  -- 6 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-37163266' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-37164713' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-38312374' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-38891190' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 135 g
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-38CAFE6B' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-39036C88' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-39390230' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-3961366' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 500 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-3A4583F3' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-3B001F9B' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 60 WHERE sku = 'FC-3CAA7C5C' AND coalesce(unidades_por_caja, 0) = 0;  -- 60 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-3D0ED22B' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-3D0F54B7' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-40004643' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-40010538' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-40010712' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 125 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-40013850' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 52 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-40013898' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 52 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-40015366' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 30 ml
UPDATE public.productos SET unidades_por_caja = 24 WHERE sku = 'FC-40017100' AND coalesce(unidades_por_caja, 0) = 0;  -- 24 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-40025839' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-40030338' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-40030963' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-40032264' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-40032271' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-40032295' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-40032325' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-40035395' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 7 WHERE sku = 'FC-40036354' AND coalesce(unidades_por_caja, 0) = 0;  -- 7 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-40036965' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-40066306' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-40074455' AND coalesce(unidades_por_caja, 0) = 0;  -- 8 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-40171550' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-405A75E3' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-40CE757D' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-41339950' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-41500096' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-42003469' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-42270027' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-42302289' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 300 ml
UPDATE public.productos SET unidades_por_caja = 2 WHERE sku = 'FC-42303194' AND coalesce(unidades_por_caja, 0) = 0;  -- 2 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-42326414' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-42417644' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 75 ml
UPDATE public.productos SET unidades_por_caja = 5 WHERE sku = 'FC-42507240' AND coalesce(unidades_por_caja, 0) = 0;  -- 5 x pieza
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-428A228F' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 5 WHERE sku = 'FC-43427754' AND coalesce(unidades_por_caja, 0) = 0;  -- 5 x pieza
UPDATE public.productos SET unidades_por_caja = 80 WHERE sku = 'FC-43454811' AND coalesce(unidades_por_caja, 0) = 0;  -- 80 x pieza
UPDATE public.productos SET unidades_por_caja = 80 WHERE sku = 'FC-43454873' AND coalesce(unidades_por_caja, 0) = 0;  -- 80 x pieza
UPDATE public.productos SET unidades_por_caja = 120 WHERE sku = 'FC-43471900' AND coalesce(unidades_por_caja, 0) = 0;  -- 120 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-43489004' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 110 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-43489165' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 225 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-4391156' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 3 g
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-443C330E' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 5 WHERE sku = 'FC-447B30F9' AND coalesce(unidades_por_caja, 0) = 0;  -- 5 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-44B6751A' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-45720550' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-45720567' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-45722547' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46059556' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 221 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46072050' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46073033' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46073040' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46073118' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 380 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46073156' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 380 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46074504' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 2 WHERE sku = 'FC-46640629' AND coalesce(unidades_por_caja, 0) = 0;  -- 2 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46642073' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 60 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46650708' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46655055' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46655079' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 90 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46655727' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 90 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46657035' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 221 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46682815' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-46683133' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-47624171' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 12 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-47640531' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 15 ml
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-47AAF23B' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-48335305' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 480 ml
UPDATE public.productos SET unidades_por_caja = 100 WHERE sku = 'FC-48623006' AND coalesce(unidades_por_caja, 0) = 0;  -- 100 x pieza
UPDATE public.productos SET unidades_por_caja = 2 WHERE sku = 'FC-48640751' AND coalesce(unidades_por_caja, 0) = 0;  -- 2 x pieza
UPDATE public.productos SET unidades_por_caja = 2 WHERE sku = 'FC-48640775' AND coalesce(unidades_por_caja, 0) = 0;  -- 2 x pieza
UPDATE public.productos SET unidades_por_caja = 2 WHERE sku = 'FC-48640799' AND coalesce(unidades_por_caja, 0) = 0;  -- 2 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-48F732CF' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-492D652F' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-49800151' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-4980275' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-49824391' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-49824771' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-49824911' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 5 WHERE sku = 'FC-49828111' AND coalesce(unidades_por_caja, 0) = 0;  -- 5 x pieza
UPDATE public.productos SET unidades_por_caja = 5 WHERE sku = 'FC-49835773' AND coalesce(unidades_por_caja, 0) = 0;  -- 5 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-49853867' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 100 WHERE sku = 'FC-4A0245DA' AND coalesce(unidades_por_caja, 0) = 0;  -- 100 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-4BD80686' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-4F05124E' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-4FD413D2' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-50002301' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-50608272' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-50724298' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-50882000' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-50882017' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-50882024' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-50959781' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-50AC2C82' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 15 WHERE sku = 'FC-50D044FF' AND coalesce(unidades_por_caja, 0) = 0;  -- 15 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-51067711' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 360 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-5106788' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 360 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-51078461' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-51078531' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-5112881' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-51448511' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 525 ml
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-5145497' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-51747971' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 625 ml
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-52400038' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-52400212' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-52400267' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-52816297' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 300 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-52844825' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 65 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-52876406' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 65 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-52910971' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 300 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-52933307' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 65 g
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-52D2A43A' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-53506FA4' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-53601247' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-53601339' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-54073302' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 105 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-54500216' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-54503095' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-54504535' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-54521161' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-54549796' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-54549819' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-54558682' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-55280956' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 65 g
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-56034041' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 90 WHERE sku = 'FC-56131681' AND coalesce(unidades_por_caja, 0) = 0;  -- 90 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56323059' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 85 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56323066' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 42 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56326142' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56330309' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56330378' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56340025' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 300 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56340117' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 300 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56340124' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 300 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56340131' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 300 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56342227' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 135 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56342258' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 135 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56360429' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-56371159' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 135 g
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-578F060C' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-57925EF3' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-58367129' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-58611420' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 460 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-58616678' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 270 g
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-58792792' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-58793249' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 ml
UPDATE public.productos SET unidades_por_caja = 28 WHERE sku = 'FC-5885E577' AND coalesce(unidades_por_caja, 0) = 0;  -- 28 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-58DB24C4' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-59225411' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 360 g
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-5A697CC2' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-5BC5F234' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-5C8C9C11' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-5D59ED54' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-5D9DFA3D' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-5EF90195' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-5F30F9D4' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-60009851' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 75 ml
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-60101231' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-60101378' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-60101521' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 56.7 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-6040351' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 20 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-60689091' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 ml
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-6074BB64' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 5 WHERE sku = 'FC-60F627D5' AND coalesce(unidades_por_caja, 0) = 0;  -- 5 x pieza
UPDATE public.productos SET unidades_por_caja = 150 WHERE sku = 'FC-61111501' AND coalesce(unidades_por_caja, 0) = 0;  -- 150 x pieza
UPDATE public.productos SET unidades_por_caja = 300 WHERE sku = 'FC-61113000' AND coalesce(unidades_por_caja, 0) = 0;  -- 300 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-61123009' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 300 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-61124013' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 g
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-614E4F82' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-62034164' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-62746605' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-62746612' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-62746643' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-63975795' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-64560163' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 60 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-64EB83AA' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-65095718' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-65095947' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-66055303' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-66534951' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 65 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-66873531' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 90 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-66888171' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-67905131' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 221 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-67905186' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 221 ml
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-68900127' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-68900226' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-68900264' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 125 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-68901117' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-68901124' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 500 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-68901131' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 1000 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-68910034' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-68910041' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 25 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-68960257' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 1000 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-68990023' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 500 ml
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-69200016' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 envase(s) de 3 g
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-69387811' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-6B2ADEE9' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 12.8 g
UPDATE public.productos SET unidades_por_caja = 5 WHERE sku = 'FC-6C2878CF' AND coalesce(unidades_por_caja, 0) = 0;  -- 5 x pieza
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-6EAD98A9' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-70100307' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 140 ml
UPDATE public.productos SET unidades_por_caja = 5 WHERE sku = 'FC-71829601' AND coalesce(unidades_por_caja, 0) = 0;  -- 5 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-72300171' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 85 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-72629012' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 15 WHERE sku = 'FC-73629981' AND coalesce(unidades_por_caja, 0) = 0;  -- 15 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-73906469' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 360 ml
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-74A5ABEE' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-75001865' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 115 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-75062897' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 45 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-75062927' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 45 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-75064938' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 45 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-75069223' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 45 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-75076009' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 45 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-75125811' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-75163051' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-75717914' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-75718676' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 400 g
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-75723137' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-759A5EF9' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-76000253' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-76000260' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-76000277' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-76000284' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 500 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-76040436' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 24 WHERE sku = 'FC-76040610' AND coalesce(unidades_por_caja, 0) = 0;  -- 24 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-77620056' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 1000 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-7907117' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-79071241' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 24 WHERE sku = 'FC-79400556' AND coalesce(unidades_por_caja, 0) = 0;  -- 24 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-7AF7ACB5' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-7D1D9857' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-7F90064A' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 4 WHERE sku = 'FC-80596011' AND coalesce(unidades_por_caja, 0) = 0;  -- 4 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-8062229' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-80950139' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-80953017' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-82176351' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 120 WHERE sku = 'FC-82200016' AND coalesce(unidades_por_caja, 0) = 0;  -- 120 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-82740011' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 125 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-82790016' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-82790504' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 125 ml
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-8281209' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-82F88FED' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-830BF3FB' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-83146207' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 15 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-83351381' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-83351691' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 230 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-83510531' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 ml
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-83683367' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-84095411' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-84154058' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 60 g
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-8421321' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 100 WHERE sku = 'FC-84272103' AND coalesce(unidades_por_caja, 0) = 0;  -- 100 x pieza
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-84273094' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-8432071' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 60 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-84431050' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 60 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-84437151' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-84471476' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 265 ml
UPDATE public.productos SET unidades_por_caja = 5 WHERE sku = 'FC-84500522' AND coalesce(unidades_por_caja, 0) = 0;  -- 5 x pieza
UPDATE public.productos SET unidades_por_caja = 9 WHERE sku = 'FC-84500607' AND coalesce(unidades_por_caja, 0) = 0;  -- 9 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-84900280' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 130 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-8505003' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 2 ml
UPDATE public.productos SET unidades_por_caja = 2 WHERE sku = 'FC-8505126' AND coalesce(unidades_por_caja, 0) = 0;  -- 2 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-85097661' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 60 ml
UPDATE public.productos SET unidades_por_caja = 40 WHERE sku = 'FC-85103015' AND coalesce(unidades_por_caja, 0) = 0;  -- 40 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-85132069' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 15 ml
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-85171113' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-85171118' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-85278507' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 15 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-85592111' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 60 g
UPDATE public.productos SET unidades_por_caja = 80 WHERE sku = 'FC-85800198' AND coalesce(unidades_por_caja, 0) = 0;  -- 80 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-86167151' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 270 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-8645080' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 20 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-86472048' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-86494262' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-86708021' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-86901100' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 125 ml
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-86A95D07' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 16 WHERE sku = 'FC-87154871' AND coalesce(unidades_por_caja, 0) = 0;  -- 16 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-87932321' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 50 ml
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-88508929' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-885F2723' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-88915491' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-88923551' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-88947797' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-8910003' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 100 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-89100101' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-89810021' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 60 ml
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-89F00320' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-90031475' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-9233072' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 144 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-92503558' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-92504539' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 25 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-92506045' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 25 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-92506601' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-92509213' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 300 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-92511261' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 300 g
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-926099D3' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-92821171' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 240 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-93022567' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 90 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-93025797' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-93025919' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 152 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-9303047' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 2 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-93037806' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-93038223' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 150 ml
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-931B4809' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-9490651' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 40 g
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-9507CD66' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-9511421' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 30 g
UPDATE public.productos SET unidades_por_caja = 2 WHERE sku = 'FC-95129166' AND coalesce(unidades_por_caja, 0) = 0;  -- 2 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-95201021' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 45 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-9525015' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 140 ml
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-95779436' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 60 WHERE sku = 'FC-9741524' AND coalesce(unidades_por_caja, 0) = 0;  -- 60 x pieza
UPDATE public.productos SET unidades_por_caja = 100 WHERE sku = 'FC-97BEFA1A' AND coalesce(unidades_por_caja, 0) = 0;  -- 100 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-98100381' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 120 ml
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-9827438F' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 6 WHERE sku = 'FC-9890331' AND coalesce(unidades_por_caja, 0) = 0;  -- 6 x pieza
UPDATE public.productos SET unidades_por_caja = 6 WHERE sku = 'FC-9890973' AND coalesce(unidades_por_caja, 0) = 0;  -- 6 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-9892403' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-99425580' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 250 g
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-99428024' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 80 g
UPDATE public.productos SET unidades_por_caja = 14 WHERE sku = 'FC-9A37D44A' AND coalesce(unidades_por_caja, 0) = 0;  -- 14 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-9ABFB996' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-A0D320D1' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 15 WHERE sku = 'FC-A23F290E' AND coalesce(unidades_por_caja, 0) = 0;  -- 15 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-A2B284E0' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 10 ml
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-A680F97E' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 6 WHERE sku = 'FC-A871D831' AND coalesce(unidades_por_caja, 0) = 0;  -- 6 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-A909ABC0' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-AA7B0686' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 200 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-AA905BF7' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-ACA2A2F6' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-AE5EEDF7' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-AEA8C8DA' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 15 WHERE sku = 'FC-B18E386A' AND coalesce(unidades_por_caja, 0) = 0;  -- 15 x pieza
UPDATE public.productos SET unidades_por_caja = 4 WHERE sku = 'FC-B2123139' AND coalesce(unidades_por_caja, 0) = 0;  -- 4 x pieza
UPDATE public.productos SET unidades_por_caja = 7 WHERE sku = 'FC-B25B4654' AND coalesce(unidades_por_caja, 0) = 0;  -- 7 x pieza
UPDATE public.productos SET unidades_por_caja = 16 WHERE sku = 'FC-B4477A00' AND coalesce(unidades_por_caja, 0) = 0;  -- 16 x pieza
UPDATE public.productos SET unidades_por_caja = 35 WHERE sku = 'FC-B69FCBF4' AND coalesce(unidades_por_caja, 0) = 0;  -- 35 x pieza
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-B8D7C997' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-BCF59548' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 14 WHERE sku = 'FC-BDB2E087' AND coalesce(unidades_por_caja, 0) = 0;  -- 14 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-BE0A0E46' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-BE2ACF63' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-BE76D409' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-C101D5B1' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 2 WHERE sku = 'FC-C22EBFE6' AND coalesce(unidades_por_caja, 0) = 0;  -- 2 x pieza
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-C4530823' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-C636D8EA' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-C6C20517' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 7 WHERE sku = 'FC-C721E8D7' AND coalesce(unidades_por_caja, 0) = 0;  -- 7 x pieza
UPDATE public.productos SET unidades_por_caja = 14 WHERE sku = 'FC-C9F4ACCC' AND coalesce(unidades_por_caja, 0) = 0;  -- 14 x pieza
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-CB5C11ED' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-CD261CD5' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 16 WHERE sku = 'FC-CF18C740' AND coalesce(unidades_por_caja, 0) = 0;  -- 16 x pieza
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-CF719C07' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-D037156B' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-D06E54FE' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-D11D586A' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 6 ml
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-D210172A' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-D3D28E20' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-D4AC123B' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-D5AC44CA' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-D751525D' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 envase(s) de 30 ml
UPDATE public.productos SET unidades_por_caja = 7 WHERE sku = 'FC-DA34D88D' AND coalesce(unidades_por_caja, 0) = 0;  -- 7 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-DB3B2584' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 12 WHERE sku = 'FC-DB4A39AE' AND coalesce(unidades_por_caja, 0) = 0;  -- 12 x pieza
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-DE106642' AND coalesce(unidades_por_caja, 0) = 0;  -- 3 x pieza
UPDATE public.productos SET unidades_por_caja = 45 WHERE sku = 'FC-DF39BB27' AND coalesce(unidades_por_caja, 0) = 0;  -- 45 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-DF8ADDAB' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-E4BE37BE' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 15 WHERE sku = 'FC-E4EFC4C2' AND coalesce(unidades_por_caja, 0) = 0;  -- 15 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-E535DE28' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-E6112F15' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-E69F2E63' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-E6B50AC3' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 6 WHERE sku = 'FC-E826D304' AND coalesce(unidades_por_caja, 0) = 0;  -- 6 x pieza
UPDATE public.productos SET unidades_por_caja = 14 WHERE sku = 'FC-E9C38DC4' AND coalesce(unidades_por_caja, 0) = 0;  -- 14 x pieza
UPDATE public.productos SET unidades_por_caja = 20 WHERE sku = 'FC-EADF1484' AND coalesce(unidades_por_caja, 0) = 0;  -- 20 x pieza
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-EFB599B5' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 1 WHERE sku = 'FC-F183C6E9' AND coalesce(unidades_por_caja, 0) = 0;  -- 1 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-F22C72BE' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-F7A2CACF' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 28 WHERE sku = 'FC-F7DB080D' AND coalesce(unidades_por_caja, 0) = 0;  -- 28 x pieza
UPDATE public.productos SET unidades_por_caja = 10 WHERE sku = 'FC-F82A6E4B' AND coalesce(unidades_por_caja, 0) = 0;  -- 10 x pieza
UPDATE public.productos SET unidades_por_caja = 16 WHERE sku = 'FC-F8691496' AND coalesce(unidades_por_caja, 0) = 0;  -- 16 x pieza
UPDATE public.productos SET unidades_por_caja = 40 WHERE sku = 'FC-F967863B' AND coalesce(unidades_por_caja, 0) = 0;  -- 40 x pieza
UPDATE public.productos SET unidades_por_caja = 30 WHERE sku = 'FC-FA3D96E6' AND coalesce(unidades_por_caja, 0) = 0;  -- 30 x pieza
UPDATE public.productos SET unidades_por_caja = 50 WHERE sku = 'FC-FBD776D2' AND coalesce(unidades_por_caja, 0) = 0;  -- 50 x pieza
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-FD718DF3' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 35 WHERE sku = 'FC-FD845E68' AND coalesce(unidades_por_caja, 0) = 0;  -- 35 x pieza
UPDATE public.productos SET unidades_por_caja = 14 WHERE sku = 'FC-FD92D114' AND coalesce(unidades_por_caja, 0) = 0;  -- 14 x pieza
UPDATE public.productos SET unidades_por_caja = 25 WHERE sku = 'FC-FEAECBF1' AND coalesce(unidades_por_caja, 0) = 0;  -- 25 x pieza
UPDATE public.productos SET unidades_por_caja = 4 WHERE sku = 'FC-FFC25DD1' AND coalesce(unidades_por_caja, 0) = 0;  -- 4 x pieza

-- ── Correcciones ──
-- Aquí el dato guardado contradice a la propia presentación del producto.
-- Estos UPDATE sí sobrescriben: revísalos antes de correrlos.

UPDATE public.productos SET unidades_por_caja = 8 WHERE sku = 'FC-070839';  -- 'C/8 tabletas 550 mg' dice 8, estaba en 6
UPDATE public.productos SET unidades_por_caja = 60 WHERE sku = 'FC-8494226';  -- 'C/60 tabletas 100 mg' dice 60, estaba en 40
UPDATE public.productos SET unidades_por_caja = 3 WHERE sku = 'FC-98217659';  -- 'C/3 jeringas prellenadas 3 mL' dice 3, estaba en 20

COMMIT;
