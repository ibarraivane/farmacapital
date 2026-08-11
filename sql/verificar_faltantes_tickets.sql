-- Cuántos de los 128 faltantes del ticket ya están en BD
-- Ejecutar en cualquier momento (solo lectura)

with faltantes (codigo_barras, sku, qty, nota) as (
  values
    ('7500435246309', null::text, 1, 'Vick Drops'),
    ('7501008427330', null::text, 3, 'Bepanthen'),
    ('7501008491096', null::text, 40, 'Cafiaspirina'),
    (null::text, 'FC-1FBF5206', 1, 'Reomatolum'),
    (null::text, 'FC-66055303', 6, 'Meditest')
),
ticket as (
  select codigo_barras, sku, qty, nota from faltantes
  union all
  select t.codigo_barras, t.sku, t.qty, left(t.nota, 40)
  from (
    select * from (values
      ('7501001246730', null::text, 1, 'Vaporub'),
      ('75022760403681', null::text, 1, 'Desenfriol D')
    ) as x(codigo_barras, sku, qty, nota)
  ) t
)
select
  count(*) filter (
    where exists (
      select 1 from public.productos p
      where (ticket.codigo_barras is not null and p.codigo_barras = ticket.codigo_barras)
         or (ticket.sku is not null and p.sku = ticket.sku)
    )
  ) as ya_cargados,
  count(*) as total_muestra
from ticket;

-- Lista completa: ejecutar patch 3 SOLO para ver el diagnóstico, o usar auditoría:
-- python3 scripts/auditar_cantidades_vs_pdfs.py

select
  p.codigo_barras,
  p.sku,
  left(p.nombre, 50) as nombre,
  p.stock,
  (select count(*) from public.lotes l where l.producto_id = p.id) as lotes
from public.productos p
where p.codigo_barras in (
  '7501008427330', '7501008491096', '7501008443026', '75022760403681'
)
   or p.sku in ('FC-1FBF5206', 'FC-66055303', 'FC-00E8A9C7', 'FC-08DB70CB')
order by p.sku nulls last;

select count(*) as productos_activos from public.productos where activo = true;

select count(*) as firmas_create_producto_with_lote
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname = 'create_producto_with_lote';
