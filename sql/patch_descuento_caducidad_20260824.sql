-- Motor de descuento por caducidad: tablas + RPCs.
-- No toca productos.precio ni descuento_pct. No agrega controlado/frío/canje.
-- Ejecutar en Supabase SQL Editor. Idempotente.

begin;

create table if not exists public.propuestas_descuento_caducidad (
  id                    bigserial primary key,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  lote_id               bigint not null references public.lotes(id),
  producto_id           bigint not null references public.productos(id),
  fecha_job             date not null,
  fase                  integer,
  estado                text not null,
  motivo                text,
  fecha_caducidad       date,
  dias_restantes        integer,
  existencia            integer not null default 0,
  costo_unitario        numeric(12,2),
  pvp                   numeric(12,2),
  precio_propuesto      numeric(12,2),
  precio_piso           numeric(12,2),
  descuento_escalon     numeric(8,4),
  descuento_efectivo    numeric(8,6),
  margen_resultante     numeric(8,6),
  perdida_pieza         numeric(12,2),
  capital_en_riesgo     numeric(14,2),
  capital_recuperable   numeric(14,2),
  vigencia_desde        date,
  vigencia_hasta        date,
  existencia_al_aplicar integer,
  texto_etiqueta        text,
  numero_lote           text,
  nombre                text,
  sku                   text
);

create unique index if not exists propuestas_caducidad_una_pendiente
  on public.propuestas_descuento_caducidad (lote_id)
  where estado = 'PENDIENTE';

create unique index if not exists propuestas_caducidad_pendiente_lote_dia
  on public.propuestas_descuento_caducidad (lote_id, fecha_job)
  where estado = 'PENDIENTE';

create index if not exists propuestas_caducidad_estado_riesgo
  on public.propuestas_descuento_caducidad (estado, capital_en_riesgo desc);

create index if not exists propuestas_caducidad_lote
  on public.propuestas_descuento_caducidad (lote_id, estado);

create table if not exists public.bitacora_descuento_caducidad (
  id                 bigserial primary key,
  created_at         timestamptz not null default now(),
  propuesta_id       bigint references public.propuestas_descuento_caducidad(id),
  lote_id            bigint,
  actor_id           bigint,
  accion             text not null,
  precio_anterior    numeric(12,2),
  precio_nuevo       numeric(12,2),
  fase               integer,
  descuento_efectivo numeric(8,6),
  motivo             text
);

create or replace function public.trg_bitacora_descuento_caducidad_inmutable()
returns trigger
language plpgsql
as $$
begin
  raise exception 'bitacora_descuento_caducidad es append-only';
end;
$$;

drop trigger if exists trg_bitacora_descuento_caducidad_no_upd on public.bitacora_descuento_caducidad;
create trigger trg_bitacora_descuento_caducidad_no_upd
  before update or delete on public.bitacora_descuento_caducidad
  for each row
  execute function public.trg_bitacora_descuento_caducidad_inmutable();

alter table public.propuestas_descuento_caducidad enable row level security;
alter table public.bitacora_descuento_caducidad enable row level security;
revoke all on table public.propuestas_descuento_caducidad from anon, authenticated;
revoke all on table public.bitacora_descuento_caducidad from anon, authenticated;

create or replace function public.admin_listar_propuestas_caducidad(
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
    select jsonb_agg(row_js order by riesgo desc, id)
    from (
      select jsonb_build_object(
        'id', p.id,
        'lote_id', p.lote_id,
        'producto_id', p.producto_id,
        'fecha_job', p.fecha_job,
        'fase', p.fase,
        'estado', p.estado,
        'motivo', p.motivo,
        'fecha_caducidad', p.fecha_caducidad,
        'dias_restantes', p.dias_restantes,
        'existencia', p.existencia,
        'costo_unitario', p.costo_unitario,
        'pvp', p.pvp,
        'precio_propuesto', p.precio_propuesto,
        'precio_piso', p.precio_piso,
        'descuento_escalon', p.descuento_escalon,
        'descuento_efectivo', p.descuento_efectivo,
        'margen_resultante', p.margen_resultante,
        'perdida_pieza', p.perdida_pieza,
        'capital_en_riesgo', p.capital_en_riesgo,
        'capital_recuperable', p.capital_recuperable,
        'vigencia_desde', p.vigencia_desde,
        'vigencia_hasta', p.vigencia_hasta,
        'texto_etiqueta', p.texto_etiqueta,
        'numero_lote', p.numero_lote,
        'nombre', p.nombre,
        'sku', p.sku,
        'created_at', p.created_at
      ) as row_js,
      coalesce(p.capital_en_riesgo, 0) as riesgo,
      p.id
      from public.propuestas_descuento_caducidad p
      where (
        p_estado is null or p_estado = 'TODAS'
        or p.estado = p_estado
      )
    ) s
  ), '[]'::jsonb);
end;
$$;

create or replace function public.admin_aprobar_propuestas_caducidad(
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
  v_row public.propuestas_descuento_caducidad%rowtype;
  v_precio numeric;
  v_desc numeric;
  v_margen numeric;
  v_n int := 0;
  v_hoy date := (timezone('America/Mexico_City', now()))::date;
begin
  v_actor := public.fn_require_admin(p_session_token);

  foreach v_id in array coalesce(p_ids, array[]::bigint[]) loop
    select * into v_row
    from public.propuestas_descuento_caducidad
    where id = v_id
    for update;
    if not found then
      continue;
    end if;
    if v_row.estado <> 'PENDIENTE' then
      continue;
    end if;

    v_precio := coalesce(p_precio, v_row.precio_propuesto);
    if v_row.precio_piso is not null and v_precio < v_row.precio_piso then
      v_precio := v_row.precio_piso;
    end if;
    if v_row.pvp is not null and v_precio > v_row.pvp then
      v_precio := v_row.pvp;
    end if;
    v_precio := round(v_precio, 2);
    v_desc := case when coalesce(v_row.pvp, 0) > 0
      then 1 - (v_precio / v_row.pvp) else 0 end;
    v_margen := case when v_precio > 0
      then (v_precio - coalesce(v_row.costo_unitario, 0)) / v_precio else 0 end;

    update public.propuestas_descuento_caducidad
       set estado = 'APROBADA',
           updated_at = now(),
           precio_propuesto = v_precio,
           descuento_efectivo = v_desc,
           margen_resultante = v_margen,
           perdida_pieza = greatest(0, coalesce(costo_unitario, 0) - v_precio),
           capital_recuperable = round(existencia * v_precio, 2),
           vigencia_desde = v_hoy,
           vigencia_hasta = coalesce(vigencia_hasta, fecha_caducidad - 1),
           existencia_al_aplicar = existencia,
           texto_etiqueta = concat_ws(
             E'\n',
             'PRECIO ESPECIAL',
             coalesce(nombre, ''),
             'Antes $' || to_char(coalesce(pvp, 0), 'FM9999990.00')
               || '  →  Ahora $' || to_char(v_precio, 'FM9999990.00'),
             'Ahorra ' || to_char(round(v_desc * 100, 1), 'FM990.0') || '%',
             'Caduca: ' || to_char(fecha_caducidad, 'MM/YYYY')
           )
     where id = v_id;

    insert into public.bitacora_descuento_caducidad (
      propuesta_id, lote_id, actor_id, accion,
      precio_anterior, precio_nuevo, fase, descuento_efectivo, motivo
    ) values (
      v_id, v_row.lote_id, v_actor,
      case when p_precio is not null then 'EDITAR_APROBAR' else 'APROBAR' end,
      v_row.pvp, v_precio, v_row.fase, v_desc, v_row.motivo
    );
    v_n := v_n + 1;
  end loop;

  return jsonb_build_object('success', true, 'aprobadas', v_n);
end;
$$;

create or replace function public.admin_rechazar_propuestas_caducidad(
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
  v_row public.propuestas_descuento_caducidad%rowtype;
  v_n int := 0;
begin
  v_actor := public.fn_require_admin(p_session_token);

  foreach v_id in array coalesce(p_ids, array[]::bigint[]) loop
    select * into v_row
    from public.propuestas_descuento_caducidad
    where id = v_id
    for update;
    if not found or v_row.estado <> 'PENDIENTE' then
      continue;
    end if;

    update public.propuestas_descuento_caducidad
       set estado = 'RECHAZADA', updated_at = now()
     where id = v_id;

    insert into public.bitacora_descuento_caducidad (
      propuesta_id, lote_id, actor_id, accion,
      precio_anterior, precio_nuevo, fase, descuento_efectivo, motivo
    ) values (
      v_id, v_row.lote_id, v_actor, 'RECHAZAR',
      v_row.pvp, v_row.precio_propuesto, v_row.fase,
      v_row.descuento_efectivo, v_row.motivo
    );
    v_n := v_n + 1;
  end loop;

  return jsonb_build_object('success', true, 'rechazadas', v_n);
end;
$$;

grant execute on function public.admin_listar_propuestas_caducidad(uuid, text) to anon, authenticated;
grant execute on function public.admin_aprobar_propuestas_caducidad(uuid, bigint[], numeric) to anon, authenticated;
grant execute on function public.admin_rechazar_propuestas_caducidad(uuid, bigint[]) to anon, authenticated;

create unique index if not exists propuestas_caducidad_alerta_dia
  on public.propuestas_descuento_caducidad (lote_id, estado, fecha_job)
  where estado not in ('PENDIENTE', 'APROBADA', 'RECHAZADA', 'VENCIDA');

create or replace function public.job_rotacion_mensual_caducidad()
returns jsonb
language sql
security definer
set search_path = public, pg_temp
as $$
  select coalesce(jsonb_object_agg(producto_id::text, rot), '{}'::jsonb)
  from (
    select pi.producto_id,
           (sum(pi.cantidad)::numeric / 3.0) as rot
      from public.pedido_items pi
      join public.pedidos p on p.id = pi.pedido_id
     where p.estado = 'completado'
       and p.created_at >= ((timezone('America/Mexico_City', now()))::date - 90)
     group by pi.producto_id
  ) s;
$$;

create or replace function public.job_vencer_propuestas_caducidad()
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_n int;
  v_hoy date := (timezone('America/Mexico_City', now()))::date;
begin
  update public.propuestas_descuento_caducidad
     set estado = 'VENCIDA', updated_at = now()
   where estado = 'APROBADA'
     and vigencia_hasta is not null
     and vigencia_hasta < v_hoy;
  get diagnostics v_n = row_count;
  return v_n;
end;
$$;

revoke all on function public.job_rotacion_mensual_caducidad() from public, anon, authenticated;
revoke all on function public.job_vencer_propuestas_caducidad() from public, anon, authenticated;
grant execute on function public.job_rotacion_mensual_caducidad() to service_role;
grant execute on function public.job_vencer_propuestas_caducidad() to service_role;

commit;
