-- FARMAX — Supabase Storage: buckets públicos para tienda + políticas
-- Ejecutar en Supabase SQL Editor (una vez). Si falla por políticas duplicadas,
-- ejecutá los DROP POLICY y volvé a correr.
--
-- Seguridad: el anon key ya está en el frontend. Para producción fuerte, preferí
-- Edge Function con service_role o JWT de Supabase Auth en políticas RLS.
--
-- Orden recomendado: 1) este archivo  2) patch_tienda_imagenes_banners_productos.sql

insert into storage.buckets (id, name, public)
values
  ('farmax-banners', 'farmax-banners', true),
  ('farmax-productos', 'farmax-productos', true)
on conflict (id) do update set public = true;

drop policy if exists "farmax_banners_select_public" on storage.objects;
drop policy if exists "farmax_productos_select_public" on storage.objects;
drop policy if exists "farmax_banners_insert" on storage.objects;
drop policy if exists "farmax_banners_update" on storage.objects;
drop policy if exists "farmax_banners_delete" on storage.objects;
drop policy if exists "farmax_productos_insert" on storage.objects;
drop policy if exists "farmax_productos_update" on storage.objects;
drop policy if exists "farmax_productos_delete" on storage.objects;

create policy "farmax_banners_select_public"
  on storage.objects for select
  using (bucket_id = 'farmax-banners');

create policy "farmax_productos_select_public"
  on storage.objects for select
  using (bucket_id = 'farmax-productos');

create policy "farmax_banners_insert"
  on storage.objects for insert
  with check (bucket_id = 'farmax-banners');

create policy "farmax_banners_update"
  on storage.objects for update
  using (bucket_id = 'farmax-banners');

create policy "farmax_banners_delete"
  on storage.objects for delete
  using (bucket_id = 'farmax-banners');

create policy "farmax_productos_insert"
  on storage.objects for insert
  with check (bucket_id = 'farmax-productos');

create policy "farmax_productos_update"
  on storage.objects for update
  using (bucket_id = 'farmax-productos');

create policy "farmax_productos_delete"
  on storage.objects for delete
  using (bucket_id = 'farmax-productos');
