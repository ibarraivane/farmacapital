-- ============================================================
-- Corte de caja: tarjeta, MercadoPago y SPEI los calcula el servidor,
-- y los pagos de servicio entran al corte.
--
-- Dos problemas que corrige:
--
--   1. registrar_corte_caja recalculaba el efectivo con reconcile_shift_cash
--      pero guardaba tarjeta / MP / SPEI tal como los mandaba el navegador.
--      El navegador los precargaba al ABRIR la pantalla, no al guardar, así
--      que toda venta con tarjeta hecha mientras el cajero contaba el cajón
--      se perdía. El efectivo sí la agarraba. Esa asimetría es la que hacía
--      que "faltaran cobros de tarjeta".
--
--   2. pagos_servicio (recargas, CFE, etc.) es su propia tabla y no escribe
--      en pedidos, así que reconcile_shift_cash nunca la veía. El cobro con
--      tarjeta Point y el efectivo de esas operaciones había que capturarlos
--      a mano — y en la práctica nadie los capturaba.
--
-- Además reescribe reconcile_shift_cash con los rangos correctos
-- (00:00–15:29:59.999 / 15:30–23:59:59.999). En sql/ conviven dos versiones
-- y la vieja cortaba el vespertino a las 21:59:59, dejando fuera lo vendido
-- de 22:00 a 22:30 y un hueco de 15:30 a 16:00. Correr esto deja una sola,
-- sin importar cuál estuviera viva.
--
-- No toca ningún corte ya guardado: efectivo_sistema, total_tarjeta y demás
-- son columnas normales, no vistas. Sólo cambia lo que se calcule de aquí
-- en adelante.
--
-- Ejecutar en Supabase SQL Editor.
-- ============================================================


-- ── 1. reconcile_shift_cash: los 4 métodos + pagos de servicio ──
-- Misma firma que la versión viva, así que create or replace la
-- reemplaza de verdad (no crea un overload).

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
  v_inicio timestamptz;
  v_fin    timestamptz;

  v_ef_pedidos   numeric := 0;
  v_tar_pedidos  numeric := 0;
  v_mp_pedidos   numeric := 0;
  v_spei_pedidos numeric := 0;

  v_ef_serv   numeric := 0;
  v_tar_serv  numeric := 0;
begin
  -- Turnos en HORA LOCAL de México, no UTC. La frontera del dinero son las
  -- 15:30 (el relevo de personal a las 15:00 es otra cosa). Los rangos cubren
  -- el día completo a propósito: una venta a las 7:50 o a las 22:40 cae en un
  -- turno en vez de perderse en un hueco.
  if p_turno = 'matutino' then
    v_inicio := (p_fecha + time '00:00:00')     at time zone 'America/Mexico_City';
    v_fin    := (p_fecha + time '15:29:59.999') at time zone 'America/Mexico_City';
  else
    v_inicio := (p_fecha + time '15:30:00')     at time zone 'America/Mexico_City';
    v_fin    := (p_fecha + time '23:59:59.999') at time zone 'America/Mexico_City';
  end if;

  -- Ventas de mostrador, tienda web y consultas de doctora.
  -- Ojo: el POS mapea bbva_terminal y mercadopago_point a 'tarjeta' antes de
  -- insertar, así que 'mercadopago' aquí son sólo pedidos de la tienda web.
  select
    coalesce(sum(total) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total) filter (where metodo_pago = 'tarjeta'),  0),
    coalesce(sum(total) filter (where metodo_pago in ('mercadopago','mercadopago_point')), 0),
    coalesce(sum(total) filter (where metodo_pago = 'spei'),     0)
  into v_ef_pedidos, v_tar_pedidos, v_mp_pedidos, v_spei_pedidos
  from public.pedidos
  where estado = 'completado'
    and created_at between v_inicio and v_fin;

  -- Pagos de servicio: se cobra total_cobrado (monto + comisión) y ese dinero
  -- entra físicamente al cajón o a la terminal. Antes no lo veía nadie.
  select
    coalesce(sum(total_cobrado) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total_cobrado) filter (where metodo_pago = 'tarjeta'),  0)
  into v_ef_serv, v_tar_serv
  from public.pagos_servicio
  where created_at between v_inicio and v_fin;

  return jsonb_build_object(
    -- Totales que usa el corte
    'efectivo_sistema', v_ef_pedidos  + v_ef_serv,
    'tarjeta',          v_tar_pedidos + v_tar_serv,
    'mercadopago',      v_mp_pedidos,
    'spei',             v_spei_pedidos,
    -- Desglose, para poder auditar de dónde salió cada peso
    'efectivo_pedidos',   v_ef_pedidos,
    'efectivo_servicios', v_ef_serv,
    'tarjeta_pedidos',    v_tar_pedidos,
    'tarjeta_servicios',  v_tar_serv,
    'rango_inicio',       v_inicio,
    'rango_fin',          v_fin
  );
end;
$$;

grant execute on function public.reconcile_shift_cash(text, date) to anon, authenticated;


-- ── 2. Barrer overloads viejos de registrar_corte_caja ──────────
-- create or replace con distinta lista de argumentos NO reemplaza: crea un
-- overload. En sql/ hay una firma de 10 args (patch_turnos_horario_2026) y
-- otra de 13. Si las dos viven en la base, PostgREST puede resolver a la que
-- no es y guardar un corte con el modelo viejo, sin fondo ni denominaciones.
-- Se borra cualquiera que no tenga exactamente 13 argumentos.

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
      and p.pronargs <> 13
  loop
    raise notice 'Borrando overload viejo: %', r.firma;
    execute format('drop function if exists %s', r.firma);
  end loop;
end
$$;


-- ── 3. registrar_corte_caja: el servidor calcula TODOS los métodos ──
-- Misma firma de 13 args, para no romper la llamada del cliente.
-- p_tarjeta, p_mercadopago y p_spei se conservan por compatibilidad
-- pero se IGNORAN, igual que ya se ignoraba p_efectivo_sistema.

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
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  select nombre into v_nombre from public.usuarios where id = v_actor_id;

  v_ahora := now() at time zone 'America/Mexico_City';

  -- El efectivo declarado sale del desglose por denominación si lo hay.
  -- Se suma en el servidor: un total tecleado a mano no manda sobre las piezas.
  v_decl := public.fn_sumar_denominaciones(p_denominaciones);
  if v_decl is null or v_decl = 0 then
    v_decl := coalesce(p_efectivo_declarado, 0);
  end if;

  -- Fondo y hora de apertura salen de la sesión de caja real, no del cliente.
  select * into v_sesion
  from public.caja_sesiones
  where empleado_id = v_actor_id and estado = 'abierta'
  limit 1;

  if v_sesion.id is not null then
    v_fondo    := v_sesion.fondo_contado;
    v_turno    := v_sesion.turno;
    v_apertura := (v_sesion.abierta_at at time zone 'America/Mexico_City')::time;
  else
    v_fondo    := coalesce(p_fondo_inicial, 0);
    v_turno    := coalesce(nullif(p_turno, ''), 'matutino');
    v_apertura := case when v_turno = 'matutino' then time '08:00' else time '15:00' end;
  end if;

  -- AQUÍ ESTÁ EL ARREGLO: una sola llamada, en el momento de guardar, para
  -- los cuatro métodos. Antes sólo el efectivo se recalculaba y tarjeta / MP
  -- llegaban congelados desde el navegador.
  v_r       := public.reconcile_shift_cash(v_turno, v_ahora::date);
  v_sistema := coalesce((v_r->>'efectivo_sistema')::numeric, 0);
  v_tarjeta := coalesce((v_r->>'tarjeta')::numeric,          0);
  v_mp      := coalesce((v_r->>'mercadopago')::numeric,      0);
  v_spei    := coalesce((v_r->>'spei')::numeric,             0);

  -- diferencia y total_general son GENERATED: las calcula Postgres.
  insert into public.cortes_caja (
    turno, empleado_id, fecha, hora_apertura, hora_cierre,
    efectivo_declarado, efectivo_sistema, fondo_inicial,
    total_tarjeta, total_spei, total_mercadopago,
    contado_por, denominaciones, notas
  ) values (
    v_turno, v_actor_id, v_ahora::date, v_apertura, v_ahora::time,
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
    values (
      v_actor_id, v_nombre,
      'corte_caja', 'cortes_caja', v_corte_id::text,
      jsonb_build_object('turno', v_turno, 'diferencia', v_fila.diferencia,
                         'total', v_fila.total_general, 'fondo', v_fila.fondo_inicial,
                         'tarjeta', v_tarjeta, 'mercadopago', v_mp,
                         'desglose', v_r)
    );
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
    -- Desglose para la pantalla de resultado: de dónde salió cada método.
    'detalle_metodos',  jsonb_build_object(
      'efectivo_pedidos',   v_r->'efectivo_pedidos',
      'efectivo_servicios', v_r->'efectivo_servicios',
      'tarjeta_pedidos',    v_r->'tarjeta_pedidos',
      'tarjeta_servicios',  v_r->'tarjeta_servicios'
    )
  );
end;
$$;

grant execute on function public.registrar_corte_caja(
  uuid, text, numeric, numeric, numeric, numeric, numeric, numeric,
  numeric, text, numeric, text, jsonb
) to anon, authenticated;


-- ── 4. El precargado del formulario también devuelve el desglose ──
-- Sigue sin devolver efectivo: ese es justo el número que el arqueo
-- ciego tiene que esconder hasta que el cajero se comprometa.

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
  v_r       jsonb;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;

  v_turno := p_turno;
  if coalesce(v_rol, '') = 'vendedor' then
    v_turno := coalesce(public.fn_turno_caja_de(v_user_id), p_turno);
  end if;

  v_r := public.reconcile_shift_cash(v_turno, p_fecha);
  return jsonb_build_object(
    'tarjeta',           v_r->'tarjeta',
    'mercadopago',       v_r->'mercadopago',
    'spei',              v_r->'spei',
    'tarjeta_pedidos',   v_r->'tarjeta_pedidos',
    'tarjeta_servicios', v_r->'tarjeta_servicios'
  );
end;
$$;

grant execute on function public.empleado_totales_electronicos_turno(uuid, text, date) to anon, authenticated;


-- ── 5. Verificación ─────────────────────────────────────────────
-- (a) Debe quedar UNA sola registrar_corte_caja, de 13 argumentos.
select p.oid::regprocedure as firma, p.pronargs as num_args
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname = 'registrar_corte_caja';

-- (b) Los rangos no se traslapan ni dejan hueco, y ahora traen desglose.
select 'matutino'   as turno, public.reconcile_shift_cash('matutino',   current_date) as r
union all
select 'vespertino', public.reconcile_shift_cash('vespertino', current_date);
