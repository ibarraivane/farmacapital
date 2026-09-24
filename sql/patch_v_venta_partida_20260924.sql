-- Una sola fuente de margen: el costo congelado del renglón.
-- 24 sep 2026. Pegar después de los patches de consumos. No se ejecuta desde el repo.

begin;

create or replace view public.v_venta_partida as
select
  pi.id as pedido_item_id,
  pi.pedido_id,
  p.created_at,
  pi.producto_id,
  pi.cantidad::numeric as cantidad,
  pi.precio_unitario::numeric as precio_unitario,
  (pi.cantidad * pi.precio_unitario)::numeric as importe,
  cons.costo::numeric as costo,
  ((pi.cantidad * pi.precio_unitario) - coalesce(cons.costo, 0))::numeric as ganancia,
  coalesce(cons.costo_origen, 'sin_costo') as costo_origen
from public.pedido_items pi
join public.pedidos p on p.id = pi.pedido_id
left join lateral (
  select
    sum(c.cantidad * c.costo_unitario) as costo,
    (array_agg(c.costo_origen order by case c.costo_origen
      when 'sin_costo' then 0
      when 'catalogo_actual' then 1
      when 'estimado_por_fecha' then 2
      when 'lote_estimado' then 3
      when 'caja_abierta' then 4
      else 5
    end))[1] as costo_origen
  from public.pedido_item_consumos c
  where c.pedido_item_id = pi.id
) cons on true;

revoke all on public.v_venta_partida from public, anon, authenticated;

create or replace view public.v_rep_partida as
select
  pi.id                                 as partida_id,
  v.venta_id,
  v.folio,
  v.fecha_local,
  v.vendedor_id,
  v.vendedor,
  v.turno,
  v.metodo_pago,
  pi.producto_id,
  coalesce(pr.codigo_barras, '')        as codigo_barras,
  coalesce(pr.nombre, 'Producto eliminado') as descripcion,
  coalesce(pr.categoria, 'Sin categoría')   as categoria,
  coalesce(pr.marca, '')                as laboratorio,
  pi.cantidad::numeric                  as cantidad,
  pi.precio_unitario::numeric           as precio_unitario,
  0::numeric                            as descuento,
  (pi.cantidad * pi.precio_unitario)::numeric as importe,
  coalesce(
    vp.costo / nullif(pi.cantidad, 0),
    l.costo_unitario,
    pr.costo
  )::numeric as costo_unitario,
  coalesce(vp.costo_origen, case when l.costo_unitario is not null then 'lote' else 'catalogo_actual' end) as costo_origen,
  (coalesce(vp.costo_origen, '') in ('lote', 'lote_estimado', 'caja_abierta')) as costo_es_historico,
  l.numero_lote                         as lote,
  l.fecha_caducidad                     as caducidad
from public.pedido_items pi
join public.v_rep_venta v on v.venta_id = pi.pedido_id
left join public.productos pr on pr.id = pi.producto_id
left join public.lotes l on l.id = pi.lote_id
left join public.v_venta_partida vp on vp.pedido_item_id = pi.id;

create or replace view public.v_rep_lote as
select
  l.producto_id,
  coalesce(l.numero_lote, '')::text as lote,
  coalesce(l.cantidad_actual, 0)::numeric as cantidad,
  l.fecha_caducidad::date           as caducidad,
  l.costo_unitario::numeric         as costo_unitario
from public.lotes l
where l.fecha_caducidad is not null
  and coalesce(l.cantidad_actual, 0) > 0
  and coalesce(l.activo, true);

create or replace function public.fn_rep_costo_origen(desde timestamp, hasta timestamp)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'costo_origen', costo_origen,
    'importe', importe,
    'pct', case when total = 0 then 0 else round(importe / total, 4) end
  ) order by importe desc), '[]'::jsonb)
  from (
    select costo_origen,
           sum(importe) as importe,
           sum(sum(importe)) over () as total
    from public.v_rep_partida
    where fecha_local >= desde and fecha_local < hasta
    group by costo_origen
  ) s;
$$;

-- Inventario del reporte: valor a costo del lote, no al costo de hoy.
create or replace function public.fn_rep_inventario(desde timestamp, hasta timestamp)
returns jsonb language sql stable security definer set search_path = public as $$
with vel as (
  select producto_id, sum(cantidad)/30.0 as piezas_dia, max(fecha_local)::date as ultima_venta
  from v_rep_partida
  where fecha_local >= (hasta - interval '30 days') and fecha_local < hasta
  group by producto_id
),
agot as (
  select p.producto_id, p.descripcion, p.codigo_barras, p.precio_actual,
         v.piezas_dia, v.ultima_venta,
         greatest(0, (hasta::date - v.ultima_venta)) as dias_sin_venta
  from v_rep_producto p
  join vel v on v.producto_id = p.producto_id
  where p.stock <= 0
),
cad as (
  select l.producto_id, p.descripcion, l.lote, l.cantidad, l.caducidad,
         l.cantidad * coalesce(l.costo_unitario, 0) as valor_costo,
         coalesce(v.piezas_dia, 0) as piezas_dia,
         (l.caducidad - hasta::date) as dias_restantes
  from v_rep_lote l
  join v_rep_producto p on p.producto_id = l.producto_id
  left join vel v on v.producto_id = l.producto_id
  where l.caducidad <= (hasta::date + 90) and l.caducidad >= hasta::date
),
valor_lote as (
  select producto_id, sum(coalesce(cantidad_actual, 0) * coalesce(costo_unitario, 0)) as valor
  from public.lotes
  where coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0 and coalesce(costo_unitario, 0) > 0
  group by producto_id
),
sin_rot as (
  select p.producto_id, p.descripcion, p.categoria, p.stock,
         coalesce(vl.valor, 0) as valor_costo,
         (select max(fecha_local)::date from v_rep_partida pa where pa.producto_id = p.producto_id) as ultima_venta
  from v_rep_producto p
  left join valor_lote vl on vl.producto_id = p.producto_id
  where p.stock > 0
    and not exists (
      select 1 from v_rep_partida pa
      where pa.producto_id = p.producto_id
        and pa.fecha_local >= (hasta - interval '60 days')
    )
)
select jsonb_build_object(
  'agotados', coalesce((select jsonb_agg(jsonb_build_object(
      'descripcion', descripcion, 'codigo_barras', codigo_barras,
      'piezas_dia', round(piezas_dia,2), 'dias_sin_venta', dias_sin_venta,
      'venta_perdida', round(piezas_dia * dias_sin_venta * precio_actual, 2))
      order by piezas_dia * dias_sin_venta * precio_actual desc)
      from (select * from agot order by piezas_dia*dias_sin_venta*precio_actual desc limit 25) x),
      '[]'::jsonb),
  'venta_perdida_total', coalesce((select sum(piezas_dia*dias_sin_venta*precio_actual) from agot),0),
  'caducidades', coalesce((select jsonb_agg(jsonb_build_object(
      'descripcion', descripcion, 'lote', lote, 'cantidad', cantidad,
      'caducidad', caducidad, 'dias_restantes', dias_restantes,
      'valor_costo', valor_costo,
      'alcanza', case when piezas_dia = 0 then false
                      else (piezas_dia * dias_restantes) >= cantidad end)
      order by caducidad)
      from (select * from cad order by caducidad limit 40) x), '[]'::jsonb),
  'caducidad_resumen', (select jsonb_build_object(
      'v30', coalesce(sum(valor_costo) filter (where dias_restantes <= 30),0),
      'v60', coalesce(sum(valor_costo) filter (where dias_restantes <= 60),0),
      'v90', coalesce(sum(valor_costo) filter (where dias_restantes <= 90),0)) from cad),
  'sin_rotacion', coalesce((select jsonb_agg(jsonb_build_object(
      'descripcion', descripcion, 'categoria', categoria, 'stock', stock,
      'valor_costo', valor_costo, 'ultima_venta', ultima_venta)
      order by valor_costo desc)
      from (select * from sin_rot order by valor_costo desc limit 30) x), '[]'::jsonb),
  'sin_rotacion_total', coalesce((select sum(valor_costo) from sin_rot),0),
  'sin_rotacion_skus',  coalesce((select count(*) from sin_rot),0),
  'valor_a_costo_lote', coalesce((select sum(valor) from valor_lote), 0),
  'lotes_sin_costo', coalesce((
      select count(*) from public.lotes
      where coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0
        and coalesce(costo_unitario, 0) <= 0
  ), 0)
);
$$;

create or replace function public.rpc_reporte_mensual(p_anio int, p_mes int)
returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  v_desde   timestamp;
  v_hasta   timestamp;
  v_corte   timestamp;
  v_parcial boolean;
  v_dias    int;
  v_pdesde  timestamp;
  v_phasta  timestamp;
  v_hoy     timestamp := fn_rep_local(now());
begin
  perform fn_rep_exige_admin();

  v_desde := make_timestamp(p_anio, p_mes, 1, 0, 0, 0);
  v_hasta := v_desde + interval '1 month';
  v_parcial := v_hoy < v_hasta;
  v_corte := least(v_hasta, date_trunc('day', v_hoy) + interval '1 day');
  v_dias   := (v_corte::date - v_desde::date);
  v_pdesde := v_desde - interval '1 month';
  v_phasta := case when v_parcial then v_pdesde + (v_dias || ' days')::interval
                   else v_desde end;

  return jsonb_build_object(
    'meta', jsonb_build_object(
      'anio', p_anio, 'mes', p_mes,
      'desde', v_desde, 'hasta', v_corte,
      'parcial', v_parcial,
      'generado_at', v_hoy,
      'generado_por', (select nombre from usuarios where id = auth.uid()),
      'zona', 'America/Mexico_City'),
    'resumen',      fn_rep_resumen(v_desde, v_corte),
    'previo',       fn_rep_resumen(v_pdesde, v_phasta),
    'crecimiento',  fn_rep_crecimiento(v_desde, v_corte),
    'tiempo',       fn_rep_tiempo(v_desde, v_corte),
    'productos',    fn_rep_productos(v_desde, v_corte),
    'inventario',   fn_rep_inventario(v_desde, v_corte),
    'dinero',       fn_rep_dinero(v_desde, v_corte),
    'personal',     fn_rep_personal(v_desde, v_corte),
    'costo_origen', fn_rep_costo_origen(v_desde, v_corte)
  );
end;
$$;

create or replace function public.empleado_dashboard_reporte_bundle(
  p_session_token uuid,
  p_desde timestamptz,
  p_desde_fecha date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_rol text;
  v_ve_costo boolean;
begin
  v_user := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user;
  v_ve_costo := coalesce(v_rol, '') <> 'vendedor';

  return jsonb_build_object(
    'peds', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'total', p.total,
          'created_at', p.created_at,
          'tipo', p.tipo,
          'atendido_por', p.atendido_por,
          'usuarios', jsonb_build_object('nombre', u.nombre)
        )
        order by p.created_at desc
      )
      from public.pedidos p
      left join public.usuarios u on u.id = p.atendido_por
      where (p.estado)::text = 'completado'
        and p.created_at >= p_desde
    ), '[]'::jsonb),
    'cons', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', c.id,
        'precio_consulta_cobrado', c.precio_consulta_cobrado
      ))
      from public.citas c
      where c.fecha >= p_desde_fecha
        and coalesce(c.estado,'') <> 'cancelada'
        and c.pedido_consulta_id is not null
    ), '[]'::jsonb),
    'ponl', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where (p.estado)::text='completado' and (p.tipo)::text='online' and p.created_at >= p_desde), '[]'::jsonb),
    'devs', coalesce((select jsonb_agg(jsonb_build_object('total_devuelto', d.total_devuelto)) from public.devoluciones d where (d.estado)::text='aprobada' and d.created_at >= p_desde), '[]'::jsonb),
    'peds_cat', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'total', p.total,
          'created_at', p.created_at,
          'productos', coalesce(pi.js, '[]'::jsonb)
        )
        order by p.created_at desc
      )
      from public.pedidos p
      left join lateral (
        select jsonb_agg(
          case when v_ve_costo then jsonb_build_object(
            'precio_unitario', x.precio_unitario,
            'cantidad', x.cantidad,
            'costo_vendido', vp.costo,
            'costo_origen', vp.costo_origen,
            'productos', jsonb_build_object(
              'categoria', pr.categoria,
              'costo', pr.costo,
              'precio', pr.precio,
              'precio_unidad', pr.precio_unidad,
              'venta_unidad', pr.venta_unidad,
              'unidades_por_caja', pr.unidades_por_caja
            )
          ) else jsonb_build_object(
            'precio_unitario', x.precio_unitario,
            'cantidad', x.cantidad,
            'productos', jsonb_build_object(
              'categoria', pr.categoria,
              'precio', pr.precio,
              'precio_unidad', pr.precio_unidad,
              'venta_unidad', pr.venta_unidad,
              'unidades_por_caja', pr.unidades_por_caja
            )
          ) end
          order by x.id
        ) as js
        from public.pedido_items x
        join public.productos pr on pr.id = x.producto_id
        left join public.v_venta_partida vp on vp.pedido_item_id = x.id
        where x.pedido_id = p.id
      ) pi on true
      where (p.estado)::text = 'completado'
        and p.created_at >= p_desde
    ), '[]'::jsonb),
    'peds_receta_farmax', coalesce((select jsonb_agg(jsonb_build_object('total', p.total)) from public.pedidos p where (p.estado)::text='completado' and (p.receta_origen)::text='medico_farmax' and p.created_at >= p_desde), '[]'::jsonb),
    'citas_receta_ext_period_count', (
      select count(*)::int from public.citas c
      where c.fecha >= p_desde_fecha
        and coalesce(c.receta_surtido_en,'') = 'externa'
        and coalesce(c.estado,'') <> 'cancelada'
        and ((c.estado)::text = any(array['completada','pagada']) or coalesce(c.pago_estado,'')='pagada')
    )
  );
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
  v_user bigint;
  v_rol text;
  v_ve_costo boolean;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_desde is null then
    raise exception 'p_desde requerido';
  end if;
  select rol into v_rol from public.usuarios where id = v_user;
  v_ve_costo := coalesce(v_rol, '') <> 'vendedor';

  return coalesce((
    select jsonb_agg(
      case when v_ve_costo then jsonb_build_object(
        'dia', d.dia, 'total', d.total, 'tickets', d.tickets,
        'devoluciones', d.devoluciones, 'costo', d.costo, 'ganancia', d.ganancia
      ) else jsonb_build_object(
        'dia', d.dia, 'total', d.total, 'tickets', d.tickets, 'devoluciones', d.devoluciones
      ) end
      order by d.dia)
    from (
      select
        coalesce(v.dia, dv.dia, g.dia) as dia,
        coalesce(v.total, 0)::numeric as total,
        coalesce(v.tickets, 0)::int as tickets,
        coalesce(dv.devoluciones, 0)::numeric as devoluciones,
        coalesce(g.costo, 0)::numeric as costo,
        coalesce(g.ganancia, 0)::numeric as ganancia
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
      full outer join (
        select
          ((vp.created_at at time zone 'America/Mexico_City')::date) as dia,
          sum(coalesce(vp.costo, 0))::numeric as costo,
          sum(coalesce(vp.ganancia, 0))::numeric as ganancia
        from public.v_venta_partida vp
        join public.pedidos p on p.id = vp.pedido_id
        where (p.estado)::text = 'completado'
          and ((vp.created_at at time zone 'America/Mexico_City')::date) >= p_desde
        group by 1
      ) g on g.dia = coalesce(v.dia, dv.dia)
    ) d
  ), '[]'::jsonb);
end;
$$;

commit;
