-- ============================================================
-- FARMAX — F6b.3: RPCs de catálogo, lotes, citas y notas
-- ============================================================
-- Corre DESPUÉS de refactor_fase6b_rpcs_auth.sql y ..._transacciones.sql
-- Idempotente.
-- ============================================================

begin;

-- ============================================================
-- PRODUCTOS (admin)
-- ============================================================
-- NUNCA permitir escribir productos.stock desde aquí (es derivado).
-- ============================================================
create or replace function public.admin_editar_producto(
  p_session_token uuid,
  p_producto_id   bigint,
  p_patch         jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_allowed  text[] := array[
    'nombre','sku','categoria','subcategoria','marca','tipo',
    'descripcion','precio','costo','stock_min','proveedor',
    'descuento','imagen_url','codigo_barras','presentacion',
    'principio_activo','requiere_receta','notas','activo',
    'controlado','grupo_controlado','visible_tienda'
  ];
  v_patch    jsonb;
  v_key      text;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  v_patch := '{}'::jsonb;
  for v_key in select jsonb_object_keys(p_patch)
  loop
    if v_key = any(v_allowed) then
      v_patch := v_patch || jsonb_build_object(v_key, p_patch->v_key);
    end if;
  end loop;

  if v_patch = '{}'::jsonb then
    raise exception 'No hay campos permitidos para actualizar';
  end if;

  update public.productos set
    nombre            = coalesce((v_patch->>'nombre')::text, nombre),
    sku               = coalesce((v_patch->>'sku')::text, sku),
    categoria         = coalesce((v_patch->>'categoria')::text, categoria),
    subcategoria      = coalesce((v_patch->>'subcategoria')::text, subcategoria),
    marca             = coalesce((v_patch->>'marca')::text, marca),
    tipo              = coalesce((v_patch->>'tipo')::text, tipo),
    descripcion       = coalesce((v_patch->>'descripcion')::text, descripcion),
    precio            = coalesce((v_patch->>'precio')::numeric, precio),
    costo             = coalesce((v_patch->>'costo')::numeric, costo),
    stock_min         = coalesce((v_patch->>'stock_min')::int, stock_min),
    proveedor         = coalesce((v_patch->>'proveedor')::text, proveedor),
    descuento         = coalesce((v_patch->>'descuento')::numeric, descuento),
    imagen_url        = coalesce((v_patch->>'imagen_url')::text, imagen_url),
    codigo_barras     = coalesce((v_patch->>'codigo_barras')::text, codigo_barras),
    presentacion      = coalesce((v_patch->>'presentacion')::text, presentacion),
    principio_activo  = coalesce((v_patch->>'principio_activo')::text, principio_activo),
    requiere_receta   = coalesce((v_patch->>'requiere_receta')::boolean, requiere_receta),
    notas             = coalesce((v_patch->>'notas')::text, notas),
    activo            = coalesce((v_patch->>'activo')::boolean, activo)
  where id = p_producto_id;

  if not found then
    raise exception 'Producto % no encontrado', p_producto_id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'editar_producto', 'productos', p_producto_id::text, v_patch
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

create or replace function public.admin_toggle_producto(
  p_session_token uuid,
  p_producto_id   bigint,
  p_activo        boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_actor bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);
  update public.productos set activo = p_activo where id = p_producto_id;
  if not found then raise exception 'Producto % no encontrado', p_producto_id; end if;
  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,(select nombre from public.usuarios where id=v_actor),
            'toggle_producto','productos',p_producto_id::text,jsonb_build_object('activo',p_activo));
  exception when others then null; end;
  return jsonb_build_object('success', true);
end;
$$;

create or replace function public.admin_eliminar_producto(
  p_session_token uuid,
  p_producto_id   bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_actor bigint; v_tiene_ventas boolean;
begin
  v_actor := public.fn_require_admin(p_session_token);

  select exists(
    select 1 from public.pedido_items where producto_id = p_producto_id
  ) into v_tiene_ventas;

  if v_tiene_ventas then
    -- Soft-delete: evita romper historial de ventas
    update public.productos set activo = false where id = p_producto_id;
    begin
      insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
      values (v_actor,(select nombre from public.usuarios where id=v_actor),
              'soft_delete_producto','productos',p_producto_id::text,
              jsonb_build_object('motivo','tiene_ventas'));
    exception when others then null; end;
    return jsonb_build_object('success', true, 'soft_deleted', true);
  end if;

  -- Desactivar lotes asociados primero
  update public.lotes set activo = false where producto_id = p_producto_id;
  delete from public.productos where id = p_producto_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,(select nombre from public.usuarios where id=v_actor),
            'hard_delete_producto','productos',p_producto_id::text,'{}'::jsonb);
  exception when others then null; end;

  return jsonb_build_object('success', true, 'soft_deleted', false);
end;
$$;

-- ============================================================
-- BANNERS (admin)
-- ============================================================
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
    insert into public.banners (titulo, subtitulo, descripcion, emoji, bg, cta, pagina, orden, activo, slot)
    values (
      p_payload->>'titulo', p_payload->>'subtitulo', p_payload->>'descripcion',
      p_payload->>'emoji', p_payload->>'bg', p_payload->>'cta',
      p_payload->>'pagina', coalesce((p_payload->>'orden')::int, 0),
      coalesce((p_payload->>'activo')::boolean, true),
      coalesce(p_payload->>'slot', 'hero')
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
      slot        = coalesce(p_payload->>'slot', slot)
    where id = p_id;
    if not found then raise exception 'Banner % no encontrado', p_id; end if;
    v_banner_id := p_id;
  end if;

  return jsonb_build_object('success', true, 'banner_id', v_banner_id);
end;
$$;

create or replace function public.admin_toggle_banner(
  p_session_token uuid, p_id bigint, p_activo boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  update public.banners set activo = p_activo where id = p_id;
  if not found then raise exception 'Banner % no encontrado', p_id; end if;
  return jsonb_build_object('success', true);
end;
$$;

create or replace function public.admin_eliminar_banner(
  p_session_token uuid, p_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  delete from public.banners where id = p_id;
  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- PROMOCIONES (admin)
-- ============================================================
-- p_productos_ids: array de ids a asociar (sobrescribe).
-- ============================================================
create or replace function public.admin_upsert_promocion(
  p_session_token uuid,
  p_id            bigint,
  p_payload       jsonb,
  p_productos_ids bigint[] default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor    bigint;
  v_promo_id bigint;
  v_pid      bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_id is null then
    insert into public.promociones (nombre, tipo, valor, descripcion, fecha_inicio, fecha_fin, activa)
    values (
      p_payload->>'nombre',
      p_payload->>'tipo',
      (p_payload->>'valor')::numeric,
      p_payload->>'descripcion',
      nullif(p_payload->>'fecha_inicio','')::date,
      nullif(p_payload->>'fecha_fin','')::date,
      coalesce((p_payload->>'activa')::boolean, true)
    ) returning id into v_promo_id;
  else
    update public.promociones set
      nombre       = coalesce(p_payload->>'nombre', nombre),
      tipo         = coalesce(p_payload->>'tipo', tipo),
      valor        = coalesce((p_payload->>'valor')::numeric, valor),
      descripcion  = coalesce(p_payload->>'descripcion', descripcion),
      fecha_inicio = coalesce(nullif(p_payload->>'fecha_inicio','')::date, fecha_inicio),
      fecha_fin    = coalesce(nullif(p_payload->>'fecha_fin','')::date, fecha_fin),
      activa       = coalesce((p_payload->>'activa')::boolean, activa)
    where id = p_id;
    if not found then raise exception 'Promoción % no encontrada', p_id; end if;
    v_promo_id := p_id;
  end if;

  if p_productos_ids is not null then
    delete from public.promocion_productos where promocion_id = v_promo_id;
    foreach v_pid in array p_productos_ids loop
      insert into public.promocion_productos (promocion_id, producto_id)
      values (v_promo_id, v_pid)
      on conflict do nothing;
    end loop;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,(select nombre from public.usuarios where id=v_actor),
            'upsert_promocion','promociones',v_promo_id::text,
            jsonb_build_object('productos', coalesce(array_length(p_productos_ids,1),0)));
  exception when others then null; end;

  return jsonb_build_object('success', true, 'promocion_id', v_promo_id);
end;
$$;

create or replace function public.admin_toggle_promocion(
  p_session_token uuid, p_id bigint, p_activa boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  update public.promociones set activa = p_activa where id = p_id;
  if not found then raise exception 'Promoción % no encontrada', p_id; end if;
  return jsonb_build_object('success', true);
end;
$$;

create or replace function public.admin_eliminar_promocion(
  p_session_token uuid, p_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  delete from public.promocion_productos where promocion_id = p_id;
  delete from public.promociones where id = p_id;
  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- LOTES (admin / gerente)
-- ============================================================
-- Crear un lote nuevo con control explícito (distinto de
-- receive_merchandise_lote que venía del flujo de compras).
-- ============================================================
create or replace function public.admin_crear_lote(
  p_session_token uuid,
  p_producto_id   bigint,
  p_numero_lote   text,
  p_cantidad      numeric,
  p_fecha_caducidad date default null,
  p_costo_unitario  numeric default null,
  p_proveedor_id    bigint default null,
  p_notas           text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_actor bigint; v_lote_id bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_cantidad is null or p_cantidad <= 0 then
    raise exception 'cantidad debe ser > 0';
  end if;
  if not exists (select 1 from public.productos where id = p_producto_id) then
    raise exception 'Producto % no existe', p_producto_id;
  end if;

  insert into public.lotes (
    producto_id, numero_lote, cantidad_inicial, cantidad_actual,
    fecha_caducidad, costo_unitario, proveedor_id, notas, activo
  ) values (
    p_producto_id, p_numero_lote, p_cantidad, p_cantidad,
    p_fecha_caducidad, p_costo_unitario, p_proveedor_id, p_notas, true
  ) returning id into v_lote_id;

  -- Registrar movimiento de entrada
  begin
    insert into public.movimientos_inventario (
      producto_id, lote_id, tipo, cantidad, usuario_id, motivo
    ) values (
      p_producto_id, v_lote_id, 'entrada', p_cantidad, v_actor,
      'Creación manual de lote ' || p_numero_lote
    );
  exception when others then null;
  end;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,(select nombre from public.usuarios where id=v_actor),
            'crear_lote','lotes',v_lote_id::text,
            jsonb_build_object('producto_id',p_producto_id,'cantidad',p_cantidad));
  exception when others then null; end;

  return jsonb_build_object('success', true, 'lote_id', v_lote_id);
end;
$$;

create or replace function public.admin_desactivar_lote(
  p_session_token uuid,
  p_lote_id       bigint,
  p_motivo        text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_actor bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);

  update public.lotes set activo = false where id = p_lote_id;
  if not found then raise exception 'Lote % no encontrado', p_lote_id; end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,(select nombre from public.usuarios where id=v_actor),
            'desactivar_lote','lotes',p_lote_id::text,
            jsonb_build_object('motivo', p_motivo));
  exception when others then null; end;

  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- CITAS (empleado / doctor)
-- ============================================================
-- Firmas anteriores: eliminar para evitar sobrecarga ambigua con PostgREST.
drop function if exists public.crear_cita(uuid, text, text, date, text, text, bigint, text);
drop function if exists public.crear_cita(uuid, text, text, date, text, text, text, bigint);

create or replace function public.crear_cita(
  p_session_token uuid,
  p_nombre        text,
  p_telefono      text,
  p_fecha         date,
  p_hora          text,
  p_motivo        text default null,
  p_canal         text default 'mostrador',
  p_paciente_id   bigint default null,
  p_medico_id     bigint default null,
  p_notas         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_cita_id bigint;
  v_canal text;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if p_nombre is null or length(trim(p_nombre))=0 then raise exception 'Nombre requerido'; end if;
  if p_telefono is null or length(trim(p_telefono))=0 then raise exception 'Teléfono requerido'; end if;
  if p_fecha is null then raise exception 'Fecha requerida'; end if;

  v_canal := lower(trim(coalesce(p_canal, 'mostrador')));
  if v_canal not in ('web', 'mostrador', 'pos') then
    v_canal := 'mostrador';
  end if;

  insert into public.citas (
    nombre, telefono, fecha, hora, motivo, medico_id, notas, estado,
    canal, cliente_id, pago_estado
  )
  values (
    trim(p_nombre), trim(p_telefono), p_fecha, p_hora, p_motivo, p_medico_id, p_notas, 'agendada',
    v_canal, p_paciente_id, 'pendiente'
  )
  returning id into v_cita_id;

  return jsonb_build_object('success', true, 'cita_id', v_cita_id);
end;
$$;

create or replace function public.actualizar_estado_cita(
  p_session_token uuid,
  p_cita_id       bigint,
  p_estado        text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_valid text[] := array['agendada','en_consulta','completada','cancelada','no_asistio'];
begin
  perform public.fn_require_empleado(p_session_token);
  if not (p_estado = any(v_valid)) then
    raise exception 'Estado inválido: %', p_estado;
  end if;
  update public.citas set estado = p_estado where id = p_cita_id;
  if not found then raise exception 'Cita % no encontrada', p_cita_id; end if;
  return jsonb_build_object('success', true);
end;
$$;

create or replace function public.agregar_consumible_cita(
  p_session_token uuid,
  p_cita_id       bigint,
  p_producto_id   bigint,
  p_nombre        text,
  p_cantidad      int,
  p_precio        numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_cons_id bigint;
begin
  perform public.fn_require_empleado(p_session_token);
  if p_cantidad is null or p_cantidad <= 0 then
    raise exception 'cantidad debe ser > 0';
  end if;

  insert into public.consumibles_consulta (cita_id, producto_id, nombre, cantidad, precio, cobrado)
  values (p_cita_id, p_producto_id, p_nombre, p_cantidad, p_precio, false)
  returning id into v_cons_id;

  return jsonb_build_object('success', true, 'consumible_id', v_cons_id);
end;
$$;

create or replace function public.eliminar_consumible_cita(
  p_session_token uuid,
  p_consumible_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_cobrado boolean;
begin
  perform public.fn_require_empleado(p_session_token);
  select cobrado into v_cobrado from public.consumibles_consulta where id = p_consumible_id;
  if v_cobrado is null then raise exception 'Consumible % no encontrado', p_consumible_id; end if;
  if v_cobrado then raise exception 'No se puede eliminar un consumible ya cobrado'; end if;
  delete from public.consumibles_consulta where id = p_consumible_id;
  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- NOTAS CLÍNICAS (empleado)
-- ============================================================
-- Doctores guardan notas al cliente identificado por teléfono.
-- ============================================================
create or replace function public.cliente_actualizar_nota_clinica(
  p_session_token uuid,
  p_telefono      text,
  p_nota          text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_actor bigint; v_cli_id bigint;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  update public.clientes set notas = p_nota where telefono = p_telefono
  returning id into v_cli_id;

  if v_cli_id is null then
    raise exception 'Cliente con teléfono % no encontrado', p_telefono;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,(select nombre from public.usuarios where id=v_actor),
            'nota_clinica','clientes',v_cli_id::text,
            jsonb_build_object('len', length(coalesce(p_nota,''))));
  exception when others then null; end;

  return jsonb_build_object('success', true, 'cliente_id', v_cli_id);
end;
$$;

create or replace function public.admin_ajustar_nota_cliente(
  p_session_token uuid,
  p_cliente_id    bigint,
  p_nota          text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_actor bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);
  update public.clientes set notas = p_nota where id = p_cliente_id;
  if not found then raise exception 'Cliente % no encontrado', p_cliente_id; end if;
  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- Grants
-- ============================================================
grant execute on function public.admin_editar_producto(uuid, bigint, jsonb)           to anon, authenticated;
grant execute on function public.admin_toggle_producto(uuid, bigint, boolean)         to anon, authenticated;
grant execute on function public.admin_eliminar_producto(uuid, bigint)                to anon, authenticated;

grant execute on function public.admin_upsert_banner(uuid, bigint, jsonb)             to anon, authenticated;
grant execute on function public.admin_toggle_banner(uuid, bigint, boolean)           to anon, authenticated;
grant execute on function public.admin_eliminar_banner(uuid, bigint)                  to anon, authenticated;

grant execute on function public.admin_upsert_promocion(uuid, bigint, jsonb, bigint[]) to anon, authenticated;
grant execute on function public.admin_toggle_promocion(uuid, bigint, boolean)         to anon, authenticated;
grant execute on function public.admin_eliminar_promocion(uuid, bigint)                to anon, authenticated;

grant execute on function public.admin_crear_lote(uuid, bigint, text, numeric, date, numeric, bigint, text) to anon, authenticated;
grant execute on function public.admin_desactivar_lote(uuid, bigint, text)             to anon, authenticated;

grant execute on function public.crear_cita(uuid, text, text, date, text, text, text, bigint, bigint, text) to anon, authenticated;
grant execute on function public.actualizar_estado_cita(uuid, bigint, text)            to anon, authenticated;
grant execute on function public.agregar_consumible_cita(uuid, bigint, bigint, text, int, numeric) to anon, authenticated;
grant execute on function public.eliminar_consumible_cita(uuid, bigint)                to anon, authenticated;

grant execute on function public.cliente_actualizar_nota_clinica(uuid, text, text)     to anon, authenticated;
grant execute on function public.admin_ajustar_nota_cliente(uuid, bigint, text)        to anon, authenticated;

commit;

-- ============================================================
-- FIN F6b.3
-- ============================================================
-- Siguiente: refactor_fase6b_rpcs_tienda.sql (clientes self + pedidos online)
-- ============================================================
