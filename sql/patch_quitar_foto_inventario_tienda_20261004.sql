-- Quitar la foto en inventario también la quita de la tienda.
--
-- La tienda prefiere producto_imagenes sobre productos.imagen_url.
-- Borrar solo imagen_url deja la galería (marca de agua) en la ficha.
-- Caso: Dexketoprofeno 10 Tab 25 Mg (id 915, EQ-ALP0633) — imagen_url null
-- y la caja con marca de agua sigue en producto_imagenes.
--
-- Ejecutar en Supabase SQL Editor. Idempotente.

begin;

create or replace function public.admin_quitar_fotos_producto(
  p_session_token uuid,
  p_producto_id   bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_n int;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  update public.productos
     set imagen_url = null,
         imagen_mobile_url = null
   where id = p_producto_id;

  if not found then
    raise exception 'Producto % no encontrado', p_producto_id;
  end if;

  delete from public.producto_imagenes
   where producto_id = p_producto_id;
  get diagnostics v_n = row_count;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'quitar_fotos_producto',
      'producto_imagenes',
      p_producto_id::text,
      jsonb_build_object('filas', v_n)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'producto_id', p_producto_id,
    'fotos_borradas', v_n
  );
end;
$$;

grant execute on function public.admin_quitar_fotos_producto(uuid, bigint)
  to anon, authenticated;

-- La foto guardada en la ficha pasa a ser la principal de la galería.
-- Sin esto, la tienda sigue pintando el packshot viejo de producto_imagenes.
create or replace function public.admin_fijar_foto_producto(
  p_session_token uuid,
  p_producto_id   bigint,
  p_url           text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_url text := btrim(coalesce(p_url, ''));
  v_base text;
begin
  v_actor_id := public.fn_require_admin(p_session_token);
  if v_url = '' then
    raise exception 'Falta la URL de la foto';
  end if;
  v_base := split_part(v_url, '?', 1);

  update public.productos
     set imagen_url = v_url,
         imagen_mobile_url = v_url
   where id = p_producto_id;
  if not found then
    raise exception 'Producto % no encontrado', p_producto_id;
  end if;

  update public.producto_imagenes
     set es_principal = false,
         updated_at = now()
   where producto_id = p_producto_id
     and es_principal
     and split_part(btrim(url), '?', 1) is distinct from v_base;

  insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
  select p_producto_id,
         v_url,
         coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p_producto_id), 0) + 1,
         true,
         'propia'
   where not exists (
     select 1 from public.producto_imagenes i
      where i.producto_id = p_producto_id
        and split_part(btrim(i.url), '?', 1) = v_base
   );

  update public.producto_imagenes
     set es_principal = true,
         url = v_url,
         updated_at = now()
   where producto_id = p_producto_id
     and split_part(btrim(url), '?', 1) = v_base;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'fijar_foto_producto',
      'producto_imagenes',
      p_producto_id::text,
      jsonb_build_object('url', v_url)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'producto_id', p_producto_id, 'url', v_url);
end;
$$;

grant execute on function public.admin_fijar_foto_producto(uuid, bigint, text)
  to anon, authenticated;

-- Fotos ya guardadas en la ficha que la galería sigue tapando
-- (no toca el desktop.jpg viejo: ahí la galería Rappi sigue siendo la buena).
update public.producto_imagenes i
   set es_principal = false,
       updated_at = now()
  from public.productos p
 where p.id = i.producto_id
   and i.es_principal
   and coalesce(btrim(p.imagen_url), '') <> ''
   and split_part(btrim(p.imagen_url), '?', 1) is distinct from split_part(btrim(i.url), '?', 1)
   and btrim(p.imagen_url) !~ '/productos/[0-9]+/(desktop|mobile)\.(jpe?g|png|webp)(\?.*)?$';

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       btrim(p.imagen_url),
       coalesce((select max(x.posicion) from public.producto_imagenes x where x.producto_id = p.id), 0) + 1,
       true,
       'propia'
  from public.productos p
 where coalesce(btrim(p.imagen_url), '') <> ''
   and btrim(p.imagen_url) !~ '/productos/[0-9]+/(desktop|mobile)\.(jpe?g|png|webp)(\?.*)?$'
   and not exists (
     select 1 from public.producto_imagenes i
      where i.producto_id = p.id
        and split_part(btrim(i.url), '?', 1) = split_part(btrim(p.imagen_url), '?', 1)
   )
   and not exists (
     select 1 from public.producto_imagenes i
      where i.producto_id = p.id
        and i.es_principal
   );

update public.producto_imagenes i
   set es_principal = true,
       updated_at = now()
  from public.productos p
 where p.id = i.producto_id
   and split_part(btrim(i.url), '?', 1) = split_part(btrim(p.imagen_url), '?', 1)
   and not i.es_principal
   and btrim(p.imagen_url) !~ '/productos/[0-9]+/(desktop|mobile)\.(jpe?g|png|webp)(\?.*)?$'
   and not exists (
     select 1 from public.producto_imagenes o
      where o.producto_id = i.producto_id
        and o.es_principal
        and o.id <> i.id
   );

-- Huérfanas: la ficha ya no tiene foto pero la galería sigue.
delete from public.producto_imagenes pi
 using public.productos p
 where p.id = pi.producto_id
   and coalesce(btrim(p.imagen_url), '') = ''
   and coalesce(btrim(p.imagen_mobile_url), '') = '';

notify pgrst, 'reload schema';

commit;
