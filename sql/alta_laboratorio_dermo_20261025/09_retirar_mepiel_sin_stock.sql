-- OPCIONAL. Solo si ya cargaste MePiel / Dermaexpress y quieres
-- apagar la vitrina de esas fuentes cuando NO hay stock ni precio publicado
-- del dueño. NO borra productos ni toca anaquel.
--
-- Revisa el select de conteo ANTES del update.

-- Conteo previo
select
  count(*) filter (where r.fuente = 'mepiel') as refs_mepiel,
  count(*) filter (where r.fuente = 'dermaexpress') as refs_derma
from public.producto_precios_referencia r
where r.fecha >= current_date - 120;

-- Apaga vitrina MePiel sin stock (no toca precio > 0 publicado)
begin;

update public.productos p
   set bajo_pedido = false,
       activo = case
         when coalesce(p.precio, 0) > 0.01 then p.activo
         else false
       end
 where coalesce(p.stock, 0) = 0
   and coalesce(p.bajo_pedido, false) = true
   and exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id
        and r.fuente = 'mepiel'
   )
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id
        and r.fuente in ('svr', 'alastin', 'medik8')
   );

commit;
