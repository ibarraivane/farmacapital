-- ============================================================
-- Devoluciones: buscar la última venta por teléfono o folio
-- ============================================================
-- Idempotente. Correr en Supabase SQL Editor.
--
-- Antes, un teléfono de 10 dígitos se casteaba a bigint y se buscaba
-- como ID de pedido (no encontraba nada). Ahora:
--   • VTA-00000123 / #FC-0123 / ID corto → pedido
--   • 10+ dígitos → última(s) venta(s) de ese teléfono
--     (cliente registrado o guest_telefono de pedido online)
-- ============================================================

begin;

create or replace function public.empleado_buscar_pedidos_devolucion(
  p_session_token uuid,
  p_busqueda text,
  p_limite int default 12
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
  v_id bigint;
  v_tel10 text;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_raw := trim(coalesce(p_busqueda, ''));
  v_digits := regexp_replace(v_raw, '\D', '', 'g');
  v_id := null;
  v_tel10 := null;

  if v_raw ~* '^(vta-|#?fc-)' then
    v_id := nullif(v_digits, '')::bigint;
  elsif length(v_digits) >= 10 then
    v_tel10 := right(v_digits, 10);
  elsif v_digits ~ '^\d{1,8}$' then
    v_id := v_digits::bigint;
  end if;

  if v_id is null and v_tel10 is null then
    return '[]'::jsonb;
  end if;

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
        and (
          (v_id is not null and p.id = v_id)
          or (
            v_tel10 is not null and (
              right(regexp_replace(coalesce(cl.telefono, ''), '\D', '', 'g'), 10) = v_tel10
              or right(regexp_replace(coalesce(p.guest_telefono, ''), '\D', '', 'g'), 10) = v_tel10
            )
          )
        )
      order by p.created_at desc
      limit greatest(1, least(coalesce(p_limite, 12), 40))
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_buscar_pedidos_devolucion(uuid, text, int) to anon, authenticated;

commit;
