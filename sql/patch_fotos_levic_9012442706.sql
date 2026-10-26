-- Fotos Levic A 9012442706 — pegar DESPUÉS del deploy de public/catalogo-propia/
-- Solo rellena si imagen_url está vacía (no pisa foto mejor).

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/gabapentina-psicofarma-400-7501384541620.jpg',
    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), 'https://www.farmacapital.mx/catalogo-propia/gabapentina-psicofarma-400-7501384541620.jpg'),
    updated_at = now()
where codigo_barras = '7501384541620'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/rosuvastatina-alpharma-20mg-15tab.jpg',
    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), 'https://www.farmacapital.mx/catalogo-propia/rosuvastatina-alpharma-20mg-15tab.jpg'),
    updated_at = now()
where sku = 'EQ-ALP0675'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/cefalexina-amsa-500-7501349021181.jpg',
    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), 'https://www.farmacapital.mx/catalogo-propia/cefalexina-amsa-500-7501349021181.jpg'),
    updated_at = now()
where codigo_barras = '7501349021181'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/gabapentina-amsa-300-7501349020436.jpg',
    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), 'https://www.farmacapital.mx/catalogo-propia/gabapentina-amsa-300-7501349020436.jpg'),
    updated_at = now()
where codigo_barras = '7501349020436'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/telmisartan-beadvance-40-7501342803715.jpg',
    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), 'https://www.farmacapital.mx/catalogo-propia/telmisartan-beadvance-40-7501342803715.jpg'),
    updated_at = now()
where codigo_barras = '7501342803715'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/synalar-otico-15ml-7501088505485.jpg',
    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), 'https://www.farmacapital.mx/catalogo-propia/synalar-otico-15ml-7501088505485.jpg'),
    updated_at = now()
where codigo_barras = '7501088505485'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/adopren-600-7501842900105.jpg',
    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), 'https://www.farmacapital.mx/catalogo-propia/adopren-600-7501842900105.jpg'),
    updated_at = now()
where codigo_barras = '7501842900105'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/adopren-800-7501842952890.jpg',
    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), 'https://www.farmacapital.mx/catalogo-propia/adopren-800-7501842952890.jpg'),
    updated_at = now()
where codigo_barras = '7501842952890'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/natrazim-40-7501075721249.jpg',
    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), 'https://www.farmacapital.mx/catalogo-propia/natrazim-40-7501075721249.jpg'),
    updated_at = now()
where codigo_barras = '7501075721249'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/seltz-magnesio-complex-20tab.jpg',
    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), 'https://www.farmacapital.mx/catalogo-propia/seltz-magnesio-complex-20tab.jpg'),
    updated_at = now()
where sku = 'EQ-SET021'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/ibuprofeno-cafeina-gelpharma-7501478316813.jpg',
    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), 'https://www.farmacapital.mx/catalogo-propia/ibuprofeno-cafeina-gelpharma-7501478316813.jpg'),
    updated_at = now()
where codigo_barras = '7501478316813'
  and coalesce(nullif(imagen_url, ''), '') = '';

commit;
