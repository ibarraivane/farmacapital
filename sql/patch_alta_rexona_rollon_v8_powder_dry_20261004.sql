-- ============================================================================
-- FARMA CAPITAL — Alta foto: Rexona roll-on 30 ml (2 SKUs)
--
-- 1) Rexona Men V8 antitranspirante roll-on 30 ml
--    EAN-8  78930841  ·  SKU FC-78930841
--    Ficha Unilever/Rexona BR · caducidad caja V 02/28 · lote ULB251954
--
-- 2) Rexona Powder Dry antitranspirante roll-on 30 ml
--    EAN-8  78924239  ·  SKU FC-78924239
--    Ficha Unilever/Rexona BR · caducidad caja V 03/28 · lote ULC061232
--
-- Compra mostrador: 6 pzas c/u · costo $18 · marca → PVP ceil(18×1.25) = $23
-- (recargo +25% sobre costo; margen real ~21.7% sobre venta).
--
-- NO confundir:
--   78924338 Rexona Woman Powder roll-on 53 g (ya en catálogo)
--   7791293022567 Rexona Men V8 aerosol/tun (otro SKU)
--
-- INSERT ONLY. Pegar TODO en Supabase → SQL Editor → Run.
-- Fotos: tras deploy → patch_fotos_rexona_rollon_v8_powder_dry_20261004.sql
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  -- ── Rexona Men V8 30 ml ──────────────────────────────────────────────
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in ('78930841', '00000078930841', '078930841')
       or p.sku in ('FC-78930841', 'FC-ND-78930841')
  ) then
    raise notice 'Rexona Men V8 78930841 ya existe; no se inserta.';
  else
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Rexona Men V8',
        'sku', 'FC-78930841',
        'codigo_barras', '78930841',
        'categoria', 'Higiene',
        'tipo', 'marca',
        'descripcion', 'Alta foto 2026-10-04 · Unilever Rexona Men V8 antitranspirante roll-on 30 ml · EAN-8 78930841 · 72h · 0% alcohol etílico · compra 6×$18 · PVP 23 (+25% marca)',
        'costo', 18,
        'precio', 23,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false,
        'marca', 'Rexona',
        'presentacion', 'Roll-on 30 ml',
        'forma_farmaceutica', 'Roll-on'
      ),
      6,
      'ULB251954',
      '2028-02-29'::date,
      18,
      null::bigint
    ) f;

    update public.productos set
      marca = 'Rexona',
      presentacion = 'Roll-on 30 ml',
      forma_farmaceutica = 'Roll-on',
      subcategoria = 'Desodorante',
      requiere_receta = false
    where id = v_pid;

    raise notice 'Rexona Men V8 creado id % lote % stock 6 cad 2028-02-29 PVP 23', v_pid, v_lid;
  end if;

  -- ── Rexona Powder Dry 30 ml ──────────────────────────────────────────
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in ('78924239', '00000078924239', '078924239')
       or p.sku in ('FC-78924239', 'FC-ND-78924239')
  ) then
    raise notice 'Rexona Powder Dry 78924239 ya existe; no se inserta.';
  else
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Rexona Powder Dry',
        'sku', 'FC-78924239',
        'codigo_barras', '78924239',
        'categoria', 'Higiene',
        'tipo', 'marca',
        'descripcion', 'Alta foto 2026-10-04 · Unilever Rexona Powder Dry antitranspirante roll-on 30 ml · EAN-8 78924239 · 72h · 0% alcohol etílico · compra 6×$18 · PVP 23 (+25% marca)',
        'costo', 18,
        'precio', 23,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false,
        'marca', 'Rexona',
        'presentacion', 'Roll-on 30 ml',
        'forma_farmaceutica', 'Roll-on'
      ),
      6,
      'ULC061232',
      '2028-03-31'::date,
      18,
      null::bigint
    ) f;

    update public.productos set
      marca = 'Rexona',
      presentacion = 'Roll-on 30 ml',
      forma_farmaceutica = 'Roll-on',
      subcategoria = 'Desodorante',
      requiere_receta = false
    where id = v_pid;

    raise notice 'Rexona Powder Dry creado id % lote % stock 6 cad 2028-03-31 PVP 23', v_pid, v_lid;
  end if;
end $$;

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.forma_farmaceutica,
  p.subcategoria,
  p.categoria,
  p.tipo,
  p.costo,
  p.precio,
  p.stock,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual,
  l.costo_unitario
from public.productos p
left join public.lotes l
  on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in ('78930841', '78924239')
   or p.sku in ('FC-78930841', 'FC-78924239', 'FC-ND-78930841', 'FC-ND-78924239')
order by p.codigo_barras, p.sku;
