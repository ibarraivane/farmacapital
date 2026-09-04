-- Libera EAN duplicados: se queda el SKU con más stock (empate: nombre más largo).
begin;

-- 3311000003920 se queda en FC-89F00320; libera FC-127F5753 (Mercurio Arnica Tomar)
update public.productos set codigo_barras = null where sku = 'FC-127F5753' and codigo_barras = '3311000003920';
-- 3311000003920 se queda en FC-89F00320; libera FC-25E452B6 (Mercurio Arnica Untar)
update public.productos set codigo_barras = null where sku = 'FC-25E452B6' and codigo_barras = '3311000003920';
-- 3311000003920 se queda en FC-89F00320; libera FC-DFF99C3F (Mercurio)
update public.productos set codigo_barras = null where sku = 'FC-DFF99C3F' and codigo_barras = '3311000003920';
-- 3311000003920 se queda en FC-89F00320; libera FC-5EF90195 (Mercurio Flor De Arnica)
update public.productos set codigo_barras = null where sku = 'FC-5EF90195' and codigo_barras = '3311000003920';
-- 7501008491074 se queda en FC-08491074; libera FC-7D1D9857 (Acetilsalicilico)
update public.productos set codigo_barras = null where sku = 'FC-7D1D9857' and codigo_barras = '7501008491074';
-- 7501349022454 se queda en FC-BDB2E087; libera FC-262F2A30 (Irbesartan)
update public.productos set codigo_barras = null where sku = 'FC-262F2A30' and codigo_barras = '7501349022454';
-- 7502009740992 se queda en FC-5F30F9D4; libera FC-022543CD (Valclan)
update public.productos set codigo_barras = null where sku = 'FC-022543CD' and codigo_barras = '7502009740992';
-- 7502009741050 se queda en FC-F3E734A0; libera FC-9538F7D6 (Fasiclor)
update public.productos set codigo_barras = null where sku = 'FC-9538F7D6' and codigo_barras = '7502009741050';
-- 7503003406600 se queda en FC-03406600; libera FC-2E5B7248 (Reumatol)
update public.productos set codigo_barras = null where sku = 'FC-2E5B7248' and codigo_barras = '7503003406600';
-- 7503008344747 se queda en FC-08344747; libera FC-6898B64F (Bioerter)
update public.productos set codigo_barras = null where sku = 'FC-6898B64F' and codigo_barras = '7503008344747';

commit;
