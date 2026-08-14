-- ============================================================================
-- BASE DE DATOS FARMACÉUTICA - DESCRIPCIONES DE MEDICAMENTOS
-- Basado en conocimiento de medicamentos comunes en Latinoamérica
-- ============================================================================

-- ANTIPARASITARIOS (Terficho, Cina, Vernisen)
UPDATE productos SET descripcion = 'Antiparasitario'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Terficho%' OR nombre ILIKE '%Cina%' OR nombre ILIKE '%Vernisen%'
  OR nombre ILIKE '%Albendazol%' OR nombre ILIKE '%Mebendazol%'
);

-- ANTIVIRALES PARA HERPES
UPDATE productos SET descripcion = 'Antiviral para herpes'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Valclan%' OR nombre ILIKE '%Valtrex%' OR nombre ILIKE '%Aciclovir%'
  OR nombre ILIKE '%Famciclovir%'
);

-- MEDICAMENTOS PARA EL HÍGADO Y VESÍCULA
UPDATE productos SET descripcion = 'Para hígado y vesícula'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Ursodesoxicolico%' OR nombre ILIKE '%Ursodeoxicólico%'
  OR nombre ILIKE '%Desmodio%' OR nombre ILIKE '%Silibarina%'
);

-- ANTAGONISTAS DE OPIOIDES
UPDATE productos SET descripcion = 'Antagonista de opioides'
WHERE descripcion = 'Medicamento' AND nombre ILIKE '%Nalixone%';

-- ANTITUSIVOS CON EXPECTORANTE
UPDATE productos SET descripcion = 'Antitusivo/Expectorante'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Pentibroxil%' OR nombre ILIKE '%Pentiver%'
  OR nombre ILIKE '%Cepobrom%' OR nombre ILIKE '%Bromexina%'
);

-- ANTIINFLAMATORIOS (AINES) GENÉRICOS
UPDATE productos SET descripcion = 'Antiinflamatorio'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Namifen%' OR nombre ILIKE '%Acemetacina%'
  OR nombre ILIKE '%Acemetac%' OR nombre ILIKE '%Inmetacina%'
);

-- ANALGÉSICOS COMBINADOS
UPDATE productos SET descripcion = 'Analgésico combinado'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Aspitak%' OR nombre ILIKE '%Acetilsalicílico Ef%'
);

-- ANTIBIÓTICOS PENICILINA
UPDATE productos SET descripcion = 'Antibiótico penicilina'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Penipot%' OR nombre ILIKE '%Penicilina%'
  OR nombre ILIKE '%Amoxil%' OR nombre ILIKE '%Ampicilina%'
);

-- ANTIBIÓTICOS CEFALOSPORINA
UPDATE productos SET descripcion = 'Antibiótico cefalosporina'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Fasiclor%' OR nombre ILIKE '%Cefuroxima%'
  OR nombre ILIKE '%Cefixima%' OR nombre ILIKE '%Cefalexina%'
);

-- ANTIBIÓTICOS FLUOROQUINOLONAS
UPDATE productos SET descripcion = 'Antibiótico fluoroquinolona'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Gimalxina%' OR nombre ILIKE '%Levofloxacino%'
  OR nombre ILIKE '%Ciprofloxacino%'
);

-- ANTIBIÓTICOS MACRÓLIDOS
UPDATE productos SET descripcion = 'Antibiótico macrólido'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Claritromicina%' OR nombre ILIKE '%Azitromicina%'
);

-- OTROS ANTIBIÓTICOS
UPDATE productos SET descripcion = 'Antibiótico'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Vanmoxol%' OR nombre ILIKE '%Acroxil%'
  OR nombre ILIKE '%Charlyn%' OR nombre ILIKE '%Epicin%'
  OR nombre ILIKE '%Knoricin%' OR nombre ILIKE '%Cloxan%'
);

-- MEDICAMENTOS CARDIOVASCULARES
UPDATE productos SET descripcion = 'Medicamento cardiovascular'
WHERE descripcion = 'Medicamento' AND (
  nombre ILIKE '%Beneventol%' OR nombre ILIKE '%Diviltac%'
  OR nombre ILIKE '%Tropharma%'
);

-- MEDICAMENTOS DE USO ESPECÍFICO (Fallback)
UPDATE productos SET descripcion = 'Medicamento de uso específico'
WHERE descripcion = 'Medicamento';

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
SELECT
  descripcion,
  COUNT(*) as total,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM productos), 1) as porcentaje
FROM productos
GROUP BY descripcion
ORDER BY total DESC;
