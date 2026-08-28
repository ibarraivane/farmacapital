-- Ciprofloxacino solución oftálmica 3 mg/mL AMSA · frasco gotero 5 mL
-- EAN: 7501349027817
-- Ticket Equilibrio 440393 · AMS407 · lote G26M00B · cad 2028-03-01 · costo 24.28
--
-- La carga del ticket NO lo creó: había varios "Ciprofloxacino…" (tabletas
-- 250 mg y G.I. 500 mg) y el script dejó la línea pendiente a mano.
-- EQ-SON214 (Dexametasona/Ciprofloxacino Sol, cad también mar-2028) es OTRO
-- producto (combo SON'S, EAN 7502001164338).
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
    where p.codigo_barras = '7501349027817'
       or p.sku in ('EQ-AMS407', 'FC-49027817')
       or (
         p.nombre ilike '%ciprofloxacino%'
         and p.nombre ilike '%3 mg%'
         and (p.nombre ilike '%5 ml%' or p.nombre ilike '%gotero%')
       )
  ) then
    raise notice 'Ciprofloxacino oftálmico 3 mg/mL ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Ciprofloxacino solución oftálmica 3 mg/mL AMSA',
      'sku', 'EQ-AMS407',
      'codigo_barras', '7501349027817',
      'categoria', 'Antibiótico',
      'tipo', 'generico',
      'descripcion', 'Ticket Equilibrio 440393 · AMS407 · CIPROFLOXACINO 1 GOT 3MG/5 ML · EAN 7501349027817',
      'costo', 24.28,
      'precio', 39,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', true
    ),
    1,
    'G26M00B',
    '2028-03-01'::date,
    24.28,
    null::bigint
  ) f;

  update public.productos set
    marca = 'AMSA',
    presentacion = 'Frasco gotero 5 mL',
    concentracion = '3 mg/mL',
    principio_activo = 'Ciprofloxacino',
    forma_farmaceutica = 'Solución oftálmica',
    requiere_receta = true
  where id = v_pid;

  raise notice 'Ciprofloxacino oftálmico creado id % lote %', v_pid, v_lid;
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
  p.requiere_receta,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras = '7501349027817'
   or p.sku = 'EQ-AMS407';
