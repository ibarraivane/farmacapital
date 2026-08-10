-- Agregar descripciones de uso a productos
-- Ejecutar en Supabase SQL Editor

-- Electrolit
UPDATE productos SET descripcion = 'Rehidratación oral electrolítica'
WHERE nombre ILIKE '%Electrolit%' AND (descripcion IS NULL OR descripcion = '');

-- Analgésicos
UPDATE productos SET descripcion = 'Analgésico para dolor'
WHERE (nombre ILIKE '%Ibuprofeno%' OR nombre ILIKE '%Paracetamol%' OR nombre ILIKE '%Tafirol%')
AND (descripcion IS NULL OR descripcion = '');

-- Antiinflamatorios
UPDATE productos SET descripcion = 'Antiinflamatorio no esteroide'
WHERE (nombre ILIKE '%Diclofenac%' OR nombre ILIKE '%Naproxeno%')
AND (descripcion IS NULL OR descripcion = '');

-- Antibióticos
UPDATE productos SET descripcion = 'Antibiótico'
WHERE (nombre ILIKE '%Amoxicilina%' OR nombre ILIKE '%Cefalexina%' OR nombre ILIKE '%Azitromicina%')
AND (descripcion IS NULL OR descripcion = '');

-- Descongestionantes
UPDATE productos SET descripcion = 'Descongestionante nasal'
WHERE (nombre ILIKE '%Drixoral%' OR nombre ILIKE '%Otrivine%' OR nombre ILIKE '%Spray%nasal%')
AND (descripcion IS NULL OR descripcion = '');

-- Antitusivos
UPDATE productos SET descripcion = 'Antitusivo/Expectorante'
WHERE (nombre ILIKE '%Robitussin%' OR nombre ILIKE '%Tusinal%' OR nombre ILIKE '%tos%')
AND (descripcion IS NULL OR descripcion = '');

-- Antidiarreico
UPDATE productos SET descripcion = 'Antidiarreico'
WHERE (nombre ILIKE '%Loperamida%' OR nombre ILIKE '%Imodium%')
AND (descripcion IS NULL OR descripcion = '');

-- Vitaminas
UPDATE productos SET descripcion = 'Suplemento vitamínico'
WHERE (nombre ILIKE '%Vitamina%' OR nombre ILIKE '%Multivitamínico%' OR nombre ILIKE '%B12%')
AND (descripcion IS NULL OR descripcion = '');

-- Minerales
UPDATE productos SET descripcion = 'Suplemento mineral'
WHERE (nombre ILIKE '%Calcio%' OR nombre ILIKE '%Hierro%' OR nombre ILIKE '%Zinc%' OR nombre ILIKE '%Magnesio%')
AND (descripcion IS NULL OR descripcion = '');

-- Probióticos
UPDATE productos SET descripcion = 'Digestivo/Probiótico'
WHERE (nombre ILIKE '%Probiótico%' OR nombre ILIKE '%Acidophilus%')
AND (descripcion IS NULL OR descripcion = '');

-- Protector gástrico
UPDATE productos SET descripcion = 'Protector gástrico'
WHERE (nombre ILIKE '%Omeprazol%' OR nombre ILIKE '%Ranitidina%')
AND (descripcion IS NULL OR descripcion = '');

-- Antialérgicos
UPDATE productos SET descripcion = 'Antialérgico'
WHERE (nombre ILIKE '%Claritin%' OR nombre ILIKE '%Loratadina%' OR nombre ILIKE '%Difenhidramina%')
AND (descripcion IS NULL OR descripcion = '');

-- Higiene (por categoría)
UPDATE productos SET descripcion = 'Producto de higiene'
WHERE categoria = 'Higiene' AND (descripcion IS NULL OR descripcion = '');

-- Fallback: medicamento genérico
UPDATE productos SET descripcion = 'Medicamento'
WHERE (descripcion IS NULL OR descripcion = '');
