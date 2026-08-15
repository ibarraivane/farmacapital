-- ALTA Pisacaina 2% 20 mg/ml sol 50 ml - EAN 7501125112881
-- (Marca Pisacaina / PiSA - lidocaina inyectable)
-- Nota: a veces se escribe "Posacaina"; el barcode correcto es 7501125112881 (13 digitos)
-- Copiar TODO este archivo en Supabase (Cmd+A en Cursor)

DO $$
DECLARE
  v_pid bigint;
  v_lid bigint;
BEGIN
  SELECT id INTO v_pid
  FROM public.productos
  WHERE sku = 'FC-5112881'
     OR codigo_barras IN ('7501125112881', '751125112881')
  LIMIT 1;

  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Pisacaina 2% 20 mg/ml Sol 50 ml',
        'sku', 'FC-5112881',
        'codigo_barras', '7501125112881',
        'categoria', 'Medicamentos',
        'tipo', 'MEDICAMENTO',
        'descripcion', 'Pisacaina 2% lidocaina frasco ampula 50 ml - PiSA. Alta manual (no en ticket FL-080826).',
        'costo', 85.00,
        'precio', 114.75,
        'stock_minimo', 2,
        'activo', true,
        'requiere_receta', true
      ),
      0,
      NULL,
      NULL,
      85.00,
      NULL
    ) f;

    UPDATE public.productos SET
      marca = 'Pisacaina',
      presentacion = 'Frasco ampula 50 ml',
      forma_farmaceutica = 'Solucion inyectable',
      principio_activo = 'Lidocaina',
      concentracion = '2% / 20 mg/ml',
      subcategoria = 'Anestesico local'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      nombre = 'Pisacaina 2% 20 mg/ml Sol 50 ml',
      sku = 'FC-5112881',
      codigo_barras = '7501125112881',
      marca = 'Pisacaina',
      presentacion = 'Frasco ampula 50 ml',
      forma_farmaceutica = 'Solucion inyectable',
      principio_activo = 'Lidocaina',
      concentracion = '2% / 20 mg/ml',
      subcategoria = 'Anestesico local',
      requiere_receta = true,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

SELECT sku, nombre, codigo_barras, presentacion, stock, requiere_receta, precio
FROM public.productos
WHERE sku = 'FC-5112881';
