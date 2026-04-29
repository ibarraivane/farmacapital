-- FARMAX — Modo de visualización de banners (solo imagen vs imagen + texto)
-- Ejecutar en Supabase SQL Editor (idempotente).

alter table public.banners
  add column if not exists modo_visualizacion text default 'imagen_fondo';

comment on column public.banners.modo_visualizacion is
  'imagen_fondo = texto editable sobre imagen/fondo | imagen_completa = solo imagen sin overlays';

-- Persistir modo desde Admin (requiere columna anterior)
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
      imagen_url, imagen_mobile_url, modo_visualizacion
    )
    values (
      p_payload->>'titulo', p_payload->>'subtitulo', p_payload->>'descripcion',
      p_payload->>'emoji', p_payload->>'bg', p_payload->>'cta',
      p_payload->>'pagina', coalesce((p_payload->>'orden')::int, 0),
      coalesce((p_payload->>'activo')::boolean, true),
      coalesce(p_payload->>'slot', 'hero'),
      nullif(trim(p_payload->>'imagen_url'), ''),
      nullif(trim(p_payload->>'imagen_mobile_url'), ''),
      coalesce(nullif(trim(p_payload->>'modo_visualizacion'), ''), 'imagen_fondo')
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
      modo_visualizacion = coalesce(nullif(trim(p_payload->>'modo_visualizacion'), ''), modo_visualizacion)
    where id = p_id;
    if not found then raise exception 'Banner % no encontrado', p_id; end if;
    v_banner_id := p_id;
  end if;

  return jsonb_build_object('success', true, 'banner_id', v_banner_id);
end;
$$;

grant execute on function public.admin_upsert_banner(uuid, bigint, jsonb) to anon, authenticated;
