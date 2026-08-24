-- Última compra = precio pagado en Recibir (no lista de proveedor).
-- La UI lee fuente 'ultima_compra' en producto_precios_referencia.

INSERT INTO public.fuentes_precio (id, nombre, tipo, metodo, notas) VALUES
  ('ultima_compra', 'Última compra', 'compra', 'manual',
   'Precio pagado en el último ticket de Recibir. No es lista.')
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
BEGIN
  IF NEW.costo_unitario IS NULL OR NEW.costo_unitario <= 0 OR NEW.producto_id IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.proveedor_id IS NOT NULL THEN
    SELECT nombre INTO v_nombre FROM public.proveedores WHERE id = NEW.proveedor_id;
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
    NULLIF(btrim(v_nombre), ''),
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
