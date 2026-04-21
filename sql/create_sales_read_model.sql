-- Materialización del read model de ventas (ver src/core/readModels/syncSalesModel.js).

create table if not exists sales_read_model (
  id uuid primary key default gen_random_uuid(),
  date text not null unique,
  total numeric not null default 0,
  count integer not null default 0
);
