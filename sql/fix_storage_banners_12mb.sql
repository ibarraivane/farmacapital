-- FARMAX — Fix rápido: subir límite de uploads en Storage bucket "banners" a 12MB
-- Ejecutar en Supabase SQL Editor.

update storage.buckets
set
  file_size_limit = 12582912,
  allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif']::text[]
where id = 'banners';

-- Opcional: si también quieres 12MB para productos, descomenta:
-- update storage.buckets
-- set
--   file_size_limit = 12582912,
--   allowed_mime_types = array['image/jpeg','image/png','image/webp']::text[]
-- where id = 'productos';
