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

-- Huérfanas: la ficha ya no tiene foto pero la galería sigue.
delete from public.producto_imagenes pi
 using public.productos p
 where p.id = pi.producto_id
   and coalesce(btrim(p.imagen_url), '') = ''
   and coalesce(btrim(p.imagen_mobile_url), '') = '';

notify pgrst, 'reload schema';

commit;
