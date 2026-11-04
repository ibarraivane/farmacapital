-- =============================================================================
-- SOLO diagnostico + reopen seguro (sin crear tickets nuevos)
-- Si un folio dice NO EXISTE, pegá despues patch_recibir_PEGAR_ESTO_TODO.sql
-- Sin dollar-quote.
-- =============================================================================

with esperados(proveedor_like, folio, etiqueta) as (
  values
    ('%tenorio%', '3838940', 'Tenorio'),
    ('%fanasa%', 'B49445264', 'Fanasa Fluxedan'),
    ('%fanasa%', 'B49397867', 'Fanasa Lubrex'),
    ('%nadro%', '6091110421', 'Nadro 6091110421'),
    ('%nadro%', '6091723171', 'Nadro 6091723171'),
    ('%nadro%', '6091546907', 'Nadro 6091546907'),
    ('%levic%', '9012545305', 'Levic 9012545305'),
    ('%levic%', '9012442706', 'Levic 9012442706'),
    ('%equilibrio%', '450233', 'Equilibrio 450233'),
    ('%equilibrio%', '450041', 'Equilibrio 450041'),
    ('%cityfarma%', 'S336478', 'Cityfarma S336478'),
    ('%cityfarma%', 'S336493', 'Cityfarma S336493'),
    ('%bodega%f-42%', '76370', 'Bodega 76370'),
    ('%farmalive%', '11104', 'Farmalive 11104')
)
select
  e.folio,
  e.etiqueta,
  r.estado,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado,false)) as sin_confirmar,
  count(*) filter (where i.lote_id is not null) as con_stock_lote,
  case
    when r.id is null then 'NO EXISTE'
    when count(*) filter (where i.lote_id is not null) = count(i.*)
      and count(i.*) > 0
      and count(*) filter (where not coalesce(i.confirmado,false)) = 0
      then 'YA RECIBIDO'
    when r.estado = 'borrador' and count(*) filter (where not coalesce(i.confirmado,false)) > 0
      then 'OK visible'
    when r.estado is distinct from 'borrador' and count(*) filter (where i.lote_id is not null) = 0
      then 'CERRADO SIN STOCK — se reabre abajo'
    else 'REVISAR'
  end as veredicto
from esperados e
left join public.recepciones r
  on r.folio = e.folio
 and (e.folio = '76370' or coalesce(r.proveedor,'') ilike e.proveedor_like)
left join public.recepcion_items i on i.recepcion_id = r.id
group by e.folio, e.etiqueta, r.id, r.estado
order by e.folio;

begin;
update public.recepciones r
set estado = 'borrador', updated_at = now()
where r.estado is distinct from 'borrador'
  and (
       (r.folio = '3838940' and coalesce(r.proveedor,'') ilike '%tenorio%')
    or (r.folio in ('B49445264','B49397867') and coalesce(r.proveedor,'') ilike '%fanasa%')
    or (r.folio in ('6091110421','6091723171','6091546907') and coalesce(r.proveedor,'') ilike '%nadro%')
    or (r.folio in ('9012545305','9012442706') and coalesce(r.proveedor,'') ilike '%levic%')
    or (r.folio in ('450233','450041') and coalesce(r.proveedor,'') ilike '%equilibrio%')
    or (r.folio in ('S336478','S336493') and coalesce(r.proveedor,'') ilike '%cityfarma%')
    or (r.folio = '76370' and coalesce(r.proveedor,'') ilike '%bodega%f-42%')
    or (r.folio = '11104' and coalesce(r.proveedor,'') ilike '%farmalive%')
  )
  and not exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id and i.lote_id is not null
  );

update public.recepcion_items i
set confirmado = false
from public.recepciones r
where i.recepcion_id = r.id
  and coalesce(i.confirmado, false) = true
  and i.lote_id is null
  and i.fecha_caducidad is null
  and r.estado = 'borrador'
  and (
       (r.folio = '3838940' and coalesce(r.proveedor,'') ilike '%tenorio%')
    or (r.folio in ('B49445264','B49397867') and coalesce(r.proveedor,'') ilike '%fanasa%')
    or (r.folio in ('6091110421','6091723171','6091546907') and coalesce(r.proveedor,'') ilike '%nadro%')
    or (r.folio in ('9012545305','9012442706') and coalesce(r.proveedor,'') ilike '%levic%')
    or (r.folio in ('450233','450041') and coalesce(r.proveedor,'') ilike '%equilibrio%')
    or (r.folio in ('S336478','S336493') and coalesce(r.proveedor,'') ilike '%cityfarma%')
    or (r.folio = '76370' and coalesce(r.proveedor,'') ilike '%bodega%f-42%')
    or (r.folio = '11104' and coalesce(r.proveedor,'') ilike '%farmalive%')
  );
commit;

select r.proveedor, r.folio, r.estado,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado,false)) as sin_confirmar,
  case
    when count(i.*) = 0 then 'FALTA RENGLONES — corre PEGAR_ESTO_TODO'
    when count(*) filter (where not coalesce(i.confirmado,false)) > 0 then 'OK visible en Recibir'
    else 'YA RECIBIDO o revisa'
  end as veredicto
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where (
       (r.folio = '3838940' and coalesce(r.proveedor,'') ilike '%tenorio%')
    or (r.folio in ('B49445264','B49397867') and coalesce(r.proveedor,'') ilike '%fanasa%')
    or (r.folio in ('6091110421','6091723171','6091546907') and coalesce(r.proveedor,'') ilike '%nadro%')
    or (r.folio in ('9012545305','9012442706') and coalesce(r.proveedor,'') ilike '%levic%')
    or (r.folio in ('450233','450041') and coalesce(r.proveedor,'') ilike '%equilibrio%')
    or (r.folio in ('S336478','S336493') and coalesce(r.proveedor,'') ilike '%cityfarma%')
    or (r.folio = '76370')
    or (r.folio = '11104' and coalesce(r.proveedor,'') ilike '%farmalive%')
  )
group by r.id, r.proveedor, r.folio, r.estado
order by r.proveedor, r.folio;
