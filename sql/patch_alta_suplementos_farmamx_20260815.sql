-- ============================================================================
-- Alta de 5 productos que faltaban en inventario (compra farma|mx, 15-ago-2026)
--
--   1. Exzon 90 tabletas masticables 490 mg uva   EAN 7503020089077
--   2. Gelcavit Platinum 30 capsulas 1.39 g       EAN 7501130713851
--   3. Gelcavit Colors 30 capsulas 0.62 g         EAN 7501130713547
--   4. Gelcavit Mulier 30 capsulas 1.04 g         SIN EAN todavia
--   5. Sol Sun protector solar facial            EAN 7502009749063
--
-- Los importes que se capturaron son PRECIO DE VENTA. El costo de compra no se
-- conoce, asi que entra como 0.01 y hay un bloque al final para capturarlo.
-- Mientras el costo siga en 0.01 el margen de estos 5 sale mal en los reportes.
--
-- Las caducidades venian como MM/AA en la caja; se guardan al ultimo dia del mes.
-- Cada uno entra con 1 pieza y el lote queda ligado al proveedor 'Farma MX'.
--
-- INSERT ONLY: si el producto ya existe (por EAN, SKU o nombre) lo salta y avisa.
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
        '7503020089077'::text,
        'FC-20089077'::text,
        'Exzon tabletas masticables 490 mg C/90 sabor uva'::text,
        'Biomiral'::text,
        'Caja 90 tabletas masticables de 490 mg'::text,
        'Fibra soluble de maiz, bioflavonoides citricos, Bacillus coagulans, vitaminas A, C y D3'::text,
        'Tableta masticable'::text,
        'Fibra y probioticos'::text,
        'Exzon Biomiral 90 tabletas masticables 490 mg sabor uva · suplemento alimenticio · EAN 7503020089077'::text,
        '%exzon%'::text,
        77.28::numeric,
        '2028-04-30'::date,
        1::integer,
        'Suplemento'::text,
        null::text
      ),
      (
        '7501130713851',
        'FC-30713851',
        'Gelcavit Platinum capsulas 1.39 g C/30',
        'Gelcavit',
        'Caja 30 capsulas de 1.39 g',
        'Coenzima Q-10, aceite de primula, aceite de germen de trigo, vitaminas y minerales',
        'Capsula',
        'Multivitaminico',
        'Gelcavit Platinum Pharmacaps 30 capsulas de 1.39 g · suplemento alimenticio · EAN 7501130713851',
        '%gelcavit%platinum%',
        71.49,
        '2028-02-29'::date,
        1,
        'Vitaminas',
        null
      ),
      (
        '7501130713547',
        'FC-30713547',
        'Gelcavit Colors capsulas 0.62 g C/30',
        'Gelcavit',
        'Caja 30 capsulas de 0.62 g',
        'Aceite de germen de trigo, vitaminas y minerales',
        'Capsula',
        'Multivitaminico',
        'Gelcavit Colors Pharmacaps 30 capsulas de 0.62 g · suplemento alimenticio · EAN 7501130713547',
        '%gelcavit%colors%',
        42.43,
        '2028-02-29'::date,
        1,
        'Vitaminas',
        null
      ),
      (
        -- Falta escanear el codigo de barras; el SKU es provisional.
        null,
        'FC-MULIER30',
        'Gelcavit Mulier capsulas 1.04 g C/30',
        'Gelcavit',
        'Caja 30 capsulas de 1.04 g',
        'Isoflavonas de soya, lecitina de soya, vitaminas y minerales',
        'Capsula',
        'Multivitaminico femenino',
        'Gelcavit Mulier Pharmacaps 30 capsulas de 1.04 g · suplemento alimenticio · falta EAN',
        '%gelcavit%mulier%',
        78.55,
        '2028-04-30'::date,
        1,
        'Vitaminas',
        null
      ),
      (
        '7502009749063',
        'FC-09749063',
        'Sol Sun protector solar facial crema hidratacion profunda',
        'Sol Sun',
        'Crema facial en tubo',
        'Acido hialuronico y aloe vera',
        'Crema',
        'Protector solar',
        'Sol Sun Cara Face protector solar facial con acido hialuronico y aloe vera · EAN 7502009749063 · falta FPS y gramaje del empaque',
        '%sol sun%',
        48.45,
        '2029-04-30'::date,
        1,
        'Cuidado personal',
        '07026067'
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
      null::bigint,
      'Farma MX'
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
-- Verificacion: deben salir las 5 filas con su lote y caducidad
-- ---------------------------------------------------------------------------
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
where p.sku in ('FC-20089077', 'FC-30713851', 'FC-30713547', 'FC-MULIER30', 'FC-09749063')
order by p.nombre;

-- ---------------------------------------------------------------------------
-- PENDIENTE 1 · costo real de compra
-- Pon el costo del ticket farma|mx en lugar de cada null y corre este bloque.
-- Los que dejes en null se quedan igual, no estorban.
-- ---------------------------------------------------------------------------
-- begin;
--
-- with costos(sku, costo) as (
--   values
--     ('FC-20089077', null::numeric),  -- Exzon 90 tabs
--     ('FC-30713851', null::numeric),  -- Gelcavit Platinum
--     ('FC-30713547', null::numeric),  -- Gelcavit Colors
--     ('FC-MULIER30', null::numeric),  -- Gelcavit Mulier
--     ('FC-09749063', null::numeric)   -- Sol Sun protector solar facial
-- )
-- update public.productos p
-- set costo = c.costo
-- from costos c
-- where p.sku = c.sku
--   and c.costo is not null
--   and c.costo > 0;
--
-- update public.lotes l
-- set costo_unitario = p.costo
-- from public.productos p
-- where l.producto_id = p.id
--   and p.sku in ('FC-20089077', 'FC-30713851', 'FC-30713547', 'FC-MULIER30', 'FC-09749063')
--   and coalesce(p.costo, 0) > 0.01;
--
-- commit;

-- ---------------------------------------------------------------------------
-- PENDIENTE 2 · codigo de barras del Gelcavit Mulier
-- Escanea la caja, pon el EAN y corre este bloque. El SKU se realinea solo
-- a los ultimos 8 digitos, que es la convencion del catalogo.
-- ---------------------------------------------------------------------------
-- begin;
--
-- update public.productos
-- set codigo_barras = '<EAN_MULIER>',
--     sku = 'FC-' || right('<EAN_MULIER>', 8),
--     descripcion = 'Gelcavit Mulier Pharmacaps 30 capsulas de 1.04 g · suplemento alimenticio · EAN <EAN_MULIER>'
-- where sku = 'FC-MULIER30';
--
-- commit;

-- ---------------------------------------------------------------------------
-- PENDIENTE 3 · EAN 7501130709830 sin producto asignado
-- Es la caja blanca de la primera foto (precio 71.49, caducidad 02/28). No se
-- dio de alta porque no se ve de que Gelcavit es; el candidato es el HO naranja.
-- Confirma el nombre y contenido y se agrega con el mismo formato de arriba.
-- ---------------------------------------------------------------------------
