-- Altas Farmalive FL-080826 que el OCR no cargó bien (barcodes truncados / líneas mezcladas)
-- Ejecutar UNA vez en Supabase SQL Editor (Cmd+A del archivo completo)
--
-- 1) Topron C/16      · 7501088579615 · Chinoin
-- 2) Brunadol C/10    · 7501537103521 · Bruluart
-- 3) Veridex C/4 6 mg · 7502209747366 · Maver

begin;

-- ── 1) Topron ──
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08579615' OR codigo_barras = '7501088579615' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Topron C/16 400 mg',
        'sku', 'FC-08579615',
        'codigo_barras', '7501088579615',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Topron Nifuroxazida 400 mg 16 caps — Chinoin EAN 7501088579615',
        'costo', 153.47,
        'precio', 251.40,
        'stock_minimo', 2,
        'activo', true,
        'requiere_receta', false
      ),
      1, '8FB077', '2028-02-28'::date, 153.47, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Topron',
      presentacion = 'C/16 capsulas 400 mg',
      principio_activo = 'Nifuroxazida 400 mg',
      forma_farmaceutica = 'Capsulas',
      subcategoria = 'Antidiarreico',
      proveedor = 'Chinoin'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501088579615',
      nombre = 'Topron C/16 400 mg',
      marca = 'Topron',
      presentacion = 'C/16 capsulas 400 mg',
      principio_activo = 'Nifuroxazida 400 mg',
      forma_farmaceutica = 'Capsulas',
      categoria = 'Medicamentos',
      costo = 153.47,
      precio = 251.40,
      stock = greatest(coalesce(stock, 0), 1),
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- ── 2) Brunadol ──
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-103521' OR codigo_barras = '7501537103521' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Brunadol C/10',
        'sku', 'FC-103521',
        'codigo_barras', '7501537103521',
        'categoria', 'Medicamentos',
        'tipo', 'generico',
        'descripcion', 'Brunadol Paracetamol 300 mg + Naproxeno 275 mg 10 tab — Bruluart',
        'costo', 19.31,
        'precio', 72.00,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      4, '604188', '2028-04-06'::date, 19.31, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Brunadol',
      presentacion = 'C/10 tabletas',
      principio_activo = 'Paracetamol 300 mg + Naproxeno 275 mg',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Analgesico / antipiretico / antinflamatorio',
      proveedor = 'Bruluart'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501537103521',
      nombre = 'Brunadol C/10',
      marca = 'Brunadol',
      presentacion = 'C/10 tabletas',
      principio_activo = 'Paracetamol 300 mg + Naproxeno 275 mg',
      forma_farmaceutica = 'Tabletas',
      categoria = 'Medicamentos',
      tipo = 'generico',
      costo = 19.31,
      precio = 72.00,
      stock = greatest(coalesce(stock, 0), 4),
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- ── 3) Veridex ──
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-9747366' OR codigo_barras = '7502209747366' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Veridex C/4 6 mg',
        'sku', 'FC-9747366',
        'codigo_barras', '7502209747366',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Veridex Ivermectina 6 mg 4 tab — Maver EAN 7502209747366',
        'costo', 75.46,
        'precio', 360.00,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', true
      ),
      1, '261181', '2028-02-28'::date, 75.46, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Veridex',
      presentacion = 'C/4 tabletas 6 mg',
      principio_activo = 'Ivermectina 6 mg',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Antiparasitario',
      proveedor = 'Maver',
      requiere_receta = true
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7502209747366',
      nombre = 'Veridex C/4 6 mg',
      marca = 'Veridex',
      presentacion = 'C/4 tabletas 6 mg',
      principio_activo = 'Ivermectina 6 mg',
      forma_farmaceutica = 'Tabletas',
      categoria = 'Medicamentos',
      costo = 75.46,
      precio = 360.00,
      requiere_receta = true,
      stock = greatest(coalesce(stock, 0), 1),
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

commit;

-- Verificación: deben ser 3 filas
SELECT p.sku, p.nombre, p.codigo_barras, p.costo, p.precio, p.stock,
       p.requiere_receta, l.numero_lote, l.fecha_caducidad, l.cantidad_actual
FROM public.productos p
LEFT JOIN public.lotes l ON l.producto_id = p.id AND coalesce(l.activo, true) = true
WHERE p.codigo_barras IN (
  '7501088579615',
  '7501537103521',
  '7502209747366'
)
ORDER BY p.nombre;
