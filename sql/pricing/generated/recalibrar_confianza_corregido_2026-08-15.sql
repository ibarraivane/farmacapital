-- Recalibracion de confianza con el comparador corregido
-- Generado 2026-08-15
--
-- Cuatro fallas del comparador salieron a la luz al revisar por que referencias buenas
-- tenian mala nota, y una regla que faltaba:
--  1) El proveedor abrevia los activos (SULFA, TRIMETOPRI, PARAC, CAFE, FENILE) pegados
--     con diagonal, y el activo quedaba escondido dentro del token. Ahora se separa.
--  2) El mismo farmaco cambia de nombre: nosotros decimos dipirona y Similares METAMIZOL
--     SODICO. Hay tabla de sinonimos.
--  3) Las formas se agrupan por como se miden: pastilla y tableta se cuentan por pieza,
--     jarabe y solucion oral por mililitro. Entre familias distintas sigue sin comparar.
--  4) Un empaque distinto ya no hunde el match: se guardan las piezas de ambos lados y
--     la comparacion se hace por unidad.
--  5) REGLA NUEVA: si al competidor le falta un principio activo, no es el mismo
--     medicamento. La doxilamina es lo que hace dormir al Tabcin Noche y la amantadina
--     es el antiviral del XL-3 VR; sin ese activo el precio no es referencia.
--
-- Ajustan confianza: 26 · se borran: 6 · pendientes de nuestro catalogo: 8

BEGIN;

-- ── Confianza recalculada sobre la evidencia ya guardada.
UPDATE producto_precios_referencia SET confianza = 100, notas = 'principios activos completos; concentracion coincide' || ' | recalibrado 2026-08-15' WHERE id = 896;  -- Pasta Lassar Andromaco 30 g: 95 -> 100
UPDATE producto_precios_referencia SET confianza = 100, notas = 'principios activos completos; equivalente generico verificado por composicion; concentracion coincide; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 746;  -- Histiacil NF adulto jarabe: 75 -> 100
UPDATE producto_precios_referencia SET confianza = 100, notas = 'principios activos completos; concentracion coincide; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 778;  -- Bisolvon Infantil: 90 -> 100
UPDATE producto_precios_referencia SET confianza = 100, notas = 'principios activos completos; equivalente generico verificado por composicion; concentracion coincide; cantidad coincide; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 780;  -- Saridon: 97 -> 100
UPDATE producto_precios_referencia SET confianza = 100, notas = 'marca coincide; cantidad coincide' || ' | recalibrado 2026-08-15' WHERE id = 813;  -- Balsamo para Labios Labello Mora: 94 -> 100
UPDATE producto_precios_referencia SET confianza = 100, notas = 'principios activos completos; concentracion coincide; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 839;  -- Canesten V Crema 3 dias 20 g + 3: 85 -> 100
UPDATE producto_precios_referencia SET confianza = 100, notas = 'principios activos completos; concentracion coincide; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 880;  -- Oppelver lactulosa jarabe 125 mL: 91 -> 100
UPDATE producto_precios_referencia SET confianza = 97, notas = 'marca coincide; cantidad coincide' || ' | recalibrado 2026-08-15' WHERE id = 877;  -- Balsamo para Labios Labello Clas: 89 -> 97
UPDATE producto_precios_referencia SET confianza = 97, notas = 'marca coincide; cantidad coincide' || ' | recalibrado 2026-08-15' WHERE id = 878;  -- Balsamo Para Labios Labello Hidr: 89 -> 97
UPDATE producto_precios_referencia SET confianza = 95, notas = 'principios activos completos; equivalente generico verificado por composicion; cantidad coincide' || ' | recalibrado 2026-08-15' WHERE id = 800;  -- Sal de uvas: 80 -> 95
UPDATE producto_precios_referencia SET confianza = 94, notas = 'principios activos completos; cantidad coincide' || ' | recalibrado 2026-08-15' WHERE id = 816;  -- Penipot: 86 -> 94
UPDATE producto_precios_referencia SET confianza = 94, notas = 'principios activos completos; cantidad coincide' || ' | recalibrado 2026-08-15' WHERE id = 861;  -- Penipot: 86 -> 94
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; equivalente generico verificado por composicion; concentracion coincide; cantidad difiere 40≠10; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 897;  -- Sedalmerck C/40 tabletas: 76 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; equivalente generico verificado por composicion; cantidad difiere 10≠24; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 723;  -- XL-3 C/10: 78 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; concentracion coincide; cantidad difiere 20≠60; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 725;  -- Novakosid senosidos A-B 8.6 mg C: 78 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; equivalente generico verificado por composicion; cantidad difiere 10≠24; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 770;  -- Next tabletas C/10: 78 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; concentracion coincide; cantidad difiere 80≠20; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 779;  -- Aspirina 500 mg: 78 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; equivalente generico verificado por composicion; cantidad difiere 50≠10; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 781;  -- Alka-Seltzer: 78 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; cantidad difiere 50≠12; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 810;  -- Bicarbonato Sobres: 77 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; concentracion coincide; cantidad difiere 16≠24; forma equivalente tableta~pastilla' || ' | recalibrado 2026-08-15' WHERE id = 791;  -- Graneodin F (flurbiprofeno): 100 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; cantidad difiere 20≠12; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 822;  -- Amifarin: 78 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; concentracion coincide; cantidad difiere 60≠30; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 834;  -- Aspirina Junior 100 mg C/60: 78 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; concentracion coincide; cantidad difiere 8≠12; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 838;  -- Alliviax Garganta C/8 tabletas: 78 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; concentracion coincide; cantidad difiere 40≠20; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 841;  -- Aspirina 500 mg C/40: 78 -> 90
UPDATE producto_precios_referencia SET confianza = 90, notas = 'principios activos completos; concentracion coincide; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 835;  -- Nazil Ofteno Solucion Oftalmica : 88 -> 90
UPDATE producto_precios_referencia SET confianza = 85, notas = 'principios activos completos; concentracion coincide; cantidad difiere 2≠10; forma coincide' || ' | recalibrado 2026-08-15' WHERE id = 758;  -- Redoxon 1g 2-pack Naranja: 100 -> 85

-- ── No son el mismo producto. Se borran.
--   Neo-Melubrina jarabe             al competidor le faltan 1/2 principios activos (metoclop
--   Tabcin Noche C/12                al competidor le faltan 1/4 principios activos (doxilami
--   XL-3 VR C/24                     al competidor le faltan 1/3 principios activos (amantadi
--   Tabcin 500 C/12                  al competidor le faltan 1/4 principios activos (fenilefr
--   Tabcin Active C/12               al competidor le faltan 1/4 principios activos (guaifene
--   Sedalmerck C/20 tabletas         al competidor le faltan 1/3 principios activos (fenilefr
DELETE FROM producto_precios_referencia WHERE id IN (
    888, 763, 776, 795, 796, 847
);

-- ── Tampoco se pueden verificar, pero aqui el dato que falta es NUESTRO, no del
-- competidor. Se borran igual para no dejar nada sin verificar en la tabla, y se
-- recuperan solas al completar el catalogo y volver a correr el sync:
--   sku FC-08344716  La Femme vitaminas menopausi   falta principio_activo vs LA FEMME CIMICIFUGA/VIT/ISOFLAV 30
--   sku FC-0211225  Dibenel cápsulas vitaminas o   falta principio_activo vs DIBENEL SIMI DIAB PLUS 30CAP 30 CA
--   sku FC-3B001F9B  Amlodipino                     falta concentracion    vs AMLODIPINO 5MG 10 TABLETAS
--   sku FC-65054135  TUMS                           falta concentracion    vs CARBONATO DE CALCIO 750MG 24 TABLE
--   sku FC-4A0245DA  Amlodipino                     falta concentracion    vs AMLODIPINO 5MG 10 TABLETAS
--   sku FC-97BEFA1A  Amlodipino                     falta concentracion    vs AMLODIPINO 5MG 10 TABLETAS
--   sku FC-E9C38DC4  Ciprofloxacino G.I             falta concentracion    vs CIPROFLOXACINO 250 MG 12 TABLETAS
--   sku FC-7AF7ACB5  Charlyn (Ciprofloxacino)       falta concentracion    vs CIPROFLOXACINO 250 MG 12 TABLETAS
DELETE FROM producto_precios_referencia WHERE id IN (
    903, 904, 764, 766, 844, 846, 865, 870
);

COMMIT;

select confianza, count(*) as refs from producto_precios_referencia where tipo='venta' group by confianza order by confianza desc;
