-- ============================================================
-- URGENTE 4-sep-2026 — restaurar registrar_corte_caja (14 args)
--
-- La tablet manda p_confirmar. Si la base tiene la firma de 13 args
-- (la de patch_corte_electronicos_servidor.sql) o no tiene ninguna,
-- PostgREST responde "Could not find the function … p_confirmar".
--
-- Este archivo restaura SOLO la firma correcta, asumiendo que el
-- resto de cadena continua (fn_ventana_corte, reconcile_cash_rango,
-- etc.) sigue vivo. Si el chequeo de abajo falla, NO sigas: pega
-- entero sql/patch_caja_cadena_continua_20260824.sql.
--
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================

do $$
declare
  faltan text[];
begin
  select array_agg(x) into faltan
  from unnest(array[
    'fn_ventana_corte',
    'reconcile_cash_rango',
    'fn_sumar_denominaciones'
  ]) as x
  where not exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = x
  );

  if faltan is not null then
    raise exception
      'Faltan helpers de cadena continua: %. Reaplica entero sql/patch_caja_cadena_continua_20260824.sql',
      array_to_string(faltan, ', ');
  end if;
end
$$;

-- Tirar overloads que no sean la firma de 14 args (con p_confirmar).
-- En particular: la de 13 args que deja electronicos_servidor.
do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure as firma
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'registrar_corte_caja'
      and p.pronargs <> 14
  loop
    raise notice 'Borrando overload incorrecto: %', r.firma;
    execute format('drop function if exists %s', r.firma);
  end loop;
end
$$;

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

-- Que PostgREST vea la firma nueva ya, sin esperar el TTL del cache.
notify pgrst, 'reload schema';

-- Verificación: tiene que salir UNA fila con 14 args.
select p.oid::regprocedure as firma, p.pronargs as num_args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname = 'registrar_corte_caja';
