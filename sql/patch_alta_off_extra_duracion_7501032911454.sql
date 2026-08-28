-- OFF! Extra Duracion repelente aerosol 170 g · SC Johnson
-- EAN empaque: 7501032911454 (7 501032 911454)
-- Costo ticket: 68.64 · Caducidad: 2028-07-27 · Lote empaque: CPE0222512042
-- INSERT ONLY: no modifica filas existentes.
-- Ejecutar en Supabase SQL Editor (copiar desde este archivo, no del chat).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in ('7501032911454', '75010329114540')
       or p.sku in ('FC-32911454', 'FC-1032911454')
       or p.nombre ilike '%off!%extra duracion%'
       or (p.nombre ilike '%off%' and p.nombre ilike '%repelente%' and p.nombre ilike '%170%')
  ) then
    raise notice 'OFF Extra Duracion ya existe en catalogo; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'OFF! Extra Duracion repelente aerosol 170 g',
      'sku', 'FC-32911454',
      'codigo_barras', '7501032911454',
      'categoria', 'Higiene',
      'tipo', 'marca',
      'descripcion', 'OFF! Extra Duracion DEET 25% aerosol 170 g SC Johnson EAN 7501032911454',
      'costo', 68.64,
      'precio', 92.66,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    'CPE0222512042',
    '2028-07-27'::date,
    68.64,
    null::bigint
  ) f;

  update public.productos set
    marca = 'OFF!',
    presentacion = 'Aerosol 170 g (202 mL)',
    principio_activo = 'DEET 25%',
    forma_farmaceutica = 'Aerosol',
    subcategoria = 'Repelente de insectos',
    requiere_receta = false
  where id = v_pid;

  raise notice 'OFF Extra Duracion creado id % lote %', v_pid, v_lid;
end $$;

commit;

select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.costo,
  p.precio,
  p.stock,
  p.requiere_receta,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras = '7501032911454'
   or p.nombre ilike '%off%extra duracion%'
order by p.id desc
limit 3;
