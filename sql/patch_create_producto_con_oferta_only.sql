-- Solo la RPC create_producto_con_oferta (si las tablas v2 ya existen)
-- Usar si verify_inventario_v2.sql muestra tablas ok pero falta la función.

BEGIN;

CREATE OR REPLACE FUNCTION public.create_producto_con_oferta(
  p_producto jsonb,
  p_cantidad INT,
  p_proveedor TEXT,
  p_precio_unitario DECIMAL,
  p_fecha_compra DATE,
  p_numero_lote TEXT,
  p_fecha_caducidad DATE
)
RETURNS TABLE (
  producto_id BIGINT,
  nombre TEXT,
  mensaje TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_producto_id BIGINT;
  v_oferta_id BIGINT;
  v_nombre TEXT;
  v_codigo TEXT := NULLIF(trim(p_producto->>'codigo_barras'), '');
BEGIN
  IF v_codigo IS NOT NULL THEN
    INSERT INTO public.productos_v2 (
      codigo_barras, nombre, marca, presentacion, contenido, contenido_unidad,
      categoria, tipo, requiere_receta, activo, visible_tienda, descripcion
    ) VALUES (
      v_codigo,
      p_producto->>'nombre',
      p_producto->>'marca',
      p_producto->>'presentacion',
      NULLIF(p_producto->>'contenido', '')::DECIMAL,
      p_producto->>'contenido_unidad',
      COALESCE(p_producto->>'categoria', 'GENERAL'),
      COALESCE(p_producto->>'tipo', 'MEDICAMENTO'),
      COALESCE(p_producto->>'requiere_receta', 'false')::BOOLEAN,
      true, true,
      p_producto->>'descripcion'
    )
    ON CONFLICT (codigo_barras) DO UPDATE
      SET updated_at = CURRENT_TIMESTAMP,
          nombre = EXCLUDED.nombre,
          marca = EXCLUDED.marca,
          presentacion = EXCLUDED.presentacion,
          contenido = EXCLUDED.contenido,
          contenido_unidad = EXCLUDED.contenido_unidad,
          descripcion = EXCLUDED.descripcion
    RETURNING public.productos_v2.id, public.productos_v2.nombre
    INTO v_producto_id, v_nombre;
  ELSE
    INSERT INTO public.productos_v2 (
      codigo_barras, nombre, marca, presentacion, contenido, contenido_unidad,
      categoria, tipo, requiere_receta, activo, visible_tienda, descripcion
    ) VALUES (
      NULL,
      p_producto->>'nombre',
      p_producto->>'marca',
      p_producto->>'presentacion',
      NULLIF(p_producto->>'contenido', '')::DECIMAL,
      p_producto->>'contenido_unidad',
      COALESCE(p_producto->>'categoria', 'GENERAL'),
      COALESCE(p_producto->>'tipo', 'MEDICAMENTO'),
      COALESCE(p_producto->>'requiere_receta', 'false')::BOOLEAN,
      true, true,
      p_producto->>'descripcion'
    )
    RETURNING public.productos_v2.id, public.productos_v2.nombre
    INTO v_producto_id, v_nombre;
  END IF;

  INSERT INTO public.ofertas_proveedor (
    producto_id, proveedor, precio_unitario, precio_total,
    cantidad_disponible, fecha_compra, vigente
  ) VALUES (
    v_producto_id, p_proveedor, p_precio_unitario,
    p_precio_unitario * p_cantidad, p_cantidad, p_fecha_compra, true
  )
  RETURNING id INTO v_oferta_id;

  IF p_cantidad > 0 THEN
    INSERT INTO public.lotes_v2 (
      producto_id, oferta_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_recepcion, fecha_caducidad, costo_unitario, costo_total, proveedor, activo
    ) VALUES (
      v_producto_id, v_oferta_id, p_numero_lote, p_cantidad, p_cantidad,
      p_fecha_compra, p_fecha_caducidad, p_precio_unitario,
      p_precio_unitario * p_cantidad, p_proveedor, true
    );
  END IF;

  INSERT INTO public.movimientos_v2 (producto_id, tipo, cantidad, motivo, usuario_id)
  VALUES (v_producto_id, 'entrada', p_cantidad, 'Ingreso de ' || p_proveedor, COALESCE(auth.uid()::TEXT, 'sistema'));

  RETURN QUERY SELECT v_producto_id, v_nombre::TEXT, 'OK'::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_producto_con_oferta(
  jsonb, INT, TEXT, DECIMAL, DATE, TEXT, DATE
) TO anon, authenticated, service_role;

COMMIT;

-- Verificación inmediata (debe devolver 1 fila):
SELECT proname FROM pg_proc WHERE proname = 'create_producto_con_oferta';
