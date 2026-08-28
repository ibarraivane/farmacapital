-- ============================================================================
-- Alta de 5 insumos que faltaban (cintas, soluciones CS y jeringa insulina)
--
--   1. Cintapore microporosa piel 2.5 cm x 9.1 m   EAN 7506484500546
--   2. Cintapore microporosa blanca 1.25 cm x 5 m  EAN 7506484500515
--   3. Solucion CS PiSA 0.9% 500 mL                EAN 7501125100123
--   4. Solucion CS PiSA 0.9% 250 mL                EAN 7501125100116
--   5. Jeringa insulina SensiMedical 1 mL 27G       EAN 7506022300881
--
-- Distintos de lo que ya esta en catalogo:
--   Cintapore blanca 2.5 cm x 5 m   7506484500522
--   Cintapore blanca 2.5 cm x 9.1 m 7506484500607
--   Jeringa insulina 0.5 mL C/100   75060223273451
--   Jeringa insulina 0.3 mL C/100   75060223272151
--
-- Los precios que se leyeron en empaque son PRECIO MAXIMO AL PUBLICO.
-- Costo de compra desconocido: entra 0.01. Cintapore piel y la jeringa
-- no traian precio; tambien entran en 0.01 hasta capturarlo.
--
-- INSERT ONLY: si ya existe por EAN, SKU o nombre exacto de esa presentacion,
-- lo salta. No toca las Cintapore / jeringas que ya tienes.
-- Ejecutar en Supabase SQL Editor (copiar desde el archivo, no del chat).
-- ============================================================================

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
        '7506484500546'::text,
        'FC-84500546'::text,
        'Cintapore cinta microporosa piel 2.5 cm x 9.1 m'::text,
        'Cintapore'::text,
        'Rollo 2.5 cm x 9.1 m color piel'::text,
        null::text,
        'Cinta'::text,
        'Cinta microporosa'::text,
        'Cintapore CODIFARMA cinta microporosa color piel 2.5 cm x 9.1 m · 1 rollo · EAN 7506484500546 · Reg. 0737C2018 SSA'::text,
        '%cintapore%piel%9.1%'::text,
        0.01::numeric,
        null::date,
        1::integer,
        'Dispositivo médico'::text,
        null::text
      ),
      (
        '7506484500515',
        'FC-84500515',
        'Cintapore cinta microporosa blanca 1.25 cm x 5 m',
        'Cintapore',
        'Rollo 1.25 cm x 5 m blanca',
        null,
        'Cinta',
        'Cinta microporosa',
        'Cintapore CODIFARMA cinta microporosa blanca 1.25 cm x 5 m · 1 rollo · EAN 7506484500515 · PMP 17.68 · Reg. 0737C2018 SSA',
        '%cintapore%1.25%',
        17.68,
        '2030-01-25'::date,
        1,
        'Dispositivo médico',
        null
      ),
      (
        '7501125100123',
        'FC-25100123',
        'Solucion CS PiSA cloruro de sodio 0.9% 500 mL',
        'PiSA',
        'Frasco 500 mL sistema abierto',
        'Cloruro de sodio 0.9%',
        'Solucion inyectable',
        'Solucion parenteral',
        'Solucion CS PiSA cloruro de sodio 0.9% inyectable IV · frasco 500 mL · EAN 7501125100123 · lote P25T706 · PMP 73.78 · Reg. 82175 SSA IV',
        '%solucion cs%500%',
        73.78,
        '2027-10-31'::date,
        1,
        'Hidratación',
        'P25T706'
      ),
      (
        '7501125100116',
        'FC-25100116',
        'Solucion CS PiSA cloruro de sodio 0.9% 250 mL',
        'PiSA',
        'Frasco 250 mL sistema abierto',
        'Cloruro de sodio 0.9%',
        'Solucion inyectable',
        'Solucion parenteral',
        'Solucion CS PiSA cloruro de sodio 0.9% inyectable IV · frasco 250 mL · EAN 7501125100116 · lote P26F301 · PMP 38.43 · Reg. 82175 SSA IV',
        '%solucion cs%250%',
        38.43,
        '2028-02-29'::date,
        1,
        'Hidratación',
        'P26F301'
      ),
      (
        '7506022300881',
        'FC-22300881',
        'Jeringa insulina SensiMedical 1 mL 27G x 13 mm',
        'SensiMedical',
        '1 pieza 1 mL 27G x 13 mm',
        null,
        'Jeringa',
        'Jeringa insulina',
        'Jeringa esteril de insulina SensiMedical 1 mL 27G x 13 mm · 1 pieza · EAN 7506022300881 · lote 2401975603 · Reg. 1284C2017 SSA · distinta de las cajas C/100 de 0.3 y 0.5 mL',
        '%jeringa%insulina%1 ml%27%',
        0.01,
        '2029-01-18'::date,
        1,
        'Dispositivo médico',
        '2401975603'
      )
    ) as t(
      ean, sku, nombre, marca, presentacion, principio_activo,
      forma_farmaceutica, subcategoria, descripcion, patron_nombre,
      precio, caducidad, cantidad, categoria, numero_lote
    )
  loop
    select exists (
      select 1 from public.productos p
      where (r.ean is not null and p.codigo_barras = r.ean)
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
        'categoria', r.categoria,
        'tipo', 'marca',
        'descripcion', r.descripcion,
        'costo', 0.01,
        'precio', r.precio,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false
      ),
      r.cantidad,
      r.numero_lote,
      r.caducidad,
      0.01,
      null::bigint
    ) f;

    update public.productos set
      marca = r.marca,
      presentacion = r.presentacion,
      principio_activo = r.principio_activo,
      forma_farmaceutica = r.forma_farmaceutica,
      subcategoria = r.subcategoria
    where id = v_pid;

    raise notice '% creado id % lote % — falta costo real y foto en Inventario', r.nombre, v_pid, v_lid;
  end loop;
end $$;

commit;

-- ---------------------------------------------------------------------------
-- Verificacion
-- ---------------------------------------------------------------------------
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
where p.sku in ('FC-84500546', 'FC-84500515', 'FC-25100123', 'FC-25100116', 'FC-22300881')
   or p.codigo_barras in (
     '7506484500546', '7506484500515',
     '7501125100123', '7501125100116',
     '7506022300881'
   )
order by p.nombre;

-- ---------------------------------------------------------------------------
-- PENDIENTE · costo real (y precio de Cintapore piel / jeringa 1 mL)
-- Pon el costo del ticket en lugar de cada null y corre este bloque.
-- ---------------------------------------------------------------------------
-- begin;
--
-- with costos(sku, costo, precio) as (
--   values
--     ('FC-84500546', null::numeric, null::numeric),  -- Cintapore piel 2.5 x 9.1
--     ('FC-84500515', null::numeric, null::numeric),  -- Cintapore blanca 1.25 x 5
--     ('FC-25100123', null::numeric, null::numeric),  -- CS PiSA 500 mL
--     ('FC-25100116', null::numeric, null::numeric),  -- CS PiSA 250 mL
--     ('FC-22300881', null::numeric, null::numeric)   -- Jeringa insulina 1 mL
-- )
-- update public.productos p
-- set
--   costo  = coalesce(c.costo, p.costo),
--   precio = coalesce(c.precio, p.precio)
-- from costos c
-- where p.sku = c.sku
--   and (c.costo is not null or c.precio is not null);
--
-- update public.lotes l
-- set costo_unitario = p.costo
-- from public.productos p
-- where l.producto_id = p.id
--   and p.sku in ('FC-84500546', 'FC-84500515', 'FC-25100123', 'FC-25100116', 'FC-22300881')
--   and coalesce(p.costo, 0) > 0.01;
--
-- commit;
