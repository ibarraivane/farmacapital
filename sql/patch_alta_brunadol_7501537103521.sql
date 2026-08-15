-- Brunadol Paracetamol + Naproxeno C/10 · Bruluart · 7501537103521
-- Frente: C/10 tab 300/275 mg · Lateral: lote 604188 cad 06-abr-2028 · PMP $72
-- Ticket Farmalive: $19.31/caja (4 cajas ≈ $77.22)
-- Ejecutar en Supabase SQL Editor (copiar archivo completo, Cmd+A)

begin;

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
        'descripcion', 'Brunadol Paracetamol 300 mg + Naproxeno 275 mg 10 tab — Bruluart EAN 7501537103521',
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

commit;

SELECT p.sku, p.nombre, p.codigo_barras, p.costo, p.precio, p.stock,
       l.numero_lote, l.fecha_caducidad, l.cantidad_actual
FROM public.productos p
LEFT JOIN public.lotes l ON l.producto_id = p.id AND coalesce(l.activo, true) = true
WHERE p.codigo_barras = '7501537103521';
