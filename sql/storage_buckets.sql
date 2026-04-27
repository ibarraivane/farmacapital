-- FARMAX — Buckets Storage públicos: banners, productos (nombres cortos)
-- Ejecutar en Supabase SQL Editor. Convive con sql/storage_farmax_tienda.sql (farmax-*)
-- si usás ambos esquemas; este archivo es el pedido para uploads vía ImageUploader (PASO 2).

-- Bucket público para banners
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'banners',
  'banners',
  true,
  5242880,
  array['image/jpeg','image/png','image/webp','image/gif']::text[]
)
on conflict (id) do update set
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif']::text[];

-- Bucket público para productos
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'productos',
  'productos',
  true,
  5242880,
  array['image/jpeg','image/png','image/webp']::text[]
)
on conflict (id) do update set
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg','image/png','image/webp']::text[];

drop policy if exists "Lectura pública de banners" on storage.objects;
create policy "Lectura pública de banners" on storage.objects
  for select
  using (bucket_id = 'banners');

drop policy if exists "Lectura pública de productos" on storage.objects;
create policy "Lectura pública de productos" on storage.objects
  for select
  using (bucket_id = 'productos');

drop policy if exists "Admin puede subir banners" on storage.objects;
create policy "Admin puede subir banners" on storage.objects
  for insert
  with check (bucket_id = 'banners');

drop policy if exists "Admin puede actualizar banners" on storage.objects;
create policy "Admin puede actualizar banners" on storage.objects
  for update
  using (bucket_id = 'banners');

drop policy if exists "Admin puede borrar banners" on storage.objects;
create policy "Admin puede borrar banners" on storage.objects
  for delete
  using (bucket_id = 'banners');

drop policy if exists "Admin puede subir productos" on storage.objects;
create policy "Admin puede subir productos" on storage.objects
  for insert
  with check (bucket_id = 'productos');

drop policy if exists "Admin puede actualizar productos" on storage.objects;
create policy "Admin puede actualizar productos" on storage.objects
  for update
  using (bucket_id = 'productos');

drop policy if exists "Admin puede borrar productos" on storage.objects;
create policy "Admin puede borrar productos" on storage.objects
  for delete
  using (bucket_id = 'productos');
