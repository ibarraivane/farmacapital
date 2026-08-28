-- FarmaCapital — fuentes de compra.
--
-- Higiene / pañales / abarrotes:
--   El piso barato es Exprezo (Zorro Abarrotero). Ya existe en fuentes_precio.
--   City Club, Sam's y Corvi NO se dan de alta como columnas: no son
--   comparables (membresía, otro empaque, casi nunca más baratos que Zorro).
--
-- Medicamento:
--   Nadro / Marzam / Levic ya cubren. Fanasa y Saba son opcionales
--   (solo si te mandan lista; el sistema no usa tu contraseña).

INSERT INTO public.fuentes_precio (id, nombre, tipo, metodo, notas) VALUES
  ('fanasa', 'Fanasa', 'compra', 'import_archivo', 'Opcional medicamento — solo si te exportan lista.'),
  ('saba', 'Casa Saba', 'compra', 'import_archivo', 'Opcional medicamento — solo si te exportan lista.')
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  tipo = EXCLUDED.tipo,
  metodo = EXCLUDED.metodo,
  notas = EXCLUDED.notas;
