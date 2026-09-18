-- FarmaCapital — un solo pegado (18-sep-2026)
-- 1) Recargos editables  2) El servidor pone el recargo  3) Corte Cynthia 17-sep
-- Idempotente. Supabase → SQL Editor → Run.

-- ══════════════════════════════════════════════════════════════
-- 1) Recargos de recibos editables (admin)
-- ══════════════════════════════════════════════════════════════
begin;

insert into public.configuracion (clave, valor)
values (
  'servicios_recargos',
  '{"cfe":8,"telmex":8,"totalplay":8,"izzi":10,"sky":10,"agua":8,"gas":8,"otro":10}'
)
on conflict (clave) do nothing;

create or replace function public.admin_set_servicios_recargos(
  p_session_token uuid,
  p_recargos      jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_id text;
  v_val numeric;
  v_clean jsonb := '{}'::jsonb;
  v_ids text[] := array['cfe','telmex','totalplay','izzi','sky','agua','gas','otro'];
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_recargos is null or jsonb_typeof(p_recargos) <> 'object' then
    return jsonb_build_object('success', false, 'error', 'recargos_invalidos');
  end if;

  foreach v_id in array v_ids loop
    begin
      v_val := round((p_recargos ->> v_id)::numeric, 2);
    exception when others then
      return jsonb_build_object('success', false, 'error', 'El recargo de ' || v_id || ' es inválido');
    end;
    if v_val is null or v_val <= 0 then
      return jsonb_build_object('success', false, 'error', 'El recargo de ' || v_id || ' tiene que ser mayor a 0');
    end if;
    if v_val > 200 then
      return jsonb_build_object('success', false, 'error', 'El recargo de ' || v_id || ' no puede pasar de $200');
    end if;
    v_clean := v_clean || jsonb_build_object(v_id, v_val);
  end loop;

  insert into public.configuracion (clave, valor)
  values ('servicios_recargos', v_clean::text)
  on conflict (clave) do update set valor = excluded.valor;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'set_servicios_recargos',
      'configuracion',
      'servicios_recargos',
      v_clean::text
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'recargos', v_clean);
end;
$$;

grant execute on function public.admin_set_servicios_recargos(uuid, jsonb)
  to anon, authenticated;

commit;

-- ══════════════════════════════════════════════════════════════
-- 2) El servidor pone el recargo (Izzi $10 aunque el POS mande $8 o $0)
-- ══════════════════════════════════════════════════════════════
begin;

create or replace function public.fn_recargo_catalogo_servicio(
  p_proveedor text,
  p_categoria text,
  p_comision  numeric default null
)
returns numeric
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_cat text := lower(btrim(coalesce(p_categoria, '')));
  v_prov text := lower(btrim(coalesce(p_proveedor, '')));
  v_id text;
  v_cfg jsonb;
  v_val numeric;
begin
  if v_cat = 'recarga' then
    return 0;
  end if;

  v_id := case
    when v_prov in ('cfe','telmex','totalplay','izzi','sky','agua','gas','otro') then v_prov
    when v_prov like '%izzi%' then 'izzi'
    when v_prov like '%cfe%' then 'cfe'
    when v_prov like '%telmex%' then 'telmex'
    when v_prov like '%totalplay%' then 'totalplay'
    when v_prov like '%sky%' then 'sky'
    when v_prov like '%agua%' then 'agua'
    when v_prov like '%gas%' then 'gas'
    else 'otro'
  end;

  select valor::jsonb into v_cfg
  from public.configuracion
  where clave = 'servicios_recargos'
  limit 1;

  begin
    v_val := round((v_cfg ->> v_id)::numeric, 2);
  exception when others then
    v_val := null;
  end;

  if v_val is null or v_val <= 0 then
    v_val := case v_id
      when 'izzi' then 10
      when 'sky' then 10
      when 'otro' then 10
      else 8
    end;
  end if;

  if v_val > 200 then
    v_val := 200;
  end if;
  return v_val;
end;
$$;

grant execute on function public.fn_recargo_catalogo_servicio(text, text, numeric)
  to anon, authenticated;

create or replace function public.registrar_pago_servicio_pos(
  p_session_token    uuid,
  p_proveedor        text,
  p_categoria        text,
  p_referencia       text,
  p_monto_servicio   numeric,
  p_comision         numeric,
  p_metodo_pago      text,
  p_liquidado_point  boolean default false,
  p_notas            text default null,
  p_cliente_id       bigint default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_id bigint;
  v_folio text;
  v_monto numeric;
  v_com numeric;
  v_total numeric;
  v_metodo text;
  v_comp numeric;
  v_cat text;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if coalesce(btrim(p_proveedor), '') = '' then
    raise exception 'Proveedor requerido';
  end if;
  if coalesce(btrim(p_categoria), '') = '' then
    raise exception 'Categoría requerida';
  end if;

  v_cat := lower(btrim(p_categoria));
  v_monto := round(coalesce(p_monto_servicio, 0)::numeric, 2);
  if v_monto <= 0 then
    raise exception 'Monto del servicio debe ser mayor a 0';
  end if;

  if v_cat = 'recarga' then
    v_com := 0;
  else
    v_com := public.fn_recargo_catalogo_servicio(p_proveedor, v_cat, p_comision);
    if v_com <= 0 then
      raise exception 'El recargo de farmacia es obligatorio en recibos. No se guarda en cero.';
    end if;
  end if;

  v_total := round(v_monto + v_com, 2);
  v_comp := round(v_monto * 0.01, 2);
  v_metodo := lower(btrim(coalesce(p_metodo_pago, '')));
  if v_metodo not in ('efectivo', 'tarjeta') then
    raise exception 'metodo_pago inválido (efectivo o tarjeta)';
  end if;

  if p_cliente_id is not null and not exists (
    select 1 from public.clientes c where c.id = p_cliente_id and c.eliminado_at is null
  ) then
    raise exception 'Cliente no encontrado';
  end if;

  insert into public.pagos_servicio (
    folio, categoria, proveedor, referencia,
    monto_servicio, comision, total_cobrado, metodo_pago,
    liquidado_point, notas, cliente_id, atendido_por,
    compensacion_mp, costo_liquidacion, fuente_liquidacion
  ) values (
    'PENDING',
    v_cat,
    btrim(p_proveedor),
    nullif(btrim(coalesce(p_referencia, '')), ''),
    v_monto,
    v_com,
    v_total,
    v_metodo,
    coalesce(p_liquidado_point, false),
    nullif(btrim(coalesce(p_notas, '')), ''),
    p_cliente_id,
    v_actor,
    v_comp,
    v_monto,
    'saldo_mp'
  )
  returning id into v_id;

  v_folio := 'SRV-' || to_char(now() at time zone 'America/Mexico_City', 'YYYYMMDD') || '-' || lpad(v_id::text, 6, '0');
  update public.pagos_servicio set folio = v_folio where id = v_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'pago_servicio_pos',
      'pagos_servicio',
      v_id::text,
      jsonb_build_object(
        'folio', v_folio,
        'proveedor', p_proveedor,
        'total', v_total,
        'comision', v_com,
        'metodo', v_metodo,
        'compensacion_mp', v_comp
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'id', v_id,
    'folio', v_folio,
    'total_cobrado', v_total,
    'comision', v_com,
    'compensacion_mp', v_comp
  );
end;
$$;

grant execute on function public.registrar_pago_servicio_pos(
  uuid, text, text, text, numeric, numeric, text, boolean, text, bigint
) to anon, authenticated;

commit;

-- ══════════════════════════════════════════════════════════════
-- 3) Qué quedó el 17-sep (para ver el Izzi)
-- ══════════════════════════════════════════════════════════════
select
  c.id,
  u.nombre,
  c.turno,
  to_char(c.created_at at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI') as hora,
  c.fondo_inicial,
  c.efectivo_sistema,
  (c.fondo_inicial + c.efectivo_sistema) as esperado,
  c.efectivo_declarado,
  c.diferencia,
  c.total_tarjeta
from public.cortes_caja c
left join public.usuarios u on u.id = c.empleado_id
where c.anulado_at is null
  and (c.created_at at time zone 'America/Mexico_City')::date = date '2026-09-17'
order by c.created_at;

select
  to_char(ps.created_at at time zone 'America/Mexico_City', 'HH24:MI') as hora,
  ps.folio,
  ps.proveedor,
  ps.categoria,
  ps.metodo_pago,
  ps.monto_servicio,
  ps.comision,
  ps.total_cobrado
from public.pagos_servicio ps
where (ps.created_at at time zone 'America/Mexico_City')::date = date '2026-09-17'
order by ps.created_at;

select
  coalesce(sum(total_cobrado) filter (where metodo_pago = 'efectivo'), 0) as efectivo_servicios,
  coalesce(sum(comision) filter (where metodo_pago = 'efectivo'), 0) as recargo_en_efectivo,
  coalesce(sum(total_cobrado) filter (where metodo_pago = 'tarjeta'), 0) as tarjeta_servicios,
  coalesce(sum(comision) filter (where metodo_pago = 'tarjeta'), 0) as recargo_en_tarjeta
from public.pagos_servicio
where (created_at at time zone 'America/Mexico_City')::date = date '2026-09-17';

-- ══════════════════════════════════════════════════════════════
-- 4) Arreglo del Izzi de Cynthia (efectivo, recargo < $10) + recálculo
--    Si el Izzi fue tarjeta, no toca el corte (sale un NOTICE).
-- ══════════════════════════════════════════════════════════════
do $$
declare
  v_ps     public.pagos_servicio%rowtype;
  v_corte  public.cortes_caja%rowtype;
  v_sesion public.caja_sesiones%rowtype;
  v_vent   jsonb;
  v_r      jsonb;
  v_inicio timestamptz;
begin
  select * into v_ps
  from public.pagos_servicio
  where (created_at at time zone 'America/Mexico_City')::date = date '2026-09-17'
    and proveedor ilike '%izzi%'
  order by created_at
  limit 1;

  if v_ps.id is null then
    raise notice 'No hay un pago Izzi el 17-sep.';
    return;
  end if;

  if v_ps.metodo_pago is distinct from 'efectivo' then
    raise notice 'Izzi % está en % (no efectivo). No se altera el corte.',
      v_ps.folio, v_ps.metodo_pago;
    return;
  end if;

  if coalesce(v_ps.comision, 0) >= 10 then
    raise notice 'Izzi % ya tiene recargo %. Nada que sumar.', v_ps.folio, v_ps.comision;
    return;
  end if;

  update public.pagos_servicio
  set comision = 10,
      total_cobrado = round(monto_servicio + 10, 2)
  where id = v_ps.id;

  raise notice 'Izzi %: recargo % → 10. total_cobrado % → %',
    v_ps.folio, v_ps.comision, v_ps.total_cobrado, round(v_ps.monto_servicio + 10, 2);

  select c.* into v_corte
  from public.cortes_caja c
  left join public.usuarios u on u.id = c.empleado_id
  where c.anulado_at is null
    and c.turno = 'matutino'
    and (c.created_at at time zone 'America/Mexico_City')::date = date '2026-09-17'
    and (u.nombre ilike '%cynthia%' or u.nombre ilike '%cintia%')
  order by c.created_at desc
  limit 1;

  if v_corte.id is null then
    raise notice 'Ticket Izzi corregido. No se halló el corte de Cynthia para recalcular.';
    return;
  end if;

  select * into v_sesion
  from public.caja_sesiones
  where corte_id = v_corte.id
  order by id desc
  limit 1;

  v_vent := public.fn_ventana_corte(v_sesion.id, v_corte.created_at);
  v_inicio := (v_vent->>'inicio')::timestamptz;
  v_r := public.reconcile_cash_rango(v_inicio, v_corte.created_at);

  update public.cortes_caja
  set efectivo_sistema = coalesce((v_r->>'efectivo_sistema')::numeric, efectivo_sistema)
  where id = v_corte.id;

  raise notice 'Corte %: efectivo_sistema % → %',
    v_corte.id, v_corte.efectivo_sistema, coalesce((v_r->>'efectivo_sistema')::numeric, v_corte.efectivo_sistema);
end;
$$;
