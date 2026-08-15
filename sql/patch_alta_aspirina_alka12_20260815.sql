-- Aspirina 80 tab 500 mg (2 cajas) + Alka-Seltzer C/12 (2 cajas)
-- Ejecutar en Supabase SQL Editor (copiar archivo completo)

begin;

-- Aspirina 500 mg C/80 · 7501008499818 · cad ene 2029 · 2 cajas
-- Distinto de FC-08491074 (7501008491074 = doble pack "80 2 paci")
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08499818' OR codigo_barras = '7501008499818' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Aspirina 500 mg C/80',
        'sku', 'FC-08499818',
        'codigo_barras', '7501008499818',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Aspirina Bayer 500 mg 80 tabletas — EAN 7501008499818',
        'costo', 61.15,
        'precio', 82.56,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      2, NULL, '2029-01-31'::date, 61.15, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Aspirina',
      presentacion = 'C/80 tabletas 500 mg',
      principio_activo = 'Acido acetilsalicilico 500 mg',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Analgesico / antipiretico'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008499818',
      nombre = 'Aspirina 500 mg C/80',
      costo = 61.15,
      precio = 82.56,
      stock = 2,
      stock_unidades = 0,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- Alka-Seltzer C/12 alivio rapido · 7501008443033 · cad 01-ene-2029 · 2 cajas
-- Ticket OCR: 73010084430331 → $39.00/caja (2 = $78.01)
-- Distinto de FC-08443026 (C/100 · 7501008443026)
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08443033' OR codigo_barras = '7501008443033' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Alka-Seltzer C/12 alivio rapido',
        'sku', 'FC-08443033',
        'codigo_barras', '7501008443033',
        'categoria', 'Otro',
        'tipo', 'marca',
        'descripcion', 'Alka-Seltzer 12 tabletas efervescentes — EAN 7501008443033',
        'costo', 39.00,
        'precio', 52.65,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      2, NULL, '2029-01-01'::date, 39.00, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Alka-Seltzer',
      presentacion = 'C/12 tabletas efervescentes',
      principio_activo = 'Acido acetilsalicilico + Bicarbonato + Citrico',
      forma_farmaceutica = 'Tabletas efervescentes',
      subcategoria = 'Antiacido / analgesico',
      venta_unidad = true,
      unidades_por_caja = 12,
      precio_unidad = 9
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008443033',
      nombre = 'Alka-Seltzer C/12 alivio rapido',
      costo = 39.00,
      precio = 52.65,
      stock = 2,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

commit;

select sku, nombre, codigo_barras, costo, precio, stock, presentacion
from public.productos
where sku in ('FC-08499818', 'FC-08443033')
order by sku;
