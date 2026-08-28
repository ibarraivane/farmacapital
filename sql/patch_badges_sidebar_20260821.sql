-- FarmaCapital — Badges del sidebar: pago MP confirmado, bajo stock alineado, cortes enterados
-- Ejecutar en Supabase SQL Editor (idempotente).

begin;

-- ── 1) Pedidos online: solo contar/listar con pago confirmado ───────────────
create or replace function public.fn_pedido_online_pago_confirmado(
  p_metodo_pago text,
  p_payment_status text,
  p_tipo text default null
)
returns boolean
language plpgsql
immutable
as $$
declare
  v_metodo text := lower(trim(coalesce(p_metodo_pago, '')));
  v_status text := lower(trim(coalesce(p_payment_status, '')));
  v_tipo   text := lower(trim(coalesce(p_tipo, '')));
begin
  if v_tipo is not null and v_tipo <> '' and v_tipo <> 'online' then
    return true;
  end if;
  if v_metodo in ('mercadopago', 'tarjeta') then
    return v_status = 'approved';
  end if;
  if v_metodo = 'efectivo' then
    return true;
  end if;
  if v_status <> '' then
    return v_status = 'approved';
  end if;
  return false;
end;
$$;

create or replace function public.empleado_contar_pedidos_tienda_web_pendientes(p_session_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_cnt bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::bigint into v_cnt
  from public.pedidos p
  where p.estado = 'pendiente'
    and (
      p.tipo = 'online'
      or (
        p.tipo is null
        and lower(trim(coalesce(p.metodo_pago, ''))) = any (array['tarjeta','mercadopago'])
      )
    )
    and public.fn_pedido_online_pago_confirmado(p.metodo_pago, p.payment_status, p.tipo);
  return coalesce(v_cnt, 0);
end;
$$;

-- ── 2) Inventario: mismo criterio que Inventario → filtro "bajo stock" ─────
create or replace function public.empleado_contar_productos_bajo_stock(p_session_token uuid)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_n int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::int into v_n
  from public.productos p
  where coalesce(p.activo, false)
    and coalesce(p.stock, 0) <= coalesce(p.stock_minimo, 0);
  return coalesce(v_n, 0);
end;
$$;

-- ── 3) Corte de caja: marcar diferencias como revisadas ("enterado") ────────
alter table public.cortes_caja
  add column if not exists diferencia_revisada boolean not null default false;

comment on column public.cortes_caja.diferencia_revisada is
  'true = admin revisó la diferencia de efectivo; deja de contar en el badge del sidebar.';

create or replace function public.empleado_contar_cortes_con_diferencia(
  p_session_token uuid
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_n int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::int into v_n
  from public.cortes_caja cc
  where cc.diferencia is not null
    and cc.diferencia <> 0
    and coalesce(cc.diferencia_revisada, false) = false;
  return coalesce(v_n, 0);
end;
$$;

create or replace function public.empleado_marcar_corte_diferencia_revisada(
  p_session_token uuid,
  p_corte_id      bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
begin
  v_actor := public.fn_require_empleado(p_session_token);
  update public.cortes_caja
     set diferencia_revisada = true
   where id = p_corte_id
     and diferencia is not null
     and diferencia <> 0;
  if not found then
    raise exception 'Corte no encontrado o sin diferencia';
  end if;
  return jsonb_build_object('success', true, 'id', p_corte_id);
end;
$$;

grant execute on function public.fn_pedido_online_pago_confirmado(text, text, text) to anon, authenticated;
grant execute on function public.empleado_contar_pedidos_tienda_web_pendientes(uuid) to anon, authenticated;
grant execute on function public.empleado_contar_productos_bajo_stock(uuid) to anon, authenticated;
grant execute on function public.empleado_contar_cortes_con_diferencia(uuid) to anon, authenticated;
grant execute on function public.empleado_marcar_corte_diferencia_revisada(uuid, bigint) to anon, authenticated;

-- Incluir flag en historial de cortes (para UI "Enterado")
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
          'notas',              c.notas
        ) as row_js,
        c.created_at as ord
      from public.cortes_caja c
      left join public.usuarios u on u.id = c.empleado_id
      where (p_fecha_desde is null or c.fecha >= p_fecha_desde)
        and (p_fecha_hasta is null or c.fecha <= p_fecha_hasta)
        and (
          coalesce(v_rol, '') = 'vendedor'
          or p_turno is null or p_turno = '' or p_turno = 'todos' or c.turno = p_turno
        )
        and (
          coalesce(v_rol, '') <> 'vendedor'
          or (
            c.empleado_id = v_user_id
            and (v_asignado is null or c.turno = v_asignado)
          )
        )
      order by c.created_at desc nulls last
      limit greatest(1, least(coalesce(p_limite, 40), 120))
    ) s
  ), '[]'::jsonb);
end;
$$;

commit;

-- Opcional: ver pedidos fantasma (creados sin pago MP aprobado)
-- select id, total, metodo_pago, payment_status, created_at
-- from public.pedidos
-- where estado = 'pendiente' and tipo = 'online'
--   and lower(trim(coalesce(metodo_pago,''))) in ('mercadopago','tarjeta')
--   and coalesce(lower(trim(payment_status)), '') <> 'approved'
-- order by created_at desc;

