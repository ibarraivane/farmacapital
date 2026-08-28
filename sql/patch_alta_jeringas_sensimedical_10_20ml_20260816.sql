-- Jeringas SensiMedical por pieza que no vinieron en los tickets/CSV.
-- Distintas de las cajas C/100 de insulina (0.3 y 0.5 mL) que si estan.
--
--   1. 10 mL 22G x 32 mm   EAN 7506022300690   lote 2504864301   cad 2030-04-10
--   2. 20 mL 21G x 32 mm   EAN 7506022314741   lote 2512962201   cad 2030-12-13
--
-- Precio y costo pendientes (0.01). INSERT ONLY.
-- Ejecutar en Supabase SQL Editor (copiar desde el archivo, no del chat).

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_lid bigint;
  v_existe boolean;
begin
  for r in
    select * from (values
      (
        '7506022300690'::text,
        'FC-22300690'::text,
        'Jeringa SensiMedical 10 mL 22G x 32 mm'::text,
        '1 pieza 10 mL 22G x 32 mm'::text,
        'Jeringa de plastico esteril SensiMedical 10 mL 22G x 32 mm · 1 pieza · EAN 7506022300690 · lote 2504864301 · Reg. 0681C2017 SSA'::text,
        '%jeringa%10 ml%22%'::text,
        '2504864301'::text,
        '2030-04-10'::date
      ),
      (
        '7506022314741',
        'FC-22314741',
        'Jeringa SensiMedical 20 mL 21G x 32 mm',
        '1 pieza 20 mL 21G x 32 mm',
        'Jeringa de plastico esteril SensiMedical 20 mL 21G x 32 mm · 1 pieza · EAN 7506022314741 · lote 2512962201 · Reg. 0881C2017 SSA',
        '%jeringa%20 ml%21%',
        '2512962201',
        '2030-12-13'::date
      )
    ) as t(ean, sku, nombre, presentacion, descripcion, patron_nombre, numero_lote, caducidad)
  loop
    select exists (
      select 1 from public.productos p
      where p.codigo_barras = r.ean
         or p.sku = r.sku
         or p.nombre ilike r.patron_nombre
    ) into v_existe;

    if v_existe then
      raise notice '% ya existe; no se inserta (INSERT ONLY).', r.nombre;
      continue;
    end if;

    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', r.nombre,
        'sku', r.sku,
        'codigo_barras', r.ean,
        'categoria', 'Dispositivo médico',
        'tipo', 'marca',
        'descripcion', r.descripcion,
        'costo', 0.01,
        'precio', 0.01,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false
      ),
      1,
      r.numero_lote,
      r.caducidad,
      0.01,
      null::bigint
    ) f;

    update public.productos set
      marca = 'SensiMedical',
      presentacion = r.presentacion,
      forma_farmaceutica = 'Jeringa',
      subcategoria = 'Jeringa hipodermica'
    where id = v_pid;

    raise notice '% creada id % lote % — falta costo/precio y foto', r.nombre, v_pid, v_lid;
  end loop;
end $$;

commit;

select
  p.id, p.sku, p.nombre, p.codigo_barras, p.categoria, p.precio,
  l.numero_lote, l.fecha_caducidad
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in ('7506022300690', '7506022314741')
   or p.sku in ('FC-22300690', 'FC-22314741');
