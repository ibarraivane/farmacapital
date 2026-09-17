-- ============================================================================
-- FarmaCapital — 2026-09-17
-- Ketorolaco / Tramadol AMSA (EAN 7501349029040, SKU FC-49029040)
-- Tramadol = Fracción III (art. 245 LGS, vigencia COFEPRIS jul-2026).
-- Solo se vende en mostrador con receta (no tienda web / Rappi / envío).
--
-- Idempotente: crea controlado / grupo_controlado / visible_tienda si faltan.
-- ============================================================================

begin;

alter table public.productos
  add column if not exists controlado boolean not null default false;

alter table public.productos
  add column if not exists grupo_controlado text;

alter table public.productos
  add column if not exists visible_tienda boolean not null default true;

comment on column public.productos.controlado is
  'Medicamento controlado COFEPRIS: solo mostrador (no tienda web / Rappi).';
comment on column public.productos.grupo_controlado is
  'Fracción LGS art. 245 (I–V). Ej. tramadol = III.';
comment on column public.productos.visible_tienda is
  'Si false, no aparece en catálogo web (controlados, etc.).';

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
      and (nombre ilike '%inyect%' or nombre ilike '%ampol%' or nombre ilike '%10%')
    );

commit;

select id, sku, nombre, codigo_barras, controlado, grupo_controlado, requiere_receta, visible_tienda
  from public.productos
 where codigo_barras = '7501349029040'
    or sku = 'FC-49029040';
