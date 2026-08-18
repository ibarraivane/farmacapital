-- FarmaCapital — Bonos opcionales + expediente de documentos de RH.
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.
--
-- 1) Flag configuracion.bonos_activos = '0' (apagado). El admin lo enciende
--    en Metas y Precios. Mientras esté en 0, Mi Día no muestra escalones.
-- 2) Bucket privado rh-documentos (sin políticas para anon: solo service_role).
-- 3) Tabla empleado_documentos + RPCs admin para listar / registrar / borrar.

begin;

insert into public.configuracion (clave, valor)
values ('bonos_activos', '0')
on conflict (clave) do nothing;


-- ── Storage: bucket privado ─────────────────────────────────────────────────

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'rh-documentos',
  'rh-documentos',
  false,
  10485760,
  array['application/pdf', 'image/jpeg', 'image/png', 'image/webp']::text[]
)
on conflict (id) do update set
  public = false,
  file_size_limit = 10485760,
  allowed_mime_types = array['application/pdf', 'image/jpeg', 'image/png', 'image/webp']::text[];

-- Por si quedó alguna política vieja: el bucket no se lee desde el cliente.
drop policy if exists "fc_rh_documentos_select" on storage.objects;
drop policy if exists "fc_rh_documentos_insert" on storage.objects;
drop policy if exists "fc_rh_documentos_update" on storage.objects;
drop policy if exists "fc_rh_documentos_delete" on storage.objects;


-- ── Tabla ───────────────────────────────────────────────────────────────────

create table if not exists public.empleado_documentos (
  id              bigserial primary key,
  empleado_id     bigint not null references public.empleados(id) on delete cascade,
  tipo            text not null,
  nombre_archivo  text not null,
  storage_path    text not null unique,
  mime_type       text,
  bytes           integer,
  notas           text,
  subido_por      bigint references public.usuarios(id) on delete set null,
  created_at      timestamptz not null default now(),
  constraint empleado_documentos_tipo_chk check (tipo in (
    'contrato', 'ine_frente', 'ine_reverso', 'domicilio',
    'curp', 'rfc', 'nss', 'clabe', 'foto', 'otro'
  ))
);

create index if not exists empleado_documentos_empleado_idx
  on public.empleado_documentos (empleado_id, tipo);

comment on table public.empleado_documentos is
  'Expediente de RH. Archivos en bucket privado rh-documentos; el vendedor no los ve.';

alter table public.empleado_documentos enable row level security;

revoke all on public.empleado_documentos from anon, authenticated;


-- ── RPCs admin ──────────────────────────────────────────────────────────────

create or replace function public.admin_listar_documentos_empleado(
  p_session_token uuid,
  p_empleado_id   bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);

  if p_empleado_id is null then
    raise exception 'Empleado requerido';
  end if;

  return coalesce((
    select jsonb_agg(row_js order by ord)
    from (
      select jsonb_build_object(
        'id', d.id,
        'empleado_id', d.empleado_id,
        'tipo', d.tipo,
        'nombre_archivo', d.nombre_archivo,
        'mime_type', d.mime_type,
        'bytes', d.bytes,
        'created_at', d.created_at
      ) as row_js,
      d.created_at as ord
      from public.empleado_documentos d
      where d.empleado_id = p_empleado_id
    ) q
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.admin_listar_documentos_empleado(uuid, bigint)
  to anon, authenticated;


create or replace function public.admin_registrar_documento_empleado(
  p_session_token  uuid,
  p_empleado_id    bigint,
  p_tipo           text,
  p_nombre_archivo text,
  p_storage_path   text,
  p_mime_type      text default null,
  p_bytes          integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_id    bigint;
  v_tipo  text;
begin
  v_actor := public.fn_require_admin(p_session_token);
  v_tipo := lower(trim(coalesce(p_tipo, '')));

  if p_empleado_id is null then
    raise exception 'Empleado requerido';
  end if;
  if not exists (select 1 from public.empleados e where e.id = p_empleado_id) then
    raise exception 'Empleado % no encontrado', p_empleado_id;
  end if;
  if v_tipo not in (
    'contrato', 'ine_frente', 'ine_reverso', 'domicilio',
    'curp', 'rfc', 'nss', 'clabe', 'foto', 'otro'
  ) then
    raise exception 'Tipo de documento inválido: %', p_tipo;
  end if;
  if coalesce(trim(p_nombre_archivo), '') = '' then
    raise exception 'Nombre de archivo requerido';
  end if;
  if coalesce(trim(p_storage_path), '') = '' then
    raise exception 'Ruta de storage requerida';
  end if;

  insert into public.empleado_documentos (
    empleado_id, tipo, nombre_archivo, storage_path, mime_type, bytes, subido_por
  ) values (
    p_empleado_id, v_tipo, trim(p_nombre_archivo), trim(p_storage_path),
    nullif(trim(coalesce(p_mime_type, '')), ''), p_bytes, v_actor
  )
  returning id into v_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'subir_documento_rh', 'empleado_documentos', v_id::text,
      jsonb_build_object('empleado_id', p_empleado_id, 'tipo', v_tipo)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'id', v_id);
end;
$$;

grant execute on function public.admin_registrar_documento_empleado(uuid, bigint, text, text, text, text, integer)
  to anon, authenticated;


-- Devuelve la ruta de storage. Lo usa la API con service_role, no el front.
create or replace function public.admin_documento_empleado_path(
  p_session_token uuid,
  p_documento_id  bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row public.empleado_documentos%rowtype;
begin
  perform public.fn_require_admin(p_session_token);

  select * into v_row
  from public.empleado_documentos
  where id = p_documento_id;

  if not found then
    raise exception 'Documento % no encontrado', p_documento_id;
  end if;

  return jsonb_build_object(
    'id', v_row.id,
    'empleado_id', v_row.empleado_id,
    'tipo', v_row.tipo,
    'nombre_archivo', v_row.nombre_archivo,
    'storage_path', v_row.storage_path,
    'mime_type', v_row.mime_type
  );
end;
$$;

grant execute on function public.admin_documento_empleado_path(uuid, bigint)
  to anon, authenticated, service_role;


create or replace function public.admin_eliminar_documento_empleado(
  p_session_token uuid,
  p_documento_id  bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_path  text;
  v_emp   bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);

  delete from public.empleado_documentos
  where id = p_documento_id
  returning storage_path, empleado_id into v_path, v_emp;

  if v_path is null then
    raise exception 'Documento % no encontrado', p_documento_id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'borrar_documento_rh', 'empleado_documentos', p_documento_id::text,
      jsonb_build_object('empleado_id', v_emp, 'storage_path', v_path)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'storage_path', v_path);
end;
$$;

grant execute on function public.admin_eliminar_documento_empleado(uuid, bigint)
  to anon, authenticated;

commit;
