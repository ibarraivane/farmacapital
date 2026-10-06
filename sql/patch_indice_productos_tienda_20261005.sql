-- Tienda: la lectura de productos activos se cancelaba con 57014
-- (canceling statement due to statement timeout) al pedir el catálogo.
-- Índice para `activo = true` ordenado por id, anaquel y vitrina por separado.
-- Pegar en Supabase → SQL Editor. No cambia datos.

create index if not exists idx_productos_tienda_activo_id
  on public.productos (activo, id);

create index if not exists idx_productos_tienda_anaquel
  on public.productos (id)
  where activo is true and bajo_pedido is not true;

create index if not exists idx_productos_tienda_vitrina
  on public.productos (id)
  where activo is true and bajo_pedido is true;
