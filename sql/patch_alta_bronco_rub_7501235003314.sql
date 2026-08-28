-- Unguento Bronco Rub 40 g · medicamento herbolario
-- EAN Mexico: 7501235003314 (7 501235 003314)
-- UPC respaldo en empaque: 714706800900
-- Costo ticket: 29.01 · Caducidad: 2028-03-29
-- INSERT ONLY: no modifica filas existentes.
-- Las fotos en Storage NO crean producto solo; hay que insertar la fila y luego pegar imagen_url en Inventario.
-- Ejecutar en Supabase SQL Editor (copiar desde archivo, no del chat).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_costo numeric := 29.01;
  v_precio numeric := 39.16;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in ('7501235003314', '714706800900', '7147068009000')
       or p.sku in ('FC-50003314', 'FC-08009000')
       or p.nombre ilike '%bronco rub%'
       or (p.nombre ilike '%unguento%' and p.nombre ilike '%bronco%' and p.nombre not ilike '%broncolin%')
  ) then
    raise notice 'Bronco Rub ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Unguento Bronco Rub 40 g',
      'sku', 'FC-50003314',
      'codigo_barras', '7501235003314',
      'categoria', 'Respiratorio',
      'tipo', 'marca',
      'descripcion', 'Bronco Rub unguento topico 40 g herbolario · EAN 7501235003314 · UPC 714706800900',
      'costo', v_costo,
      'precio', v_precio,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    null,
    '2028-03-29'::date,
    v_costo,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Bronco Rub',
    presentacion = 'Frasco 40 g',
    principio_activo = 'Herbolario topico',
    forma_farmaceutica = 'Unguento',
    subcategoria = 'Gripa / descongestionante topico'
  where id = v_pid;

  raise notice 'Bronco Rub creado id % lote % — sube foto en Inventario si aun no tiene imagen_url', v_pid, v_lid;
end $$;

commit;

select
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.costo,
  p.precio,
  p.stock,
  p.imagen_url,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in ('7501235003314', '714706800900')
   or p.nombre ilike '%bronco rub%'
order by p.id desc
limit 3;
