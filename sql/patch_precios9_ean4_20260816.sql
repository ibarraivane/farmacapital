-- ============================================================================
-- FARMA CAPITAL — 9 precios + 4 EAN de fotos  16-ago-2026
--
-- 1) Precio ceil(costo*1.6) solo si el precio sigue en 0 y hay costo.
--    No toca Mornin (costo 0, sin ticket).
-- 2) Pega los 4 EAN de las fotos que no quedaron en el SQL anterior.
--
-- Idempotente. No pisa un precio o un código que ya tenga valor.
-- ============================================================================

update public.productos set precio = ceil(costo * 1.6)
where sku in (
  'FC-01007199',  -- Valclan 500/125
  'FC-01007250',  -- Valclan 875/125
  'FC-09741043',  -- Fasiclor 125/5 mL 75 mL
  'FC-09745140',  -- Clamoxín S 50 mL
  'FC-42803524',  -- AAS 100 mg C/30
  'FC-49020269',  -- Ursodeoxicólico 50 cap
  'FC-49021570',  -- Amoxicilina 12 cap 500
  'FC-49028913',  -- Atorvastatina 40 C/10
  'FC-83141226'   -- Perludil 1 FA
)
  and coalesce(costo, 0) > 0
  and coalesce(precio, 0) <= 0.01;


update public.productos set
  codigo_barras = '7502001165397',
  activo = true
where sku = 'EQ-SON233'
  and coalesce(codigo_barras, '') = ''
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502001165397' and o.sku <> 'EQ-SON233'
  );

update public.productos set
  codigo_barras = '7501349022485',
  activo = true
where sku = 'EQ-AMS292'
  and coalesce(codigo_barras, '') = ''
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501349022485' and o.sku <> 'EQ-AMS292'
  );

update public.productos set
  codigo_barras = '7501109763986',
  activo = true
where sku = 'EQ-QUI091'
  and coalesce(codigo_barras, '') = ''
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501109763986' and o.sku <> 'EQ-QUI091'
  );

update public.productos set
  codigo_barras = '7502223111202',
  activo = true
where sku = 'EQ-QUM014'
  and coalesce(codigo_barras, '') = ''
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502223111202' and o.sku <> 'EQ-QUM014'
  );


select sku, nombre, codigo_barras, costo, precio, stock
from public.productos
where sku in (
  'FC-01007199','FC-01007250','FC-09741043','FC-09745140','FC-42803524',
  'FC-49020269','FC-49021570','FC-49028913','FC-83141226','FC-01162365',
  'EQ-SON233','EQ-AMS292','EQ-QUI091','EQ-QUM014'
)
order by sku;
