-- FARMAX: consultorio — pago en caja, canal, reparto doctor/farmacia, ficha clínica, receta surtida
-- Ejecutar en Supabase SQL Editor (Run without RLS si aplica).

ALTER TABLE public.citas
  ADD COLUMN IF NOT EXISTS canal text DEFAULT 'web',
  ADD COLUMN IF NOT EXISTS pago_estado text DEFAULT 'pagada',
  ADD COLUMN IF NOT EXISTS pedido_consulta_id bigint REFERENCES public.pedidos(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS confirmada_inicio_at timestamptz,
  ADD COLUMN IF NOT EXISTS precio_consulta_cobrado numeric,
  ADD COLUMN IF NOT EXISTS ingreso_doctor numeric,
  ADD COLUMN IF NOT EXISTS ingreso_farmacia numeric,
  ADD COLUMN IF NOT EXISTS signos_vitales jsonb DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS expediente_json jsonb DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS receta_surtido_en text;

COMMENT ON COLUMN public.citas.canal IS 'web | mostrador | pos';
COMMENT ON COLUMN public.citas.pago_estado IS 'pendiente | pagada';
COMMENT ON COLUMN public.citas.receta_surtido_en IS 'farmax | externa | pendiente';

ALTER TABLE public.procedimientos_medicos
  ADD COLUMN IF NOT EXISTS plantilla_consumibles jsonb DEFAULT '[]'::jsonb;

COMMENT ON COLUMN public.procedimientos_medicos.plantilla_consumibles IS 'Ej: [{"producto_id":1,"cantidad":2}]';
