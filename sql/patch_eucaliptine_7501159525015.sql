-- ALTA Eucaliptine Jarabe 140 ml - EAN 7501159525015
-- Copiar TODO este archivo en Supabase (Cmd+A en Cursor, no desde chat colapsado)
-- Ajusta stock abajo si ya tienes unidades en anaquel

DO $$
DECLARE
  v_pid bigint;
  v_lid bigint;
BEGIN
  SELECT id INTO v_pid
  FROM public.productos
  WHERE sku = 'FC-9525015'
     OR codigo_barras = '7501159525015'
  LIMIT 1;

  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Eucaliptine Jarabe 140 ml',
        'sku', 'FC-9525015',
        'codigo_barras', '7501159525015',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Eucaliptine jarabe 140 ml - Sanfer. Alta manual (no en ticket FL-080826).',
        'costo', 107.00,
        'precio', 144.45,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0,
      NULL,
      NULL,
      107.00,
      NULL
    ) f;

    UPDATE public.productos SET
      marca = 'Eucaliptine',
      presentacion = 'Frasco 140 ml',
      forma_farmaceutica = 'Jarabe',
      principio_activo = 'Dextrometorfano + Sulfoguayacol',
      subcategoria = 'Tos / vias respiratorias'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      nombre = 'Eucaliptine Jarabe 140 ml',
      sku = 'FC-9525015',
      codigo_barras = '7501159525015',
      marca = 'Eucaliptine',
      presentacion = 'Frasco 140 ml',
      forma_farmaceutica = 'Jarabe',
      principio_activo = 'Dextrometorfano + Sulfoguayacol',
      subcategoria = 'Tos / vias respiratorias',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

SELECT sku, nombre, codigo_barras, stock, costo, precio
FROM public.productos
WHERE sku = 'FC-9525015';
