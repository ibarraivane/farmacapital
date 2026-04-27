-- FARMAX — Setup imágenes (columnas, placeholder global, RPCs auxiliares)
-- Ejecutar en Supabase SQL Editor DESPUÉS de refactor_fase6d (fn_require_admin).
-- Idempotente: IF NOT EXISTS / CREATE OR REPLACE.
--
-- Nota: banners y productos usan imagen_url + imagen_mobile_url (tienda / Admin).
-- Las RPCs admin_upsert_banner y admin_actualizar_imagen_banner escriben ambas en banners.
-- admin_upsert_banner también usa slot (Zona en el home: hero | strip | tile). Ver sql/banners_slot.sql.

begin;

-- 1. Columnas (por si faltan en proyectos viejos)
alter table public.banners add column if not exists imagen_url text;
alter table public.banners add column if not exists imagen_mobile_url text;
alter table public.banners add column if not exists slot text default 'hero';

comment on column public.banners.slot is 'hero=carrusel superior | strip=franja horizontal | tile=rejilla';
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

-- 6. admin_upsert_banner — DEBE persistir imagen_url / imagen_mobile_url (la versión F6b no lo hace).
create or replace function public.admin_upsert_banner(
  p_session_token uuid,
  p_id            bigint,
  p_payload       jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_actor bigint; v_banner_id bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_id is null then
    insert into public.banners (
      titulo, subtitulo, descripcion, emoji, bg, cta, pagina, orden, activo, slot,
      imagen_url, imagen_mobile_url
    )
    values (
      p_payload->>'titulo', p_payload->>'subtitulo', p_payload->>'descripcion',
      p_payload->>'emoji', p_payload->>'bg', p_payload->>'cta',
      p_payload->>'pagina', coalesce((p_payload->>'orden')::int, 0),
      coalesce((p_payload->>'activo')::boolean, true),
      coalesce(p_payload->>'slot', 'hero'),
      nullif(trim(p_payload->>'imagen_url'), ''),
      nullif(trim(p_payload->>'imagen_mobile_url'), '')
    ) returning id into v_banner_id;
  else
    update public.banners set
      titulo      = coalesce(p_payload->>'titulo', titulo),
      subtitulo   = coalesce(p_payload->>'subtitulo', subtitulo),
      descripcion = coalesce(p_payload->>'descripcion', descripcion),
      emoji       = coalesce(p_payload->>'emoji', emoji),
      bg          = coalesce(p_payload->>'bg', bg),
      cta         = coalesce(p_payload->>'cta', cta),
      pagina      = coalesce(p_payload->>'pagina', pagina),
      orden       = coalesce((p_payload->>'orden')::int, orden),
      activo      = coalesce((p_payload->>'activo')::boolean, activo),
      slot        = coalesce(p_payload->>'slot', slot),
      imagen_url = case when p_payload ? 'imagen_url'
        then nullif(trim(p_payload->>'imagen_url'), '') else imagen_url end,
      imagen_mobile_url = case when p_payload ? 'imagen_mobile_url'
        then nullif(trim(p_payload->>'imagen_mobile_url'), '') else imagen_mobile_url end
    where id = p_id;
    if not found then raise exception 'Banner % no encontrado', p_id; end if;
    v_banner_id := p_id;
  end if;

  return jsonb_build_object('success', true, 'banner_id', v_banner_id);
end;
$$;

comment on function public.admin_upsert_banner(uuid, bigint, jsonb) is
  'Alta/edición de banner con imagen_url e imagen_mobile_url (Storage). Requiere admin/gerente.';

grant execute on function public.admin_upsert_banner(uuid, bigint, jsonb) to anon, authenticated;

grant execute on function public.admin_actualizar_imagen_producto(text, bigint, text) to anon, authenticated;
grant execute on function public.admin_actualizar_imagen_banner(text, bigint, text) to anon, authenticated;
grant execute on function public.admin_actualizar_placeholder(text, text) to anon, authenticated;

commit;
