-- Import exprezo: 32 productos — 2026-08-14
begin;

with imp as (
  insert into public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
  values ('exprezo', 'compra', '2026-08-14', 'import_exprezo_listo.csv', 32, 'importar_capturas_claude.py')
  returning id
)
insert into public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza)
select p.id, 'exprezo', 'compra', v.precio, '2026-08-14'::date, 'import_csv', imp.id, 85
from imp, (values
  ('FC-01157296', 12.95::numeric),
  ('FC-01405335', 21.25::numeric),
  ('FC-06257597', 71.49::numeric),
  ('FC-07528939', 38.99::numeric),
  ('FC-08443026', 267.68::numeric),
  ('FC-08485316', 70.6::numeric),
  ('FC-14982514', 33.5::numeric),
  ('FC-19006371', 16.84::numeric),
  ('FC-19006623', 20.11::numeric),
  ('FC-22150221', 21.94::numeric),
  ('FC-25104411', 19.17::numeric),
  ('FC-25149221', 19.17::numeric),
  ('FC-31244486', 38.99::numeric),
  ('FC-35469151', 42.49::numeric),
  ('FC-36033735', 69.73::numeric),
  ('FC-40013898', 34.66::numeric),
  ('FC-46073040', 15.53::numeric),
  ('FC-48335305', 15.95::numeric),
  ('FC-51448511', 19.17::numeric),
  ('FC-56330309', 79.19::numeric),
  ('FC-60009851', 24.94::numeric),
  ('FC-60403681', 72.37::numeric),
  ('FC-60689091', 16.96::numeric),
  ('FC-66534951', 20.58::numeric),
  ('FC-68901131', 36.9::numeric),
  ('FC-70612368', 142.24::numeric),
  ('FC-73629981', 31.73::numeric),
  ('FC-83351381', 13.2::numeric),
  ('FC-83510531', 13.0::numeric),
  ('FC-92506601', 18.84::numeric),
  ('FC-95451096', 156.0::numeric),
  ('FC-DE106642', 18.21::numeric)
) as v(sku, precio)
join public.productos p on p.sku = v.sku and p.activo = true;

commit;