-- Kannes Delta shampoo 250 ml · Pet's Pharma · uso veterinario
-- Botella: EAN-13 7506343804129 (dígito verificador 9).
-- SKU FarmaCapital: FC-1792190821000. No se cambia.
-- M26125 impreso junto al código es el SKU de fábrica, no el de la tienda.
-- Pegar este archivo si el ticket 143865 ya se cargó sin código.
-- Si todavía no se cargó, basta con patch_carga_hacienda_143865.sql.

begin;

update public.productos p
set codigo_barras = '7506343804129'
where p.sku = 'FC-1792190821000'
  and (
    p.codigo_barras is null
    or trim(p.codigo_barras) = ''
    or p.codigo_barras = '7506343804129'
  )
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506343804129'
      and o.sku <> 'FC-1792190821000'
  );

update public.recepcion_items i
set codigo_escaneado = '7506343804129'
from public.recepciones r
join public.productos p on p.sku = 'FC-1792190821000'
where i.recepcion_id = r.id
  and (
    i.producto_id = p.id
    or (
      i.producto_id is null
      and i.nombre_snapshot ilike '%kannes%'
    )
  )
  and r.folio = '143865'
  and coalesce(r.proveedor, '') ilike '%hacienda%'
  and r.estado = 'borrador'
  and (
    i.codigo_escaneado is null
    or trim(i.codigo_escaneado) = ''
    or i.codigo_escaneado = '7506343804129'
  );

update public.recepciones
set
  notas = 'Ticket Bodega G-71 La Hacienda Pets 143865 · 16-oct-2026 16:47 · efectivo $290.00 · sello PAGADO · cola Recibir. El papel no trae código. La botella es EAN 7506343804129. M26125 es el código de fábrica, no el SKU. Pon MMAA de la botella.',
  updated_at = now()
where folio = '143865'
  and coalesce(proveedor, '') ilike '%hacienda%'
  and estado = 'borrador';

commit;

select sku, codigo_barras, nombre
from public.productos
where sku = 'FC-1792190821000'
   or codigo_barras = '7506343804129';

select r.folio, r.estado, i.codigo_escaneado, i.nombre_snapshot, i.cantidad
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '143865'
  and coalesce(r.proveedor, '') ilike '%hacienda%';
