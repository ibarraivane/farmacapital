-- Quita de productos.descripcion (y presentacion si se usó como nota)
-- el texto de dónde se compró: Dulcería La Victoria, La Famosa, Nadro,
-- EAN pendiente, ticket decía… El cliente no debe ver eso en la web.
--
-- No toca fichas reales (ej. "Aspirina Bayer … EAN 7501…").
-- Recibir / POS siguen viendo el proveedor en recepciones.notas.
-- Idempotente. Pegar en Supabase → SQL Editor → Run.

begin;

update public.productos
set descripcion = null
where descripcion is not null
  and btrim(descripcion) <> ''
  and (
    descripcion ~* '^(alta|ticket|factura)\s'
    or descripcion ~* '^nota\s+t[0-9]'
    or descripcion ~* 'ean pendiente'
    or descripcion ~* 'pendiente de caja'
    or descripcion ~* 'ticket\s+dec'
    or descripcion ~* 'ticket\s+imprime'
    or descripcion ~* 'falta c[oó]digo de barras'
    or descripcion ~* 'c[oó]digo de proveedor'
    or descripcion ~* 'clave de proveedor'
    or descripcion ~* 'listo para pistola'
    or descripcion ~* 'dulcer[ií]a la victoria'
    or descripcion ~* 'la famosa'
  );

update public.productos
set presentacion = null
where presentacion is not null
  and btrim(presentacion) <> ''
  and (
    presentacion ~* '^(alta|ticket|factura)\s'
    or presentacion ~* 'ean pendiente'
    or presentacion ~* 'ticket\s+dec'
    or presentacion ~* 'dulcer[ií]a la victoria'
    or presentacion ~* 'la famosa'
  );

select sku, left(nombre, 40) as nombre, left(coalesce(descripcion, ''), 80) as desc_restante
from public.productos
where descripcion ilike '%ticket%'
   or descripcion ilike 'Alta %'
   or descripcion ilike '%Victoria%'
   or descripcion ilike '%Famosa%'
   or descripcion ilike '%EAN pendiente%';

commit;
