-- FarmaCapital — Un corte por turno por día.
--
-- Mary = matutino, Erika = vespertino.
-- No se reabre el mismo turno después del corte (eso duplicó el matutino
-- de Mary el 19-ago a las 22:50). Quien cubre ambos sí cierra matutino
-- y abre vespertino.
--
-- Ejecutar TODO en Supabase → SQL Editor → Run. Idempotente.

begin;

-- ── Perfiles: Mary matutino, Erika vespertino ───────────────────────────────

do $$
declare
  v_mary  bigint;
  v_erika bigint;
begin
  select u.id into v_mary
  from public.usuarios u
  where u.eliminado_at is null
    and u.nombre ilike '%mary%'
  order by case when u.nombre ilike '%yen%' then 0 else 1 end, u.id
  limit 1;

  select u.id into v_erika
  from public.usuarios u
  where u.eliminado_at is null
    and u.nombre ilike '%erika%'
  order by u.id
  limit 1;

  if v_mary is not null then
    perform public.fn_sync_turno_caja(v_mary, null, 'matutino');
  end if;
  if v_erika is not null then
    perform public.fn_sync_turno_caja(v_erika, null, 'vespertino');
  end if;
end $$;


-- ¿Ya hubo sesión o corte de este turno hoy (esta persona)?
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
      )
      or exists (
        select 1
        from public.cortes_caja cc
        where cc.empleado_id = p_user_id
          and cc.turno = p_turno
          and (
            cc.fecha = p_fecha
            or ((cc.created_at at time zone 'America/Mexico_City')::date) = p_fecha
          )
      )
    );
$$;


-- ¿Ya hay un corte de ese turno (el cajón de la farmacia) en el día?
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
        and (
          cc.fecha = p_fecha
          or ((cc.created_at at time zone 'America/Mexico_City')::date) = p_fecha
        )
    );
$$;


-- Turno que debe abrir AHORA.
-- Si no cubre ambos: el asignado, una sola vez. Después de las 15:30 el
-- matutino ya no abre (el vespertino es de la compañera).
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
begin
  if public.fn_es_descanso_hoy(p_user_id) then
    return null;
  end if;

  v_asignado := public.fn_turno_caja_de(p_user_id);
  v_ahora := now() at time zone 'America/Mexico_City';
  v_fecha := v_ahora::date;
  v_minutos := (extract(hour from v_ahora)::int * 60) + extract(minute from v_ahora)::int;

  if public.fn_cubre_ambos_hoy(p_user_id) then
    if exists (
      select 1 from public.caja_sesiones s
      where s.empleado_id = p_user_id
        and s.fecha = v_fecha
        and s.turno = 'matutino'
        and s.estado = 'cerrada'
    ) or public.fn_farmacia_ya_corte_turno_hoy('matutino', v_fecha) then
      if public.fn_empleado_ya_tuvo_turno_hoy(p_user_id, 'vespertino', v_fecha)
         or public.fn_farmacia_ya_corte_turno_hoy('vespertino', v_fecha) then
        return null;
      end if;
      return 'vespertino';
    end if;
    if public.fn_empleado_ya_tuvo_turno_hoy(p_user_id, 'vespertino', v_fecha)
       or public.fn_farmacia_ya_corte_turno_hoy('vespertino', v_fecha) then
      return null;
    end if;
    return case when v_minutos < (15 * 60 + 30) then 'matutino' else 'vespertino' end;
  end if;

  if v_asignado is null then
    return null;
  end if;

  if public.fn_empleado_ya_tuvo_turno_hoy(p_user_id, v_asignado, v_fecha)
     or public.fn_farmacia_ya_corte_turno_hoy(v_asignado, v_fecha) then
    return null;
  end if;

  -- Matutino no abre de noche: a las 15:30 el cajón pasa al vespertino.
  if v_asignado = 'matutino' and v_minutos >= (15 * 60 + 30) then
    return null;
  end if;

  -- Vespertino no abre de mañana (el relevo empieza ~15:00).
  if v_asignado = 'vespertino' and v_minutos < (14 * 60 + 30) then
    return null;
  end if;

  return v_asignado;
end;
$$;


create or replace function public.empleado_jornada_hoy(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_descanso boolean;
  v_ambos boolean;
  v_abrir text;
  v_habitual text;
  v_fecha date;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  v_descanso := coalesce(public.fn_es_descanso_hoy(v_user_id), false);
  v_ambos := coalesce(public.fn_cubre_ambos_hoy(v_user_id), false);
  v_abrir := public.fn_turno_abrir_hoy(v_user_id);
  v_habitual := public.fn_turno_caja_de(v_user_id);
  v_fecha := (now() at time zone 'America/Mexico_City')::date;

  return jsonb_build_object(
    'dia_idx_hoy', public.fn_dia_idx_cdmx(),
    'dia_descanso', (select dia_descanso from public.usuarios where id = v_user_id),
    'es_descanso', v_descanso,
    'cubre_ambos', v_ambos,
    'turno_habitual', v_habitual,
    'turno_abrir', v_abrir,
    'ya_cerro_turno', (
      v_abrir is null
      and not v_descanso
      and v_habitual is not null
      and public.fn_empleado_ya_tuvo_turno_hoy(v_user_id, v_habitual, v_fecha)
    )
  );
end;
$$;


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
  v_fecha date;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol, nombre into v_rol, v_nombre from public.usuarios where id = v_user_id;

  if exists (
    select 1 from public.caja_sesiones
    where empleado_id = v_user_id and estado = 'abierta'
  ) then
    return jsonb_build_object('success', false, 'error', 'Ya tienes una caja abierta.');
  end if;

  select u.nombre into v_ocupada
  from public.caja_sesiones s
  join public.usuarios u on u.id = s.empleado_id
  where s.estado = 'abierta'
  limit 1;
  if v_ocupada is not null then
    return jsonb_build_object(
      'success', false,
      'error', format('Hay una caja abierta de %s. Debe cerrar turno antes de que abras la tuya.', v_ocupada)
    );
  end if;

  v_ahora := now() at time zone 'America/Mexico_City';
  v_fecha := v_ahora::date;
  v_minutos := (extract(hour from v_ahora)::int * 60) + extract(minute from v_ahora)::int;
  v_asignado := public.fn_turno_caja_de(v_user_id);

  if coalesce(v_rol, '') = 'vendedor' then
    if coalesce(public.fn_es_descanso_hoy(v_user_id), false) then
      return jsonb_build_object(
        'success', false,
        'error', 'Hoy es tu día de descanso. La caja la abre quien cubre ambos turnos.'
      );
    end if;
    v_turno := public.fn_turno_abrir_hoy(v_user_id);
    if v_turno is null then
      if v_asignado is null then
        return jsonb_build_object(
          'success', false,
          'error', 'RH debe asignarte un turno (matutino o vespertino) antes de abrir caja.'
        );
      end if;
      if public.fn_empleado_ya_tuvo_turno_hoy(v_user_id, v_asignado, v_fecha)
         or public.fn_farmacia_ya_corte_turno_hoy(v_asignado, v_fecha) then
        return jsonb_build_object(
          'success', false,
          'error', format(
            'Ya cerraste el turno %s de hoy. No se abre otra vez. El otro turno es de tu compañera.',
            v_asignado
          )
        );
      end if;
      if v_asignado = 'matutino' and v_minutos >= (15 * 60 + 30) then
        return jsonb_build_object(
          'success', false,
          'error', 'Tu turno es el matutino (hasta las 15:30). El vespertino lo abre tu compañera.'
        );
      end if;
      if v_asignado = 'vespertino' and v_minutos < (14 * 60 + 30) then
        return jsonb_build_object(
          'success', false,
          'error', 'Tu turno es el vespertino (desde las 15:00). El matutino lo abre tu compañera.'
        );
      end if;
      return jsonb_build_object(
        'success', false,
        'error', 'Ya cerraste los turnos que te tocan hoy.'
      );
    end if;
  else
    v_turno := coalesce(
      public.fn_turno_abrir_hoy(v_user_id),
      v_asignado,
      case when v_minutos < (15 * 60 + 30) then 'matutino' else 'vespertino' end
    );
  end if;

  if public.fn_farmacia_ya_corte_turno_hoy(v_turno, v_fecha)
     or exists (
       select 1 from public.caja_sesiones s
       where s.fecha = v_fecha and s.turno = v_turno
     ) then
    return jsonb_build_object(
      'success', false,
      'error', format('El turno %s de hoy ya se abrió o se cerró. No se puede abrir otra vez.', v_turno)
    );
  end if;

  v_fondo := public.fn_sumar_denominaciones(p_denominaciones);

  insert into public.caja_sesiones (
    empleado_id, turno, fecha, fondo_contado, denominaciones, nota_apertura, abierta_at, estado
  ) values (
    v_user_id, v_turno, v_fecha, v_fondo,
    coalesce(p_denominaciones, '{}'::jsonb),
    nullif(btrim(coalesce(p_nota, '')), ''),
    now(),
    'abierta'
  ) returning id into v_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_user_id, v_nombre,
      'abrir_caja', 'caja_sesiones', v_id::text,
      jsonb_build_object('turno', v_turno, 'fondo', v_fondo, 'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id))
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'abierta', true,
    'id', v_id,
    'turno', v_turno,
    'fondo_contado', v_fondo,
    'abierta_at', now(),
    'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id)
  );
end;
$$;


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
  v_fecha    date;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  select nombre into v_nombre from public.usuarios where id = v_actor_id;

  v_ahora := now() at time zone 'America/Mexico_City';
  v_fecha := v_ahora::date;

  v_decl := public.fn_sumar_denominaciones(p_denominaciones);
  if v_decl is null or v_decl = 0 then
    v_decl := coalesce(p_efectivo_declarado, 0);
  end if;

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

  if public.fn_farmacia_ya_corte_turno_hoy(v_turno, v_fecha) then
    raise exception 'Ya existe un corte % de hoy. No se puede guardar otro.', v_turno
      using errcode = 'P0001';
  end if;

  v_r       := public.reconcile_shift_cash(v_turno, v_fecha);
  v_sistema := coalesce((v_r->>'efectivo_sistema')::numeric, 0);
  v_tarjeta := coalesce((v_r->>'tarjeta')::numeric,          0);
  v_mp      := coalesce((v_r->>'mercadopago')::numeric,      0);
  v_spei    := coalesce((v_r->>'spei')::numeric,             0);

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

grant execute on function public.fn_empleado_ya_tuvo_turno_hoy(bigint, text, date) to anon, authenticated;
grant execute on function public.fn_farmacia_ya_corte_turno_hoy(text, date) to anon, authenticated;
grant execute on function public.fn_turno_abrir_hoy(bigint) to anon, authenticated;
grant execute on function public.empleado_jornada_hoy(uuid) to anon, authenticated;
grant execute on function public.abrir_sesion_caja(uuid, jsonb, text) to anon, authenticated;
grant execute on function public.registrar_corte_caja(
  uuid, text, numeric, numeric, numeric, numeric, numeric, numeric,
  numeric, text, numeric, text, jsonb
) to anon, authenticated;

notify pgrst, 'reload schema';

commit;
