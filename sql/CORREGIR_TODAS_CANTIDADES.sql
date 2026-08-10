-- ============================================================================
-- CORRECCIÓN DE CANTIDADES - Ticket FarmaLive
-- ============================================================================
-- Se encontraron productos que se cargaron con cantidad 1 pero debería ser 2+
-- Ejecutar en: Supabase SQL Editor

-- ============================================================================
-- 1. ELECTROLITS (5 productos) - De 1 a 2 unidades
-- ============================================================================

UPDATE productos
SET stock = 2
WHERE nombre ILIKE '%Electrolit Uva%'
   OR nombre ILIKE '%Electrolit Coco%'
   OR nombre ILIKE '%Electrolit Eresa-Kiwi%'
   OR nombre ILIKE '%Electrolit Èresa%'
   OR nombre ILIKE '%Electrolit Mora Azul%';

-- Verificar
SELECT id, nombre, stock FROM productos
WHERE nombre ILIKE '%Electrolit%'
ORDER BY nombre;

-- ============================================================================
-- 2. OTROS PRODUCTOS CON CANTIDAD > 1
-- ============================================================================

-- REPELENTE BIOCLAP 265 ML (cantidad: 2)
UPDATE productos
SET stock = 2
WHERE nombre ILIKE '%BIOCLAP%265%' OR codigo_barras = '759684471476';

-- PROMEGA 3 CAPS (cantidad: 2)
UPDATE productos
SET stock = 2
WHERE nombre ILIKE '%PROMEGA 3%CAPS%' OR codigo_barras = '7501065095718';

-- TRIBEDOCE TAB C/30 (cantidad: 5)
UPDATE productos
SET stock = 5
WHERE nombre ILIKE '%TRIBEDOCE%TAB%' AND nombre ILIKE '%C/30%' OR codigo_barras = '75022088947797';

-- ALGODON DIBAR 200 GR (cantidad: 2)
UPDATE productos
SET stock = 2
WHERE nombre ILIKE '%ALGODON DIBAR%200%' OR codigo_barras = '75018689100101';

-- ALGODON DIBAR 60 GR (cantidad: 2)
UPDATE productos
SET stock = 2
WHERE nombre ILIKE '%ALGODON DIBAR%60%' OR codigo_barras = '7501868900127';

-- ============================================================================
-- 3. VERIFICACIÓN FINAL
-- ============================================================================

-- Ver todos los cambios
SELECT id, nombre, stock, codigo_barras FROM productos
WHERE nombre ILIKE '%Electrolit%'
   OR nombre ILIKE '%BIOCLAP%'
   OR nombre ILIKE '%PROMEGA 3%'
   OR nombre ILIKE '%TRIBEDOCE%'
   OR nombre ILIKE '%ALGODON DIBAR%'
ORDER BY nombre;

-- NOTA: Algunos productos pueden tener nombres ligeramente diferentes
-- Si los UPDATE anteriores no encontraron registros, buscar manualmente:
SELECT * FROM productos
WHERE nombre ILIKE '%BIOCLAP%' OR nombre ILIKE '%REPELENTE%'
LIMIT 10;

SELECT * FROM productos
WHERE nombre ILIKE '%PROMEGA%'
LIMIT 10;

SELECT * FROM productos
WHERE nombre ILIKE '%TRIBEDOCE%'
LIMIT 10;

SELECT * FROM productos
WHERE nombre ILIKE '%ALGODON%'
LIMIT 10;
