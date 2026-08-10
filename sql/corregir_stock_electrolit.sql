-- CORRECCIÓN DE STOCK: Electrolit debe tener 2 unidades (no 1)
-- Verificado en ticket FarmaLive: todos los Electrolits tienen cantidad 2
-- Ejecutar en Supabase SQL Editor

-- Ver stock actual
SELECT id, nombre, stock FROM productos
WHERE nombre ILIKE '%Electrolit%'
ORDER BY id;

-- Actualizar a cantidad correcta
UPDATE productos
SET stock = 2
WHERE nombre ILIKE '%Electrolit%';

-- Verificar cambio
SELECT id, nombre, stock FROM productos
WHERE nombre ILIKE '%Electrolit%'
ORDER BY id;
