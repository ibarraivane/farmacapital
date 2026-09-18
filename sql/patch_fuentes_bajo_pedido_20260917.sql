-- Fuentes de mayoreo especialidad (bajo pedido / vitrina /conseguir).
-- Extra: no abren columna en la tabla Compra (como Scorpion).
-- promexsa = techo web, no costo. mepiel reservada hasta la lista.

begin;

insert into public.fuentes_precio (id, nombre, tipo, metodo, notas) values
  ('dermaexpress', 'Dermaexpress', 'compra', 'import_archivo', 'Mayoreo dermo. Costo de portal.'),
  ('birdman', 'Birdman', 'compra', 'import_archivo', 'Mayoreo proteína / wellness. Costo base (escalón chico).'),
  ('ewafra', 'Ewafra (DIS)', 'compra', 'import_archivo', 'Lista 6 −20% Julio César Sánchez Santos. Costo mayoreo de insumos.'),
  ('promexsa', 'Promexsa', 'compra', 'import_archivo', 'Precio web ≈ PVP. Techo de mercado, no costo mayoreo.'),
  ('mepiel', 'Mepiel', 'compra', 'import_archivo', 'Mayoreo dermo / médico. Reservada hasta cargar la lista.')
on conflict (id) do update set
  nombre = excluded.nombre,
  tipo = excluded.tipo,
  metodo = excluded.metodo,
  notas = excluded.notas;

commit;
