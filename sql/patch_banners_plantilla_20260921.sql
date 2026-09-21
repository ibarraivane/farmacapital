-- FARMACAPITAL — Banners por plantilla (producto / servicio / categoría / imagen propia)
-- 21-sep-2026. Idempotente. Conserva el flujo de imagen_propia.

begin;

alter table public.banners
  add column if not exists plantilla text not null default 'imagen_propia',
  add column if not exists producto_ids integer[] default '{}',
  add column if not exists descuento_pct numeric,
  add column if not exists destino text,
  add column if not exists vigente_desde date,
  add column if not exists vigente_hasta date,
  add column if not exists ocultar_sin_stock boolean not null default true;

alter table public.banners drop constraint if exists banners_plantilla_check;
alter table public.banners
  add constraint banners_plantilla_check
  check (plantilla in ('producto','servicio','categoria','imagen_propia'));

comment on column public.banners.plantilla is
  'producto|servicio|categoria|imagen_propia. El precio "ahora" no se guarda: se calcula en tienda.';
comment on column public.banners.destino is
  'cotizar | consultorio | categoria:<nombre> | página interna.';

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
declare
  v_actor bigint;
  v_banner_id bigint;
  v_plantilla text;
  v_ids integer[];
  v_rx boolean;
begin
  v_actor := public.fn_require_admin(p_session_token);

  v_plantilla := coalesce(nullif(trim(p_payload->>'plantilla'), ''), 'imagen_propia');
  if v_plantilla not in ('producto','servicio','categoria','imagen_propia') then
    v_plantilla := 'imagen_propia';
  end if;

  v_ids := coalesce(
    array(
      select (value #>> '{}')::int
      from jsonb_array_elements(coalesce(p_payload->'producto_ids', '[]'::jsonb))
    ),
    '{}'
  );

  if v_plantilla = 'producto' then
    if coalesce(array_length(v_ids, 1), 0) < 1 then
      raise exception 'El banner de producto necesita un producto.';
    end if;
    select coalesce(bool_or(p.requiere_receta), false) into v_rx
    from public.productos p where p.id = any(v_ids);
    if v_rx then
      raise exception 'No se puede promocionar un medicamento que requiere receta.';
    end if;
  end if;

  if p_id is null then
    insert into public.banners (
      titulo, subtitulo, descripcion, emoji, bg, cta, pagina, orden, activo, slot,
      imagen_url, imagen_mobile_url, imagen_url_mobile, modo_visualizacion, video_url,
      plantilla, producto_ids, descuento_pct, destino, vigente_desde, vigente_hasta, ocultar_sin_stock
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
      nullif(trim(p_payload->>'video_url'), ''),
      v_plantilla,
      v_ids,
      nullif(p_payload->>'descuento_pct', '')::numeric,
      nullif(trim(p_payload->>'destino'), ''),
      nullif(p_payload->>'vigente_desde', '')::date,
      nullif(p_payload->>'vigente_hasta', '')::date,
      coalesce((p_payload->>'ocultar_sin_stock')::boolean, true)
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
        then nullif(trim(p_payload->>'video_url'), '') else video_url end,
      plantilla = v_plantilla,
      producto_ids = case when p_payload ? 'producto_ids' then v_ids else producto_ids end,
      descuento_pct = case when p_payload ? 'descuento_pct'
        then nullif(p_payload->>'descuento_pct', '')::numeric else descuento_pct end,
      destino = case when p_payload ? 'destino'
        then nullif(trim(p_payload->>'destino'), '') else destino end,
      vigente_desde = case when p_payload ? 'vigente_desde'
        then nullif(p_payload->>'vigente_desde', '')::date else vigente_desde end,
      vigente_hasta = case when p_payload ? 'vigente_hasta'
        then nullif(p_payload->>'vigente_hasta', '')::date else vigente_hasta end,
      ocultar_sin_stock = coalesce((p_payload->>'ocultar_sin_stock')::boolean, ocultar_sin_stock)
    where id = p_id;
    if not found then raise exception 'Banner % no encontrado', p_id; end if;
    v_banner_id := p_id;
  end if;

  return jsonb_build_object('success', true, 'banner_id', v_banner_id);
end;
$$;

grant execute on function public.admin_upsert_banner(uuid, bigint, jsonb) to anon, authenticated;

commit;
