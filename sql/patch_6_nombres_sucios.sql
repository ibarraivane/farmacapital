-- Corrige los 6 productos que aún tienen nombre OCR sucio ($, |, ticket)
-- Ejecutar una vez en Supabase SQL Editor.

begin;

-- FC-23272151 | Jeringa insulina Jayor 0.3 ml
update public.productos set
  nombre = 'Jeringa insulina 0.3 ml C/100',
  marca = 'Jayor',
  presentacion = '0.3 ML · C/100',
  forma_farmaceutica = 'Jeringa',
  categoria = 'Botiquín',
  tipo = 'marca'
where sku = 'FC-23272151';

-- FC-23273451 | Jeringa insulina Jayor 0.5 ml
update public.productos set
  nombre = 'Jeringa insulina 0.5 ml C/100',
  marca = 'Jayor',
  presentacion = '0.5 ML · C/100',
  forma_farmaceutica = 'Jeringa',
  categoria = 'Botiquín',
  tipo = 'marca'
where sku = 'FC-23273451';

-- FC-33961373 | Pedialyte sabor fresa
update public.productos set
  nombre = 'Pedialyte Fresa 500 ml',
  marca = 'Pedialyte',
  presentacion = '500 ML',
  forma_farmaceutica = 'Suero oral',
  categoria = 'Higiene',
  tipo = 'marca'
where sku = 'FC-33961373';

-- FC-56034041 | Toallitas húmedas Escudo
update public.productos set
  nombre = 'Escudo Toallitas Antibacterial C/50',
  marca = 'Escudo',
  presentacion = 'C/50',
  forma_farmaceutica = 'Toallas húmedas',
  categoria = 'Higiene',
  tipo = 'marca'
where sku = 'FC-56034041';

-- FC-66534951 | Colgate Total
update public.productos set
  nombre = 'Colgate Total Crema dental',
  marca = 'Colgate',
  forma_farmaceutica = 'Crema dental',
  categoria = 'Higiene',
  tipo = 'marca'
where sku = 'FC-66534951';

-- FC-83351381 | Agua oxigenada Dermocleen
update public.productos set
  nombre = 'Dermocleen Agua oxigenada 100 ml',
  marca = 'Dermocleen',
  presentacion = '100 ML',
  forma_farmaceutica = 'Agua oxigenada',
  categoria = 'Botiquín',
  tipo = 'marca'
where sku = 'FC-83351381';

-- Verificación (debe dar nombres_sucios = 0)
select
  count(*) filter (where nombre ~* 'descto|lab pisa|\$|\|') as nombres_sucios
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';

select sku, nombre, marca, presentacion
from public.productos
where sku in (
  'FC-23272151', 'FC-23273451', 'FC-33961373',
  'FC-56034041', 'FC-66534951', 'FC-83351381'
)
order by sku;

commit;
