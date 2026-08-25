-- ============================================================================
-- FarmaCapital — La caja deja de partirse por reloj y se parte por sesión.
-- 24 ago 2026. Idempotente. Pegar TODO en Supabase → SQL Editor → Run.
--
-- POR QUÉ
-- -------
-- Mary sale 15:30 y Erika entra 15:00: se traslapan media hora. Como la
-- conciliación cortaba el día con una línea dura a las 15:30, cuando Mary
-- contaba a las 14:58 todo lo vendido entre 14:58 y 15:30 quedaba en la
-- ventana del matutino (ya cortado) y el vespertino no lo recogía: dinero
-- que no conciliaba nadie.
--
-- Además, un corte quemaba el turno para TODA la farmacia. El 24-ago se
-- guardó un corte vespertino a las 15:19 y Erika quedó fuera de la caja
-- siete horas.
--
-- QUÉ CAMBIA
-- ----------
-- 1. La ventana de un corte va del corte anterior hasta ahora. Cadena
--    continua: nada se pierde, nada se cuenta dos veces, y da igual a qué
--    hora corte cada quien.
-- 2. Sin sesión abierta no hay corte (así nació el corte fantasma).
-- 3. El bloqueo es por persona, no por turno global: que Mary corte ya no
--    deja a Erika afuera.
-- 4. Un corte se puede anular el mismo día. Un mal clic cuesta un minuto.
-- 5. Cortar con la caja recién abierta o sin movimientos pide confirmación.
-- ============================================================================

begin;

-- ── 1. Un corte se puede anular ─────────────────────────────────────────────

alter table public.cortes_caja
  add column if not exists anulado_at     timestamptz,
  add column if not exists anulado_por    bigint,
  add column if not exists anulado_motivo text;

comment on column public.cortes_caja.anulado_at is
  'Corte cancelado por gerencia el mismo día. No cuenta para la cadena ni bloquea la caja.';

create index if not exists cortes_caja_vigentes_idx
  on public.cortes_caja (created_at desc)
  where anulado_at is null;


-- ── 2. La cadena: ¿dónde terminó el corte anterior? ─────────────────────────

-- El eslabón previo. Sin él, el primer corte de la vida arranca en su sesión.
create or replace function public.fn_corte_previo_at(p_antes timestamptz default now())
returns timestamptz
language sql
stable
set search_path = public, pg_temp
as $$
  select max(cc.created_at)
  from public.cortes_caja cc
  where cc.created_at < p_antes
    and cc.anulado_at is null;
$$;

comment on function public.fn_corte_previo_at(timestamptz) is
  'Momento del último corte vigente. Inicio de la ventana del corte que sigue.';


-- Conciliación por rango explícito. Mismo cálculo de siempre; lo único que
-- cambia es que ya no inventa las horas: se las dan.
create or replace function public.reconcile_cash_rango(
  p_inicio timestamptz,
  p_fin    timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_ef_pedidos   numeric := 0;
  v_tar_pedidos  numeric := 0;
  v_mp_pedidos   numeric := 0;
  v_spei_pedidos numeric := 0;
  v_ef_serv   numeric := 0;
  v_tar_serv  numeric := 0;
  v_dev_ef numeric := 0;
  v_dev_in numeric := 0;
  v_dev_tar numeric := 0;
  v_dev_cred numeric := 0;
begin
  if p_inicio is null or p_fin is null or p_fin <= p_inicio then
    return jsonb_build_object(
      'efectivo_sistema', 0, 'tarjeta', 0, 'mercadopago', 0, 'spei', 0,
      'efectivo_pedidos', 0, 'efectivo_servicios', 0,
      'efectivo_devoluciones', 0, 'efectivo_cambios_ingreso', 0,
      'credito_otorgado', 0, 'tarjeta_pedidos', 0, 'tarjeta_servicios', 0,
      'tarjeta_cambios', 0, 'rango_inicio', p_inicio, 'rango_fin', p_fin,
      'vacio', true
    );
  end if;

  select
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'tarjeta'),  0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago in ('mercadopago','mercadopago_point')), 0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'spei'),     0)
  into v_ef_pedidos, v_tar_pedidos, v_mp_pedidos, v_spei_pedidos
  from public.pedidos
  where estado = 'completado'
    and created_at > p_inicio
    and created_at <= p_fin;

  select
    coalesce(sum(total_cobrado) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total_cobrado) filter (where metodo_pago = 'tarjeta'),  0)
  into v_ef_serv, v_tar_serv
  from public.pagos_servicio
  where created_at > p_inicio
    and created_at <= p_fin;

  select
    coalesce(sum(monto_efectivo), 0),
    coalesce(sum(monto_efectivo_ingreso), 0),
    coalesce(sum(monto_tarjeta_ingreso), 0),
    coalesce(sum(monto_credito), 0)
  into v_dev_ef, v_dev_in, v_dev_tar, v_dev_cred
  from public.devoluciones
  where estado = 'aprobada'
    and created_at > p_inicio
    and created_at <= p_fin;

  return jsonb_build_object(
    'efectivo_sistema',   v_ef_pedidos + v_ef_serv - v_dev_ef + v_dev_in,
    'tarjeta',            v_tar_pedidos + v_tar_serv + v_dev_tar,
    'mercadopago',        v_mp_pedidos,
    'spei',               v_spei_pedidos,
    'efectivo_pedidos',   v_ef_pedidos,
    'efectivo_servicios', v_ef_serv,
    'efectivo_devoluciones', v_dev_ef,
    'efectivo_cambios_ingreso', v_dev_in,
    'credito_otorgado',   v_dev_cred,
    'tarjeta_pedidos',    v_tar_pedidos,
    'tarjeta_servicios',  v_tar_serv,
    'tarjeta_cambios',    v_dev_tar,
    'rango_inicio',       p_inicio,
    'rango_fin',          p_fin,
    'vacio',              false
  );
end;
$$;

grant execute on function public.reconcile_cash_rango(timestamptz, timestamptz) to anon, authenticated;


-- La ventana que le toca al corte que se está por guardar.
create or replace function public.fn_ventana_corte(
  p_sesion_id bigint default null,
  p_fin       timestamptz default now()
)
returns jsonb
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_prev   timestamptz;
  v_abrio  timestamptz;
  v_inicio timestamptz;
begin
  v_prev := public.fn_corte_previo_at(p_fin);

  if p_sesion_id is not null then
    select abierta_at into v_abrio from public.caja_sesiones where id = p_sesion_id;
  end if;

  -- El corte anterior manda: ahí quedó cortada la cinta. Si nunca hubo corte,
  -- arranca cuando se abrió la caja; y si tampoco hay sesión, al inicio del día.
  v_inicio := coalesce(
    v_prev,
    v_abrio,
    (((p_fin at time zone 'America/Mexico_City')::date)::timestamp) at time zone 'America/Mexico_City'
  );

  return jsonb_build_object('inicio', v_inicio, 'fin', p_fin);
end;
$$;

grant execute on function public.fn_ventana_corte(bigint, timestamptz) to anon, authenticated;


-- Compatibilidad: quien todavía pida (turno, fecha) recibe la cadena del día.
create or replace function public.reconcile_shift_cash(
  p_turno text,
  p_fecha date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dia_ini timestamptz;
  v_dia_fin timestamptz;
  v_corte   record;
  v_inicio  timestamptz;
  v_fin     timestamptz;
begin
  v_dia_ini := (p_fecha::timestamp) at time zone 'America/Mexico_City';
  v_dia_fin := ((p_fecha + 1)::timestamp) at time zone 'America/Mexico_City';

  -- ¿Ya hay un corte de ese turno ese día? Entonces su ventana es la que quedó.
  select cc.id, cc.created_at into v_corte
  from public.cortes_caja cc
  where cc.turno = p_turno
    and cc.anulado_at is null
    and cc.created_at >= v_dia_ini
    and cc.created_at <  v_dia_fin
  order by cc.created_at
  limit 1;

  if v_corte.id is not null then
    v_fin    := v_corte.created_at;
    v_inicio := coalesce(public.fn_corte_previo_at(v_corte.created_at), v_dia_ini);
  else
    -- Turno en curso: desde el último corte hasta ahora.
    v_inicio := coalesce(public.fn_corte_previo_at(now()), v_dia_ini);
    v_fin    := least(now(), v_dia_fin);
  end if;

  return public.reconcile_cash_rango(v_inicio, v_fin);
end;
$$;

grant execute on function public.reconcile_shift_cash(text, date) to anon, authenticated;


-- ── 3. El bloqueo es por persona, no por turno de la farmacia ───────────────

-- Ya no cuenta un corte anulado.
create or replace function public.fn_empleado_ya_tuvo_turno_hoy(
  p_user_id bigint,
  p_turno   text,
  p_fecha   date default ((now() at time zone 'America/Mexico_City')::date)
)
returns boolean
language sql
stable
set search_path = public, pg_temp
as $$
  select
    p_user_id is not null
    and p_turno in ('matutino', 'vespertino')
    and (
      exists (
        select 1
        from public.caja_sesiones s
        where s.empleado_id = p_user_id
          and s.fecha = p_fecha
          and s.turno = p_turno
          and s.estado = 'cerrada'
      )
      or exists (
        select 1
        from public.cortes_caja cc
        where cc.empleado_id = p_user_id
          and cc.turno = p_turno
          and cc.anulado_at is null
          and ((cc.created_at at time zone 'America/Mexico_City')::date) = p_fecha
      )
    );
$$;


create or replace function public.fn_farmacia_ya_corte_turno_hoy(
  p_turno text,
  p_fecha date default ((now() at time zone 'America/Mexico_City')::date)
)
returns boolean
language sql
stable
set search_path = public, pg_temp
as $$
  select
    p_turno in ('matutino', 'vespertino')
    and exists (
      select 1
      from public.cortes_caja cc
      where cc.turno = p_turno
        and cc.anulado_at is null
        and ((cc.created_at at time zone 'America/Mexico_City')::date) = p_fecha
    );
$$;


-- Turno que puede abrir AHORA.
-- Sin candados de reloj: se abre cuando el cajón está libre, no cuando el
-- reloj lo permite. Lo único que impide reabrir es haber cerrado ya ese turno.
create or replace function public.fn_turno_abrir_hoy(p_user_id bigint)
returns text
language plpgsql
volatile
set search_path = public, pg_temp
as $$
declare
  v_asignado text;
  v_ahora    timestamp;
  v_minutos  int;
  v_fecha    date;
  v_ya_mat   boolean;
  v_ya_vesp  boolean;
begin
  if public.fn_es_descanso_hoy(p_user_id) then
    return null;
  end if;

  v_asignado := public.fn_turno_caja_de(p_user_id);
  if v_asignado is null then
    return null;
  end if;

  v_ahora   := now() at time zone 'America/Mexico_City';
  v_fecha   := v_ahora::date;
  v_minutos := (extract(hour from v_ahora)::int * 60) + extract(minute from v_ahora)::int;

  v_ya_mat  := public.fn_empleado_ya_tuvo_turno_hoy(p_user_id, 'matutino',   v_fecha);
  v_ya_vesp := public.fn_empleado_ya_tuvo_turno_hoy(p_user_id, 'vespertino', v_fecha);

  -- Cubre ambos: abre, corta y vuelve a abrir el mismo día.
  if public.fn_cubre_ambos_hoy(p_user_id) then
    if v_ya_mat and v_ya_vesp then
      return null;
    end if;
    if v_ya_mat then
      return 'vespertino';
    end if;
    if v_ya_vesp then
      return 'matutino';
    end if;
    return case when v_minutos < (15 * 60 + 30) then 'matutino' else 'vespertino' end;
  end if;

  -- Día normal: su turno, una sola vez. Que la compañera haya cortado el
  -- suyo no le quita el derecho a abrir el propio.
  if public.fn_empleado_ya_tuvo_turno_hoy(p_user_id, v_asignado, v_fecha) then
    return null;
  end if;

  return v_asignado;
end;
$$;

grant execute on function public.fn_turno_abrir_hoy(bigint) to anon, authenticated;


-- ── 4. Jornada: decir la verdad, no un mensaje para tres casos ──────────────

create or replace function public.empleado_jornada_hoy(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id  bigint;
  v_descanso boolean;
  v_ambos    boolean;
  v_abrir    text;
  v_habitual text;
  v_fecha    date;
  v_corte    record;
  v_ocupada  text;
begin
  v_user_id  := public.fn_require_empleado(p_session_token);
  v_descanso := coalesce(public.fn_es_descanso_hoy(v_user_id), false);
  v_ambos    := coalesce(public.fn_cubre_ambos_hoy(v_user_id), false);
  v_abrir    := public.fn_turno_abrir_hoy(v_user_id);
  v_habitual := public.fn_turno_caja_de(v_user_id);
  v_fecha    := (now() at time zone 'America/Mexico_City')::date;

  -- ¿Su propio corte de hoy? Para poder decir a qué hora fue.
  select cc.id, cc.turno,
         to_char(cc.created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora
    into v_corte
  from public.cortes_caja cc
  where cc.empleado_id = v_user_id
    and cc.anulado_at is null
    and ((cc.created_at at time zone 'America/Mexico_City')::date) = v_fecha
  order by cc.created_at desc
  limit 1;

  -- ¿El cajón lo tiene alguien más ahora mismo?
  select u.nombre into v_ocupada
  from public.caja_sesiones s
  join public.usuarios u on u.id = s.empleado_id
  where s.estado = 'abierta'
    and s.empleado_id <> v_user_id
  limit 1;

  return jsonb_build_object(
    'dia_idx_hoy',    public.fn_dia_idx_cdmx(),
    'dia_descanso',   (select dia_descanso from public.usuarios where id = v_user_id),
    'es_descanso',    v_descanso,
    'cubre_ambos',    v_ambos,
    'turno_habitual', v_habitual,
    'turno_abrir',    v_abrir,
    'caja_ocupada_por', v_ocupada,
    'mi_corte_id',    v_corte.id,
    'mi_corte_turno', v_corte.turno,
    'mi_corte_hora',  v_corte.hora,
    'ya_cerro_turno', (
      v_abrir is null
      and not v_descanso
      and v_habitual is not null
      and public.fn_empleado_ya_tuvo_turno_hoy(v_user_id, v_habitual, v_fecha)
    )
  );
end;
$$;

grant execute on function public.empleado_jornada_hoy(uuid) to anon, authenticated;


-- ── 5. Abrir caja: mensajes que dicen qué pasó ──────────────────────────────

create or replace function public.abrir_sesion_caja(
  p_session_token uuid,
  p_denominaciones jsonb,
  p_nota text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
  v_nombre text;
  v_ahora timestamp;
  v_minutos int;
  v_turno text;
  v_asignado text;
  v_fondo numeric;
  v_id bigint;
  v_ocupada text;
  v_hora text;
  v_sesion public.caja_sesiones%rowtype;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol, nombre into v_rol, v_nombre from public.usuarios where id = v_user_id;

  -- Ya la tiene abierta: reanudar, no volver a contar el fondo.
  select * into v_sesion
  from public.caja_sesiones
  where empleado_id = v_user_id and estado = 'abierta'
  limit 1;
  if v_sesion.id is not null then
    return jsonb_build_object(
      'success', true, 'abierta', true, 'reanudada', true,
      'id', v_sesion.id, 'turno', v_sesion.turno,
      'fondo_contado', v_sesion.fondo_contado,
      'abierta_at', v_sesion.abierta_at,
      'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id)
    );
  end if;

  -- El cajón es uno solo.
  select u.nombre into v_ocupada
  from public.caja_sesiones s
  join public.usuarios u on u.id = s.empleado_id
  where s.estado = 'abierta'
  limit 1;
  if v_ocupada is not null then
    return jsonb_build_object(
      'success', false,
      'motivo', 'caja_ocupada',
      'error', format('%s todavía tiene la caja abierta. En cuanto haga su corte, abres la tuya.', v_ocupada)
    );
  end if;

  v_ahora   := now() at time zone 'America/Mexico_City';
  v_minutos := (extract(hour from v_ahora)::int * 60) + extract(minute from v_ahora)::int;
  v_asignado := public.fn_turno_caja_de(v_user_id);

  if coalesce(v_rol, '') = 'vendedor' then
    if coalesce(public.fn_es_descanso_hoy(v_user_id), false) then
      return jsonb_build_object(
        'success', false, 'motivo', 'descanso',
        'error', 'Hoy es tu día de descanso. La caja la abre quien cubre ambos turnos.'
      );
    end if;

    if v_asignado is null then
      return jsonb_build_object(
        'success', false, 'motivo', 'sin_turno',
        'error', 'RH debe asignarte un turno (matutino o vespertino) antes de abrir caja.'
      );
    end if;

    v_turno := public.fn_turno_abrir_hoy(v_user_id);

    if v_turno is null then
      select to_char(cc.created_at at time zone 'America/Mexico_City', 'HH24:MI')
        into v_hora
      from public.cortes_caja cc
      where cc.empleado_id = v_user_id
        and cc.anulado_at is null
        and ((cc.created_at at time zone 'America/Mexico_City')::date) = v_ahora::date
      order by cc.created_at desc
      limit 1;

      return jsonb_build_object(
        'success', false,
        'motivo', 'ya_cerro',
        'error', case
          when v_hora is not null then
            format('Ya cerraste tu turno de hoy: hiciste el corte a las %s. Si fue por error, pide a gerencia que lo anule.', v_hora)
          else
            'Ya cerraste tu turno de hoy. Si fue por error, pide a gerencia que anule el corte.'
        end
      );
    end if;
  else
    v_turno := coalesce(
      public.fn_turno_abrir_hoy(v_user_id),
      v_asignado,
      case when v_minutos < (15 * 60 + 30) then 'matutino' else 'vespertino' end
    );
  end if;

  v_fondo := public.fn_sumar_denominaciones(p_denominaciones);

  insert into public.caja_sesiones (
    empleado_id, turno, fecha, fondo_contado, denominaciones, nota_apertura, abierta_at, estado
  ) values (
    v_user_id, v_turno, v_ahora::date, v_fondo,
    coalesce(p_denominaciones, '{}'::jsonb),
    nullif(btrim(coalesce(p_nota, '')), ''),
    now(), 'abierta'
  ) returning id into v_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_user_id, v_nombre, 'abrir_caja', 'caja_sesiones', v_id::text,
      jsonb_build_object('turno', v_turno, 'fondo', v_fondo,
                         'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id)));
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true, 'abierta', true, 'reanudada', false,
    'id', v_id, 'turno', v_turno, 'fondo_contado', v_fondo,
    'abierta_at', now(),
    'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id)
  );
end;
$$;

grant execute on function public.abrir_sesion_caja(uuid, jsonb, text) to anon, authenticated;

commit;


-- ============================================================================
-- Parte 2 — El corte cierra una sesión real, y se puede deshacer.
-- ============================================================================

begin;

-- ── 6. Registrar corte: sin sesión abierta no hay corte ─────────────────────
--
-- Antes, si no había sesión, la función inventaba el turno con
-- coalesce(p_turno, 'matutino'). Así nació el corte fantasma de las 15:19
-- que dejó a Erika fuera de la caja. Ahora el corte es la clausura de algo
-- que estaba abierto: si no hay nada abierto, no hay nada que cerrar.

-- La firma gana un argumento (p_confirmar), así que `create or replace` NO
-- reemplaza: crearía una segunda función y las llamadas quedarían ambiguas.
-- Hay que tirar la de 13 argumentos explícitamente.
drop function if exists public.registrar_corte_caja(
  uuid, text, numeric, numeric, numeric, numeric, numeric, numeric,
  numeric, text, numeric, text, jsonb
);

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
  p_denominaciones     jsonb default null,
  p_confirmar          boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_nombre   text;
  v_rol      text;
  v_corte_id bigint;
  v_ahora    timestamp;
  v_fecha    date;
  v_vent     jsonb;
  v_inicio   timestamptz;
  v_fin      timestamptz;
  v_apertura time;
  v_r        jsonb;
  v_sistema  numeric;
  v_tarjeta  numeric;
  v_mp       numeric;
  v_spei     numeric;
  v_fila     public.cortes_caja%rowtype;
  v_sesion   public.caja_sesiones%rowtype;
  v_fondo    numeric;
  v_turno    text;
  v_decl     numeric;
  v_mins     int;
  v_movs     int;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  select nombre, rol into v_nombre, v_rol from public.usuarios where id = v_actor_id;

  v_ahora := now() at time zone 'America/Mexico_City';
  v_fecha := v_ahora::date;

  select * into v_sesion
  from public.caja_sesiones
  where empleado_id = v_actor_id and estado = 'abierta'
  limit 1;

  -- El vendedor corta lo suyo. Sin caja abierta no hay corte que hacer.
  if v_sesion.id is null and coalesce(v_rol, '') = 'vendedor' then
    return jsonb_build_object(
      'success', false,
      'motivo', 'sin_sesion',
      'error', 'No tienes caja abierta, así que no hay turno que cortar. Abre tu turno primero.'
    );
  end if;

  if v_sesion.id is not null then
    v_fondo := v_sesion.fondo_contado;
    v_turno := v_sesion.turno;
  else
    -- Gerencia cerrando a mano (caja huérfana, ajuste). Exige confirmación.
    if not p_confirmar then
      return jsonb_build_object(
        'success', false,
        'motivo', 'sin_sesion_admin',
        'confirmable', true,
        'error', 'No hay ninguna caja abierta. Vas a registrar un corte administrativo, sin sesión de vendedor. ¿Continuar?'
      );
    end if;
    v_fondo := coalesce(p_fondo_inicial, 0);
    v_turno := coalesce(nullif(p_turno, ''),
                        case when (extract(hour from v_ahora)::int * 60
                                   + extract(minute from v_ahora)::int) < (15 * 60 + 30)
                             then 'matutino' else 'vespertino' end);
  end if;

  -- La ventana: desde donde quedó el corte anterior hasta este instante.
  -- No hay línea de las 15:30. Por eso da igual que Mary corte a las 14:58
  -- y Erika abra a las 15:19: los minutos de en medio caen en este corte.
  v_vent   := public.fn_ventana_corte(v_sesion.id, now());
  v_inicio := (v_vent->>'inicio')::timestamptz;
  v_fin    := (v_vent->>'fin')::timestamptz;

  v_decl := public.fn_sumar_denominaciones(p_denominaciones);
  if v_decl is null or v_decl = 0 then
    v_decl := coalesce(p_efectivo_declarado, 0);
  end if;

  v_r       := public.reconcile_cash_rango(v_inicio, v_fin);
  v_sistema := coalesce((v_r->>'efectivo_sistema')::numeric, 0);
  v_tarjeta := coalesce((v_r->>'tarjeta')::numeric,          0);
  v_mp      := coalesce((v_r->>'mercadopago')::numeric,      0);
  v_spei    := coalesce((v_r->>'spei')::numeric,             0);

  -- Freno suave: cortar recién abierta o sin un peso de movimiento casi
  -- siempre es un clic equivocado. Pregunta, no prohíbe.
  if not p_confirmar and v_sesion.id is not null then
    v_mins := floor(extract(epoch from (now() - v_sesion.abierta_at)) / 60)::int;
    v_movs := (case when v_sistema <> 0 or v_tarjeta <> 0 or v_mp <> 0 or v_spei <> 0
                    then 1 else 0 end);

    if v_mins < 30 or v_movs = 0 then
      return jsonb_build_object(
        'success', false,
        'motivo', 'corte_prematuro',
        'confirmable', true,
        'minutos_abierta', v_mins,
        'sin_movimientos', (v_movs = 0),
        'error', case
          when v_mins < 30 and v_movs = 0 then
            format('Abriste la caja hace %s minutos y no hay ventas en este periodo. Si cortas ahora cierras tu turno y no podrás volver a abrirlo hoy. ¿Seguro?', v_mins)
          when v_mins < 30 then
            format('Abriste la caja hace %s minutos. Si cortas ahora cierras tu turno y no podrás volver a abrirlo hoy. ¿Seguro?', v_mins)
          else
            'No hay ventas en este periodo. Si cortas ahora cierras tu turno y no podrás volver a abrirlo hoy. ¿Seguro?'
        end
      );
    end if;
  end if;

  v_apertura := (v_inicio at time zone 'America/Mexico_City')::time;

  insert into public.cortes_caja (
    turno, empleado_id, fecha, hora_apertura, hora_cierre,
    efectivo_declarado, efectivo_sistema, fondo_inicial,
    total_tarjeta, total_spei, total_mercadopago,
    contado_por, denominaciones, notas
  ) values (
    v_turno, v_actor_id, v_fecha, v_apertura, v_ahora::time,
    v_decl, v_sistema, v_fondo,
    v_tarjeta, v_spei, v_mp,
    nullif(btrim(coalesce(p_contado_por, '')), ''), p_denominaciones, p_notas
  ) returning * into v_fila;

  v_corte_id := v_fila.id;

  if v_sesion.id is not null then
    update public.caja_sesiones
       set estado     = 'cerrada',
           cerrada_at = now(),
           corte_id   = v_corte_id
     where id = v_sesion.id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor_id, v_nombre, 'corte_caja', 'cortes_caja', v_corte_id::text,
      jsonb_build_object('turno', v_turno, 'diferencia', v_fila.diferencia,
                         'total', v_fila.total_general, 'fondo', v_fila.fondo_inicial,
                         'tarjeta', v_tarjeta, 'mercadopago', v_mp,
                         'ventana_inicio', v_inicio, 'ventana_fin', v_fin,
                         'sesion_id', v_sesion.id, 'desglose', v_r));
  exception when others then null;
  end;

  return jsonb_build_object(
    'success',          true,
    'corte_id',         v_corte_id,
    'efectivo_sistema', v_fila.efectivo_sistema,
    'fondo_inicial',    v_fila.fondo_inicial,
    'esperado',         v_fila.fondo_inicial + v_fila.efectivo_sistema,
    'diferencia',       v_fila.diferencia,
    'total_general',    v_fila.total_general,
    'tarjeta',          v_fila.total_tarjeta,
    'mercadopago',      v_fila.total_mercadopago,
    'spei',             v_fila.total_spei,
    'hora_apertura',    v_fila.hora_apertura,
    'hora_cierre',      v_fila.hora_cierre,
    'turno',            v_turno,
    'ventana_inicio',   v_inicio,
    'ventana_fin',      v_fin,
    'detalle_metodos',  jsonb_build_object(
      'efectivo_pedidos',         v_r->'efectivo_pedidos',
      'efectivo_servicios',       v_r->'efectivo_servicios',
      'efectivo_devoluciones',    v_r->'efectivo_devoluciones',
      'efectivo_cambios_ingreso', v_r->'efectivo_cambios_ingreso',
      'credito_otorgado',         v_r->'credito_otorgado',
      'tarjeta_pedidos',          v_r->'tarjeta_pedidos',
      'tarjeta_servicios',        v_r->'tarjeta_servicios',
      'tarjeta_cambios',          v_r->'tarjeta_cambios'
    )
  );
end;
$$;

grant execute on function public.registrar_corte_caja(
  uuid, text, numeric, numeric, numeric, numeric, numeric, numeric,
  numeric, text, numeric, text, jsonb, boolean
) to anon, authenticated;


-- ── 7. Anular un corte: que un mal clic cueste un minuto, no un turno ───────

create or replace function public.anular_corte_caja(
  p_session_token uuid,
  p_corte_id      bigint,
  p_motivo        text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_rol      text;
  v_nombre   text;
  v_corte    public.cortes_caja%rowtype;
  v_hoy      date;
  v_sesion   bigint;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  select rol, nombre into v_rol, v_nombre from public.usuarios where id = v_actor_id;

  if coalesce(v_rol, '') not in ('admin', 'gerente') then
    return jsonb_build_object(
      'success', false,
      'error', 'Solo gerencia puede anular un corte.'
    );
  end if;

  if btrim(coalesce(p_motivo, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error', 'Escribe por qué se anula. Queda en la bitácora.'
    );
  end if;

  select * into v_corte from public.cortes_caja where id = p_corte_id;
  if v_corte.id is null then
    return jsonb_build_object('success', false, 'error', 'Ese corte no existe.');
  end if;
  if v_corte.anulado_at is not null then
    return jsonb_build_object('success', false, 'error', 'Ese corte ya estaba anulado.');
  end if;

  -- Solo el mismo día: más atrás ya hay reportes y depósitos hechos sobre él.
  v_hoy := (now() at time zone 'America/Mexico_City')::date;
  if ((v_corte.created_at at time zone 'America/Mexico_City')::date) <> v_hoy then
    return jsonb_build_object(
      'success', false,
      'error', 'Solo se puede anular un corte del mismo día. Para uno anterior, haz un ajuste con Contabilidad.'
    );
  end if;

  -- Si el corte que sigue ya se guardó, anular este descuadraría la cadena:
  -- la ventana del siguiente arrancó justo donde terminó éste.
  if exists (
    select 1 from public.cortes_caja cc
    where cc.anulado_at is null
      and cc.created_at > v_corte.created_at
  ) then
    return jsonb_build_object(
      'success', false,
      'error', 'Ya hay un corte posterior. Anula primero el más reciente.'
    );
  end if;

  update public.cortes_caja
     set anulado_at     = now(),
         anulado_por    = v_actor_id,
         anulado_motivo = btrim(p_motivo)
   where id = p_corte_id;

  -- Se reabre la sesión que este corte había cerrado.
  update public.caja_sesiones
     set estado     = 'abierta',
         cerrada_at = null,
         corte_id   = null
   where corte_id = p_corte_id
  returning id into v_sesion;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor_id, v_nombre, 'anular_corte', 'cortes_caja', p_corte_id::text,
      jsonb_build_object('motivo', btrim(p_motivo), 'turno', v_corte.turno,
                         'empleado_id', v_corte.empleado_id,
                         'total', v_corte.total_general,
                         'sesion_reabierta', v_sesion));
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'corte_id', p_corte_id,
    'sesion_reabierta', v_sesion,
    'mensaje', case
      when v_sesion is not null then 'Corte anulado. La caja quedó abierta otra vez.'
      else 'Corte anulado. No había sesión ligada; la vendedora ya puede abrir su turno.'
    end
  );
end;
$$;

grant execute on function public.anular_corte_caja(uuid, bigint, text) to anon, authenticated;


-- Un corte anulado deja de contar también para la pantalla: si no, el botón
-- de guardar seguiría bloqueado después de anularlo y la anulación no serviría.
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
  v_turno text;
  v_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;
  v_turno := p_turno;
  if coalesce(v_rol, '') = 'vendedor' then
    v_turno := coalesce(public.fn_turno_caja_de(v_user_id), p_turno);
  end if;
  select cc.id into v_id
  from public.cortes_caja cc
  where cc.turno = v_turno
    and cc.anulado_at is null
    and ((cc.created_at at time zone 'America/Mexico_City')::date) = p_fecha
    and (coalesce(v_rol, '') <> 'vendedor' or cc.empleado_id = v_user_id)
  limit 1;
  return jsonb_build_object('existe', v_id is not null, 'id', v_id);
end;
$$;

grant execute on function public.empleado_corte_turno_en_fecha(uuid, date, text) to anon, authenticated;

commit;


-- ============================================================================
-- Verificación (solo lee; el resultado te dice si quedó bien)
-- ============================================================================

-- (a) Debe haber UNA registrar_corte_caja, ahora de 14 argumentos.
select p.oid::regprocedure as firma, p.pronargs as num_args
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname = 'registrar_corte_caja';

-- (b) La cadena del día: cada corte y la ventana que cubrió.
select cc.id, u.nombre, cc.turno,
       (cc.created_at at time zone 'America/Mexico_City') as corte_cdmx,
       (public.fn_corte_previo_at(cc.created_at) at time zone 'America/Mexico_City') as desde_cdmx,
       cc.anulado_at
from public.cortes_caja cc
left join public.usuarios u on u.id = cc.empleado_id
where cc.created_at >= (now() - interval '3 days')
order by cc.created_at;

-- (c) ¿Erika ya puede abrir?
select u.nombre, public.fn_turno_abrir_hoy(u.id) as puede_abrir
from public.usuarios u
where u.eliminado_at is null and u.rol = 'vendedor';
