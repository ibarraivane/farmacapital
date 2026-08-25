-- Cierra el hueco del ajuste anterior.
--
-- patch_recepcion_levic_A9012100253_ajuste.sql corrigió productos.costo y
-- lotes.costo_unitario, pero NO recepcion_items.costo_estimado — y eso es
-- justo lo que leen la pestaña Historia y la referencia de "última compra".
-- Sin esto, la Historia sigue diciendo que el Fluconazol se compró a 12.92.
--
-- También sincroniza numero_lote del renglón con el del lote (el ajuste
-- renombró el lote pero dejó el renglón con el nombre viejo).
-- Idempotente. Pegar en Supabase.

begin;

update public.recepcion_items i
set costo_estimado = v.costo
from (values
  (3619::bigint,  13.61::numeric),   -- AMS165 Fluconazol 1 caps 150 mg
  (3621,           9.28),            -- AMS253 Dexametasona 1 FA 8mg/2ml
  (3625,         148.89)             -- CHI030 Neuralin iny 2 amp
) as v(item_id, costo)
where i.id = v.item_id
  and i.recepcion_id = 14;

-- el renglón debe decir el mismo lote que su lote real
update public.recepcion_items i
set numero_lote = l.numero_lote
from public.lotes l
where i.recepcion_id = 14
  and i.lote_id = l.id
  and i.numero_lote is distinct from l.numero_lote;

commit;

-- ─────────────── Comprobación ───────────────
select
  i.id,
  i.codigo_escaneado as ean,
  left(p.nombre, 32) as producto,
  i.cantidad,
  i.costo_estimado as costo_historia,
  i.numero_lote as lote_renglon,
  l.numero_lote as lote_real,
  l.costo_unitario as costo_lote,
  p.costo as costo_catalogo
from public.recepcion_items i
left join public.productos p on p.id = i.producto_id
left join public.lotes l on l.id = i.lote_id
where i.recepcion_id = 14 and i.producto_id is not null
order by i.id;
