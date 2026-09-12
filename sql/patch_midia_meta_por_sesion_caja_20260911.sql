-- FarmaCapital — 11-sep-2026
-- Mi Día en 0% con ventas en Transacciones.
--
-- Causa: el corte de caja cuenta ventas por VENTANA DE SESIÓN
-- (created_at entre abierta_at y cerrada_at). Mi Día solo miraba
-- atendido_por = vendedora. Si cobró un admin/otra persona con su
-- cajón abierto, Transacciones muestra $ y ella ve 0% en la meta.
--
-- Este patch alinea Mi Día con el corte: suma ventas etiquetadas a
-- ella O ocurridas durante su sesión de caja de hoy.
-- Idempotente. Pegar en Supabase SQL Editor.

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
begin
  v_actor := public.fn_require_empleado(p_session_token);
  -- Admin/gerente puede consultar a otra persona; vendedora solo a sí misma.
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
            -- A) etiquetada a ella dentro de la ventana que manda el cliente
            (
              p.atendido_por = v_actor
              and p.created_at >= p_turno_start
              and p.created_at <= p_turno_end
            )
            -- B) ocurrió con SU caja abierta (como el corte) — aunque
            --    atendido_por sea admin u otra persona
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

-- Reetiqueta las ventas de HOY hechas durante la sesión de caja de cada
-- vendedora, si quedaron a nombre de otro (admin). Idempotente.
update public.pedidos p
   set atendido_por = s.empleado_id
  from public.caja_sesiones s
  join public.usuarios u on u.id = s.empleado_id
 where (p.estado)::text = 'completado'
   and s.fecha = (now() at time zone 'America/Mexico_City')::date
   and p.created_at >= s.abierta_at
   and p.created_at <= coalesce(s.cerrada_at, now())
   and p.atendido_por is distinct from s.empleado_id
   and lower(coalesce(u.rol, '')) = 'vendedor';

commit;

-- ── Diagnóstico (solo lectura) ────────────────────────────────
-- select p.id, p.total,
--        to_char(p.created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora,
--        p.atendido_por, u.nombre as vendedor,
--        s.empleado_id as caja_de, uc.nombre as caja_nombre
-- from public.pedidos p
-- left join public.usuarios u on u.id = p.atendido_por
-- left join public.caja_sesiones s
--   on s.fecha = (now() at time zone 'America/Mexico_City')::date
--  and p.created_at >= s.abierta_at
--  and p.created_at <= coalesce(s.cerrada_at, now())
-- left join public.usuarios uc on uc.id = s.empleado_id
-- where ((p.created_at at time zone 'America/Mexico_City')::date)
--         = (now() at time zone 'America/Mexico_City')::date
--   and (p.estado)::text = 'completado'
-- order by p.created_at;
