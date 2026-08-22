-- Recibir: si el documento vino de PDF/CSV, la pistola solo confirma renglones
-- del ticket. Un EAN ajeno no inserta ni suma stock.
-- 21 ago 2026. Idempotente.

begin;

create or replace function public.recepcion_agregar_item(
  p_session_token uuid,
  p_recepcion_id bigint,
  p_codigo text,
  p_cantidad integer,
  p_fecha_caducidad date default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_estado text;
  v_codigo text;
  v_producto_id bigint;
  v_nombre text;
  v_costo numeric;
  v_item_id bigint;
  v_pendiente boolean := false;
  v_gray public.recepcion_items%rowtype;
  v_es_ticket boolean := false;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_cantidad is null or p_cantidad <= 0 then
    raise exception 'cantidad invalida';
  end if;

  select estado into v_estado from public.recepciones where id = p_recepcion_id for update;
  if not found then raise exception 'recepcion no existe'; end if;
  if v_estado <> 'borrador' then raise exception 'solo se edita una recepcion en borrador'; end if;

  v_codigo := btrim(coalesce(p_codigo, ''));
  if v_codigo = '' then raise exception 'codigo requerido'; end if;

  v_producto_id := public.fc_buscar_producto_escaneo(v_codigo);

  select exists (
    select 1 from public.recepcion_items
    where recepcion_id = p_recepcion_id
      and origen in ('pdf', 'csv')
  ) into v_es_ticket;

  select * into v_gray
  from public.recepcion_items i
  where i.recepcion_id = p_recepcion_id
    and not i.confirmado
    and (
      (v_producto_id is not null and i.producto_id = v_producto_id)
      or public.fc_match_codigo_barras(v_codigo, i.codigo_escaneado)
      or upper(btrim(coalesce(i.codigo_escaneado, ''))) = upper(v_codigo)
    )
  order by i.id
  limit 1;

  if found then
    if p_fecha_caducidad is null then
      raise exception 'Caducidad requerida (MMAA de la caja)';
    end if;
    return public.recepcion_confirmar_item(
      p_session_token, v_gray.id, p_fecha_caducidad, p_cantidad
    );
  end if;

  if v_es_ticket then
    if exists (
      select 1 from public.recepcion_items i
      where i.recepcion_id = p_recepcion_id
        and (
          (v_producto_id is not null and i.producto_id = v_producto_id)
          or public.fc_match_codigo_barras(v_codigo, i.codigo_escaneado)
          or upper(btrim(coalesce(i.codigo_escaneado, ''))) = upper(v_codigo)
        )
    ) then
      raise exception 'Ya esta en este ticket';
    end if;
    raise exception 'No corresponde a ninguno de los items de este ticket';
  end if;

  if v_producto_id is not null then
    select nombre, costo into v_nombre, v_costo
    from public.productos where id = v_producto_id;
  else
    if v_codigo ~ '^[0-9]{8,}$' then
      v_pendiente := true;
      v_nombre := 'Pendiente de alta';
    else
      raise exception 'Producto no encontrado. Escanea el codigo de barras de la caja.';
    end if;
  end if;

  if v_pendiente then
    select id into v_item_id
    from public.recepcion_items
    where recepcion_id = p_recepcion_id
      and pendiente_alta
      and codigo_escaneado = v_codigo
      and fecha_caducidad is not distinct from p_fecha_caducidad
    limit 1;
  else
    select id into v_item_id
    from public.recepcion_items
    where recepcion_id = p_recepcion_id
      and not pendiente_alta
      and producto_id = v_producto_id
      and confirmado
      and fecha_caducidad is not distinct from p_fecha_caducidad
    limit 1;
  end if;

  if v_item_id is not null then
    update public.recepcion_items
    set cantidad = cantidad + p_cantidad, confirmado = true, origen = coalesce(origen, 'pistola')
    where id = v_item_id;
  else
    insert into public.recepcion_items (
      recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
      cantidad, fecha_caducidad, costo_estimado, pendiente_alta,
      origen, confirmado
    ) values (
      p_recepcion_id, v_producto_id, v_codigo, v_nombre,
      p_cantidad, p_fecha_caducidad, v_costo, v_pendiente,
      'pistola', true
    )
    returning id into v_item_id;
  end if;

  update public.recepciones set updated_at = now() where id = p_recepcion_id;
  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

grant execute on function public.recepcion_agregar_item(uuid, bigint, text, integer, date) to anon, authenticated;

commit;
