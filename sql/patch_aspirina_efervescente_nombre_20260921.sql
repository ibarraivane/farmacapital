-- ============================================================================
-- FarmaCapital — 2026-09-21
-- Aspirina Eferv (EAN 7501008496701): el ticket recortó el nombre.
-- En mostrador / tienda debe decir el producto real, no «Eferv».
--
-- Pegar en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

update public.productos
   set nombre = 'Aspirina Efervescente',
       marca = 'Bayer',
       presentacion = 'Caja con 12',
       forma_farmaceutica = 'Tabletas efervescentes',
       principio_activo = 'Ácido acetilsalicílico',
       descripcion = null
 where sku = 'FC-08496701'
    or codigo_barras = '7501008496701';

commit;

select id, sku, nombre, marca, presentacion, forma_farmaceutica, principio_activo, codigo_barras
  from public.productos
 where sku = 'FC-08496701'
    or codigo_barras = '7501008496701';
