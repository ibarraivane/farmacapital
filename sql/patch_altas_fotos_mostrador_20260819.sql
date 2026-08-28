-- ============================================================
-- FARMACAPITAL — Altas desde fotos de mostrador (19-ago-2026)
-- ============================================================
-- 4 productos que NO están en catálogo (los EQ- cercanos son OTRA
-- presentación). 1 corrección: Dolo-Neurobion C/20 ya existe como
-- "Bolo Eurobion" inactivo (OCR).
--
-- Costos Levic 2026-08-18; lotes del ticket Equilibrio 440393
-- (Cirulan gotas: lote 120036 / cad MAR 29 coincide con la foto).
-- Stock inicial = piezas fotografiadas (no el ticket completo).
-- INSERT ONLY en los 4 nuevos. Idempotente.
-- ============================================================

begin;

-- 1) Flexiver 15 mg C/10 (NO es Flexiver Compuesto EQ-MAV174/175)
do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras = '7502009740459'
       or p.sku = 'EQ-MAV098'
  ) then
    raise notice 'Flexiver 15 mg C/10 ya existe; no se inserta.';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Flexiver Meloxicam 15 mg C/10',
      'sku', 'EQ-MAV098',
      'codigo_barras', '7502009740459',
      'categoria', 'Analgésico',
      'tipo', 'generico',
      'descripcion', 'Foto mostrador 2026-08-19 · Maver · receta · ≠ Flexiver Compuesto (cápsulas metocarbamol)',
      'costo', 22.50,
      'precio', 45,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', true
    ),
    2,
    '260502',
    '2028-01-01'::date,
    22.50,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Maver',
    presentacion = 'Caja con 10 tabletas',
    concentracion = '15 mg',
    principio_activo = 'Meloxicam',
    forma_farmaceutica = 'Tabletas',
    requiere_receta = true
  where id = v_pid;

  raise notice 'Flexiver 15 mg C/10 id % lote %', v_pid, v_lid;
end $$;

-- 2) Cirulan gotas 400 mg / 20 mL (NO es Cirulan tabletas EQ-NOV004)
do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras = '75006433'
       or p.sku = 'EQ-NOV005'
  ) then
    raise notice 'Cirulan gotas ya existe; no se inserta.';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Cirulan solución oral 400 mg / 20 mL',
      'sku', 'EQ-NOV005',
      'codigo_barras', '75006433',
      'categoria', 'Gastrointestinal',
      'tipo', 'generico',
      'descripcion', 'Foto mostrador 2026-08-19 · Novag · gotero 20 mL · ≠ Cirulan 20 tab 10 mg (EQ-NOV004)',
      'costo', 15,
      'precio', 28,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', true
    ),
    1,
    '120036',
    '2029-03-01'::date,
    15,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Novag',
    presentacion = 'Frasco gotero 20 mL',
    concentracion = '400 mg / 20 mL',
    principio_activo = 'Metoclopramida',
    forma_farmaceutica = 'Solución oral',
    requiere_receta = true
  where id = v_pid;

  raise notice 'Cirulan gotas id % lote %', v_pid, v_lid;
end $$;

-- 3) Tobramicina oftálmica OPKO 15 mL (NO es Tobra/Dexa Grin)
do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in ('7505101007405', '75050740')
       or p.sku = 'EQ-EXA040'
  ) then
    raise notice 'Tobramicina OPKO 15 mL ya existe; no se inserta.';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Tobramicina solución oftálmica 3 mg/mL 15 mL OPKO',
      'sku', 'EQ-EXA040',
      'codigo_barras', '7505101007405',
      'categoria', 'Oftálmico',
      'tipo', 'generico',
      'descripcion', 'Foto mostrador 2026-08-19 · Pharmacos Exakta / OPKO · Reg. 138M2004 · ≠ Tobra/Dexa Grin 5 mL (FC-00005823). Levic lista EAN corto 75050740.',
      'costo', 66.34,
      'precio', 110,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', true
    ),
    1,
    '26139P',
    '2028-04-20'::date,
    66.34,
    null::bigint
  ) f;

  update public.productos set
    marca = 'OPKO',
    presentacion = 'Caja con frasco gotero 15 mL',
    concentracion = '3 mg/mL',
    principio_activo = 'Tobramicina',
    forma_farmaceutica = 'Solución oftálmica',
    requiere_receta = true
  where id = v_pid;

  raise notice 'Tobramicina OPKO id % lote %', v_pid, v_lid;
end $$;

-- 4) Ridin Adulto 120 mL (NO es Ridin Pediátrica FC-01163232)
do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras = '7502001163072'
       or p.sku = 'EQ-SON112'
  ) then
    raise notice 'Ridin Adulto ya existe; no se inserta.';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Ridin Adulto jarabe dextrometorfano/guaifenesina/clorfenamina 120 mL',
      'sku', 'EQ-SON112',
      'codigo_barras', '7502001163072',
      'categoria', 'Respiratorio',
      'tipo', 'generico',
      'descripcion', 'Foto mostrador 2026-08-19 · Son''s · 7.5/100/1 mg por 5 mL · ≠ Ridin Pediátrica EAN 7502001163232',
      'costo', 41.87,
      'precio', 65,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    '26030796',
    '2028-03-01'::date,
    41.87,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Son''s',
    presentacion = 'Caja con frasco 120 mL y vaso dosificador',
    concentracion = '7.5 / 100 / 1 mg / 5 mL',
    principio_activo = 'Dextrometorfano / Guaifenesina / Clorfenamina',
    forma_farmaceutica = 'Jarabe',
    requiere_receta = false
  where id = v_pid;

  raise notice 'Ridin Adulto id % lote %', v_pid, v_lid;
end $$;

-- 5) Dolo-Neurobion C/20: ya está, mal OCR ("Bolo Eurobion") e inactivo
update public.productos set
  nombre = 'Dolo-Neurobion tabletas C/20',
  marca = 'Dolo-Neurobión',
  activo = true,
  tipo = 'marca',
  categoria = 'Analgésico',
  presentacion = 'Caja con 20 tabletas',
  concentracion = '50 / 50 / 50 / 0.25 mg',
  principio_activo = 'Diclofenaco / Complejo B',
  forma_farmaceutica = 'Tabletas',
  requiere_receta = true,
  descripcion = coalesce(descripcion, '')
    || ' · corregido 2026-08-19: OCR Bolo Eurobion → Dolo-Neurobion C/20 EAN 7501298223704 Merck'
where sku = 'FC-98223704'
  and codigo_barras = '7501298223704';

commit;

select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.activo,
  p.precio,
  p.costo,
  p.stock,
  p.requiere_receta,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.sku in ('EQ-MAV098', 'EQ-NOV005', 'EQ-EXA040', 'EQ-SON112', 'FC-98223704')
   or p.codigo_barras in (
     '7502009740459', '75006433', '7505101007405', '7502001163072', '7501298223704'
   )
order by p.sku;
