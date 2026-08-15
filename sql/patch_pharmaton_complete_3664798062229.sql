-- Pharmaton Complete 3664798062229
-- Abrir ESTE archivo en Cursor, Cmd+A, copiar, pegar en Supabase SQL Editor, RUN una sola vez.

DO $$
DECLARE
  v_pid bigint;
  v_lid bigint;
BEGIN
  SELECT id INTO v_pid
  FROM public.productos
  WHERE sku = 'FC-8062229'
     OR codigo_barras = '3664798062229'
  LIMIT 1;

  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Pharmaton Complete',
        'sku', 'FC-8062229',
        'codigo_barras', '3664798062229',
        'categoria', 'Producto',
        'tipo', 'marca',
        'descripcion', 'Pharmaton Complete C/30 tabletas - Sanofi. Alta manual.',
        'costo', 118.00,
        'precio', 159.30,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0,
      NULL,
      NULL,
      118.00,
      NULL
    ) f;

    UPDATE public.productos SET
      marca = 'Pharmaton',
      presentacion = 'C/30 tabletas',
      forma_farmaceutica = 'Tabletas',
      principio_activo = 'Multivitaminas + Ginseng G115',
      subcategoria = 'Multivitaminico / suplemento'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      nombre = 'Pharmaton Complete',
      sku = 'FC-8062229',
      codigo_barras = '3664798062229',
      marca = 'Pharmaton',
      presentacion = 'C/30 tabletas',
      forma_farmaceutica = 'Tabletas',
      principio_activo = 'Multivitaminas + Ginseng G115',
      subcategoria = 'Multivitaminico / suplemento',
      costo = COALESCE(costo, 118.00),
      precio = COALESCE(precio, 159.30),
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

SELECT id, sku, codigo_barras, nombre, stock, precio
FROM public.productos
WHERE sku = 'FC-8062229';
