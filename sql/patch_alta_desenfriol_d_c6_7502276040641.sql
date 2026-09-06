-- ============================================================================
-- FARMACAPITAL — Desenfriol D tabletas C/6
-- EAN 7502276040641 · Bayer OTC · caducidad JUL/2027 (foto mostrador)
--
-- Distinto de FC-60403681 (7502276040368 = Desenfriol D C/30).
-- Stock 1 + lote con caducidad fin de julio 2027.
-- Sin costo de compra (ticket en foto es Farmamayoreo Blumen; no trae este EAN).
-- PVP ancla ~$27 (Rappi/Soriana/WeCare 23–29).
-- INSERT ONLY. Pegar TODO en Supabase → SQL Editor → Run.
-- Foto: tras deploy → patch_fotos_dove_lysol_mostrador_20260906.sql
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in ('7502276040641', '75022760406410')
       or p.sku in ('FC-27604064', 'FC-6040641')
       or (
         p.nombre ilike '%desenfriol%d%'
         and (
           p.presentacion ilike '%c/6%'
           or p.presentacion ilike '%6 tableta%'
           or p.nombre ilike '%c/6%'
         )
       )
  ) then
    raise notice 'Desenfriol D C/6 ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Desenfriol D tabletas C/6',
      'sku', 'FC-27604064',
      'codigo_barras', '7502276040641',
      'categoria', 'Medicamentos',
      'tipo', 'marca',
      'descripcion', 'Desenfriol D Bayer OTC · clorfenamina 2 mg / fenilefrina 5 mg / paracetamol 500 mg · C/6 · EAN 7502276040641 · foto mostrador cad JUL/2027 · sin costo de ticket',
      'costo', null,
      'precio', 27.00,
      'stock_minimo', 2,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    'S/L',
    '2027-07-31'::date,
    null,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Desenfriol',
    presentacion = 'Caja con 6 tabletas',
    principio_activo = 'Clorfenamina 2 mg / Fenilefrina 5 mg / Paracetamol 500 mg',
    forma_farmaceutica = 'Tableta',
    subcategoria = 'Antigripal',
    requiere_receta = false
  where id = v_pid;

  raise notice 'Desenfriol D C/6 creado id % lote % cad 2027-07-31', v_pid, v_lid;
end $$;

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.principio_activo,
  p.costo,
  p.precio,
  p.stock,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l
  on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in ('7502276040641', '7502276040368')
   or p.sku in ('FC-27604064', 'FC-60403681')
order by p.codigo_barras, p.sku;
