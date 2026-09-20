-- =====================================================================
-- FarmaCapital — Reporte mensual (PDF) y exportación de transacciones (Excel)
-- Migración 20260920100000
--
-- ESTRUCTURA:
--   0. Utilidades (zona horaria, validación de rol)
--   1. CAPA DE ADAPTACIÓN  ← ES LO ÚNICO QUE HAY QUE AJUSTAR AL ESQUEMA REAL
--   2. Funciones de bloque (una por sección del reporte)
--   3. RPC rpc_reporte_mensual  → JSON con todo el PDF
--   4. RPC rpc_transacciones_mes → filas planas para el Excel
--   5. Permisos
--
-- REGLA: nada fuera de la sección 1 toca una tabla real. Si el esquema no
-- coincide, se corrigen las vistas de la sección 1 y todo lo demás sigue
-- funcionando sin cambios.
-- =====================================================================

set search_path = public;

-- =====================================================================
-- 0. UTILIDADES
-- =====================================================================

-- Toda fecha se interpreta en hora local de la CDMX. Supabase guarda en UTC.
-- Si esto se omite, el mapa de calor y el "día de mayor venta" salen corridos.
create or replace function fn_rep_local(ts timestamptz)
returns timestamp
language sql immutable as $$
  select (ts at time zone 'America/Mexico_City');
$$;

-- FarmaCapital no usa auth.uid(): la sesión es un token de empleado.
-- El wrapper setea farmacapital.session_token antes de llamar los RPC.
create or replace function fn_rep_es_admin()
returns boolean
language plpgsql stable security definer
set search_path = public, pg_temp as $$
declare
  v_tok text;
  v_uid bigint;
  v_rol text;
begin
  v_tok := nullif(current_setting('farmacapital.session_token', true), '');
  if v_tok is null then
    return false;
  end if;
  begin
    v_uid := public.fn_validar_token_empleado(v_tok::uuid);
  exception when others then
    return false;
  end;
  if v_uid is null then
    return false;
  end if;
  select rol into v_rol
    from public.usuarios
   where id = v_uid and coalesce(activo, true) and eliminado_at is null;
  return v_rol = 'admin';
end;
$$;

create or replace function fn_rep_exige_admin()
returns void
language plpgsql stable as $$
begin
  if not fn_rep_es_admin() then
    raise exception 'ACCESO_DENEGADO: este reporte es exclusivo del rol admin'
      using errcode = '42501';
  end if;
end;
$$;


-- =====================================================================
-- 1. CAPA DE ADAPTACIÓN
--    >>> ÚNICA SECCIÓN QUE SE MODIFICA PARA EMPATAR CON EL ESQUEMA REAL <<<
--
--    Cada vista debe devolver exactamente las columnas declaradas, con esos
--    nombres y tipos. Lo de adentro se adapta libremente.
--    Si una fuente no existe todavía (devoluciones, costo histórico,
--    cliente), dejar la vista devolviendo cero filas con los tipos correctos:
--    el reporte se genera igual y el bloque sale vacío, no truena.
-- =====================================================================

-- 1.1 Un renglón por ticket completado ---------------------------------
create or replace view v_rep_venta as
select
  p.id                                  as venta_id,
  p.id::text                            as folio,
  fn_rep_local(p.created_at)            as fecha_local,
  p.atendido_por                        as vendedor_id,
  coalesce(u.nombre, 'Sin asignar')     as vendedor,
  (
    select s.id
    from public.caja_sesiones s
    where s.empleado_id = p.atendido_por
      and s.abierta_at <= p.created_at
      and (s.cerrada_at is null or s.cerrada_at >= p.created_at)
    order by s.abierta_at desc
    limit 1
  )                                     as caja_sesion_id,
  case
    when extract(hour from fn_rep_local(p.created_at)) * 60
       + extract(minute from fn_rep_local(p.created_at)) < 15 * 60 + 30
    then 'matutino' else 'vespertino'
  end                                   as turno,
  case
    when lower(coalesce(p.tipo, '')) = 'online' then 'en línea'
    else 'mostrador'
  end                                   as canal,
  lower(coalesce(p.metodo_pago, ''))    as metodo_pago,
  coalesce(p.subtotal_productos, p.total)::numeric as subtotal,
  0::numeric                            as descuento,
  p.total::numeric                      as total,
  coalesce(cl.nombre, p.guest_nombre, '') as cliente_id
from public.pedidos p
left join public.usuarios u on u.id = p.atendido_por
left join public.clientes cl on cl.id = p.cliente_id
where p.estado = 'completado';

-- 1.2 Un renglón por producto vendido -----------------------------------
create or replace view v_rep_partida as
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
  coalesce(l.costo_unitario, pr.costo)::numeric as costo_unitario,
  (l.costo_unitario is not null)        as costo_es_historico,
  l.numero_lote                         as lote,
  l.fecha_caducidad                     as caducidad
from public.pedido_items pi
join v_rep_venta v on v.venta_id = pi.pedido_id
left join public.productos pr on pr.id = pi.producto_id
left join public.lotes l on l.id = pi.lote_id;

-- 1.3 Catálogo de productos ---------------------------------------------
create or replace view v_rep_producto as
select
  pr.id                                 as producto_id,
  coalesce(pr.codigo_barras, '')        as codigo_barras,
  pr.nombre                             as descripcion,
  coalesce(pr.categoria, 'Sin categoría') as categoria,
  coalesce(pr.marca, '')                as laboratorio,
  coalesce(pr.costo, 0)::numeric        as costo_actual,
  coalesce(pr.precio, 0)::numeric       as precio_actual,
  greatest(coalesce(pr.stock, 0), coalesce(l.stock_lotes, 0))::numeric as stock
from public.productos pr
left join (
  select producto_id, sum(cantidad_actual) as stock_lotes
  from public.lotes
  where coalesce(activo, true)
  group by producto_id
) l on l.producto_id = pr.id;

-- 1.4 Lotes con caducidad ------------------------------------------------
create or replace view v_rep_lote as
select
  l.producto_id,
  coalesce(l.numero_lote, '')::text as lote,
  coalesce(l.cantidad_actual, 0)::numeric as cantidad,
  l.fecha_caducidad::date           as caducidad
from public.lotes l
where l.fecha_caducidad is not null
  and coalesce(l.cantidad_actual, 0) > 0
  and coalesce(l.activo, true);

-- 1.5 Pagos de servicio (recargas, CFE) — NO son venta -------------------
create or replace view v_rep_pago_servicio as
select
  ps.id                              as pago_id,
  fn_rep_local(ps.created_at)        as fecha_local,
  coalesce(ps.categoria, 'otro')     as tipo,
  coalesce(ps.referencia, '')        as referencia,
  coalesce(ps.monto_servicio, 0)::numeric as monto,
  coalesce(ps.comision, 0)::numeric  as comision,
  lower(coalesce(ps.metodo_pago,'efectivo')) as metodo_pago,
  ps.atendido_por                    as vendedor_id,
  coalesce(u.nombre,'')              as vendedor
from public.pagos_servicio ps
left join public.usuarios u on u.id = ps.atendido_por;

-- 1.6 Cortes de caja -----------------------------------------------------
create or replace view v_rep_corte as
select
  c.id                                 as corte_id,
  coalesce(
    fn_rep_local(s.abierta_at)::date,
    c.fecha
  )                                    as fecha_local,
  c.turno                              as turno,
  c.empleado_id                        as vendedor_id,
  coalesce(u.nombre,'')                as vendedor,
  fn_rep_local(coalesce(
    s.abierta_at,
    ((c.fecha::text || ' 08:00:00')::timestamp at time zone 'America/Mexico_City')
  ))                                   as abierta_at,
  fn_rep_local(s.cerrada_at)           as cerrada_at,
  coalesce(c.fondo_inicial,0)::numeric      as fondo_inicial,
  coalesce(c.efectivo_declarado,0)::numeric as efectivo_declarado,
  coalesce(c.efectivo_sistema,0)::numeric   as efectivo_sistema,
  (coalesce(c.fondo_inicial,0) + coalesce(c.efectivo_sistema,0))::numeric as esperado,
  coalesce(c.diferencia,0)::numeric    as diferencia,
  coalesce(c.total_tarjeta,0)::numeric as tarjeta,
  coalesce(c.total_spei,0)::numeric    as spei,
  coalesce(c.total_mercadopago,0)::numeric as mercadopago,
  coalesce(c.total_general,0)::numeric as total_general,
  case
    when c.anulado_at is not null then 'anulada'
    else 'cerrada'
  end                                  as estado
from public.cortes_caja c
left join public.caja_sesiones s on s.corte_id = c.id
left join public.usuarios u on u.id = c.empleado_id;

-- 1.7 Devoluciones -------------------------------------------------------
create or replace view v_rep_devolucion as
select
  di.id                              as devolucion_id,
  fn_rep_local(d.created_at)         as fecha_local,
  coalesce(d.pedido_id::text, '')    as folio_original,
  di.producto_id,
  coalesce(nullif(btrim(di.producto_nombre), ''), pr.nombre, '') as descripcion,
  coalesce(di.cantidad,0)::numeric   as cantidad,
  (coalesce(di.cantidad,0) * coalesce(di.precio_unitario,0))::numeric as importe,
  coalesce(d.motivo,'')              as motivo,
  coalesce(ua.nombre,'')             as autorizo
from public.devoluciones d
join public.devolucion_items di on di.devolucion_id = d.id
left join public.productos pr on pr.id = di.producto_id
left join public.usuarios ua on ua.id = coalesce(d.aprobado_por, d.atendido_por)
where d.estado = 'aprobada';


-- =====================================================================
-- 2. FUNCIONES DE BLOQUE
--    Todas reciben el rango local [desde, hasta) y devuelven jsonb.
-- =====================================================================

-- 2.1 Resumen de un rango cualquiera ------------------------------------
create or replace function fn_rep_resumen(desde timestamp, hasta timestamp)
returns jsonb language sql stable security definer set search_path = public as $$
with v as (
  select * from v_rep_venta where fecha_local >= desde and fecha_local < hasta
),
pa as (
  select * from v_rep_partida where fecha_local >= desde and fecha_local < hasta
),
dev as (
  select coalesce(sum(importe),0) imp, count(*) n
  from v_rep_devolucion where fecha_local >= desde and fecha_local < hasta
),
hrs as (
  select coalesce(sum(extract(epoch from (cerrada_at - abierta_at))/3600),0) h
  from v_rep_corte
  where abierta_at >= desde and abierta_at < hasta
    and cerrada_at is not null and estado <> 'forzada'
)
select jsonb_build_object(
  'venta_bruta',     coalesce((select sum(total) from v),0),
  'devoluciones',    (select imp from dev),
  'devoluciones_n',  (select n from dev),
  'venta_neta',      coalesce((select sum(total) from v),0) - (select imp from dev),
  'tickets',         (select count(*) from v),
  'ticket_promedio', case when (select count(*) from v) = 0 then 0
                     else (coalesce((select sum(total) from v),0) - (select imp from dev))
                          / (select count(*) from v) end,
  'piezas',          coalesce((select sum(cantidad) from pa),0),
  'piezas_x_ticket', case when (select count(*) from v) = 0 then 0
                     else coalesce((select sum(cantidad) from pa),0)::numeric
                          / (select count(*) from v) end,
  'costo_vendido',   coalesce((select sum(cantidad * costo_unitario) from pa),0),
  'utilidad_bruta',  coalesce((select sum(total) from v),0) - (select imp from dev)
                     - coalesce((select sum(cantidad * costo_unitario) from pa),0),
  'margen_pct',      case when coalesce((select sum(total) from v),0) = 0 then 0
                     else (coalesce((select sum(total) from v),0) - (select imp from dev)
                           - coalesce((select sum(cantidad * costo_unitario) from pa),0))
                          / nullif(coalesce((select sum(total) from v),0) - (select imp from dev),0) end,
  'horas_abiertas',  (select h from hrs),
  'venta_por_hora',  case when (select h from hrs) = 0 then 0
                     else (coalesce((select sum(total) from v),0) - (select imp from dev))
                          / (select h from hrs) end,
  -- Calidad del dato: qué parte de la venta se valuó con costo histórico real
  'pct_costo_historico', case when coalesce((select sum(importe) from pa),0) = 0 then 0
                         else coalesce((select sum(importe) from pa where costo_es_historico),0)
                              / (select sum(importe) from pa) end
);
$$;

-- 2.2 Crecimiento: semanas y serie de 6 meses ---------------------------
create or replace function fn_rep_crecimiento(desde timestamp, hasta timestamp)
returns jsonb language sql stable security definer set search_path = public as $$
with sem as (
  select
    date_trunc('week', fecha_local)::date          as semana,
    greatest(date_trunc('week', fecha_local)::date, desde::date) as ini,
    least((date_trunc('week', fecha_local) + interval '6 days')::date, (hasta - interval '1 day')::date) as fin,
    sum(total)   as venta,
    count(*)     as tickets
  from v_rep_venta
  where fecha_local >= desde and fecha_local < hasta
  group by 1
),
sem_n as (
  select *, row_number() over (order by semana) as n,
         lag(venta) over (order by semana) as venta_prev,
         (semana < desde::date or (semana + 6) > (hasta - interval '1 day')::date) as parcial
  from sem
),
meses as (
  select
    date_trunc('month', fecha_local)::date as mes,
    sum(total) as venta,
    count(*)   as tickets
  from v_rep_venta
  where fecha_local >= (desde - interval '5 months') and fecha_local < hasta
  group by 1 order by 1
)
select jsonb_build_object(
  'semanas', coalesce((
    select jsonb_agg(jsonb_build_object(
      'n', n, 'inicio', ini, 'fin', fin, 'parcial', parcial,
      'venta', venta, 'tickets', tickets,
      'variacion', case when coalesce(venta_prev,0) = 0 then null
                        else (venta - venta_prev) / venta_prev end
    ) order by n) from sem_n), '[]'::jsonb),
  'serie_meses', coalesce((
    select jsonb_agg(jsonb_build_object(
      'mes', mes, 'venta', venta, 'tickets', tickets,
      'ticket_promedio', case when tickets = 0 then 0 else venta/tickets end
    ) order by mes) from meses), '[]'::jsonb)
);
$$;

-- 2.3 Cuándo se vende ----------------------------------------------------
create or replace function fn_rep_tiempo(desde timestamp, hasta timestamp)
returns jsonb language sql stable security definer set search_path = public as $$
with v as (
  select fecha_local, total,
         extract(dow  from fecha_local)::int  as dow,
         extract(hour from fecha_local)::int  as hora,
         fecha_local::date                    as dia,
         extract(day  from fecha_local)::int  as num_dia
  from v_rep_venta where fecha_local >= desde and fecha_local < hasta
),
celdas as (
  select dow, hora, sum(total) venta, count(*) tickets
  from v where hora between 8 and 22 group by 1,2
),
dias as (
  select dia, sum(total) venta, count(*) tickets from v group by 1
),
dow_prom as (
  select dow, sum(total) venta, count(*) tickets,
         count(distinct dia) as n_dias
  from v group by 1
),
quincena as (
  select
    sum(total) filter (where num_dia in (1,2,15,16)) as venta_q,
    count(distinct dia) filter (where num_dia in (1,2,15,16)) as dias_q,
    sum(total) filter (where num_dia not in (1,2,15,16)) as venta_r,
    count(distinct dia) filter (where num_dia not in (1,2,15,16)) as dias_r
  from v
),
horas_tot as (
  select hora, count(*) tickets, count(distinct dia) n_dias
  from v where hora between 8 and 22 group by 1
)
select jsonb_build_object(
  'heatmap', coalesce((select jsonb_agg(jsonb_build_object(
      'dow', dow, 'hora', hora, 'venta', venta, 'tickets', tickets)) from celdas), '[]'::jsonb),
  'mejor_dia', (select jsonb_build_object('dia', dia, 'venta', venta, 'tickets', tickets)
                from dias order by venta desc limit 1),
  'peor_dia',  (select jsonb_build_object('dia', dia, 'venta', venta, 'tickets', tickets)
                from dias order by venta asc limit 1),
  'por_dia', coalesce((select jsonb_agg(jsonb_build_object(
      'dia', dia, 'venta', venta, 'tickets', tickets) order by dia) from dias), '[]'::jsonb),
  'por_dow', coalesce((select jsonb_agg(jsonb_build_object(
      'dow', dow, 'venta', venta, 'tickets', tickets, 'n_dias', n_dias,
      'venta_promedio', case when n_dias=0 then 0 else venta/n_dias end) order by dow)
      from dow_prom), '[]'::jsonb),
  'quincena', (select jsonb_build_object(
      'promedio_quincena', case when coalesce(dias_q,0)=0 then 0 else venta_q/dias_q end,
      'promedio_resto',    case when coalesce(dias_r,0)=0 then 0 else venta_r/dias_r end)
      from quincena),
  'horas_muertas', coalesce((select jsonb_agg(jsonb_build_object(
      'hora', hora, 'tickets_por_dia', tickets::numeric/nullif(n_dias,0)) order by hora)
      from horas_tot where n_dias > 0 and tickets::numeric/n_dias < 3), '[]'::jsonb)
);
$$;

-- 2.4 Qué se vende -------------------------------------------------------
create or replace function fn_rep_productos(desde timestamp, hasta timestamp)
returns jsonb language sql stable security definer set search_path = public as $$
with pa as (
  select * from v_rep_partida where fecha_local >= desde and fecha_local < hasta
),
prod as (
  select producto_id, min(codigo_barras) codigo_barras, min(descripcion) descripcion,
         min(categoria) categoria,
         sum(cantidad) piezas, sum(importe) importe,
         sum(cantidad * costo_unitario) costo,
         sum(importe) - sum(cantidad * costo_unitario) utilidad
  from pa group by producto_id
),
total as (select nullif(sum(importe),0) t from prod),
abc as (
  select p.*,
         p.importe / (select t from total) as part,
         sum(p.importe) over (order by p.importe desc rows unbounded preceding)
           / (select t from total) as acum
  from prod p
),
clasif as (
  select *, case when acum <= 0.80 then 'A' when acum <= 0.95 then 'B' else 'C' end as clase
  from abc
),
cat as (
  select categoria, sum(importe) importe, sum(cantidad*costo_unitario) costo,
         sum(cantidad) piezas
  from pa group by categoria
)
select jsonb_build_object(
  'top_importe', coalesce((select jsonb_agg(jsonb_build_object(
      'descripcion', descripcion, 'codigo_barras', codigo_barras,
      'piezas', piezas, 'importe', importe) order by importe desc)
      from (select * from prod order by importe desc limit 20) x), '[]'::jsonb),
  'top_piezas', coalesce((select jsonb_agg(jsonb_build_object(
      'descripcion', descripcion, 'codigo_barras', codigo_barras,
      'piezas', piezas, 'importe', importe) order by piezas desc)
      from (select * from prod order by piezas desc limit 20) x), '[]'::jsonb),
  'top_utilidad', coalesce((select jsonb_agg(jsonb_build_object(
      'descripcion', descripcion, 'piezas', piezas, 'importe', importe,
      'utilidad', utilidad,
      'margen_pct', case when importe=0 then 0 else utilidad/importe end)
      order by utilidad desc)
      from (select * from prod order by utilidad desc limit 20) x), '[]'::jsonb),
  'abc', (select jsonb_build_object(
      'A', count(*) filter (where clase='A'),
      'B', count(*) filter (where clase='B'),
      'C', count(*) filter (where clase='C'),
      'venta_A', coalesce(sum(importe) filter (where clase='A'),0),
      'venta_B', coalesce(sum(importe) filter (where clase='B'),0),
      'venta_C', coalesce(sum(importe) filter (where clase='C'),0),
      'skus', count(*)) from clasif),
  'categorias', coalesce((select jsonb_agg(jsonb_build_object(
      'categoria', categoria, 'importe', importe, 'piezas', piezas,
      'utilidad', importe - costo,
      'margen_pct', case when importe=0 then 0 else (importe-costo)/importe end)
      order by importe desc) from cat), '[]'::jsonb),
  'concentracion_top10', coalesce((
      select sum(importe) from (select importe from prod order by importe desc limit 10) y)
      / nullif((select t from total),0), 0)
);
$$;

-- 2.5 Inventario ---------------------------------------------------------
create or replace function fn_rep_inventario(desde timestamp, hasta timestamp)
returns jsonb language sql stable security definer set search_path = public as $$
with vel as (  -- velocidad: piezas por día en los últimos 30 días del periodo
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
         l.cantidad * p.costo_actual as valor_costo,
         coalesce(v.piezas_dia, 0) as piezas_dia,
         (l.caducidad - hasta::date) as dias_restantes
  from v_rep_lote l
  join v_rep_producto p on p.producto_id = l.producto_id
  left join vel v on v.producto_id = l.producto_id
  where l.caducidad <= (hasta::date + 90) and l.caducidad >= hasta::date
),
sin_rot as (
  select p.producto_id, p.descripcion, p.categoria, p.stock,
         p.stock * p.costo_actual as valor_costo,
         (select max(fecha_local)::date from v_rep_partida pa where pa.producto_id = p.producto_id) as ultima_venta
  from v_rep_producto p
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
  'sin_rotacion_skus',  coalesce((select count(*) from sin_rot),0)
);
$$;

-- 2.6 Dinero: mezcla de pago, servicios, descuentos, devoluciones, caja --
create or replace function fn_rep_dinero(desde timestamp, hasta timestamp)
returns jsonb language sql stable security definer set search_path = public as $$
with v as (select * from v_rep_venta where fecha_local >= desde and fecha_local < hasta),
mezcla as (
  select metodo_pago, sum(total) importe, count(*) tickets from v group by 1
),
serv as (
  select tipo, count(*) n, sum(monto) monto, sum(comision) comision
  from v_rep_pago_servicio where fecha_local >= desde and fecha_local < hasta
  group by 1
),
dev as (
  select producto_id, descripcion, sum(cantidad) piezas, sum(importe) importe, count(*) n
  from v_rep_devolucion where fecha_local >= desde and fecha_local < hasta
  group by 1,2
),
cortes as (
  select * from v_rep_corte where abierta_at >= desde and abierta_at < hasta
)
select jsonb_build_object(
  'mezcla_pago', coalesce((select jsonb_agg(jsonb_build_object(
      'metodo', metodo_pago, 'importe', importe, 'tickets', tickets)
      order by importe desc) from mezcla), '[]'::jsonb),
  'descuentos_total', coalesce((select sum(descuento) from v),0),
  'pagos_servicio', coalesce((select jsonb_agg(jsonb_build_object(
      'tipo', tipo, 'operaciones', n, 'monto', monto, 'comision', comision)
      order by monto desc) from serv), '[]'::jsonb),
  'pagos_servicio_total', coalesce((select sum(monto) from serv),0),
  'pagos_servicio_comision', coalesce((select sum(comision) from serv),0),
  'devoluciones_top', coalesce((select jsonb_agg(jsonb_build_object(
      'descripcion', descripcion, 'piezas', piezas, 'importe', importe, 'eventos', n)
      order by importe desc)
      from (select * from dev order by importe desc limit 5) x), '[]'::jsonb),
  'caja', (select jsonb_build_object(
      'cortes', count(*),
      'faltantes', abs(coalesce(sum(diferencia) filter (where diferencia < 0),0)),
      'sobrantes', coalesce(sum(diferencia) filter (where diferencia > 0),0),
      'neto', coalesce(sum(diferencia),0),
      'fuera_tolerancia', count(*) filter (where abs(diferencia) > 50),
      'forzados', count(*) filter (where estado = 'forzada')
      ) from cortes)
);
$$;

-- 2.7 Personal -----------------------------------------------------------
create or replace function fn_rep_personal(desde timestamp, hasta timestamp)
returns jsonb language sql stable security definer set search_path = public as $$
with horas as (
  select vendedor_id, vendedor,
         sum(extract(epoch from (cerrada_at - abierta_at))/3600) as horas,
         count(*) as turnos,
         abs(coalesce(sum(diferencia) filter (where diferencia < 0),0)) as faltantes,
         coalesce(sum(diferencia) filter (where diferencia > 0),0) as sobrantes,
         count(*) filter (
           where abierta_at::time > (case when turno = 'vespertino'
                 then time '15:10' else time '08:10' end)) as retardos
  from v_rep_corte
  where abierta_at >= desde and abierta_at < hasta
    and cerrada_at is not null and estado <> 'forzada'
  group by 1,2
),
ventas as (
  select vendedor_id, sum(total) venta, count(*) tickets from v_rep_venta
  where fecha_local >= desde and fecha_local < hasta group by 1
),
piezas as (
  select vendedor_id, sum(cantidad) piezas from v_rep_partida
  where fecha_local >= desde and fecha_local < hasta group by 1
),
forzados as (
  select vendedor, fecha_local, turno from v_rep_corte
  where abierta_at >= desde and abierta_at < hasta and estado = 'forzada'
)
select jsonb_build_object(
  'personal', coalesce((select jsonb_agg(jsonb_build_object(
      'vendedor', h.vendedor,
      'horas', round(h.horas::numeric, 1),
      'turnos', h.turnos,
      'venta', coalesce(vt.venta,0),
      'venta_por_hora', case when h.horas = 0 then 0 else coalesce(vt.venta,0)/h.horas::numeric end,
      'tickets', coalesce(vt.tickets,0),
      'ticket_promedio', case when coalesce(vt.tickets,0)=0 then 0 else vt.venta/vt.tickets end,
      'piezas_x_ticket', case when coalesce(vt.tickets,0)=0 then 0
                         else coalesce(pz.piezas,0)::numeric/vt.tickets end,
      'puntualidad', case when h.turnos = 0 then 0
                     else 1 - (h.retardos::numeric / h.turnos) end,
      'faltantes', h.faltantes,
      'sobrantes', h.sobrantes)
      order by case when h.horas = 0 then 0 else coalesce(vt.venta,0)/h.horas::numeric end desc)
      from horas h
      left join ventas vt on vt.vendedor_id = h.vendedor_id
      left join piezas pz on pz.vendedor_id = h.vendedor_id), '[]'::jsonb),
  'turnos_forzados', coalesce((select jsonb_agg(jsonb_build_object(
      'vendedor', vendedor, 'fecha', fecha_local, 'turno', turno)) from forzados), '[]'::jsonb)
);
$$;


-- =====================================================================
-- 3. RPC PRINCIPAL DEL PDF
-- =====================================================================
create or replace function rpc_reporte_mensual(p_anio int, p_mes int)
returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  v_desde   timestamp;
  v_hasta   timestamp;
  v_corte   timestamp;          -- fin real (si el mes está en curso, hoy)
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

  -- Mes anterior comparado contra el MISMO TRAMO, no contra el mes completo.
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
    'personal',     fn_rep_personal(v_desde, v_corte)
  );
end;
$$;


-- =====================================================================
-- 4. RPC DE FILAS PLANAS PARA EL EXCEL
--    p_hoja: transacciones | detalle | diario | productos | por_hora
--            | pagos_servicio | cortes | devoluciones
-- =====================================================================
create or replace function rpc_transacciones_mes(
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
    return query
      select to_jsonb(t) from (
        select v.fecha_local::date as fecha, to_char(v.fecha_local,'TMDay') as dia_semana,
               sum(v.total) as venta_neta, count(*) as tickets,
               sum(v.total)/count(*) as ticket_promedio,
               coalesce((select sum(cantidad) from v_rep_partida pa
                         where pa.fecha_local::date = v.fecha_local::date),0) as piezas,
               coalesce((select sum(cantidad*costo_unitario) from v_rep_partida pa
                         where pa.fecha_local::date = v.fecha_local::date),0) as costo,
               sum(v.total) filter (where metodo_pago='efectivo')    as efectivo,
               sum(v.total) filter (where metodo_pago='tarjeta')     as tarjeta,
               sum(v.total) filter (where metodo_pago='spei')        as spei,
               sum(v.total) filter (where metodo_pago='mercadopago') as mercadopago
        from v_rep_venta v
        where v.fecha_local >= d and v.fecha_local < h
        group by 1,2 order by 1 offset p_offset limit p_limit) t;

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


-- =====================================================================
-- 5. PERMISOS
--    Las vistas exponen COSTO. Nadie las lee directo: solo las funciones
--    security definer, que validan rol admin antes de devolver nada.
-- =====================================================================
revoke all on v_rep_venta, v_rep_partida, v_rep_producto, v_rep_lote,
              v_rep_pago_servicio, v_rep_corte, v_rep_devolucion
  from public, anon, authenticated;

revoke all on function rpc_reporte_mensual(int,int)             from public, anon;
revoke all on function rpc_transacciones_mes(int,int,text,int,int) from public, anon;

grant execute on function rpc_reporte_mensual(int,int)              to authenticated;
grant execute on function rpc_transacciones_mes(int,int,text,int,int) to authenticated;

-- Índices de apoyo (crear solo si no existen equivalentes)
create index if not exists idx_pedidos_created_estado on pedidos (created_at) where estado = 'completado';
create index if not exists idx_pedido_items_pedido    on pedido_items (pedido_id);
create index if not exists idx_pedido_items_producto  on pedido_items (producto_id);
create index if not exists idx_caja_sesiones_abierta  on caja_sesiones (abierta_at);
create index if not exists idx_pagos_servicio_created on pagos_servicio (created_at);

-- =====================================================================
-- 6. Wrappers FarmaCapital (token de empleado, no auth.uid)
-- =====================================================================
create or replace function public.empleado_rpc_reporte_mensual(
  p_session_token uuid,
  p_anio int,
  p_mes int
)
returns jsonb
language plpgsql stable security definer
set search_path = public, pg_temp
as $$
begin
  perform set_config('farmacapital.session_token', p_session_token::text, true);
  return public.rpc_reporte_mensual(p_anio, p_mes);
end;
$$;

create or replace function public.empleado_rpc_transacciones_mes(
  p_session_token uuid,
  p_anio int,
  p_mes int,
  p_hoja text,
  p_offset int default 0,
  p_limit int default 5000
)
returns setof jsonb
language plpgsql stable security definer
set search_path = public, pg_temp
as $$
begin
  perform set_config('farmacapital.session_token', p_session_token::text, true);
  return query
    select * from public.rpc_transacciones_mes(p_anio, p_mes, p_hoja, p_offset, p_limit);
end;
$$;

revoke all on function public.empleado_rpc_reporte_mensual(uuid, int, int) from public;
revoke all on function public.empleado_rpc_transacciones_mes(uuid, int, int, text, int, int) from public;
grant execute on function public.empleado_rpc_reporte_mensual(uuid, int, int) to anon, authenticated;
grant execute on function public.empleado_rpc_transacciones_mes(uuid, int, int, text, int, int) to anon, authenticated;
