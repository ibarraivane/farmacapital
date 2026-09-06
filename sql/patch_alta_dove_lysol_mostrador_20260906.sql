-- ============================================================================
-- FARMA CAPITAL — Altas foto mostrador 06-sep-2026
--
-- Dove Tono Uniforme Caléndula aerosol 150 ml · EAN 7506306241152
-- Lysol Crisp Linen desinfectante 354 g · EAN 7501058796882
--
-- eGo Force roll-on YA está (FC-75064938 / 75064938) — no se toca.
--
-- NO confundir:
--   Dove 7506306241206 (FC-06241206) ni 3PACK 7506306248052 (FC-06248052)
--   Lysol 475 g 7501058752796 (FC-58752796)
--
-- Sin costo de compra (foto, no ticket). PVP ancla:
--   Dove ~$90 (Soriana ~91.50)
--   Lysol 354 g $139 (Home Depot MX)
-- Stock 0 hasta Recibir. SIN do $$.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Fotos: después del deploy → patch_fotos_dove_lysol_mostrador_20260906.sql
-- ============================================================================

begin;

create temp table _fc_foto_altas (
  ean text primary key,
  sku text not null,
  nombre text not null,
  precio numeric(12,2) not null,
  categoria text not null,
  marca text not null,
  presentacion text not null,
  forma_farmaceutica text not null,
  subcategoria text not null,
  descripcion text not null
) on commit drop;

insert into _fc_foto_altas values
  (
    '7506306241152',
    'FC-06241152',
    'Dove antitranspirante aerosol Tono Uniforme Caléndula 150 ml',
    90.00,
    'Higiene',
    'Dove',
    'Aerosol 150 ml (87 g)',
    'Aerosol',
    'Desodorante',
    'Alta foto mostrador 2026-09-06 · Unilever Dove MX EAN 7506306241152 · 72h · caléndula + vitamina E · PVP ancla Soriana ~91.50 · sin costo de compra'
  ),
  (
    '7501058796882',
    'FC-58796882',
    'Lysol desinfectante antibacterial Crisp Linen 354 g',
    139.00,
    'Higiene',
    'Lysol',
    'Aerosol 354 g',
    'Aerosol',
    'Desinfectante',
    'Alta foto mostrador 2026-09-06 · Reckitt Benckiser · EAN 7501058796882 · Crisp Linen 354 g (no es el de 475 g) · PVP ancla Home Depot 139 · sin costo de compra'
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  'marca',
  t.descripcion,
  null,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.presentacion,
  t.forma_farmaceutica,
  t.subcategoria
from _fc_foto_altas t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
       or p.codigo_barras = t.ean
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  p.categoria,
  p.activo
from public.productos p
where p.codigo_barras in ('7506306241152', '7501058796882', '75064938')
   or p.sku in (
     'FC-06241152', 'FC-58796882', 'FC-75064938',
     'FC-ND-06241152', 'FC-ND-58796882',
     'FC-06241206', 'FC-06248052', 'FC-58752796'
   )
order by p.codigo_barras, p.sku;
