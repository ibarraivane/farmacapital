-- Laritol loratadina 10 mg C/10 · Maver
-- EAN de la caja (fotos): 7502009740435
-- Ticket Equilibrio 440393 · MAV039 · lote 257226 · cad 2027-12-01
-- 5 cajas · costo 7.01 · total 35.05
--
-- Por qué no estaba:
--   1. La carga del ticket saltó MAV039: ya había otros "Laritol…"
--      (EX jarabe, EX tabs, D tabs, solución 60 mL) y no adivinó.
--   2. El lote de fotos ordenadas3 dejó el EAN como "no se inventa".
--   3. patch_altas_fotos_faltantes (EQ-MAV039) nunca se ejecutó.
--   4. El otro código de las mismas fotos, 7501573909859, SÍ está:
--      es Sarox omeprazol 20 mg (FC-73909859, cajas azules Biomep).
--      Escanear esa pila no encuentra Laritol.
--
-- INSERT ONLY. Ejecutar en Supabase SQL Editor (archivo completo).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras = '7502009740435'
       or p.sku in ('EQ-MAV039', 'FC-09740435')
       or (
         p.nombre ilike '%laritol%'
         and p.nombre not ilike '% ex%'
         and p.nombre not ilike '%laritol d%'
         and p.nombre not ilike '%soluci%'
         and p.nombre not ilike '%jarabe%'
         and (
           p.nombre ilike '%10 mg%'
           or p.nombre ilike '%10 tab%'
         )
       )
  ) then
    raise notice 'Laritol 10 mg C/10 ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Laritol loratadina 10 mg C/10',
      'sku', 'EQ-MAV039',
      'codigo_barras', '7502009740435',
      'categoria', 'Alergia',
      'tipo', 'marca',
      'descripcion', 'Ticket Equilibrio 440393 · MAV039 · LARITOL 10 TAB 10 MG · EAN 7502009740435',
      'costo', 7.01,
      'precio', 12,
      'stock_minimo', 2,
      'activo', true,
      'requiere_receta', false
    ),
    5,
    '257226',
    '2027-12-01'::date,
    7.01,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Maver',
    presentacion = 'Caja con 10 tabletas',
    concentracion = '10 mg',
    principio_activo = 'Loratadina',
    forma_farmaceutica = 'Tabletas',
    requiere_receta = false
  where id = v_pid;

  raise notice 'Laritol 10 mg C/10 creado id % lote %', v_pid, v_lid;
end $$;

commit;

select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.categoria,
  p.costo,
  p.precio,
  p.stock,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in ('7502009740435', '7501573909859')
   or p.sku in ('EQ-MAV039', 'FC-09740435', 'FC-73909859')
order by p.sku;
