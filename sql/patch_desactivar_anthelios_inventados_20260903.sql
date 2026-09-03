-- ============================================================================
-- FARMA CAPITAL — Quitar las 4 altas inventadas de Anthelios UV Mune 400 50 ml
--
-- El 3-sep se cargaron cuatro SKU que Nadro vende, pero que NO vinieron en
-- ningún ticket (stock 0, sin lotes, $522). En POS “la roch” salían cuatro
-- tarjetas idénticas: “La Roche Anthelios · 50 ml · Fluido”.
--
-- El bloqueador del ticket Nadro 20260901 es otro:
--   EAN 3337875917810 · Anthelios UV Air 40 ml · NO se toca.
--
-- Solo desactiva si sigue en 0 y nadie lo vendió. Idempotente.
-- Pegar en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

update public.productos p
   set activo = false,
       descripcion = trim(both ' ·' from concat_ws(
         ' · ',
         nullif(trim(both ' ·' from coalesce(p.descripcion, '')), ''),
         'desactivado 2026-09-03: alta inventada, no vino en ticket'
       ))
 where p.codigo_barras in (
        '3337875797597',  -- UV Mune 400 fluido invisible 50 ml
        '3337875797641',  -- UV Mune 400 fluido con color 50 ml
        '3337875847292',  -- UV Mune 400 oil control 50 ml
        '3337875847087'   -- UV Mune 400 oil control con color 50 ml
      )
   and p.codigo_barras <> '3337875917810'
   and p.activo is distinct from false
   and coalesce(p.stock, 0) = 0
   and coalesce(p.stock_unidades, 0) = 0
   and not exists (
         select 1 from public.lotes l
          where l.producto_id = p.id
            and coalesce(l.cantidad_actual, 0) > 0
       )
   and not exists (
         select 1 from public.pedido_items pi
          where pi.producto_id = p.id
       );

update public.lotes l
   set activo = false
 where l.producto_id in (
         select p.id
           from public.productos p
          where p.codigo_barras in (
                 '3337875797597',
                 '3337875797641',
                 '3337875847292',
                 '3337875847087'
               )
            and p.activo = false
       )
   and coalesce(l.cantidad_actual, 0) = 0
   and l.activo is distinct from false;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.activo,
  p.stock,
  p.precio
from public.productos p
where p.codigo_barras in (
  '3337875797597',
  '3337875797641',
  '3337875847292',
  '3337875847087',
  '3337875917810'
)
order by p.codigo_barras;
