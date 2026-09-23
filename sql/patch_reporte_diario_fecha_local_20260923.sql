-- ============================================================================
-- Excel del mes: la hoja diaria usaba v.fecha_local fuera del GROUP BY
--
-- Causa: piezas y costo salían de una subconsulta correlacionada sobre
-- v.fecha_local, mientras el GROUP BY era la expresión fecha_local::date.
-- Postgres responde:
--   subquery uses ungrouped column "v.fecha_local" from outer query
-- y Exportar a Excel se queda en "No se pudo consultar la información".
--
-- Piezas y costo ahora se agregan por fecha y se unen. Mismas columnas.
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.
-- ============================================================================

begin;

create or replace function public.rpc_transacciones_mes(
  p_anio int, p_mes int, p_hoja text,
  p_offset int default 0, p_limit int default 5000)
returns setof jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  d timestamp; h timestamp;
begin
  perform fn_rep_exige_admin();
  if p_limit > 20000 then p_limit := 20000; end if;

  d := make_timestamp(p_anio, p_mes, 1, 0, 0, 0);
  h := least(d + interval '1 month', date_trunc('day', fn_rep_local(now())) + interval '1 day');

  if p_hoja = 'transacciones' then
    return query
      select to_jsonb(t) from (
        select folio, fecha_local::date as fecha, fecha_local::time as hora,
               to_char(fecha_local,'TMDay') as dia_semana, turno, vendedor, canal,
               metodo_pago, subtotal, descuento, total,
               (select coalesce(sum(cantidad),0) from v_rep_partida pa where pa.venta_id = v.venta_id) as piezas,
               (select count(*) from v_rep_partida pa where pa.venta_id = v.venta_id) as partidas,
               cliente_id::text as cliente, 'completado' as estado, caja_sesion_id::text
        from v_rep_venta v
        where fecha_local >= d and fecha_local < h
        order by fecha_local offset p_offset limit p_limit) t;

  elsif p_hoja = 'detalle' then
    return query
      select to_jsonb(t) from (
        select folio, fecha_local::date as fecha, fecha_local::time as hora, turno, vendedor,
               producto_id::text, codigo_barras, descripcion, categoria, laboratorio,
               cantidad, precio_unitario, descuento, importe,
               costo_unitario, (cantidad*costo_unitario) as costo_total,
               (importe - cantidad*costo_unitario) as utilidad,
               case when importe = 0 then 0 else (importe - cantidad*costo_unitario)/importe end as margen_pct,
               lote, caducidad, metodo_pago
        from v_rep_partida
        where fecha_local >= d and fecha_local < h
        order by fecha_local offset p_offset limit p_limit) t;

  elsif p_hoja = 'diario' then
    -- Piezas y costo van en un agregado aparte. Una subconsulta correlacionada
    -- sobre v.fecha_local truena: Postgres no deja usar esa columna si el
    -- GROUP BY es la expresión fecha_local::date
    -- ("subquery uses ungrouped column v.fecha_local from outer query").
    return query
      select to_jsonb(t) from (
        with ventas as (
          select v.fecha_local::date as fecha,
                 to_char(min(v.fecha_local), 'TMDay') as dia_semana,
                 sum(v.total) as venta_neta,
                 count(*) as tickets,
                 sum(v.total)/count(*) as ticket_promedio,
                 sum(v.total) filter (where v.metodo_pago='efectivo')    as efectivo,
                 sum(v.total) filter (where v.metodo_pago='tarjeta')     as tarjeta,
                 sum(v.total) filter (where v.metodo_pago='spei')        as spei,
                 sum(v.total) filter (where v.metodo_pago='mercadopago') as mercadopago
          from v_rep_venta v
          where v.fecha_local >= d and v.fecha_local < h
          group by v.fecha_local::date
        ),
        partidas as (
          select pa.fecha_local::date as fecha,
                 coalesce(sum(pa.cantidad), 0) as piezas,
                 coalesce(sum(pa.cantidad * pa.costo_unitario), 0) as costo
          from v_rep_partida pa
          where pa.fecha_local >= d and pa.fecha_local < h
          group by pa.fecha_local::date
        )
        select v.fecha, v.dia_semana, v.venta_neta, v.tickets, v.ticket_promedio,
               coalesce(p.piezas, 0) as piezas,
               coalesce(p.costo, 0) as costo,
               v.efectivo, v.tarjeta, v.spei, v.mercadopago
        from ventas v
        left join partidas p on p.fecha = v.fecha
        order by v.fecha
        offset p_offset limit p_limit) t;

  elsif p_hoja = 'productos' then
    return query
      select to_jsonb(t) from (
        with pa as (select * from v_rep_partida where fecha_local >= d and fecha_local < h),
        agg as (
          select producto_id, min(codigo_barras) codigo_barras, min(descripcion) descripcion,
                 min(categoria) categoria, sum(cantidad) piezas, sum(importe) importe,
                 sum(cantidad*costo_unitario) costo, max(fecha_local)::date ultima_venta
          from pa group by producto_id),
        tot as (select nullif(sum(importe),0) t from agg)
        select a.producto_id::text, a.codigo_barras, a.descripcion, a.categoria,
               a.piezas, a.importe, a.costo, (a.importe-a.costo) as utilidad,
               case when a.importe=0 then 0 else (a.importe-a.costo)/a.importe end as margen_pct,
               a.importe/(select t from tot) as part_venta,
               case when sum(a.importe) over (order by a.importe desc rows unbounded preceding)
                         /(select t from tot) <= 0.80 then 'A'
                    when sum(a.importe) over (order by a.importe desc rows unbounded preceding)
                         /(select t from tot) <= 0.95 then 'B' else 'C' end as clase_abc,
               coalesce(pr.stock,0) as stock_actual,
               case when a.piezas = 0 then null
                    else round(coalesce(pr.stock,0) / (a.piezas/30.0), 1) end as dias_cobertura,
               a.ultima_venta
        from agg a left join v_rep_producto pr on pr.producto_id = a.producto_id
        order by a.importe desc offset p_offset limit p_limit) t;

  elsif p_hoja = 'por_hora' then
    return query
      select to_jsonb(t) from (
        select extract(dow from fecha_local)::int as dow,
               extract(hour from fecha_local)::int as hora,
               sum(total) as importe, count(*) as tickets
        from v_rep_venta where fecha_local >= d and fecha_local < h
        group by 1,2 order by 1,2) t;

  elsif p_hoja = 'pagos_servicio' then
    return query
      select to_jsonb(t) from (
        select fecha_local::date as fecha, fecha_local::time as hora, tipo, referencia,
               monto, comision, metodo_pago, vendedor
        from v_rep_pago_servicio where fecha_local >= d and fecha_local < h
        order by fecha_local offset p_offset limit p_limit) t;

  elsif p_hoja = 'cortes' then
    return query
      select to_jsonb(t) from (
        select fecha_local as fecha, turno, vendedor, abierta_at, cerrada_at,
               round(extract(epoch from (cerrada_at-abierta_at))/3600::numeric, 2) as horas,
               fondo_inicial, efectivo_declarado, efectivo_sistema, esperado, diferencia,
               tarjeta, spei, mercadopago, total_general, estado
        from v_rep_corte where abierta_at >= d and abierta_at < h
        order by abierta_at offset p_offset limit p_limit) t;

  elsif p_hoja = 'devoluciones' then
    return query
      select to_jsonb(t) from (
        select fecha_local::date as fecha, folio_original, descripcion as producto,
               cantidad, importe, motivo, autorizo
        from v_rep_devolucion where fecha_local >= d and fecha_local < h
        order by fecha_local offset p_offset limit p_limit) t;

  else
    raise exception 'HOJA_DESCONOCIDA: %', p_hoja;
  end if;
end;
$$;

commit;
