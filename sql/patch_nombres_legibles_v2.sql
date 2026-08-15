-- Renombrar productos con nombres truncados / OCR ilegibles (delta vs catálogo live)
-- 31 updates · solo campo nombre · 2026-08-14
-- Ejecutar DESPUÉS de patch_nombres_legibles_20260814.sql (v1 ya aplicado)
-- NO modifica precio, costo, stock ni presentación

BEGIN;

UPDATE public.productos SET nombre = 'Genoprazol tabletas C/7' WHERE sku = 'FC-40036354' AND activo = true;
UPDATE public.productos SET nombre = 'Gelcavit-9M cápsulas C/30' WHERE sku = 'FC-4F05124E' AND activo = true;
UPDATE public.productos SET nombre = 'Drosquim adulto jarabe 300/160' WHERE sku = 'FC-AA7B0686' AND activo = true;
UPDATE public.productos SET nombre = 'Crema Nivea manos antiarrugas' WHERE sku = 'FC-00701992' AND activo = true;
UPDATE public.productos SET nombre = 'Afrin Adulto spray 20 mL' WHERE sku = 'FC-06134531' AND activo = true;
UPDATE public.productos SET nombre = 'Crema para peinar Sedal reconstructor instantáneo' WHERE sku = 'FC-56342258' AND activo = true;
UPDATE public.productos SET nombre = 'Cinta micropore blanca 2.5 cm x 5 m' WHERE sku = 'FC-84500522' AND activo = true;
UPDATE public.productos SET nombre = 'Aderogyl ampolletas C/4' WHERE sku = 'FC-80596011' AND activo = true;
UPDATE public.productos SET nombre = 'Tabcin efervescente' WHERE sku = 'FC-08485316' AND activo = true;
UPDATE public.productos SET nombre = 'Cinta micropore blanca 2.5 cm x 9.1 m' WHERE sku = 'FC-84500607' AND activo = true;
UPDATE public.productos SET nombre = 'Valgab 3 jarabe 6 mL' WHERE sku = 'FC-D11D586A' AND activo = true;
UPDATE public.productos SET nombre = 'Alevarin cápsulas C/45' WHERE sku = 'FC-DF39BB27' AND activo = true;
UPDATE public.productos SET nombre = 'Animalin fórmula líquida 30 mL' WHERE sku = 'FC-D751525D' AND activo = true;
UPDATE public.productos SET nombre = 'Ajolotius menta eucalipto pastillas' WHERE sku = 'FC-62746643' AND activo = true;
UPDATE public.productos SET nombre = 'Vick Drops jengibre pastillas C/20' WHERE sku = 'FC-35246309' AND activo = true;
UPDATE public.productos SET nombre = 'Cafiaspirina tartrato C/100' WHERE sku = 'FC-08491096' AND activo = true;
UPDATE public.productos SET nombre = 'Aspirina efervescente C/12' WHERE sku = 'FC-08496701' AND activo = true;
UPDATE public.productos SET nombre = 'Next tabletas C/10' WHERE sku = 'FC-40010538' AND activo = true;
UPDATE public.productos SET nombre = 'XL-3 VR C/24' WHERE sku = 'FC-40017100' AND activo = true;
UPDATE public.productos SET nombre = 'Talco para bebé Mennen azul chico' WHERE sku = 'FC-35908116' AND activo = true;
UPDATE public.productos SET nombre = 'Talco para bebé Mennen azul' WHERE sku = 'FC-35908130' AND activo = true;
UPDATE public.productos SET nombre = 'Talco para bebé Mennen rosa' WHERE sku = 'FC-35908147' AND activo = true;
UPDATE public.productos SET nombre = 'Talco Nuvel Pura para bebé' WHERE sku = 'FC-82790016' AND activo = true;
UPDATE public.productos SET nombre = 'Shampoo Pert Aceite oliva' WHERE sku = 'FC-20500201' AND activo = true;
UPDATE public.productos SET nombre = 'Shampoo Ricitos de Oro Agua De Coco' WHERE sku = 'FC-36033735' AND activo = true;
UPDATE public.productos SET nombre = 'Shampoo Ricitos de Oro Biopure' WHERE sku = 'FC-36032776' AND activo = true;
UPDATE public.productos SET nombre = 'Dove aerosol tono uniforme caléndula y vitamina E' WHERE sku = 'FC-06248052' AND activo = true;
UPDATE public.productos SET nombre = 'Hucius cápsulas' WHERE sku = 'FC-1812D26D' AND activo = true;
UPDATE public.productos SET nombre = 'Valnait cápsulas valeriana' WHERE sku = 'FC-BE2ACF63' AND activo = true;
UPDATE public.productos SET nombre = 'Tusilen adulto jarabe' WHERE sku = 'FC-1DAD5EF1' AND activo = true;
UPDATE public.productos SET nombre = 'Ajolotius jengibre pastillas' WHERE sku = 'FC-52400212' AND activo = true;
UPDATE public.productos SET concentracion = '150 ML', presentacion = '1 JARABE' WHERE sku = 'FC-89794961' AND activo = true AND concentracion ILIKE '%OPELLA%';

COMMIT;
