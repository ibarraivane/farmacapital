-- ============================================================================
-- FarmaCapital — 2026-09-17
-- Ketorolaco / Tramadol AMSA (EAN 7501349029040, SKU FC-49029040)
-- Tramadol = Fracción III (art. 245 LGS, vigencia COFEPRIS jul-2026).
-- Solo se vende en mostrador con receta (no tienda web / Rappi / envío).
-- ============================================================================

begin;

update public.productos
   set controlado = true,
       grupo_controlado = coalesce(nullif(btrim(grupo_controlado), ''), 'III'),
       requiere_receta = true,
       visible_tienda = false
 where codigo_barras = '7501349029040'
    or sku = 'FC-49029040'
    or (
      nombre ilike '%ketorolaco%'
      and nombre ilike '%tramadol%'
      and (nombre ilike '%inyect%' or nombre ilike '%ampol%' or nombre ilike '%10%' )
    );

commit;

select id, sku, nombre, codigo_barras, controlado, grupo_controlado, requiere_receta, visible_tienda
  from public.productos
 where codigo_barras = '7501349029040'
    or sku = 'FC-49029040';
