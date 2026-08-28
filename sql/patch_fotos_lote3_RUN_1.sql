-- Fotos lote 3 medicamentos · 2026-08-15
-- Abrir desde DISCO · Cmd+A · pegar completo en Supabase
-- NO copiar desde chat (trunca → error 42601)
-- Sin columna proveedor · solo DO $$

BEGIN;


DO $$
DECLARE v_pid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501070612368','75010706123680') OR sku = 'FC-70612368' LIMIT 1;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET
      nombre = 'Treda antidiarreico C/20', marca = 'Treda',
      principio_activo = 'Neomicina + Caolin + Pectina',
      presentacion = 'C/20', forma_farmaceutica = 'Capsulas',
      subcategoria = 'Antidiarreico', costo = 139.84, precio = 223.74,
      descripcion = 'Treda Sanfer · ticket FL-080826 $139.84'
    WHERE id = v_pid;
    UPDATE public.lotes SET costo_unitario = 139.84 WHERE producto_id = v_pid;
  END IF;
END $$;

DO $$
DECLARE v_pid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras = '7502227875568' OR sku IN ('FC-B3B8F9BB','FC-27875568') LIMIT 1;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET
      sku = 'FC-27875568', codigo_barras = '7502227875568',
      nombre = 'Desrotan fexofenadina 180 mg C/10', marca = 'Raam',
      principio_activo = 'Fexofenadina 180 mg', presentacion = 'C/10',
      forma_farmaceutica = 'Tabletas', subcategoria = 'Antialergico', activo = true
    WHERE id = v_pid
      AND NOT EXISTS (SELECT 1 FROM public.productos o WHERE o.sku = 'FC-27875568' AND o.id <> v_pid);
  END IF;
END $$;

DO $$
DECLARE v_pid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras = '7503000422511' OR sku IN ('FC-DEAF33B0','FC-00422511') LIMIT 1;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET
      sku = 'FC-00422511', codigo_barras = '7503000422511',
      nombre = 'Bactiver sulfametoxazol/trimetoprima susp. 120 mL', marca = 'Bactiver',
      principio_activo = 'Sulfametoxazol + Trimetoprima', presentacion = 'Frasco 120 mL',
      forma_farmaceutica = 'Suspension', subcategoria = 'Antibiotico', activo = true
    WHERE id = v_pid
      AND NOT EXISTS (SELECT 1 FROM public.productos o WHERE o.sku = 'FC-00422511' AND o.id <> v_pid);
    UPDATE public.lotes SET
      numero_lote = coalesce(nullif(btrim(numero_lote), ''), '262631'),
      fecha_caducidad = coalesce(fecha_caducidad, '2028-05-31'::date)
    WHERE producto_id = v_pid;
  END IF;
END $$;

DO $$
DECLARE v_pid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos WHERE sku = 'FC-1FFBB505' LIMIT 1;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET
      nombre = 'Supratex levodropropizina jarabe 120 mL', marca = 'Supratex',
      principio_activo = 'Levodropropizina 600 mg/100 mL',
      presentacion = 'Frasco 120 mL + vaso', forma_farmaceutica = 'Jarabe',
      subcategoria = 'Antitusivo',
      descripcion = 'MAVI · EAN pendiente · no usar PMP caja'
    WHERE id = v_pid;
  END IF;
END $$;

DO $$
DECLARE v_pid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos WHERE sku = 'FC-52D2A43A' LIMIT 1;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET
      nombre = 'Zukedib glimepirida 2 mg C/30', marca = 'Loeffler',
      principio_activo = 'Glimepirida 2 mg', presentacion = 'C/30',
      forma_farmaceutica = 'Tabletas', subcategoria = 'Antidiabetico',
      descripcion = 'EAN pendiente otra cara del empaque'
    WHERE id = v_pid;
  END IF;
END $$;


-- Topron nifuroxazida 400 mg C/16 · FC-88579615
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501088579615', '75010885796150') OR sku IN ('FC-88579615', 'FC-08579615') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Topron nifuroxazida 400 mg C/16', 'sku', 'FC-88579615', 'codigo_barras', '7501088579615',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Chinoin ticket FL-080826',
        'costo', 153.47, 'precio', 251.4, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, '8FB077', '2028-02-28'::date, 153.47, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-88579615', codigo_barras = '7501088579615', nombre = 'Topron nifuroxazida 400 mg C/16',
      marca = 'Topron', presentacion = 'C/16 capsulas 400 mg', forma_farmaceutica = 'Capsulas', subcategoria = 'Antidiarreico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Nifuroxazida 400 mg', costo = 153.47, precio = 251.4, activo = true, descripcion = 'Chinoin ticket FL-080826'
    WHERE id = v_pid;
    UPDATE public.lotes SET numero_lote = coalesce(nullif(btrim(numero_lote), ''), '8FB077'), fecha_caducidad = coalesce(fecha_caducidad, '2028-02-28'::date) WHERE producto_id = v_pid;
  END IF;
END $$;

-- Treda antidiarreico sobres Maver · FC-09745522
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502009745522', '75020097455220') OR sku IN ('FC-09745522') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Treda antidiarreico sobres Maver', 'sku', 'FC-09745522', 'codigo_barras', '7502009745522',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Reg. 194M2014 distinto Treda Sanfer · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-09745522', codigo_barras = '7502009745522', nombre = 'Treda antidiarreico sobres Maver',
      marca = 'Treda', presentacion = 'Sobres', forma_farmaceutica = 'Polvo', subcategoria = 'Antidiarreico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Neomicina + Caolin + Pectina',  activo = true, descripcion = 'Reg. 194M2014 distinto Treda Sanfer · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Treda infantil suspension Maver 120 mL · FC-09745027
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502009745027', '75020097450270') OR sku IN ('FC-09745027') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Treda infantil suspension Maver 120 mL', 'sku', 'FC-09745027', 'codigo_barras', '7502009745027',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Reg. 194M2014 · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, '262654', '2028-04-30'::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-09745027', codigo_barras = '7502009745027', nombre = 'Treda infantil suspension Maver 120 mL',
      marca = 'Treda', presentacion = 'Frasco 120 mL', forma_farmaceutica = 'Suspension', subcategoria = 'Antidiarreico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Neomicina + Caolin + Pectina',  activo = true, descripcion = 'Reg. 194M2014 · costo pendiente ticket'
    WHERE id = v_pid;
    UPDATE public.lotes SET numero_lote = coalesce(nullif(btrim(numero_lote), ''), '262654'), fecha_caducidad = coalesce(fecha_caducidad, '2028-04-30'::date) WHERE producto_id = v_pid;
  END IF;
END $$;

-- Kao-Paver infantil suspension Maver · FC-09745560
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502009745560', '75020097455600') OR sku IN ('FC-09745560') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Kao-Paver infantil suspension Maver', 'sku', 'FC-09745560', 'codigo_barras', '7502009745560',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Reg. 376M2014 · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, '255469', '2027-10-31'::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-09745560', codigo_barras = '7502009745560', nombre = 'Kao-Paver infantil suspension Maver',
      marca = 'Kao-Paver', presentacion = 'Frasco susp.', forma_farmaceutica = 'Suspension', subcategoria = 'Antidiarreico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Caolin + Pectina + Furazolidona',  activo = true, descripcion = 'Reg. 376M2014 · costo pendiente ticket'
    WHERE id = v_pid;
    UPDATE public.lotes SET numero_lote = coalesce(nullif(btrim(numero_lote), ''), '255469'), fecha_caducidad = coalesce(fecha_caducidad, '2027-10-31'::date) WHERE producto_id = v_pid;
  END IF;
END $$;

-- Oppelver lactulosa jarabe 125 mL · FC-09745584
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502009745584', '75020097455840') OR sku IN ('FC-09745584') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Oppelver lactulosa jarabe 125 mL', 'sku', 'FC-09745584', 'codigo_barras', '7502009745584',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-09745584', codigo_barras = '7502009745584', nombre = 'Oppelver lactulosa jarabe 125 mL',
      marca = 'Oppelver', presentacion = 'Frasco 125 mL + vaso', forma_farmaceutica = 'Jarabe', subcategoria = 'Laxante',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Lactulosa 10 g/15 mL',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Producto Maver Reg. 202M2001 · FC-09740435
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502009740435', '75020097404350') OR sku IN ('FC-09740435') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Producto Maver Reg. 202M2001', 'sku', 'FC-09740435', 'codigo_barras', '7502009740435',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Identificar nombre · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      5, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-09740435', codigo_barras = '7502009740435', nombre = 'Producto Maver Reg. 202M2001',
      marca = 'Maver', presentacion = 'Caja', forma_farmaceutica = 'Tabletas', subcategoria = 'Medicamentos',
      categoria = 'Medicamentos', tipo = 'marca',   activo = true, descripcion = 'Identificar nombre · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- K-PEC suspension infantil Novag · FC-75717914
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501075717914', '75010757179140') OR sku IN ('FC-75717914') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'K-PEC suspension infantil Novag', 'sku', 'FC-75717914', 'codigo_barras', '7501075717914',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Novag Reg. 352M2006 · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, '460056', '2028-03-31'::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-75717914', codigo_barras = '7501075717914', nombre = 'K-PEC suspension infantil Novag',
      marca = 'K-PEC', presentacion = 'Frasco ~100 mL', forma_farmaceutica = 'Suspension', subcategoria = 'Antidiarreico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Neomicina + Caolin + Pectina',  activo = true, descripcion = 'Novag Reg. 352M2006 · costo pendiente ticket'
    WHERE id = v_pid;
    UPDATE public.lotes SET numero_lote = coalesce(nullif(btrim(numero_lote), ''), '460056'), fecha_caducidad = coalesce(fecha_caducidad, '2028-03-31'::date) WHERE producto_id = v_pid;
  END IF;
END $$;

-- Metamizol sodico solucion Novag Infancia · FC-75713770
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501075713770', '75010757137700') OR sku IN ('FC-75713770') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Metamizol sodico solucion Novag Infancia', 'sku', 'FC-75713770', 'codigo_barras', '7501075713770',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Reg. 149M92 · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, '500546', '2030-01-31'::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-75713770', codigo_barras = '7501075713770', nombre = 'Metamizol sodico solucion Novag Infancia',
      marca = 'Novag', presentacion = 'Frasco', forma_farmaceutica = 'Solucion oral', subcategoria = 'Analgesico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Metamizol sodico',  activo = true, descripcion = 'Reg. 149M92 · costo pendiente ticket'
    WHERE id = v_pid;
    UPDATE public.lotes SET numero_lote = coalesce(nullif(btrim(numero_lote), ''), '500546'), fecha_caducidad = coalesce(fecha_caducidad, '2030-01-31'::date) WHERE producto_id = v_pid;
  END IF;
END $$;

-- Novagon psyllium polvo 400 g · FC-75718676
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501075718676', '75010757186760') OR sku IN ('FC-75718676') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Novagon psyllium polvo 400 g', 'sku', 'FC-75718676', 'codigo_barras', '7501075718676',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Novag · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, '491866', '2030-04-30'::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-75718676', codigo_barras = '7501075718676', nombre = 'Novagon psyllium polvo 400 g',
      marca = 'Novagon', presentacion = 'Frasco 400 g', forma_farmaceutica = 'Polvo', subcategoria = 'Laxante',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Plantago psyllium',  activo = true, descripcion = 'Novag · costo pendiente ticket'
    WHERE id = v_pid;
    UPDATE public.lotes SET numero_lote = coalesce(nullif(btrim(numero_lote), ''), '491866'), fecha_caducidad = coalesce(fecha_caducidad, '2030-04-30'::date) WHERE producto_id = v_pid;
  END IF;
END $$;

-- Novakosid senosidos A-B 8.6 mg C/20 · FC-75723137
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501075723137', '75010757231370') OR sku IN ('FC-75723137') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Novakosid senosidos A-B 8.6 mg C/20', 'sku', 'FC-75723137', 'codigo_barras', '7501075723137',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-75723137', codigo_barras = '7501075723137', nombre = 'Novakosid senosidos A-B 8.6 mg C/20',
      marca = 'Novakosid', presentacion = 'C/20', forma_farmaceutica = 'Tabletas', subcategoria = 'Laxante',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Senosidos A-B 8.6 mg',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Producto Novag Reg. 410M2016 · FC-24901059
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7506624901059', '75066249010590') OR sku IN ('FC-24901059') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Producto Novag Reg. 410M2016', 'sku', 'FC-24901059', 'codigo_barras', '7506624901059',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-24901059', codigo_barras = '7506624901059', nombre = 'Producto Novag Reg. 410M2016',
      marca = 'Novag', presentacion = 'Caja', forma_farmaceutica = 'Tabletas', subcategoria = 'Medicamentos',
      categoria = 'Medicamentos', tipo = 'marca',   activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Bactiver infantil tabletas Maver · FC-09747236
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502009747236', '75020097472360') OR sku IN ('FC-09747236') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Bactiver infantil tabletas Maver', 'sku', 'FC-09747236', 'codigo_barras', '7502009747236',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-09747236', codigo_barras = '7502009747236', nombre = 'Bactiver infantil tabletas Maver',
      marca = 'Bactiver', presentacion = 'Caja tabletas', forma_farmaceutica = 'Tabletas', subcategoria = 'Antibiotico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Sulfametoxazol + Trimetoprima',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Producto PiSA Reg. 423M2005 · FC-49022485
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501349022485', '75013490224850') OR sku IN ('FC-49022485') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Producto PiSA Reg. 423M2005', 'sku', 'FC-49022485', 'codigo_barras', '7501349022485',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-49022485', codigo_barras = '7501349022485', nombre = 'Producto PiSA Reg. 423M2005',
      marca = 'PiSA', presentacion = 'Caja', forma_farmaceutica = 'Tabletas', subcategoria = 'Medicamentos',
      categoria = 'Medicamentos', tipo = 'marca',   activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;
COMMIT;
