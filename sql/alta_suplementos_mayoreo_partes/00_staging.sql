-- Suplementos Mayoreo — staging. Pegar en el SQL Editor EN ORDEN.
-- Antes: sql/patch_bajo_pedido_20260916.sql y sql/patch_fuente_suplementosmayoreo_20260922.sql
-- El precio del CSV es costo. productos.precio queda 0 (botón Ordenar).

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

create table if not exists public._fc_cat_sm_stg (
  sku text not null,
  ean text,
  nombre text not null,
  marca text,
  presentacion text,
  concentracion text,
  forma_farmaceutica text,
  categoria text not null,
  subcategoria text,
  tipo text not null,
  costo numeric(12,2),
  precio numeric(12,2) not null,
  imagen_url text,
  fuente text not null,
  sku_externo text
);

truncate public._fc_cat_sm_stg;
commit;

select 'staging suplementos mayoreo lista' as ok;
