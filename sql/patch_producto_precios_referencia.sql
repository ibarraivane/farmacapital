-- ════════════════════════════════════════════════════════════════
-- Referencias de precio (compra + venta) — historial normalizado
-- Ejecutar en Supabase SQL Editor (Fase 0)
-- ════════════════════════════════════════════════════════════════

BEGIN;

-- Catálogo de fuentes (extensible sin migración de columnas)
CREATE TABLE IF NOT EXISTS public.fuentes_precio (
  id          TEXT PRIMARY KEY,
  nombre      TEXT NOT NULL,
  tipo        TEXT NOT NULL CHECK (tipo IN ('compra', 'venta')),
  metodo      TEXT NOT NULL DEFAULT 'import_archivo'
    CHECK (metodo IN ('import_archivo', 'job_api', 'manual')),
  activo      BOOLEAN NOT NULL DEFAULT true,
  notas       TEXT
);

INSERT INTO public.fuentes_precio (id, nombre, tipo, metodo, notas) VALUES
  ('exprezo',   'Exprezo (Zorro)',              'compra', 'import_archivo', 'Mayoreo — subir CSV exportado de la app'),
  ('marzam',    'Marzam',                       'compra', 'import_archivo', 'Precio lista distribuidor (no benchmark de mercado libre)'),
  ('nadro',     'Nadro',                        'compra', 'import_archivo', 'Precio lista distribuidor (no benchmark de mercado libre)'),
  ('levic',     'Levic',                        'compra', 'import_archivo', 'Medicamentos — entrega a domicilio'),
  ('similares', 'Farmacias Similares',          'venta',  'job_api',        'Job VTEX semanal'),
  ('fahorro',   'Farmacias del Ahorro',         'venta',  'manual',         'Captura manual / CSV hasta confirmar API')
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  tipo = EXCLUDED.tipo,
  metodo = EXCLUDED.metodo,
  notas = EXCLUDED.notas;

CREATE TABLE IF NOT EXISTS public.importaciones_referencia (
  id           BIGSERIAL PRIMARY KEY,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  fuente       TEXT NOT NULL REFERENCES public.fuentes_precio (id),
  tipo         TEXT NOT NULL CHECK (tipo IN ('compra', 'venta')),
  fecha_lista  DATE NOT NULL DEFAULT CURRENT_DATE,
  archivo      TEXT,
  filas_ok     INT NOT NULL DEFAULT 0,
  filas_error  INT NOT NULL DEFAULT 0,
  notas        TEXT
);

CREATE TABLE IF NOT EXISTS public.producto_precios_referencia (
  id            BIGSERIAL PRIMARY KEY,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  producto_id   BIGINT NOT NULL REFERENCES public.productos (id) ON DELETE CASCADE,
  fuente        TEXT NOT NULL REFERENCES public.fuentes_precio (id),
  tipo          TEXT NOT NULL CHECK (tipo IN ('compra', 'venta')),

  precio        NUMERIC(12, 2) NOT NULL CHECK (precio >= 0),
  moneda        TEXT NOT NULL DEFAULT 'MXN',
  fecha         DATE NOT NULL DEFAULT CURRENT_DATE,

  nombre_fuente TEXT,
  sku_externo   TEXT,
  confianza     SMALLINT CHECK (confianza IS NULL OR (confianza >= 0 AND confianza <= 100)),
  origen        TEXT NOT NULL DEFAULT 'import_csv'
    CHECK (origen IN ('import_csv', 'job_vtex', 'manual')),
  import_id     BIGINT REFERENCES public.importaciones_referencia (id) ON DELETE SET NULL,

  notas         TEXT
);

CREATE INDEX IF NOT EXISTS idx_ppr_producto_fuente_fecha
  ON public.producto_precios_referencia (producto_id, fuente, fecha DESC, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_ppr_fuente_fecha
  ON public.producto_precios_referencia (fuente, fecha DESC);

CREATE INDEX IF NOT EXISTS idx_ppr_import
  ON public.producto_precios_referencia (import_id)
  WHERE import_id IS NOT NULL;

-- Precio vigente = fila más reciente por producto + fuente
CREATE OR REPLACE VIEW public.producto_precios_referencia_actual AS
SELECT DISTINCT ON (producto_id, fuente)
  id,
  producto_id,
  fuente,
  tipo,
  precio,
  moneda,
  fecha,
  nombre_fuente,
  sku_externo,
  confianza,
  origen,
  import_id,
  notas,
  created_at
FROM public.producto_precios_referencia
ORDER BY producto_id, fuente, fecha DESC, created_at DESC;

COMMENT ON VIEW public.producto_precios_referencia_actual IS
  'Última referencia de precio por producto y fuente (DISTINCT ON).';

-- RLS: lectura pública (como productos); escritura abierta para RPC/scripts con service role
ALTER TABLE public.fuentes_precio ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.importaciones_referencia ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.producto_precios_referencia ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS fuentes_precio_select ON public.fuentes_precio;
CREATE POLICY fuentes_precio_select ON public.fuentes_precio FOR SELECT USING (true);

DROP POLICY IF EXISTS importaciones_referencia_select ON public.importaciones_referencia;
CREATE POLICY importaciones_referencia_select ON public.importaciones_referencia FOR SELECT USING (true);

DROP POLICY IF EXISTS importaciones_referencia_insert ON public.importaciones_referencia;
CREATE POLICY importaciones_referencia_insert ON public.importaciones_referencia FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS ppr_select ON public.producto_precios_referencia;
CREATE POLICY ppr_select ON public.producto_precios_referencia FOR SELECT USING (true);

DROP POLICY IF EXISTS ppr_insert ON public.producto_precios_referencia;
CREATE POLICY ppr_insert ON public.producto_precios_referencia FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS ppr_update ON public.producto_precios_referencia;
CREATE POLICY ppr_update ON public.producto_precios_referencia FOR UPDATE USING (true);

GRANT SELECT ON public.producto_precios_referencia_actual TO anon, authenticated;
GRANT SELECT, INSERT ON public.producto_precios_referencia TO anon, authenticated;
GRANT SELECT, INSERT ON public.importaciones_referencia TO anon, authenticated;
GRANT SELECT ON public.fuentes_precio TO anon, authenticated;

COMMIT;
