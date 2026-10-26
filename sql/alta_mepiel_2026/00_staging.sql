-- ME Piel lista 2026 — staging.
-- Costo = precio cliente c/IVA. productos.precio no se publica (Ordenar).
-- Antes: sql/patch_bajo_pedido_20260916.sql y sql/patch_fuentes_bajo_pedido_20260917.sql
-- Orden: 00, 01…, 99.

begin;

update public.fuentes_precio
   set notas = 'Mayoreo dermo. Lista 2026: precio cliente c/IVA. El PVP de la lista es techo, no costo.'
 where id = 'mepiel';

create table if not exists public._fc_mepiel_stg (
  sku text not null,
  ean text,
  nombre text not null,
  marca text,
  presentacion text,
  concentracion text,
  forma text,
  categoria text not null,
  subcategoria text,
  linea text,
  costo numeric(12,2),
  techo numeric(12,2),
  imagen_url text,
  oferta text
);

truncate public._fc_mepiel_stg;
commit;

select 'staging mepiel lista' as ok;
