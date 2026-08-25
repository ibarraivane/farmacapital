-- ============================================================================
-- FARMA CAPITAL — Lote ordenadas 3 · nombres según fotos  16-ago-2026
--
-- Las fotos van en pares (portada + código del MISMO producto).
-- En el lote 3 varios EAN se cargaron con el nombre de otra caja.
-- Aquí se corrige la identidad. No toca costo, precio ni stock.
--
-- Correr DESPUÉS de patch_lote_ordenadas3_20260816.sql
-- (o solo). Idempotente. No va en transacción.
--
-- Qué hace:
--   1) Renombra 5 SKU cuyo EAN+costo ya eran del producto de la foto.
--   2) Pasa el EAN de Galaver sobres de un fantasma (Treda, stock 1, costo 0)
--      a EQ-MAV263 (el del ticket). El fantasma se queda sin EAN, activo.
--   3) Quita el EAN de X-TRID que estaba en ML-PRIM, se lo pone a EQ-GEP049,
--      y le pone a ML-PRIM el EAN de su propia foto.
--
-- No desactiva nada. Laritol 10 tab no se crea.
-- ============================================================================

-- 1) Identidad: el EAN ya es el correcto; el nombre/PA/marca no.
update public.productos set
  nombre = 'Exaliv (Paracetamol / Fenilefrina / Clorfenamina) 24 tabletas',
  presentacion = 'Caja con 24 tabletas',
  principio_activo = 'Paracetamol / Fenilefrina / Clorfenamina',
  denominacion_generica = 'Paracetamol / Fenilefrina / Clorfenamina',
  forma_farmaceutica = 'Tableta',
  marca = 'Maver',
  concentracion = '325 mg / 5 mg / 2 mg',
  unidades_por_caja = case when unidades_por_caja is null or unidades_por_caja = 0 then 24 else unidades_por_caja end,
  activo = true
where sku = 'FC-09747236'
  and codigo_barras = '7502009747236';

update public.productos set
  nombre = 'Novagon polvo sabor natural 400 g',
  presentacion = 'Frasco 400 g sabor natural',
  principio_activo = 'Plantago psyllium',
  denominacion_generica = 'Plantago psyllium',
  forma_farmaceutica = 'Polvo',
  marca = 'Novag',
  concentracion = '49.70 g / 100 g',
  activo = true
where sku = 'FC-75713770'
  and codigo_barras = '7501075713770';

update public.productos set
  nombre = 'Galaver gel 250 mL (Magaldrato / Dimeticona)',
  presentacion = 'Frasco 250 mL',
  principio_activo = 'Magaldrato / Dimeticona',
  denominacion_generica = 'Magaldrato / Dimeticona',
  forma_farmaceutica = 'Gel',
  marca = 'Maver',
  concentracion = '8 g / 1 g / 100 mL',
  activo = true
where sku = 'FC-09745027'
  and codigo_barras = '7502009745027';

update public.productos set
  nombre = 'Supratex (Levodropropizina) jarabe 120 mL',
  presentacion = 'Frasco 120 mL',
  principio_activo = 'Levodropropizina',
  denominacion_generica = 'Levodropropizina',
  forma_farmaceutica = 'Jarabe',
  marca = 'MAVI',
  concentracion = '600 mg / 100 mL',
  activo = true
where sku = 'FC-18754259'
  and codigo_barras = '785118754259';

update public.productos set
  nombre = 'Bioxover (Dropropizina) jarabe 120 mL',
  presentacion = 'Frasco 120 mL',
  principio_activo = 'Dropropizina',
  denominacion_generica = 'Dropropizina',
  forma_farmaceutica = 'Jarabe',
  marca = 'Maver',
  concentracion = '3 mg / mL',
  activo = true
where sku = 'FC-09745560'
  and codigo_barras = '7502009745560';


-- 2) Galaver sobres: el EAN está en el fantasma Treda (costo 0, stock 1).
--    El producto del ticket es EQ-MAV263 (costo 37.54, stock 4).
update public.productos
   set codigo_barras = null
 where sku = 'FC-09745522'
   and codigo_barras = '7502009745522';

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7502009745522' else codigo_barras end,
  presentacion = coalesce(nullif(presentacion,''), 'Caja con 10 sobres de 10 mL'),
  principio_activo = coalesce(nullif(principio_activo,''), 'Magaldrato / Dimeticona'),
  denominacion_generica = coalesce(nullif(denominacion_generica,''), 'Magaldrato / Dimeticona'),
  forma_farmaceutica = coalesce(nullif(forma_farmaceutica,''), 'Gel'),
  marca = coalesce(nullif(marca,''), 'Maver'),
  concentracion = coalesce(nullif(concentracion,''), '80 mg / 10 mg / 1 mL'),
  unidades_por_caja = case when unidades_por_caja is null or unidades_por_caja = 0 then 10 else unidades_por_caja end,
  activo = true
where sku = 'EQ-MAV263';


-- 3) ML-PRIM se quedó con el EAN de X-TRID. Primero se suelta, luego se
--    acomoda cada uno con el de su foto.
update public.productos
   set codigo_barras = null
 where sku = 'FC-27427392'
   and codigo_barras = '7502227427392';

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7502227427392' else codigo_barras end,
  presentacion = coalesce(nullif(presentacion,''), 'Caja con 12 cápsulas'),
  forma_farmaceutica = coalesce(nullif(forma_farmaceutica,''), 'Cápsula'),
  marca = coalesce(nullif(marca,''), 'GEL pharma'),
  concentracion = coalesce(nullif(concentracion,''), '15 mg / 5 mg / 2 mg / 250 mg'),
  unidades_por_caja = case when unidades_por_caja is null or unidades_por_caja = 0 then 12 else unidades_por_caja end,
  activo = true
where sku = 'EQ-GEP049';

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7502227426982' else codigo_barras end,
  activo = true
where sku = 'FC-27427392';


select sku, nombre, codigo_barras, presentacion, principio_activo, marca,
       concentracion, costo, precio, stock, activo
from public.productos
where sku in (
  'FC-09747236','FC-75713770','FC-09745027','FC-18754259','FC-09745560',
  'FC-09745522','EQ-MAV263','FC-27427392','EQ-GEP049'
)
order by sku;
