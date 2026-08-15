-- Línea Tabcin Bayer: 4 variantes con EAN distintos
-- Ejecutar en Supabase SQL Editor (copiar archivo completo, Cmd+A)
--
-- Ya existía: FC-08485316 eferv (7501008485316), posible FC-08499702 noche
-- Altas: Tabcin 500 (7501008485408), Tabcin Active (7501008499689)

begin;

-- 1) Corregir Tabcin efervescente (existía con nombre/presentación OCR)
UPDATE public.productos SET
  codigo_barras = '7501008485316',
  nombre = 'Tabcin efervescente C/12',
  marca = 'Tabcin',
  presentacion = 'C/12 tabletas efervescentes',
  principio_activo = 'Acido acetilsalicilico + Fenilefrina + Clorfenamina',
  forma_farmaceutica = 'Tabletas efervescentes',
  categoria = 'Medicamentos',
  tipo = 'marca',
  subcategoria = 'Antigripal',
  costo = 37.73,
  precio = 49.05,
  activo = true
WHERE sku = 'FC-08485316';

-- 2) Tabcin Noche · 7501008499702
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
        'descripcion', 'Tabcin Noche C/12 — EAN 7501008499702',
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
      marca = 'Tabcin',
      presentacion = 'C/12 capsulas',
      principio_activo = 'Paracetamol + Fenilefrina + Dextrometorfano + Doxilamina',
      forma_farmaceutica = 'Capsulas',
      categoria = 'Medicamentos',
      costo = 71.21,
      precio = 96.14,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- 3) Tabcin 500 · 7501008485408 · ticket $46.06/caja
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08485408' OR codigo_barras = '7501008485408' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Tabcin 500 C/12',
        'sku', 'FC-08485408',
        'codigo_barras', '7501008485408',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Tabcin 500 C/12 — EAN 7501008485408',
        'costo', 46.06,
        'precio', 62.19,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0, NULL, NULL, 46.06, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Tabcin',
      presentacion = 'C/12 capsulas',
      principio_activo = 'Paracetamol + Amantadina + Clorfenamina + Fenilefrina',
      forma_farmaceutica = 'Capsulas',
      subcategoria = 'Antigripal'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008485408',
      nombre = 'Tabcin 500 C/12',
      costo = 46.06,
      precio = 62.19,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- 4) Tabcin Active · 7501008499689 · Exprezo $70.60
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08499689' OR codigo_barras = '7501008499689' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Tabcin Active C/12',
        'sku', 'FC-08499689',
        'codigo_barras', '7501008499689',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Tabcin Active C/12 — EAN 7501008499689',
        'costo', 70.60,
        'precio', 95.31,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0, NULL, NULL, 70.60, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Tabcin',
      presentacion = 'C/12 capsulas',
      principio_activo = 'Paracetamol + Fenilefrina + Dextrometorfano + Guaifenesina',
      forma_farmaceutica = 'Capsulas',
      subcategoria = 'Antigripal / tos'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008499689',
      nombre = 'Tabcin Active C/12',
      costo = 70.60,
      precio = 95.31,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

commit;

-- Verificación (deben ser 4 filas, barcodes distintos)
SELECT sku, nombre, codigo_barras, costo, precio, stock, activo
FROM public.productos
WHERE codigo_barras IN (
  '7501008485316',
  '7501008499702',
  '7501008485408',
  '7501008499689'
)
ORDER BY nombre;
