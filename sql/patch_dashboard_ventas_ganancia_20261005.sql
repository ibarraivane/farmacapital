-- Dashboard: ganancia bruta por día civil CDMX, junto a la serie de ventas.
-- 5-oct-2026. Idempotente. Pegar en Supabase SQL Editor.
--
-- Ganancia bruta = venta neta (tickets − devoluciones del día) − costo de lo vendido.
-- El costo prefiere el lote de la línea; si la pieza no guardó lote, el del catálogo.
-- Pieza y blister prorratean ese costo (misma idea que costoLineaVenta).
-- Sin esta función la gráfica sigue mostrando solo la venta.

begin;

create or replace function public.fn_costo_linea_mostrador(
  p_precio numeric,
  p_cantidad numeric,
  p_costo_lote numeric,
  p_costo_cat numeric,
  p_precio_caja numeric,
  p_precio_unidad numeric,
  p_precio_blister numeric,
  p_upc integer,
  p_ppb integer,
  p_venta_unidad boolean
)
returns numeric
language plpgsql
immutable
as $$
declare
  v_costo numeric;
  v_cant numeric;
  v_precio numeric;
  v_blisters integer;
begin
  v_cant := coalesce(p_cantidad, 1);
  v_precio := coalesce(p_precio, 0);
  v_costo := coalesce(nullif(p_costo_lote, 0), nullif(p_costo_cat, 0), 0);
  if v_costo <= 0 then
    return 0;
  end if;

  v_blisters := public.blisters_por_caja(p_upc, p_ppb);
  if v_blisters >= 2
     and coalesce(p_precio_blister, 0) > 0
     and abs(v_precio - p_precio_blister) <= 1 then
    return round((v_costo / v_blisters) * v_cant, 2);
  end if;

  if coalesce(p_venta_unidad, false)
     and coalesce(p_upc, 0) > 1
     and (
       (coalesce(p_precio_unidad, 0) > 0 and abs(v_precio - p_precio_unidad) <= 1)
       or (coalesce(p_precio_caja, 0) > 0 and v_precio > 0 and v_precio < p_precio_caja * 0.45)
     ) then
    return round((v_costo / p_upc) * v_cant, 2);
  end if;

  return round(v_costo * v_cant, 2);
end;
$$;

create or replace function public.empleado_dashboard_ventas_serie(
  p_session_token uuid,
  p_desde date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  if p_desde is null then
    raise exception 'p_desde requerido';
  end if;

  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'dia', d.dia,
      'total', d.total,
      'tickets', d.tickets,
      'devoluciones', d.devoluciones,
      'costo', d.costo,
      'ganancia', d.ganancia
    ) order by d.dia)
    from (
      select
        coalesce(v.dia, dv.dia) as dia,
        coalesce(v.total, 0)::numeric as total,
        coalesce(v.tickets, 0)::int as tickets,
        coalesce(dv.devoluciones, 0)::numeric as devoluciones,
        coalesce(c.costo, 0)::numeric as costo,
        (
          coalesce(v.total, 0) - coalesce(dv.devoluciones, 0) - coalesce(c.costo, 0)
        )::numeric as ganancia
      from (
        select
          ((p.created_at at time zone 'America/Mexico_City')::date) as dia,
          sum(p.total)::numeric as total,
          count(*)::int as tickets
        from public.pedidos p
        where (p.estado)::text = 'completado'
          and ((p.created_at at time zone 'America/Mexico_City')::date) >= p_desde
        group by 1
      ) v
      full outer join (
        select
          ((d.created_at at time zone 'America/Mexico_City')::date) as dia,
          sum(d.total_devuelto)::numeric as devoluciones
        from public.devoluciones d
        where (d.estado)::text = 'aprobada'
          and ((d.created_at at time zone 'America/Mexico_City')::date) >= p_desde
        group by 1
      ) dv on dv.dia = v.dia
      left join (
        select
          ((p.created_at at time zone 'America/Mexico_City')::date) as dia,
          sum(public.fn_costo_linea_mostrador(
            pi.precio_unitario,
            pi.cantidad,
            l.costo_unitario,
            pr.costo,
            pr.precio,
            pr.precio_unidad,
            pr.precio_blister,
            pr.unidades_por_caja::integer,
            pr.piezas_por_blister::integer,
            coalesce(pr.venta_unidad, false)
          ))::numeric as costo
        from public.pedidos p
        join public.pedido_items pi on pi.pedido_id = p.id
        join public.productos pr on pr.id = pi.producto_id
        left join public.lotes l on l.id = pi.lote_id
        where (p.estado)::text = 'completado'
          and ((p.created_at at time zone 'America/Mexico_City')::date) >= p_desde
        group by 1
      ) c on c.dia = coalesce(v.dia, dv.dia)
    ) d
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.fn_costo_linea_mostrador(
  numeric, numeric, numeric, numeric, numeric, numeric, numeric, integer, integer, boolean
) to anon, authenticated;

grant execute on function public.empleado_dashboard_ventas_serie(uuid, date) to anon, authenticated;

commit;
