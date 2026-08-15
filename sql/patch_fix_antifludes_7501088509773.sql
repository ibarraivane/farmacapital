-- Antiflu-Des C/24 · Chinoin · barcode real 7501088509773
-- (existía FC-01508201 con OCR 750525301508201 — no escaneaba)
-- Ejecutar en Supabase SQL Editor (Cmd+A)

begin;

UPDATE public.productos SET
  codigo_barras = '7501088509773',
  nombre = 'Antiflu-Des C/24',
  marca = 'Antiflu-Des',
  presentacion = 'C/24 capsulas',
  principio_activo = 'Amantadina + Clorfenamina + Paracetamol',
  forma_farmaceutica = 'Capsulas',
  categoria = 'Medicamentos',
  tipo = 'marca',
  subcategoria = 'Antigripal',
  costo = 149.35,
  precio = 201.63,
  activo = true
WHERE sku = 'FC-01508201'
  AND NOT EXISTS (
    SELECT 1 FROM public.productos o
    WHERE o.codigo_barras = '7501088509773' AND o.id <> public.productos.id
  );

-- Si nunca se creó (patch completo no corrido)
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-01508201' OR codigo_barras = '7501088509773' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Antiflu-Des C/24',
        'sku', 'FC-08509773',
        'codigo_barras', '7501088509773',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Antiflu-Des C/24 Chinoin — EAN 7501088509773',
        'costo', 149.35,
        'precio', 201.63,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      1, NULL, NULL, 149.35, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Antiflu-Des',
      presentacion = 'C/24 capsulas',
      principio_activo = 'Amantadina + Clorfenamina + Paracetamol',
      forma_farmaceutica = 'Capsulas',
      subcategoria = 'Antigripal',
      proveedor = 'Chinoin'
    WHERE id = v_pid;
  END IF;
END $$;

commit;

SELECT sku, nombre, codigo_barras, costo, precio, stock, activo
FROM public.productos
WHERE codigo_barras = '7501088509773' OR sku IN ('FC-01508201', 'FC-08509773');
