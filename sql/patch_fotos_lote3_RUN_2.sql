-- Fotos lote 3 medicamentos · 2026-08-15
-- Abrir desde DISCO · Cmd+A · pegar completo en Supabase
-- NO copiar desde chat (trunca → error 42601)
-- Sin columna proveedor · solo DO $$

BEGIN;

-- Lumboxen parche capsicum C/1 · FC-09749209
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502009749209', '75020097492090') OR sku IN ('FC-09749209') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Lumboxen parche capsicum C/1', 'sku', 'FC-09749209', 'codigo_barras', '7502009749209',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Maver import · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, 'L200624BC', '2028-12-31'::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-09749209', codigo_barras = '7502009749209', nombre = 'Lumboxen parche capsicum C/1',
      marca = 'Lumboxen', presentacion = 'Parche gel x1', forma_farmaceutica = 'Parche', subcategoria = 'Analgesico topico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Capsaicina + Alcanfor + Mentol + Salicilato de metilo',  activo = true, descripcion = 'Maver import · costo pendiente ticket'
    WHERE id = v_pid;
    UPDATE public.lotes SET numero_lote = coalesce(nullif(btrim(numero_lote), ''), 'L200624BC'), fecha_caducidad = coalesce(fecha_caducidad, '2028-12-31'::date) WHERE producto_id = v_pid;
  END IF;
END $$;

-- Velatuss levodropropizina jarabe 120 mL · FC-03388008
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502003388008', '75020033880080') OR sku IN ('FC-03388008') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Velatuss levodropropizina jarabe 120 mL', 'sku', 'FC-03388008', 'codigo_barras', '7502003388008',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-03388008', codigo_barras = '7502003388008', nombre = 'Velatuss levodropropizina jarabe 120 mL',
      marca = 'Velatuss', presentacion = 'Frasco 120 mL + vaso', forma_farmaceutica = 'Jarabe', subcategoria = 'Antitusivo',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Levodropropizina 600 mg',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Levocetirizina Mavi Reg. 086M2019 · FC-18754259
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('785118754259', '7851187542590') OR sku IN ('FC-18754259') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Levocetirizina Mavi Reg. 086M2019', 'sku', 'FC-18754259', 'codigo_barras', '785118754259',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-18754259', codigo_barras = '785118754259', nombre = 'Levocetirizina Mavi Reg. 086M2019',
      marca = 'Mavi', presentacion = 'Caja', forma_farmaceutica = 'Tabletas', subcategoria = 'Antialergico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Levocetirizina',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Biobend bencidamina solucion bucal 360 mL · FC-73906469
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501573906469', '75015739064690') OR sku IN ('FC-73906469') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Biobend bencidamina solucion bucal 360 mL', 'sku', 'FC-73906469', 'codigo_barras', '7501573906469',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-73906469', codigo_barras = '7501573906469', nombre = 'Biobend bencidamina solucion bucal 360 mL',
      marca = 'Biobend', presentacion = 'Frasco 360 mL', forma_farmaceutica = 'Solucion bucal', subcategoria = 'Antiseptico bucal',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Bencidamina 0.15 g/100 mL',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- ML-PRIM metocarbamol/ibuprofeno C/12 · FC-27427392
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502227427392', '75022274273920') OR sku IN ('FC-27427392') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'ML-PRIM metocarbamol/ibuprofeno C/12', 'sku', 'FC-27427392', 'codigo_barras', '7502227427392',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      3, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-27427392', codigo_barras = '7502227427392', nombre = 'ML-PRIM metocarbamol/ibuprofeno C/12',
      marca = 'ML-PRIM', presentacion = 'C/12 capsulas', forma_farmaceutica = 'Capsulas', subcategoria = 'Relajante muscular',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Metocarbamol 375 mg + Ibuprofeno 200 mg',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Producto Gelpharma Reg. 065M2019 · FC-27426982
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502227426982', '75022274269820') OR sku IN ('FC-27426982') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Producto Gelpharma Reg. 065M2019', 'sku', 'FC-27426982', 'codigo_barras', '7502227426982',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-27426982', codigo_barras = '7502227426982', nombre = 'Producto Gelpharma Reg. 065M2019',
      marca = 'Gelpharma', presentacion = 'Caja', forma_farmaceutica = 'Capsulas', subcategoria = 'Medicamentos',
      categoria = 'Medicamentos', tipo = 'marca',   activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Rosel-t antigripal C/15 · FC-03738879
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7503003738879', '75030037388790') OR sku IN ('FC-03738879') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Rosel-t antigripal C/15', 'sku', 'FC-03738879', 'codigo_barras', '7503003738879',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-03738879', codigo_barras = '7503003738879', nombre = 'Rosel-t antigripal C/15',
      marca = 'Rosel-t', presentacion = 'C/15', forma_farmaceutica = 'Tabletas', subcategoria = 'Antigripal',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Amantadina + Clorfenamina + Paracetamol',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Rexurdir nifuroxazida 400 mg C/16 · FC-01165953
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502001165953', '75020011659530') OR sku IN ('FC-01165953') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Rexurdir nifuroxazida 400 mg C/16', 'sku', 'FC-01165953', 'codigo_barras', '7502001165953',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-01165953', codigo_barras = '7502001165953', nombre = 'Rexurdir nifuroxazida 400 mg C/16',
      marca = 'Rexurdir', presentacion = 'C/16', forma_farmaceutica = 'Capsulas', subcategoria = 'Antidiarreico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Nifuroxazida 400 mg',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Raspisons unguento neomicina/retinol 28 g · FC-11165726
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501311165726', '75013111657260') OR sku IN ('FC-11165726') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Raspisons unguento neomicina/retinol 28 g', 'sku', 'FC-11165726', 'codigo_barras', '7501311165726',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-11165726', codigo_barras = '7501311165726', nombre = 'Raspisons unguento neomicina/retinol 28 g',
      marca = 'Raspisons', presentacion = 'Tubo 28 g', forma_farmaceutica = 'Unguento', subcategoria = 'Antibiotico topico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Neomicina + Retinol',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Producto Sons side panel · FC-01165397
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502001165397', '75020011653970') OR sku IN ('FC-01165397') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Producto Sons side panel', 'sku', 'FC-01165397', 'codigo_barras', '7502001165397',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-01165397', codigo_barras = '7502001165397', nombre = 'Producto Sons side panel',
      marca = 'Sons', presentacion = 'Caja', forma_farmaceutica = 'Tabletas', subcategoria = 'Medicamentos',
      categoria = 'Medicamentos', tipo = 'marca',   activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Producto Sons side panel alt · FC-01165724
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502001165724', '75020011657240') OR sku IN ('FC-01165724') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Producto Sons side panel alt', 'sku', 'FC-01165724', 'codigo_barras', '7502001165724',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-01165724', codigo_barras = '7502001165724', nombre = 'Producto Sons side panel alt',
      marca = 'Sons', presentacion = 'Caja', forma_farmaceutica = 'Tabletas', subcategoria = 'Medicamentos',
      categoria = 'Medicamentos', tipo = 'marca',   activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Jarabe dropropizina/bromhexina Quimpharma 100 mL · FC-23111387
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502223111387', '75022231113870') OR sku IN ('FC-23111387') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Jarabe dropropizina/bromhexina Quimpharma 100 mL', 'sku', 'FC-23111387', 'codigo_barras', '7502223111387',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-23111387', codigo_barras = '7502223111387', nombre = 'Jarabe dropropizina/bromhexina Quimpharma 100 mL',
      marca = 'Quimpharma', presentacion = 'Frasco 100 mL', forma_farmaceutica = 'Jarabe', subcategoria = 'Antitusivo',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Dropropizina + Bromhexina',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Producto Quimpharma Reg. 476M2005 · FC-23111202
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502223111202', '75022231112020') OR sku IN ('FC-23111202') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Producto Quimpharma Reg. 476M2005', 'sku', 'FC-23111202', 'codigo_barras', '7502223111202',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-23111202', codigo_barras = '7502223111202', nombre = 'Producto Quimpharma Reg. 476M2005',
      marca = 'Quimpharma', presentacion = 'Caja', forma_farmaceutica = 'Tabletas', subcategoria = 'Medicamentos',
      categoria = 'Medicamentos', tipo = 'marca',   activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;
COMMIT;
