-- Microdacyn solucion 60 ml · 7502246642073
-- Ticket FL-080826: MICRODACYN 60 · $114.66 (sin barcode OCR)
-- Distinto de FC-87932321 (Sico lubricante 50 ml · 7501058793232)

begin;

DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-46642073'
     OR codigo_barras = '7502246642073'
  LIMIT 1;

  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Microdacyn Solucion 60 ml',
        'sku', 'FC-46642073',
        'codigo_barras', '7502246642073',
        'categoria', 'Botiquín',
        'tipo', 'marca',
        'descripcion', 'Microdacyn solucion antiseptica 60 ml — EAN 7502246642073',
        'costo', 114.66,
        'precio', 154.80,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      1, NULL, NULL, 114.66, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Microdacyn',
      presentacion = 'Frasco 60 ml',
      principio_activo = 'Acido hipocloroso / solucion antiseptica',
      forma_farmaceutica = 'Solucion topica',
      subcategoria = 'Antiseptico / curacion de heridas'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7502246642073',
      nombre = 'Microdacyn Solucion 60 ml',
      marca = 'Microdacyn',
      presentacion = 'Frasco 60 ml',
      costo = 114.66,
      precio = 154.80,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

commit;

select sku, nombre, codigo_barras, costo, precio, stock, presentacion
from public.productos
where sku = 'FC-46642073' or codigo_barras = '7502246642073';
