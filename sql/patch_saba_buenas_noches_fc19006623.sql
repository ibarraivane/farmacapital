-- Saba Buenas Noches C/8 · FC-19006623
-- Código paquete: 7501019050664
-- Costo ticket 112558: $9.90/paquete (10 pzas = $99.00)
-- Precio mercado paquete: $19.29
-- Precio unidad suelta: $3.50 (8×$3.50=$28 > paquete; incentiva C/8)

begin;

update public.productos set
  codigo_barras = '7501019050664',
  nombre = 'Saba Buenas Noches',
  marca = 'Saba',
  presentacion = 'C/8',
  forma_farmaceutica = 'Toallas sanitarias',
  categoria = 'Higiene',
  tipo = 'marca',
  costo = 9.90,
  precio = 19.29,
  venta_unidad = true,
  unidades_por_caja = 8,
  precio_unidad = 3.50,
  descripcion = 'Saba Buenas Noches C/8 extra larga con alas — ticket 112558'
where sku = 'FC-19006623';

update public.lotes
set costo_unitario = 9.90
where producto_id = (select id from public.productos where sku = 'FC-19006623' limit 1);

commit;
