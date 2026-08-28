-- ============================================================
-- FARMACAPITAL — Galería: varias imágenes por producto
-- ============================================================
-- Hoy `productos` solo tiene imagen_url / imagen_mobile_url: una foto
-- por producto. Este parche crea la tabla que permite N fotos con orden
-- y una marcada como principal, para el carrusel con flechas en Tienda,
-- POS e Inventario.
--
-- NO toca productos.imagen_url. Las fotos actuales siguen igual; la
-- galería es aditiva y la principal se decide después, a mano.
--
-- El origen inicial es catalogo_imagenes_rappi (1,812 fotos, 687
-- productos, ya vinculadas y subidas al bucket `productos`). La tabla
-- queda agnóstica al origen para poder sumar después los packshots de
-- catalogo-imagenes/aprobadas y las fotos propias.
--
-- Ejecutar en Supabase SQL Editor. Idempotente.
-- ============================================================

begin;

create table if not exists public.producto_imagenes (
  id            bigserial primary key,
  producto_id   integer not null references public.productos(id) on delete cascade,
  url           text not null,
  storage_path  text,
  posicion      integer not null default 1,
  es_principal  boolean not null default false,
  origen        text not null default 'rappi'
                  check (origen in ('rappi','distribuidor','propia','gs1','otro')),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Una misma foto no se repite en el producto; el orden tampoco choca.
create unique index if not exists ux_producto_imagenes_producto_url
  on public.producto_imagenes(producto_id, url);
create unique index if not exists ux_producto_imagenes_producto_posicion
  on public.producto_imagenes(producto_id, posicion);
create index if not exists idx_producto_imagenes_producto_id
  on public.producto_imagenes(producto_id);

-- Como máximo una principal por producto.
create unique index if not exists ux_producto_imagenes_una_principal
  on public.producto_imagenes(producto_id)
  where es_principal;

alter table public.producto_imagenes enable row level security;

-- Lectura pública: son fotos de catálogo, mismo criterio que `productos`.
drop policy if exists "Lectura pública de imágenes de producto" on public.producto_imagenes;
create policy "Lectura pública de imágenes de producto"
  on public.producto_imagenes for select
  to anon, authenticated
  using (
    exists (
      select 1 from public.productos p
      where p.id = producto_imagenes.producto_id
        and p.activo = true
    )
  );

grant select on public.producto_imagenes to anon, authenticated;

commit;

-- Comprobación (debe responder 0 filas por ahora; las siembro yo por API):
-- select count(*) from public.producto_imagenes;
