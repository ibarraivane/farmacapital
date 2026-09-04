-- FarmaCapital — Pedidos de mostrador ("Lo que buscan").
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.
--
-- Lista viva: el piso anota lo que el cliente pide y no hay (o no está en
-- catálogo), con vendedor, cliente, teléfono y si dejó depósito.
-- Admin ve pendientes, cambia estado y consulta ranking.

begin;

create table if not exists public.solicitudes_mostrador (
  id               bigserial primary key,
  texto            text not null,
  producto_id      bigint references public.productos(id) on delete set null,
  cantidad         integer not null default 1,
  urgencia         text not null default 'sin_prisa',
  tipo             text not null default 'no_catalogo',
  estado           text not null default 'pendiente',
  notas            text,
  cliente_nombre   text,
  cliente_telefono text,
  pago_tipo        text not null default 'nada',
  pago_monto       numeric(12,2),
  anotado_por      bigint not null references public.usuarios(id) on delete restrict,
  resuelto_por     bigint references public.usuarios(id) on delete set null,
  resuelto_at      timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  constraint solicitudes_mostrador_texto_chk
    check (length(trim(texto)) >= 2),
  constraint solicitudes_mostrador_cantidad_chk
    check (cantidad >= 1 and cantidad <= 999),
  constraint solicitudes_mostrador_urgencia_chk
    check (urgencia in ('hoy', 'manana', 'sin_prisa')),
  constraint solicitudes_mostrador_tipo_chk
    check (tipo in ('agotado', 'no_catalogo', 'en_catalogo')),
  constraint solicitudes_mostrador_estado_chk
    check (estado in ('pendiente', 'pedir', 'pedido', 'llego', 'descartado')),
  constraint solicitudes_mostrador_pago_tipo_chk
    check (pago_tipo in ('nada', 'deposito', 'completo')),
  constraint solicitudes_mostrador_pago_monto_chk
    check (pago_monto is null or pago_monto >= 0)
);

-- Columnas nuevas si la tabla ya existía de un intento previo.
alter table public.solicitudes_mostrador
  add column if not exists cliente_nombre text,
  add column if not exists cliente_telefono text,
  add column if not exists pago_tipo text not null default 'nada',
  add column if not exists pago_monto numeric(12,2);

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'solicitudes_mostrador_pago_tipo_chk'
  ) then
    alter table public.solicitudes_mostrador
      add constraint solicitudes_mostrador_pago_tipo_chk
      check (pago_tipo in ('nada', 'deposito', 'completo'));
  end if;
  if not exists (
    select 1 from pg_constraint
    where conname = 'solicitudes_mostrador_pago_monto_chk'
  ) then
    alter table public.solicitudes_mostrador
      add constraint solicitudes_mostrador_pago_monto_chk
      check (pago_monto is null or pago_monto >= 0);
  end if;
end $$;

create index if not exists solicitudes_mostrador_estado_created_idx
  on public.solicitudes_mostrador (estado, created_at desc);

create index if not exists solicitudes_mostrador_created_idx
  on public.solicitudes_mostrador (created_at desc);

create index if not exists solicitudes_mostrador_producto_idx
  on public.solicitudes_mostrador (producto_id)
  where producto_id is not null;

comment on table public.solicitudes_mostrador is
  'Lo que buscan en mostrador: pedidos de clientes por producto faltante o no catalogado.';

alter table public.solicitudes_mostrador enable row level security;

revoke all on public.solicitudes_mostrador from anon, authenticated;

drop policy if exists solicitudes_mostrador_sin_acceso_directo on public.solicitudes_mostrador;
create policy solicitudes_mostrador_sin_acceso_directo
  on public.solicitudes_mostrador
  for all
  using (false)
  with check (false);


-- Helper: arma el JSON de una fila
create or replace function public._solicitud_mostrador_json(p_id bigint)
returns jsonb
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select jsonb_build_object(
    'id', s.id,
    'texto', s.texto,
    'producto_id', s.producto_id,
    'producto_nombre', p.nombre,
    'producto_stock', coalesce(p.stock, 0),
    'cantidad', s.cantidad,
    'urgencia', s.urgencia,
    'tipo', s.tipo,
    'estado', s.estado,
    'notas', s.notas,
    'cliente_nombre', s.cliente_nombre,
    'cliente_telefono', s.cliente_telefono,
    'pago_tipo', s.pago_tipo,
    'pago_monto', s.pago_monto,
    'anotado_por', s.anotado_por,
    'anotado_por_nombre', u.nombre,
    'resuelto_por', s.resuelto_por,
    'resuelto_por_nombre', ur.nombre,
    'resuelto_at', s.resuelto_at,
    'created_at', s.created_at,
    'updated_at', s.updated_at
  )
  from public.solicitudes_mostrador s
  left join public.productos p on p.id = s.producto_id
  left join public.usuarios u on u.id = s.anotado_por
  left join public.usuarios ur on ur.id = s.resuelto_por
  where s.id = p_id;
$$;


create or replace function public.empleado_crear_solicitud_mostrador(
  p_session_token    uuid,
  p_texto            text,
  p_producto_id      bigint default null,
  p_cantidad         integer default 1,
  p_urgencia         text default 'sin_prisa',
  p_notas            text default null,
  p_cliente_nombre   text default null,
  p_cliente_telefono text default null,
  p_pago_tipo        text default 'nada',
  p_pago_monto       numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user     bigint;
  v_texto    text;
  v_cant     integer;
  v_urg      text;
  v_tipo     text;
  v_stock    integer;
  v_nombre   text;
  v_id       bigint;
  v_cli_nom  text;
  v_cli_tel  text;
  v_pago     text;
  v_monto    numeric(12,2);
begin
  v_user := public.fn_require_empleado(p_session_token);
  v_texto := trim(coalesce(p_texto, ''));
  if length(v_texto) < 2 then
    raise exception 'Escribe qué buscan (mínimo 2 caracteres)';
  end if;
  if length(v_texto) > 200 then
    v_texto := left(v_texto, 200);
  end if;

  v_cant := greatest(1, least(coalesce(p_cantidad, 1), 999));
  v_urg := coalesce(nullif(trim(p_urgencia), ''), 'sin_prisa');
  if v_urg not in ('hoy', 'manana', 'sin_prisa') then
    v_urg := 'sin_prisa';
  end if;

  v_cli_nom := nullif(trim(coalesce(p_cliente_nombre, '')), '');
  if v_cli_nom is not null and length(v_cli_nom) > 120 then
    v_cli_nom := left(v_cli_nom, 120);
  end if;
  v_cli_tel := nullif(regexp_replace(coalesce(p_cliente_telefono, ''), '\D', '', 'g'), '');
  if v_cli_tel is not null and length(v_cli_tel) > 15 then
    v_cli_tel := left(v_cli_tel, 15);
  end if;

  v_pago := coalesce(nullif(trim(p_pago_tipo), ''), 'nada');
  if v_pago not in ('nada', 'deposito', 'completo') then
    v_pago := 'nada';
  end if;
  v_monto := p_pago_monto;
  if v_pago = 'nada' then
    v_monto := null;
  elsif v_monto is not null and v_monto < 0 then
    raise exception 'El monto de pago no puede ser negativo';
  end if;

  v_tipo := 'no_catalogo';
  if p_producto_id is not null then
    select p.nombre, coalesce(p.stock, 0)
      into v_nombre, v_stock
    from public.productos p
    where p.id = p_producto_id;
    if v_nombre is null then
      raise exception 'Producto no encontrado';
    end if;
    if coalesce(v_stock, 0) <= 0 then
      v_tipo := 'agotado';
    else
      v_tipo := 'en_catalogo';
    end if;
  end if;

  insert into public.solicitudes_mostrador (
    texto, producto_id, cantidad, urgencia, tipo, notas,
    cliente_nombre, cliente_telefono, pago_tipo, pago_monto, anotado_por
  ) values (
    v_texto,
    p_producto_id,
    v_cant,
    v_urg,
    v_tipo,
    nullif(trim(coalesce(p_notas, '')), ''),
    v_cli_nom,
    v_cli_tel,
    v_pago,
    v_monto,
    v_user
  )
  returning id into v_id;

  return public._solicitud_mostrador_json(v_id);
end;
$$;


create or replace function public.empleado_obtener_solicitud_mostrador(
  p_session_token uuid,
  p_id            bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_row   jsonb;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_row := public._solicitud_mostrador_json(p_id);
  if v_row is null then
    raise exception 'Solicitud no encontrada';
  end if;
  return v_row;
end;
$$;


create or replace function public.empleado_listar_solicitudes_mostrador(
  p_session_token uuid,
  p_estado        text default null,
  p_limite        integer default 100
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_lim   integer;
  v_est   text;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limite, 100), 300));
  v_est := nullif(trim(coalesce(p_estado, '')), '');
  if v_est is not null
     and v_est not in ('pendiente', 'pedir', 'pedido', 'llego', 'descartado', 'abiertas') then
    v_est := null;
  end if;

  return coalesce((
    select jsonb_agg(public._solicitud_mostrador_json(t.id) order by t.ord_urgencia, t.created_at desc)
    from (
      select
        s.id,
        case s.urgencia
          when 'hoy' then 0
          when 'manana' then 1
          else 2
        end as ord_urgencia,
        s.created_at
      from public.solicitudes_mostrador s
      where (
        v_est is null
        or (v_est = 'abiertas' and s.estado in ('pendiente', 'pedir', 'pedido'))
        or s.estado = v_est
      )
      order by ord_urgencia, s.created_at desc
      limit v_lim
    ) t
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_actualizar_estado_solicitud_mostrador(
  p_session_token uuid,
  p_id            bigint,
  p_estado        text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user   bigint;
  v_estado text;
begin
  v_user := public.fn_require_empleado(p_session_token);
  v_estado := trim(coalesce(p_estado, ''));
  if v_estado not in ('pendiente', 'pedir', 'pedido', 'llego', 'descartado') then
    raise exception 'Estado inválido';
  end if;
  if p_id is null then
    raise exception 'Solicitud requerida';
  end if;

  update public.solicitudes_mostrador s
  set
    estado = v_estado,
    updated_at = now(),
    resuelto_por = case
      when v_estado in ('llego', 'descartado') then v_user
      else s.resuelto_por
    end,
    resuelto_at = case
      when v_estado in ('llego', 'descartado') then now()
      when v_estado in ('pendiente', 'pedir', 'pedido') then null
      else s.resuelto_at
    end
  where s.id = p_id;

  if not found then
    raise exception 'Solicitud no encontrada';
  end if;

  return public._solicitud_mostrador_json(p_id);
end;
$$;


create or replace function public.empleado_contar_solicitudes_mostrador_abiertas(
  p_session_token uuid
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_n     integer;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::integer into v_n
  from public.solicitudes_mostrador
  where estado in ('pendiente', 'pedir', 'pedido');
  return coalesce(v_n, 0);
end;
$$;


create or replace function public.empleado_ranking_solicitudes_mostrador(
  p_session_token uuid,
  p_dias          integer default 30,
  p_limite        integer default 20
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_dias  integer;
  v_lim   integer;
  v_desde timestamptz;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_dias := greatest(1, least(coalesce(p_dias, 30), 180));
  v_lim := greatest(1, least(coalesce(p_limite, 20), 50));
  v_desde := now() - make_interval(days => v_dias);

  return coalesce((
    select jsonb_agg(to_jsonb(r) order by r.veces desc, r.unidades desc)
    from (
      select
        lower(trim(s.texto)) as clave,
        min(s.texto) as texto,
        s.producto_id,
        max(p.nombre) as producto_nombre,
        count(*)::integer as veces,
        sum(s.cantidad)::integer as unidades,
        max(s.created_at) as ultima_vez,
        bool_or(s.tipo = 'no_catalogo') as alguna_sin_catalogo,
        bool_or(s.tipo = 'agotado') as alguna_agotada
      from public.solicitudes_mostrador s
      left join public.productos p on p.id = s.producto_id
      where s.created_at >= v_desde
        and s.estado <> 'descartado'
      group by lower(trim(s.texto)), s.producto_id
      order by count(*) desc, sum(s.cantidad) desc
      limit v_lim
    ) r
  ), '[]'::jsonb);
end;
$$;


revoke all on function public._solicitud_mostrador_json(bigint) from public, anon, authenticated;

grant execute on function public.empleado_crear_solicitud_mostrador(uuid, text, bigint, integer, text, text, text, text, text, numeric)
  to anon, authenticated;
grant execute on function public.empleado_obtener_solicitud_mostrador(uuid, bigint)
  to anon, authenticated;
grant execute on function public.empleado_listar_solicitudes_mostrador(uuid, text, integer)
  to anon, authenticated;
grant execute on function public.empleado_actualizar_estado_solicitud_mostrador(uuid, bigint, text)
  to anon, authenticated;
grant execute on function public.empleado_contar_solicitudes_mostrador_abiertas(uuid)
  to anon, authenticated;
grant execute on function public.empleado_ranking_solicitudes_mostrador(uuid, integer, integer)
  to anon, authenticated;

commit;
