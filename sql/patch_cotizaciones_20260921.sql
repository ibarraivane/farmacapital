-- FarmaCapital — Cotizaciones (oficina de proyecto, admin/gerente).
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.
--
-- No infla solicitudes_mostrador: el piso sigue en «Lo que buscan».
-- Aquí el dueño compara fuentes, elige compra y anota precio de venta / ganancia.

begin;

create table if not exists public.cotizaciones (
  id                 bigserial primary key,
  cliente_nombre     text,
  cliente_telefono   text,
  cliente_email      text,
  direccion          text,
  origen             text not null default 'admin',
  para_cuando        date,
  urgencia           text not null default 'sin_prisa',
  solicitud_id       bigint references public.solicitudes_mostrador(id) on delete set null,
  estado             text not null default 'nueva',
  notas              text,
  creado_por         bigint not null references public.usuarios(id) on delete restrict,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  constraint cotizaciones_origen_chk
    check (origen in ('admin', 'tienda', 'mostrador', 'whatsapp', 'telefono', 'otro')),
  constraint cotizaciones_urgencia_chk
    check (urgencia in ('hoy', 'manana', 'sin_prisa')),
  constraint cotizaciones_estado_chk
    check (estado in ('nueva', 'buscando', 'lista', 'pedida', 'cerrada', 'perdida'))
);

create table if not exists public.cotizacion_items (
  id                 bigserial primary key,
  cotizacion_id      bigint not null references public.cotizaciones(id) on delete cascade,
  texto              text not null,
  producto_id        bigint references public.productos(id) on delete set null,
  ean                text,
  cantidad           integer not null default 1,
  tipo_margen        text not null default 'marca',
  fuente_elegida_id  bigint,
  costo_elegido      numeric(12,2),
  precio_venta       numeric(12,2),
  estado             text not null default 'pendiente',
  notas              text,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  constraint cotizacion_items_texto_chk
    check (length(trim(texto)) >= 2),
  constraint cotizacion_items_cantidad_chk
    check (cantidad >= 1 and cantidad <= 999),
  constraint cotizacion_items_tipo_margen_chk
    check (tipo_margen in ('marca', 'generico')),
  constraint cotizacion_items_estado_chk
    check (estado in ('pendiente', 'buscando', 'elegido', 'pedir', 'pedido', 'llego', 'no_se_consigue')),
  constraint cotizacion_items_costo_chk
    check (costo_elegido is null or costo_elegido >= 0),
  constraint cotizacion_items_precio_chk
    check (precio_venta is null or precio_venta >= 0)
);

create table if not exists public.cotizacion_fuentes (
  id            bigserial primary key,
  item_id       bigint not null references public.cotizacion_items(id) on delete cascade,
  lugar         text not null,
  precio        numeric(12,2) not null,
  url           text,
  sku_externo   text,
  disponible    boolean not null default true,
  elegida       boolean not null default false,
  notas         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint cotizacion_fuentes_lugar_chk
    check (length(trim(lugar)) >= 2),
  constraint cotizacion_fuentes_precio_chk
    check (precio > 0)
);

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'cotizacion_items_fuente_elegida_fk'
  ) then
    alter table public.cotizacion_items
      add constraint cotizacion_items_fuente_elegida_fk
      foreign key (fuente_elegida_id)
      references public.cotizacion_fuentes(id)
      on delete set null;
  end if;
end $$;

create unique index if not exists cotizaciones_solicitud_id_uidx
  on public.cotizaciones (solicitud_id)
  where solicitud_id is not null;

create index if not exists cotizaciones_estado_created_idx
  on public.cotizaciones (estado, created_at desc);

create index if not exists cotizaciones_origen_created_idx
  on public.cotizaciones (origen, created_at desc);

create index if not exists cotizacion_items_cotizacion_idx
  on public.cotizacion_items (cotizacion_id);

create index if not exists cotizacion_fuentes_item_idx
  on public.cotizacion_fuentes (item_id);

comment on table public.cotizaciones is
  'Oficina admin de cotización: cliente + seguimiento. Distinto de solicitudes_mostrador.';
comment on table public.cotizacion_items is
  'Renglones de una cotización (qué piden).';
comment on table public.cotizacion_fuentes is
  'Comparativa: dónde se encontró y a qué costo.';

alter table public.cotizaciones enable row level security;
alter table public.cotizacion_items enable row level security;
alter table public.cotizacion_fuentes enable row level security;

revoke all on public.cotizaciones from anon, authenticated;
revoke all on public.cotizacion_items from anon, authenticated;
revoke all on public.cotizacion_fuentes from anon, authenticated;

drop policy if exists cotizaciones_sin_acceso_directo on public.cotizaciones;
create policy cotizaciones_sin_acceso_directo
  on public.cotizaciones for all using (false) with check (false);

drop policy if exists cotizacion_items_sin_acceso_directo on public.cotizacion_items;
create policy cotizacion_items_sin_acceso_directo
  on public.cotizacion_items for all using (false) with check (false);

drop policy if exists cotizacion_fuentes_sin_acceso_directo on public.cotizacion_fuentes;
create policy cotizacion_fuentes_sin_acceso_directo
  on public.cotizacion_fuentes for all using (false) with check (false);


create or replace function public._cotizacion_item_json(p_id bigint, p_con_fuentes boolean default true)
returns jsonb
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select jsonb_build_object(
    'id', i.id,
    'cotizacion_id', i.cotizacion_id,
    'texto', i.texto,
    'producto_id', i.producto_id,
    'producto_nombre', p.nombre,
    'ean', i.ean,
    'cantidad', i.cantidad,
    'tipo_margen', i.tipo_margen,
    'fuente_elegida_id', i.fuente_elegida_id,
    'costo_elegido', i.costo_elegido,
    'precio_venta', i.precio_venta,
    'estado', i.estado,
    'notas', i.notas,
    'created_at', i.created_at,
    'updated_at', i.updated_at,
    'fuentes', case
      when p_con_fuentes then coalesce((
        select jsonb_agg(jsonb_build_object(
          'id', f.id,
          'item_id', f.item_id,
          'lugar', f.lugar,
          'precio', f.precio,
          'url', f.url,
          'sku_externo', f.sku_externo,
          'disponible', f.disponible,
          'elegida', f.elegida,
          'notas', f.notas,
          'created_at', f.created_at
        ) order by f.elegida desc, f.precio asc, f.id)
        from public.cotizacion_fuentes f
        where f.item_id = i.id
      ), '[]'::jsonb)
      else '[]'::jsonb
    end
  )
  from public.cotizacion_items i
  left join public.productos p on p.id = i.producto_id
  where i.id = p_id;
$$;


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


create or replace function public._cotizacion_norm_urgencia(p text)
returns text
language sql
immutable
as $$
  select case
    when nullif(trim(coalesce(p, '')), '') in ('hoy', 'manana', 'sin_prisa')
      then trim(p)
    else 'sin_prisa'
  end;
$$;


create or replace function public._cotizacion_norm_origen(p text)
returns text
language sql
immutable
as $$
  select case
    when nullif(trim(coalesce(p, '')), '') in ('admin', 'tienda', 'mostrador', 'whatsapp', 'telefono', 'otro')
      then trim(p)
    else 'admin'
  end;
$$;


create or replace function public._cotizacion_insert_items(p_cotizacion_id bigint, p_items jsonb)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_el      jsonb;
  v_texto   text;
  v_cant    integer;
  v_tipo    text;
  v_ean     text;
  v_prod    bigint;
begin
  if p_items is null or jsonb_typeof(p_items) <> 'array' then
    return;
  end if;
  for v_el in select value from jsonb_array_elements(p_items)
  loop
    v_texto := left(trim(regexp_replace(coalesce(v_el->>'texto', ''), '\s+', ' ', 'g')), 200);
    if length(v_texto) < 2 then
      continue;
    end if;
    v_cant := greatest(1, least(coalesce((v_el->>'cantidad')::integer, 1), 999));
    if coalesce(v_el->>'tipo_margen', '') in ('generico') then
      v_tipo := 'generico';
    else
      v_tipo := 'marca';
    end if;
    v_ean := nullif(regexp_replace(coalesce(v_el->>'ean', ''), '\D', '', 'g'), '');
    if v_ean is not null and length(v_ean) < 8 then
      v_ean := null;
    end if;
    v_prod := nullif(v_el->>'producto_id', '')::bigint;
    if v_prod is not null and not exists (select 1 from public.productos p where p.id = v_prod) then
      v_prod := null;
    end if;
    insert into public.cotizacion_items (
      cotizacion_id, texto, producto_id, ean, cantidad, tipo_margen
    ) values (
      p_cotizacion_id, v_texto, v_prod, v_ean, v_cant, v_tipo
    );
  end loop;
end;
$$;


create or replace function public.admin_crear_cotizacion(
  p_session_token    uuid,
  p_cliente_nombre   text default null,
  p_cliente_telefono text default null,
  p_cliente_email    text default null,
  p_direccion        text default null,
  p_origen           text default 'admin',
  p_para_cuando      date default null,
  p_urgencia         text default 'sin_prisa',
  p_notas            text default null,
  p_solicitud_id     bigint default null,
  p_items            jsonb default '[]'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user    bigint;
  v_nombre  text;
  v_tel     text;
  v_id      bigint;
  v_items   jsonb;
begin
  v_user := public.fn_require_admin(p_session_token);
  v_nombre := nullif(left(trim(coalesce(p_cliente_nombre, '')), 120), '');
  v_tel := nullif(regexp_replace(coalesce(p_cliente_telefono, ''), '\D', '', 'g'), '');
  if v_tel is not null and length(v_tel) > 15 then
    v_tel := left(v_tel, 15);
  end if;
  if v_nombre is null and (v_tel is null or length(v_tel) < 8) then
    raise exception 'Pon el nombre o un teléfono de quien pide';
  end if;

  v_items := coalesce(p_items, '[]'::jsonb);
  if jsonb_typeof(v_items) <> 'array'
     or not exists (
       select 1
       from jsonb_array_elements(v_items) e
       where length(trim(coalesce(e.value->>'texto', ''))) >= 2
     )
  then
    raise exception 'Agrega al menos un producto (mínimo 2 caracteres)';
  end if;

  if p_solicitud_id is not null then
    if not exists (select 1 from public.solicitudes_mostrador s where s.id = p_solicitud_id) then
      raise exception 'La solicitud de mostrador no existe';
    end if;
    select c.id into v_id
    from public.cotizaciones c
    where c.solicitud_id = p_solicitud_id
    limit 1;
    if v_id is not null then
      return public._cotizacion_json(v_id, true);
    end if;
  end if;

  insert into public.cotizaciones (
    cliente_nombre, cliente_telefono, cliente_email, direccion,
    origen, para_cuando, urgencia, solicitud_id, notas, creado_por
  ) values (
    v_nombre,
    v_tel,
    nullif(left(trim(coalesce(p_cliente_email, '')), 180), ''),
    nullif(left(trim(coalesce(p_direccion, '')), 300), ''),
    public._cotizacion_norm_origen(p_origen),
    p_para_cuando,
    public._cotizacion_norm_urgencia(p_urgencia),
    p_solicitud_id,
    nullif(trim(coalesce(p_notas, '')), ''),
    v_user
  )
  returning id into v_id;

  perform public._cotizacion_insert_items(v_id, v_items);
  return public._cotizacion_json(v_id, true);
end;
$$;


create or replace function public.admin_listar_cotizaciones(
  p_session_token uuid,
  p_estado        text default 'abiertas',
  p_origen        text default null,
  p_limite        integer default 120
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
  v_ori   text;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limite, 120), 300));
  v_est := nullif(trim(coalesce(p_estado, '')), '');
  if v_est is not null
     and v_est not in ('abiertas', 'nueva', 'buscando', 'lista', 'pedida', 'cerrada', 'perdida') then
    v_est := 'abiertas';
  end if;
  v_ori := nullif(trim(coalesce(p_origen, '')), '');
  if v_ori is not null
     and v_ori not in ('admin', 'tienda', 'mostrador', 'whatsapp', 'telefono', 'otro') then
    v_ori := null;
  end if;

  return coalesce((
    select jsonb_agg(public._cotizacion_json(t.id, false) order by t.ord_urgencia, t.created_at desc)
    from (
      select
        c.id,
        case c.urgencia when 'hoy' then 0 when 'manana' then 1 else 2 end as ord_urgencia,
        c.created_at
      from public.cotizaciones c
      where (
        v_est is null
        or (v_est = 'abiertas' and c.estado in ('nueva', 'buscando', 'lista', 'pedida'))
        or c.estado = v_est
      )
        and (v_ori is null or c.origen = v_ori)
      order by ord_urgencia, c.created_at desc
      limit v_lim
    ) t
  ), '[]'::jsonb);
end;
$$;


create or replace function public.admin_obtener_cotizacion(
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
  v_dummy := public.fn_require_admin(p_session_token);
  v_row := public._cotizacion_json(p_id, true);
  if v_row is null then
    raise exception 'Cotización no encontrada';
  end if;
  return v_row;
end;
$$;


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
  p_estado           text default null
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
    estado = coalesce(v_estado, c.estado),
    updated_at = now()
  where c.id = p_id;

  if not found then
    raise exception 'Cotización no encontrada';
  end if;
  return public._cotizacion_json(p_id, true);
end;
$$;


create or replace function public.admin_agregar_cotizacion_item(
  p_session_token uuid,
  p_cotizacion_id bigint,
  p_texto         text,
  p_cantidad      integer default 1,
  p_producto_id   bigint default null,
  p_ean           text default null,
  p_tipo_margen   text default 'marca'
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_id    bigint;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  if not exists (select 1 from public.cotizaciones c where c.id = p_cotizacion_id) then
    raise exception 'Cotización no encontrada';
  end if;
  perform public._cotizacion_insert_items(
    p_cotizacion_id,
    jsonb_build_array(jsonb_build_object(
      'texto', p_texto,
      'cantidad', p_cantidad,
      'producto_id', p_producto_id,
      'ean', p_ean,
      'tipo_margen', p_tipo_margen
    ))
  );
  select i.id into v_id
  from public.cotizacion_items i
  where i.cotizacion_id = p_cotizacion_id
  order by i.id desc
  limit 1;
  if v_id is null then
    raise exception 'Escribe el producto (mínimo 2 caracteres)';
  end if;
  update public.cotizaciones set updated_at = now() where id = p_cotizacion_id;
  return public._cotizacion_json(p_cotizacion_id, true);
end;
$$;


create or replace function public.admin_actualizar_cotizacion_item(
  p_session_token uuid,
  p_id            bigint,
  p_texto         text default null,
  p_cantidad      integer default null,
  p_tipo_margen   text default null,
  p_estado        text default null,
  p_precio_venta  numeric default null,
  p_notas         text default null,
  p_ean           text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy  bigint;
  v_cotiz  bigint;
  v_texto  text;
  v_estado text;
  v_tipo   text;
  v_ean    text;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  select i.cotizacion_id into v_cotiz from public.cotizacion_items i where i.id = p_id;
  if v_cotiz is null then
    raise exception 'Renglón no encontrado';
  end if;
  v_estado := nullif(trim(coalesce(p_estado, '')), '');
  if v_estado is not null
     and v_estado not in ('pendiente', 'buscando', 'elegido', 'pedir', 'pedido', 'llego', 'no_se_consigue') then
    raise exception 'Estado de línea inválido';
  end if;
  v_texto := nullif(left(trim(regexp_replace(coalesce(p_texto, ''), '\s+', ' ', 'g')), 200), '');
  if p_texto is not null and (v_texto is null or length(v_texto) < 2) then
    raise exception 'El producto necesita al menos 2 caracteres';
  end if;
  v_tipo := nullif(trim(coalesce(p_tipo_margen, '')), '');
  if v_tipo is not null then
    if v_tipo in ('marca', 'patente') then
      v_tipo := 'marca';
    elsif v_tipo = 'generico' then
      v_tipo := 'generico';
    else
      raise exception 'Tipo de recargo inválido';
    end if;
  end if;
  v_ean := case
    when p_ean is null then null
    else nullif(regexp_replace(p_ean, '\D', '', 'g'), '')
  end;
  if v_ean is not null and length(v_ean) < 8 then
    v_ean := null;
  end if;

  update public.cotizacion_items i
  set
    texto = coalesce(v_texto, i.texto),
    cantidad = case
      when p_cantidad is null then i.cantidad
      else greatest(1, least(p_cantidad, 999))
    end,
    tipo_margen = coalesce(v_tipo, i.tipo_margen),
    estado = coalesce(v_estado, i.estado),
    precio_venta = case
      when p_precio_venta is null then i.precio_venta
      when p_precio_venta < 0 then i.precio_venta
      else p_precio_venta
    end,
    notas = case
      when p_notas is null then i.notas
      else nullif(trim(p_notas), '')
    end,
    ean = case when p_ean is null then i.ean else v_ean end,
    updated_at = now()
  where i.id = p_id;

  update public.cotizaciones set updated_at = now() where id = v_cotiz;
  return public._cotizacion_json(v_cotiz, true);
end;
$$;


create or replace function public.admin_agregar_cotizacion_fuente(
  p_session_token uuid,
  p_item_id       bigint,
  p_lugar         text,
  p_precio        numeric,
  p_url           text default null,
  p_sku_externo   text default null,
  p_disponible    boolean default true,
  p_notas         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_cotiz bigint;
  v_lugar text;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  select i.cotizacion_id into v_cotiz from public.cotizacion_items i where i.id = p_item_id;
  if v_cotiz is null then
    raise exception 'Renglón no encontrado';
  end if;
  v_lugar := left(trim(regexp_replace(coalesce(p_lugar, ''), '\s+', ' ', 'g')), 80);
  if length(v_lugar) < 2 then
    raise exception 'Escribe dónde lo encontraste';
  end if;
  if p_precio is null or p_precio <= 0 then
    raise exception 'El costo tiene que ser mayor a cero';
  end if;

  insert into public.cotizacion_fuentes (
    item_id, lugar, precio, url, sku_externo, disponible, notas
  ) values (
    p_item_id,
    v_lugar,
    round(p_precio::numeric, 2),
    nullif(left(trim(coalesce(p_url, '')), 500), ''),
    nullif(left(trim(coalesce(p_sku_externo, '')), 80), ''),
    coalesce(p_disponible, true),
    nullif(trim(coalesce(p_notas, '')), '')
  );

  update public.cotizacion_items
  set
    estado = case when estado = 'pendiente' then 'buscando' else estado end,
    updated_at = now()
  where id = p_item_id;

  update public.cotizaciones
  set
    estado = case when estado = 'nueva' then 'buscando' else estado end,
    updated_at = now()
  where id = v_cotiz;

  return public._cotizacion_json(v_cotiz, true);
end;
$$;


create or replace function public.admin_actualizar_cotizacion_fuente(
  p_session_token uuid,
  p_id            bigint,
  p_lugar         text default null,
  p_precio        numeric default null,
  p_url           text default null,
  p_sku_externo   text default null,
  p_disponible    boolean default null,
  p_notas         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_item  bigint;
  v_cotiz bigint;
  v_lugar text;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  select f.item_id into v_item from public.cotizacion_fuentes f where f.id = p_id;
  if v_item is null then
    raise exception 'Fuente no encontrada';
  end if;
  select i.cotizacion_id into v_cotiz from public.cotizacion_items i where i.id = v_item;
  v_lugar := nullif(left(trim(regexp_replace(coalesce(p_lugar, ''), '\s+', ' ', 'g')), 80), '');
  if p_lugar is not null and (v_lugar is null or length(v_lugar) < 2) then
    raise exception 'Escribe dónde lo encontraste';
  end if;
  if p_precio is not null and p_precio <= 0 then
    raise exception 'El costo tiene que ser mayor a cero';
  end if;

  update public.cotizacion_fuentes f
  set
    lugar = coalesce(v_lugar, f.lugar),
    precio = case when p_precio is null then f.precio else round(p_precio::numeric, 2) end,
    url = case
      when p_url is null then f.url
      else nullif(left(trim(p_url), 500), '')
    end,
    sku_externo = case
      when p_sku_externo is null then f.sku_externo
      else nullif(left(trim(p_sku_externo), 80), '')
    end,
    disponible = coalesce(p_disponible, f.disponible),
    notas = case
      when p_notas is null then f.notas
      else nullif(trim(p_notas), '')
    end,
    updated_at = now()
  where f.id = p_id;

  update public.cotizacion_items i
  set
    costo_elegido = case when i.fuente_elegida_id = p_id then coalesce(p_precio, i.costo_elegido) else i.costo_elegido end,
    updated_at = now()
  where i.id = v_item;

  update public.cotizaciones set updated_at = now() where id = v_cotiz;
  return public._cotizacion_json(v_cotiz, true);
end;
$$;


create or replace function public.admin_elegir_cotizacion_fuente(
  p_session_token uuid,
  p_id            bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy    bigint;
  v_item     bigint;
  v_cotiz    bigint;
  v_precio   numeric(12,2);
  v_tipo     text;
  v_sugerido numeric(12,2);
begin
  v_dummy := public.fn_require_admin(p_session_token);
  select f.item_id, f.precio into v_item, v_precio
  from public.cotizacion_fuentes f
  where f.id = p_id;
  if v_item is null then
    raise exception 'Fuente no encontrada';
  end if;
  select i.cotizacion_id, i.tipo_margen into v_cotiz, v_tipo
  from public.cotizacion_items i
  where i.id = v_item;

  update public.cotizacion_fuentes
  set elegida = (id = p_id), updated_at = now()
  where item_id = v_item;

  v_sugerido := ceil(v_precio * case when v_tipo = 'marca' then 1.25 else 1.60 end);

  update public.cotizacion_items
  set
    fuente_elegida_id = p_id,
    costo_elegido = v_precio,
    precio_venta = coalesce(precio_venta, v_sugerido),
    estado = case
      when estado in ('pendiente', 'buscando') then 'elegido'
      else estado
    end,
    updated_at = now()
  where id = v_item;

  update public.cotizaciones
  set
    estado = case when estado = 'nueva' then 'buscando' else estado end,
    updated_at = now()
  where id = v_cotiz;

  return public._cotizacion_json(v_cotiz, true);
end;
$$;


create or replace function public.admin_eliminar_cotizacion_fuente(
  p_session_token uuid,
  p_id            bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy        bigint;
  v_item         bigint;
  v_cotiz        bigint;
  v_era_elegida  boolean;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  select f.item_id, f.elegida into v_item, v_era_elegida
  from public.cotizacion_fuentes f
  where f.id = p_id;
  if v_item is null then
    raise exception 'Fuente no encontrada';
  end if;
  select i.cotizacion_id into v_cotiz from public.cotizacion_items i where i.id = v_item;

  delete from public.cotizacion_fuentes where id = p_id;

  if coalesce(v_era_elegida, false) then
    update public.cotizacion_items
    set fuente_elegida_id = null, costo_elegido = null, updated_at = now()
    where id = v_item;
  else
    update public.cotizacion_items set updated_at = now() where id = v_item;
  end if;

  update public.cotizaciones set updated_at = now() where id = v_cotiz;
  return public._cotizacion_json(v_cotiz, true);
end;
$$;


create or replace function public.admin_eliminar_cotizacion_item(
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
  v_cotiz bigint;
  v_n     integer;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  select i.cotizacion_id into v_cotiz from public.cotizacion_items i where i.id = p_id;
  if v_cotiz is null then
    raise exception 'Renglón no encontrado';
  end if;
  select count(*)::integer into v_n from public.cotizacion_items where cotizacion_id = v_cotiz;
  if v_n <= 1 then
    raise exception 'Deja al menos un producto en la cotización';
  end if;
  delete from public.cotizacion_items where id = p_id;
  update public.cotizaciones set updated_at = now() where id = v_cotiz;
  return public._cotizacion_json(v_cotiz, true);
end;
$$;


create or replace function public.admin_promover_solicitud_a_cotizacion(
  p_session_token uuid,
  p_solicitud_id  bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_s     public.solicitudes_mostrador%rowtype;
  v_id    bigint;
  v_ori   text;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  if p_solicitud_id is null then
    raise exception 'Solicitud requerida';
  end if;
  select * into v_s from public.solicitudes_mostrador where id = p_solicitud_id;
  if not found then
    raise exception 'Solicitud no encontrada';
  end if;

  select c.id into v_id
  from public.cotizaciones c
  where c.solicitud_id = p_solicitud_id
  limit 1;
  if v_id is not null then
    return public._cotizacion_json(v_id, true);
  end if;

  v_ori := case when coalesce(v_s.origen, 'mostrador') = 'tienda' then 'tienda' else 'mostrador' end;

  return public.admin_crear_cotizacion(
    p_session_token,
    coalesce(nullif(trim(v_s.cliente_nombre), ''), 'Solicitud LQ-' || v_s.id::text),
    v_s.cliente_telefono,
    v_s.cliente_email,
    v_s.direccion,
    v_ori,
    null,
    v_s.urgencia,
    v_s.notas,
    p_solicitud_id,
    jsonb_build_array(jsonb_build_object(
      'texto', v_s.texto,
      'cantidad', v_s.cantidad,
      'producto_id', v_s.producto_id,
      'tipo_margen', 'marca'
    ))
  );
end;
$$;


create or replace function public.admin_cotizaciones_de_solicitudes(
  p_session_token  uuid,
  p_solicitud_ids  bigint[]
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  if p_solicitud_ids is null or cardinality(p_solicitud_ids) = 0 then
    return '[]'::jsonb;
  end if;
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'solicitud_id', c.solicitud_id,
      'cotizacion_id', c.id,
      'folio', 'C-' || c.id::text
    ) order by c.id)
    from public.cotizaciones c
    where c.solicitud_id = any (p_solicitud_ids)
  ), '[]'::jsonb);
end;
$$;


create or replace function public.admin_contar_cotizaciones_abiertas(
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
  v_dummy := public.fn_require_admin(p_session_token);
  select count(*)::integer into v_n
  from public.cotizaciones
  where estado in ('nueva', 'buscando', 'lista', 'pedida');
  return coalesce(v_n, 0);
end;
$$;


revoke all on function public._cotizacion_item_json(bigint, boolean) from public, anon, authenticated;
revoke all on function public._cotizacion_json(bigint, boolean) from public, anon, authenticated;
revoke all on function public._cotizacion_norm_urgencia(text) from public, anon, authenticated;
revoke all on function public._cotizacion_norm_origen(text) from public, anon, authenticated;
revoke all on function public._cotizacion_insert_items(bigint, jsonb) from public, anon, authenticated;

grant execute on function public.admin_crear_cotizacion(uuid, text, text, text, text, text, date, text, text, bigint, jsonb)
  to anon, authenticated;
grant execute on function public.admin_listar_cotizaciones(uuid, text, text, integer)
  to anon, authenticated;
grant execute on function public.admin_obtener_cotizacion(uuid, bigint)
  to anon, authenticated;
grant execute on function public.admin_actualizar_cotizacion(uuid, bigint, text, text, text, text, text, date, text, text, text)
  to anon, authenticated;
grant execute on function public.admin_agregar_cotizacion_item(uuid, bigint, text, integer, bigint, text, text)
  to anon, authenticated;
grant execute on function public.admin_actualizar_cotizacion_item(uuid, bigint, text, integer, text, text, numeric, text, text)
  to anon, authenticated;
grant execute on function public.admin_agregar_cotizacion_fuente(uuid, bigint, text, numeric, text, text, boolean, text)
  to anon, authenticated;
grant execute on function public.admin_actualizar_cotizacion_fuente(uuid, bigint, text, numeric, text, text, boolean, text)
  to anon, authenticated;
grant execute on function public.admin_elegir_cotizacion_fuente(uuid, bigint)
  to anon, authenticated;
grant execute on function public.admin_eliminar_cotizacion_fuente(uuid, bigint)
  to anon, authenticated;
grant execute on function public.admin_eliminar_cotizacion_item(uuid, bigint)
  to anon, authenticated;
grant execute on function public.admin_promover_solicitud_a_cotizacion(uuid, bigint)
  to anon, authenticated;
grant execute on function public.admin_cotizaciones_de_solicitudes(uuid, bigint[])
  to anon, authenticated;
grant execute on function public.admin_contar_cotizaciones_abiertas(uuid)
  to anon, authenticated;

commit;
