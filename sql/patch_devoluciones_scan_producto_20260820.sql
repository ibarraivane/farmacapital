-- ============================================================
-- Devoluciones: escanear producto → venta reciente (15 días)
-- 20 ago 2026. Idempotente. Pegar DESPUÉS del patch de caja/crédito
-- si ese ya se corrió; si no, basta con el archivo grande
-- sql/patch_devoluciones_caja_credito_20260820.sql (ya lo incluye).
-- ============================================================

begin;

create or replace function public.empleado_identificar_producto_codigo(
  p_session_token uuid,
  p_codigo text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_raw text;
  v_digits text;
  v_row jsonb;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_raw := trim(coalesce(p_codigo, ''));
  v_digits := regexp_replace(v_raw, '\D', '', 'g');
  if length(v_raw) < 2 then
    return 'null'::jsonb;
  end if;

  select to_jsonb(r) into v_row
  from (
    select
      p.id, p.nombre, p.sku, p.codigo_barras,
      round(coalesce(p.precio, 0), 0) as precio,
      coalesce(p.stock, 0) as stock
    from public.productos p
    where coalesce(p.activo, true) = true
      and (
        (length(v_digits) >= 8 and (
          regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g') = v_digits
          or regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g') = '0' || v_digits
          or v_digits = '0' || regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g')
        ))
        or upper(coalesce(p.sku, '')) = upper(v_raw)
      )
    order by p.id
    limit 1
  ) r;

  return coalesce(v_row, 'null'::jsonb);
end;
$$;

grant execute on function public.empleado_identificar_producto_codigo(uuid, text)
  to anon, authenticated;

create or replace function public.empleado_buscar_venta_reciente_por_producto(
  p_session_token uuid,
  p_producto_id bigint,
  p_dias int default 15
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_dias int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  if p_producto_id is null then
    return '[]'::jsonb;
  end if;
  v_dias := greatest(1, least(coalesce(p_dias, 15), 90));

  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        to_jsonb(p) ||
        jsonb_build_object(
          'clientes', jsonb_build_object(
            'nombre', coalesce(cl.nombre, p.guest_nombre),
            'telefono', coalesce(cl.telefono, p.guest_telefono)
          ),
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.clientes cl on cl.id = p.cliente_id
      left join lateral (
        select jsonb_agg(
          jsonb_build_object(
            'id', i.id,
            'cantidad', i.cantidad,
            'precio_unitario', i.precio_unitario,
            'lote_id', i.lote_id,
            'productos', jsonb_build_object('id', pr.id, 'nombre', pr.nombre, 'stock', pr.stock)
          )
          order by i.id
        ) as js
        from public.pedido_items i
        join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
      ) pi on true
      where (p.estado)::text = 'completado'
        and p.created_at >= now() - (v_dias || ' days')::interval
        and exists (
          select 1 from public.pedido_items x
          where x.pedido_id = p.id and x.producto_id = p_producto_id
        )
      order by p.created_at desc
      limit 12
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_buscar_venta_reciente_por_producto(uuid, bigint, int)
  to anon, authenticated;

notify pgrst, 'reload schema';

commit;
