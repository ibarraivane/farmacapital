-- FarmaCapital — Fase A / Flujo de caja: tabla gastos + config + RPCs.
-- 2026-09-04. Idempotente. NO editar este archivo una vez aplicado.
--
-- Contexto (el markdown docs/CURSOR_FINANZAS_PROMPT.md NO trae Parte 9;
-- esta fase se arma con el brief de implementación + Parte 8 + rentabilidad §3.1):
--   • Parte 8 manda: nómina y pago a proveedor son captura manual en v1.
--   • compra_inventario sale en Flujo; el servidor fuerza afecta_pl = false.
--   • No se deriva nómina desde nomina_empleados (0 filas → $0 mentiroso).
--   • No hay admin_generar_gastos_derivados en este parche.
--   • finanzas_fecha_inicio / finanzas_saldo_inicial nacen VACÍAS.
--
-- Aplicar ANTES de sql/patch_finanzas_flujo_caja_20260904.sql.

begin;

-- ── 1. Tabla gastos ─────────────────────────────────────────────────────────
create table if not exists public.gastos (
  id              bigserial primary key,
  fecha           date          not null default ((now() at time zone 'America/Mexico_City')::date),
  categoria       text          not null,
  subcategoria    text,
  concepto        text          not null,
  monto           numeric(12,2) not null check (monto >= 0),
  origen          text          not null default 'manual',
  ref_id          bigint,
  es_recurrente   boolean       not null default false,
  periodicidad    text,
  proveedor       text,
  metodo_pago     text,
  deducible       boolean       not null default true,
  comprobante_url text,
  registrado_por  bigint        references public.usuarios(id),
  notas           text,
  afecta_pl       boolean       not null default true,
  eliminado_at    timestamptz,
  created_at      timestamptz   not null default now()
);

alter table public.gastos
  add column if not exists afecta_pl boolean not null default true;

alter table public.gastos
  add column if not exists eliminado_at timestamptz;

comment on table public.gastos is
  'Salidas de caja capturadas a mano (v1). compra_inventario afecta Flujo, no P&L.';
comment on column public.gastos.afecta_pl is
  'false cuando categoria = compra_inventario (el servidor lo fuerza). Reservado para P&L.';

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'gastos_categoria_chk'
      and conrelid = 'public.gastos'::regclass
  ) then
    alter table public.gastos
      add constraint gastos_categoria_chk
      check (categoria in (
        'renta','nomina','servicios','comisiones','mermas','mantenimiento',
        'publicidad','insumos','seguros','licencias','impuestos','financieros',
        'ajuste_redondeo','compra_inventario','otros'
      ));
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'gastos_origen_chk'
      and conrelid = 'public.gastos'::regclass
  ) then
    alter table public.gastos
      add constraint gastos_origen_chk
      check (origen in (
        'manual','nomina','comision_tpv','comision_online','merma','pagos_servicio'
      ));
  end if;
end
$$;

create index if not exists idx_gastos_fecha
  on public.gastos (fecha);
create index if not exists idx_gastos_categoria
  on public.gastos (categoria);
create index if not exists idx_gastos_eliminado_fecha
  on public.gastos (fecha)
  where eliminado_at is null;
create unique index if not exists uq_gastos_derivado
  on public.gastos (origen, ref_id)
  where origen <> 'manual' and eliminado_at is null;

alter table public.gastos enable row level security;
revoke all on table public.gastos from public;
revoke all on table public.gastos from anon, authenticated;

-- ── 2. Claves de configuracion (9.2) ────────────────────────────────────────
-- fecha_inicio / saldo_inicial VACÍAS a propósito. El flujo se queda en
-- estado vacío hasta que el dueño las ponga en Metas y Precios → Finanzas.
insert into public.configuracion (clave, valor)
values
  ('finanzas_fecha_inicio', ''),
  ('finanzas_saldo_inicial', ''),
  ('finanzas_sin_compra_meses', ''),
  ('comision_tpv_pct', '3.5'),
  ('comision_online_pct', '25'),
  ('carga_patronal_pct', '30'),
  ('dias_operativos_mes', '30')
on conflict (clave) do nothing;

-- ── 3. Escritura admin de claves financieras ────────────────────────────────
create or replace function public.admin_upsert_configuracion_finanzas(
  p_session_token uuid,
  p_clave         text,
  p_valor         text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  k text := trim(coalesce(p_clave, ''));
  v text := trim(coalesce(p_valor, ''));
begin
  v_actor := public.fn_require_admin(p_session_token);

  if k not in (
    'finanzas_fecha_inicio',
    'finanzas_saldo_inicial',
    'finanzas_sin_compra_meses',
    'comision_tpv_pct',
    'comision_online_pct',
    'carga_patronal_pct',
    'dias_operativos_mes'
  ) then
    return jsonb_build_object('success', false, 'error', 'Clave de finanzas no permitida');
  end if;

  if k = 'finanzas_fecha_inicio' and v <> '' then
    if v !~ '^\d{4}-\d{2}-\d{2}$' then
      return jsonb_build_object('success', false, 'error', 'fecha_inicio debe ser YYYY-MM-DD');
    end if;
    begin
      perform v::date;
    exception when others then
      return jsonb_build_object('success', false, 'error', 'fecha_inicio inválida');
    end;
  end if;

  if k = 'finanzas_saldo_inicial' and v <> '' then
    begin
      if v::numeric < 0 then
        return jsonb_build_object('success', false, 'error', 'saldo_inicial no puede ser negativo');
      end if;
    exception when others then
      return jsonb_build_object('success', false, 'error', 'saldo_inicial debe ser un número');
    end;
  end if;

  insert into public.configuracion (clave, valor)
  values (k, v)
  on conflict (clave) do update
    set valor = excluded.valor;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'upsert_config_finanzas',
      'configuracion',
      k,
      jsonb_build_object('clave', k, 'valor', v)::text
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'clave', k, 'valor', v);
end;
$$;

grant execute on function public.admin_upsert_configuracion_finanzas(uuid, text, text)
  to anon, authenticated;

create or replace function public.admin_marcar_periodo_sin_compra(
  p_session_token uuid,
  p_anio_mes      text,
  p_sin_compra    boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_mes   text := substring(trim(coalesce(p_anio_mes, '')) from 1 for 7);
  v_cur   text;
  v_arr   text[];
  v_next  text;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if v_mes !~ '^\d{4}-\d{2}$' then
    return jsonb_build_object('success', false, 'error', 'Mes inválido (YYYY-MM)');
  end if;

  select coalesce(valor, '') into v_cur
  from public.configuracion
  where clave = 'finanzas_sin_compra_meses';

  v_arr := string_to_array(v_cur, ',');
  v_arr := array(
    select distinct trim(x)
    from unnest(coalesce(v_arr, array[]::text[])) as x
    where trim(x) ~ '^\d{4}-\d{2}$'
  );

  if coalesce(p_sin_compra, false) then
    if not (v_mes = any (v_arr)) then
      v_arr := array_append(v_arr, v_mes);
    end if;
  else
    v_arr := array(
      select x from unnest(v_arr) as x where x <> v_mes
    );
  end if;

  select string_agg(x, ',' order by x) into v_next
  from unnest(v_arr) as x;

  v_next := coalesce(v_next, '');

  insert into public.configuracion (clave, valor)
  values ('finanzas_sin_compra_meses', v_next)
  on conflict (clave) do update
    set valor = excluded.valor;

  return jsonb_build_object(
    'success', true,
    'anio_mes', v_mes,
    'sin_compra', coalesce(p_sin_compra, false),
    'meses', v_next
  );
end;
$$;

grant execute on function public.admin_marcar_periodo_sin_compra(uuid, text, boolean)
  to anon, authenticated;

-- ── 4. RPCs de gastos ───────────────────────────────────────────────────────
create or replace function public.admin_registrar_gasto(
  p_session_token uuid,
  p_gasto         jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor     bigint;
  v_g         jsonb := coalesce(p_gasto, '{}'::jsonb);
  v_fecha     date;
  v_cat       text;
  v_concepto  text;
  v_monto     numeric;
  v_afecta    boolean;
  v_id        bigint;
  v_row       jsonb;
begin
  v_actor := public.fn_require_admin(p_session_token);

  begin
    v_fecha := coalesce(nullif(v_g->>'fecha', '')::date,
                        (now() at time zone 'America/Mexico_City')::date);
  exception when others then
    return jsonb_build_object('success', false, 'error', 'Fecha inválida');
  end;

  v_cat := lower(trim(coalesce(v_g->>'categoria', '')));
  if v_cat not in (
    'renta','nomina','servicios','comisiones','mermas','mantenimiento',
    'publicidad','insumos','seguros','licencias','impuestos','financieros',
    'ajuste_redondeo','compra_inventario','otros'
  ) then
    return jsonb_build_object('success', false, 'error', 'Categoría inválida');
  end if;

  v_concepto := trim(coalesce(v_g->>'concepto', ''));
  if v_concepto = '' then
    return jsonb_build_object('success', false, 'error', 'Concepto requerido');
  end if;

  begin
    v_monto := round(coalesce((v_g->>'monto')::numeric, 0), 2);
  exception when others then
    return jsonb_build_object('success', false, 'error', 'Monto inválido');
  end;
  if v_monto <= 0 then
    return jsonb_build_object('success', false, 'error', 'El monto debe ser mayor a 0');
  end if;

  -- El servidor manda: comprar inventario no es pérdida del P&L.
  if v_cat = 'compra_inventario' then
    v_afecta := false;
  else
    v_afecta := coalesce((v_g->>'afecta_pl')::boolean, true);
  end if;

  insert into public.gastos (
    fecha, categoria, subcategoria, concepto, monto,
    origen, ref_id, es_recurrente, periodicidad, proveedor,
    metodo_pago, deducible, comprobante_url, registrado_por, notas, afecta_pl
  ) values (
    v_fecha,
    v_cat,
    nullif(trim(coalesce(v_g->>'subcategoria', '')), ''),
    v_concepto,
    v_monto,
    'manual',
    null,
    coalesce((v_g->>'es_recurrente')::boolean, false),
    nullif(trim(coalesce(v_g->>'periodicidad', '')), ''),
    nullif(trim(coalesce(v_g->>'proveedor', '')), ''),
    nullif(trim(coalesce(v_g->>'metodo_pago', '')), ''),
    coalesce((v_g->>'deducible')::boolean, true),
    nullif(trim(coalesce(v_g->>'comprobante_url', '')), ''),
    v_actor,
    nullif(trim(coalesce(v_g->>'notas', '')), ''),
    v_afecta
  )
  returning id into v_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'registrar_gasto',
      'gastos',
      v_id::text,
      jsonb_build_object('categoria', v_cat, 'monto', v_monto, 'afecta_pl', v_afecta)::text
    );
  exception when others then null;
  end;

  select jsonb_build_object(
    'id', g.id,
    'fecha', g.fecha,
    'categoria', g.categoria,
    'subcategoria', g.subcategoria,
    'concepto', g.concepto,
    'monto', g.monto,
    'origen', g.origen,
    'es_recurrente', g.es_recurrente,
    'periodicidad', g.periodicidad,
    'proveedor', g.proveedor,
    'metodo_pago', g.metodo_pago,
    'afecta_pl', g.afecta_pl,
    'notas', g.notas,
    'created_at', g.created_at
  ) into v_row
  from public.gastos g
  where g.id = v_id;

  return jsonb_build_object('success', true, 'gasto', v_row);
end;
$$;

grant execute on function public.admin_registrar_gasto(uuid, jsonb)
  to anon, authenticated;

create or replace function public.admin_listar_gastos(
  p_session_token uuid,
  p_desde         date default null,
  p_hasta         date default null,
  p_categoria     text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_desde date;
  v_hasta date;
  v_cat   text := nullif(lower(trim(coalesce(p_categoria, ''))), '');
begin
  perform public.fn_require_admin(p_session_token);

  v_hasta := coalesce(p_hasta, (now() at time zone 'America/Mexico_City')::date);
  v_desde := coalesce(p_desde, v_hasta - 90);

  return jsonb_build_object(
    'desde', v_desde,
    'hasta', v_hasta,
    'gastos', coalesce((
      select jsonb_agg(row_to_json(x)::jsonb order by x.fecha desc, x.id desc)
      from (
        select
          g.id,
          g.fecha,
          g.categoria,
          g.subcategoria,
          g.concepto,
          g.monto,
          g.origen,
          g.es_recurrente,
          g.periodicidad,
          g.proveedor,
          g.metodo_pago,
          g.afecta_pl,
          g.notas,
          g.created_at
        from public.gastos g
        where g.eliminado_at is null
          and g.fecha >= v_desde
          and g.fecha <= v_hasta
          and (v_cat is null or g.categoria = v_cat)
      ) x
    ), '[]'::jsonb)
  );
end;
$$;

grant execute on function public.admin_listar_gastos(uuid, date, date, text)
  to anon, authenticated;

create or replace function public.admin_eliminar_gasto(
  p_session_token uuid,
  p_id            bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_n     int;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_id is null then
    return jsonb_build_object('success', false, 'error', 'Id requerido');
  end if;

  update public.gastos
     set eliminado_at = now()
   where id = p_id
     and eliminado_at is null;

  get diagnostics v_n = row_count;
  if v_n = 0 then
    return jsonb_build_object('success', false, 'error', 'Gasto no encontrado');
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'eliminar_gasto',
      'gastos',
      p_id::text,
      '{}'::text
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'id', p_id);
end;
$$;

grant execute on function public.admin_eliminar_gasto(uuid, bigint)
  to anon, authenticated;

commit;
