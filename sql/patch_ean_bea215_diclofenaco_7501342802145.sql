-- ============================================================================
-- EQ-BEA215 · Diclofenaco beadvance 100 mg C/20 · EAN de caja
-- Fuente: Farmasmart packshot Be Advance 20 tabs · EAN 7501342802145
-- (familia Beadvance 75013428…; NO confundir con AMSA iny 7501349025929
--  ni con Ultra C/20 7502216802919 / EQ-ULT103)
--
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Luego en Recibir: tocar el renglón gris → MMAA de la caja → Guardar.
-- ============================================================================

begin;

-- Catálogo: solo si aún no tiene EAN (no pisa otro producto).
update public.productos
set codigo_barras = '7501342802145'
where sku = 'EQ-BEA215'
  and (
    codigo_barras is null
    or btrim(codigo_barras) = ''
    or codigo_barras = 'EQ-BEA215'
  )
  and not exists (
    select 1 from public.productos p2
    where p2.codigo_barras = '7501342802145'
      and p2.sku is distinct from 'EQ-BEA215'
  );

-- Ticket Levic 9012545305: pistola debe abrir el renglón.
update public.recepcion_items i
set codigo_escaneado = '7501342802145'
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012545305'
  and coalesce(r.proveedor, '') ilike '%levic%'
  and r.estado = 'borrador'
  and not coalesce(i.confirmado, false)
  and (
    i.codigo_escaneado is null
    or i.codigo_escaneado in ('EQ-BEA215', 'BEA215')
  )
  and (
    i.producto_id = public.fc_buscar_producto_escaneo('EQ-BEA215')
    or i.nombre_snapshot ilike '%beadvance%diclofenaco%'
    or i.nombre_snapshot ilike '%diclofenaco%beadvance%'
  );

commit;

select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.marca,
  p.presentacion
from public.productos p
where p.sku = 'EQ-BEA215'
   or p.codigo_barras = '7501342802145';

select
  i.codigo_escaneado,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.numero_lote,
  i.confirmado,
  i.fecha_caducidad
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '9012545305'
  and coalesce(r.proveedor, '') ilike '%levic%'
  and (
    i.codigo_escaneado = '7501342802145'
    or i.nombre_snapshot ilike '%beadvance%'
  );
