-- ════════════════════════════════════════════════════════════════
-- ESQUEMA DE INVENTARIO - FarmaCapital
-- Tablas para gestión de productos, lotes y movimientos
-- ════════════════════════════════════════════════════════════════

-- ── TABLA: PRODUCTOS (Catálogo maestro)
CREATE TABLE IF NOT EXISTS public.productos (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  sku TEXT UNIQUE NOT NULL,
  nombre TEXT NOT NULL,
  marca TEXT,
  codigo_barras TEXT UNIQUE,
  categoria TEXT DEFAULT 'GENERAL',
  descripcion TEXT,
  tipo TEXT DEFAULT 'MEDICAMENTO',
  presentacion TEXT,
  contenido TEXT,
  unidad TEXT DEFAULT 'UNIT',

  precio DECIMAL(10, 2),
  costo DECIMAL(10, 2),
  stock INT DEFAULT 0,
  stock_minimo INT DEFAULT 10,

  proveedor TEXT DEFAULT 'EQUILIBRIO FARMACEÚTICO',
  requiere_receta BOOLEAN DEFAULT false,
  activo BOOLEAN DEFAULT true,
  visible_tienda BOOLEAN DEFAULT true,

  imagen_url TEXT,

  INDEX idx_codigo_barras (codigo_barras),
  INDEX idx_sku (sku),
  INDEX idx_categoria (categoria),
  INDEX idx_activo (activo)
);

-- ── TABLA: LOTES (Seguimiento por lote y caducidad)
CREATE TABLE IF NOT EXISTS public.lotes (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  producto_id BIGINT NOT NULL REFERENCES productos(id) ON DELETE CASCADE,
  numero_lote TEXT NOT NULL,
  cantidad_inicial INT NOT NULL,
  cantidad_actual INT NOT NULL,

  fecha_caducidad DATE,
  costo_unitario DECIMAL(10, 2),

  activo BOOLEAN DEFAULT true,

  INDEX idx_producto (producto_id),
  INDEX idx_numero_lote (numero_lote),
  INDEX idx_caducidad (fecha_caducidad)
);

-- ── TABLA: MOVIMIENTOS_INVENTARIO (Auditoría de cambios)
CREATE TABLE IF NOT EXISTS public.movimientos_inventario (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  producto_id BIGINT NOT NULL REFERENCES productos(id) ON DELETE CASCADE,
  tipo TEXT NOT NULL, -- 'entrada', 'salida', 'ajuste', 'devolución'
  cantidad INT NOT NULL,
  motivo TEXT,

  usuario_id TEXT,
  documento_referencia TEXT,

  INDEX idx_producto (producto_id),
  INDEX idx_tipo (tipo),
  INDEX idx_fecha (created_at)
);

-- ── RLS: Acceso a productos (todos pueden leer, solo admin puede escribir)
ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "productos_select" ON public.productos FOR SELECT USING (true);
CREATE POLICY "productos_insert_admin" ON public.productos FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM auth.users WHERE auth.uid() = id AND raw_user_meta_data->>'rol' = 'admin'));
CREATE POLICY "productos_update_admin" ON public.productos FOR UPDATE
  USING (EXISTS (SELECT 1 FROM auth.users WHERE auth.uid() = id AND raw_user_meta_data->>'rol' = 'admin'));

-- ── RLS: Lotes (similar a productos)
ALTER TABLE public.lotes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "lotes_select" ON public.lotes FOR SELECT USING (true);
CREATE POLICY "lotes_insert_admin" ON public.lotes FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM auth.users WHERE auth.uid() = id AND raw_user_meta_data->>'rol' = 'admin'));

-- ── RLS: Movimientos (solo lectura para audit)
ALTER TABLE public.movimientos_inventario ENABLE ROW LEVEL SECURITY;
CREATE POLICY "movimientos_select" ON public.movimientos_inventario FOR SELECT USING (true);
CREATE POLICY "movimientos_insert" ON public.movimientos_inventario FOR INSERT
  WITH CHECK (true);

-- ── FUNCIÓN: Crear producto con lote automático
CREATE OR REPLACE FUNCTION create_producto_with_lote(
  p_producto jsonb,
  p_cantidad INT,
  p_numero_lote TEXT,
  p_fecha_caducidad DATE,
  p_costo_unitario DECIMAL
) RETURNS TABLE (
  producto_id BIGINT,
  nombre TEXT,
  mensaje TEXT
) AS $$
DECLARE
  v_producto_id BIGINT;
  v_nombre TEXT;
BEGIN
  -- Crear producto
  INSERT INTO productos (
    sku, nombre, marca, codigo_barras, categoria, presentacion, contenido,
    precio, costo, stock, proveedor, requiere_receta, activo, visible_tienda,
    tipo, descripcion, unidad
  ) VALUES (
    p_producto->>'sku',
    p_producto->>'nombre',
    p_producto->>'marca',
    p_producto->>'codigo_barras',
    COALESCE(p_producto->>'categoria', 'GENERAL'),
    p_producto->>'presentacion',
    p_producto->>'contenido',
    (p_producto->>'precio')::DECIMAL,
    (p_producto->>'costo')::DECIMAL,
    p_cantidad,
    COALESCE(p_producto->>'proveedor', 'EQUILIBRIO FARMACEÚTICO'),
    (COALESCE(p_producto->>'requiere_receta', 'false'))::BOOLEAN,
    (COALESCE(p_producto->>'activo', 'true'))::BOOLEAN,
    (COALESCE(p_producto->>'visible_tienda', 'true'))::BOOLEAN,
    COALESCE(p_producto->>'tipo', 'MEDICAMENTO'),
    p_producto->>'descripcion',
    COALESCE(p_producto->>'unidad', 'UNIT')
  )
  RETURNING productos.id, productos.nombre INTO v_producto_id, v_nombre;

  -- Crear lote
  IF p_cantidad > 0 THEN
    INSERT INTO lotes (
      producto_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_caducidad, costo_unitario, activo
    ) VALUES (
      v_producto_id, p_numero_lote, p_cantidad, p_cantidad,
      p_fecha_caducidad, p_costo_unitario, true
    );
  END IF;

  -- Registrar movimiento
  INSERT INTO movimientos_inventario (
    producto_id, tipo, cantidad, motivo, usuario_id
  ) VALUES (
    v_producto_id, 'entrada', p_cantidad,
    'Ingreso inicial desde PDF/ticket', auth.uid()::TEXT
  );

  RETURN QUERY SELECT v_producto_id, v_nombre::TEXT, 'OK'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── GRANT: Permisos para funciones
GRANT EXECUTE ON FUNCTION create_producto_with_lote TO authenticated;

-- ── ÍNDICES ADICIONALES para búsquedas frecuentes
CREATE INDEX IF NOT EXISTS idx_productos_proveedor ON productos(proveedor);
CREATE INDEX IF NOT EXISTS idx_productos_visible ON productos(visible_tienda, activo);
CREATE INDEX IF NOT EXISTS idx_lotes_caducidad_activos ON lotes(fecha_caducidad) WHERE activo = true;

-- ── TRIGGER: Actualizar updated_at en productos
CREATE OR REPLACE FUNCTION update_productos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_productos_updated_at ON productos;
CREATE TRIGGER trigger_update_productos_updated_at
  BEFORE UPDATE ON productos
  FOR EACH ROW
  EXECUTE FUNCTION update_productos_updated_at();

-- ── TRIGGER: Actualizar stock cuando se crea/modifica lote
CREATE OR REPLACE FUNCTION update_stock_on_lote_change()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE productos
  SET stock = (SELECT COALESCE(SUM(cantidad_actual), 0) FROM lotes WHERE producto_id = NEW.producto_id AND activo = true)
  WHERE id = NEW.producto_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_stock_on_lote_change ON lotes;
CREATE TRIGGER trigger_update_stock_on_lote_change
  AFTER INSERT OR UPDATE ON lotes
  FOR EACH ROW
  EXECUTE FUNCTION update_stock_on_lote_change();

COMMIT;
