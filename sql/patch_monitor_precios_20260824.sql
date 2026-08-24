-- Monitor de precios de referencia.
-- Ejecutar en Supabase SQL Editor. Idempotente.
-- No inventa precios. No cambia productos.precio (solo el RPC de aprobar).

begin;

-- ── Fuentes ──────────────────────────────────────────────────────────────
insert into public.fuentes_precio (id, nombre, tipo, metodo, notas) values
  ('lista_distribuidor', 'Lista de distribuidor (CSV)', 'compra', 'import_archivo',
   'CSV/Excel que cargas. No es benchmark de venta al público.'),
  ('profeco_qqp', 'PROFECO — Quién es Quién en los Precios', 'venta', 'job_api',
   'Dataset oficial datos.profeco.gob.mx / qqp.profeco.gob.mx'),
  ('datos_gob_patente', 'Catálogo datos.gob.mx — medicamentos de patente', 'venta', 'import_archivo',
   'CSV oficial de catalogo.datos.gob.mx')
on conflict (id) do update set
  nombre = excluded.nombre,
  tipo = excluded.tipo,
  metodo = excluded.metodo,
  notas = excluded.notas;

-- ── Capturas crudas (antes del match) ────────────────────────────────────
create table if not exists public.capturas_precio (
  id                    bigserial primary key,
  created_at            timestamptz not null default now(),
  import_id             bigint references public.importaciones_referencia (id) on delete set null,
  fuente                text not null references public.fuentes_precio (id),
  tipo                  text not null check (tipo in ('compra', 'venta')),
  nombre_crudo          text not null,
  precio                numeric(12,2) not null check (precio >= 0),
  moneda                text not null default 'MXN',
  url_origen            text not null,
  fecha_captura         timestamptz not null,
  ciudad                text,
  region                text,
  gtin_fuente           text,
  sku_externo           text,
  sustancia_activa      text,
  concentracion_valor   numeric,
  concentracion_unidad  text,
  forma_farmaceutica    text,
  piezas_por_empaque    integer,
  marca                 text,
  precio_unitario       numeric(12,4),
  estado_norm           text not null check (estado_norm in ('NORMALIZADO', 'NO_NORMALIZABLE')),
  html_crudo_path       text,
  huella                text not null unique
);

create index if not exists idx_capturas_fuente_fecha
  on public.capturas_precio (fuente, fecha_captura desc);
create index if not exists idx_capturas_gtin
  on public.capturas_precio (gtin_fuente)
  where gtin_fuente is not null and gtin_fuente <> '';

-- ── Caché de emparejamiento ──────────────────────────────────────────────
create table if not exists public.mapeo_sku_fuente (
  id                         bigserial primary key,
  created_at                 timestamptz not null default now(),
  updated_at                 timestamptz not null default now(),
  producto_id                bigint not null references public.productos (id) on delete cascade,
  sku                        text not null,
  fuente                     text not null references public.fuentes_precio (id),
  captura_huella             text not null,
  gtin_nuestro               text,
  gtin_fuente                text,
  indice_elegido             integer,
  confianza                  numeric(4,3) not null,
  razon                      text,
  metodo                     text not null check (metodo in ('GTIN', 'MODELO', 'MANUAL')),
  estado                     text not null
    check (estado in ('ACEPTADO', 'POR_VERIFICAR', 'SIN_MAPEO', 'INVALIDADO')),
  descripcion_producto_hash  text not null,
  modelo                     text,
  invalidado_en              timestamptz,
  invalidado_por             text,
  unique (producto_id, fuente, captura_huella)
);

create index if not exists idx_mapeo_estado
  on public.mapeo_sku_fuente (estado) where estado = 'POR_VERIFICAR';
create index if not exists idx_mapeo_sku
  on public.mapeo_sku_fuente (sku, fuente);

-- ── Extender historial por fuente ────────────────────────────────────────
alter table public.producto_precios_referencia
  add column if not exists precio_unitario numeric(12,4),
  add column if not exists piezas_por_empaque integer,
  add column if not exists captura_id bigint references public.capturas_precio (id) on delete set null,
  add column if not exists mapeo_id bigint references public.mapeo_sku_fuente (id) on delete set null,
  add column if not exists url_origen text,
  add column if not exists fecha_captura timestamptz,
  add column if not exists estado text not null default 'VIGENTE',
  add column if not exists delta_vs_anterior numeric;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.producto_precios_referencia'::regclass
      and conname = 'ppr_estado_check'
  ) then
    alter table public.producto_precios_referencia
      add constraint ppr_estado_check
      check (estado in ('VIGENTE', 'ANOMALIA_POR_REVISAR', 'DESCARTADA'));
  end if;
end $$;

do $$
declare
  cname text;
begin
  select conname into cname
  from pg_constraint
  where conrelid = 'public.producto_precios_referencia'::regclass
    and contype = 'c'
    and pg_get_constraintdef(oid) ilike '%origen%'
    and conname <> 'ppr_estado_check';
  if cname is not null then
    execute format('alter table public.producto_precios_referencia drop constraint %I', cname);
  end if;
end $$;

alter table public.producto_precios_referencia
  add constraint producto_precios_referencia_origen_check
  check (origen in ('import_csv', 'job_vtex', 'manual', 'monitor_precios'));

-- ── Snapshot de mediana vigente (venta) ──────────────────────────────────
create table if not exists public.referencia_vigente (
  producto_id                 bigint primary key references public.productos (id) on delete cascade,
  updated_at                  timestamptz not null default now(),
  sku                         text,
  precio_unitario_mediana     numeric(12,4) not null,
  precio_unitario_min         numeric(12,4),
  precio_unitario_max         numeric(12,4),
  n_fuentes                   integer not null default 0,
  fecha_dato_mas_reciente     timestamptz
);

-- ── Cola de PVP ──────────────────────────────────────────────────────────
create table if not exists public.propuestas_precio (
  id                          bigserial primary key,
  created_at                  timestamptz not null default now(),
  updated_at                  timestamptz not null default now(),
  fecha_job                   date not null default (timezone('America/Mexico_City', now()))::date,
  producto_id                 bigint not null references public.productos (id),
  sku                         text,
  nombre                      text,
  precio_actual               numeric(12,2),
  costo_usado                 numeric(12,2),
  piezas_por_empaque          integer,
  referencia_unitaria         numeric(12,4),
  referencia_caja             numeric(12,2),
  n_fuentes                   integer,
  fecha_dato_mas_reciente     timestamptz,
  factor_posicionamiento      numeric,
  margen_minimo_categoria     numeric,
  piso                        numeric(12,2),
  pmvp                        numeric(12,2),
  pvp_sugerido                numeric(12,2) not null,
  margen_resultante           numeric,
  impacto_estimado            numeric,
  umbral_motivo               text,
  estado                      text not null default 'PENDIENTE'
    check (estado in ('PENDIENTE', 'APROBADA', 'RECHAZADA', 'EDITADA', 'VENCIDA')),
  precio_aprobado             numeric(12,2)
);

create unique index if not exists propuestas_precio_una_pendiente
  on public.propuestas_precio (producto_id)
  where estado = 'PENDIENTE';

create index if not exists propuestas_precio_estado
  on public.propuestas_precio (estado, created_at desc);

-- ── Bitácora append-only ─────────────────────────────────────────────────
create table if not exists public.bitacora_precios (
  id                   bigserial primary key,
  created_at           timestamptz not null default now(),
  propuesta_id         bigint references public.propuestas_precio (id),
  producto_id          bigint,
  actor_id             bigint,
  accion               text not null,
  precio_anterior      numeric(12,2),
  precio_nuevo         numeric(12,2),
  referencia_unitaria  numeric(12,4),
  n_fuentes            integer,
  motivo               text
);

create or replace function public.trg_bitacora_precios_inmutable()
returns trigger
language plpgsql
as $$
begin
  raise exception 'bitacora_precios es append-only';
end;
$$;

drop trigger if exists trg_bitacora_precios_no_upd on public.bitacora_precios;
create trigger trg_bitacora_precios_no_upd
  before update or delete on public.bitacora_precios
  for each row
  execute function public.trg_bitacora_precios_inmutable();

-- ── Config ───────────────────────────────────────────────────────────────
insert into public.configuracion (clave, valor)
values
  ('monitor_precios_dias_vigencia', '30'),
  ('monitor_precios_umbral_anomalia', '0.40'),
  ('monitor_precios_umbral_pct', '0.05'),
  ('monitor_precios_umbral_pesos', '10'),
  ('monitor_precios_factor', '0.98'),
  ('monitor_precios_margen_patente', '0.12'),
  ('monitor_precios_margen_generico', '0.25'),
  ('monitor_precios_margen_otc', '0.30')
on conflict (clave) do nothing;

-- ── RLS ──────────────────────────────────────────────────────────────────
alter table public.capturas_precio enable row level security;
alter table public.mapeo_sku_fuente enable row level security;
alter table public.referencia_vigente enable row level security;
alter table public.propuestas_precio enable row level security;
alter table public.bitacora_precios enable row level security;

revoke all on table public.capturas_precio from anon, authenticated;
revoke all on table public.mapeo_sku_fuente from anon, authenticated;
revoke all on table public.referencia_vigente from anon, authenticated;
revoke all on table public.propuestas_precio from anon, authenticated;
revoke all on table public.bitacora_precios from anon, authenticated;

-- ── RPCs admin ───────────────────────────────────────────────────────────
create or replace function public.admin_listar_propuestas_precio(
  p_session_token uuid,
  p_estado        text default 'PENDIENTE'
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  return coalesce((
    select jsonb_agg(row_js order by abs(coalesce(impacto, 0)) desc, id)
    from (
      select jsonb_build_object(
        'id', p.id,
        'producto_id', p.producto_id,
        'sku', p.sku,
        'nombre', p.nombre,
        'precio_actual', p.precio_actual,
        'costo_usado', p.costo_usado,
        'piezas_por_empaque', p.piezas_por_empaque,
        'referencia_unitaria', p.referencia_unitaria,
        'referencia_caja', p.referencia_caja,
        'n_fuentes', p.n_fuentes,
        'fecha_dato_mas_reciente', p.fecha_dato_mas_reciente,
        'piso', p.piso,
        'pmvp', p.pmvp,
        'pvp_sugerido', p.pvp_sugerido,
        'margen_resultante', p.margen_resultante,
        'impacto_estimado', p.impacto_estimado,
        'estado', p.estado,
        'precio_aprobado', p.precio_aprobado,
        'fecha_job', p.fecha_job,
        'created_at', p.created_at,
        'costo_compra', coalesce(uc.precio, p.costo_usado),
        'proveedor_compra', coalesce(
          nullif(btrim(uc.nombre_fuente), ''),
          nullif(btrim(lote_prov.nombre), '')
        )
      ) as row_js,
      p.impacto_estimado as impacto,
      p.id
      from public.propuestas_precio p
      left join public.producto_precios_referencia_actual uc
        on uc.producto_id = p.producto_id
       and uc.fuente = 'ultima_compra'
      left join lateral (
        select pv.nombre
        from public.lotes l
        left join public.proveedores pv on pv.id = l.proveedor_id
        where l.producto_id = p.producto_id
          and coalesce(l.activo, true)
          and nullif(btrim(pv.nombre), '') is not null
        order by (coalesce(l.cantidad_actual, 0) > 0) desc,
                 l.cantidad_actual desc nulls last,
                 l.created_at desc nulls last
        limit 1
      ) lote_prov on true
      where (
        p_estado is null or p_estado = 'TODAS'
        or p.estado = p_estado
      )
    ) s
  ), '[]'::jsonb);
end;
$$;

create or replace function public.admin_aprobar_propuestas_precio(
  p_session_token uuid,
  p_ids           bigint[],
  p_precio        numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_id bigint;
  v_row public.propuestas_precio%rowtype;
  v_precio numeric;
  v_n int := 0;
  v_accion text;
begin
  v_actor := public.fn_require_admin(p_session_token);

  foreach v_id in array coalesce(p_ids, array[]::bigint[]) loop
    select * into v_row
    from public.propuestas_precio
    where id = v_id
    for update;
    if not found or v_row.estado <> 'PENDIENTE' then
      continue;
    end if;

    v_precio := coalesce(p_precio, v_row.pvp_sugerido);
    if v_row.piso is not null and v_precio < v_row.piso then
      v_precio := v_row.piso;
    end if;
    if v_row.pmvp is not null and v_row.pmvp > 0 and v_precio > v_row.pmvp then
      v_precio := v_row.pmvp;
    end if;
    v_precio := round(v_precio, 2);
    v_accion := case when p_precio is not null then 'EDITAR' else 'APROBAR' end;

    update public.propuestas_precio
       set estado = case when p_precio is not null then 'EDITADA' else 'APROBADA' end,
           precio_aprobado = v_precio,
           updated_at = now()
     where id = v_id;

    update public.productos
       set precio = v_precio,
           price_updated_at = now()
     where id = v_row.producto_id;

    insert into public.productos_precio_historial (
      producto_id, precio_anterior, precio_nuevo, costo_usado,
      origen, notas
    ) values (
      v_row.producto_id, v_row.precio_actual, v_precio, v_row.costo_usado,
      'monitor_precios_aprobacion',
      coalesce(v_row.umbral_motivo, 'aprobacion_humana')
    );

    insert into public.bitacora_precios (
      propuesta_id, producto_id, actor_id, accion,
      precio_anterior, precio_nuevo, referencia_unitaria, n_fuentes, motivo
    ) values (
      v_id, v_row.producto_id, v_actor, v_accion,
      v_row.precio_actual, v_precio, v_row.referencia_unitaria, v_row.n_fuentes,
      v_row.umbral_motivo
    );
    v_n := v_n + 1;
  end loop;

  return jsonb_build_object('success', true, 'aprobadas', v_n);
end;
$$;

create or replace function public.admin_rechazar_propuestas_precio(
  p_session_token uuid,
  p_ids           bigint[]
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_id bigint;
  v_row public.propuestas_precio%rowtype;
  v_n int := 0;
begin
  v_actor := public.fn_require_admin(p_session_token);

  foreach v_id in array coalesce(p_ids, array[]::bigint[]) loop
    select * into v_row
    from public.propuestas_precio
    where id = v_id
    for update;
    if not found or v_row.estado <> 'PENDIENTE' then
      continue;
    end if;

    update public.propuestas_precio
       set estado = 'RECHAZADA', updated_at = now()
     where id = v_id;

    insert into public.bitacora_precios (
      propuesta_id, producto_id, actor_id, accion,
      precio_anterior, precio_nuevo, referencia_unitaria, n_fuentes, motivo
    ) values (
      v_id, v_row.producto_id, v_actor, 'RECHAZAR',
      v_row.precio_actual, v_row.pvp_sugerido, v_row.referencia_unitaria,
      v_row.n_fuentes, v_row.umbral_motivo
    );
    v_n := v_n + 1;
  end loop;

  return jsonb_build_object('success', true, 'rechazadas', v_n);
end;
$$;

create or replace function public.admin_listar_mapeos_monitor(
  p_session_token uuid,
  p_estado        text default 'POR_VERIFICAR'
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', m.id,
      'sku', m.sku,
      'producto_id', m.producto_id,
      'nombre', pr.nombre,
      'fuente', m.fuente,
      'confianza', m.confianza,
      'razon', m.razon,
      'metodo', m.metodo,
      'estado', m.estado,
      'gtin_nuestro', m.gtin_nuestro,
      'gtin_fuente', m.gtin_fuente,
      'created_at', m.created_at
    ) order by m.confianza desc, m.id)
    from public.mapeo_sku_fuente m
    left join public.productos pr on pr.id = m.producto_id
    where (
      p_estado is null or p_estado = 'TODAS'
      or m.estado = p_estado
    )
  ), '[]'::jsonb);
end;
$$;

create or replace function public.admin_decidir_mapeo_monitor(
  p_session_token uuid,
  p_id            bigint,
  p_accion        text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_row public.mapeo_sku_fuente%rowtype;
begin
  v_actor := public.fn_require_admin(p_session_token);
  if p_accion not in ('ACEPTAR', 'RECHAZAR') then
    raise exception 'accion_invalida';
  end if;

  select * into v_row from public.mapeo_sku_fuente where id = p_id for update;
  if not found then
    return jsonb_build_object('success', false, 'error', 'no_encontrado');
  end if;

  if p_accion = 'ACEPTAR' then
    update public.mapeo_sku_fuente
       set estado = 'ACEPTADO', metodo = 'MANUAL', updated_at = now()
     where id = p_id;
  else
    update public.mapeo_sku_fuente
       set estado = 'INVALIDADO',
           invalidado_en = now(),
           invalidado_por = v_actor::text,
           updated_at = now()
     where id = p_id;
  end if;

  return jsonb_build_object('success', true, 'id', p_id, 'accion', p_accion);
end;
$$;

create or replace function public.admin_listar_anomalias_monitor(
  p_session_token uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', r.id,
      'producto_id', r.producto_id,
      'nombre', pr.nombre,
      'sku', pr.sku,
      'fuente', r.fuente,
      'precio', r.precio,
      'precio_unitario', r.precio_unitario,
      'delta_vs_anterior', r.delta_vs_anterior,
      'fecha', r.fecha,
      'url_origen', r.url_origen,
      'nombre_fuente', r.nombre_fuente
    ) order by r.created_at desc)
    from public.producto_precios_referencia r
    left join public.productos pr on pr.id = r.producto_id
    where r.estado = 'ANOMALIA_POR_REVISAR'
  ), '[]'::jsonb);
end;
$$;

create or replace function public.admin_resolver_anomalia_monitor(
  p_session_token uuid,
  p_id            bigint,
  p_accion        text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  if p_accion not in ('ACEPTAR', 'DESCARTAR') then
    raise exception 'accion_invalida';
  end if;
  update public.producto_precios_referencia
     set estado = case when p_accion = 'ACEPTAR' then 'VIGENTE' else 'DESCARTADA' end
   where id = p_id
     and estado = 'ANOMALIA_POR_REVISAR';
  if not found then
    return jsonb_build_object('success', false, 'error', 'no_encontrado');
  end if;
  return jsonb_build_object('success', true, 'id', p_id, 'accion', p_accion);
end;
$$;

grant execute on function public.admin_listar_propuestas_precio(uuid, text) to anon, authenticated;
grant execute on function public.admin_aprobar_propuestas_precio(uuid, bigint[], numeric) to anon, authenticated;
grant execute on function public.admin_rechazar_propuestas_precio(uuid, bigint[]) to anon, authenticated;
grant execute on function public.admin_listar_mapeos_monitor(uuid, text) to anon, authenticated;
grant execute on function public.admin_decidir_mapeo_monitor(uuid, bigint, text) to anon, authenticated;
grant execute on function public.admin_listar_anomalias_monitor(uuid) to anon, authenticated;
grant execute on function public.admin_resolver_anomalia_monitor(uuid, bigint, text) to anon, authenticated;

commit;
