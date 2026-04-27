-- FARMAX — Parche puntual: columnas faltantes en public.banners (admin tienda)
--
-- SÍNTOMAS (al guardar banner desde Admin)
--   • column "imagen_mobile_url" does not exist
--   • column "slot" does not exist   ← campo "Zona en el home" (carrusel / franja / mosaico)
--
-- CAUSA
--   Tabla banners creada antes de sql/banners.sql actual o sin ejecutar sql/banners_slot.sql.
--   Las RPCs (p. ej. admin_upsert_banner) escriben imagen_url, imagen_mobile_url y slot.
--
-- CÓMO APLICAR (Supabase)
--   1. SQL Editor → New query
--   2. Pegar este archivo completo y ejecutar (Run)
--   3. Opcional: ejecutar sql/imagenes_setup.sql actualizado para RPCs/placeholder
--
-- Idempotente: IF NOT EXISTS.

begin;

alter table public.banners add column if not exists imagen_url text;
alter table public.banners add column if not exists imagen_mobile_url text;
alter table public.banners add column if not exists slot text default 'hero';

comment on column public.banners.slot is 'hero=carrusel superior | strip=franja horizontal | tile=rejilla';

commit;
