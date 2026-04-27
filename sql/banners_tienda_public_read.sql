-- FARMAX — La tienda debe leer banners activos como usuario anónimo (anon)
--
-- SÍNTOMA
--   Los banners se guardan en Admin pero el home sigue mostrando textos/imágenes
--   de plantilla (fallback en Tienda.jsx) o no se actualizan.
--
-- CAUSA TÍPICA
--   • RLS activado en public.banners sin política SELECT para anon, o
--   • Falta GRANT SELECT ON public.banners TO anon
--   En ambos casos PostgREST devuelve 0 filas sin error claro.
--
-- CÓMO APLICAR: Supabase → SQL Editor → ejecutar este archivo completo.
-- Idempotente.

begin;

grant select on public.banners to anon, authenticated;

alter table public.banners enable row level security;

drop policy if exists "rls_banners_public_read" on public.banners;
create policy "rls_banners_public_read"
  on public.banners
  for select
  to anon, authenticated
  using (activo = true);

commit;
