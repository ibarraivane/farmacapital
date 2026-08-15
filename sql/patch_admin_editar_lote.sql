-- Editar fecha de caducidad (y número de lote) de un lote existente.
-- p_quitar_caducidad = true → borra la fecha (productos sin caducidad).
-- Ejecutar en Supabase SQL Editor (o usar patch_admin_limpiar_caducidad.sql).

create or replace function public.admin_editar_lote(
  p_session_token uuid,
  p_lote_id       bigint,
  p_fecha_caducidad date default null,
  p_numero_lote   text default null,
  p_quitar_caducidad boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_prev record;
  v_fecha_despues date;
begin
  v_actor := public.fn_require_admin(p_session_token);

  select id, producto_id, numero_lote, fecha_caducidad
  into v_prev
  from public.lotes
  where id = p_lote_id and coalesce(activo, true) = true;

  if not found then
    raise exception 'Lote % no encontrado o inactivo', p_lote_id;
  end if;

  v_fecha_despues := case
    when p_quitar_caducidad then null
    when p_fecha_caducidad is not null then p_fecha_caducidad
    else v_prev.fecha_caducidad
  end;

  update public.lotes
  set
    fecha_caducidad = v_fecha_despues,
    numero_lote = coalesce(nullif(btrim(p_numero_lote), ''), numero_lote)
  where id = p_lote_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'editar_lote',
      'lotes',
      p_lote_id::text,
      jsonb_build_object(
        'producto_id', v_prev.producto_id,
        'fecha_caducidad_antes', v_prev.fecha_caducidad,
        'fecha_caducidad_despues', v_fecha_despues,
        'numero_lote_antes', v_prev.numero_lote,
        'numero_lote_despues', coalesce(nullif(btrim(p_numero_lote), ''), v_prev.numero_lote),
        'quitar_caducidad', p_quitar_caducidad
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'lote_id', p_lote_id);
end;
$$;

grant execute on function public.admin_editar_lote(uuid, bigint, date, text, boolean) to anon, authenticated;
