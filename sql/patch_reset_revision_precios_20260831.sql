-- ============================================================================
-- Restaurar sugerencias Subir / Bajar / Aceptar
-- Fecha: 2026-08-31
--
-- Qué pasó: al abrir Referencias, el front selló
--   configuracion.precios_revision_venta.epoch = Date.now()
-- y eso escondió todas las refs que el bot ya había escrito.
-- El bot solo actualiza mercado; no acepta.
--
-- Este parche pone epoch = 1 (no 0: el JS viejo trata 0 como “sin epoch”
-- y vuelve a sellar Date.now()). Conserva porId (Aceptar/Subir/Bajar a mano).
--
-- Pegar en Supabase → SQL Editor → Run. Luego recargar Referencias.
-- ============================================================================

-- Antes (opcional): ver el sello que escondió los botones.
-- No uses jsonb_object_keys_count: no existe en Postgres.
select
  c.clave,
  c.valor::jsonb->>'epoch' as epoch_ms,
  case
    when (c.valor::jsonb->>'epoch') ~ '^[0-9]+$'
      and (c.valor::jsonb->>'epoch')::bigint > 100000
    then to_timestamp((c.valor::jsonb->>'epoch')::bigint / 1000.0)
           at time zone 'America/Mexico_City'
    else null
  end as epoch_mexico,
  (
    select count(*)
    from jsonb_each(coalesce((c.valor::jsonb)->'porId', '{}'::jsonb))
  ) as aceptadas_a_mano
from public.configuracion c
where c.clave = 'precios_revision_venta';

insert into public.configuracion (clave, valor)
values ('precios_revision_venta', '{"epoch":1,"porId":{}}')
on conflict (clave) do update
set valor = jsonb_build_object(
  'epoch', 1,
  'porId', coalesce((public.configuracion.valor::jsonb)->'porId', '{}'::jsonb)
)::text;

-- Después: epoch debe ser 1.
select
  c.clave,
  c.valor::jsonb->>'epoch' as epoch_ms,
  (
    select count(*)
    from jsonb_each(coalesce((c.valor::jsonb)->'porId', '{}'::jsonb))
  ) as aceptadas_a_mano,
  c.valor
from public.configuracion c
where c.clave = 'precios_revision_venta';
