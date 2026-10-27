-- Miniaturas pregeneradas del bucket `productos` (reemplaza /render/image).
--
-- Lista las fotos que no tienen miniatura o cuya miniatura es más vieja que la
-- foto. La usa api/_lib/miniaturasJob.js con la service role. Solo lectura;
-- no toca tablas ni objetos.
--
-- Regla de nombre (igual que src/utils/tiendaCardImage.js → rutaMiniatura):
--   rappi/7501/1.webp  →  _miniaturas/480/rappi/7501/1.webp.webp

create or replace function public.fn_miniaturas_pendientes(p_limite integer default 200)
returns table (name text, updated_at timestamptz)
language sql
stable
security definer
set search_path = ''
as $$
  select o.name, o.updated_at
  from storage.objects o
  where o.bucket_id = 'productos'
    and o.name not like '\_miniaturas/%'
    and o.name ~* '\.(jpe?g|png|webp|avif)$'
    and not exists (
      select 1
      from storage.objects m
      where m.bucket_id = 'productos'
        and m.name = '_miniaturas/480/' || o.name || '.webp'
        and m.updated_at >= o.updated_at
    )
  order by o.updated_at desc
  limit greatest(1, least(coalesce(p_limite, 200), 1000));
$$;

revoke all on function public.fn_miniaturas_pendientes(integer) from public, anon, authenticated;
grant execute on function public.fn_miniaturas_pendientes(integer) to service_role;
