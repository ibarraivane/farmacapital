-- Registro de eventos del bus en app (ver src/core/eventStore/initEventStore.js).
-- Ejecutar en Supabase SQL Editor o psql tras revisar RLS/políticas según tu modelo de auth.

create table if not exists event_log (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  payload jsonb,
  created_at timestamp default now()
);
