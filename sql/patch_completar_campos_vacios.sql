-- ============================================================================
-- COMPLETAR campos vacíos — inventario (NO pisa precios ni nombres editados)
-- 6 updates · solo rellena NULL/vacío
-- Ejecutar después de exportar catálogo fresco
-- ============================================================================

begin;


-- [1] FC-06247327 · Afrin No Drip extra humectante spray
update public.productos set
  presentacion = CASE WHEN presentacion IS NULL OR btrim(presentacion) = '' THEN '15 mL' ELSE presentacion END,
  principio_activo = CASE WHEN principio_activo IS NULL OR btrim(principio_activo) = '' THEN 'Oximetazolina clorhidrato' ELSE principio_activo END,
  concentracion = CASE WHEN concentracion IS NULL OR btrim(concentracion) = '' THEN '0.05%' ELSE concentracion END,
  forma_farmaceutica = CASE WHEN forma_farmaceutica IS NULL OR btrim(forma_farmaceutica) = '' THEN 'Solución nasal' ELSE forma_farmaceutica END
where sku = 'FC-06247327'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );

-- [2] FC-06134531 · Afrin Adulto rojo spray
update public.productos set
  concentracion = CASE WHEN concentracion IS NULL OR btrim(concentracion) = '' THEN '0.05%' ELSE concentracion END
where sku = 'FC-06134531'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );

-- [3] FC-49853867 · Softlub Extra condones C/3
update public.productos set
  principio_activo = CASE WHEN principio_activo IS NULL OR btrim(principio_activo) = '' THEN 'Latex' ELSE principio_activo END
where sku = 'FC-49853867'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );

-- [4] FC-DB4A39AE · Eferox (Cefalexina)
update public.productos set
  principio_activo = CASE WHEN principio_activo IS NULL OR btrim(principio_activo) = '' THEN 'Cefalexina' ELSE principio_activo END
where sku = 'FC-DB4A39AE'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );

-- [5] FC-F8691496 · Bactiver F (Sulfametoxazol/Trimetoprima)
update public.productos set
  principio_activo = CASE WHEN principio_activo IS NULL OR btrim(principio_activo) = '' THEN 'SULFAMETOXAZOL + TRIMETOPRIMA' ELSE principio_activo END
where sku = 'FC-F8691496'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );

-- [6] FC-86708021 · Protec termómetro digital
update public.productos set
  forma_farmaceutica = CASE WHEN forma_farmaceutica IS NULL OR btrim(forma_farmaceutica) = '' THEN 'Material de curación' ELSE forma_farmaceutica END
where sku = 'FC-86708021'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );
commit;

select
  count(*) filter (where codigo_barras is null or btrim(codigo_barras) = '') as sin_barcode,
  count(*) filter (where presentacion is null or btrim(presentacion) = '') as sin_presentacion,
  count(*) filter (where principio_activo is null or btrim(principio_activo) = '') as sin_pa
from public.productos;
