-- Bisolvon Adulto + Pepto-Bismol + Corega Ultra (ticket FL-080826 / empaque)
-- Ejecutar en Supabase SQL Editor (Cmd+A)

begin;

-- ── 1) Bisolvon Solución Adulto · 7501037907117 ──
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
        'descripcion', 'Bisolvon Bromhexina solucion adulto 120 ml — Sanfer',
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
      costo = 141.94,
      precio = 191.62,
      stock = greatest(coalesce(stock, 0), 1),
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- ── 2) Pepto-Bismol · 020800753067 ──
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-00753067'
     OR codigo_barras IN ('020800753067', '0208007530671', '20800753067')
  LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Pepto-Bismol Suspension 118 ml',
        'sku', 'FC-00753067',
        'codigo_barras', '020800753067',
        'categoria', 'Digestivo',
        'tipo', 'marca',
        'descripcion', 'Pepto-Bismol subsalicilato 118 ml — P&G',
        'costo', 96.73,
        'precio', 150.00,
        'stock_minimo', 2,
        'activo', true,
        'requiere_receta', false
      ),
      1, NULL, '2027-06-30'::date, 96.73, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Pepto-Bismol',
      presentacion = 'Frasco 118 ml',
      principio_activo = 'Subsalicilato de bismuto 1.75 g/100 ml',
      forma_farmaceutica = 'Suspension oral',
      subcategoria = 'Antiácido / antidiarreico',
      proveedor = 'Procter & Gamble'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '020800753067',
      nombre = 'Pepto-Bismol Suspension 118 ml',
      costo = 96.73,
      precio = 150.00,
      stock = greatest(coalesce(stock, 0), 1),
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- ── 3) Corega Ultra Sin Sabor · 7896009490651 ──
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-9490651'
     OR codigo_barras IN ('7896009490651', '78960094906511')
  LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Corega Ultra Sin Sabor 40 g',
        'sku', 'FC-9490651',
        'codigo_barras', '7896009490651',
        'categoria', 'Higiene',
        'tipo', 'marca',
        'descripcion', 'Corega Ultra crema adhesiva protesis 40 g — Haleon',
        'costo', 120.05,
        'precio', 162.07,
        'stock_minimo', 2,
        'activo', true,
        'requiere_receta', false
      ),
      1, 'NK9S', '2028-10-31'::date, 120.05, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Corega',
      presentacion = 'Tubo 40 g',
      principio_activo = 'Crema adhesiva para protesis dentales',
      forma_farmaceutica = 'Crema',
      subcategoria = 'Protesis dental / adhesivo',
      proveedor = 'Haleon'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7896009490651',
      nombre = 'Corega Ultra Sin Sabor 40 g',
      costo = 120.05,
      precio = 162.07,
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
WHERE p.codigo_barras IN (
  '7501037907117', '020800753067', '0208007530671', '7896009490651'
)
ORDER BY p.nombre;
