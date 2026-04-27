-- FARMAX — Parche puntual: columna faltante en banners tras imagenes_setup.sql v1
--
-- SÍNTOMA
--   Al guardar un banner (RPC admin_upsert_banner) o al usar admin_actualizar_imagen_banner:
--   error PostgreSQL tipo: column "imagen_mobile_url" does not exist
--
-- CAUSA
--   Una versión anterior de sql/imagenes_setup.sql añadía solo banners.imagen_url.
--   El frontend y las RPCs esperan también banners.imagen_mobile_url (como en
--   sql/patch_tienda_imagenes_banners_productos.sql).
--
-- CÓMO APLICAR (Supabase)
--   1. SQL Editor → New query
--   2. Pegar este archivo completo y ejecutar (Run)
--   3. Opcional: volver a ejecutar sql/imagenes_setup.sql actualizado para alinear comentarios/RPCs
--
-- Idempotente: IF NOT EXISTS.

begin;

alter table public.banners add column if not exists imagen_url text;
alter table public.banners add column if not exists imagen_mobile_url text;

commit;
