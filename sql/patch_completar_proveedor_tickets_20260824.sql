-- Completar quién se compró (Farma City / Farmalive / Levic / …) desde los
-- tickets de Recibir. No borra historial: solo inserta filas nuevas.
-- También rellena lotes.proveedor_id vacíos y el trigger de última compra
-- para que un lote con proveedor complete el nombre sin subir el costo.

BEGIN;

INSERT INTO public.fuentes_precio (id, nombre, tipo, metodo, notas) VALUES
  ('ultima_compra', 'Costo de compra', 'compra', 'manual',
   'Primera compra (quién + precio). Recibir solo lo pisa si el ticket es más barato.')
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  tipo = EXCLUDED.tipo,
  metodo = EXCLUDED.metodo,
  notas = EXCLUDED.notas;

CREATE OR REPLACE FUNCTION public.fc_registrar_ultima_compra_lote()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_nombre text;
  v_precio_act numeric;
  v_quien_act text;
BEGIN
  IF NEW.costo_unitario IS NULL OR NEW.costo_unitario <= 0 OR NEW.producto_id IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.proveedor_id IS NOT NULL THEN
    SELECT nombre INTO v_nombre FROM public.proveedores WHERE id = NEW.proveedor_id;
  END IF;
  v_nombre := NULLIF(btrim(v_nombre), '');

  SELECT a.precio, NULLIF(btrim(a.nombre_fuente), '')
    INTO v_precio_act, v_quien_act
  FROM public.producto_precios_referencia_actual a
  WHERE a.producto_id = NEW.producto_id
    AND a.fuente = 'ultima_compra'
    AND a.precio IS NOT NULL
    AND a.precio > 0
  LIMIT 1;

  IF v_precio_act IS NOT NULL AND NEW.costo_unitario >= v_precio_act - 0.005 THEN
    IF v_quien_act IS NULL AND v_nombre IS NOT NULL THEN
      INSERT INTO public.producto_precios_referencia (
        producto_id, fuente, tipo, precio, fecha, nombre_fuente,
        confianza, origen, notas
      ) VALUES (
        NEW.producto_id,
        'ultima_compra',
        'compra',
        v_precio_act,
        COALESCE(NEW.created_at::date, CURRENT_DATE),
        v_nombre,
        100,
        'manual',
        'completar quien sin subir precio'
      );
    END IF;
    RETURN NEW;
  END IF;

  INSERT INTO public.producto_precios_referencia (
    producto_id, fuente, tipo, precio, fecha, nombre_fuente,
    confianza, origen, notas
  ) VALUES (
    NEW.producto_id,
    'ultima_compra',
    'compra',
    NEW.costo_unitario,
    COALESCE(NEW.created_at::date, CURRENT_DATE),
    v_nombre,
    100,
    'manual',
    'lote recepcion'
  );

  RETURN NEW;
END;
$$;

-- Ticket más reciente con nombre, por producto.
CREATE TEMP TABLE _ticket_quien ON COMMIT DROP AS
SELECT DISTINCT ON (i.producto_id)
  i.producto_id,
  NULLIF(btrim(r.proveedor), '') AS proveedor,
  r.folio,
  r.fecha,
  i.costo_estimado
FROM public.recepcion_items i
JOIN public.recepciones r ON r.id = i.recepcion_id
WHERE i.confirmado
  AND NOT COALESCE(i.pendiente_alta, false)
  AND i.producto_id IS NOT NULL
  AND NULLIF(btrim(r.proveedor), '') IS NOT NULL
  AND lower(btrim(r.proveedor)) <> 'sin proveedor'
ORDER BY i.producto_id, r.fecha DESC NULLS LAST, r.id DESC;

-- Costo más barato del ticket (para productos sin fila ultima_compra).
CREATE TEMP TABLE _ticket_costo ON COMMIT DROP AS
SELECT DISTINCT ON (i.producto_id)
  i.producto_id,
  i.costo_estimado AS precio,
  NULLIF(btrim(r.proveedor), '') AS proveedor,
  r.folio,
  r.fecha
FROM public.recepcion_items i
JOIN public.recepciones r ON r.id = i.recepcion_id
WHERE i.confirmado
  AND NOT COALESCE(i.pendiente_alta, false)
  AND i.producto_id IS NOT NULL
  AND i.costo_estimado IS NOT NULL
  AND i.costo_estimado > 0
ORDER BY i.producto_id, i.costo_estimado ASC, r.fecha DESC NULLS LAST;

-- 1) Ya hay costo vigente sin quién: se queda el precio y se pone el ticket.
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
SELECT
  a.producto_id,
  'ultima_compra',
  'compra',
  a.precio,
  CURRENT_DATE,
  t.proveedor,
  100,
  'manual',
  concat_ws(' · ', 'ticket ' || NULLIF(btrim(t.folio), ''), 'completar quien')
FROM public.producto_precios_referencia_actual a
JOIN _ticket_quien t ON t.producto_id = a.producto_id
WHERE a.fuente = 'ultima_compra'
  AND a.precio IS NOT NULL
  AND a.precio > 0
  AND (
    NULLIF(btrim(a.nombre_fuente), '') IS NULL
    OR lower(btrim(a.nombre_fuente)) = 'sin proveedor'
  );

-- 2) Nunca se registró ultima_compra: entra el ticket más barato con quién.
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
SELECT
  t.producto_id,
  'ultima_compra',
  'compra',
  round(t.precio, 2),
  CURRENT_DATE,
  t.proveedor,
  100,
  'manual',
  concat_ws(' · ', 'ticket ' || NULLIF(btrim(t.folio), ''), 'desde recepcion')
FROM _ticket_costo t
WHERE t.proveedor IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM public.producto_precios_referencia_actual a
    WHERE a.producto_id = t.producto_id
      AND a.fuente = 'ultima_compra'
      AND a.precio IS NOT NULL
      AND a.precio > 0
  );

-- 3) Lotes viejos sin proveedor_id: el del ticket más reciente del mismo producto.
DO $$
BEGIN
  IF to_regprocedure('public.fc_resolver_proveedor_tienda(text)') IS NULL THEN
    RETURN;
  END IF;
  UPDATE public.lotes l
  SET proveedor_id = public.fc_resolver_proveedor_tienda(t.proveedor)
  FROM _ticket_quien t
  WHERE l.producto_id = t.producto_id
    AND l.proveedor_id IS NULL
    AND t.proveedor IS NOT NULL
    AND public.fc_resolver_proveedor_tienda(t.proveedor) IS NOT NULL;
END $$;

COMMIT;
