-- ============================================================================
-- DESCRIPCIONES POR PATRÓN QUÍMICO/FARMACOLÓGICO
-- Usa terminaciones y patrones típicos de medicamentos
-- ============================================================================

-- ANTIBIÓTICOS BETA-LACTÁMICOS (terminan en -cilina, -cefal, -xil)
UPDATE productos SET descripcion = 'Antibiótico'
WHERE descripcion = 'Medicamento' AND (
  nombre ~* '(cilina|cefal|cefax|xilo|oxil|roxil|cimba|cloxa|xacin|romicina|mitacin|amicin|taflor|morfan|pidem)'
  OR nombre ILIKE '%Clarith%' OR nombre ILIKE '%Claritro%'
);

-- ANTIFLAMATORIOS (terminan en -fenac, -proxen, -ibupro, -prof)
UPDATE productos SET descripcion = 'Antiinflamatorio'
WHERE descripcion = 'Medicamento' AND (
  nombre ~* '(fenac|proxen|ibupro|profeno|loxicam|meloxic|piroxic|ketorol)'
);

-- PARA HIPERTENSIÓN (terminan en -pril, -sartan, -olol)
UPDATE productos SET descripcion = 'Para la presión arterial'
WHERE descripcion = 'Medicamento' AND (
  nombre ~* '(opril|losartan|sartan|molol|sapril)'
  OR nombre ILIKE '%Bisoprolol%' OR nombre ILIKE '%Enalapril%'
);

-- PARA EL CORAZÓN (terminan en -verapamil, -diltiazem)
UPDATE productos SET descripcion = 'Para el corazón'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Verapamil%' OR nombre ILIKE '%Diltiazem%' OR nombre ILIKE '%Digoxina%'
);

-- PARA LA GARGANTA Y BRONQUIOS (palabra clave: brom, broq)
UPDATE productos SET descripcion = 'Para garganta/bronquios'
WHERE descripcion = 'Medicamento' AND (
  nombre ~* '(bromhex|bromexina|cepobrom|pentibroq|bromelina)'
  OR nombre ILIKE '%Brom%'
);

-- PARA EL HÍGADO Y VESÍCULA (ursodeoxicolico, etc)
UPDATE productos SET descripcion = 'Para hígado/vesícula'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Ursodeoxicolico%' OR nombre ILIKE '%Silibarina%' OR nombre ILIKE '%Desmodio%'
);

-- PARA LOS OJOS (Gotas, solución oftalmológica)
UPDATE productos SET descripcion = 'Gotas oftalmológicas'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Gotas%' OR nombre ILIKE '%Oftalmológ%' OR nombre ILIKE '%Oftálmic%'
  OR nombre ILIKE '%Oculeno%' OR nombre ILIKE '%Nazil%' OR nombre ILIKE '%Ofteno%'
);

-- ANTIVIRALES (terminan en -ciclovir, -clovir)
UPDATE productos SET descripcion = 'Antiviral'
WHERE descripcion = 'Medicamento' AND (
  nombre ~* '(ciclovir|clovir|vir)'
  OR nombre ILIKE '%Aciclovir%'
);

-- PARA INFECCIONES DE OÍDO/NARIZ
UPDATE productos SET descripcion = 'Para oído/nariz'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Otálgina%' OR nombre ILIKE '%Otifren%' OR nombre ILIKE '%Ototoxina%'
);

-- LAXANTES (palabra clave: lax, evacuante, purgante)
UPDATE productos SET descripcion = 'Laxante'
WHERE descripcion = 'Medicamento' AND (
  nombre ~* '(laxant|evacuant|purgant)'
  OR nombre ILIKE '%Riopan%' OR nombre ILIKE '%Lactulose%'
);

-- PARA ARTRITIS/OSTEOPOROSIS
UPDATE productos SET descripcion = 'Para artritis/huesos'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Reumatic%' OR nombre ILIKE '%Osteo%' OR nombre ILIKE '%Artrit%'
  OR nombre ILIKE '%Condrotin%'
);

-- PARA DIABETES
UPDATE productos SET descripcion = 'Antidiabético'
WHERE descripcion = 'Medicamento' AND (
  nombre ~* '(sulfonilurea|metiforma|glibencla|gliburid|gliptina|acarbo)'
  OR nombre ILIKE '%Glucoph%'
);

-- VITAMINA COMPLEJO B (12H, etc)
UPDATE productos SET descripcion = 'Vitamina complejo B'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%12H%' OR nombre ILIKE '%Neurobion%' OR nombre ILIKE '%Bedoyecta%'
  OR nombre ILIKE '%Tiamina%' OR nombre ILIKE '%Complejo B%'
);

-- PARA NERVIOS/ANSIEDAD
UPDATE productos SET descripcion = 'Para los nervios'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Sedalmerk%' OR nombre ILIKE '%Sedalmer%' OR nombre ILIKE '%Valium%'
  OR nombre ILIKE '%Valclan%' OR nombre ILIKE '%Ansioso%'
);

-- PARA INFLAMACIÓN DE GARGANTA
UPDATE productos SET descripcion = 'Para inflamación'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Broncolin%' OR nombre ILIKE '%Bicoestol%'
  OR nombre ILIKE '%Ajolotius%'
);

-- PARA ÁCIDO/REFLUJO
UPDATE productos SET descripcion = 'Para ácido/reflujo'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Alka%' OR nombre ILIKE '%Seltzer%'
);

-- PARA DOLORES DE CABEZA ESPECÍFICOS
UPDATE productos SET descripcion = 'Para migraña/cefalea'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Migra%' OR nombre ILIKE '%Cefalea%' OR nombre ILIKE '%Migrasil%'
);

-- ANTIBIÓTICOS GENÉRICOS (marcas raras)
UPDATE productos SET descripcion = 'Antibiótico'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Klarix%' OR nombre ILIKE '%Epicin%' OR nombre ILIKE '%Knoricin%'
  OR nombre ILIKE '%Vanmoxol%' OR nombre ILIKE '%Gimalxina%' OR nombre ILIKE '%Penipot%'
  OR nombre ILIKE '%Cloxan%' OR nombre ILIKE '%Fasiclor%' OR nombre ILIKE '%Acroxil%'
  OR nombre ILIKE '%Cepobrom%' OR nombre ILIKE '%Cefalver%' OR nombre ILIKE '%Charlyn%'
  OR nombre ILIKE '%Terficho%' OR nombre ILIKE '%Cina%' OR nombre ILIKE '%Vernisen%'
  OR nombre ILIKE '%Tropharma%' OR nombre ILIKE '%Nalixone%' OR nombre ILIKE '%Mexapin%'
);

-- ANALGÉSICOS GENÉRICOS
UPDATE productos SET descripcion = 'Analgésico'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Diclofen%' OR nombre ILIKE '%Namifen%' OR nombre ILIKE '%Aspitak%'
  OR nombre ILIKE '%Acemetacina%' OR nombre ILIKE '%Acetilsalicilico Ef%'
);

-- PARA EL SISTEMA NERVIOSO
UPDATE productos SET descripcion = 'Para el sistema nervioso'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Neurobio%' OR nombre ILIKE '%Dolo%' OR nombre ILIKE '%Nervio%'
  OR nombre ILIKE '%Sentibel%'
);

-- OTROS (Fallback para los que queden)
UPDATE productos SET descripcion = 'Medicamento de uso específico'
WHERE descripcion = 'Medicamento';

-- VERIFICACIÓN FINAL
SELECT
  descripcion,
  COUNT(*) as total,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM productos), 1) as porcentaje
FROM productos
GROUP BY descripcion
ORDER BY total DESC;
