-- ============================================================================
-- DESCRIPCIONES COMPLETAS - Poblado automático basado en nombre del producto
-- ============================================================================
-- Este SQL asigna descripciones específicas según el tipo de medicamento

-- ANTIBIÓTICOS
UPDATE productos SET descripcion = 'Antibiótico'
WHERE (nombre ILIKE '%Amoxicilina%' OR nombre ILIKE '%Cefalexina%' OR nombre ILIKE '%Azitromicina%'
    OR nombre ILIKE '%Levofloxacino%' OR nombre ILIKE '%Ciprofloxacino%' OR nombre ILIKE '%Penicilina%'
    OR nombre ILIKE '%Cefixima%' OR nombre ILIKE '%Cefuroxima%') AND descripcion = 'Medicamento';

-- ANTIINFLAMATORIOS Y ANALGÉSICOS
UPDATE productos SET descripcion = 'Analgésico para dolor'
WHERE (nombre ILIKE '%Ibuprofeno%' OR nombre ILIKE '%Paracetamol%' OR nombre ILIKE '%Tafirol%'
    OR nombre ILIKE '%Ibupirac%' OR nombre ILIKE '%Actron%' OR nombre ILIKE '%Aspirina%'
    OR nombre ILIKE '%Diclofenac%' OR nombre ILIKE '%Naproxeno%' OR nombre ILIKE '%Meloxicam%'
    OR nombre ILIKE '%Piroxicam%' OR nombre ILIKE '%Ketorolac%' OR nombre ILIKE '%Indomethacin%')
    AND descripcion = 'Medicamento';

-- ANTIALÉRGICOS
UPDATE productos SET descripcion = 'Antialérgico'
WHERE (nombre ILIKE '%Loratadina%' OR nombre ILIKE '%Cetirizina%' OR nombre ILIKE '%Fexofenadina%'
    OR nombre ILIKE '%Difenhidramina%' OR nombre ILIKE '%Claritin%' OR nombre ILIKE '%Allegra%'
    OR nombre ILIKE '%Desloratadina%') AND descripcion = 'Medicamento';

-- DESCONGESTIONANTES Y RINITIS
UPDATE productos SET descripcion = 'Descongestionante nasal'
WHERE (nombre ILIKE '%Afrin%' OR nombre ILIKE '%Otrivine%' OR nombre ILIKE '%Spray%nasal%'
    OR nombre ILIKE '%Fenilefrina%' OR nombre ILIKE '%Oximetazolina%' OR nombre ILIKE '%Drixoral%')
    AND descripcion = 'Medicamento';

-- ANTITUSIVOS Y EXPECTORANTES
UPDATE productos SET descripcion = 'Antitusivo/Expectorante'
WHERE (nombre ILIKE '%Robitussin%' OR nombre ILIKE '%Tusinal%' OR nombre ILIKE '%Tos%'
    OR nombre ILIKE '%Cough%' OR nombre ILIKE '%Bromhexina%' OR nombre ILIKE '%Ambroxol%'
    OR nombre ILIKE '%Dextrometorfano%') AND descripcion = 'Medicamento';

-- PROTECTORES GÁSTRICOS
UPDATE productos SET descripcion = 'Protector gástrico'
WHERE (nombre ILIKE '%Omeprazol%' OR nombre ILIKE '%Ranitidina%' OR nombre ILIKE '%Famotidina%'
    OR nombre ILIKE '%Pantoprazol%' OR nombre ILIKE '%Lansoprazol%' OR nombre ILIKE '%Rabeprazol%'
    OR nombre ILIKE '%Sucralfato%') AND descripcion = 'Medicamento';

-- PROBIÓTICOS Y DIGESTIVOS
UPDATE productos SET descripcion = 'Digestivo/Probiótico'
WHERE (nombre ILIKE '%Probiótico%' OR nombre ILIKE '%Acidophilus%' OR nombre ILIKE '%Lactobacillus%'
    OR nombre ILIKE '%Bifidobacterium%' OR nombre ILIKE '%Enzimas%digestivas%')
    AND descripcion = 'Medicamento';

-- ANTIDIARREICOS
UPDATE productos SET descripcion = 'Antidiarreico'
WHERE (nombre ILIKE '%Loperamida%' OR nombre ILIKE '%Imodium%' OR nombre ILIKE '%Bismuto%'
    OR nombre ILIKE '%Tanino%') AND descripcion = 'Medicamento';

-- VITAMINAS Y SUPLEMENTOS
UPDATE productos SET descripcion = 'Suplemento vitamínico'
WHERE (nombre ILIKE '%Vitamina%' OR nombre ILIKE '%Multivitamínico%' OR nombre ILIKE '%B12%'
    OR nombre ILIKE '%Vitamina C%' OR nombre ILIKE '%Vitamina D%' OR nombre ILIKE '%Vitamina E%'
    OR nombre ILIKE '%Complejo B%') AND descripcion = 'Medicamento';

-- MINERALES Y SUPLEMENTOS
UPDATE productos SET descripcion = 'Suplemento mineral'
WHERE (nombre ILIKE '%Calcio%' OR nombre ILIKE '%Hierro%' OR nombre ILIKE '%Zinc%'
    OR nombre ILIKE '%Magnesio%' OR nombre ILIKE '%Potasio%' OR nombre ILIKE '%Selenio%')
    AND descripcion = 'Medicamento';

-- REHIDRATANTES
UPDATE productos SET descripcion = 'Rehidratación oral electrolítica'
WHERE (nombre ILIKE '%Electrolit%' OR nombre ILIKE '%Pedialyte%' OR nombre ILIKE '%Suero%oral%'
    OR nombre ILIKE '%Sales de rehidratación%') AND descripcion = 'Medicamento';

-- ANTIHISTAMÍNICOS
UPDATE productos SET descripcion = 'Antihistamínico'
WHERE (nombre ILIKE '%Histamin%' OR nombre ILIKE '%Antihistamin%') AND descripcion = 'Medicamento';

-- ANTIESPASMÓDICOS
UPDATE productos SET descripcion = 'Antiespasmódico'
WHERE (nombre ILIKE '%Espasmo%' OR nombre ILIKE '%Mebeverina%' OR nombre ILIKE '%Trimebutina%')
    AND descripcion = 'Medicamento';

-- HIPNÓTICOS Y SEDANTES
UPDATE productos SET descripcion = 'Sedante/Hipnótico'
WHERE (nombre ILIKE '%Melatonina%' OR nombre ILIKE '%Diazepam%' OR nombre ILIKE '%Alprazolam%'
    OR nombre ILIKE '%Lorazepam%' OR nombre ILIKE '%Dormilon%') AND descripcion = 'Medicamento';

-- ANTIINFLAMATORIOS TÓPICOS
UPDATE productos SET descripcion = 'Crema antiinflamatoria'
WHERE (nombre ILIKE '%Crema%' OR nombre ILIKE '%Pomada%' OR nombre ILIKE '%Ungüento%'
    OR nombre ILIKE '%Gel%' OR nombre ILIKE '%Ointment%') AND nombre ILIKE '%inflamatori%'
    AND descripcion = 'Medicamento';

-- PRODUCTOS DE HIGIENE
UPDATE productos SET descripcion = 'Producto de higiene'
WHERE categoria = 'Higiene' AND descripcion = 'Medicamento';

-- SUEROS Y SOLUCIONES
UPDATE productos SET descripcion = 'Solución oftalmológica'
WHERE (nombre ILIKE '%Suero%' OR nombre ILIKE '%Solución%' OR nombre ILIKE '%Oftálmico%'
    OR nombre ILIKE '%Gotas%ojos%') AND descripcion = 'Medicamento';

-- ANTISÉPTICOS Y DESINFECTANTES
UPDATE productos SET descripcion = 'Antiséptico/Desinfectante'
WHERE (nombre ILIKE '%Agua oxigenada%' OR nombre ILIKE '%Hipoclorito%' OR nombre ILIKE '%Alcohol%'
    OR nombre ILIKE '%Betadine%' OR nombre ILIKE '%Mersalyl%' OR nombre ILIKE '%Desinfectant%')
    AND descripcion = 'Medicamento';

-- VENDAJES Y MATERIALES DE CURA
UPDATE productos SET descripcion = 'Material de cura'
WHERE (nombre ILIKE '%Venda%' OR nombre ILIKE '%Gasa%' OR nombre ILIKE '%Algodón%'
    OR nombre ILIKE '%Adhesivo%' OR nombre ILIKE '%Curitas%' OR nombre ILIKE '%Apósito%'
    OR nombre ILIKE '%Bandaje%') AND descripcion = 'Medicamento';

-- LUBRICANTES Y ÍNTIMOS
UPDATE productos SET descripcion = 'Lubricante íntimo'
WHERE (nombre ILIKE '%Lubricante%' OR nombre ILIKE '%Preservativo%' OR nombre ILIKE '%Condón%')
    AND descripcion = 'Medicamento';

-- CREMAS DENTALES Y BUCALES
UPDATE productos SET descripcion = 'Producto de higiene bucal'
WHERE (nombre ILIKE '%Crema dental%' OR nombre ILIKE '%Pasta dental%' OR nombre ILIKE '%Enjuague%'
    OR nombre ILIKE '%Hilo dental%' OR nombre ILIKE '%Cepillo%') AND descripcion = 'Medicamento';

-- BRONCODILATADORES
UPDATE productos SET descripcion = 'Broncodilatador'
WHERE (nombre ILIKE '%Broncodilata%' OR nombre ILIKE '%Salbutamol%' OR nombre ILIKE '%Albuterol%'
    OR nombre ILIKE '%Terbutalina%') AND descripcion = 'Medicamento';

-- DESCONGESTIONANTES ORALES
UPDATE productos SET descripcion = 'Descongestionante oral'
WHERE (nombre ILIKE '%Fenilefrina%' OR nombre ILIKE '%Pseudoefedrina%' OR nombre ILIKE '%Descongestionante%')
    AND descripcion = 'Medicamento';

-- VERIFICACIÓN FINAL
SELECT
  descripcion,
  COUNT(*) as total,
  COUNT(CASE WHEN descripcion = 'Medicamento' THEN 1 END) as genérico
FROM productos
GROUP BY descripcion
ORDER BY total DESC;
