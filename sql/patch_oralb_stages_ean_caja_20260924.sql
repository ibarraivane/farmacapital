-- Corrige fichas Oral-B Stages del ticket Farma Mayoreo 306277.
-- Caja real: Toy Story + Princesas = mismo EAN 3014260279264 (OK003).
-- Frozen grande = EAN 3014260278922 (OK011).
-- No son 2 SKUs distintos para Princesas/Toy Story: el fabricante usa un solo código.
-- Pegar en Supabase → SQL Editor → Run.

begin;

update public.productos
set
  nombre = 'Oral-B Stages cepillo dental infantil 3+ Disney/Pixar',
  marca = coalesce(nullif(btrim(marca), ''), 'Oral-B'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '1 pieza'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cepillo'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
  subcategoria = coalesce(nullif(btrim(subcategoria), ''), 'Bucal'),
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'P&G'),
  updated_at = now()
where codigo_barras = '3014260279264'
   or sku = 'FC-60279264';

update public.productos
set
  nombre = 'Oral-B Stages cepillo dental infantil 3+ Frozen',
  marca = coalesce(nullif(btrim(marca), ''), 'Oral-B'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '1 pieza'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cepillo'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
  subcategoria = coalesce(nullif(btrim(subcategoria), ''), 'Bucal'),
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'P&G'),
  updated_at = now()
where codigo_barras = '3014260278922'
   or sku = 'FC-60278922';

-- Si el borrador Farma Mayoreo 306277 ya está vivo: alinea snapshot + lote Frozen.
update public.recepcion_items i
set
  nombre_snapshot = case
    when i.codigo_escaneado = '3014260279264' then 'Oral-B Stages cepillo dental infantil 3+ Disney/Pixar'
    when i.codigo_escaneado = '3014260278922' then 'Oral-B Stages cepillo dental infantil 3+ Frozen'
    else i.nombre_snapshot
  end,
  numero_lote = case
    when i.codigo_escaneado = '3014260278922' then '6037833520'
    else i.numero_lote
  end
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '306277'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
  and r.estado = 'borrador'
  and i.codigo_escaneado in ('3014260279264', '3014260278922');

select sku, codigo_barras, nombre, presentacion
from public.productos
where codigo_barras in ('3014260279264', '3014260278922')
   or sku in ('FC-60279264', 'FC-60278922')
order by codigo_barras;

commit;
