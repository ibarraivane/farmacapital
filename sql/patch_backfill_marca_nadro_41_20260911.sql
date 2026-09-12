-- Backfill de marca (caja/anaquel) del ticket Nadro 1658128647824-01.
-- El alta no escribió la columna marca; el POS busca por marca/PA, pero iba vacío.
--
-- Solo marcas confirmadas (nombre POS o ficha de caja).
-- NO inventa marca para LGEN/AMSA solo-molécula.
-- Idempotente. EAN/SKU de sql/patch_alta_catalogo_nadro_41_20260831.sql
-- Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos p
set
  marca = v.marca,
  denominacion_distintiva = coalesce(nullif(btrim(p.denominacion_distintiva), ''), v.marca)
from (
  values
    ('7501008499412', 'FC-08499412', 'Flanax'),
    ('7501008499092', 'FC-08499092', 'Flanax'),
    ('7501008498866', 'FC-08498866', 'Flanax'),
    ('7501070600709', 'FC-70600709', 'Syncol'),
    ('354312225133', 'FC-12225133', 'Vitacilina'),
    ('354312225140', 'FC-12225140', 'Vitacilina'),
    ('7502321440013', 'FC-21440013', 'Buscapina'),
    ('7501165011649', 'FC-65011649', 'Buscapina'),
    ('7501019068911', 'FC-19068911', 'Saba'),
    ('7501058715913', 'FC-58715913', 'Picot'),
    ('7501019039355', 'FC-19039355', 'Saba'),
    ('7501349029613', 'FC-49029613', 'Combedi'),
    ('4005800631702', 'FC-00631702', 'Eucerin'),
    ('650240053634', 'FC-40053634', 'Alli'),
    ('7501019032424', 'FC-19032424', 'Saba'),
    ('7502268541491', 'FC-68541491', 'Electrolife'),
    ('75073107', 'FC-75073107', 'Rexona'),
    ('75073114', 'FC-75073114', 'Rexona'),
    ('4005900948670', 'FC-00948670', 'Labello'),
    ('7501054503637', 'FC-54503637', 'Labello'),
    ('7501019050473', 'FC-19050473', 'Tena'),
    ('7502256729917', 'FC-56729917', 'Inhala Care'),
    ('3337875784054', 'FC-75784054', 'CeraVe'),
    ('7501300450227', 'FC-00450227', 'Bactrim'),
    ('7501300450210', 'FC-00450210', 'Bactrim'),
    ('7502009740442', 'FC-09740442', 'Klarix'),
    ('7502227879597', 'FC-27879597', 'Tervutan'),
    ('7502227870259', 'FC-27870259', 'Roxidolin'),
    ('7501493888302', 'FC-93888302', 'Kenciclen'),
    ('7506442700643', 'FC-42700643', 'Camber')
) as v(ean, sku, marca)
where (p.codigo_barras = v.ean or p.sku = v.sku)
  and (p.marca is null or btrim(p.marca) = '');

-- Kenciclen: ticket "Ken LGEN" → caja Kenciclen (Kener).
update public.productos
set
  nombre = 'Kenciclen Doxiciclina 100 mg 10 cápsulas',
  marca = 'Kenciclen',
  denominacion_distintiva = 'Kenciclen',
  denominacion_generica = coalesce(nullif(btrim(denominacion_generica), ''), 'Doxiciclina'),
  principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Doxiciclina'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Caja con 10 cápsulas'),
  concentracion = coalesce(nullif(btrim(concentracion), ''), '100 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cápsulas'),
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Kener'),
  tipo = 'generico'
where (codigo_barras = '7501493888302' or sku = 'FC-93888302')
  and (
    nombre ilike '%ken%lgen%'
    or nombre ilike 'doxiciclina%'
    or marca is null
    or btrim(marca) = ''
    or marca = 'Kenciclen'
  );

update public.productos p
set principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), v.pa),
    denominacion_generica = coalesce(nullif(btrim(p.denominacion_generica), ''), v.pa)
from (
  values
    ('7501349026377', 'FC-49026377', 'Gentamicina'),
    ('7502216798878', 'FC-16798878', 'Pioglitazona'),
    ('7501349029613', 'FC-49029613', 'Complejo B / Dexametasona'),
    ('7501349013223', 'FC-49013223', 'Deflazacort'),
    ('7501349028234', 'FC-49028234', 'Omeprazol'),
    ('7501349022768', 'FC-49022768', 'Cefalotina'),
    ('7501125195105', 'FC-25195105', 'Cefuroxima'),
    ('7502009740442', 'FC-09740442', 'Claritromicina'),
    ('7502227879597', 'FC-27879597', 'Oxitetraciclina'),
    ('7502227870259', 'FC-27870259', 'Doxiciclina'),
    ('7501493888302', 'FC-93888302', 'Doxiciclina'),
    ('7506442700643', 'FC-42700643', 'Irbesartán + Hidroclorotiazida'),
    ('7501349022492', 'FC-49022492', 'Irbesartán'),
    ('7502216804708', 'FC-16804708', 'Irbesartán'),
    ('7506442700629', 'FC-42700629', 'Irbesartán'),
    ('7502216792760', 'FC-16792760', 'Omeprazol'),
    ('7502216792555', 'FC-16792555', 'Omeprazol')
) as v(ean, sku, pa)
where (p.codigo_barras = v.ean or p.sku = v.sku);

commit;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 56) as nombre,
  p.marca,
  p.principio_activo,
  p.tipo
from public.productos p
where p.sku in (
  'FC-08499412',
  'FC-08499092',
  'FC-08498866',
  'FC-70600709',
  'FC-12225133',
  'FC-12225140',
  'FC-21440013',
  'FC-65011649',
  'FC-49026377',
  'FC-16798878',
  'FC-19068911',
  'FC-58715913',
  'FC-19039355',
  'FC-49029613',
  'FC-00631702',
  'FC-40053634',
  'FC-19032424',
  'FC-68541491',
  'FC-75073107',
  'FC-75073114',
  'FC-49013223',
  'FC-00948670',
  'FC-54503637',
  'FC-19050473',
  'FC-56729917',
  'FC-75784054',
  'FC-00450227',
  'FC-49028234',
  'FC-00450210',
  'FC-49022768',
  'FC-25195105',
  'FC-09740442',
  'FC-27879597',
  'FC-27870259',
  'FC-93888302',
  'FC-42700643',
  'FC-49022492',
  'FC-16804708',
  'FC-42700629',
  'FC-16792760',
  'FC-16792555'
)
order by p.nombre;
