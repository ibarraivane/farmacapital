-- ============================================================
-- FARMAX — Verificacion de F3a
-- ============================================================
-- Corre este script DESPUES de refactor_fase3a_rpcs_lotes.sql.
-- Retorna una sola tabla _diag con:
--   A_funciones  -> existencia de las 5 RPCs nuevas / reescritas
--   B_venta      -> prueba real de venta (lote FEFO) y auto-revert
--   C_ajuste     -> prueba de adjust_stock_via_lotes (+/-) con auto-revert
-- ============================================================

drop table if exists _diag;
create temp table _diag (
  seccion   text,
  item      text,
  detalle_1 text,
  detalle_2 text
) on commit drop;

-- ---------------------------------------------------------------
-- Seccion A: funciones instaladas
-- ---------------------------------------------------------------
insert into _diag (seccion, item, detalle_1, detalle_2)
select
  'A_funciones',
  p.proname,
  case when p.prosecdef then 'SECURITY DEFINER' else 'SECURITY INVOKER' end,
  pg_get_function_identity_arguments(p.oid)
from pg_proc p
where p.proname in (
  'create_sale_transaction_v2',
  'abrir_caja_lote',
  'restock_via_lote',
  'adjust_stock_via_lotes',
  'create_producto_with_lote'
)
order by p.proname;

insert into _diag (seccion, item, detalle_1, detalle_2)
select 'A_funciones', '(faltan)', nombre, null
from (
  values
    ('create_sale_transaction_v2'),
    ('abrir_caja_lote'),
    ('restock_via_lote'),
    ('adjust_stock_via_lotes'),
    ('create_producto_with_lote')
) as esperadas(nombre)
where not exists (
  select 1 from pg_proc where proname = esperadas.nombre
);

-- ---------------------------------------------------------------
-- Seccion B: prueba real de venta sobre Paracetamol (id=99)
--   - Estado inicial
--   - Llamar create_sale_transaction_v2 con 1 unidad (modo caja)
--   - Estado despues
--   - Revertir con restock_via_lote
--   - Estado final (debe igualar inicial)
-- ---------------------------------------------------------------

do $$
declare
  v_stock_ini int;
  v_lotes_ini int;
  v_pedido_id bigint;
  v_stock_post int;
  v_lotes_post int;
  v_stock_final int;
  v_lotes_final int;
  v_precio numeric;
  v_user_id bigint;
begin
  -- Buscar un usuario real (admin preferente, si no, el primero)
  select id into v_user_id from public.usuarios
  where lower(coalesce(rol, '')) in ('admin', 'farmaceutico', 'vendedor')
  order by id limit 1;
  if v_user_id is null then
    select id into v_user_id from public.usuarios order by id limit 1;
  end if;

  if v_user_id is null then
    insert into _diag (seccion, item, detalle_1, detalle_2)
    values ('B_venta', '!skipped', 'no hay usuarios en public.usuarios', null);
    return;
  end if;

  select p.stock, coalesce((
    select sum(l.cantidad_actual)::int from public.lotes l
    where l.producto_id = 99 and coalesce(l.activo, true) = true
  ), 0), coalesce(p.precio, 0)
  into v_stock_ini, v_lotes_ini, v_precio
  from public.productos p where p.id = 99;

  insert into _diag (seccion, item, detalle_1, detalle_2)
  values ('B_venta', '1_inicial',
    'stock=' || v_stock_ini, 'sum_lotes=' || v_lotes_ini
    || ', user_id=' || v_user_id);

  begin
    select pedido_id into v_pedido_id
    from public.create_sale_transaction_v2(
      p_user_id := v_user_id,
      p_metodo_pago := 'efectivo',
      p_total := v_precio,
      p_cart_items := jsonb_build_array(
        jsonb_build_object(
          'producto_id', 99,
          'cantidad', 1,
          'modo_venta', 'caja',
          'precio_unitario', v_precio
        )
      ),
      p_cliente_id := null,
      p_tipo := 'pos',
      p_tipo_entrega := null,
      p_direccion := null
    );

    select p.stock, coalesce((
      select sum(l.cantidad_actual)::int from public.lotes l
      where l.producto_id = 99 and coalesce(l.activo, true) = true
    ), 0)
    into v_stock_post, v_lotes_post
    from public.productos p where p.id = 99;

    insert into _diag (seccion, item, detalle_1, detalle_2)
    values ('B_venta', '2_post_venta',
      'stock=' || v_stock_post, 'sum_lotes=' || v_lotes_post);

    insert into _diag (seccion, item, detalle_1, detalle_2)
    values ('B_venta', '3_pedido_creado',
      'pedido_id=' || v_pedido_id,
      'esperado: stock baja 1 y coincide con lotes');

    -- Revertir: sumar 1 via restock, y borrar pedido+items+movimiento
    delete from public.movimientos_inventario where referencia = v_pedido_id::text;
    delete from public.pedido_items where pedido_id = v_pedido_id;
    delete from public.pedidos where id = v_pedido_id;
    perform public.restock_via_lote(99, 1, 'REVERT test F3a', v_user_id, null);
    delete from public.movimientos_inventario
      where producto_id = 99 and motivo = 'REVERT test F3a'
      and created_at > now() - interval '1 minute';

    select p.stock, coalesce((
      select sum(l.cantidad_actual)::int from public.lotes l
      where l.producto_id = 99 and coalesce(l.activo, true) = true
    ), 0)
    into v_stock_final, v_lotes_final
    from public.productos p where p.id = 99;

    insert into _diag (seccion, item, detalle_1, detalle_2)
    values ('B_venta', '4_final',
      'stock=' || v_stock_final, 'sum_lotes=' || v_lotes_final);

  exception when others then
    insert into _diag (seccion, item, detalle_1, detalle_2)
    values ('B_venta', '!ERROR', SQLERRM, SQLSTATE);
  end;
end $$;

-- ---------------------------------------------------------------
-- Seccion C: prueba de adjust_stock_via_lotes (+2 luego -2)
-- ---------------------------------------------------------------

do $$
declare
  v_stock_ini int;
  v_stock_post_sube int;
  v_stock_final int;
  v_user_id bigint;
begin
  select id into v_user_id from public.usuarios order by id limit 1;
  if v_user_id is null then
    insert into _diag (seccion, item, detalle_1, detalle_2)
    values ('C_ajuste', '!skipped', 'no hay usuarios en public.usuarios', null);
    return;
  end if;

  select coalesce(p.stock, 0) into v_stock_ini
  from public.productos p where p.id = 99;

  insert into _diag (seccion, item, detalle_1, detalle_2)
  values ('C_ajuste', '1_inicial', 'stock=' || v_stock_ini, 'user_id=' || v_user_id);

  begin
    perform public.adjust_stock_via_lotes(99, v_stock_ini + 2, 'TEST ajuste +2', v_user_id);

    select coalesce(p.stock, 0) into v_stock_post_sube
    from public.productos p where p.id = 99;

    insert into _diag (seccion, item, detalle_1, detalle_2)
    values ('C_ajuste', '2_post_+2',
      'stock=' || v_stock_post_sube, 'esperado=' || (v_stock_ini + 2));

    perform public.adjust_stock_via_lotes(99, v_stock_ini, 'TEST ajuste -2', v_user_id);

    select coalesce(p.stock, 0) into v_stock_final
    from public.productos p where p.id = 99;

    insert into _diag (seccion, item, detalle_1, detalle_2)
    values ('C_ajuste', '3_final',
      'stock=' || v_stock_final, 'esperado=' || v_stock_ini);

    -- Limpiar movimientos de test
    delete from public.movimientos_inventario
    where producto_id = 99
      and motivo in ('TEST ajuste +2', 'TEST ajuste -2')
      and created_at > now() - interval '1 minute';

  exception when others then
    insert into _diag (seccion, item, detalle_1, detalle_2)
    values ('C_ajuste', '!ERROR', SQLERRM, SQLSTATE);
  end;
end $$;

-- ---------------------------------------------------------------
-- Resultado
-- ---------------------------------------------------------------
select * from _diag order by seccion, item;
