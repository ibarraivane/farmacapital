-- ============================================================================
-- FARMA CAPITAL — Baby Einstein Neptune's Busy Bubbles
-- UPC empaque (fotos): 0 74451 16656 1  →  074451166561
-- Modelo Kids2 16656 · Ocean Explorers · juguete sensorial 3+ meses
--
-- Ficha: Kids2 / Baby Einstein (barcode 074451166561, SKU 16656-000).
-- Nombre de mostrador = marca + producto real (no código interno).
--
-- Stock 1 (pieza en mano) · lote S/L sin caducidad.
-- Sin costo de compra (no hay ticket). PVP $250 (indicado en mostrador).
-- Cuando haya remisión: actualizar costo / costo_unitario del lote.
-- INSERT ONLY. Pegar TODO en Supabase → SQL Editor → Run.
-- Foto: tras deploy → patch_fotos_baby_einstein_busy_bubbles_074451166561.sql
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in (
           '074451166561',
           '74451166561',
           '0074451166561'
         )
       or p.sku in ('FC-45116656', 'FC-ND-45116656')
       or (
         p.nombre ilike '%busy bubbles%'
         and p.nombre ilike '%baby einstein%'
       )
       or (
         p.nombre ilike '%neptune%'
         and p.nombre ilike '%busy bubbles%'
       )
  ) then
    raise notice 'Baby Einstein Busy Bubbles ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Baby Einstein Neptune''s Busy Bubbles juguete sensorial Ocean Explorers',
      'sku', 'FC-45116656',
      'codigo_barras', '074451166561',
      'categoria', 'Otro',
      'tipo', 'marca',
      'descripcion', 'Alta foto mostrador 2026-09-12 · Kids2 modelo 16656 · UPC 074451166561 · juguete de actividades sensoriales 3+ meses · luces/música · 3 AA · sin costo de compra · PVP 250',
      'costo', null,
      'precio', 250.00,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    'S/L',
    null::date,
    null,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Baby Einstein',
    presentacion = '1 pieza · modelo 16656 · 3+ meses',
    forma_farmaceutica = 'Juguete',
    subcategoria = 'Juguetes',
    requiere_receta = false
  where id = v_pid;

  raise notice 'Baby Einstein Busy Bubbles creado id % lote % stock 1 PVP 250 sin costo', v_pid, v_lid;
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
where p.codigo_barras in ('074451166561', '74451166561', '0074451166561')
   or p.sku in ('FC-45116656', 'FC-ND-45116656')
order by p.id desc
limit 5;
