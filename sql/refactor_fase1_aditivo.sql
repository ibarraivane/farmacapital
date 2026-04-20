-- ============================================================
-- FARMAX — Refactor FASE 1: ADITIVO PURO
-- ============================================================
-- Contiene las tareas del plan que NO modifican ni eliminan nada:
--   T1  (solo tabla proveedores, sin tocar lotes.proveedor todavía)
--   T2  (compras + compra_items)
--   T3  (direcciones_cliente)
--   T6  (sucursales + columnas sucursal_id NULLABLE)
--   T7  (envios)
--   T8  (audit_log_detallado)
--   T11 (índices en tablas existentes)
--
-- Es IDEMPOTENTE: se puede correr varias veces sin romper nada.
-- Todo dentro de una transacción; si falla algo, se revierte entero.
--
-- Lo que se deja EXPLÍCITAMENTE para fases siguientes:
--   - T1 parte 2: agregar lotes.proveedor_id + backfill + drop lotes.proveedor (F2-F4)
--   - T4: pedido_items.lote_id + backfill + drop lote (F2-F4)
--   - T5: VIEW v_stock_actual + migración de consumidores (F2-F3)
--   - T9 RLS, T10 Auth, T12-T20: fases posteriores
-- ============================================================

begin;

-- ============================================================
-- T1 — Tabla proveedores (catálogo, sin FK desde lotes todavía)
-- ============================================================
create table if not exists public.proveedores (
  id          serial       primary key,
  nombre      text         not null,
  rfc         text,
  telefono    text,
  email       text,
  direccion   text,
  activo      boolean      not null default true,
  created_at  timestamptz  not null default now()
);

create index if not exists idx_proveedores_nombre on public.proveedores (nombre);
create index if not exists idx_proveedores_activo on public.proveedores (activo);

comment on table public.proveedores is
  'Catálogo de proveedores. F1: creado vacío. F2 migrará lotes.proveedor (texto) aquí y añadirá lotes.proveedor_id.';


-- ============================================================
-- T2 — Compras
-- ============================================================
create table if not exists public.compras (
  id            serial        primary key,
  proveedor_id  integer       references public.proveedores(id) on delete restrict,
  fecha         date          not null default current_date,
  total         numeric(14,2) not null default 0,
  estado        text          not null default 'pendiente',
  created_at    timestamptz   not null default now()
);

create index if not exists idx_compras_proveedor on public.compras (proveedor_id);
create index if not exists idx_compras_fecha     on public.compras (fecha);
create index if not exists idx_compras_estado    on public.compras (estado);

create table if not exists public.compra_items (
  id               serial        primary key,
  compra_id        integer       not null references public.compras(id) on delete cascade,
  producto_id      integer       references public.productos(id) on delete restrict,
  lote             text,
  fecha_caducidad  date,
  cantidad         integer       not null check (cantidad > 0),
  costo_unitario   numeric(14,4) not null default 0,
  created_at       timestamptz   not null default now()
);

create index if not exists idx_compra_items_compra   on public.compra_items (compra_id);
create index if not exists idx_compra_items_producto on public.compra_items (producto_id);


-- ============================================================
-- T3 — Direcciones del cliente
-- ============================================================
create table if not exists public.direcciones_cliente (
  id             serial        primary key,
  cliente_id     integer       not null references public.clientes(id) on delete cascade,
  direccion      text          not null,
  colonia        text,
  ciudad         text,
  codigo_postal  text,
  lat            numeric(10,7),
  lng            numeric(10,7),
  es_principal   boolean       not null default false,
  created_at     timestamptz   not null default now()
);

create index if not exists idx_direcciones_cliente_cliente on public.direcciones_cliente (cliente_id);

-- Solo una dirección principal por cliente
create unique index if not exists uq_direcciones_cliente_principal
  on public.direcciones_cliente (cliente_id)
  where es_principal = true;


-- ============================================================
-- T6 — Sucursales
-- ============================================================
create table if not exists public.sucursales (
  id          serial       primary key,
  nombre      text         not null,
  direccion   text,
  telefono    text,
  activo      boolean      not null default true,
  created_at  timestamptz  not null default now()
);

-- Columnas NULLABLE (no tocamos data existente, queda en NULL = "sucursal única implícita")
alter table public.productos add column if not exists sucursal_id integer references public.sucursales(id);
alter table public.lotes     add column if not exists sucursal_id integer references public.sucursales(id);
alter table public.pedidos   add column if not exists sucursal_id integer references public.sucursales(id);

create index if not exists idx_productos_sucursal on public.productos (sucursal_id);
create index if not exists idx_lotes_sucursal     on public.lotes (sucursal_id);
create index if not exists idx_pedidos_sucursal   on public.pedidos (sucursal_id);


-- ============================================================
-- T7 — Envíos (delivery readiness)
-- ============================================================
create table if not exists public.envios (
  id            serial       primary key,
  pedido_id     integer      not null references public.pedidos(id) on delete cascade,
  direccion_id  integer      references public.direcciones_cliente(id) on delete set null,
  metodo        text,
  estado        text         not null default 'pendiente',
  tracking      text,
  created_at    timestamptz  not null default now()
);

-- Un envío por pedido (por ahora). Si en el futuro permitimos splits, quitamos este unique.
create unique index if not exists uq_envios_pedido on public.envios (pedido_id);
create index        if not exists idx_envios_estado on public.envios (estado);


-- ============================================================
-- T8 — Auditoría detallada (tabla, sin triggers todavía)
-- ============================================================
create table if not exists public.audit_log_detallado (
  id           bigserial    primary key,
  usuario_id   integer,
  accion       text         not null,
  tabla        text         not null,
  registro_id  integer,
  antes        jsonb,
  despues      jsonb,
  created_at   timestamptz  not null default now()
);

create index if not exists idx_audit_log_detallado_tabla
  on public.audit_log_detallado (tabla, registro_id);
create index if not exists idx_audit_log_detallado_usuario
  on public.audit_log_detallado (usuario_id);
create index if not exists idx_audit_log_detallado_created
  on public.audit_log_detallado (created_at desc);

comment on table public.audit_log_detallado is
  'Log de cambios con payload antes/despues. F5 añadirá triggers en pedidos/pedido_items/movimientos_inventario/facturas.';


-- ============================================================
-- T11 — Índices sobre tablas existentes
-- ============================================================
-- Los que dependen de columnas específicas van protegidos por DO blocks
-- para que NO falle si la columna aún no existe en tu esquema.

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'productos' and column_name = 'codigo_barras'
  ) then
    execute 'create index if not exists idx_productos_codigo_barras on public.productos (codigo_barras)';
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'productos' and column_name = 'sku'
  ) then
    execute 'create index if not exists idx_productos_sku on public.productos (sku)';
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'lotes' and column_name = 'producto_id'
  ) then
    execute 'create index if not exists idx_lotes_producto on public.lotes (producto_id)';
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'pedido_items' and column_name = 'pedido_id'
  ) then
    execute 'create index if not exists idx_pedido_items_pedido on public.pedido_items (pedido_id)';
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'movimientos_inventario' and column_name = 'producto_id'
  ) then
    execute 'create index if not exists idx_movimientos_inventario_producto on public.movimientos_inventario (producto_id)';
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'pedidos' and column_name = 'cliente_id'
  ) then
    execute 'create index if not exists idx_pedidos_cliente on public.pedidos (cliente_id)';
  end if;
end $$;


commit;

-- ============================================================
-- FASE 1 — Cómo verificar que todo quedó bien:
--   select * from public.proveedores;            -- (vacío)
--   select * from public.compras;                -- (vacío)
--   select * from public.compra_items;           -- (vacío)
--   select * from public.direcciones_cliente;    -- (vacío)
--   select * from public.sucursales;             -- (vacío)
--   select * from public.envios;                 -- (vacío)
--   select * from public.audit_log_detallado;    -- (vacío)
--   \d public.productos   -- debe mostrar sucursal_id
--   \d public.lotes       -- debe mostrar sucursal_id
--   \d public.pedidos     -- debe mostrar sucursal_id
-- ============================================================
