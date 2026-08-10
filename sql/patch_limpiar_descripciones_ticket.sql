-- Quita descripciones que son basura OCR del ticket (precios, Lab Pisa, etc.)
-- El POS ya usa texto de uso desde catálogo local, no este campo.
-- Idempotente.

begin;

update public.productos
set descripcion = null
where descripcion is not null
  and (
    descripcion ~* 'descto|ticket\s|lab\s+pisa|\|\s*lab'
    or descripcion ~ '\$'
    or (length(descripcion) > 60 and descripcion ~ '\d+[.,]\d{2}')
  );

select count(*) as descripciones_restantes_no_nulas
from public.productos
where descripcion is not null and btrim(descripcion) <> '';

commit;
