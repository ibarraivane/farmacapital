-- FarmaCapital — Storage buckets banners/productos + RLS + listado admin
-- Ejecutar en Supabase SQL Editor si falla "new row violates row-level security policy".

begin;

-- Buckets públicos (ImageUploader usa nombres cortos: banners | productos)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'banners',
  'banners',
  true,
  12582912,
  array['image/jpeg','image/png','image/webp','image/gif']::text[]
)
on conflict (id) do update set
  public = true,
  file_size_limit = 12582912,
  allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif']::text[];

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'productos',
  'productos',
  true,
  12582912,
  array['image/jpeg','image/png','image/webp']::text[]
)
on conflict (id) do update set
  public = true,
  file_size_limit = 12582912,
  allowed_mime_types = array['image/jpeg','image/png','image/webp']::text[];

-- Políticas Storage (anon + authenticated — el admin usa anon key + RPC de sesión)
drop policy if exists "fc_banners_select_public" on storage.objects;
create policy "fc_banners_select_public"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'banners');

drop policy if exists "fc_productos_select_public" on storage.objects;
create policy "fc_productos_select_public"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'productos');

drop policy if exists "fc_banners_insert" on storage.objects;
create policy "fc_banners_insert"
  on storage.objects for insert
  to anon, authenticated
  with check (bucket_id = 'banners');

drop policy if exists "fc_banners_update" on storage.objects;
create policy "fc_banners_update"
  on storage.objects for update
  to anon, authenticated
  using (bucket_id = 'banners')
  with check (bucket_id = 'banners');

drop policy if exists "fc_banners_delete" on storage.objects;
create policy "fc_banners_delete"
  on storage.objects for delete
  to anon, authenticated
  using (bucket_id = 'banners');

drop policy if exists "fc_productos_insert" on storage.objects;
create policy "fc_productos_insert"
  on storage.objects for insert
  to anon, authenticated
  with check (bucket_id = 'productos');

drop policy if exists "fc_productos_update" on storage.objects;
create policy "fc_productos_update"
  on storage.objects for update
  to anon, authenticated
  using (bucket_id = 'productos')
  with check (bucket_id = 'productos');

drop policy if exists "fc_productos_delete" on storage.objects;
create policy "fc_productos_delete"
  on storage.objects for delete
  to anon, authenticated
  using (bucket_id = 'productos');

-- Admin: listar todos los banners (incluye inactivos; RLS pública solo activo=true)
create or replace function public.admin_listar_banners(p_session_token uuid)
returns setof public.banners
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_empleado(p_session_token);
  return query
    select * from public.banners
    order by orden asc, id asc;
end;
$$;

grant execute on function public.admin_listar_banners(uuid) to anon, authenticated;

commit;
