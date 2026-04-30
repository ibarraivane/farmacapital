-- FARMAX — Columna imagen_url_mobile + RPC admin_upsert_banner (conserva video_url)
-- Ejecutar en Supabase SQL Editor (idempotente). Después de banners_video_url.sql.

alter table public.banners
  add column if not exists imagen_url_mobile text;

comment on column public.banners.imagen_url_mobile is
  'Imagen para viewport estrecho; si es null, la tienda usa imagen_mobile_url o imagen_url.';

update public.banners
set imagen_url_mobile = imagen_mobile_url
where (imagen_url_mobile is null or trim(imagen_url_mobile) = '')
  and imagen_mobile_url is not null
  and trim(imagen_mobile_url) <> '';

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
      imagen_url, imagen_mobile_url, imagen_url_mobile, modo_visualizacion, video_url
    )
    values (
      p_payload->>'titulo', p_payload->>'subtitulo', p_payload->>'descripcion',
      p_payload->>'emoji', p_payload->>'bg', p_payload->>'cta',
      p_payload->>'pagina', coalesce((p_payload->>'orden')::int, 0),
      coalesce((p_payload->>'activo')::boolean, true),
      coalesce(p_payload->>'slot', 'hero'),
      nullif(trim(p_payload->>'imagen_url'), ''),
      nullif(trim(p_payload->>'imagen_mobile_url'), ''),
      nullif(trim(p_payload->>'imagen_url_mobile'), ''),
      coalesce(nullif(trim(p_payload->>'modo_visualizacion'), ''), 'imagen_fondo'),
      nullif(trim(p_payload->>'video_url'), '')
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
        then nullif(trim(p_payload->>'imagen_mobile_url'), '') else imagen_mobile_url end,
      imagen_url_mobile = case when p_payload ? 'imagen_url_mobile'
        then nullif(trim(p_payload->>'imagen_url_mobile'), '') else imagen_url_mobile end,
      modo_visualizacion = coalesce(nullif(trim(p_payload->>'modo_visualizacion'), ''), modo_visualizacion),
      video_url = case when p_payload ? 'video_url'
        then nullif(trim(p_payload->>'video_url'), '') else video_url end
    where id = p_id;
    if not found then raise exception 'Banner % no encontrado', p_id; end if;
    v_banner_id := p_id;
  end if;

  return jsonb_build_object('success', true, 'banner_id', v_banner_id);
end;
$$;

grant execute on function public.admin_upsert_banner(uuid, bigint, jsonb) to anon, authenticated;
