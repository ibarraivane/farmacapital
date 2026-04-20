-- Teléfono opcional en usuarios: permite NULL y evita duplicados solo cuando hay valor.
-- Ejecutar en el SQL editor de Supabase (o psql) una sola vez.

ALTER TABLE public.usuarios
  ALTER COLUMN telefono DROP NOT NULL;

ALTER TABLE public.usuarios
  DROP CONSTRAINT IF EXISTS usuarios_telefono_key;

CREATE UNIQUE INDEX IF NOT EXISTS usuarios_telefono_unique_cuando_definido
  ON public.usuarios (telefono)
  WHERE telefono IS NOT NULL AND btrim(telefono) <> '';
