-- ALTA Redoxon 1g 2-pack (2 tubos x 10 tab naranja) - EAN 7501008421321
-- Promo "2 a precio especial" - Bayer OTC
-- Copiar TODO este archivo en Supabase (Cmd+A en Cursor)

DO $$
DECLARE
  v_pid bigint;
  v_lid bigint;
BEGIN
  SELECT id INTO v_pid
  FROM public.productos
  WHERE sku = 'FC-8421321'
     OR codigo_barras = '7501008421321'
  LIMIT 1;

  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Redoxon 1g 2-pack Naranja',
        'sku', 'FC-8421321',
        'codigo_barras', '7501008421321',
        'categoria', 'Otro',
        'tipo', 'marca',
        'descripcion', 'Redoxon vitamina C 1g - caja promo 2 tubos x 10 tab efervescentes naranja. Alta manual.',
        'costo', 130.00,
        'precio', 175.50,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0,
      NULL,
      NULL,
      130.00,
      NULL
    ) f;

    UPDATE public.productos SET
      marca = 'Redoxon',
      presentacion = 'Caja 2 tubos x 10 tab',
      forma_farmaceutica = 'Tabletas efervescentes',
      principio_activo = 'Acido ascorbico (Vitamina C)',
      concentracion = '1 g',
      subcategoria = 'Vitamina C / inmunidad'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      nombre = 'Redoxon 1g 2-pack Naranja',
      sku = 'FC-8421321',
      codigo_barras = '7501008421321',
      marca = 'Redoxon',
      presentacion = 'Caja 2 tubos x 10 tab',
      forma_farmaceutica = 'Tabletas efervescentes',
      principio_activo = 'Acido ascorbico (Vitamina C)',
      concentracion = '1 g',
      subcategoria = 'Vitamina C / inmunidad',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

SELECT sku, nombre, codigo_barras, presentacion, stock, costo, precio
FROM public.productos
WHERE sku = 'FC-8421321';
