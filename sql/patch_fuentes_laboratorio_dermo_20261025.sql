-- Fuentes de compra a precio directo de laboratorio (dermo).
-- Reemplazan MePiel / Dermaexpress para SVR, Alastin y Medik8.
-- Idempotente.

begin;

insert into public.fuentes_precio (id, nombre, tipo, metodo, notas) values
  ('svr', 'SVR (laboratorio)', 'compra', 'import_archivo',
   'Compra directa SVR. Costo real de factura + PVP FarmaCapital.'),
  ('alastin', 'Alastin (laboratorio)', 'compra', 'import_archivo',
   'Lista Alastin 2026. Costo base c/IVA; descuentos por volumen en notas.'),
  ('medik8', 'Medik8 / Dermatotec', 'compra', 'import_archivo',
   'Lista especialistas Medik8 México 2025 (Dermatotec). Costo = precio especialista c/IVA.')
on conflict (id) do update set
  nombre = excluded.nombre,
  tipo = excluded.tipo,
  metodo = excluded.metodo,
  notas = excluded.notas;

commit;
