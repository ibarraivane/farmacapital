-- ════════════════════════════════════════════════════════════════
-- SCHEMA V2: INVENTARIO CON ANÁLISIS DE PROVEEDORES Y PRECIOS
-- Permite comparar precios y rastrear cambios
-- ════════════════════════════════════════════════════════════════

-- ── TABLA: PRODUCTOS NORMALIZADOS (Maestro único)
CREATE TABLE IF NOT EXISTS public.productos_v2 (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  -- Identificadores
  codigo_barras TEXT UNIQUE,
  nombre TEXT NOT NULL,
  marca TEXT,

  -- Presentación (normalizada)
  presentacion TEXT,          -- ej: 40 CAPSULAS
  contenido DECIMAL(10,2),    -- ej: 500 (mg/ml)
  contenido_unidad TEXT,      -- ej: MG, ML, G
  unidad TEXT DEFAULT 'UNIT', -- ej: CAPS, TAB, ML

  -- Categorización
  categoria TEXT DEFAULT 'GENERAL',
  tipo TEXT DEFAULT 'MEDICAMENTO',
  requiere_receta BOOLEAN DEFAULT false,

  -- Campos informativos
  descripcion TEXT,
  imagen_url TEXT,

  -- Estado
  activo BOOLEAN DEFAULT true,
  visible_tienda BOOLEAN DEFAULT true,

  INDEX idx_codigo_barras (codigo_barras),
  INDEX idx_nombre (nombre),
  INDEX idx_categoria (categoria)
);

-- ── TABLA: OFERTAS DE PROVEEDORES (Historial de precios)
CREATE TABLE IF NOT EXISTS public.ofertas_proveedor (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  -- Producto y proveedor
  producto_id BIGINT NOT NULL REFERENCES productos_v2(id) ON DELETE CASCADE,
  proveedor TEXT NOT NULL,

  -- Precio y cantidad
  precio_unitario DECIMAL(10, 2) NOT NULL,
  precio_total DECIMAL(10, 2),
  cantidad_disponible INT,

  -- Metadatos
  fecha_compra DATE,
  ticket_numero TEXT,
  vigente BOOLEAN DEFAULT true,

  INDEX idx_producto (producto_id),
  INDEX idx_proveedor (proveedor),
  INDEX idx_fecha (fecha_compra),
  UNIQUE(producto_id, proveedor, fecha_compra)
);

-- ── TABLA: LOTES POR PROVEEDOR
CREATE TABLE IF NOT EXISTS public.lotes_v2 (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  -- Referencia
  producto_id BIGINT NOT NULL REFERENCES productos_v2(id) ON DELETE CASCADE,
  oferta_id BIGINT REFERENCES ofertas_proveedor(id) ON DELETE SET NULL,

  -- Información del lote
  numero_lote TEXT,
  cantidad_inicial INT NOT NULL,
  cantidad_actual INT NOT NULL,

  -- Fechas
  fecha_recepcion DATE,
  fecha_caducidad DATE,

  -- Costos
  costo_unitario DECIMAL(10, 2),
  costo_total DECIMAL(10, 2),

  -- Estado
  proveedor TEXT,
  activo BOOLEAN DEFAULT true,

  INDEX idx_producto (producto_id),
  INDEX idx_caducidad (fecha_caducidad),
  INDEX idx_proveedor_lote (proveedor)
);

-- ── TABLA: MOVIMIENTOS DE INVENTARIO
CREATE TABLE IF NOT EXISTS public.movimientos_v2 (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  producto_id BIGINT NOT NULL REFERENCES productos_v2(id) ON DELETE CASCADE,
  lote_id BIGINT REFERENCES lotes_v2(id) ON DELETE SET NULL,

  tipo TEXT NOT NULL, -- entrada, salida, ajuste, devolución
  cantidad INT NOT NULL,
  motivo TEXT,

  usuario_id TEXT,
  documento_referencia TEXT,

  INDEX idx_producto (producto_id),
  INDEX idx_tipo (tipo),
  INDEX idx_fecha (created_at)
);

-- ── VISTA: MEJOR PRECIO POR PRODUCTO
CREATE OR REPLACE VIEW vw_mejor_precio AS
SELECT
  p.id,
  p.codigo_barras,
  p.nombre,
  p.marca,
  p.presentacion,
  p.contenido || ' ' || p.contenido_unidad as concentracion,

  o.proveedor,
  o.precio_unitario,
  o.fecha_compra,

  -- Ranking por precio
  ROW_NUMBER() OVER (PARTITION BY p.id ORDER BY o.precio_unitario ASC) as precio_rank,

  -- Stock total disponible
  (SELECT COALESCE(SUM(cantidad_actual), 0)
   FROM lotes_v2 WHERE producto_id = p.id AND activo = true) as stock_disponible

FROM productos_v2 p
LEFT JOIN ofertas_proveedor o ON p.id = o.producto_id AND o.vigente = true
WHERE p.activo = true;

-- ── VISTA: COMPARATIVA DE PRECIOS ACTUALES
CREATE OR REPLACE VIEW vw_comparativa_precios AS
SELECT
  p.nombre,
  p.marca,
  p.presentacion,
  p.contenido || ' ' || p.contenido_unidad as concentracion,

  STRING_AGG(DISTINCT o.proveedor, ', ') as proveedores,
  MIN(o.precio_unitario) as precio_minimo,
  MAX(o.precio_unitario) as precio_maximo,
  AVG(o.precio_unitario)::NUMERIC(10,2) as precio_promedio,
  COUNT(DISTINCT o.proveedor) as num_proveedores,

  ROUND(((MAX(o.precio_unitario) - MIN(o.precio_unitario)) / MIN(o.precio_unitario) * 100)::NUMERIC, 1) as % diferencia

FROM productos_v2 p
LEFT JOIN ofertas_proveedor o ON p.id = o.producto_id AND o.vigente = true
WHERE p.activo = true
GROUP BY p.id, p.nombre, p.marca, p.presentacion, p.contenido, p.contenido_unidad;

-- ── FUNCIÓN: Crear producto con oferta de proveedor
CREATE OR REPLACE FUNCTION create_producto_con_oferta(
  p_producto jsonb,
  p_cantidad INT,
  p_proveedor TEXT,
  p_precio_unitario DECIMAL,
  p_fecha_compra DATE,
  p_numero_lote TEXT,
  p_fecha_caducidad DATE
) RETURNS TABLE (
  producto_id BIGINT,
  nombre TEXT,
  mensaje TEXT
) AS $$
DECLARE
  v_producto_id BIGINT;
  v_oferta_id BIGINT;
  v_nombre TEXT;
BEGIN
  -- Crear o actualizar producto
  INSERT INTO productos_v2 (
    codigo_barras, nombre, marca, presentacion, contenido, contenido_unidad,
    categoria, tipo, requiere_receta, activo, visible_tienda, descripcion
  ) VALUES (
    p_producto->>'codigo_barras',
    p_producto->>'nombre',
    p_producto->>'marca',
    p_producto->>'presentacion',
    (p_producto->>'contenido')::DECIMAL,
    p_producto->>'contenido_unidad',
    COALESCE(p_producto->>'categoria', 'GENERAL'),
    COALESCE(p_producto->>'tipo', 'MEDICAMENTO'),
    (COALESCE(p_producto->>'requiere_receta', 'false'))::BOOLEAN,
    true, true,
    p_producto->>'descripcion'
  )
  ON CONFLICT (codigo_barras) DO UPDATE
  SET updated_at = CURRENT_TIMESTAMP
  RETURNING productos_v2.id, productos_v2.nombre INTO v_producto_id, v_nombre;

  -- Registrar oferta de proveedor
  INSERT INTO ofertas_proveedor (
    producto_id, proveedor, precio_unitario, precio_total,
    cantidad_disponible, fecha_compra, vigente
  ) VALUES (
    v_producto_id, p_proveedor, p_precio_unitario,
    p_precio_unitario * p_cantidad,
    p_cantidad, p_fecha_compra, true
  )
  RETURNING id INTO v_oferta_id;

  -- Crear lote
  IF p_cantidad > 0 THEN
    INSERT INTO lotes_v2 (
      producto_id, oferta_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_recepcion, fecha_caducidad, costo_unitario, costo_total, proveedor, activo
    ) VALUES (
      v_producto_id, v_oferta_id, p_numero_lote, p_cantidad, p_cantidad,
      p_fecha_compra, p_fecha_caducidad, p_precio_unitario,
      p_precio_unitario * p_cantidad, p_proveedor, true
    );
  END IF;

  -- Registrar movimiento
  INSERT INTO movimientos_v2 (
    producto_id, tipo, cantidad, motivo, usuario_id
  ) VALUES (
    v_producto_id, 'entrada', p_cantidad,
    'Ingreso de ' || p_proveedor, auth.uid()::TEXT
  );

  RETURN QUERY SELECT v_producto_id, v_nombre::TEXT, 'OK'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── TRIGGERS: Actualizar timestamp
CREATE OR REPLACE FUNCTION update_productos_v2_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_productos_v2_updated_at ON productos_v2;
CREATE TRIGGER trigger_update_productos_v2_updated_at
  BEFORE UPDATE ON productos_v2
  FOR EACH ROW
  EXECUTE FUNCTION update_productos_v2_updated_at();

-- ── RLS: Row Level Security
ALTER TABLE public.productos_v2 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ofertas_proveedor ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lotes_v2 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimientos_v2 ENABLE ROW LEVEL SECURITY;

-- Políticas permisivas
CREATE POLICY "productos_v2_select" ON public.productos_v2 FOR SELECT USING (true);
CREATE POLICY "ofertas_select" ON public.ofertas_proveedor FOR SELECT USING (true);
CREATE POLICY "lotes_v2_select" ON public.lotes_v2 FOR SELECT USING (true);
CREATE POLICY "movimientos_v2_select" ON public.movimientos_v2 FOR SELECT USING (true);

-- Índices de rendimiento
CREATE INDEX IF NOT EXISTS idx_ofertas_precio ON ofertas_proveedor(precio_unitario);
CREATE INDEX IF NOT EXISTS idx_lotes_v2_caducidad_activo ON lotes_v2(fecha_caducidad) WHERE activo = true;
CREATE INDEX IF NOT EXISTS idx_productos_v2_activo_visible ON productos_v2(activo, visible_tienda);

COMMIT;
