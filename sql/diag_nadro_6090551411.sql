-- SOLO DIAGNÓSTICO — no escribe nada.
-- Folio Nadro 6090551411. Pegar en Supabase → SQL Editor → Run.
--
-- Cómo leerlo:
--   0 filas del folio          → nunca se cargó patch_carga_nadro_6090551411.sql
--   estado = borrador, 4 renglones, pendientes_pistola = 4 → vivo en Recibir
--   Hypafix/Asepxia ausentes   → confirmá que corriste CARGA, no solo FOTOS

select
  r.id,
  r.folio,
  r.estado,
  r.fecha,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where coalesce(i.confirmado, false)) as confirmados,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola,
  left(coalesce(r.notas, ''), 80) as notas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%nadro%'
  and r.folio = '6090551411'
group by r.id, r.folio, r.estado, r.fecha, r.total_ticket, r.notas
order by r.id;

select
  p.id,
  p.sku,
  p.codigo_barras,
  left(p.nombre, 48) as nombre,
  p.costo,
  p.precio,
  case
    when p.imagen_url like '%catalogo-propia/%' then 'foto_propia'
    when coalesce(p.imagen_url, '') = '' then 'sin_foto'
    else 'otra'
  end as foto
from public.productos p
where p.codigo_barras in (
  '7501026462245',
  '4042809591446',
  '650240032431',
  '650240032455'
)
order by p.codigo_barras;
