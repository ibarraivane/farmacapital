-- ALTA Alka-Seltzer Boost C/10 tabletas - EAN 7501008497593
-- Copiar TODO este archivo en Supabase (Cmd+A en Cursor)
-- Stock: 2 cajas (conteo fisico usuario)

DO $$
DECLARE
  v_pid bigint;
  v_lid bigint;
BEGIN
  SELECT id INTO v_pid
  FROM public.productos
  WHERE sku = 'FC-8497593'
     OR codigo_barras = '7501008497593'
  LIMIT 1;

  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Alka-Seltzer Boost C/10',
        'sku', 'FC-8497593',
        'codigo_barras', '7501008497593',
        'categoria', 'Otro',
        'tipo', 'marca',
        'descripcion', 'Alka-Seltzer Boost 10 tabletas efervescentes - Bayer. Alta manual (presentacion C/10 distinta a C/50 en catalogo).',
        'costo', 42.00,
        'precio', 56.70,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      2,
      NULL,
      NULL,
      42.00,
      NULL
    ) f;

    UPDATE public.productos SET
      marca = 'Alka-Seltzer',
      presentacion = 'C/10 tabletas efervescentes',
      forma_farmaceutica = 'Tabletas',
      principio_activo = 'Acido acetilsalicilico + Cafeina',
      subcategoria = 'Antiacido / analgesico',
      stock = 2,
      stock_unidades = 2
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      nombre = 'Alka-Seltzer Boost C/10',
      sku = 'FC-8497593',
      codigo_barras = '7501008497593',
      marca = 'Alka-Seltzer',
      presentacion = 'C/10 tabletas efervescentes',
      forma_farmaceutica = 'Tabletas',
      principio_activo = 'Acido acetilsalicilico + Cafeina',
      subcategoria = 'Antiacido / analgesico',
      stock = 2,
      stock_unidades = 2,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

SELECT sku, nombre, codigo_barras, presentacion, stock, costo, precio
FROM public.productos
WHERE sku = 'FC-8497593';
