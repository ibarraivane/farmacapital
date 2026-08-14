-- ============================================================================
-- Nombres Electrolit con sabor (ejecutar una vez si aún no están limpios)
-- Cantidades de TODOS los tickets: sql/patch_cantidades_tickets_completo.sql
-- ============================================================================

begin;

update public.productos set nombre = 'Electrolit Uva', marca = 'Electrolit', presentacion = '525 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca' where sku = 'FC-51448511';
update public.productos set nombre = 'Electrolit Coco', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca' where sku = 'FC-25104411';
update public.productos set nombre = 'Electrolit Eresa-Kiwi', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca' where sku = 'FC-25149221';
update public.productos set nombre = 'Electrolit Fresa', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca' where sku = 'FC-25104268';
update public.productos set nombre = 'Electrolit Mora Azul', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca' where sku = 'FC-51747971';

commit;
