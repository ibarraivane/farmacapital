-- ════════════════════════════════════════════════════════════════
-- SCHEMA V2: INVENTARIO CON ANÁLISIS DE PROVEEDORES Y PRECIOS
-- PostgreSQL / Supabase — ejecutar en SQL Editor (una vez)
-- ════════════════════════════════════════════════════════════════

BEGIN;

-- ── TABLA: PRODUCTOS NORMALIZADOS (Maestro único)
CREATE TABLE IF NOT EXISTS public.productos_v2 (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

  codigo_barras TEXT UNIQUE,
  nombre TEXT NOT NULL,
  marca TEXT,

  presentacion TEXT,
  contenido DECIMAL(10, 2),
  contenido_unidad TEXT,
  unidad TEXT DEFAULT 'UNIT',

  categoria TEXT DEFAULT 'GENERAL',
  tipo TEXT DEFAULT 'MEDICAMENTO',
  requiere_receta BOOLEAN DEFAULT false,

  descripcion TEXT,
  imagen_url TEXT,

  activo BOOLEAN DEFAULT true,
  visible_tienda BOOLEAN DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_productos_v2_codigo_barras ON public.productos_v2 (codigo_barras);
CREATE INDEX IF NOT EXISTS idx_productos_v2_nombre ON public.productos_v2 (nombre);
CREATE INDEX IF NOT EXISTS idx_productos_v2_categoria ON public.productos_v2 (categoria);

-- ── TABLA: OFERTAS DE PROVEEDORES (Historial de precios)
CREATE TABLE IF NOT EXISTS public.ofertas_proveedor (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

  producto_id BIGINT NOT NULL REFERENCES public.productos_v2 (id) ON DELETE CASCADE,
  proveedor TEXT NOT NULL,

  precio_unitario DECIMAL(10, 2) NOT NULL,
  precio_total DECIMAL(10, 2),
  cantidad_disponible INT,

  fecha_compra DATE,
  ticket_numero TEXT,
  vigente BOOLEAN DEFAULT true,

  UNIQUE (producto_id, proveedor, fecha_compra)
);

CREATE INDEX IF NOT EXISTS idx_ofertas_producto ON public.ofertas_proveedor (producto_id);
CREATE INDEX IF NOT EXISTS idx_ofertas_proveedor ON public.ofertas_proveedor (proveedor);
CREATE INDEX IF NOT EXISTS idx_ofertas_fecha ON public.ofertas_proveedor (fecha_compra);

-- ── TABLA: LOTES POR PROVEEDOR
CREATE TABLE IF NOT EXISTS public.lotes_v2 (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

  producto_id BIGINT NOT NULL REFERENCES public.productos_v2 (id) ON DELETE CASCADE,
  oferta_id BIGINT REFERENCES public.ofertas_proveedor (id) ON DELETE SET NULL,

  numero_lote TEXT,
  cantidad_inicial INT NOT NULL,
  cantidad_actual INT NOT NULL,

  fecha_recepcion DATE,
  fecha_caducidad DATE,

  costo_unitario DECIMAL(10, 2),
  costo_total DECIMAL(10, 2),

  proveedor TEXT,
  activo BOOLEAN DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_lotes_v2_producto ON public.lotes_v2 (producto_id);
CREATE INDEX IF NOT EXISTS idx_lotes_v2_caducidad ON public.lotes_v2 (fecha_caducidad);
CREATE INDEX IF NOT EXISTS idx_lotes_v2_proveedor ON public.lotes_v2 (proveedor);

-- ── TABLA: MOVIMIENTOS DE INVENTARIO
CREATE TABLE IF NOT EXISTS public.movimientos_v2 (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

  producto_id BIGINT NOT NULL REFERENCES public.productos_v2 (id) ON DELETE CASCADE,
  lote_id BIGINT REFERENCES public.lotes_v2 (id) ON DELETE SET NULL,

  tipo TEXT NOT NULL,
  cantidad INT NOT NULL,
  motivo TEXT,

  usuario_id TEXT,
  documento_referencia TEXT
);

CREATE INDEX IF NOT EXISTS idx_movimientos_v2_producto ON public.movimientos_v2 (producto_id);
CREATE INDEX IF NOT EXISTS idx_movimientos_v2_tipo ON public.movimientos_v2 (tipo);
CREATE INDEX IF NOT EXISTS idx_movimientos_v2_fecha ON public.movimientos_v2 (created_at);

-- ── VISTA: MEJOR PRECIO POR PRODUCTO
CREATE OR REPLACE VIEW public.vw_mejor_precio AS
SELECT
  p.id,
  p.codigo_barras,
  p.nombre,
  p.marca,
  p.presentacion,
  p.contenido || ' ' || p.contenido_unidad AS concentracion,
  o.proveedor,
  o.precio_unitario,
  o.fecha_compra,
  ROW_NUMBER() OVER (PARTITION BY p.id ORDER BY o.precio_unitario ASC) AS precio_rank,
  (
    SELECT COALESCE(SUM(l.cantidad_actual), 0)
    FROM public.lotes_v2 l
    WHERE l.producto_id = p.id
      AND l.activo = true
  ) AS stock_disponible
FROM public.productos_v2 p
LEFT JOIN public.ofertas_proveedor o
  ON p.id = o.producto_id
 AND o.vigente = true
WHERE p.activo = true;

-- ── VISTA: COMPARATIVA DE PRECIOS ACTUALES
CREATE OR REPLACE VIEW public.vw_comparativa_precios AS
SELECT
  p.nombre,
  p.marca,
  p.presentacion,
  p.contenido || ' ' || p.contenido_unidad AS concentracion,
  STRING_AGG(DISTINCT o.proveedor, ', ') AS proveedores,
  MIN(o.precio_unitario) AS precio_minimo,
  MAX(o.precio_unitario) AS precio_maximo,
  AVG(o.precio_unitario)::NUMERIC(10, 2) AS precio_promedio,
  COUNT(DISTINCT o.proveedor) AS num_proveedores,
  ROUND(
    (
      (MAX(o.precio_unitario) - MIN(o.precio_unitario))
      / NULLIF(MIN(o.precio_unitario), 0)
      * 100
    )::NUMERIC,
    1
  ) AS pct_diferencia
FROM public.productos_v2 p
LEFT JOIN public.ofertas_proveedor o
  ON p.id = o.producto_id
 AND o.vigente = true
WHERE p.activo = true
GROUP BY
  p.id,
  p.nombre,
  p.marca,
  p.presentacion,
  p.contenido,
  p.contenido_unidad;

-- ── FUNCIÓN: Crear producto con oferta de proveedor
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
      true,
      true,
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
      true,
      true,
      p_producto->>'descripcion'
    )
    RETURNING public.productos_v2.id, public.productos_v2.nombre
    INTO v_producto_id, v_nombre;
  END IF;

  INSERT INTO public.ofertas_proveedor (
    producto_id, proveedor, precio_unitario, precio_total,
    cantidad_disponible, fecha_compra, vigente
  ) VALUES (
    v_producto_id,
    p_proveedor,
    p_precio_unitario,
    p_precio_unitario * p_cantidad,
    p_cantidad,
    p_fecha_compra,
    true
  )
  RETURNING id INTO v_oferta_id;

  IF p_cantidad > 0 THEN
    INSERT INTO public.lotes_v2 (
      producto_id, oferta_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_recepcion, fecha_caducidad, costo_unitario, costo_total, proveedor, activo
    ) VALUES (
      v_producto_id,
      v_oferta_id,
      p_numero_lote,
      p_cantidad,
      p_cantidad,
      p_fecha_compra,
      p_fecha_caducidad,
      p_precio_unitario,
      p_precio_unitario * p_cantidad,
      p_proveedor,
      true
    );
  END IF;

  INSERT INTO public.movimientos_v2 (
    producto_id, tipo, cantidad, motivo, usuario_id
  ) VALUES (
    v_producto_id,
    'entrada',
    p_cantidad,
    'Ingreso de ' || p_proveedor,
    COALESCE(auth.uid()::TEXT, 'sistema')
  );

  RETURN QUERY SELECT v_producto_id, v_nombre::TEXT, 'OK'::TEXT;
END;
$$;

-- ── TRIGGER: updated_at
CREATE OR REPLACE FUNCTION public.update_productos_v2_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_update_productos_v2_updated_at ON public.productos_v2;
CREATE TRIGGER trigger_update_productos_v2_updated_at
  BEFORE UPDATE ON public.productos_v2
  FOR EACH ROW
  EXECUTE FUNCTION public.update_productos_v2_updated_at();

-- ── RLS
ALTER TABLE public.productos_v2 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ofertas_proveedor ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lotes_v2 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimientos_v2 ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS productos_v2_select ON public.productos_v2;
CREATE POLICY productos_v2_select ON public.productos_v2 FOR SELECT USING (true);

DROP POLICY IF EXISTS ofertas_select ON public.ofertas_proveedor;
CREATE POLICY ofertas_select ON public.ofertas_proveedor FOR SELECT USING (true);

DROP POLICY IF EXISTS lotes_v2_select ON public.lotes_v2;
CREATE POLICY lotes_v2_select ON public.lotes_v2 FOR SELECT USING (true);

DROP POLICY IF EXISTS movimientos_v2_select ON public.movimientos_v2;
CREATE POLICY movimientos_v2_select ON public.movimientos_v2 FOR SELECT USING (true);

-- Índices extra
CREATE INDEX IF NOT EXISTS idx_ofertas_precio ON public.ofertas_proveedor (precio_unitario);
CREATE INDEX IF NOT EXISTS idx_lotes_v2_caducidad_activo ON public.lotes_v2 (fecha_caducidad) WHERE activo = true;
CREATE INDEX IF NOT EXISTS idx_productos_v2_activo_visible ON public.productos_v2 (activo, visible_tienda);

GRANT EXECUTE ON FUNCTION public.create_producto_con_oferta(
  jsonb, INT, TEXT, DECIMAL, DATE, TEXT, DATE
) TO anon, authenticated, service_role;

COMMIT;
