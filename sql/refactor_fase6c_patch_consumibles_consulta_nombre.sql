-- FARMAX — Columna consumibles_consulta.nombre (denormalizada para ticket/UI sin join).
-- Corrige: column consumibles_consulta_1.nombre does not exist (PostgREST / Supabase).
-- Ejecutar en Supabase SQL Editor. Idempotente.

begin;

alter table public.consumibles_consulta
  add column if not exists nombre text;

comment on column public.consumibles_consulta.nombre is 'Copia del nombre del producto al registrar el consumible; evita embed productos en lecturas.';

-- Rellenar filas viejas que tengan producto_id
update public.consumibles_consulta cc
set nombre = p.nombre
from public.productos p
where cc.producto_id = p.id
  and (cc.nombre is null or btrim(cc.nombre) = '');

commit;
