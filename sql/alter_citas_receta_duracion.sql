-- FARMAX: duración de consulta + medicamentos prescritos estructurados (JSON)
-- Ejecutar en Supabase SQL Editor.

ALTER TABLE public.citas
  ADD COLUMN IF NOT EXISTS medicamentos_prescritos jsonb DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS consulta_fin_at timestamptz,
  ADD COLUMN IF NOT EXISTS duracion_consulta_segundos integer;

COMMENT ON COLUMN public.citas.medicamentos_prescritos IS
  'Array JSON: [{ producto_id?, medicamento, cantidad?, dosis, indicaciones, surtido: pendiente|farmax|externa, pedido_surtido_id? }] — producto_id enlaza inventario Farmax para KPI y caja.';
COMMENT ON COLUMN public.citas.consulta_fin_at IS 'Momento en que la consulta se marcó terminada (doctora o lista de espera).';
COMMENT ON COLUMN public.citas.duracion_consulta_segundos IS 'consulta_fin_at - confirmada_inicio_at (si ambos existen).';
