-- FARMACAPITAL — copia la foto de galería a productos.imagen_url
-- cuando la portada está vacía. No busca ni sube nada: usa lo que
-- ya está en public.producto_imagenes (10 SKUs del corte 2026-09-15).
-- Idempotente. Pegar en Supabase → SQL Editor → Run.

begin;

update public.productos p
set imagen_url = e.url,
    imagen_mobile_url = e.url
from (
  select distinct on (producto_id) producto_id, url
  from public.producto_imagenes
  where coalesce(btrim(url), '') <> ''
  order by producto_id, es_principal desc, posicion asc, id asc
) e
where e.producto_id = p.id
  and coalesce(btrim(p.imagen_url), '') = '';

commit;
