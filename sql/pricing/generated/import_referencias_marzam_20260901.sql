-- Marzam fichas septiembre 2026 · 17 matches · precio farmacia con oferta
-- Archivo: Fichas_Septiembre_2026_MXM.pdf
-- Generado: scripts/importar_marzam_fichas.py

begin;

insert into public.fuentes_precio (id, nombre, tipo, metodo, notas) values
  ('marzam', 'Marzam', 'compra', 'import_archivo',
   'Fichas / lista farmacia Marzam (precio con oferta). No es benchmark de mercado libre.')
on conflict (id) do update set
  nombre = excluded.nombre, tipo = excluded.tipo, metodo = excluded.metodo, notas = excluded.notas;

with imp as (
  insert into public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
  values ('marzam', 'compra', '2026-09-01', 'Fichas_Septiembre_2026_MXM.pdf', 17,
          'importar_marzam_fichas.py · precio fcia con oferta · match revisado')
  returning id
)
insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, sku_externo,
  confianza, origen, import_id, notas
)
select
  v.producto_id, 'marzam', 'compra', v.precio, '2026-09-01'::date,
  v.nombre_fuente, v.sku_externo, v.confianza, 'import_csv', imp.id,
  'fichas sept-2026 · precio fcia con oferta'
from imp, (values
  (67::bigint, 49.64::numeric, 'ACEMETACINA 90MG CAPS C14', 'D 3401779', 100::smallint),
  (73::bigint, 57.22::numeric, 'ACICLOVIR 400MG TAB C35', '3401077', 100::smallint),
  (792::bigint, 19.58::numeric, 'AFLUSIL 120ML', '3400007', 100::smallint),
  (492::bigint, 25.96::numeric, 'AGRIFEN TAB C10', 'A 65002', 100::smallint),
  (681::bigint, 64.95::numeric, 'ALIN AMP 2ML C1', 'A 103003', 100::smallint),
  (667::bigint, 135.29::numeric, 'ALLI-TRIPLE TAB C10', 'E 109703', 100::smallint),
  (1311::bigint, 102.94::numeric, 'ALLIVIAX 550MG TAB C10', 'E 109701', 100::smallint),
  (121::bigint, 17.59::numeric, 'AMCEF IM 1G IM 3.5ML', '3400265', 100::smallint),
  (122::bigint, 17.45::numeric, 'AMCEF IM 500MG SOL 2ML', '3400258', 100::smallint),
  (85::bigint, 31.03::numeric, 'AMLODIPINO 5MG TAB C100', 'D 3401214', 100::smallint),
  (103::bigint, 10.72::numeric, 'AMLODIPINO 5MG TAB C30', 'D 3401315', 100::smallint),
  (44::bigint, 18.38::numeric, 'AMOXICILINA 500MG CAP C12', '3400611', 100::smallint),
  (51::bigint, 26.81::numeric, 'AMPICILINA 1G TAB C10', '3401304', 100::smallint),
  (469::bigint, 138.56::numeric, 'ANARA TAB C20', 'A 177002', 100::smallint),
  (615::bigint, 162.87::numeric, 'ANTIFLU DES CAP C24', 'A 204001', 100::smallint),
  (496::bigint, 125.02::numeric, 'ANTIFLU DES JR SOL 60ML', 'A 204005', 100::smallint),
  (1413::bigint, 141.04::numeric, 'ANTIFLU DES PED 30ML', 'A 204004', 100::smallint)
) as v(producto_id, precio, nombre_fuente, sku_externo, confianza);

commit;
