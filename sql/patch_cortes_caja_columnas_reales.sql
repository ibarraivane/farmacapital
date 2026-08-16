-- Corte de caja: alinear los RPCs con las columnas REALES de cortes_caja.
--
-- La tabla se creó con otros nombres de los que asumían los RPCs de la fase 6b:
--
--   RPC esperaba        tabla real
--   ------------        ----------
--   cajero (text)       empleado_id (bigint)
--   tarjeta             total_tarjeta
--   spei                total_spei
--   mercadopago         total_mercadopago
--   (no lo mandaba)     hora_apertura  <- NOT NULL
--
-- Efectos: guardar corte fallaba con
--   column "cajero" of relation "cortes_caja" does not exist
-- y el Historial mostraba Tarjeta/MP/Cajero vacíos porque el frontend lee
-- c.tarjeta / c.mercadopago / c.cajero.
--
-- Las fechas y horas se calculan en hora local de México: a las 20:00 de
-- México ya son las 02:00 UTC del día siguiente, y el corte debe quedar
-- fechado en el día que lo vivió la farmacia.
--
-- Ejecutar en Supabase SQL Editor.

begin;

-- ============================================================
-- 1) registrar_corte_caja  → escribe en las columnas reales
-- ============================================================
create or replace function public.registrar_corte_caja(
  p_session_token      uuid,
  p_turno              text,
  p_efectivo_declarado numeric,
  p_efectivo_sistema   numeric,
  p_tarjeta            numeric,
  p_mercadopago        numeric,
  p_diferencia         numeric,
  p_total_general      numeric,
  p_spei               numeric default 0,
  p_notas              text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_nombre   text;
  v_corte_id bigint;
  v_ahora    timestamp;
  v_apertura time;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  select nombre into v_nombre from public.usuarios where id = v_actor_id;

  v_ahora    := now() at time zone 'America/Mexico_City';
  v_apertura := case when p_turno = 'matutino' then time '08:00' else time '16:00' end;

  -- diferencia y total_general son columnas GENERATED: las calcula Postgres a
  -- partir de las demás y rechazan cualquier valor explícito. Los parámetros
  -- p_diferencia / p_total_general se conservan en la firma (el módulo los
  -- manda) pero solo se usan para la bitácora.
  insert into public.cortes_caja (
    turno, empleado_id, fecha, hora_apertura, hora_cierre,
    efectivo_declarado, efectivo_sistema,
    total_tarjeta, total_spei, total_mercadopago,
    notas
  ) values (
    p_turno, v_actor_id, v_ahora::date, v_apertura, v_ahora::time,
    coalesce(p_efectivo_declarado, 0), coalesce(p_efectivo_sistema, 0),
    coalesce(p_tarjeta, 0), coalesce(p_spei, 0), coalesce(p_mercadopago, 0),
    p_notas
  ) returning id into v_corte_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id, v_nombre,
      'corte_caja', 'cortes_caja', v_corte_id::text,
      jsonb_build_object('turno', p_turno, 'diferencia', p_diferencia, 'total', p_total_general)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'corte_id', v_corte_id);
end;
$$;

grant execute on function public.registrar_corte_caja(uuid, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text) to anon, authenticated;


-- ============================================================
-- 2) empleado_listar_cortes_caja  → expone los alias que lee el módulo
-- ============================================================
create or replace function public.empleado_listar_cortes_caja(
  p_session_token uuid,
  p_limite int default 40,
  p_fecha_desde date default null,
  p_fecha_hasta date default null,
  p_turno text default null
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
  return coalesce((
    select jsonb_agg(row_js order by ord desc nulls last)
    from (
      select
        jsonb_build_object(
          'id',                 c.id,
          'fecha',             (c.fecha + coalesce(c.hora_cierre, c.hora_apertura)),
          'turno',              c.turno,
          'cajero',             u.nombre,
          'efectivo_declarado', c.efectivo_declarado,
          'efectivo_sistema',   c.efectivo_sistema,
          'diferencia',         c.diferencia,
          'tarjeta',            c.total_tarjeta,
          'spei',               c.total_spei,
          'mercadopago',        c.total_mercadopago,
          'total_general',      c.total_general,
          'notas',              c.notas
        ) as row_js,
        c.created_at as ord
      from public.cortes_caja c
      left join public.usuarios u on u.id = c.empleado_id
      where (p_fecha_desde is null or c.fecha >= p_fecha_desde)
        and (p_fecha_hasta is null or c.fecha <= p_fecha_hasta)
        and (p_turno is null or p_turno = '' or p_turno = 'todos' or c.turno = p_turno)
      order by c.created_at desc nulls last
      limit greatest(1, least(coalesce(p_limite, 40), 120))
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_cortes_caja(uuid, int, date, date, text) to anon, authenticated;

commit;
