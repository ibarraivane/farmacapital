-- Crea un lote PEPS para stock que ya existe en productos (sin sumar unidades).
-- Usar cuando hay stock pero no hay lote activo → no se puede guardar caducidad.
-- NO modifica precio ni cantidad total (trigger resync deja stock = sum(lotes)).

create or replace function public.admin_crear_lote_stock_existente(
  p_session_token   uuid,
  p_producto_id     bigint,
  p_fecha_caducidad date default null,
  p_numero_lote     text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_stock integer;
  v_costo numeric;
  v_sku text;
  v_lid bigint;
  v_numero text;
begin
  v_actor := public.fn_require_admin(p_session_token);

  select p.stock, p.costo, p.sku
  into v_stock, v_costo, v_sku
  from public.productos p
  where p.id = p_producto_id
  for update;

  if not found then
    raise exception 'Producto % no existe', p_producto_id;
  end if;

  if coalesce(v_stock, 0) <= 0 then
    raise exception 'Producto sin stock — usá Recibir mercancía para entrar unidades';
  end if;

  if exists (
    select 1 from public.lotes l
    where l.producto_id = p_producto_id
      and coalesce(l.activo, true) = true
      and coalesce(l.cantidad_actual, 0) > 0
  ) then
    raise exception 'El producto ya tiene lote(s) activo(s) — editá la caducidad del lote existente';
  end if;

  v_numero := coalesce(
    nullif(btrim(p_numero_lote), ''),
    'INV-' || coalesce(nullif(btrim(v_sku), ''), p_producto_id::text) || '-' || to_char(now(), 'YYYYMMDD')
  );

  insert into public.lotes (
    producto_id,
    numero_lote,
    cantidad_inicial,
    cantidad_actual,
    fecha_caducidad,
    costo_unitario,
    activo
  ) values (
    p_producto_id,
    v_numero,
    v_stock,
    v_stock,
    p_fecha_caducidad,
    coalesce(v_costo, 0),
    true
  )
  returning id into v_lid;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'crear_lote_stock_existente',
      'lotes',
      v_lid::text,
      jsonb_build_object(
        'producto_id', p_producto_id,
        'cantidad', v_stock,
        'fecha_caducidad', p_fecha_caducidad,
        'numero_lote', v_numero
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'lote_id', v_lid, 'cantidad', v_stock);
end;
$$;

grant execute on function public.admin_crear_lote_stock_existente(uuid, bigint, date, text) to anon, authenticated;
