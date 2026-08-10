-- FARMACAPITAL — Productos de prueba para testing
-- Ejecutar TODO el bloque en Supabase SQL Editor (una sola ejecución)

DELETE FROM public.productos WHERE sku LIKE 'GEN-%';

INSERT INTO public.productos (
  nombre,
  sku,
  precio,
  costo,
  stock,
  stock_minimo,
  stock_unidades,
  categoria,
  tipo,
  descripcion,
  codigo_barras,
  requiere_receta,
  activo
) VALUES
  ('Paracetamol 500mg Tab', 'GEN-001', 35.00, 18.00, 150, 20, 0, 'Analgésicos', 'GENERICO', 'Analgésico y antipirético. Caja 20 tabletas', '7501234560001', false, true),
  ('Ibuprofeno 400mg Tab', 'GEN-002', 48.00, 24.00, 120, 20, 0, 'Analgésicos', 'GENERICO', 'Antiinflamatorio no esteroideo. Caja 20 tabletas', '7501234560002', false, true),
  ('Amoxicilina 500mg Cap', 'GEN-003', 85.00, 42.00, 80, 15, 0, 'Antibióticos', 'GENERICO', 'Antibiótico de amplio espectro. Caja 12 cápsulas', '7501234560003', true, true),
  ('Omeprazol 20mg Cap', 'GEN-004', 62.00, 31.00, 100, 15, 0, 'Gastrointestinal', 'GENERICO', 'Inhibidor de bomba de protones. Caja 14 cápsulas', '7501234560004', false, true),
  ('Metformina 850mg Tab', 'GEN-005', 55.00, 27.00, 90, 15, 0, 'Diabetes', 'GENERICO', 'Antidiabético oral. Caja 30 tabletas', '7501234560005', true, true),
  ('Loratadina 10mg Tab', 'GEN-006', 42.00, 21.00, 130, 20, 0, 'Alergias', 'GENERICO', 'Antihistamínico. Caja 10 tabletas', '7501234560006', false, true),
  ('Enalapril 10mg Tab', 'GEN-007', 68.00, 34.00, 75, 15, 0, 'Cardiovascular', 'GENERICO', 'Antihipertensivo IECA. Caja 30 tabletas', '7501234560007', true, true),
  ('Atorvastatina 20mg Tab', 'GEN-008', 95.00, 47.00, 60, 10, 0, 'Cardiovascular', 'GENERICO', 'Reductor de colesterol. Caja 30 tabletas', '7501234560008', true, true),
  ('Azitromicina 500mg Tab', 'GEN-009', 78.00, 39.00, 70, 10, 0, 'Antibióticos', 'GENERICO', 'Antibiótico macrólido. Caja 3 tabletas', '7501234560009', true, true),
  ('Clonazepam 0.5mg Tab', 'GEN-010', 72.00, 36.00, 50, 10, 0, 'Neurológicos', 'GENERICO', 'Ansiolítico benzodiacepínico. Caja 30 tabletas', '7501234560010', true, true),
  ('Dexametasona 4mg/2ml Amp', 'GEN-011', 58.00, 29.00, 45, 10, 0, 'Corticoides', 'GENERICO', 'Corticoide inyectable. Caja 3 ampolletas', '7501234560011', true, true),
  ('Diclofenaco 100mg Supos', 'GEN-012', 65.00, 32.00, 55, 10, 0, 'Analgésicos', 'GENERICO', 'Antiinflamatorio rectal. Caja 5 supositorios', '7501234560012', false, true),
  ('Vitamina C 500mg Tab', 'GEN-013', 38.00, 19.00, 200, 30, 0, 'Vitaminas', 'GENERICO', 'Suplemento vitamínico. Caja 30 tabletas', '7501234560013', false, true),
  ('Complejo B Tab', 'GEN-014', 45.00, 22.00, 180, 30, 0, 'Vitaminas', 'GENERICO', 'Suplemento vitaminas del complejo B. Caja 30 tabletas', '7501234560014', false, true),
  ('Alcohol Isopropílico 70% 1L', 'GEN-015', 52.00, 26.00, 85, 15, 0, 'Antisépticos', 'GENERICO', 'Antiséptico para uso externo. Frasco 1 litro', '7501234560015', false, true),
  ('Gasas Estériles 10x10cm', 'GEN-016', 28.00, 14.00, 120, 20, 0, 'Curación', 'GENERICO', 'Apósito estéril. Paquete 10 piezas', '7501234560016', false, true),
  ('Insulina Glargina 100UI/mL', 'GEN-017', 285.00, 142.00, 30, 5, 0, 'Diabetes', 'GENERICO', 'Insulina de acción prolongada. Frasco 10mL', '7501234560017', true, true),
  ('Salbutamol Aerosol 100mcg', 'GEN-018', 148.00, 74.00, 40, 8, 0, 'Respiratorio', 'GENERICO', 'Broncodilatador. Inhalador 200 dosis', '7501234560018', true, true),
  ('Sertralina 50mg Tab', 'GEN-019', 118.00, 59.00, 35, 8, 0, 'Neurológicos', 'GENERICO', 'Antidepresivo ISRS. Caja 30 tabletas', '7501234560019', true, true),
  ('Suero Oral Rehidratante', 'GEN-020', 22.00, 11.00, 250, 40, 0, 'Gastrointestinal', 'GENERICO', 'Sales de rehidratación oral. Sobre 27.9g', '7501234560020', false, true);

SELECT sku, nombre, precio, stock, activo
FROM public.productos
WHERE sku LIKE 'GEN-%'
ORDER BY sku;
