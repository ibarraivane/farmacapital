-- Estomaquil C/10 (FC-69200085): la descripción citaba el EAN del C/20
-- (7501369200016). El match de pistola en POS toma cualquier 12–14 dígitos
-- de la ficha como código alterno, así que al escanear la caja de 20 sobres
-- salía el de 10 si el C/10 aparecía antes en el catálogo en memoria.
--
-- Caja física C/20 = 7501369200016 → FC-69200016 Estomaquil Polvo C/20
-- Caja C/10        = 7501369200085 → FC-69200085 Estomaquil polvo C/10
--
-- (Son sobres de polvo, no cápsulas.)

begin;

update public.productos
set descripcion = 'Farmalive 127790 · Fahorro Estomaquil C/10 EAN 7501369200085 (no confundir con presentación C/20)'
where sku = 'FC-69200085'
  and codigo_barras = '7501369200085'
  and descripcion is not null
  and descripcion like '%7501369200016%';

commit;

select sku, codigo_barras, nombre, presentacion, left(descripcion, 120) as descripcion
  from public.productos
 where sku in ('FC-69200016', 'FC-69200085')
    or codigo_barras in ('7501369200016', '7501369200085')
 order by sku;
