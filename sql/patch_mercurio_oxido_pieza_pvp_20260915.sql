-- Mercurio óxido de zinc C/50: se compra la CAJA y se vende por PIEZA.
-- El costo $1.08 (54/50) ya está. El PVP $54 era el de la caja.
-- La otra ficha de pieza (FC-0ACC5B6A) ya cobra $14.
-- No se inventa caducidad. No se multiplica el stock.
--
-- Idempotente. Supabase → SQL Editor → Run.

begin;

update public.productos
   set
     precio = 14,
     presentacion = 'pieza (caja C/50)',
     descripcion = trim(both from coalesce(descripcion, '') ||
       case
         when coalesce(descripcion, '') ilike '%vende por pieza%' then ''
         else ' · caja C/50 se vende por pieza'
       end)
 where sku = 'FC-C4530823'
   and activo = true
   and precio >= 50
   and precio <= 90;

commit;

select sku, left(nombre, 40) as nombre, presentacion, costo, precio, stock
from public.productos
where sku in ('FC-C4530823', 'FC-0ACC5B6A')
order by sku;
