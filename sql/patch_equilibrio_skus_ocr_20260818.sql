-- ============================================================================
-- Equilibrio 440393 · claves OCR → claves del archivo digital / Levic
--
-- El Excel VICTOR HUGO AGUILAR ZARCO.xlsx y el catálogo Levic coinciden.
-- El ticket OCR cambió el último dígito y cruzó SON096/SON098.
-- ============================================================================

begin;

-- Swap Fenimeth ↔ Metroson (nombres y EAN ya son los de la caja)
update public.productos set sku = 'EQ-SON096__swap' where sku = 'EQ-SON096';
update public.productos set sku = 'EQ-SON096' where sku = 'EQ-SON098';
update public.productos set sku = 'EQ-SON098' where sku = 'EQ-SON096__swap';

update public.productos set sku = 'EQ-BIO138' where sku = 'EQ-BIO136';
update public.productos set sku = 'EQ-MAV198' where sku = 'EQ-MAV196';
update public.productos set sku = 'EQ-MAV208' where sku = 'EQ-MAV206';
update public.productos set sku = 'EQ-MAV378' where sku = 'EQ-MAV376';

-- C/28: EAN Levic
update public.productos
   set codigo_barras = '7501644707490'
 where sku = 'EQ-QUI127'
   and coalesce(codigo_barras, '') = '';

commit;

select sku, nombre, codigo_barras, costo, stock
  from public.productos
 where sku in (
   'EQ-BIO138','EQ-MAV198','EQ-MAV208','EQ-MAV378',
   'EQ-SON096','EQ-SON098','EQ-QUI096','EQ-QUI127'
 )
 order by sku;
