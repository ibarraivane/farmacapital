-- Todos los tickets: enlazar EANs que ya están en catálogo y entrar stock
-- de renglones verdes con MMAA sin lote.
-- No crea productos nuevos (eso va en el SQL de alta de cada ticket).
-- No borra renglones. Idempotente.
-- Pegar en Supabase → SQL Editor → Run.

begin;

-- 1) Relink: pendiente_alta / sin producto_id, pero el EAN ya existe.
update public.recepcion_items i
set
  producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
  pendiente_alta = false
where (i.pendiente_alta or i.producto_id is null)
  and nullif(btrim(i.codigo_escaneado), '') is not null
  and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null;

commit;

-- 2) Stock huérfano (confirmado + MMAA + sin lote).
select
  case
    when exists (
      select 1 from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'recepcion_reparar_stock_huerfanos'
    ) then public.recepcion_reparar_stock_huerfanos(null)
    else jsonb_build_object('skipped', 'falta patch_recepcion_verde_sin_stock_20260903')
  end as reparacion_stock;

-- 3) Diagnóstico: lo que Recibir todavía no puede sumar.
select
  r.proveedor,
  r.folio,
  r.estado,
  count(*) filter (where i.pendiente_alta) as pendiente_alta,
  count(*) filter (where i.confirmado and i.lote_id is not null) as con_stock,
  count(*) filter (where i.confirmado and i.lote_id is null and i.fecha_caducidad is not null) as verde_sin_lote,
  count(*) filter (where not i.confirmado and not i.pendiente_alta) as gris_listo_pistola
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad', 'parcial')
group by r.id, r.proveedor, r.folio, r.estado
order by (count(*) filter (where i.pendiente_alta)) desc, r.id desc;

select
  r.proveedor,
  r.folio,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.confirmado,
  i.fecha_caducidad,
  i.lote_id
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where i.pendiente_alta
order by r.proveedor, r.folio, i.id
limit 200;
