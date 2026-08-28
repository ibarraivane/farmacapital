-- Correccion de catalogo: Neo-Melubrina jarabe (sku FC-50003151, id 476)
-- Generado 2026-08-15
--
-- CONFIRMA ANTES DE CORRER: son datos clinicos y el criterio es tuyo.
--
-- Salio al revisar por que una referencia de precio buena no se podia verificar. El dato
-- equivocado no era la referencia, era el nuestro. El registro se contradice solo:
--
--   nombre             : Neo-Melubrina jarabe
--   presentacion       : 100 ML
--   forma_farmaceutica : Inyectable        <-- contradice al nombre y a la presentacion
--   principio_activo   : Dipirona + Metoclopramida
--   concentracion      : (vacia)
--
-- Contra lo que dicen las dos fuentes externas del mismo producto:
--   Excel Similares : NEO MELUBRINA METAMIZOL SODICO 5G/100ML JBE 120ML
--   API Similares   : NEO-MELUBRINA JARABE INFANTIL SABOR FRAMBUESA FRASCO CON 100 ML
--
-- Dipirona y metamizol son el mismo farmaco, esa parte esta bien. Lo que sobra es la
-- metoclopramida: ninguna de las dos fuentes la menciona, y por ese activo fantasma el
-- comparador concluia "al competidor le falta un principio activo" y descartaba un match
-- que en realidad es correcto (misma marca, 5g/100ml, jarabe).

BEGIN;

UPDATE productos
SET principio_activo  = 'Metamizol sodico',
    forma_farmaceutica = 'Jarabe',
    concentracion      = '5 g/100 mL'
WHERE sku = 'FC-50003151';

COMMIT;

-- Comprobacion
select sku, nombre, principio_activo, forma_farmaceutica, concentracion, presentacion
from productos where sku = 'FC-50003151';

-- Aparte, y sin tocar nada: nos cuesta $118.58 y Similares vende su jarabe de 120 ml en
-- $51.00. Aunque el nuestro es de marca, esa diferencia no se explica por marca. Vale
-- revisar si el costo quedo capturado de otro empaque o si hay un problema de compra.
