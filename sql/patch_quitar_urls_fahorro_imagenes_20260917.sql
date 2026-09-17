-- ============================================================================
-- FarmaCapital — 2026-09-17
-- Quitar hotlinks a Del Ahorro (fahorro.com) de imagen_url / galería.
-- No borra packshots en catalogo-propia/ ni Storage propio.
-- Tras correr: productos sin foto propia quedan sin imagen (ícono vacío),
-- nunca con el logo rosa «A» de la competencia.
-- ============================================================================

begin;

update public.productos
   set imagen_url = null
 where imagen_url ilike '%fahorro.com%';

update public.productos
   set imagen_mobile_url = null
 where imagen_mobile_url ilike '%fahorro.com%';

delete from public.producto_imagenes
 where url ilike '%fahorro.com%';

commit;

select
  (select count(*) from public.productos where imagen_url ilike '%fahorro.com%') as productos_con_fahorro,
  (select count(*) from public.producto_imagenes where url ilike '%fahorro.com%') as galeria_con_fahorro;
