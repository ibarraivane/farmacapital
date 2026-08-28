-- Dolo-Neurobion tabletas C/20 · EAN 7501298223704
-- Ticket Surtidor 112558 · 1 pza · lista 561 · desc 52% · costo 269.28
-- Caducidad en caja: noviembre 2027 (el ticket de Surtidor no trae lote).
--
-- Historia: el OCR leyó "BOLO EUROBION TAB C/20" y se creó FC-98223704
-- con ese EAN. Esa ficha ya no existe. El EAN tampoco está en el inyectable
-- FC-98217659 (C/3 jeringas, 7501298217659) ni en el Forte C/1 (7501298217635).
-- sql/patch_altas_lista_faltantes_20260816.sql tenía ST-8223704 pero no se corrió.
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
    where p.codigo_barras = '7501298223704'
       or p.sku in ('FC-98223704', 'ST-8223704')
       or (
         p.nombre ilike '%dolo%neurobion%'
         and p.nombre ilike '%c/20%'
         and p.nombre not ilike '%inyect%'
         and p.nombre not ilike '%jga%'
       )
  ) then
    raise notice 'Dolo-Neurobion tabletas C/20 ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Dolo-Neurobion tabletas C/20',
      'sku', 'FC-98223704',
      'codigo_barras', '7501298223704',
      'categoria', 'Analgésico',
      'tipo', 'marca',
      'descripcion', 'Ticket Surtidor 112558 · DOLO NEUROBION TAB C/20 · EAN 7501298223704 · OCR lo había leído como Bolo Eurobion',
      'costo', 269.28,
      'precio', 431,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    null,
    '2027-11-30'::date,
    269.28,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Dolo-Neurobion',
    presentacion = 'Caja con 20 tabletas',
    principio_activo = 'Diclofenaco / Complejo B',
    forma_farmaceutica = 'Tabletas',
    requiere_receta = false
  where id = v_pid;

  raise notice 'Dolo-Neurobion tabletas C/20 creado id % lote %', v_pid, v_lid;
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
where p.codigo_barras = '7501298223704'
   or p.sku in ('FC-98223704', 'ST-8223704');
