-- Recibir: no se cierra si falta MMAA de anaquel.
-- Si hay cajas grises sin pistola, entra el stock confirmado y el resto queda pendiente.
-- 21 ago 2026. Idempotente. Pegar en Supabase → SQL Editor.

begin;

create or replace function public.recepcion_cerrar(
  p_session_token uuid,
  p_recepcion_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_rec public.recepciones%rowtype;
  v_item record;
  v_lote_id bigint;
  v_numero text;
  v_subtotal numeric := 0;
  v_pendientes int := 0;
  v_mapeados int := 0;
  v_anaquel_sin_cad int := 0;
  v_gris_sin_cad int := 0;
  v_estado text;
  v_diff numeric;
begin
  v_user := public.fn_require_empleado(p_session_token);

  select * into v_rec from public.recepciones where id = p_recepcion_id for update;
  if not found then raise exception 'recepcion no existe'; end if;
  if v_rec.estado <> 'borrador' then raise exception 'esta recepcion ya esta cerrada'; end if;

  select
    count(*) filter (where confirmado and not pendiente_alta),
    count(*) filter (where pendiente_alta),
    count(*) filter (where lote_id is not null and fecha_caducidad is null),
    count(*) filter (where not confirmado and not pendiente_alta),
    coalesce(sum(cantidad * coalesce(costo_estimado, 0)) filter (where confirmado), 0)
  into v_mapeados, v_pendientes, v_anaquel_sin_cad, v_gris_sin_cad, v_subtotal
  from public.recepcion_items
  where recepcion_id = p_recepcion_id;

  if v_anaquel_sin_cad > 0 then
    raise exception 'Faltan % caducidad(es) de producto que ya está en anaquel. Escanea y teclea MMAA.', v_anaquel_sin_cad;
  end if;
  if v_mapeados = 0 then
    raise exception 'Confirma al menos un renglón con caducidad (pistola + MMAA).';
  end if;

  for v_item in
    select i.*
    from public.recepcion_items i
    where i.recepcion_id = p_recepcion_id
      and i.confirmado
      and not i.pendiente_alta
      and i.producto_id is not null
      and i.lote_id is null
    order by i.id
  loop
    if v_item.fecha_caducidad is null then
      raise exception 'Falta caducidad en un renglón confirmado';
    end if;
    v_numero := coalesce(
      nullif(btrim(v_item.numero_lote), ''),
      'RX-' || coalesce(nullif(btrim(v_rec.folio), ''), to_char(now(), 'YYYYMMDD'))
        || '-' || v_item.id::text
    );
    select lote_id into v_lote_id
    from public.receive_merchandise_lote(
      v_item.producto_id, v_item.cantidad, v_numero,
      v_item.fecha_caducidad, v_item.costo_estimado, v_rec.proveedor, v_user
    );
    update public.recepcion_items
    set lote_id = v_lote_id, numero_lote = v_numero
    where id = v_item.id;
  end loop;

  v_diff := case
    when v_rec.total_ticket is null then 0
    else round(v_subtotal - v_rec.total_ticket, 2)
  end;

  if v_gris_sin_cad > 0 then
    update public.recepciones
    set
      subtotal_estimado = round(v_subtotal, 2),
      diferencia = v_diff,
      capturado_por = coalesce(capturado_por, v_user),
      updated_at = now()
    where id = p_recepcion_id;
    return public.fc_recepcion_json(p_recepcion_id);
  end if;

  if v_pendientes > 0 then
    v_estado := 'pendiente_alta';
  elsif v_rec.total_ticket is not null and abs(v_diff) > 1 then
    v_estado := 'descuadre';
  else
    v_estado := 'confirmada';
  end if;

  update public.recepciones
  set
    estado = v_estado,
    subtotal_estimado = round(v_subtotal, 2),
    diferencia = v_diff,
    cerrado_en = now(),
    capturado_por = coalesce(capturado_por, v_user),
    updated_at = now()
  where id = p_recepcion_id;

  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

grant execute on function public.recepcion_cerrar(uuid, bigint) to anon, authenticated;

commit;
