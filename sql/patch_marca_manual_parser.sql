-- Marca + nombre limpio: productos tipo=marca sin columna marca en catálogo automático
-- (patch_backfill_marca_desde_catalogo.sql no los cubre: marca vacía en CSV)
begin;

-- Medicamento / aerosol
update public.productos set marca = 'Protect', nombre = 'Protect aerosol 200 dosis' where sku = 'FC-6B2ADEE9' and (marca is null or btrim(marca) = '');

-- Higiene / cuidado personal
update public.productos set marca = 'Azufre', nombre = 'Jabón azufre con miel' where sku = 'FC-14119032' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Genérico', nombre = 'Jabón proteína de arroz y concha nácar' where sku = 'FC-14121782' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Natural-G', nombre = 'Agua micelar bifásica' where sku = 'FC-45722547' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Genérico', nombre = 'Tiraleche de cristal' where sku = 'FC-41500096' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Ting', nombre = 'Ting polvo decolorante' where sku = 'FC-72300171' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Silkhair', nombre = 'Quitaesmalte mora azul' where sku = 'FC-45720550' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Silkhair', nombre = 'Quitaesmalte coco' where sku = 'FC-45720567' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Genérico', nombre = 'Talco desodorante pies' where sku = 'FC-56360429' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Nivea', nombre = 'Gel facial hidratante hialurónico' where sku = 'FC-00942760' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Nivea', nombre = 'Crema corporal Nivea Milk' where sku = 'FC-54558682' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Nivea', nombre = 'Crema corporal piel seca' where sku = 'FC-54549819' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Genérico', nombre = 'Gotero de cristal' where sku = 'FC-07521317' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Genérico', nombre = 'Tubos surtidos' where sku = 'FC-65054135' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Sico', nombre = 'Lubricante sensación calor' where sku = 'FC-58793249' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Piel con Piel', nombre = 'Lubricante íntimo' where sku = 'FC-60101378' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Genérico', nombre = 'Crema dental anticaries' where sku = 'FC-66873531' and (marca is null or btrim(marca) = '');

-- Botiquín / material curación (Protec)
update public.productos set marca = 'Protec', nombre = 'Venda de yeso 10 cm x 2.75 m C/12' where sku = 'FC-48640775' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Protec', nombre = 'Venda de yeso 15 cm x 2.75 m C/12' where sku = 'FC-48640799' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Protec', nombre = 'Venda de yeso 20 cm x 2.75 m' where sku = 'FC-46640629' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Protec', nombre = 'Venda de yeso 5 cm x 2.75 m C/12' where sku = 'FC-48640751' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Protec', nombre = 'Tensolastic Plus venda elástica 5 cm x 5 m' where sku = 'FC-48690800' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Protec', nombre = 'Tensolastic Plus venda elástica 7 cm x 5 m' where sku = 'FC-48690909' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Protec', nombre = 'Tensolastic Plus venda elástica 10 cm x 5 m' where sku = 'FC-48691005' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Protec', nombre = 'Tensolastic Plus venda elástica 15 cm x 5 m' where sku = 'FC-48691104' and (marca is null or btrim(marca) = '');

-- Algodón / gasas / alcohol
update public.productos set marca = 'Dibar', nombre = 'Gasa Lox10 C/100' where sku = 'FC-68900134' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Genérico', nombre = 'Alcohol etílico' where sku = 'FC-68901124' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Genérico', nombre = 'Alcohol azul' where sku = 'FC-68901131' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Dibar', nombre = 'Algodón 5 g C/12' where sku = 'FC-68910041' and (marca is null or btrim(marca) = '');
update public.productos set marca = 'Dibak', nombre = 'Algodón 200 g' where sku = 'FC-89100101' and (marca is null or btrim(marca) = '');

-- Higiene íntima
update public.productos set marca = 'Absorsec', nombre = 'Toallitas húmedas C/120' where sku = 'FC-43471900' and (marca is null or btrim(marca) = '');

-- Colgate (presentación faltante del parche anterior)
update public.productos set presentacion = '1 tubo' where sku = 'FC-66534951' and (presentacion is null or btrim(presentacion) = '');

-- Verificación
select count(*) filter (where tipo = 'marca' and (marca is null or btrim(marca) = '')) as marca_sin_llenar
from public.productos
where sku like 'FC-%';

select sku, nombre, marca, presentacion
from public.productos
where tipo = 'marca' and (marca is null or btrim(marca) = '') and sku like 'FC-%'
order by sku;

commit;
