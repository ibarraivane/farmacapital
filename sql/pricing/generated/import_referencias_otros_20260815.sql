-- Import referencias Otros (venta) — 5 filas nuevas vs CSV v1
-- Archivo: referencias_venta_consolidado_20260815_1.csv
-- (Los 17 Similares de este CSV ya están en import_referencias_similares_20260815.sql)

begin;

insert into public.fuentes_precio (id, nombre, tipo, metodo, notas) values
  ('otros_compra', 'Otros (compra)', 'compra', 'manual', 'Promedio de mercado o consulta manual (Claude, Google, etc.)'),
  ('otros_venta', 'Otros (venta)', 'venta', 'manual', 'Promedio de mercado o consulta manual (Claude, Google, etc.)')
on conflict (id) do update set
  nombre = excluded.nombre,
  tipo = excluded.tipo,
  metodo = excluded.metodo,
  notas = excluded.notas;

with imp as (
  insert into public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
  values ('otros_venta', 'venta', '2026-08-15', 'referencias_venta_consolidado_20260815_1.csv', 5, 'importar_referencias_precio.py — delta otros')
  returning id
)
insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza, notas
)
select
  p.id,
  'otros_venta',
  'venta',
  v.precio,
  '2026-08-15'::date,
  'import_csv',
  imp.id,
  v.confianza,
  v.notas
from imp, (values
  ('FC-E9C38DC4', 65.43::numeric, 75::smallint, 'Vitau.mx - Ciprofloxacino genérico 500mg 14 tabletas'),
  ('FC-7AF7ACB5', 65.43::numeric, 60::smallint, 'Basado en precio Ciprofloxacino 500mg genérico; presentación de 3 tab no encontrada'),
  ('FC-50959781', 150.0::numeric, 75::smallint, 'Farmacias referencia - Centrum Multivitamínico 30 tabletas (verificar en Fahorro/Walmart)'),
  ('FC-84999001', 260.0::numeric, 75::smallint, 'Farmacias San Isidro - Alka-Seltzer Boost 50 tabletas efervescentes'),
  ('FC-08491074', 97.89::numeric, 75::smallint, 'Vitau.mx - Aspirina 500mg genérica 40 tabletas (tu presentación es 80)')
) as v(sku, precio, confianza, notas)
join public.productos p on p.sku = v.sku and p.activo = true
where v.sku is not null;

commit;
