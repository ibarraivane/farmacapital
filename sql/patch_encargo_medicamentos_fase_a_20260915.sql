-- FarmaCapital — Fase (a) Encargo de medicamentos (Caso A + Caso B).
-- Idempotente. Fuente: docs/claude_encargo-medicamentos.md + decisiones E.1–E.11.
--
-- Nombres conceptuales del spec → mapeo real:
--   entrada_inventario.validada → recepción confirmar ítem / productos.stock > 0
--   (el trigger de avisos se cablea en fase b; aquí solo el modelo)
--
-- envio_id queda UUID nullable SIN FK: claude_envio-domicilio.md aún no está en código
-- (Uber Direct sigue vivo; fase f bloqueada).

begin;

-- ── Config [CONFIGURABLE] ───────────────────────────────────────────
insert into public.configuracion (clave, valor)
values ('tiempo_vigencia_cotizacion_dias', '3')
on conflict (clave) do nothing;

-- ── Caso A: aviso_disponibilidad ────────────────────────────────────
create table if not exists public.aviso_disponibilidad (
  id                 uuid primary key default gen_random_uuid(),
  producto_id        bigint not null references public.productos(id) on delete cascade,
  cliente_telefono   text not null,
  cliente_nombre     text,
  notificado         boolean not null default false,
  notificado_at      timestamptz,
  created_at         timestamptz not null default now(),
  constraint aviso_disponibilidad_telefono_chk
    check (cliente_telefono ~ '^[0-9]{10}$'),
  constraint aviso_disponibilidad_notificado_at_chk
    check (notificado = false or notificado_at is not null)
);

create unique index if not exists aviso_disponibilidad_activo_uidx
  on public.aviso_disponibilidad (producto_id, cliente_telefono)
  where notificado = false;

create index if not exists aviso_disponibilidad_pendiente_idx
  on public.aviso_disponibilidad (producto_id, created_at desc)
  where notificado = false;

create index if not exists aviso_disponibilidad_listos_idx
  on public.aviso_disponibilidad (notificado, created_at desc);

comment on table public.aviso_disponibilidad is
  'Caso A: cliente pide aviso cuando un producto del catálogo vuelva a stock>0. Cola wa.me manual; modelo listo para WABA.';

alter table public.aviso_disponibilidad enable row level security;
revoke all on table public.aviso_disponibilidad from anon, authenticated;
drop policy if exists aviso_disponibilidad_sin_acceso_directo on public.aviso_disponibilidad;
create policy aviso_disponibilidad_sin_acceso_directo
  on public.aviso_disponibilidad
  for all using (false) with check (false);

-- ── Caso B: encargo_medicamento ─────────────────────────────────────
create table if not exists public.encargo_medicamento (
  id                    uuid primary key default gen_random_uuid(),
  cliente_nombre        text not null,
  cliente_telefono      text not null,
  cliente_id            bigint references public.clientes(id) on delete set null,
  nombre_medicamento    text not null,
  presentacion          text,
  cantidad              integer not null default 1,
  requiere_receta       boolean not null default false,
  receta_url            text,
  comentario_cliente    text,
  estado                text not null default 'pendiente_cotizacion',
  metodo_entrega        text,
  -- Sin FK a envio: el rediseño DiDi/preauth aún no existe en el repo.
  envio_id              uuid,
  pedido_id             bigint references public.pedidos(id) on delete set null,
  requiere_cadena_fria  boolean not null default false,
  costo_entrega_extra   numeric(12,2),
  nota_entrega_extra    text,
  cotizacion_activa_id  uuid,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  constraint encargo_medicamento_nombre_chk
    check (length(trim(nombre_medicamento)) >= 2),
  constraint encargo_medicamento_cliente_nombre_chk
    check (length(trim(cliente_nombre)) >= 2),
  constraint encargo_medicamento_telefono_chk
    check (cliente_telefono ~ '^[0-9]{10}$'),
  constraint encargo_medicamento_cantidad_chk
    check (cantidad >= 1 and cantidad <= 999),
  constraint encargo_medicamento_estado_chk
    check (estado in (
      'pendiente_cotizacion',
      'cotizado',
      'aceptado',
      'rechazado',
      'expirado',
      'pagado',
      'consiguiendo',
      'listo_para_entrega',
      'entregado',
      'cancelado'
    )),
  constraint encargo_medicamento_metodo_entrega_chk
    check (
      metodo_entrega is null
      or metodo_entrega in ('domicilio', 'recoger_en_tienda', 'entrega_personalizada')
    ),
  constraint encargo_medicamento_receta_chk
    check (requiere_receta = false or (receta_url is not null and length(trim(receta_url)) > 0)),
  constraint encargo_medicamento_cadena_fria_metodo_chk
    check (
      requiere_cadena_fria = false
      or metodo_entrega is null
      or metodo_entrega in ('recoger_en_tienda', 'entrega_personalizada')
    ),
  constraint encargo_medicamento_costo_extra_chk
    check (costo_entrega_extra is null or costo_entrega_extra >= 0)
);

create index if not exists encargo_medicamento_estado_created_idx
  on public.encargo_medicamento (estado, created_at desc);

create index if not exists encargo_medicamento_telefono_idx
  on public.encargo_medicamento (cliente_telefono, created_at desc);

create index if not exists encargo_medicamento_pedido_idx
  on public.encargo_medicamento (pedido_id)
  where pedido_id is not null;

comment on table public.encargo_medicamento is
  'Caso B: encargo de medicamento fuera de catálogo. Cotiza solo admin; vendedor puede estados operativos.';

alter table public.encargo_medicamento enable row level security;
revoke all on table public.encargo_medicamento from anon, authenticated;
drop policy if exists encargo_medicamento_sin_acceso_directo on public.encargo_medicamento;
create policy encargo_medicamento_sin_acceso_directo
  on public.encargo_medicamento
  for all using (false) with check (false);

-- ── cotizacion_encargo ──────────────────────────────────────────────
create table if not exists public.cotizacion_encargo (
  id                     uuid primary key default gen_random_uuid(),
  encargo_id             uuid not null references public.encargo_medicamento(id) on delete cascade,
  precio_unitario        numeric(12,2) not null,
  -- Snapshot de cantidad al cotizar (generated no puede leer otra tabla).
  cantidad               integer not null,
  precio_total           numeric(12,2) generated always as (round(precio_unitario * cantidad, 2)) stored,
  disponibilidad         text not null,
  nota_disponibilidad    text,
  tiempo_estimado_dias   integer not null,
  tiempo_estimado_nota   text,
  vigencia_hasta         timestamptz not null,
  cotizado_por           bigint not null references public.usuarios(id) on delete restrict,
  estado                 text not null default 'enviada',
  -- Token de link mágico (aceptar/rechazar sin login). Hash o token opaco.
  token_aceptacion       text not null,
  enviado_at             timestamptz not null default now(),
  respondido_at          timestamptz,
  created_at             timestamptz not null default now(),
  constraint cotizacion_encargo_precio_chk
    check (precio_unitario > 0),
  constraint cotizacion_encargo_cantidad_chk
    check (cantidad >= 1 and cantidad <= 999),
  constraint cotizacion_encargo_disponibilidad_chk
    check (disponibilidad in ('disponible', 'sujeto_a_confirmacion', 'no_disponible')),
  constraint cotizacion_encargo_tiempo_chk
    check (tiempo_estimado_dias >= 0 and tiempo_estimado_dias <= 365),
  constraint cotizacion_encargo_estado_chk
    check (estado in ('enviada', 'aceptada', 'rechazada', 'expirada')),
  constraint cotizacion_encargo_token_chk
    check (length(trim(token_aceptacion)) >= 16),
  constraint cotizacion_encargo_respondido_chk
    check (
      (estado = 'enviada' and respondido_at is null)
      or (estado <> 'enviada')
    )
);

create unique index if not exists cotizacion_encargo_token_uidx
  on public.cotizacion_encargo (token_aceptacion);

-- Solo una cotización "enviada" (activa) por encargo.
create unique index if not exists cotizacion_encargo_activa_uidx
  on public.cotizacion_encargo (encargo_id)
  where estado = 'enviada';

create index if not exists cotizacion_encargo_encargo_idx
  on public.cotizacion_encargo (encargo_id, created_at desc);

create index if not exists cotizacion_encargo_vigencia_idx
  on public.cotizacion_encargo (vigencia_hasta)
  where estado = 'enviada';

comment on table public.cotizacion_encargo is
  'Cotización manual de encargo. Escritura solo admin (RPC). Historial: filas nuevas, no overwrite.';

alter table public.cotizacion_encargo enable row level security;
revoke all on table public.cotizacion_encargo from anon, authenticated;
drop policy if exists cotizacion_encargo_sin_acceso_directo on public.cotizacion_encargo;
create policy cotizacion_encargo_sin_acceso_directo
  on public.cotizacion_encargo
  for all using (false) with check (false);

-- FK diferida: cotizacion_activa_id → cotizacion_encargo
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'encargo_medicamento_cotizacion_activa_fk'
  ) then
    alter table public.encargo_medicamento
      add constraint encargo_medicamento_cotizacion_activa_fk
      foreign key (cotizacion_activa_id)
      references public.cotizacion_encargo(id)
      on delete set null;
  end if;
end $$;

-- ── Integridad: no aceptar encargo sin cotización aceptada ──────────
create or replace function public.trg_encargo_requiere_cotizacion_aceptada()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_ok boolean;
begin
  if tg_op = 'UPDATE'
     and new.estado = 'aceptado'
     and (old.estado is distinct from 'aceptado')
  then
    select exists (
      select 1
      from public.cotizacion_encargo c
      where c.encargo_id = new.id
        and c.estado = 'aceptada'
    ) into v_ok;
    if not coalesce(v_ok, false) then
      raise exception 'encargo_aceptado_sin_cotizacion_aceptada'
        using errcode = '23514';
    end if;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_encargo_requiere_cotizacion_aceptada on public.encargo_medicamento;
create trigger trg_encargo_requiere_cotizacion_aceptada
  before update on public.encargo_medicamento
  for each row
  execute function public.trg_encargo_requiere_cotizacion_aceptada();

-- Cadena fría: bloquear metodo domicilio (y cualquier envío automático) a nivel fila.
create or replace function public.trg_encargo_cadena_fria_metodo()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  if new.requiere_cadena_fria
     and new.metodo_entrega is not null
     and new.metodo_entrega not in ('recoger_en_tienda', 'entrega_personalizada')
  then
    raise exception 'cadena_fria_bloquea_domicilio_automatico'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_encargo_cadena_fria_metodo on public.encargo_medicamento;
create trigger trg_encargo_cadena_fria_metodo
  before insert or update on public.encargo_medicamento
  for each row
  execute function public.trg_encargo_cadena_fria_metodo();

-- Expiración: marca cotizaciones enviadas vencidas + encargo asociado.
-- (Job/cron o llamada desde admin; sin WhatsApp API.)
create or replace function public.encargo_expirar_cotizaciones_vencidas()
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_n integer := 0;
  r record;
begin
  for r in
    select c.id, c.encargo_id
    from public.cotizacion_encargo c
    where c.estado = 'enviada'
      and c.vigencia_hasta < now()
  loop
    update public.cotizacion_encargo
       set estado = 'expirada',
           respondido_at = coalesce(respondido_at, now())
     where id = r.id
       and estado = 'enviada';

    update public.encargo_medicamento e
       set estado = 'expirado',
           updated_at = now()
     where e.id = r.encargo_id
       and e.estado = 'cotizado';

    v_n := v_n + 1;
  end loop;
  return v_n;
end;
$$;

revoke all on function public.encargo_expirar_cotizaciones_vencidas() from public, anon, authenticated;
grant execute on function public.encargo_expirar_cotizaciones_vencidas() to service_role;

comment on function public.encargo_expirar_cotizaciones_vencidas() is
  'Marca cotizaciones enviadas con vigencia_hasta < now() como expirada y el encargo cotizado como expirado.';

commit;
