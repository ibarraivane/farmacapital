-- Alcohol Dibar rojo 500 ml (FC-68990023)
-- El ticket 112558 dejó 7501868990023 (checksum GS1 inválido).
-- El bote escanea 7501868900233 (EAN-13 válido).
-- Sin este arreglo la pistola no encuentra el SKU: Recibir dice "fuera"
-- y en Catálogo parece que hay que darlo de alta otra vez.
--
-- No toca stock, costo, precio ni caducidad.
-- Si ya se dio de alta un segundo renglón con el EAN del bote, se le
-- quita el código para no chocar el UNIQUE y se queda FC-68990023.

begin;

update public.productos
   set codigo_barras = null
 where codigo_barras = '7501868900233'
   and sku is distinct from 'FC-68990023';

update public.productos
set
  codigo_barras = '7501868900233',
  marca = coalesce(nullif(btrim(marca), ''), 'Dibar'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '500 ML'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Alcohol'),
  descripcion = case
    when descripcion ilike '%7501868990023%' then descripcion
    when coalesce(btrim(descripcion), '') = '' then
      'Alcohol Dibar rojo 96° 500 ml. EAN bote 7501868900233 · EAN ticket OCR 7501868990023.'
    else
      btrim(descripcion) || ' EAN bote 7501868900233 · EAN ticket OCR 7501868990023.'
  end
where sku = 'FC-68990023'
   or codigo_barras in ('7501868990023', '7501868900233');

commit;

select sku, codigo_barras, nombre, marca, presentacion, stock, costo, precio
  from public.productos
 where sku = 'FC-68990023'
    or codigo_barras in ('7501868900233', '7501868990023')
    or (nombre ilike '%dibar%' and presentacion ilike '%500%');
