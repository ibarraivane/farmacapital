-- Fotos lote 3 medicamentos · 2026-08-15
-- Abrir desde DISCO · Cmd+A · pegar completo en Supabase
-- NO copiar desde chat (trunca → error 42601)
-- Sin columna proveedor · solo DO $$

BEGIN;

-- Daclafin subsalicilato bismuto susp. 120 mL · FC-53601339
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502253601339', '75022536013390') OR sku IN ('FC-53601339') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Daclafin subsalicilato bismuto susp. 120 mL', 'sku', 'FC-53601339', 'codigo_barras', '7502253601339',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Columbia/Weser · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, '26C0037', '2028-03-31'::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-53601339', codigo_barras = '7502253601339', nombre = 'Daclafin subsalicilato bismuto susp. 120 mL',
      marca = 'Daclafin', presentacion = 'Frasco 120 mL', forma_farmaceutica = 'Suspension', subcategoria = 'Antidiarreico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Subsalicilato de bismuto',  activo = true, descripcion = 'Columbia/Weser · costo pendiente ticket'
    WHERE id = v_pid;
    UPDATE public.lotes SET numero_lote = coalesce(nullif(btrim(numero_lote), ''), '26C0037'), fecha_caducidad = coalesce(fecha_caducidad, '2028-03-31'::date) WHERE producto_id = v_pid;
  END IF;
END $$;

-- Collifrin oximetazolina 0.05% solucion 20 mL · FC-31144302
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7500831144302', '75008311443020') OR sku IN ('FC-31144302') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Collifrin oximetazolina 0.05% solucion 20 mL', 'sku', 'FC-31144302', 'codigo_barras', '7500831144302',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-31144302', codigo_barras = '7500831144302', nombre = 'Collifrin oximetazolina 0.05% solucion 20 mL',
      marca = 'Collifrin', presentacion = 'Frasco 20 mL', forma_farmaceutica = 'Solucion nasal', subcategoria = 'Descongestionante',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Oximetazolina 0.05%',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Lidocaina unguento 5% tubo 35 g · FC-04908738
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7503004908738', '75030049087380') OR sku IN ('FC-04908738') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Lidocaina unguento 5% tubo 35 g', 'sku', 'FC-04908738', 'codigo_barras', '7503004908738',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-04908738', codigo_barras = '7503004908738', nombre = 'Lidocaina unguento 5% tubo 35 g',
      marca = 'Lidocaina', presentacion = 'Tubo 35 g', forma_farmaceutica = 'Unguento', subcategoria = 'Anestesico topico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Lidocaina 5%',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Omeprazol Avivia capsulas C/60 · FC-16803800
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502216803800', '75022168038000') OR sku IN ('FC-16803800') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Omeprazol Avivia capsulas C/60', 'sku', 'FC-16803800', 'codigo_barras', '7502216803800',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-16803800', codigo_barras = '7502216803800', nombre = 'Omeprazol Avivia capsulas C/60',
      marca = 'Avivia', presentacion = 'C/60', forma_farmaceutica = 'Capsulas', subcategoria = 'Protector gastrico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Omeprazol 20 mg',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Aktyzar omeprazol Solfran capsulas C/120 · FC-82200016
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501482200016', '75014822000160') OR sku IN ('FC-82200016') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Aktyzar omeprazol Solfran capsulas C/120', 'sku', 'FC-82200016', 'codigo_barras', '7501482200016',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Solfran · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, '61168', '2028-06-30'::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-82200016', codigo_barras = '7501482200016', nombre = 'Aktyzar omeprazol Solfran capsulas C/120',
      marca = 'Aktyzar', presentacion = 'C/120', forma_farmaceutica = 'Capsulas', subcategoria = 'Protector gastrico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Omeprazol 20 mg',  activo = true, descripcion = 'Solfran · costo pendiente ticket'
    WHERE id = v_pid;
    UPDATE public.lotes SET numero_lote = coalesce(nullif(btrim(numero_lote), ''), '61168'), fecha_caducidad = coalesce(fecha_caducidad, '2028-06-30'::date) WHERE producto_id = v_pid;
  END IF;
END $$;

-- Plusgel antiacido C/50 masticables · FC-31405888
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7500831405888', '75008314058880') OR sku IN ('FC-31405888') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Plusgel antiacido C/50 masticables', 'sku', 'FC-31405888', 'codigo_barras', '7500831405888',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', 'Collins · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, '26141277', '2028-05-31'::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-31405888', codigo_barras = '7500831405888', nombre = 'Plusgel antiacido C/50 masticables',
      marca = 'Plusgel', presentacion = 'C/50 masticables', forma_farmaceutica = 'Tabletas', subcategoria = 'Antiácido',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Hidroxido de aluminio + Hidroxido de magnesio + Dimeticona',  activo = true, descripcion = 'Collins · costo pendiente ticket'
    WHERE id = v_pid;
    UPDATE public.lotes SET numero_lote = coalesce(nullif(btrim(numero_lote), ''), '26141277'), fecha_caducidad = coalesce(fecha_caducidad, '2028-05-31'::date) WHERE producto_id = v_pid;
  END IF;
END $$;

-- Precicol hioscina/paracetamol gotas 20 mL · FC-36003621
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501836003621', '75018360036210') OR sku IN ('FC-36003621') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Precicol hioscina/paracetamol gotas 20 mL', 'sku', 'FC-36003621', 'codigo_barras', '7501836003621',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-36003621', codigo_barras = '7501836003621', nombre = 'Precicol hioscina/paracetamol gotas 20 mL',
      marca = 'Precicol', presentacion = 'Gotas 20 mL', forma_farmaceutica = 'Gotas', subcategoria = 'Antiespasmodico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Hioscina + Paracetamol',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Raamcinet cetirizina 10 mg · FC-27872123
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502227872123', '75022278721230') OR sku IN ('FC-27872123') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Raamcinet cetirizina 10 mg', 'sku', 'FC-27872123', 'codigo_barras', '7502227872123',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      6, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-27872123', codigo_barras = '7502227872123', nombre = 'Raamcinet cetirizina 10 mg',
      marca = 'Raam', presentacion = 'Caja tabletas', forma_farmaceutica = 'Tabletas', subcategoria = 'Antialergico',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Cetirizina 10 mg',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Raamfen difenidol 25 mg · FC-27871416
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502227871416', '75022278714160') OR sku IN ('FC-27871416') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Raamfen difenidol 25 mg', 'sku', 'FC-27871416', 'codigo_barras', '7502227871416',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      3, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-27871416', codigo_barras = '7502227871416', nombre = 'Raamfen difenidol 25 mg',
      marca = 'Raam', presentacion = 'Caja tabletas', forma_farmaceutica = 'Tabletas', subcategoria = 'Antiemético',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Difenidol 25 mg',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- ML-PRIM Russek side panel · FC-11784029
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502211784029', '75022117840290') OR sku IN ('FC-11784029') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'ML-PRIM Russek side panel', 'sku', 'FC-11784029', 'codigo_barras', '7502211784029',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-11784029', codigo_barras = '7502211784029', nombre = 'ML-PRIM Russek side panel',
      marca = 'ML-PRIM', presentacion = 'Caja', forma_farmaceutica = 'Capsulas', subcategoria = 'Relajante muscular',
      categoria = 'Medicamentos', tipo = 'marca', principio_activo = 'Metocarbamol + Ibuprofeno',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Producto side morado (identificar) · FC-09763986
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501109763986', '75011097639860') OR sku IN ('FC-09763986') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Producto side morado (identificar)', 'sku', 'FC-09763986', 'codigo_barras', '7501109763986',
        'categoria', 'Medicamentos', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-09763986', codigo_barras = '7501109763986', nombre = 'Producto side morado (identificar)',
       presentacion = 'Caja', forma_farmaceutica = 'Tabletas', subcategoria = 'Medicamentos',
      categoria = 'Medicamentos', tipo = 'marca',   activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Playboy Max Sens condones C/4 3+1 · FC-14377180
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7503014377180', '75030143771800') OR sku IN ('FC-14377180') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Playboy Max Sens condones C/4 3+1', 'sku', 'FC-14377180', 'codigo_barras', '7503014377180',
        'categoria', 'Cuidado personal', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-14377180', codigo_barras = '7503014377180', nombre = 'Playboy Max Sens condones C/4 3+1',
      marca = 'Playboy', presentacion = 'C/4 (3+1)', forma_farmaceutica = 'Condones', subcategoria = 'Anticonceptivo',
      categoria = 'Cuidado personal', tipo = 'marca', principio_activo = 'Hule latex natural',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;

-- Playboy Max Sens Extra Sensible C/4 3+1 · FC-14377197
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7503014377197', '75030143771970') OR sku IN ('FC-14377197') LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object('nombre', 'Playboy Max Sens Extra Sensible C/4 3+1', 'sku', 'FC-14377197', 'codigo_barras', '7503014377197',
        'categoria', 'Cuidado personal', 'tipo', 'marca', 'descripcion', ' · costo pendiente ticket',
        'costo', 0, 'precio', 0, 'stock_minimo', 2, 'activo', true, 'requiere_receta', false),
      1, NULL, NULL::date, 0, NULL::bigint, NULL::text) f;
  END IF;
  IF v_pid IS NOT NULL THEN
    UPDATE public.productos SET sku = 'FC-14377197', codigo_barras = '7503014377197', nombre = 'Playboy Max Sens Extra Sensible C/4 3+1',
      marca = 'Playboy', presentacion = 'C/4 (3+1)', forma_farmaceutica = 'Condones', subcategoria = 'Anticonceptivo',
      categoria = 'Cuidado personal', tipo = 'marca', principio_activo = 'Hule latex natural',  activo = true, descripcion = ' · costo pendiente ticket'
    WHERE id = v_pid;
  END IF;
END $$;
SELECT p.sku,p.nombre,p.codigo_barras FROM public.productos p WHERE p.sku IN ('FC-88579615','FC-27875568','FC-75723137','FC-27872123') ORDER BY 1;
COMMIT;
