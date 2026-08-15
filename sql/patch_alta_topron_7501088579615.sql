-- Topron Nifuroxazida 400 mg C/16 · Chinoin · 7501088579615
-- (Incluido también en sql/patch_altas_farmalive_anexos_20260815.sql junto con Brunadol y Veridex)

begin;

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

commit;

SELECT p.sku, p.nombre, p.codigo_barras, p.costo, p.precio, p.stock,
       l.numero_lote, l.fecha_caducidad, l.cantidad_actual
FROM public.productos p
LEFT JOIN public.lotes l ON l.producto_id = p.id AND coalesce(l.activo, true) = true
WHERE p.codigo_barras = '7501088579615';
