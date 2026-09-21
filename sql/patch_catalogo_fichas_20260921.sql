-- FARMACAPITAL — Fichas enriquecidas (monografías + producto_fichas + jobs)
-- 21-sep-2026. Idempotente. NO ejecuta nada en producción desde este PR.
-- Anon solo lee contenido publicado vía vista/RPC, sin fuentes internas.

begin;

create table if not exists public.monografias (
  id              bigserial primary key,
  clave           text not null,
  via             text not null
                  check (via in ('oral','topica','oftalmica','otica','nasal','vaginal','inyectable','inhalada')),
  contenido       jsonb not null,
  fuentes         jsonb not null default '[]'::jsonb,
  estado          text not null default 'borrador'
                  check (estado in ('borrador','en_revision','publicado','rechazado')),
  revisado_por    text,
  revisado_en     timestamptz,
  version         int not null default 1,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (clave, via)
);

create table if not exists public.producto_fichas (
  producto_id     integer primary key references public.productos(id) on delete cascade,
  tipo_ficha      text not null
                  check (tipo_ficha in ('medicamento','dermocosmetico','suplemento','cuidado_personal','material','equipo_medico')),
  monografia_id   bigint references public.monografias(id),
  contenido       jsonb not null default '{}'::jsonb,
  instructivo_url text,
  registro_sanitario text,
  fuentes         jsonb not null default '[]'::jsonb,
  estado          text not null default 'borrador'
                  check (estado in ('borrador','en_revision','publicado','rechazado')),
  revisado_por    text,
  revisado_en     timestamptz,
  updated_at      timestamptz not null default now()
);

create table if not exists public.enriquecimiento_jobs (
  id              bigserial primary key,
  producto_id     integer not null references public.productos(id) on delete cascade,
  tipo            text not null check (tipo in ('ficha','imagenes','ambos')),
  estado          text not null default 'pendiente'
                  check (estado in ('pendiente','procesando','listo_para_revision','error','descartado')),
  intentos        int not null default 0,
  error           text,
  resultado       jsonb,
  tokens          int not null default 0,
  busquedas       int not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create unique index if not exists ux_enriquecimiento_jobs_abierto
  on public.enriquecimiento_jobs (producto_id)
  where estado in ('pendiente','procesando','listo_para_revision');

create index if not exists idx_enriquecimiento_jobs_estado
  on public.enriquecimiento_jobs (estado, created_at);

create index if not exists idx_producto_fichas_estado
  on public.producto_fichas (estado);

create index if not exists idx_monografias_estado
  on public.monografias (estado);

-- Galería: trazabilidad. Las fotos actuales quedan aprobadas para no vaciar la tienda.
alter table public.producto_imagenes
  add column if not exists fuente_url text,
  add column if not exists licencia  text,
  add column if not exists aprobada  boolean not null default true;

alter table public.producto_imagenes
  drop constraint if exists producto_imagenes_origen_check;

alter table public.producto_imagenes
  add constraint producto_imagenes_origen_check
  check (origen in (
    'rappi','distribuidor','propia','gs1','otro',
    'fabricante','openfacts','ia_busqueda'
  ));

alter table public.monografias enable row level security;
alter table public.producto_fichas enable row level security;
alter table public.enriquecimiento_jobs enable row level security;

revoke all on public.monografias from anon, authenticated;
revoke all on public.producto_fichas from anon, authenticated;
revoke all on public.enriquecimiento_jobs from anon, authenticated;

-- Vista pública: solo publicado, sin fuentes ni revisor.
create or replace view public.tienda_fichas_publicas
with (security_invoker = true)
as
select
  pf.producto_id,
  pf.tipo_ficha,
  pf.contenido,
  pf.instructivo_url,
  pf.registro_sanitario,
  pf.updated_at as ficha_updated_at,
  case when m.estado = 'publicado' then m.id else null end as monografia_id,
  case when m.estado = 'publicado' then m.clave else null end as monografia_clave,
  case when m.estado = 'publicado' then m.via else null end as monografia_via,
  case when m.estado = 'publicado' then m.contenido else null end as monografia_contenido
from public.producto_fichas pf
left join public.monografias m on m.id = pf.monografia_id
where pf.estado = 'publicado';

grant select on public.tienda_fichas_publicas to anon, authenticated;

-- RLS de la vista: security_invoker + tablas sin SELECT a anon = 0 filas directas.
-- El público usa la RPC security definer de abajo.

create or replace function public.tienda_ficha_producto(p_producto_id integer)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v jsonb;
begin
  select jsonb_build_object(
    'producto_id', pf.producto_id,
    'tipo_ficha', pf.tipo_ficha,
    'contenido', pf.contenido,
    'instructivo_url', pf.instructivo_url,
    'registro_sanitario', pf.registro_sanitario,
    'monografia', case
      when m.id is not null and m.estado = 'publicado' then jsonb_build_object(
        'id', m.id,
        'clave', m.clave,
        'via', m.via,
        'contenido', m.contenido
      )
      else null
    end
  )
  into v
  from public.producto_fichas pf
  left join public.monografias m on m.id = pf.monografia_id
  where pf.producto_id = p_producto_id
    and pf.estado = 'publicado';

  return v;
end;
$$;

comment on function public.tienda_ficha_producto(integer) is
  'Ficha publicada para la tienda. No expone fuentes ni revisado_por.';

grant execute on function public.tienda_ficha_producto(integer) to anon, authenticated;

-- Un solo job abierto por producto al dar de alta (no toca POS ni precios).
create or replace function public.trg_producto_enriquecimiento_job()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  insert into public.enriquecimiento_jobs (producto_id, tipo, estado)
  select new.id, 'ambos', 'pendiente'
  where not exists (
    select 1 from public.enriquecimiento_jobs j
    where j.producto_id = new.id
      and j.estado in ('pendiente','procesando','listo_para_revision')
  );
  return new;
end;
$$;

drop trigger if exists trg_producto_enriquecimiento_job on public.productos;
create trigger trg_producto_enriquecimiento_job
  after insert on public.productos
  for each row
  execute procedure public.trg_producto_enriquecimiento_job();

create or replace function public.admin_listar_fichas_revision(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  return coalesce((
    select jsonb_agg(row_to_json(x))
    from (
      select
        j.id,
        j.producto_id,
        j.tipo,
        j.estado,
        j.intentos,
        j.error,
        j.resultado,
        j.created_at,
        j.updated_at,
        p.nombre,
        p.sku,
        p.marca,
        p.codigo_barras,
        p.principio_activo,
        p.forma_farmaceutica,
        p.requiere_receta,
        pf.estado as ficha_estado,
        pf.revisado_por,
        pf.revisado_en
      from public.enriquecimiento_jobs j
      join public.productos p on p.id = j.producto_id
      left join public.producto_fichas pf on pf.producto_id = j.producto_id
      where j.estado in ('listo_para_revision','error','pendiente','procesando')
      order by
        case j.estado
          when 'listo_para_revision' then 0
          when 'error' then 1
          else 2
        end,
        j.updated_at desc
      limit 200
    ) x
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.admin_listar_fichas_revision(uuid) to anon, authenticated;

create or replace function public.admin_guardar_ficha_revision(
  p_session_token uuid,
  p_job_id bigint,
  p_accion text,
  p_payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_actor_nombre text;
  v_job public.enriquecimiento_jobs%rowtype;
  v_mono_id bigint;
  v_clave text;
  v_via text;
  v_tipo text;
begin
  v_actor := public.fn_require_admin(p_session_token);
  select coalesce(nullif(trim(nombre), ''), 'admin') into v_actor_nombre
  from public.usuarios where id = v_actor;

  select * into v_job from public.enriquecimiento_jobs where id = p_job_id;
  if not found then
    raise exception 'Job % no encontrado', p_job_id;
  end if;

  if p_accion = 'rechazar' then
    update public.enriquecimiento_jobs
      set estado = 'descartado',
          error = coalesce(p_payload->>'motivo', 'rechazado'),
          updated_at = now()
    where id = p_job_id;
    update public.producto_fichas
      set estado = 'rechazado',
          revisado_por = v_actor_nombre,
          revisado_en = now(),
          updated_at = now()
    where producto_id = v_job.producto_id;
    return jsonb_build_object('ok', true, 'accion', 'rechazar');
  end if;

  v_tipo := coalesce(p_payload->>'tipo_ficha', v_job.resultado->>'tipo_ficha', 'medicamento');
  v_clave := nullif(trim(coalesce(p_payload->'monografia'->>'clave', '')), '');
  v_via := nullif(trim(coalesce(p_payload->'monografia'->>'via', '')), '');

  if v_clave is not null and v_via is not null then
    insert into public.monografias (clave, via, contenido, fuentes, estado, revisado_por, revisado_en, updated_at)
    values (
      v_clave,
      v_via,
      coalesce(p_payload->'monografia'->'contenido', '{}'::jsonb),
      coalesce(p_payload->'monografia'->'fuentes', '[]'::jsonb),
      case when p_accion = 'publicar' then 'publicado' else 'borrador' end,
      case when p_accion = 'publicar' then v_actor_nombre else null end,
      case when p_accion = 'publicar' then now() else null end,
      now()
    )
    on conflict (clave, via) do update set
      contenido = excluded.contenido,
      fuentes = excluded.fuentes,
      estado = excluded.estado,
      revisado_por = excluded.revisado_por,
      revisado_en = excluded.revisado_en,
      version = public.monografias.version + 1,
      updated_at = now()
    returning id into v_mono_id;
  end if;

  insert into public.producto_fichas (
    producto_id, tipo_ficha, monografia_id, contenido, instructivo_url,
    registro_sanitario, fuentes, estado, revisado_por, revisado_en, updated_at
  ) values (
    v_job.producto_id,
    v_tipo,
    v_mono_id,
    coalesce(p_payload->'producto', '{}'::jsonb),
    nullif(p_payload->>'instructivo_url', ''),
    nullif(p_payload->>'registro_sanitario', ''),
    coalesce(p_payload->'fuentes', '[]'::jsonb),
    case when p_accion = 'publicar' then 'publicado' else 'borrador' end,
    case when p_accion = 'publicar' then v_actor_nombre else null end,
    case when p_accion = 'publicar' then now() else null end,
    now()
  )
  on conflict (producto_id) do update set
    tipo_ficha = excluded.tipo_ficha,
    monografia_id = coalesce(excluded.monografia_id, public.producto_fichas.monografia_id),
    contenido = excluded.contenido,
    instructivo_url = excluded.instructivo_url,
    registro_sanitario = excluded.registro_sanitario,
    fuentes = excluded.fuentes,
    estado = excluded.estado,
    revisado_por = excluded.revisado_por,
    revisado_en = excluded.revisado_en,
    updated_at = now();

  if p_accion = 'publicar' then
    if p_payload ? 'imagen_principal'
       and nullif(trim(coalesce(
         p_payload->'imagen_principal'->>'url_storage',
         p_payload->'imagen_principal'->>'url'
       )), '') is not null then
      update public.producto_imagenes
        set es_principal = false, updated_at = now()
      where producto_id = v_job.producto_id and es_principal is true;

      insert into public.producto_imagenes (
        producto_id, url, storage_path, origen, fuente_url, licencia, aprobada, es_principal, posicion
      ) values (
        v_job.producto_id,
        trim(coalesce(
          p_payload->'imagen_principal'->>'url_storage',
          p_payload->'imagen_principal'->>'url'
        )),
        nullif(trim(p_payload->'imagen_principal'->>'storage_path'), ''),
        case
          when coalesce(p_payload->'imagen_principal'->>'origen', '') in
            ('rappi','distribuidor','propia','gs1','otro','fabricante','openfacts','ia_busqueda')
          then p_payload->'imagen_principal'->>'origen'
          else 'ia_busqueda'
        end,
        nullif(trim(coalesce(
          p_payload->'imagen_principal'->>'fuente_url',
          p_payload->'imagen_principal'->>'url'
        )), ''),
        nullif(trim(p_payload->'imagen_principal'->>'licencia'), ''),
        true,
        true,
        coalesce((
          select max(posicion) from public.producto_imagenes
          where producto_id = v_job.producto_id
        ), 0) + 1
      )
      on conflict (producto_id, url) do update set
        origen = excluded.origen,
        fuente_url = excluded.fuente_url,
        licencia = excluded.licencia,
        aprobada = true,
        es_principal = true,
        storage_path = coalesce(excluded.storage_path, public.producto_imagenes.storage_path),
        updated_at = now();
    end if;

    update public.enriquecimiento_jobs
      set estado = 'descartado', updated_at = now()
    where id = p_job_id;
  else
    update public.enriquecimiento_jobs
      set resultado = coalesce(p_payload, resultado),
          estado = 'listo_para_revision',
          updated_at = now()
    where id = p_job_id;
  end if;

  return jsonb_build_object('ok', true, 'accion', p_accion, 'monografia_id', v_mono_id);
end;
$$;

grant execute on function public.admin_guardar_ficha_revision(uuid, bigint, text, jsonb)
  to anon, authenticated;

-- Lectura pública de imágenes: solo aprobadas (las actuales ya son true).
drop policy if exists "Lectura pública de imágenes de producto" on public.producto_imagenes;
create policy "Lectura pública de imágenes de producto"
  on public.producto_imagenes for select
  to anon, authenticated
  using (
    aprobada = true
    and exists (
      select 1 from public.productos p
      where p.id = producto_imagenes.producto_id
        and p.activo = true
    )
  );

commit;
