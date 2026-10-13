-- Tukol-D adulto (FC-40010712): POS decía «Sin lotes» con 1 en inventario.
--
-- Causa: patch_restaurar_caducidades_y_costos_20260818.sql guardó
-- fecha_caducidad = 0027-10-01 (año 27 d.C., basura OCR de 2027-10-01).
-- Inventario suma cantidad_actual del lote → muestra 1.
-- POS FEFO / get_lote_fefo tratan esa fecha como vencida → 0 vendible → bloquea Agregar.
--
-- Idempotente. Correr en Supabase SQL Editor.
-- 1) Corrige años < 1990 (00YY → 20YY si cae en 2020–2045; si no, NULL).
-- 2) get_lote_fefo: años inválidos = sin MMAA (se venden, no se tiran).

begin;

-- A) Datos: caducidades con año imposible
update public.lotes l
   set fecha_caducidad = case
     when extract(year from l.fecha_caducidad)::int between 0 and 99
      and (2000 + extract(year from l.fecha_caducidad)::int) between 2020 and 2045
     then make_date(
       2000 + extract(year from l.fecha_caducidad)::int,
       extract(month from l.fecha_caducidad)::int,
       least(
         extract(day from l.fecha_caducidad)::int,
         extract(day from (
           (date_trunc('month', make_date(
             2000 + extract(year from l.fecha_caducidad)::int,
             extract(month from l.fecha_caducidad)::int,
             1
           )) + interval '1 month - 1 day')::date
         ))::int
       )
     )
     else null
   end
 where l.fecha_caducidad is not null
   and extract(year from l.fecha_caducidad) < 1990;
-- FC-40010712 (Tukol-D adulto): 0027-10-01 → 2027-10-01 con la regla de arriba.

-- B) FEFO: no descartar basura OCR como «vencido»
create or replace function public.get_lote_fefo(
  p_producto_id bigint
)
returns table(
  lote_id bigint,
  numero_lote text,
  fecha_caducidad date,
  cantidad_disponible integer
)
language sql
security definer
set search_path = public
as $$
  select
    l.id as lote_id,
    l.numero_lote,
    case
      when l.fecha_caducidad is null then null
      when extract(year from l.fecha_caducidad)::int < 1990 then null
      when extract(year from l.fecha_caducidad)::int > 2045 then null
      else l.fecha_caducidad
    end as fecha_caducidad,
    coalesce(l.cantidad_actual, 0)::integer as cantidad_disponible
  from public.lotes l
  where l.producto_id = p_producto_id
    and l.activo = true
    and coalesce(l.cantidad_actual, 0) > 0
    and (
      l.fecha_caducidad is null
      or extract(year from l.fecha_caducidad)::int < 1990
      or extract(year from l.fecha_caducidad)::int > 2045
      or l.fecha_caducidad >= current_date
    )
  order by
    case
      when l.fecha_caducidad is null then 0
      when extract(year from l.fecha_caducidad)::int < 1990 then 0
      when extract(year from l.fecha_caducidad)::int > 2045 then 0
      else 1
    end,
    l.fecha_caducidad asc nulls first,
    l.id asc
  limit 1;
$$;

comment on function public.get_lote_fefo(bigint) is
  'FEFO: sin fecha / año inválido primero (stock ciego), luego la caducidad más próxima. No vende vencidos reales.';

grant execute on function public.get_lote_fefo(bigint) to anon, authenticated, service_role;

commit;

-- Verificación (opcional):
-- select p.sku, p.nombre, p.stock, l.id, l.cantidad_actual, l.fecha_caducidad, l.activo
--   from public.productos p
--   join public.lotes l on l.producto_id = p.id
--  where p.sku = 'FC-40010712';
-- select * from public.get_lote_fefo((select id from public.productos where sku = 'FC-40010712' limit 1));
