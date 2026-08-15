-- Bisolvon Solución Adulto 120 ml · Sanfer · 7501037907117
-- Distinto de Bisolvon Infantil FC-79071241 (7501037907124)
-- Costo $141.94 · cad feb 2028
-- Ejecutar en Supabase SQL Editor (Cmd+A)

begin;

DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-7907117' OR codigo_barras = '7501037907117' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Bisolvon Solucion Adulto 120 ml',
        'sku', 'FC-7907117',
        'codigo_barras', '7501037907117',
        'categoria', 'Respiratorio',
        'tipo', 'marca',
        'descripcion', 'Bisolvon Bromhexina solucion adulto 120 ml — Sanfer EAN 7501037907117',
        'costo', 141.94,
        'precio', 191.62,
        'stock_minimo', 2,
        'activo', true,
        'requiere_receta', false
      ),
      1, NULL, '2028-02-28'::date, 141.94, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Bisolvon',
      presentacion = 'Frasco 120 ml',
      principio_activo = 'Bromhexina',
      forma_farmaceutica = 'Solucion oral',
      subcategoria = 'Expectorante / antitusivo',
      proveedor = 'Sanfer'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501037907117',
      nombre = 'Bisolvon Solucion Adulto 120 ml',
      marca = 'Bisolvon',
      presentacion = 'Frasco 120 ml',
      principio_activo = 'Bromhexina',
      forma_farmaceutica = 'Solucion oral',
      categoria = 'Respiratorio',
      costo = 141.94,
      precio = 191.62,
      stock = greatest(coalesce(stock, 0), 1),
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

commit;

SELECT p.sku, p.nombre, p.codigo_barras, p.costo, p.precio, p.stock,
       l.fecha_caducidad, l.cantidad_actual
FROM public.productos p
LEFT JOIN public.lotes l ON l.producto_id = p.id AND coalesce(l.activo, true) = true
WHERE p.codigo_barras = '7501037907117';
