-- ============================================================
-- Columnas de catálogo en productos (requeridas antes de ACTUALIZACION_MASIVA)
-- Idempotente: seguro ejecutar varias veces.
-- ============================================================

begin;

alter table if exists public.productos
  add column if not exists marca text,
  add column if not exists presentacion text,
  add column if not exists principio_activo text,
  add column if not exists concentracion text,
  add column if not exists forma_farmaceutica text,
  add column if not exists denominacion_generica text,
  add column if not exists denominacion_distintiva text,
  add column if not exists ubicacion_texto text,
  add column if not exists precio_similares numeric,
  add column if not exists precio_del_ahorro numeric,
  add column if not exists fecha_actualizacion_precios date;

-- Catálogo proveedores + FK en lotes (si aún no existen)
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

alter table if exists public.lotes
  add column if not exists proveedor_id integer references public.proveedores(id);

create index if not exists idx_lotes_proveedor_id on public.lotes (proveedor_id);

-- Verificación rápida
select column_name
from information_schema.columns
where table_schema = 'public'
  and table_name = 'productos'
  and column_name in (
    'marca', 'presentacion', 'principio_activo',
    'concentracion', 'forma_farmaceutica'
  )
order by 1;

commit;
