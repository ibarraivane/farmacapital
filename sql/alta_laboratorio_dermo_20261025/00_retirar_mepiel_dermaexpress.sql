-- ============================================================================
-- OBLIGATORIO primero: sacar de inventario/vitrina lo cargado desde
-- listas de páginas (MePiel, Dermaexpress). NO toca anaquel con stock > 0.
-- NO toca Birdman / Ewafra. Las altas de laboratorio (SVR/Alastin/Medik8)
-- que siguen vuelven a activar solo lo pedible al lab.
-- ============================================================================

-- Conteo previo (revisar antes del update)
select
  count(*) filter (
    where coalesce(p.stock, 0) = 0
      and (
        exists (
          select 1 from public.producto_precios_referencia r
           where r.producto_id = p.id
             and r.fuente in ('mepiel', 'dermaexpress')
        )
        or coalesce(p.descripcion, '') ~* 'Bajo pedido ·[[:space:]]*(mepiel|dermaexpress|me[[:space:]]*piel)'
        or coalesce(p.descripcion, '') ~* '(^|[[:space:]])(mepiel|dermaexpress)([[:space:]]|$)'
      )
  ) as a_retirar_sin_stock,
  count(*) filter (
    where coalesce(p.stock, 0) > 0
      and (
        exists (
          select 1 from public.producto_precios_referencia r
           where r.producto_id = p.id
             and r.fuente in ('mepiel', 'dermaexpress')
        )
      )
  ) as con_stock_se_conservan
from public.productos p;

begin;

update public.productos p
   set bajo_pedido = false,
       activo = false
 where coalesce(p.stock, 0) = 0
   and (
     exists (
       select 1 from public.producto_precios_referencia r
        where r.producto_id = p.id
          and r.fuente in ('mepiel', 'dermaexpress')
     )
     or coalesce(p.descripcion, '') ~* 'Bajo pedido ·[[:space:]]*(mepiel|dermaexpress|me[[:space:]]*piel)'
   )
   -- No apagar lo que ya quedó marcado como lab (por si se re-corre)
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id
        and r.fuente in ('svr', 'alastin', 'medik8')
   )
   -- Birdman / Ewafra siguen
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id
        and r.fuente in ('birdman', 'ewafra')
   );

commit;

select
  count(*) filter (where coalesce(bajo_pedido, false) and coalesce(activo, false)) as vitrina_activa,
  count(*) filter (where marca ilike 'alastin' and coalesce(activo, false)) as alastin_activos,
  count(*) filter (where marca ilike 'medik8' and coalesce(activo, false)) as medik8_activos,
  count(*) filter (where marca ilike 'svr' and coalesce(activo, false)) as svr_activos
from public.productos;
