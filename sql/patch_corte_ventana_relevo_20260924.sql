-- 24-sep-2026. Raquel ya cerró; Cinthia entró y vendió.
-- El ticket del corte cerrado pedía TODO el matutino hasta las 15:30,
-- así que las ventas de Cinthia salían dentro del corte de Raquel.
-- La tarjeta del formulario, si ya había un corte de ese nombre,
-- enseñaba la ventana cerrada y no la caja que está abierta.
--
-- Pegar TODO en Supabase → SQL Editor → Run.

begin;

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
  v_user_id bigint;
  v_rol text;
  v_asignado text;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;
  v_asignado := public.fn_turno_caja_de(v_user_id);
  return coalesce((
    select jsonb_agg(row_js order by ord desc nulls last)
    from (
      select
        jsonb_build_object(
          'id',                 c.id,
          'fecha',             (c.fecha + coalesce(c.hora_cierre, c.hora_apertura)),
          'turno',              c.turno,
          'cajero',             u.nombre,
          'contado_por',        c.contado_por,
          'fondo_inicial',      c.fondo_inicial,
          'efectivo_declarado', c.efectivo_declarado,
          'efectivo_sistema',   case when coalesce(v_rol,'') = 'vendedor' then null else c.efectivo_sistema end,
          'esperado',           case when coalesce(v_rol,'') = 'vendedor' then null else (c.fondo_inicial + c.efectivo_sistema) end,
          'diferencia',         c.diferencia,
          'diferencia_revisada', coalesce(c.diferencia_revisada, false),
          'tarjeta',            c.total_tarjeta,
          'spei',               c.total_spei,
          'mercadopago',        c.total_mercadopago,
          'total_general',      case when coalesce(v_rol,'') = 'vendedor' then null else c.total_general end,
          'denominaciones',     c.denominaciones,
          'notas',              c.notas,
          'ventana_inicio',     ses.abierta_at,
          'ventana_fin',        coalesce(ses.cerrada_at, c.created_at)
        ) as row_js,
        c.created_at as ord
      from public.cortes_caja c
      left join public.usuarios u on u.id = c.empleado_id
      left join lateral (
        select s.abierta_at, s.cerrada_at
        from public.caja_sesiones s
        where s.corte_id = c.id
           or (
             s.empleado_id = c.empleado_id
             and s.turno = c.turno
             and s.fecha = c.fecha
             and s.estado = 'cerrada'
             and s.cerrada_at is not null
             and abs(extract(epoch from (s.cerrada_at - c.created_at))) < 180
           )
        order by case when s.corte_id = c.id then 0 else 1 end, s.cerrada_at desc nulls last
        limit 1
      ) ses on true
      where c.anulado_at is null
        and (p_fecha_desde is null or c.fecha >= p_fecha_desde)
        and (p_fecha_hasta is null or c.fecha <= p_fecha_hasta)
        and (
          coalesce(v_rol, '') = 'vendedor'
          or p_turno is null or p_turno = '' or p_turno = 'todos' or c.turno = p_turno
        )
        and (
          coalesce(v_rol, '') <> 'vendedor'
          or (
            c.empleado_id = v_user_id
            and (v_asignado is null or c.turno = v_asignado or c.turno = p_turno)
          )
        )
      order by c.created_at desc nulls last
      limit greatest(1, least(coalesce(p_limite, 40), 120))
    ) s
  ), '[]'::jsonb);
end;
$$;

-- Quien tiene la caja abierta ve SUS cobros con tarjeta, no el corte ya cerrado.
create or replace function public.empleado_totales_electronicos_turno(
  p_session_token uuid,
  p_turno text,
  p_fecha date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol     text;
  v_turno   text;
  v_sesion  public.caja_sesiones%rowtype;
  v_r       jsonb;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;

  select * into v_sesion
  from public.caja_sesiones
  where empleado_id = v_user_id and estado = 'abierta'
  limit 1;

  if v_sesion.id is not null then
    v_r := public.reconcile_cash_rango(v_sesion.abierta_at, now());
  else
    v_turno := p_turno;
    if coalesce(v_rol, '') = 'vendedor' then
      v_turno := coalesce(public.fn_turno_caja_de(v_user_id), p_turno);
    end if;
    v_r := public.reconcile_shift_cash(v_turno, p_fecha);
  end if;

  return jsonb_build_object(
    'tarjeta',           v_r->'tarjeta',
    'mercadopago',       v_r->'mercadopago',
    'spei',              v_r->'spei',
    'tarjeta_pedidos',   v_r->'tarjeta_pedidos',
    'tarjeta_servicios', v_r->'tarjeta_servicios'
  );
end;
$$;

-- El corte de Raquel no le cierra el turno a Cinthia.
create or replace function public.empleado_corte_turno_en_fecha(
  p_session_token uuid,
  p_fecha date,
  p_turno text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
  v_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;

  select cc.id into v_id
  from public.cortes_caja cc
  where cc.turno = p_turno
    and cc.anulado_at is null
    and cc.created_at >= (p_fecha::timestamp) at time zone 'America/Mexico_City'
    and cc.created_at <  ((p_fecha + 1)::timestamp) at time zone 'America/Mexico_City'
    and (
      coalesce(v_rol, '') <> 'vendedor'
      or cc.empleado_id = v_user_id
    )
  limit 1;

  return jsonb_build_object('existe', v_id is not null, 'id', v_id);
end;
$$;

grant execute on function public.empleado_listar_cortes_caja(uuid, int, date, date, text) to anon, authenticated;
grant execute on function public.empleado_totales_electronicos_turno(uuid, text, date) to anon, authenticated;
grant execute on function public.empleado_corte_turno_en_fecha(uuid, date, text) to anon, authenticated;

commit;
