-- ============================================================================
-- FARMA CAPITAL — Pricing rules (001)
-- Idempotente · reversible con 005_rollback_pricing.sql
-- NO modifica costos, lotes, inventario ni pedidos históricos.
-- ============================================================================

begin;

-- ---------------------------------------------------------------------------
-- 1) Reglas configurables
-- ---------------------------------------------------------------------------
create table if not exists public.pricing_rules (
  id                      bigserial primary key,
  codigo                  text not null unique,
  nombre                  text not null,
  categoria_criterio      text,
  descripcion             text,
  porcentaje_recargo      numeric(6,4) not null check (porcentaje_recargo >= 0),
  utilidad_minima_costo_lt_20 numeric(10,2) default 5,
  utilidad_minima_costo_20_49 numeric(10,2) default 8,
  utilidad_minima_costo_gte_50 numeric(10,2) default 0,
  costo_umbral_dispositivo  numeric(10,2) default 300,
  prioridad               integer not null default 100,
  activo                  boolean not null default true,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now()
);

comment on table public.pricing_rules is
  'Reglas de recargo sobre costo (markup), no margen sobre precio de venta.';

-- Semilla inicial (ON CONFLICT actualiza metadatos, no borra)
insert into public.pricing_rules
  (codigo, nombre, categoria_criterio, porcentaje_recargo, prioridad, descripcion)
values
  ('med_generico',           'Medicamento genérico',              'medicamento:generico',           0.6000, 10,  'Recargo 60% sobre costo'),
  ('med_patente',            'Medicamento patente / marca RX',    'medicamento:marca:rx',           0.2500, 20,  'Recargo 25%'),
  ('med_otc_marca',          'Medicamento OTC marca sin receta',  'medicamento:marca:otc',          0.3500, 30,  'Recargo 35%'),
  ('material_curacion',      'Material de curación',              'material_curacion',              0.5000, 40,  'Recargo 50%'),
  ('higiene',                'Higiene y cuidado personal',        'higiene',                        0.4000, 50,  'Recargo 40%'),
  ('vitaminas',              'Vitaminas y suplementos',           'vitaminas',                      0.4500, 60,  'Recargo 45%'),
  ('bebidas_sueros',         'Bebidas, sueros, electrolitos',     'bebidas_sueros',                 0.3000, 70,  'Recargo 30%'),
  ('bebe',                   'Productos para bebé',               'bebe',                           0.3000, 80,  'Recargo 30%'),
  ('disp_med_bajo',          'Dispositivo médico económico (<300)','dispositivo:bajo',              0.5000, 90,  'Recargo 50%'),
  ('disp_med_alto',          'Dispositivo médico alto (>=300)',   'dispositivo:alto',               0.3000, 95,  'Recargo 30%'),
  ('impulso',                'Dulces, botanas, impulso',          'impulso',                        0.4000, 110, 'Recargo 40%'),
  ('sin_clasificar',         'Sin clasificación (provisional)',   'sin_clasificar',                 0.3500, 999, 'Revisión manual obligatoria')
on conflict (codigo) do update set
  nombre = excluded.nombre,
  categoria_criterio = excluded.categoria_criterio,
  porcentaje_recargo = excluded.porcentaje_recargo,
  prioridad = excluded.prioridad,
  descripcion = excluded.descripcion,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- 2) Columnas en productos (solo si no existen)
-- ---------------------------------------------------------------------------
alter table if exists public.productos
  add column if not exists pricing_rule_id bigint references public.pricing_rules(id),
  add column if not exists markup_percentage numeric(6,4),
  add column if not exists calculated_price numeric(10,2),
  add column if not exists manual_price_override boolean not null default false,
  add column if not exists price_needs_review boolean not null default false,
  add column if not exists price_updated_at timestamptz,
  add column if not exists tasa_iva numeric(5,4),
  add column if not exists costo_incluye_iva boolean,
  add column if not exists subcategoria text;

create index if not exists idx_productos_pricing_rule on public.productos (pricing_rule_id);
create index if not exists idx_productos_price_review on public.productos (price_needs_review) where price_needs_review = true;

-- ---------------------------------------------------------------------------
-- 3) Respaldo antes de cualquier apply (snapshot único por fecha)
-- ---------------------------------------------------------------------------
create table if not exists public.productos_precio_backup_20260810 (
  backup_at           timestamptz not null default now(),
  producto_id         bigint not null,
  sku                 text,
  nombre              text,
  categoria           text,
  tipo                text,
  costo               numeric(10,2),
  precio_anterior     numeric(10,2),
  precio_unidad_ant   numeric(10,2),
  descuento_pct_ant   numeric(10,2),
  primary key (producto_id)
);

insert into public.productos_precio_backup_20260810
  (producto_id, sku, nombre, categoria, tipo, costo, precio_anterior, precio_unidad_ant, descuento_pct_ant)
select
  p.id, p.sku, p.nombre, p.categoria, p.tipo, p.costo, p.precio, p.precio_unidad, p.descuento_pct
from public.productos p
on conflict (producto_id) do nothing;

-- ---------------------------------------------------------------------------
-- 4) Historial mínimo de cambios de precio
-- ---------------------------------------------------------------------------
create table if not exists public.productos_precio_historial (
  id                bigserial primary key,
  producto_id       bigint not null references public.productos(id) on delete cascade,
  precio_anterior   numeric(10,2),
  precio_nuevo      numeric(10,2),
  costo_usado       numeric(10,2),
  pricing_rule_id   bigint references public.pricing_rules(id),
  pricing_rule_codigo text,
  markup_percentage numeric(6,4),
  origen            text not null default 'pricing_engine',
  notas             text,
  created_at        timestamptz not null default now()
);

create index if not exists idx_precio_hist_producto on public.productos_precio_historial (producto_id, created_at desc);

commit;

-- Verificación
select codigo, porcentaje_recargo, prioridad, activo from public.pricing_rules order by prioridad;
select count(*) as productos_respaldados from public.productos_precio_backup_20260810;
