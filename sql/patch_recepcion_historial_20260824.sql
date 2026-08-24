-- Historia de compras — pestaña Historia dentro de Recibir.
-- Devuelve los tickets ya recibidos y sus renglones para armar la tabla
-- producto (filas) × ticket (columnas) con el costo de cada compra.
-- Solo lee: no toca stock, costos ni referencias.

BEGIN;

CREATE OR REPLACE FUNCTION public.recepcion_historial(
  p_session_token uuid,
  p_limite integer DEFAULT 40
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user bigint;
  v_lim  integer := least(greatest(coalesce(p_limite, 40), 1), 200);
  v_ids  bigint[];
  v_tickets jsonb;
  v_renglones jsonb;
BEGIN
  v_user := public.fn_require_empleado(p_session_token);

  -- Tickets que ya entraron: al menos un renglón confirmado y con producto.
  SELECT array_agg(t.id ORDER BY t.fecha DESC, t.id DESC)
    INTO v_ids
  FROM (
    SELECT r.id, r.fecha
    FROM public.recepciones r
    WHERE EXISTS (
      SELECT 1 FROM public.recepcion_items i
      WHERE i.recepcion_id = r.id
        AND i.confirmado
        AND NOT i.pendiente_alta
        AND i.producto_id IS NOT NULL
        AND i.costo_estimado IS NOT NULL
        AND i.costo_estimado > 0
    )
    ORDER BY r.fecha DESC, r.id DESC
    LIMIT v_lim
  ) t;

  IF v_ids IS NULL OR cardinality(v_ids) = 0 THEN
    RETURN jsonb_build_object('tickets', '[]'::jsonb, 'renglones', '[]'::jsonb);
  END IF;

  SELECT coalesce(jsonb_agg(row_to_json(x)::jsonb ORDER BY x.fecha DESC, x.id DESC), '[]'::jsonb)
    INTO v_tickets
  FROM (
    SELECT
      r.id,
      r.proveedor,
      r.folio,
      r.fecha,
      r.total_ticket,
      r.estado,
      count(i.id)::int                        AS renglones,
      coalesce(sum(i.cantidad), 0)::int       AS piezas,
      coalesce(sum(i.cantidad * i.costo_estimado), 0)::numeric(12,2) AS importe
    FROM public.recepciones r
    JOIN public.recepcion_items i ON i.recepcion_id = r.id
    WHERE r.id = ANY(v_ids)
      AND i.confirmado
      AND NOT i.pendiente_alta
      AND i.producto_id IS NOT NULL
      AND i.costo_estimado IS NOT NULL
      AND i.costo_estimado > 0
    GROUP BY r.id, r.proveedor, r.folio, r.fecha, r.total_ticket, r.estado
  ) x;

  -- Un renglón por producto y ticket: si el mismo producto se capturó en
  -- varias líneas del mismo ticket, se suma la cantidad y se toma el costo
  -- más barato de esas líneas.
  SELECT coalesce(jsonb_agg(row_to_json(y)::jsonb), '[]'::jsonb)
    INTO v_renglones
  FROM (
    SELECT
      i.recepcion_id,
      i.producto_id,
      coalesce(p.sku, '')                              AS sku,
      coalesce(p.nombre, max(i.nombre_snapshot), '')   AS nombre,
      sum(i.cantidad)::int                             AS cantidad,
      min(i.costo_estimado)::numeric(12,2)             AS costo
    FROM public.recepcion_items i
    LEFT JOIN public.productos p ON p.id = i.producto_id
    WHERE i.recepcion_id = ANY(v_ids)
      AND i.confirmado
      AND NOT i.pendiente_alta
      AND i.producto_id IS NOT NULL
      AND i.costo_estimado IS NOT NULL
      AND i.costo_estimado > 0
    GROUP BY i.recepcion_id, i.producto_id, p.sku, p.nombre
  ) y;

  RETURN jsonb_build_object('tickets', v_tickets, 'renglones', v_renglones);
END;
$$;

GRANT EXECUTE ON FUNCTION public.recepcion_historial(uuid, integer) TO anon, authenticated;

COMMENT ON FUNCTION public.recepcion_historial(uuid, integer) IS
  'Historia de compras: tickets recibidos y su costo por producto. Solo lectura.';

COMMIT;
