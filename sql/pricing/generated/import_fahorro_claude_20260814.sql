-- Import fahorro: 46 productos — 2026-08-14
begin;

with imp as (
  insert into public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
  values ('fahorro', 'venta', '2026-08-14', 'import_fahorro_listo.csv', 46, 'importar_capturas_claude.py')
  returning id
)
insert into public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza)
select p.id, 'fahorro', 'venta', v.precio, '2026-08-14'::date, 'import_csv', imp.id, 85
from imp, (values
  ('FC-02012468', 125.0::numeric),
  ('FC-06134531', 113.0::numeric),
  ('FC-08895196', 43.0::numeric),
  ('FC-09419324', 79.0::numeric),
  ('FC-11294615', 55.0::numeric),
  ('FC-2005DD57', 253.0::numeric),
  ('FC-22105207', 30.0::numeric),
  ('FC-22150801', 32.5::numeric),
  ('FC-25104411', 25.0::numeric),
  ('FC-25149221', 25.0::numeric),
  ('FC-31887928', 97.0::numeric),
  ('FC-33954740', 34.5::numeric),
  ('FC-357D4A17', 261.0::numeric),
  ('FC-3B001F9B', 282.0::numeric),
  ('FC-3CAA7C5C', 77.0::numeric),
  ('FC-405A75E3', 432.0::numeric),
  ('FC-41339950', 236.0::numeric),
  ('FC-51448511', 25.0::numeric),
  ('FC-53506FA4', 102.0::numeric),
  ('FC-5BC5F234', 67.0::numeric),
  ('FC-60F627D5', 45.5::numeric),
  ('FC-65095718', 199.0::numeric),
  ('FC-6519183A', 143.0::numeric),
  ('FC-74A5ABEE', 239.0::numeric),
  ('FC-75354321', 118.0::numeric),
  ('FC-7D1D9857', 32.5::numeric),
  ('FC-7F90064A', 85.0::numeric),
  ('FC-82F88FED', 58.0::numeric),
  ('FC-84973401', 227.0::numeric),
  ('FC-885F2723', 80.0::numeric),
  ('FC-9A4E4C31', 135.0::numeric),
  ('FC-A2B284E0', 423.0::numeric),
  ('FC-ACA2A2F6', 133.0::numeric),
  ('FC-BDB2E087', 400.0::numeric),
  ('FC-C101D5B1', 366.0::numeric),
  ('FC-C721E8D7', 158.0::numeric),
  ('FC-C9F4ACCC', 151.0::numeric),
  ('FC-D06E54FE', 143.0::numeric),
  ('FC-D9391288', 212.0::numeric),
  ('FC-DEAF33B0', 87.0::numeric),
  ('FC-E4BE37BE', 217.0::numeric),
  ('FC-E4EFC4C2', 266.0::numeric),
  ('FC-E6B50AC3', 457.0::numeric),
  ('FC-EADF1484', 364.0::numeric),
  ('FC-F4E9C71F', 102.0::numeric),
  ('FC-FD845E68', 334.0::numeric)
) as v(sku, precio)
join public.productos p on p.sku = v.sku and p.activo = true;

commit;