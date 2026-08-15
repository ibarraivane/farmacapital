-- ============================================================================
-- CARGAR faltantes corregidos — FarmaLive FL-080826
-- 0 productos con barcode y nombre limpio (Genomma 65024…, etc.)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;


commit;

select count(*) as productos_fc from public.productos where sku like 'FC-%';
