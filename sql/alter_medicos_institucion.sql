-- Institución que expidió el título (dato útil en receta México)
ALTER TABLE public.medicos
  ADD COLUMN IF NOT EXISTS institucion text;

COMMENT ON COLUMN public.medicos.institucion IS
  'Universidad / institución que expidió el título profesional (impreso en receta).';
