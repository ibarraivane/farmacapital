-- Costo de compra = primera compra (quién + precio).
-- Recibir solo lo pisa si el ticket nuevo es más barato.

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

DROP TRIGGER IF EXISTS trg_lotes_ultima_compra ON public.lotes;
CREATE TRIGGER trg_lotes_ultima_compra
AFTER INSERT ON public.lotes
FOR EACH ROW
EXECUTE PROCEDURE public.fc_registrar_ultima_compra_lote();
