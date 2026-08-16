-- Corte de caja: fondo inicial, desglose por denominación y testigo del conteo.
--
-- Cambia el modelo del arqueo. Antes el cajero apartaba el fondo y declaraba
-- sólo el sobrante, lo que lo obligaba a restar de cabeza y dejaba el fondo sin
-- registrar en ningún lado. Ahora declara TODO lo que hay en el cajón y el
-- sistema calcula lo que debería haber:
--
--     esperado   = fondo_inicial + ventas en efectivo
--     diferencia = declarado - esperado
--
-- Por eso hay que rehacer las dos columnas GENERATED: sus fórmulas ignoraban
-- el fondo, y con el nuevo modelo marcarían un sobrante del tamaño del fondo
-- todos los días. Son columnas derivadas, así que borrarlas no pierde datos.
--
-- Ejecutar en Supabase SQL Editor.

begin;

alter table public.cortes_caja
  add column if not exists fondo_inicial  numeric not null default 0,
  add column if not exists contado_por    text,
  add column if not exists denominaciones jsonb;

comment on column public.cortes_caja.fondo_inicial is
  'Efectivo con el que abrió el turno. Se cuenta dentro de efectivo_declarado.';
comment on column public.cortes_caja.contado_por is
  'Quién contó físicamente el dinero, si fue alguien distinto de quien capturó.';
comment on column public.cortes_caja.denominaciones is
  'Conteo por denominación: {"500": 3, "200": 10, ...}. Informativo.';

-- Postgres no deja cambiar la expresión de una columna generada; hay que
-- borrarla y volverla a crear.
alter table public.cortes_caja drop column if exists diferencia;
alter table public.cortes_caja drop column if exists total_general;

alter table public.cortes_caja
  add column diferencia numeric
    generated always as
      (efectivo_declarado - (fondo_inicial + efectivo_sistema)) stored;

-- El fondo no es venta: se descuenta para que el total del turno sea lo que
-- realmente entró.
alter table public.cortes_caja
  add column total_general numeric
    generated always as
      ((efectivo_declarado - fondo_inicial)
        + total_tarjeta + total_spei + total_mercadopago) stored;

commit;


-- ============================================================
-- registrar_corte_caja: recibe fondo, testigo y denominaciones
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
  p_notas              text default null,
  p_fondo_inicial      numeric default 0,
  p_contado_por        text default null,
  p_denominaciones     jsonb default null
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
  v_sistema  numeric;
  v_fila     public.cortes_caja%rowtype;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  select nombre into v_nombre from public.usuarios where id = v_actor_id;

  v_ahora    := now() at time zone 'America/Mexico_City';
  v_apertura := case when p_turno = 'matutino' then time '08:00' else time '15:00' end;

  -- El efectivo esperado lo calcula la base, NO el cliente. Si viajara al
  -- navegador para que lo reenviara, el cajero podría verlo antes de declarar
  -- (mirando la red) o alterarlo para que su conteo cuadrara. p_efectivo_sistema
  -- se ignora a propósito; se conserva en la firma por compatibilidad.
  v_sistema := coalesce(
    (public.reconcile_shift_cash(p_turno, v_ahora::date)->>'efectivo_sistema')::numeric, 0);

  -- diferencia y total_general son GENERATED: las calcula Postgres.
  insert into public.cortes_caja (
    turno, empleado_id, fecha, hora_apertura, hora_cierre,
    efectivo_declarado, efectivo_sistema, fondo_inicial,
    total_tarjeta, total_spei, total_mercadopago,
    contado_por, denominaciones, notas
  ) values (
    p_turno, v_actor_id, v_ahora::date, v_apertura, v_ahora::time,
    coalesce(p_efectivo_declarado, 0), v_sistema,
    coalesce(p_fondo_inicial, 0),
    coalesce(p_tarjeta, 0), coalesce(p_spei, 0), coalesce(p_mercadopago, 0),
    nullif(btrim(coalesce(p_contado_por, '')), ''), p_denominaciones, p_notas
  ) returning * into v_fila;

  v_corte_id := v_fila.id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id, v_nombre,
      'corte_caja', 'cortes_caja', v_corte_id::text,
      jsonb_build_object('turno', p_turno, 'diferencia', v_fila.diferencia,
                         'total', v_fila.total_general, 'fondo', v_fila.fondo_inicial)
    );
  exception when others then null;
  end;

  -- Se devuelven los valores calculados por la base: es hasta aquí que el
  -- cajero puede ver la diferencia, nunca antes de declarar.
  return jsonb_build_object(
    'success',          true,
    'corte_id',         v_corte_id,
    'efectivo_sistema', v_fila.efectivo_sistema,
    'fondo_inicial',    v_fila.fondo_inicial,
    'esperado',         v_fila.fondo_inicial + v_fila.efectivo_sistema,
    'diferencia',       v_fila.diferencia,
    'total_general',    v_fila.total_general
  );
end;
$$;

grant execute on function public.registrar_corte_caja(uuid, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text, numeric, text, jsonb) to anon, authenticated;


-- ============================================================
-- Historial: exponer los campos nuevos
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
          'contado_por',        c.contado_por,
          'fondo_inicial',      c.fondo_inicial,
          'efectivo_declarado', c.efectivo_declarado,
          'efectivo_sistema',   c.efectivo_sistema,
          'esperado',           c.fondo_inicial + c.efectivo_sistema,
          'diferencia',         c.diferencia,
          'tarjeta',            c.total_tarjeta,
          'spei',               c.total_spei,
          'mercadopago',        c.total_mercadopago,
          'total_general',      c.total_general,
          'denominaciones',     c.denominaciones,
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


-- ============================================================
-- Totales electrónicos del turno (sin efectivo)
--
-- El formulario necesita precargar tarjeta y MercadoPago, que no se cuentan a
-- mano y por tanto no hay razón para ocultarlos. Pero no puede usar
-- reconcile_shift_cash para eso, porque esa función devuelve también el
-- efectivo esperado — justo el número que el arqueo ciego debe esconder.
-- ============================================================
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
  v_dummy bigint;
  v_r jsonb;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_r := public.reconcile_shift_cash(p_turno, p_fecha);
  return jsonb_build_object(
    'tarjeta',     v_r->'tarjeta',
    'mercadopago', v_r->'mercadopago'
  );
end;
$$;

grant execute on function public.empleado_totales_electronicos_turno(uuid, text, date) to anon, authenticated;


-- ============================================================
-- Último fondo usado, para precargarlo en el formulario
-- ============================================================
create or replace function public.empleado_ultimo_fondo_caja(
  p_session_token uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_fondo numeric;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select fondo_inicial into v_fondo
  from public.cortes_caja
  where fondo_inicial > 0
  order by created_at desc
  limit 1;
  return jsonb_build_object('fondo', coalesce(v_fondo, 0));
end;
$$;

grant execute on function public.empleado_ultimo_fondo_caja(uuid) to anon, authenticated;
