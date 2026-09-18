-- ============================================================================
-- FarmaCapital — 2026-09-18
-- Vitrina /conseguir (dermatología, vitaminas, suplementos, proteína,
-- dispositivos médicos): el dueño no ha revisado los precios.
--
-- precio = 0. La tienda muestra el botón «Ordenar» y no publica cifra.
-- Conserva costo de mayoreo (para cotizar después). No toca anaquel (stock > 0).
-- No toca Accu-Chek Softclix 25/100: ese PVP sí lo fijó el dueño
--   (4015630018277 = $85, 4015630018284 = $180).
--
-- Pegar en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

update public.productos
   set precio = 0
 where coalesce(bajo_pedido, false) = true
   and coalesce(stock, 0) = 0
   and coalesce(precio, 0) > 0.01
   and coalesce(codigo_barras, '') not in ('4015630018277', '4015630018284');

commit;

select
  case
    when categoria = 'Cuidado personal'
     and coalesce(subcategoria, '') ilike 'dermatolog%' then 'Dermatología'
    when categoria = 'Vitaminas' then 'Vitaminas'
    when categoria = 'Suplemento'
     and (coalesce(subcategoria, '') ilike 'protein%'
       or coalesce(subcategoria, '') ilike 'nutricion deport%') then 'Proteína'
    when categoria = 'Suplemento' then 'Suplementos'
    when categoria in ('Dispositivo médico', 'Botiquín') then 'Dispositivos médicos'
    else 'Otro bajo pedido'
  end as rubro,
  count(*) as productos,
  count(*) filter (where coalesce(precio, 0) <= 0.01) as sin_precio,
  count(*) filter (where coalesce(precio, 0) > 0.01) as con_precio
from public.productos
where coalesce(bajo_pedido, false) = true
group by 1
order by 1;
