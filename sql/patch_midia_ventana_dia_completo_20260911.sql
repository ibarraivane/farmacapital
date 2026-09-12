-- FarmaCapital — 11-sep-2026
-- Mi Día 0% con ventas propias en la mañana.
--
-- Causa residual: el cliente mandaba p_turno_start/end del TURNO DE PERFIL
-- (ej. vespertino = desde 15:30). Las ventas 09:xx quedaban fuera del filtro A.
-- Si además se re-aplicó patch_atendido_por_caja_meta DESPUÉS de
-- patch_midia_meta_por_sesion_caja, el filtro B (sesión de caja) se perdía.
--
-- Este patch:
--  1) Restaura A|B (atendido_por O sesión de caja).
--  2) En A, acepta el día civil CDMX además de la ventana del cliente.
-- Idempotente. Pegar en Supabase SQL Editor DESPUÉS de los otros dos de hoy.

begin;

create or replace function public.empleado_midia_snapshot(
  p_session_token uuid,
  p_empleado_id bigint,
  p_turno_start timestamptz,
  p_turno_end timestamptz,
  p_mes_start timestamptz,
  p_fecha_citas date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_hoy date := (now() at time zone 'America/Mexico_City')::date;
  v_dia_ini timestamptz := (v_hoy::timestamp at time zone 'America/Mexico_City');
  v_dia_fin timestamptz := ((v_hoy + 1)::timestamp at time zone 'America/Mexico_City');
begin
  v_actor := public.fn_require_empleado(p_session_token);
  if exists (
    select 1 from public.usuarios u
    where u.id = v_actor and lower(coalesce(u.rol, '')) in ('admin', 'gerente')
  ) and p_empleado_id is not null then
    v_actor := p_empleado_id;
  end if;

  return jsonb_build_object(
    'ped_turno', coalesce((
      select jsonb_agg(row_js order by ord)
      from (
        select
          jsonb_build_object(
            'id', p.id,
            'total', p.total,
            'cliente_id', p.cliente_id,
            'created_at', p.created_at,
            'pedido_items', coalesce(pi.js, '[]'::jsonb)
          ) as row_js,
          p.created_at as ord
        from public.pedidos p
        left join lateral (
          select jsonb_agg(
            jsonb_build_object(
              'cantidad', x.cantidad,
              'productos', jsonb_build_object(
                'nombre', pr.nombre,
                'sku', pr.sku,
                'categoria', pr.categoria
              ),
              'lotes', jsonb_build_object(
                'numero_lote', lo.numero_lote
              )
            )
            order by x.id
          ) as js
          from public.pedido_items x
          join public.productos pr on pr.id = x.producto_id
          left join public.lotes lo on lo.id = x.lote_id
          where x.pedido_id = p.id
        ) pi on true
        where (p.estado)::text = 'completado'
          and (
            -- A) suyas hoy (día civil CDMX) o dentro de la ventana del cliente
            (
              p.atendido_por = v_actor
              and (
                (p.created_at >= v_dia_ini and p.created_at < v_dia_fin)
                or (
                  p.created_at >= p_turno_start
                  and p.created_at <= p_turno_end
                )
              )
            )
            -- B) ocurrieron con SU caja (abierta o de hoy), aunque
            --    atendido_por sea otra persona
            or exists (
              select 1
              from public.caja_sesiones s
              where s.empleado_id = v_actor
                and (s.fecha = v_hoy or s.estado = 'abierta')
                and p.created_at >= s.abierta_at
                and p.created_at <= coalesce(s.cerrada_at, now())
            )
          )
      ) q
    ), '[]'::jsonb),
    'ped_mes', coalesce((
      select jsonb_agg(
        jsonb_build_object('id', p.id, 'total', p.total, 'created_at', p.created_at)
        order by p.created_at
      )
      from public.pedidos p
      where (p.estado)::text = 'completado'
        and p.created_at >= p_mes_start
        and (
          p.atendido_por = v_actor
          or exists (
            select 1
            from public.caja_sesiones s
            where s.empleado_id = v_actor
              and s.fecha >= (p_mes_start at time zone 'America/Mexico_City')::date
              and p.created_at >= s.abierta_at
              and p.created_at <= coalesce(s.cerrada_at, now())
          )
        )
    ), '[]'::jsonb),
    'citas_espera', (
      select count(*)::int
      from public.citas c
      where c.fecha = p_fecha_citas
        and (c.estado)::text = 'confirmada'
    )
  );
end;
$$;

grant execute on function public.empleado_midia_snapshot(uuid, bigint, timestamptz, timestamptz, timestamptz, date)
  to anon, authenticated;

commit;

-- ── Verificar qué versión está viva ───────────────────────────
-- select pg_get_functiondef('public.empleado_midia_snapshot(uuid,bigint,timestamptz,timestamptz,timestamptz,date)'::regprocedure);
-- Debe mencionar caja_sesiones y v_dia_ini.
--
-- ── Diagnóstico de la vendedora ───────────────────────────────
-- select p.id, p.total, p.estado,
--        to_char(p.created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora,
--        p.atendido_por, u.nombre, u.rol, u.turno
-- from public.pedidos p
-- left join public.usuarios u on u.id = p.atendido_por
-- where ((p.created_at at time zone 'America/Mexico_City')::date)
--         = (now() at time zone 'America/Mexico_City')::date
--   and (p.estado)::text = 'completado'
-- order by p.created_at;
