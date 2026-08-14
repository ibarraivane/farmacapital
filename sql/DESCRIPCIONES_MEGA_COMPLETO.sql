-- ============================================================================
-- DESCRIPCIONES COMPLETAS - VERSIÓN MEGA (cubre más marcas y genéricos)
-- ============================================================================

-- ANTIBIÓTICOS (Beta-lactámicos, quinolonas, etc)
UPDATE productos SET descripcion = 'Antibiótico'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Amoxicilina%' OR nombre ILIKE '%Cefalexina%' OR nombre ILIKE '%Cefixima%'
  OR nombre ILIKE '%Cefaroxil%' OR nombre ILIKE '%Cefagen%' OR nombre ILIKE '%Cefalver%'
  OR nombre ILIKE '%Azitromicina%' OR nombre ILIKE '%Levofloxacino%' OR nombre ILIKE '%Ciprofloxacino%'
  OR nombre ILIKE '%Clindamicina%' OR nombre ILIKE '%Ampicilina%' OR nombre ILIKE '%Gentamicina%'
  OR nombre ILIKE '%Clamoxin%' OR nombre ILIKE '%Knoricin%' OR nombre ILIKE '%Klarix%'
  OR nombre ILIKE '%Acroxil%' OR nombre ILIKE '%Fasiclor%' OR nombre ILIKE '%Epicin%'
  OR nombre ILIKE '%Cefuroxima%' OR nombre ILIKE '%Penicilina%' OR nombre ILIKE '%Triazol%'
);

-- ANALGÉSICOS Y ANTIPIRÉTICOS
UPDATE productos SET descripcion = 'Analgésico/Antipirético'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Paracetamol%' OR nombre ILIKE '%Tafirol%' OR nombre ILIKE '%Acetaminofén%'
  OR nombre ILIKE '%Acetilsalicílico%' OR nombre ILIKE '%Aspirina%'
);

-- ANTIINFLAMATORIOS NO ESTEROIDES
UPDATE productos SET descripcion = 'Antiinflamatorio'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Ibuprofeno%' OR nombre ILIKE '%Ibupirac%' OR nombre ILIKE '%Actron%'
  OR nombre ILIKE '%Diclofenac%' OR nombre ILIKE '%Diclofen%' OR nombre ILIKE '%Naproxeno%'
  OR nombre ILIKE '%Meloxicam%' OR nombre ILIKE '%Piroxicam%' OR nombre ILIKE '%Ketorolac%'
  OR nombre ILIKE '%Indomethacin%'
);

-- ANTICOAGULANTES Y ANTIAGREGANTES
UPDATE productos SET descripcion = 'Anticoagulante'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Amifarin%' OR nombre ILIKE '%Warfarina%' OR nombre ILIKE '%Heparina%'
  OR nombre ILIKE '%Dabigatrán%' OR nombre ILIKE '%Rivaroxabán%'
);

-- ANTIGOTA
UPDATE productos SET descripcion = 'Antigota'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Alopurinol%' OR nombre ILIKE '%Febuxostat%'
);

-- ANTIALÉRGICOS
UPDATE productos SET descripcion = 'Antialérgico'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Loratadina%' OR nombre ILIKE '%Cetirizina%' OR nombre ILIKE '%Fexofenadina%'
  OR nombre ILIKE '%Desloratadina%' OR nombre ILIKE '%Azelastina%'
);

-- DESCONGESTIONANTES
UPDATE productos SET descripcion = 'Descongestionante'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Afrin%' OR nombre ILIKE '%Otrivine%' OR nombre ILIKE '%Fenilefrina%'
  OR nombre ILIKE '%Oximetazolina%' OR nombre ILIKE '%Drixoral%'
);

-- ANTITUSIVOS Y EXPECTORANTES
UPDATE productos SET descripcion = 'Antitusivo'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Robitussin%' OR nombre ILIKE '%Tusinal%' OR nombre ILIKE '%Bromhexina%'
  OR nombre ILIKE '%Ambroxol%' OR nombre ILIKE '%Dextrometorfano%'
);

-- PROTECTORES GÁSTRICOS
UPDATE productos SET descripcion = 'Protector gástrico'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Omeprazol%' OR nombre ILIKE '%Ranitidina%' OR nombre ILIKE '%Famotidina%'
  OR nombre ILIKE '%Pantoprazol%' OR nombre ILIKE '%Lansoprazol%' OR nombre ILIKE '%Rabeprazol%'
  OR nombre ILIKE '%Sucralfato%'
);

-- PROBIÓTICOS
UPDATE productos SET descripcion = 'Probiótico'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Probiótico%' OR nombre ILIKE '%Lactobacillus%' OR nombre ILIKE '%Bifidobacterium%'
  OR nombre ILIKE '%Acidophilus%'
);

-- VITAMINAS
UPDATE productos SET descripcion = 'Suplemento vitamínico'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Vitamina%' OR nombre ILIKE '%Multivitamínico%' OR nombre ILIKE '%Centrum%'
  OR nombre ILIKE '%B12%' OR nombre ILIKE '%Thiamin%' OR nombre ILIKE '%Riboflavin%'
);

-- MINERALES
UPDATE productos SET descripcion = 'Suplemento mineral'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Calcio%' OR nombre ILIKE '%Hierro%' OR nombre ILIKE '%Zinc%'
  OR nombre ILIKE '%Magnesio%' OR nombre ILIKE '%Potasio%' OR nombre ILIKE '%Selenio%'
);

-- REHIDRATANTES
UPDATE productos SET descripcion = 'Rehidratación oral'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Electrolit%' OR nombre ILIKE '%Pedialyte%' OR nombre ILIKE '%Suerox%'
  OR nombre ILIKE '%Suero%'
);

-- CREMAS DENTALES Y BUCALES
UPDATE productos SET descripcion = 'Higiene bucal'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Crema dental%' OR nombre ILIKE '%Pasta dental%' OR nombre ILIKE '%Colgate%'
  OR nombre ILIKE '%Hilo dental%' OR nombre ILIKE '%Enjuague%' OR nombre ILIKE '%Labello%'
);

-- CHAMPÚS Y PRODUCTOS CAPILARES
UPDATE productos SET descripcion = 'Producto capilar'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Champú%' OR nombre ILIKE '%Shampoo%' OR nombre ILIKE '%Shampo%'
  OR nombre ILIKE '%Pert Plus%' OR nombre ILIKE '%Herklin%' OR nombre ILIKE '%Ricitos%'
);

-- DESODORANTES
UPDATE productos SET descripcion = 'Desodorante'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Desodorante%' OR nombre ILIKE '%Deodorant%' OR nombre ILIKE '%Axe%'
  OR nombre ILIKE '%Old Spice%' OR nombre ILIKE '%Dove%' OR nombre ILIKE '%Sure%'
);

-- CREMAS Y LOCIONES CORPORALES
UPDATE productos SET descripcion = 'Crema/Loción corporal'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Crema%' OR nombre ILIKE '%Loción%' OR nombre ILIKE '%Mexsana%'
  OR nombre ILIKE '%Hinds%' OR nombre ILIKE '%Vaselina%' OR nombre ILIKE '%Pomada%'
);

-- ANTISÉPTICOS Y DESINFECTANTES
UPDATE productos SET descripcion = 'Desinfectante'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Agua oxigenada%' OR nombre ILIKE '%Betadine%' OR nombre ILIKE '%Hipoclorito%'
  OR nombre ILIKE '%Desinfect%' OR nombre ILIKE '%Antiséptic%'
);

-- SUPLEMENTOS NUTRICIONALES
UPDATE productos SET descripcion = 'Suplemento nutricional'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Leche%' OR nombre ILIKE '%Nestum%' OR nombre ILIKE '%Nidal%'
  OR nombre ILIKE '%Kinder%' OR nombre ILIKE '%Jarabe%' OR nombre ILIKE '%Maltodextrina%'
);

-- PRODUCTOS ÍNTIMOS
UPDATE productos SET descripcion = 'Producto íntimo'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Lubricante%' OR nombre ILIKE '%Condón%' OR nombre ILIKE '%Preservativo%'
  OR nombre ILIKE '%Prudence%' OR nombre ILIKE '%Trojan%'
);

-- MATERIALES DE CURA (Ya filtrado pero asegurar)
UPDATE productos SET descripcion = 'Material de cura'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Venda%' OR nombre ILIKE '%Gasa%' OR nombre ILIKE '%Algodón%'
  OR nombre ILIKE '%Curitas%' OR nombre ILIKE '%Bandaje%' OR nombre ILIKE '%Quirmex%'
  OR nombre ILIKE '%Dibar%' OR nombre ILIKE '%Jeringa%' OR nombre ILIKE '%Parche%'
);

-- OTROS MEDICAMENTOS POR PATRÓN
UPDATE productos SET descripcion = 'Medicamento'
WHERE descripcion = 'Medicamento' AND nombre LIKE '%Jr%';

-- VERIFICACIÓN FINAL
SELECT
  descripcion,
  COUNT(*) as total,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM productos), 1) as porcentaje
FROM productos
GROUP BY descripcion
ORDER BY total DESC;
