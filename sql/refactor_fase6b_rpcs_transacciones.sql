-- ============================================================
-- FARMAX — F6b.2: RPCs de transacciones y dinero
-- ============================================================
-- Wraps seguros para las operaciones sensibles al dinero,
-- inventario y cumplimiento regulatorio.
--
-- Corre DESPUES de refactor_fase6b_rpcs_auth.sql.
-- Este SQL es IDEMPOTENTE.
-- ============================================================

begin;

-- ============================================================
-- 1) crear_factura
-- ============================================================
-- Emite factura (simulada o real) y actualiza datos fiscales
-- del cliente si corresponde.
-- ============================================================
create or replace function public.crear_factura(
  p_session_token uuid,
  p_pedido_id     bigint,
  p_rfc           text,
  p_razon_social  text,
  p_uso_cfdi      text default 'G03',
  p_regimen       text default '616',
  p_email         text default null,
  p_pac_proveedor text default 'simulado',
  p_folio_fiscal  text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id   bigint;
  v_pedido     record;
  v_factura_id bigint;
  v_folio      text;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);

  if p_rfc is null or length(trim(p_rfc)) = 0 then
    raise exception 'RFC requerido';
  end if;
  if p_razon_social is null or length(trim(p_razon_social)) = 0 then
    raise exception 'Razón social requerida';
  end if;

  select id, cliente_id, total into v_pedido
  from public.pedidos where id = p_pedido_id;

  if v_pedido.id is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  v_folio := coalesce(p_folio_fiscal, 'SIM-' || extract(epoch from now())::bigint::text);

  insert into public.facturas (
    pedido_id, cliente_id, rfc, razon_social, uso_cfdi, regimen_fiscal,
    total, estado, folio_fiscal, pac_proveedor
  ) values (
    v_pedido.id, v_pedido.cliente_id,
    upper(trim(p_rfc)), upper(trim(p_razon_social)),
    p_uso_cfdi, p_regimen, v_pedido.total, 'pendiente',
    v_folio, p_pac_proveedor
  )
  returning id into v_factura_id;

  -- Actualizar datos fiscales del cliente si existe
  if v_pedido.cliente_id is not null then
    update public.clientes set
      rfc = upper(trim(p_rfc)),
      razon_social = upper(trim(p_razon_social)),
      regimen_fiscal = p_regimen,
      uso_cfdi = p_uso_cfdi,
      email = coalesce(nullif(trim(coalesce(p_email, '')), ''), email)
    where id = v_pedido.cliente_id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'crear_factura', 'facturas', v_factura_id::text,
      jsonb_build_object('pedido_id', v_pedido.id, 'total', v_pedido.total, 'rfc', p_rfc)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'factura_id', v_factura_id,
    'folio_fiscal', v_folio
  );
end;
$$;

-- ============================================================
-- 2) admin_eliminar_pedido
-- ============================================================
-- Restaura stock (via restock_via_lote) y elimina pedido.
-- ============================================================
create or replace function public.admin_eliminar_pedido(
  p_session_token uuid,
  p_pedido_id     bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_item     record;
  v_cnt      int := 0;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if not exists (select 1 from public.pedidos where id = p_pedido_id) then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  -- Restaurar stock de cada item
  for v_item in
    select producto_id, cantidad, lote_id
    from public.pedido_items
    where pedido_id = p_pedido_id
  loop
    if v_item.producto_id is not null and coalesce(v_item.cantidad, 0) > 0 then
      begin
        perform public.restock_via_lote(
          v_item.producto_id,
          v_item.cantidad,
          'Reintegro por eliminación de pedido #' || p_pedido_id,
          v_actor_id,
          v_item.lote_id
        );
      exception when others then
        raise notice 'restock_via_lote falló para producto %: %', v_item.producto_id, SQLERRM;
      end;
      v_cnt := v_cnt + 1;
    end if;
  end loop;

  delete from public.pedido_items where pedido_id = p_pedido_id;
  delete from public.pedidos where id = p_pedido_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'eliminar_pedido', 'pedidos', p_pedido_id::text,
      jsonb_build_object('items_restaurados', v_cnt)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'items_restaurados', v_cnt);
end;
$$;

-- ============================================================
-- 3) admin_editar_pedido
-- ============================================================
create or replace function public.admin_editar_pedido(
  p_session_token uuid,
  p_pedido_id     bigint,
  p_estado        text default null,
  p_metodo_pago   text default null,
  p_notas         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  update public.pedidos set
    estado      = coalesce(p_estado, estado),
    metodo_pago = coalesce(p_metodo_pago, metodo_pago),
    notas       = coalesce(p_notas, notas)
  where id = p_pedido_id;

  if not found then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'editar_pedido', 'pedidos', p_pedido_id::text,
      jsonb_build_object('estado', p_estado, 'metodo_pago', p_metodo_pago)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- 4) admin_cancelar_pedido
-- ============================================================
-- Cancela pedido y restaura stock si aun no estaba cancelado.
-- ============================================================
create or replace function public.admin_cancelar_pedido(
  p_session_token uuid,
  p_pedido_id     bigint,
  p_motivo        text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_estado_prev text;
  v_item     record;
  v_cnt      int := 0;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  select estado into v_estado_prev from public.pedidos where id = p_pedido_id;
  if v_estado_prev is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;
  if v_estado_prev = 'cancelado' then
    return jsonb_build_object('success', true, 'ya_cancelado', true);
  end if;

  -- Restaurar stock si el pedido estaba activo (completado, listo, pendiente)
  if v_estado_prev in ('completado','listo','pendiente') then
    for v_item in
      select producto_id, cantidad, lote_id
      from public.pedido_items where pedido_id = p_pedido_id
    loop
      if v_item.producto_id is not null and coalesce(v_item.cantidad, 0) > 0 then
        begin
          perform public.restock_via_lote(
            v_item.producto_id, v_item.cantidad,
            'Cancelación pedido #' || p_pedido_id || coalesce(' - ' || p_motivo, ''),
            v_actor_id, v_item.lote_id
          );
          v_cnt := v_cnt + 1;
        exception when others then null;
        end;
      end if;
    end loop;
  end if;

  update public.pedidos
     set estado = 'cancelado',
         notas  = case when p_motivo is null then notas
                       else coalesce(notas || E'\n', '') || 'Cancelación: ' || p_motivo end
   where id = p_pedido_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'cancelar_pedido', 'pedidos', p_pedido_id::text,
      jsonb_build_object('estado_previo', v_estado_prev, 'items_restaurados', v_cnt, 'motivo', p_motivo)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'items_restaurados', v_cnt);
end;
$$;

-- ============================================================
-- 5) marcar_pedido_listo
-- ============================================================
-- Cambia estado a 'listo' y asigna atendido_por (pedidos online).
-- ============================================================
create or replace function public.marcar_pedido_listo(
  p_session_token uuid,
  p_pedido_id     bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);

  update public.pedidos
     set estado = 'listo', atendido_por = v_actor_id
   where id = p_pedido_id;

  if not found then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- 6) crear_devolucion
-- ============================================================
-- p_items es un jsonb array: [{pedido_item_id, producto_id, lote_id,
--                             cantidad, precio_unitario, producto_nombre}, ...]
-- ============================================================
create or replace function public.crear_devolucion(
  p_session_token uuid,
  p_pedido_id     bigint,
  p_motivo        text,
  p_metodo_reembolso text,
  p_items         jsonb,
  p_notas         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id    bigint;
  v_pedido      record;
  v_dev_id      bigint;
  v_total       numeric := 0;
  v_item        jsonb;
  v_cnt         int := 0;
  v_producto_id bigint;
  v_lote_id     bigint;
  v_cantidad    numeric;
  v_precio      numeric;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);

  if p_motivo is null or length(trim(p_motivo)) = 0 then
    raise exception 'Motivo requerido';
  end if;
  if jsonb_array_length(coalesce(p_items, '[]'::jsonb)) = 0 then
    raise exception 'Debe incluir al menos un item';
  end if;

  select id, cliente_id into v_pedido from public.pedidos where id = p_pedido_id;
  if v_pedido.id is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  -- Calcular total
  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_total := v_total +
      ((v_item->>'cantidad')::numeric * (v_item->>'precio_unitario')::numeric);
  end loop;

  insert into public.devoluciones (
    pedido_id, cliente_id, motivo, estado, total_devuelto,
    metodo_reembolso, notas, atendido_por
  ) values (
    v_pedido.id, v_pedido.cliente_id, p_motivo, 'aprobada',
    v_total, p_metodo_reembolso, p_notas, v_actor_id
  ) returning id into v_dev_id;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_producto_id := (v_item->>'producto_id')::bigint;
    v_lote_id     := nullif(v_item->>'lote_id', '')::bigint;
    v_cantidad    := (v_item->>'cantidad')::numeric;
    v_precio      := (v_item->>'precio_unitario')::numeric;

    insert into public.devolucion_items (
      devolucion_id, producto_id, producto_nombre, cantidad, precio_unitario
    ) values (
      v_dev_id, v_producto_id,
      coalesce(v_item->>'producto_nombre', 'Producto'),
      v_cantidad, v_precio
    );

    -- Reintegrar stock
    if v_producto_id is not null and v_cantidad > 0 then
      begin
        perform public.restock_via_lote(
          v_producto_id, v_cantidad::int,
          'Devolución #' || v_dev_id || ' - ' || p_motivo,
          v_actor_id, v_lote_id
        );
        v_cnt := v_cnt + 1;
      exception when others then
        raise notice 'restock falló para producto %: %', v_producto_id, SQLERRM;
      end;
    end if;
  end loop;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'crear_devolucion', 'devoluciones', v_dev_id::text,
      jsonb_build_object('pedido_id', p_pedido_id, 'total', v_total, 'items', v_cnt)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'devolucion_id', v_dev_id,
    'total_devuelto', v_total,
    'items_restaurados', v_cnt
  );
end;
$$;

-- ============================================================
-- 7) registrar_corte_caja
-- ============================================================
create or replace function public.registrar_corte_caja(
  p_session_token     uuid,
  p_turno             text,
  p_efectivo_declarado numeric,
  p_efectivo_sistema  numeric,
  p_tarjeta           numeric,
  p_mercadopago       numeric,
  p_diferencia        numeric,
  p_total_general     numeric,
  p_spei              numeric default 0,
  p_notas             text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_nombre   text;
  v_corte_id bigint;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  select nombre into v_nombre from public.usuarios where id = v_actor_id;

  insert into public.cortes_caja (
    turno, cajero,
    efectivo_declarado, efectivo_sistema, tarjeta, spei, mercadopago,
    diferencia, total_general, notas, fecha
  ) values (
    p_turno, v_nombre,
    p_efectivo_declarado, p_efectivo_sistema, p_tarjeta,
    coalesce(p_spei, 0), p_mercadopago,
    p_diferencia, p_total_general,
    p_notas, now()
  ) returning id into v_corte_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id, v_nombre,
      'corte_caja', 'cortes_caja', v_corte_id::text,
      jsonb_build_object('turno', p_turno, 'diferencia', p_diferencia, 'total', p_total_general)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'corte_id', v_corte_id);
end;
$$;

-- ============================================================
-- 8) registrar_nomina
-- ============================================================
create or replace function public.registrar_nomina(
  p_session_token     uuid,
  p_empleado_id       bigint,
  p_periodo_inicio    date,
  p_periodo_fin       date,
  p_salario_base      numeric,
  p_horas_extra       numeric default 0,
  p_prima_dominical   numeric default 0,
  p_bono              numeric default 0,
  p_total_percepciones numeric default null,
  p_imss_obrero       numeric default null,
  p_isr               numeric default null,
  p_total_deducciones numeric default null,
  p_neto_pagar        numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_nomina_id bigint;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if p_empleado_id is null then raise exception 'empleado_id requerido'; end if;
  if p_salario_base is null or p_salario_base <= 0 then
    raise exception 'salario_base requerido';
  end if;
  if not exists (select 1 from public.empleados where id = p_empleado_id) then
    raise exception 'Empleado % no encontrado', p_empleado_id;
  end if;

  insert into public.nomina_empleados (
    empleado_id, periodo_inicio, periodo_fin,
    salario_base, horas_extra, prima_dominical, bono,
    total_percepciones, imss_obrero, isr,
    total_deducciones, neto_pagar, pagado
  ) values (
    p_empleado_id, p_periodo_inicio, p_periodo_fin,
    p_salario_base, p_horas_extra, p_prima_dominical, p_bono,
    p_total_percepciones, p_imss_obrero, p_isr,
    p_total_deducciones, p_neto_pagar, false
  ) returning id into v_nomina_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'registrar_nomina', 'nomina_empleados', v_nomina_id::text,
      jsonb_build_object(
        'empleado_id', p_empleado_id,
        'neto', p_neto_pagar,
        'periodo', jsonb_build_object('inicio', p_periodo_inicio, 'fin', p_periodo_fin)
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'nomina_id', v_nomina_id);
end;
$$;

-- ============================================================
-- 9) cobrar_consulta
-- ============================================================
-- Server-side: lee cita y sus consumibles pendientes, calcula total,
-- crea pedido tipo=consulta, marca consumibles como cobrados,
-- actualiza cita (pago_estado=pagada), suma puntos al cliente.
-- ============================================================
create or replace function public.cobrar_consulta(
  p_session_token   uuid,
  p_cita_id         bigint,
  p_metodo_pago     text,
  p_precio_consulta numeric,
  p_ya_pago_consulta boolean default false,
  p_parte_doctor    numeric default 0,
  p_parte_farmacia  numeric default 0
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_cita     record;
  v_cli      record;
  v_total_consumibles numeric := 0;
  v_base_cobrar numeric;
  v_total_final numeric;
  v_pedido_id bigint;
  v_puntos_nuevos int;
  v_upd jsonb;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);

  select * into v_cita from public.citas where id = p_cita_id;
  if v_cita.id is null then
    raise exception 'Cita % no encontrada', p_cita_id;
  end if;

  select coalesce(sum(precio * cantidad), 0) into v_total_consumibles
  from public.consumibles_consulta
  where cita_id = p_cita_id and coalesce(cobrado, false) = false;

  v_base_cobrar := case when p_ya_pago_consulta then 0 else coalesce(p_precio_consulta, 0) end;
  v_total_final := v_base_cobrar + v_total_consumibles;

  if v_total_final <= 0 then
    raise exception 'No hay monto por cobrar';
  end if;

  -- Cliente asociado (por telefono en citas)
  select * into v_cli from public.clientes where telefono = v_cita.telefono limit 1;

  insert into public.pedidos (
    cliente_id, total, estado, tipo, metodo_pago, atendido_por
  ) values (
    v_cli.id, v_total_final, 'completado', 'consulta',
    p_metodo_pago, v_actor_id
  ) returning id into v_pedido_id;

  update public.consumibles_consulta set cobrado = true
  where cita_id = p_cita_id and coalesce(cobrado, false) = false;

  -- Update cita
  if v_base_cobrar > 0 then
    update public.citas set
      pago_estado = 'pagada',
      pedido_consulta_id = v_pedido_id,
      precio_consulta_cobrado = p_precio_consulta,
      ingreso_doctor = p_parte_doctor,
      ingreso_farmacia = p_parte_farmacia
    where id = p_cita_id;
  else
    update public.citas set
      pago_estado = 'pagada',
      pedido_consulta_id = v_pedido_id
    where id = p_cita_id;
  end if;

  -- Puntos al cliente: 1 por cada $10
  if v_cli.id is not null then
    v_puntos_nuevos := floor(v_total_final / 10);
    update public.clientes
       set puntos = coalesce(puntos, 0) + v_puntos_nuevos
     where id = v_cli.id;
  end if;

  return jsonb_build_object(
    'success', true,
    'pedido_id', v_pedido_id,
    'total_final', v_total_final,
    'consumibles_total', v_total_consumibles,
    'puntos_ganados', coalesce(v_puntos_nuevos, 0)
  );
end;
$$;

-- ============================================================
-- 10) admin_ajustar_puntos
-- ============================================================
-- Ajuste manual de puntos a un cliente por admin.
-- ============================================================
create or replace function public.admin_ajustar_puntos(
  p_session_token uuid,
  p_cliente_id    bigint,
  p_ajuste        int,
  p_motivo        text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_nuevos   int;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if p_ajuste is null or p_ajuste = 0 then
    raise exception 'Ajuste inválido';
  end if;

  update public.clientes
     set puntos = greatest(0, coalesce(puntos, 0) + p_ajuste)
   where id = p_cliente_id
  returning puntos into v_nuevos;

  if not found then
    raise exception 'Cliente % no encontrado', p_cliente_id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'ajustar_puntos', 'clientes', p_cliente_id::text,
      jsonb_build_object('ajuste', p_ajuste, 'puntos_nuevos', v_nuevos, 'motivo', p_motivo)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'puntos', v_nuevos);
end;
$$;

-- ============================================================
-- Grants
-- ============================================================
grant execute on function public.crear_factura(uuid, bigint, text, text, text, text, text, text, text) to anon, authenticated;
grant execute on function public.admin_eliminar_pedido(uuid, bigint)                                    to anon, authenticated;
grant execute on function public.admin_editar_pedido(uuid, bigint, text, text, text)                    to anon, authenticated;
grant execute on function public.admin_cancelar_pedido(uuid, bigint, text)                              to anon, authenticated;
grant execute on function public.marcar_pedido_listo(uuid, bigint)                                      to anon, authenticated;
grant execute on function public.crear_devolucion(uuid, bigint, text, text, jsonb, text)                to anon, authenticated;
grant execute on function public.registrar_corte_caja(uuid, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text) to anon, authenticated;
grant execute on function public.registrar_nomina(uuid, bigint, date, date, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric) to anon, authenticated;
grant execute on function public.cobrar_consulta(uuid, bigint, text, numeric, boolean, numeric, numeric) to anon, authenticated;
grant execute on function public.admin_ajustar_puntos(uuid, bigint, int, text)                          to anon, authenticated;

commit;

-- ============================================================
-- FIN F6b.2
-- ============================================================
-- Siguiente: refactor_fase6b_rpcs_inventario_catalogo.sql
-- ============================================================
