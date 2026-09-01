-- Incluye producto_id en el historial del cliente (Comprar de nuevo).
-- Ejecutar en Supabase → SQL. Si no se corre, la tienda igual empareja por nombre.

create or replace function public.cliente_listar_mis_pedidos(
  p_session_token uuid,
  p_limite int default 120
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli bigint;
begin
  v_cli := public.fn_require_cliente(p_session_token);
  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        jsonb_build_object(
          'id', p.id,
          'total', p.total,
          'estado', p.estado,
          'tipo', p.tipo,
          'metodo_pago', p.metodo_pago,
          'tipo_entrega', p.tipo_entrega,
          'direccion', p.direccion,
          'created_at', p.created_at,
          'payment_provider', p.payment_provider,
          'payment_status', p.payment_status,
          'payment_id', p.payment_id,
          'paid_at', p.paid_at,
          'delivery_provider', p.delivery_provider,
          'delivery_status', p.delivery_status,
          'delivery_tracking_url', p.delivery_tracking_url,
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join lateral (
        select
          jsonb_agg(
            jsonb_build_object(
              'producto_id', i.producto_id,
              'cantidad', i.cantidad,
              'precio_unitario', i.precio_unitario,
              'productos', jsonb_build_object(
                'id', pr.id,
                'nombre', pr.nombre
              )
            )
            order by i.id
          ) as js
        from public.pedido_items i
        join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
      ) pi on true
      where p.cliente_id = v_cli
      order by p.created_at desc
      limit greatest(1, least(coalesce(p_limite, 120), 500))
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.cliente_listar_mis_pedidos(uuid, int) to anon, authenticated;
