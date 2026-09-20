-- Export de ventas para análisis (Dashboard → Transacciones → Exportar CSV).
-- 2026-09-20. Idempotente. Pegar en Supabase SQL Editor.
--
-- Una fila por línea: pedido (ítem o ticket vacío), recarga/CFE, devolución aprobada.
-- Sin teléfono. Sin caducidad inventada. Paginado (offset/limite, máx. 2000).

begin;

create or replace function public.empleado_exportar_ventas_lineas(
  p_session_token uuid,
  p_created_desde timestamptz default null,
  p_created_hasta timestamptz default null,
  p_offset int default 0,
  p_limite int default 1000
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_off int;
  v_lim int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_off := greatest(0, coalesce(p_offset, 0));
  v_lim := greatest(1, least(coalesce(p_limite, 1000), 2000));

  return coalesce((
    select jsonb_agg(to_jsonb(s) - 'sort_key' order by s.fecha_venta desc, s.sort_key)
    from (
      select
        p.id::text                                              as folio,
        p.id                                                    as pedido_id,
        p.created_at                                            as fecha_venta,
        coalesce(u.nombre, '')                                  as vendedor,
        coalesce(cl.nombre, p.guest_nombre, '')                 as cliente,
        coalesce(nullif(btrim(p.tipo), ''), 'tienda_fisica')    as tipo,
        coalesce(p.estado, '')                                  as estado,
        coalesce(p.metodo_pago, '')                             as metodo_pago,
        p.total                                                 as total_ticket,
        coalesce(prod.sku, '')                                  as sku,
        coalesce(prod.nombre, '')                               as producto,
        coalesce(prod.categoria, '')                            as categoria,
        coalesce(prod.marca, '')                                as marca,
        pi.cantidad,
        pi.precio_unitario,
        case
          when pi.cantidad is null or pi.precio_unitario is null then null
          else round(pi.cantidad * pi.precio_unitario, 2)
        end                                                     as importe_linea,
        l.costo_unitario                                        as costo_lote,
        'pedido'::text                                          as origen,
        ('p:' || p.id::text || ':' || coalesce(pi.id, 0)::text) as sort_key
      from public.pedidos p
      left join public.pedido_items pi on pi.pedido_id = p.id
      left join public.productos prod on prod.id = pi.producto_id
      left join public.lotes l on l.id = pi.lote_id
      left join public.clientes cl on cl.id = p.cliente_id
      left join public.usuarios u on u.id = p.atendido_por
      where (p_created_desde is null or p.created_at >= p_created_desde)
        and (p_created_hasta is null or p.created_at <= p_created_hasta)

      union all

      select
        coalesce(nullif(btrim(ps.folio), ''), 'SRV-' || ps.id::text) as folio,
        null::bigint                                                 as pedido_id,
        ps.created_at                                                as fecha_venta,
        coalesce(u.nombre, '')                                       as vendedor,
        coalesce(cl.nombre, '')                                      as cliente,
        'servicio'::text                                             as tipo,
        'completado'::text                                           as estado,
        coalesce(ps.metodo_pago, '')                                 as metodo_pago,
        ps.total_cobrado                                             as total_ticket,
        ''::text                                                     as sku,
        coalesce(nullif(btrim(ps.proveedor), ''), ps.categoria, 'Servicio') as producto,
        coalesce(ps.categoria, '')                                   as categoria,
        ''::text                                                     as marca,
        1::numeric                                                   as cantidad,
        ps.total_cobrado                                             as precio_unitario,
        ps.total_cobrado                                             as importe_linea,
        null::numeric                                                as costo_lote,
        'servicio'::text                                             as origen,
        ('s:' || ps.id::text)                                        as sort_key
      from public.pagos_servicio ps
      left join public.clientes cl on cl.id = ps.cliente_id
      left join public.usuarios u on u.id = ps.atendido_por
      where (p_created_desde is null or ps.created_at >= p_created_desde)
        and (p_created_hasta is null or ps.created_at <= p_created_hasta)

      union all

      select
        ('DEV-' || d.id::text)                                       as folio,
        d.pedido_id,
        d.created_at                                                 as fecha_venta,
        coalesce(u.nombre, '')                                       as vendedor,
        coalesce(cl.nombre, '')                                      as cliente,
        coalesce(nullif(btrim(ped.tipo), ''), 'tienda_fisica')       as tipo,
        d.estado,
        coalesce(
          nullif(btrim(d.metodo_reembolso), ''),
          nullif(btrim(d.metodo_pago_original), ''),
          ped.metodo_pago,
          ''
        )                                                            as metodo_pago,
        -abs(coalesce(d.total_devuelto, 0))                          as total_ticket,
        coalesce(prod.sku, '')                                       as sku,
        coalesce(nullif(btrim(di.producto_nombre), ''), prod.nombre, '') as producto,
        coalesce(prod.categoria, '')                                 as categoria,
        coalesce(prod.marca, '')                                     as marca,
        case
          when coalesce(di.es_entrada, false) then di.cantidad
          else -abs(coalesce(di.cantidad, 0))
        end                                                          as cantidad,
        di.precio_unitario,
        case
          when di.cantidad is null or di.precio_unitario is null then null
          when coalesce(di.es_entrada, false) then round(di.cantidad * di.precio_unitario, 2)
          else -abs(round(di.cantidad * di.precio_unitario, 2))
        end                                                          as importe_linea,
        l.costo_unitario                                             as costo_lote,
        'devolucion'::text                                           as origen,
        ('d:' || di.id::text)                                        as sort_key
      from public.devoluciones d
      join public.devolucion_items di on di.devolucion_id = d.id
      left join public.productos prod on prod.id = di.producto_id
      left join public.lotes l on l.id = di.lote_id
      left join public.pedidos ped on ped.id = d.pedido_id
      left join public.clientes cl on cl.id = d.cliente_id
      left join public.usuarios u on u.id = d.atendido_por
      where d.estado = 'aprobada'
        and (p_created_desde is null or d.created_at >= p_created_desde)
        and (p_created_hasta is null or d.created_at <= p_created_hasta)

      order by fecha_venta desc, sort_key
      offset v_off
      limit v_lim
    ) s
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.empleado_exportar_ventas_lineas(uuid, timestamptz, timestamptz, int, int) from public;
grant execute on function public.empleado_exportar_ventas_lineas(uuid, timestamptz, timestamptz, int, int)
  to anon, authenticated;

comment on function public.empleado_exportar_ventas_lineas(uuid, timestamptz, timestamptz, int, int) is
  'Export análisis: líneas de pedido + servicios + devoluciones aprobadas. Sin teléfono. Paginado.';

commit;
