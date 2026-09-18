-- 00/N — crea staging (NO es temp: cada parte se pega en una query del SQL Editor).
-- Orden: 00, luego 01.., luego 99. Primero: patch_fuentes_bajo_pedido_20260917.sql

begin;

do $$
begin
  if not exists (
    select 1 from information_schema.columns
     where table_schema = 'public' and table_name = 'productos' and column_name = 'bajo_pedido'
  ) then
    raise exception 'Primero corre sql/patch_bajo_pedido_20260916.sql';
  end if;
end
$$;

create table if not exists public._fc_cat_bp_stg (
  sku text not null,
  ean text,
  nombre text not null,
  marca text,
  presentacion text,
  categoria text not null,
  subcategoria text,
  tipo text not null,
  costo numeric(12,2),
  precio numeric(12,2) not null,
  imagen_url text,
  fuente text not null,
  sku_externo text,
  techo numeric(12,2),
  disponible boolean not null default true
);

truncate public._fc_cat_bp_stg;
commit;

select 'staging lista' as ok;
