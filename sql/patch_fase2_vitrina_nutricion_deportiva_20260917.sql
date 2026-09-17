-- ============================================================================
-- FARMA CAPITAL — Fase 2 vitrina: Nutrición deportiva (reclasificar)
-- 17-sep-2026
--
-- NO inserta SKUs. NO marca bajo_pedido. NO toca stock, precio ni foto.
-- Solo pone subcategoria = 'Nutrición deportiva' en suplementos que ya
-- son proteína / creatina / pre-entreno / whey / BCAA.
--
-- Excluye pancreatina (digestivo) y shampoo / cabello con «proteína».
-- Si hay stock de anaquel, el renglón se queda en anaquel (esta sentencia
-- no escribe productos.bajo_pedido).
--
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.
-- ============================================================================

begin;

update public.productos p
   set subcategoria = 'Nutrición deportiva'
 where p.activo is not false
   and lower(translate(coalesce(p.categoria, ''),
         'áéíóúüñÁÉÍÓÚÜÑ',
         'aeiouunAEIOUUN')) in ('suplemento', 'suplementos')
   and coalesce(p.subcategoria, '') is distinct from 'Nutrición deportiva'
   and (
     lower(translate(coalesce(p.subcategoria, ''),
       'áéíóúüñÁÉÍÓÚÜÑ',
       'aeiouunAEIOUUN')) ~ '^(protein|nutricion deport|deport)'
     or (
       lower(translate(
         coalesce(p.subcategoria, '') || ' ' || coalesce(p.nombre, ''),
         'áéíóúüñÁÉÍÓÚÜÑ',
         'aeiouunAEIOUUN'
       )) ~ '(^|[^a-z])(creatina|whey|preentren|pre entren|bcaa|aminoacido|ganador de peso|mass gainer)([^a-z]|$)'
       or lower(translate(
         coalesce(p.subcategoria, '') || ' ' || coalesce(p.nombre, ''),
         'áéíóúüñÁÉÍÓÚÜÑ',
         'aeiouunAEIOUUN'
       )) ~ '(proteina 90|proteina vegetal|proteina whey|proteina en polvo|proteina isolate|proteina low)'
     )
   )
   and lower(translate(
     coalesce(p.subcategoria, '') || ' ' || coalesce(p.nombre, ''),
     'áéíóúüñÁÉÍÓÚÜÑ',
     'aeiouunAEIOUUN'
   )) !~ 'pancreatin'
   and lower(translate(
     coalesce(p.subcategoria, '') || ' ' || coalesce(p.nombre, ''),
     'áéíóúüñÁÉÍÓÚÜÑ',
     'aeiouunAEIOUUN'
   )) !~ '(shampoo|acondicionador|peinar|cabello|capilar)';

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.categoria,
  p.subcategoria,
  p.stock,
  p.bajo_pedido,
  p.activo
from public.productos p
where p.activo is not false
  and p.subcategoria = 'Nutrición deportiva'
order by p.bajo_pedido desc, p.nombre;
