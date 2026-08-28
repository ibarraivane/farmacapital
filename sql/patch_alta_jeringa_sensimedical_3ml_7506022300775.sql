-- Jeringa de plastico Sensi Medical 3 mL 22G x 32 mm · 1 pieza
-- EAN: 7506022300775 · Lote: 2504863707 · Caducidad 05-ABR-2030
-- Distinta de la jeringa insulina 1 mL (7506022300881) y de las cajas C/100.
-- Precio de venta y costo pendientes (entran como 0.01).
-- INSERT ONLY: no modifica filas existentes.
-- Ejecutar en Supabase SQL Editor (copiar desde el archivo, no del chat).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in ('7506022300775', '75060223007750')
       or p.sku = 'FC-22300775'
       or p.nombre ilike '%jeringa%3 ml%22%'
  ) then
    raise notice 'Jeringa Sensi Medical 3 mL 22G ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Jeringa Sensi Medical 3 mL 22G x 32 mm',
      'sku', 'FC-22300775',
      'codigo_barras', '7506022300775',
      'categoria', 'Dispositivo médico',
      'tipo', 'marca',
      'descripcion', 'Jeringa de plastico esteril Sensi Medical 3 mL 22G x 32 mm · 1 pieza · hipodermica desechable · EAN 7506022300775 · lote 2504863707 · Reg. 0681C2017 SSA',
      'costo', 0.01,
      'precio', 0.01,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    '2504863707',
    '2030-04-05'::date,
    0.01,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Sensi Medical',
    presentacion = '1 pieza 3 mL 22G x 32 mm',
    forma_farmaceutica = 'Jeringa',
    subcategoria = 'Jeringa hipodermica'
  where id = v_pid;

  raise notice 'Jeringa 3 mL creada id % lote % — falta costo/precio y foto en Inventario', v_pid, v_lid;
end $$;

commit;

select
  p.id,
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
where p.codigo_barras = '7506022300775'
   or p.sku = 'FC-22300775';

-- Cuando tengas costo y precio del ticket:
-- begin;
-- update public.productos set costo = <COSTO>, precio = <PRECIO> where sku = 'FC-22300775';
-- update public.lotes l set costo_unitario = <COSTO>
--   from public.productos p where l.producto_id = p.id and p.sku = 'FC-22300775';
-- commit;
