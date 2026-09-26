-- FarmaCapital — Documento de cotización para el cliente (vigencia + registro de envío).
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.
--
-- Complementa sql/patch_cotizaciones_20260921.sql (ya aplicado). No cambia nada de lo
-- existente: solo agrega dos columnas opcionales a `cotizaciones`, extiende
-- admin_actualizar_cotizacion con un parámetro nuevo (al final, con default, no rompe
-- llamadas viejas) y agrega una función para marcar cuándo y por dónde se mandó.

begin;

alter table public.cotizaciones
  add column if not exists vigencia_texto text,
  add column if not exists enviada_at timestamptz,
  add column if not exists enviada_canal text;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'cotizaciones_enviada_canal_chk'
  ) then
    alter table public.cotizaciones
      add constraint cotizaciones_enviada_canal_chk
      check (enviada_canal is null or enviada_canal in ('whatsapp', 'correo', 'impreso', 'otro'));
  end if;
end $$;


-- _cotizacion_json: agrega vigencia_texto, enviada_at, enviada_canal al detalle.
create or replace function public._cotizacion_json(p_id bigint, p_con_detalle boolean default true)
returns jsonb
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select jsonb_build_object(
    'id', c.id,
    'folio', 'C-' || c.id::text,
    'cliente_nombre', c.cliente_nombre,
    'cliente_telefono', c.cliente_telefono,
    'cliente_email', c.cliente_email,
    'direccion', c.direccion,
    'origen', c.origen,
    'para_cuando', c.para_cuando,
    'urgencia', c.urgencia,
    'solicitud_id', c.solicitud_id,
    'estado', c.estado,
    'notas', c.notas,
    'vigencia_texto', c.vigencia_texto,
    'enviada_at', c.enviada_at,
    'enviada_canal', c.enviada_canal,
    'creado_por', c.creado_por,
    'creado_por_nombre', u.nombre,
    'created_at', c.created_at,
    'updated_at', c.updated_at,
    'resumen', coalesce((
      select string_agg(
        case when i.cantidad > 1 then i.texto || ' ×' || i.cantidad::text else i.texto end,
        ' · '
        order by i.id
      )
      from (
        select texto, cantidad, id
        from public.cotizacion_items
        where cotizacion_id = c.id
        order by id
        limit 3
      ) i
    ), 'Sin productos'),
    'items_count', (
      select count(*)::integer from public.cotizacion_items i where i.cotizacion_id = c.id
    ),
    'totales', (
      select jsonb_build_object(
        'costo', round(sum(i.costo_elegido * i.cantidad)::numeric, 2),
        'venta', round(sum(i.precio_venta * i.cantidad)::numeric, 2),
        'ganancia', round(sum((i.precio_venta - i.costo_elegido) * i.cantidad)::numeric, 2),
        'lineas', count(*)::integer
      )
      from public.cotizacion_items i
      where i.cotizacion_id = c.id
        and i.costo_elegido is not null
        and i.precio_venta is not null
    ),
    'items', case
      when p_con_detalle then coalesce((
        select jsonb_agg(public._cotizacion_item_json(i.id, true) order by i.id)
        from public.cotizacion_items i
        where i.cotizacion_id = c.id
      ), '[]'::jsonb)
      else '[]'::jsonb
    end
  )
  from public.cotizaciones c
  left join public.usuarios u on u.id = c.creado_por
  where c.id = p_id;
$$;


-- admin_actualizar_cotizacion: misma firma que ya está en producción, + p_vigencia_texto
-- al final (default null → las llamadas existentes del frontend no se rompen).
-- Se elimina primero la versión de 11 parámetros: si solo se hace CREATE OR REPLACE con
-- un parámetro extra, Postgres la trata como una sobrecarga nueva (firma distinta) y
-- quedan las dos coexistiendo, lo que puede volver ambiguas las llamadas con los
-- parámetros de siempre. Con el DROP solo queda la versión de 12.
drop function if exists public.admin_actualizar_cotizacion(
  uuid, bigint, text, text, text, text, text, date, text, text, text
);

create or replace function public.admin_actualizar_cotizacion(
  p_session_token    uuid,
  p_id               bigint,
  p_cliente_nombre   text default null,
  p_cliente_telefono text default null,
  p_cliente_email    text default null,
  p_direccion        text default null,
  p_origen           text default null,
  p_para_cuando      date default null,
  p_urgencia         text default null,
  p_notas            text default null,
  p_estado           text default null,
  p_vigencia_texto   text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy  bigint;
  v_nombre text;
  v_tel    text;
  v_estado text;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  if p_id is null then
    raise exception 'Cotización requerida';
  end if;
  v_estado := nullif(trim(coalesce(p_estado, '')), '');
  if v_estado is not null
     and v_estado not in ('nueva', 'buscando', 'lista', 'pedida', 'cerrada', 'perdida') then
    raise exception 'Estado inválido';
  end if;
  v_nombre := nullif(left(trim(coalesce(p_cliente_nombre, '')), 120), '');
  v_tel := nullif(regexp_replace(coalesce(p_cliente_telefono, ''), '\D', '', 'g'), '');
  if v_tel is not null and length(v_tel) > 15 then
    v_tel := left(v_tel, 15);
  end if;

  update public.cotizaciones c
  set
    cliente_nombre = coalesce(v_nombre, c.cliente_nombre),
    cliente_telefono = case
      when p_cliente_telefono is null then c.cliente_telefono
      else v_tel
    end,
    cliente_email = case
      when p_cliente_email is null then c.cliente_email
      else nullif(left(trim(p_cliente_email), 180), '')
    end,
    direccion = case
      when p_direccion is null then c.direccion
      else nullif(left(trim(p_direccion), 300), '')
    end,
    origen = case
      when p_origen is null then c.origen
      else public._cotizacion_norm_origen(p_origen)
    end,
    para_cuando = case
      when p_para_cuando is null then c.para_cuando
      else p_para_cuando
    end,
    urgencia = case
      when p_urgencia is null then c.urgencia
      else public._cotizacion_norm_urgencia(p_urgencia)
    end,
    notas = case
      when p_notas is null then c.notas
      else nullif(trim(p_notas), '')
    end,
    vigencia_texto = case
      when p_vigencia_texto is null then c.vigencia_texto
      else nullif(left(trim(p_vigencia_texto), 120), '')
    end,
    estado = coalesce(v_estado, c.estado),
    updated_at = now()
  where c.id = p_id;

  if not found then
    raise exception 'Cotización no encontrada';
  end if;
  return public._cotizacion_json(p_id, true);
end;
$$;


-- Marca cuándo y por dónde se mandó el documento al cliente (WhatsApp / correo / impreso).
create or replace function public.admin_marcar_cotizacion_enviada(
  p_session_token uuid,
  p_id            bigint,
  p_canal         text default 'otro'
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_canal text;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  v_canal := nullif(trim(coalesce(p_canal, '')), '');
  if v_canal is null or v_canal not in ('whatsapp', 'correo', 'impreso', 'otro') then
    v_canal := 'otro';
  end if;

  update public.cotizaciones
  set enviada_at = now(), enviada_canal = v_canal, updated_at = now()
  where id = p_id;

  if not found then
    raise exception 'Cotización no encontrada';
  end if;
  return public._cotizacion_json(p_id, true);
end;
$$;

grant execute on function public.admin_actualizar_cotizacion(uuid, bigint, text, text, text, text, text, date, text, text, text, text)
  to anon, authenticated;
grant execute on function public.admin_marcar_cotizacion_enviada(uuid, bigint, text)
  to anon, authenticated;

commit;
