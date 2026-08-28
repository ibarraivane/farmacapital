-- Veridex Ivermectina 6 mg C/4 tab · Maver
-- EAN empaque: 7502009747366 (7 502009 747366)
-- Costo ticket: 75.46 · Caducidad: 2028-02-28 · Lote ticket: 261181
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
    where p.codigo_barras in ('7502009747366', '7502209747366', '75020027471')
       or p.sku in ('FC-09747366', 'FC-9747366')
       or p.nombre ilike '%veridex%'
  ) then
    raise notice 'Veridex ya existe en catalogo; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Veridex ivermectina 6 mg C/4',
      'sku', 'FC-09747366',
      'codigo_barras', '7502009747366',
      'categoria', 'Medicamentos',
      'tipo', 'marca',
      'descripcion', 'Veridex Ivermectina 6 mg 4 tab Maver EAN 7502009747366',
      'costo', 75.46,
      'precio', 101.88,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', true
    ),
    1,
    '261181',
    '2028-02-28'::date,
    75.46,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Veridex',
    presentacion = 'C/4 tabletas 6 mg',
    principio_activo = 'Ivermectina 6 mg',
    forma_farmaceutica = 'Tabletas',
    subcategoria = 'Antiparasitario',
    requiere_receta = true
  where id = v_pid;

  raise notice 'Veridex creado id % lote %', v_pid, v_lid;
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
where p.codigo_barras in ('7502009747366', '7502209747366')
   or p.nombre ilike '%veridex%'
order by p.id desc
limit 3;
