-- Delta referencias Otros (venta) — CSV v2 vs v1
-- Archivo: referencias_venta_consolidado_20260815_2.csv
-- Solo 7 filas NUEVAS (el resto ya estaba en v1)

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
  values ('otros_venta', 'venta', '2026-08-15', 'referencias_venta_consolidado_20260815_2.csv', 7, 'delta v2 — importar_referencias_precio.py')
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
  ('FC-F82A6E4B', 67.0::numeric, 75::smallint, 'Vitau.mx - Ampicilina genérica 1g 10 tabletas'),
  ('FC-33954078', 66.0::numeric, 75::smallint, 'Vitau.mx - Ensure Advance 237ml (referencia)'),
  ('FC-33950070', 66.0::numeric, 75::smallint, 'Vitau.mx - Ensure Advance 237ml (referencia similar)'),
  ('FC-33956126', 75.0::numeric, 60::smallint, 'Estimado basado en Ensure; Glucerna agotado en mayoría de farmacias'),
  ('FC-33956133', 75.0::numeric, 60::smallint, 'Estimado; Glucerna agotado'),
  ('FC-33956140', 75.0::numeric, 60::smallint, 'Estimado; Glucerna agotado'),
  ('FC-51747971', 26.5::numeric, 75::smallint, 'Farmatodo.com.mx - Electrolit suero oral 625ml')
) as v(sku, precio, confianza, notas)
join public.productos p on p.sku = v.sku and p.activo = true
where v.sku is not null;

commit;
