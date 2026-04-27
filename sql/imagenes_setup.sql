-- FARMAX — Setup imágenes (columnas, placeholder global, RPCs auxiliares)
-- Ejecutar en Supabase SQL Editor DESPUÉS de refactor_fase6d (fn_require_admin).
-- Idempotente: IF NOT EXISTS / CREATE OR REPLACE.
--
-- Nota: banners y productos usan imagen_url + imagen_mobile_url (tienda / Admin).
-- Las RPCs admin_upsert_banner y admin_actualizar_imagen_banner escriben ambas en banners.

begin;

-- 1. Columnas (por si faltan en proyectos viejos)
alter table public.banners add column if not exists imagen_url text;
alter table public.banners add column if not exists imagen_mobile_url text;
alter table public.productos add column if not exists imagen_url text;
alter table public.productos add column if not exists imagen_mobile_url text;

-- 2. Placeholder global (configuracion.clave única)
insert into public.configuracion (clave, valor)
values ('placeholder_producto_url', '')
on conflict (clave) do nothing;

-- 3. Actualizar imagen de producto (admin/gerente via fn_require_admin)
create or replace function public.admin_actualizar_imagen_producto(
  p_session_token text,
  p_producto_id bigint,
  p_imagen_url text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_url text;
begin
  perform public.fn_require_admin(p_session_token::uuid);
  v_url := nullif(trim(p_imagen_url), '');
  update public.productos
  set imagen_url = v_url,
      imagen_mobile_url = v_url
  where id = p_producto_id;
  if not found then
    raise exception 'Producto no encontrado';
  end if;
end;
$$;

comment on function public.admin_actualizar_imagen_producto(text, bigint, text) is
  'Actualiza imagen_url e imagen_mobile_url del producto (misma URL). Requiere admin/gerente.';

-- 4. Actualizar imagen de banner
create or replace function public.admin_actualizar_imagen_banner(
  p_session_token text,
  p_banner_id bigint,
  p_imagen_url text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_url text;
begin
  perform public.fn_require_admin(p_session_token::uuid);
  v_url := nullif(trim(p_imagen_url), '');
  update public.banners
  set imagen_url = v_url,
      imagen_mobile_url = v_url
  where id = p_banner_id;
  if not found then
    raise exception 'Banner no encontrado';
  end if;
end;
$$;

comment on function public.admin_actualizar_imagen_banner(text, bigint, text) is
  'Actualiza imagen_url e imagen_mobile_url del banner. Requiere admin/gerente.';

-- 5. Placeholder global
create or replace function public.admin_actualizar_placeholder(
  p_session_token text,
  p_url text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.fn_require_admin(p_session_token::uuid);
  insert into public.configuracion (clave, valor)
  values ('placeholder_producto_url', coalesce(nullif(trim(p_url), ''), ''))
  on conflict (clave) do update set valor = excluded.valor;
end;
$$;

comment on function public.admin_actualizar_placeholder(text, text) is
  'Guarda URL pública del placeholder de productos en configuracion. Requiere admin/gerente.';

grant execute on function public.admin_actualizar_imagen_producto(text, bigint, text) to anon, authenticated;
grant execute on function public.admin_actualizar_imagen_banner(text, bigint, text) to anon, authenticated;
grant execute on function public.admin_actualizar_placeholder(text, text) to anon, authenticated;

commit;
