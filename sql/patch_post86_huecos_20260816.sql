-- ============================================================================
-- FARMA CAPITAL — Post 86 fotos · huecos + duplicados  16-ago-2026
--
-- Los dos SQL de las fotos ya corrieron (nombres OK). Esto cierra
-- lo que quedó mal o a medias. No crea SKU. No toca stock.
--
-- 1) 5 EAN de las fotos que no se pegaron (hoy no los tiene nadie).
-- 2) EAN de internet, solo si el producto y la presentación coinciden
--    y el código está libre (o se mueve de un fantasma stock 0).
-- 3) Apaga duplicados de tipeo que repiten el mismo costo/stock
--    de un EQ- que ya tiene código. El bueno se queda activo.
-- 4) Precio en los que tienen costo y precio 0 (regla genérico: ceil 60%).
--
-- Idempotente. No va en transacción.
-- ============================================================================

-- 1) Reintento EAN de fotos (libres ahora)
update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7502001165397' else codigo_barras end,
  activo = true
where sku = 'EQ-SON233'
  and not exists (select 1 from public.productos o where o.codigo_barras = '7502001165397' and o.sku <> 'EQ-SON233');

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7502211784029' else codigo_barras end,
  activo = true
where sku = 'FC-52D2A43A'
  and not exists (select 1 from public.productos o where o.codigo_barras = '7502211784029' and o.sku <> 'FC-52D2A43A');

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7502223111202' else codigo_barras end,
  activo = true
where sku = 'EQ-QUM014'
  and not exists (select 1 from public.productos o where o.codigo_barras = '7502223111202' and o.sku <> 'EQ-QUM014');

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7501349022485' else codigo_barras end,
  activo = true
where sku = 'EQ-AMS292'
  and not exists (select 1 from public.productos o where o.codigo_barras = '7501349022485' and o.sku <> 'EQ-AMS292');

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7501109763986' else codigo_barras end,
  activo = true
where sku = 'EQ-QUI091'
  and not exists (select 1 from public.productos o where o.codigo_barras = '7501109763986' and o.sku <> 'EQ-QUI091');


-- 2a) Internet, código libre, misma presentación
update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7501349023369' else codigo_barras end,
  presentacion = coalesce(nullif(presentacion,''), 'Caja con 6 tabletas sublinguales'),
  principio_activo = coalesce(nullif(principio_activo,''), 'Ketorolaco trometamina'),
  denominacion_generica = coalesce(nullif(denominacion_generica,''), 'Ketorolaco trometamina'),
  forma_farmaceutica = coalesce(nullif(forma_farmaceutica,''), 'Tableta sublingual'),
  marca = coalesce(nullif(marca,''), 'AMSA'),
  concentracion = coalesce(nullif(concentracion,''), '30 mg'),
  unidades_por_caja = case when unidades_por_caja is null or unidades_por_caja = 0 then 6 else unidades_por_caja end,
  activo = true
where sku = 'EQ-AMS160'
  and not exists (select 1 from public.productos o where o.codigo_barras = '7501349023369' and o.sku <> 'EQ-AMS160');

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7501836000927' else codigo_barras end,
  presentacion = coalesce(nullif(presentacion,''), 'Frasco 120 mL'),
  principio_activo = coalesce(nullif(principio_activo,''), 'Ketoconazol'),
  denominacion_generica = coalesce(nullif(denominacion_generica,''), 'Ketoconazol'),
  forma_farmaceutica = coalesce(nullif(forma_farmaceutica,''), 'Shampoo'),
  marca = coalesce(nullif(marca,''), 'Liferpal'),
  concentracion = coalesce(nullif(concentracion,''), '2 g / 100 mL'),
  activo = true
where sku = 'EQ-LIF039'
  and not exists (select 1 from public.productos o where o.codigo_barras = '7501836000927' and o.sku <> 'EQ-LIF039');

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '0020800790246' else codigo_barras end,
  presentacion = coalesce(nullif(presentacion,''), 'Bote 504 g sabor natural'),
  principio_activo = coalesce(nullif(principio_activo,''), 'Plantago psyllium'),
  denominacion_generica = coalesce(nullif(denominacion_generica,''), 'Plantago psyllium'),
  forma_farmaceutica = coalesce(nullif(forma_farmaceutica,''), 'Polvo'),
  marca = coalesce(nullif(marca,''), 'Metamucil'),
  activo = true
where sku = 'EQ-PYG016'
  and not exists (select 1 from public.productos o where o.codigo_barras in ('0020800790246','20800790246','020800790246') and o.sku <> 'EQ-PYG016');


-- 2b) El EAN está en un fantasma (stock 0, costo 0). El ticket tiene el stock.
--     Se suelta del fantasma y se pone en el EQ- real.
update public.productos set codigo_barras = null
where sku = 'FC-49025943' and codigo_barras = '7501349025943' and coalesce(stock,0) = 0;

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7501349025943' else codigo_barras end,
  presentacion = coalesce(nullif(presentacion,''), 'Caja con 28 cápsulas'),
  principio_activo = coalesce(nullif(principio_activo,''), 'Pregabalina'),
  denominacion_generica = coalesce(nullif(denominacion_generica,''), 'Pregabalina'),
  forma_farmaceutica = coalesce(nullif(forma_farmaceutica,''), 'Cápsula'),
  marca = coalesce(nullif(marca,''), 'AMSA'),
  concentracion = coalesce(nullif(concentracion,''), '75 mg'),
  unidades_por_caja = case when unidades_por_caja is null or unidades_por_caja = 0 then 28 else unidades_por_caja end,
  activo = true
where sku = 'EQ-AMS232';

update public.productos set activo = false
where sku = 'FC-49025943' and coalesce(stock,0) = 0;

update public.productos set codigo_barras = null
where sku = 'FC-09858046' and codigo_barras = '7502209858046' and coalesce(stock,0) = 0;

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7502209858046' else codigo_barras end,
  presentacion = coalesce(nullif(presentacion,''), 'Caja con 14 tabletas'),
  principio_activo = coalesce(nullif(principio_activo,''), 'Meloxicam'),
  denominacion_generica = coalesce(nullif(denominacion_generica,''), 'Meloxicam'),
  forma_farmaceutica = coalesce(nullif(forma_farmaceutica,''), 'Tableta'),
  marca = coalesce(nullif(marca,''), 'Avitus'),
  concentracion = coalesce(nullif(concentracion,''), '7.5 mg'),
  unidades_por_caja = case when unidades_por_caja is null or unidades_por_caja = 0 then 14 else unidades_por_caja end,
  activo = true
where sku = 'EQ-AVT213';

update public.productos set activo = false
where sku = 'FC-09858046' and coalesce(stock,0) = 0;

update public.productos set codigo_barras = null
where sku = 'FC-73900436' and codigo_barras = '7501573900436' and coalesce(stock,0) = 0;

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7501573900436' else codigo_barras end,
  presentacion = coalesce(nullif(presentacion,''), 'Caja con 30 tabletas'),
  principio_activo = coalesce(nullif(principio_activo,''), 'Pravastatina'),
  denominacion_generica = coalesce(nullif(denominacion_generica,''), 'Pravastatina'),
  forma_farmaceutica = coalesce(nullif(forma_farmaceutica,''), 'Tableta'),
  marca = coalesce(nullif(marca,''), 'Biomep'),
  concentracion = coalesce(nullif(concentracion,''), '10 mg'),
  unidades_por_caja = case when unidades_por_caja is null or unidades_por_caja = 0 then 30 else unidades_por_caja end,
  activo = true
where sku = 'EQ-BIO017';

update public.productos set activo = false
where sku = 'FC-73900436' and coalesce(stock,0) = 0;


-- Playboy: el EQ- del ticket tiene costo/precio; el FC- de la foto tiene el EAN.
-- Se pasa el EAN al EQ- y se apaga el FC- (mismo stock 1, costo 0).
update public.productos set codigo_barras = null
where sku = 'FC-14377197' and codigo_barras = '7503014377197';

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7503014377197' else codigo_barras end,
  presentacion = coalesce(nullif(presentacion,''), '3+1 extra delgados Tropicana Mix'),
  marca = coalesce(nullif(marca,''), 'Playboy'),
  unidades_por_caja = case when unidades_por_caja is null or unidades_por_caja = 0 then 4 else unidades_por_caja end,
  activo = true
where sku = 'EQ-PBY007';

update public.productos set activo = false
where sku in ('FC-14377197','EQ-PBY007-1');

update public.productos set codigo_barras = null
where sku = 'FC-14377180' and codigo_barras = '7503014377180';

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7503014377180' else codigo_barras end,
  presentacion = coalesce(nullif(presentacion,''), '3+1 extra delgados Passion Mix'),
  marca = coalesce(nullif(marca,''), 'Playboy'),
  unidades_por_caja = case when unidades_por_caja is null or unidades_por_caja = 0 then 4 else unidades_por_caja end,
  activo = true
where sku = 'EQ-PBY008';

update public.productos set activo = false
where sku in ('FC-14377180','EQ-PBY008-1');


-- Vandix (ticket) vs Vandil (mismo costo/stock, EAN en el FC-)
update public.productos set codigo_barras = null
where sku = 'FC-930E0B1B' and codigo_barras = '7503001007069';

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7503001007069' else codigo_barras end,
  presentacion = coalesce(nullif(presentacion,''), 'Frasco 75 mL'),
  principio_activo = coalesce(nullif(principio_activo,''), 'Amoxicilina'),
  denominacion_generica = coalesce(nullif(denominacion_generica,''), 'Amoxicilina'),
  forma_farmaceutica = coalesce(nullif(forma_farmaceutica,''), 'Suspensión'),
  marca = coalesce(nullif(marca,''), 'Wandel'),
  concentracion = coalesce(nullif(concentracion,''), '250 mg / 5 mL'),
  activo = true
where sku = 'EQ-WAN013';

update public.productos set activo = false
where sku = 'FC-930E0B1B';


-- 3) Duplicados de tipeo: el EQ- (o FC- bueno) ya tiene EAN y el mismo costo.
--    El FC- mal escrito se apaga para no vender dos veces la misma pieza.
update public.productos set activo = false
where sku in (
  'FC-0BDE9283',  -- Clophiven = EQ-HIS087 Clofhiven
  'FC-174824A0',  -- Vernisen = EQ-NOV025 Vermisen
  'FC-1751468C',  -- Flospet = EQ-MAI141 Flosef
  'FC-1AE9D7E6',  -- Collucort = EQ-COL120 Collicort
  'FC-1CF27DC9',  -- Dison Dex = EQ-SON160 Disons Dex
  'FC-4FD413D2',  -- Haspen = EQ-HIS076 Fhaspem
  'FC-72C28BC1',  -- Knoricin = EQ-MAI071 Krobicin
  'FC-48F732CF',  -- Epicin = EQ-SON237 Expicin
  'FC-CD261CD5',  -- Doliprofen = EQ-COL226 Dolprofen
  'FC-F967863B',  -- Terficho = EQ-HIS075 Terfhicid
  'FC-FA3D96E6',  -- N Calcitriol = EQ-PGE052 Ercatriv
  'FC-77FE5C83',  -- Sonblefam = EQ-SON256 Sonblefan
  'FC-97BEFA1A',  -- Amlodipino dup de FC-4A0245DA
  'FMX-506817',   -- Meditest dup de FC-66055303 (mismo stock 6)
  'FMX-501002',   -- Gelcavit Mulier dup de FC-MULIER30
  'FC-09745522'   -- Treda fantasma (EAN ya está en EQ-MAV263)
);


-- 4) Precio 0 + costo > 0 → ceil(costo * 1.60), no baja de lo que ya tenga
update public.productos
   set precio = ceil(costo * 1.60)
 where activo = true
   and coalesce(precio, 0) = 0
   and coalesce(costo, 0) > 0;


-- Verificación
select sku, nombre, codigo_barras, activo, costo, precio, stock
from public.productos
where sku in (
  'EQ-SON233','FC-52D2A43A','EQ-QUM014','EQ-AMS292','EQ-QUI091',
  'EQ-AMS160','EQ-LIF039','EQ-PYG016','EQ-AMS232','EQ-AVT213','EQ-BIO017',
  'EQ-PBY007','EQ-PBY008','EQ-WAN013','FC-49025943','FC-09858046','FC-73900436',
  'FC-09747236','FC-27427392','FC-75713770','FC-09745560'
)
order by sku;
