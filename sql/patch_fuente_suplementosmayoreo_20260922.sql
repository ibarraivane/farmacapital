-- Fuente de mayoreo Suplementos Mayoreo (vitrina /conseguir).
-- El precio del CSV es costo. No abre columna en la tabla Compra.

begin;

insert into public.fuentes_precio (id, nombre, tipo, metodo, notas) values
  ('suplementosmayoreo', 'Suplementos Mayoreo', 'compra', 'import_archivo',
   'Mayoreo suplementosmayoreo.com. Costo del CSV; no es precio de mostrador.')
on conflict (id) do update set
  nombre = excluded.nombre,
  tipo = excluded.tipo,
  metodo = excluded.metodo,
  notas = excluded.notas;

commit;
