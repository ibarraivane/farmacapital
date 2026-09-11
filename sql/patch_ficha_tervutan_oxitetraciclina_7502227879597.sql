-- Oxitetraciclina EAN 7502227879597 (FC-27879597)
-- Alta Nadro 1658128647824-01 dejó solo el genérico; en caja/anaquel es Tervutan.
-- Misma lógica que Klarix/Roxidolin del mismo ticket: marca + molécula en nombre.
-- Fuentes: Prixz / Farmacias Liz / Sufarmed · EAN 7502227879597 · lab RAAM.
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set
  nombre = 'Tervutan Oxitetraciclina 500 mg 16 cápsulas',
  marca = 'Tervutan',
  denominacion_distintiva = 'Tervutan',
  denominacion_generica = coalesce(nullif(btrim(denominacion_generica), ''), 'Oxitetraciclina'),
  principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Oxitetraciclina'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Caja con 16 cápsulas'),
  concentracion = coalesce(nullif(btrim(concentracion), ''), '500 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cápsulas'),
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'RAAM'),
  tipo = 'generico',
  categoria = coalesce(nullif(btrim(categoria), ''), 'Medicamentos'),
  descripcion = case
    when descripcion is null
      or btrim(descripcion) = ''
      or descripcion ilike 'Alta Nadro%'
      or descripcion ilike '%listo para pistola%'
      then 'Tervutan (oxitetraciclina 500 mg). Antibiótico; caja con 16 cápsulas. Requiere receta.'
    else descripcion
  end,
  activo = true
where codigo_barras = '7502227879597'
   or sku = 'FC-27879597';

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.denominacion_distintiva,
  p.principio_activo,
  p.presentacion,
  p.concentracion,
  p.forma_farmaceutica,
  p.laboratorio,
  p.tipo,
  p.precio,
  p.stock
from public.productos p
where p.codigo_barras = '7502227879597'
   or p.sku = 'FC-27879597';
