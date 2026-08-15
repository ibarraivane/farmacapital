-- Catálogo canónico: barcodes verificados + altas Farmalive
-- Ejecutar UNA vez en Supabase SQL Editor (copiar archivo completo, Cmd+A)
-- Fuente: scripts/datos_barcodes_canonicos.py

-- ═══ 1. Corregir barcodes / stock en productos existentes ═══

-- FIX FC-00740024 → 650240007408 · Silka Medic Gel
UPDATE public.productos SET
  codigo_barras = '650240007408',
  nombre = 'Silka Medic Gel',
  marca = 'Silka',
  presentacion = 'Tubo 15 g',
  principio_activo = 'Terbinafina',
  forma_farmaceutica = 'GEL',
  descripcion = coalesce(nullif(btrim(descripcion), ''), 'OCR ticket: 65024000740024 → patch erróneo 6502400074024')
WHERE sku = 'FC-00740024'
  AND NOT EXISTS (
    SELECT 1 FROM public.productos o
    WHERE o.codigo_barras = '650240007408' AND o.id <> public.productos.id
  );

-- FIX FC-58715517 → 7501095409004 · Graneodin B Frambuesa
UPDATE public.productos SET
  codigo_barras = '7501095409004',
  nombre = 'Graneodin B Frambuesa',
  marca = 'Graneodin',
  presentacion = 'C/24 pastillas',
  principio_activo = 'Benzocaina',
  forma_farmaceutica = 'PASTILLAS',
  stock = 2,
  stock_unidades = 2,
  descripcion = coalesce(nullif(btrim(descripcion), ''), 'Ticket tenía 7501058715517 (otro sabor); físico frambuesa')
WHERE sku = 'FC-58715517'
  AND NOT EXISTS (
    SELECT 1 FROM public.productos o
    WHERE o.codigo_barras = '7501095409004' AND o.id <> public.productos.id
  );

-- ═══ 2. Altas que nunca entraron por OCR ═══

-- INSERT FC-69200016 · 7501369200016 · Estomaquil Polvo C/20
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-69200016' OR codigo_barras = '7501369200016' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Estomaquil Polvo C/20',
        'sku', 'FC-69200016',
        'codigo_barras', '7501369200016',
        'categoria', 'Producto',
        'tipo', 'marca',
        'descripcion', 'Estomaquil Polvo C/20 — alta canonica EAN 7501369200016',
        'costo', 98.79,
        'precio', 133.37,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0, NULL, NULL, 98.79, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Higia',
      presentacion = 'C/20 sobres 3 g',
      principio_activo = 'Bismuto subsalicilato; Hidróxido de magnesio; Carbonato de calcio',
      forma_farmaceutica = 'Polvo'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501369200016',
      nombre = 'Estomaquil Polvo C/20',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-98062229 · 3664798062229 · Pharmaton Complete
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-98062229' OR codigo_barras = '3664798062229' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Pharmaton Complete',
        'sku', 'FC-98062229',
        'codigo_barras', '3664798062229',
        'categoria', 'Producto',
        'tipo', 'marca',
        'descripcion', 'Pharmaton Complete — alta canonica EAN 3664798062229',
        'costo', 118.00,
        'precio', 159.30,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0, NULL, NULL, 118.00, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Pharmaton',
      presentacion = 'C/30 tabletas',
      principio_activo = 'Multivitaminas + Ginseng G115',
      forma_farmaceutica = 'Tabletas'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '3664798062229',
      nombre = 'Pharmaton Complete',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-59525015 · 7501159525015 · Eucaliptine Jarabe 140 ml
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-59525015' OR codigo_barras = '7501159525015' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Eucaliptine Jarabe 140 ml',
        'sku', 'FC-59525015',
        'codigo_barras', '7501159525015',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Eucaliptine Jarabe 140 ml — alta canonica EAN 7501159525015',
        'costo', 107.00,
        'precio', 144.45,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0, NULL, NULL, 107.00, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Eucaliptine',
      presentacion = 'Frasco 140 ml',
      principio_activo = 'Dextrometorfano + Sulfoguayacol',
      forma_farmaceutica = 'Jarabe'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501159525015',
      nombre = 'Eucaliptine Jarabe 140 ml',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-25112881 · 7501125112881 · Pisacaina 2% 20 mg/ml Sol 50 ml
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-25112881' OR codigo_barras = '7501125112881' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Pisacaina 2% 20 mg/ml Sol 50 ml',
        'sku', 'FC-25112881',
        'codigo_barras', '7501125112881',
        'categoria', 'Medicamentos',
        'tipo', 'MEDICAMENTO',
        'descripcion', 'Pisacaina 2% 20 mg/ml Sol 50 ml — alta canonica EAN 7501125112881',
        'costo', 85.00,
        'precio', 114.75,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', true
      ),
      0, NULL, NULL, 85.00, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Pisacaina',
      presentacion = 'Frasco ampula 50 ml',
      principio_activo = 'Lidocaina',
      forma_farmaceutica = 'Solucion inyectable',
      subcategoria = 'Anestesico local'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501125112881',
      nombre = 'Pisacaina 2% 20 mg/ml Sol 50 ml',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-08421321 · 7501008421321 · Redoxon 1g 2-pack Naranja
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08421321' OR codigo_barras = '7501008421321' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Redoxon 1g 2-pack Naranja',
        'sku', 'FC-08421321',
        'codigo_barras', '7501008421321',
        'categoria', 'Otro',
        'tipo', 'marca',
        'descripcion', 'Redoxon 1g 2-pack Naranja — alta canonica EAN 7501008421321',
        'costo', 130.00,
        'precio', 175.50,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0, NULL, NULL, 130.00, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Redoxon',
      presentacion = 'Caja 2 tubos x 10 tab',
      principio_activo = 'Acido ascorbico (Vitamina C)',
      forma_farmaceutica = 'Tabletas efervescentes',
      subcategoria = 'Vitamina C / inmunidad'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008421321',
      nombre = 'Redoxon 1g 2-pack Naranja',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-08497593 · 7501008497593 · Alka-Seltzer Boost C/10
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08497593' OR codigo_barras = '7501008497593' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Alka-Seltzer Boost C/10',
        'sku', 'FC-08497593',
        'codigo_barras', '7501008497593',
        'categoria', 'Otro',
        'tipo', 'marca',
        'descripcion', 'Alka-Seltzer Boost C/10 — alta canonica EAN 7501008497593',
        'costo', 42.00,
        'precio', 56.70,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      2, NULL, NULL, 42.00, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Alka-Seltzer',
      presentacion = 'C/10 tabletas efervescentes',
      principio_activo = 'Acido acetilsalicilico + Cafeina',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Antiacido / analgesico',
      stock = 2,
      stock_unidades = 2
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008497593',
      nombre = 'Alka-Seltzer Boost C/10',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-08499702 · 7501008499702 · Tabcin Noche C/12
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08499702' OR codigo_barras = '7501008499702' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Tabcin Noche C/12',
        'sku', 'FC-08499702',
        'codigo_barras', '7501008499702',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Tabcin Noche C/12 — alta canonica EAN 7501008499702',
        'costo', 71.21,
        'precio', 96.14,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0, NULL, NULL, 71.21, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Tabcin',
      presentacion = 'C/12 capsulas',
      principio_activo = 'Paracetamol + Fenilefrina + Dextrometorfano + Doxilamina',
      forma_farmaceutica = 'Capsulas',
      subcategoria = 'Antigripal / noche'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008499702',
      nombre = 'Tabcin Noche C/12',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-07535494 · 7501007535494 · Motrin Infantil Suspension 120 ml
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-07535494' OR codigo_barras = '7501007535494' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Motrin Infantil Suspension 120 ml',
        'sku', 'FC-07535494',
        'codigo_barras', '7501007535494',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Motrin Infantil Suspension 120 ml — alta canonica EAN 7501007535494',
        'costo', 186.40,
        'precio', 251.64,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0, NULL, NULL, 186.40, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Motrin',
      presentacion = 'Frasco 120 ml sabor frutas',
      principio_activo = 'Ibuprofeno 2 g/100 ml',
      forma_farmaceutica = 'Suspension oral',
      subcategoria = 'Analgesico / antipiretico infantil'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501007535494',
      nombre = 'Motrin Infantil Suspension 120 ml',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-98215099 · 7501298215099 · Sedalmerck Max C/24
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-98215099' OR codigo_barras = '7501298215099' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Sedalmerck Max C/24',
        'sku', 'FC-98215099',
        'codigo_barras', '7501298215099',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Sedalmerck Max C/24 — alta canonica EAN 7501298215099',
        'costo', 122.06,
        'precio', 164.78,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      2, NULL, NULL, 122.06, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Sedalmerck',
      presentacion = 'C/24 tabletas',
      principio_activo = 'Paracetamol + Clorfenamina + Fenilefrina',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Antigripal',
      stock = 2,
      stock_unidades = 2
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501298215099',
      nombre = 'Sedalmerck Max C/24',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-85278507 · 0736085278507 · Manzanilla Sophia Solucion 15 ml
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-85278507' OR codigo_barras = '0736085278507' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Manzanilla Sophia Solucion 15 ml',
        'sku', 'FC-85278507',
        'codigo_barras', '0736085278507',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Manzanilla Sophia Solucion 15 ml — alta canonica EAN 0736085278507',
        'costo', 63.41,
        'precio', 85.61,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      1, NULL, NULL, 63.41, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Sophia',
      presentacion = 'Frasco 15 ml',
      principio_activo = 'Manzanilla (Matricaria chamomilla)',
      forma_farmaceutica = 'Solucion oral',
      subcategoria = 'Digestivo / calmante',
      stock = 1,
      stock_unidades = 1
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '0736085278507',
      nombre = 'Manzanilla Sophia Solucion 15 ml',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-08499818 · 7501008499818 · Aspirina 500 mg C/80
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08499818' OR codigo_barras = '7501008499818' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Aspirina 500 mg C/80',
        'sku', 'FC-08499818',
        'codigo_barras', '7501008499818',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Aspirina 500 mg C/80 — alta canonica EAN 7501008499818',
        'costo', 61.15,
        'precio', 82.56,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      2, NULL, NULL, 61.15, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Aspirina',
      presentacion = 'C/80 tabletas 500 mg',
      principio_activo = 'Acido acetilsalicilico 500 mg',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Analgesico / antipiretico',
      stock = 2,
      stock_unidades = 2
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008499818',
      nombre = 'Aspirina 500 mg C/80',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-08443033 · 7501008443033 · Alka-Seltzer C/12 alivio rapido
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08443033' OR codigo_barras = '7501008443033' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Alka-Seltzer C/12 alivio rapido',
        'sku', 'FC-08443033',
        'codigo_barras', '7501008443033',
        'categoria', 'Otro',
        'tipo', 'marca',
        'descripcion', 'Alka-Seltzer C/12 alivio rapido — alta canonica EAN 7501008443033',
        'costo', 39.00,
        'precio', 52.65,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      2, NULL, NULL, 39.00, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Alka-Seltzer',
      presentacion = 'C/12 tabletas efervescentes',
      principio_activo = 'Acido acetilsalicilico + Bicarbonato + Citrico',
      forma_farmaceutica = 'Tabletas efervescentes',
      subcategoria = 'Antiacido / analgesico',
      stock = 2,
      stock_unidades = 2
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008443033',
      nombre = 'Alka-Seltzer C/12 alivio rapido',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-46642073 · 7502246642073 · Microdacyn Solucion 60 ml
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-46642073' OR codigo_barras = '7502246642073' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Microdacyn Solucion 60 ml',
        'sku', 'FC-46642073',
        'codigo_barras', '7502246642073',
        'categoria', 'Botiquín',
        'tipo', 'marca',
        'descripcion', 'Microdacyn Solucion 60 ml — alta canonica EAN 7502246642073',
        'costo', 114.66,
        'precio', 154.80,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      1, NULL, NULL, 114.66, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Microdacyn',
      presentacion = 'Frasco 60 ml',
      principio_activo = 'Acido hipocloroso / solucion antiseptica',
      forma_farmaceutica = 'Solucion topica',
      subcategoria = 'Antiseptico / curacion de heridas',
      stock = 1,
      stock_unidades = 1
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7502246642073',
      nombre = 'Microdacyn Solucion 60 ml',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- Verificación
SELECT sku, nombre, codigo_barras, stock, precio
FROM public.productos
WHERE sku IN (
  'FC-00740024','FC-58715517','FC-69200016','FC-8062229','FC-9525015',
  'FC-5112881','FC-8421321','FC-8497593'
) OR codigo_barras IN (
  '650240007408','7501095409004','7501369200016','3664798062229',
  '7501159525015','7501125112881','7501008421321','7501008497593'
)
ORDER BY sku;
