-- Precios por pieza (venta_unidad) + Manzanilla Sophia + fix Obao
-- Ejecutar en Supabase SQL Editor (copiar archivo completo)

begin;

-- Obao: producto de 1 pieza, no venta suelta
update public.productos set
  venta_unidad = false,
  unidades_por_caja = 0,
  precio_unidad = 0,
  stock_unidades = 0
where sku = 'FC-52844825';

-- Precios unitarios recalculados (recargo costo + utilidad min + penalizacion vs caja)
update public.productos set precio_unidad = 8 where sku = 'FC-08443026';
update public.productos set precio_unidad = 10 where sku = 'FC-8497593';
update public.productos set precio_unidad = 39 where sku = 'FC-98217659';
update public.productos set precio_unidad = 7 where sku = 'FC-58715517';
update public.productos set precio_unidad = 8 where sku = 'FC-01157296';
update public.productos set precio_unidad = 8 where sku = 'FC-01405335';
update public.productos set precio_unidad = 15 where sku = 'FC-16800803';
update public.productos set precio_unidad = 24 where sku = 'FC-92730451';
update public.productos set
  precio = 19.29,
  precio_unidad = 7,
  unidades_por_caja = 8
where sku = 'FC-19006623';
update public.productos set precio_unidad = 9 where sku = 'FC-95451096';
update public.productos set precio_unidad = 10 where sku = 'FC-95467264';
update public.productos set precio_unidad = 11 where sku = 'FC-98215099';
update public.productos set precio_unidad = 13 where sku = 'FC-34092301';
update public.productos set precio_unidad = 9 where sku = 'FC-08485316';
update public.productos set precio_unidad = 11 where sku = 'FC-08499702';
update public.productos set precio_unidad = 10 where sku = 'FC-54525051';
update public.productos set precio_unidad = 26 where sku = 'FC-50071598';
update public.productos set
  unidades_por_caja = 8,
  precio_unidad = 10
where sku = 'FC-65054135';
update public.productos set precio_unidad = 9 where sku = 'FC-00525451';

-- Manzanilla Sophia 15 ml (EAN escaneado 736085278507 → 0736085278507)
-- Ticket OCR mezclo linea con Aspirina: [7360852785071 MANZANIILA SOPHIA
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-85278507'
     OR codigo_barras IN ('0736085278507', '736085278507')
  LIMIT 1;

  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Manzanilla Sophia Solucion 15 ml',
        'sku', 'FC-85278507',
        'codigo_barras', '0736085278507',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Manzanilla Sophia gotas 15 ml — ticket FL-080826 OCR mezclado con Aspirina',
        'costo', 63.41,
        'precio', 85.61,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      1, NULL, '2028-03-31'::date, 63.41, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Sophia',
      presentacion = 'Frasco 15 ml',
      principio_activo = 'Manzanilla (Matricaria chamomilla)',
      forma_farmaceutica = 'Solucion oral',
      subcategoria = 'Digestivo / calmante'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '0736085278507',
      nombre = 'Manzanilla Sophia Solucion 15 ml',
      marca = 'Sophia',
      presentacion = 'Frasco 15 ml',
      costo = 63.41,
      precio = 85.61,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

commit;

-- Verificacion
select sku, nombre, codigo_barras, costo, precio, precio_unidad, unidades_por_caja, venta_unidad
from public.productos
where sku in (
  'FC-08443026','FC-8497593','FC-98217659','FC-58715517','FC-01157296','FC-01405335',
  'FC-16800803','FC-92730451','FC-19006623','FC-95451096','FC-95467264','FC-98215099',
  'FC-34092301','FC-08485316','FC-08499702','FC-54525051','FC-50071598','FC-65054135',
  'FC-00525451','FC-52844825','FC-85278507'
)
order by nombre;
