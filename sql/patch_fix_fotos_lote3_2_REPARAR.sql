-- ════════════════════════════════════════════════════════════════
-- FIX fotos lote 3 · PASO 2 · REPARACION
-- 2026-08-15
--
-- Saca de circulacion los 9 registros creados solo con la foto del
-- codigo de barras, sin borrar nada (todo queda respaldado en
-- public.fix_lote3_respaldo) y deja lista la funcion de fusion para
-- cuando identifiquemos cada par foto-principal + foto-codigo.
--
-- Abrir desde DISCO · Cmd+A · pegar completo en Supabase.
-- NO copiar desde chat (trunca -> error 42601).
-- Idempotente: se puede correr mas de una vez.
--
-- Las columnas opcionales (visible_tienda, stock_minimo) se aplican
-- solo si existen en la tabla, por eso el UPDATE es dinamico.
-- ════════════════════════════════════════════════════════════════

BEGIN;

-- ── Respaldo completo antes de tocar nada
CREATE TABLE IF NOT EXISTS public.fix_lote3_respaldo (
  id          bigserial PRIMARY KEY,
  creado_en   timestamptz NOT NULL DEFAULT now(),
  motivo      text,
  producto_id bigint,
  sku         text,
  producto    jsonb,
  lotes       jsonb
);

INSERT INTO public.fix_lote3_respaldo (motivo, producto_id, sku, producto, lotes)
SELECT 'cuarentena fotos lote3: EAN sin foto principal',
       p.id, p.sku, to_jsonb(p),
       COALESCE(
         (SELECT jsonb_agg(to_jsonb(l)) FROM public.lotes l WHERE l.producto_id = p.id),
         '[]'::jsonb)
FROM public.productos p
WHERE p.sku IN ('FC-09740435','FC-24901059','FC-49022485','FC-27426982',
                'FC-01165397','FC-01165724','FC-23111202','FC-11784029','FC-09763986')
  AND NOT EXISTS (SELECT 1 FROM public.fix_lote3_respaldo r WHERE r.sku = p.sku);

-- ── Cuarentena: fuera del POS y de la tienda, marcados para revision
DO $fix$
DECLARE
  v_skus text[] := ARRAY['FC-09740435','FC-24901059','FC-49022485','FC-27426982',
                         'FC-01165397','FC-01165724','FC-23111202','FC-11784029','FC-09763986'];
  v_set  text;
  v_n    int;
BEGIN
  v_set := $q$
      nombre = '[REVISAR-EAN] ' || nombre,
      descripcion = COALESCE(NULLIF(btrim(descripcion), '') || ' · ', '')
                    || 'PENDIENTE: registro creado solo con la foto del codigo de barras '
                    || '(lote3 2026-08-15). Falta identificar el producto real. NO VENDER.',
      activo = false$q$;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema = 'public' AND table_name = 'productos'
               AND column_name = 'visible_tienda') THEN
    v_set := v_set || ', visible_tienda = false';
  ELSE
    RAISE NOTICE 'productos.visible_tienda no existe, se omite';
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema = 'public' AND table_name = 'productos'
               AND column_name = 'stock_minimo') THEN
    v_set := v_set || ', stock_minimo = 0';
  ELSE
    RAISE NOTICE 'productos.stock_minimo no existe, se omite';
  END IF;

  EXECUTE format(
    'UPDATE public.productos SET %s WHERE sku = ANY($1) AND nombre NOT LIKE %L',
    v_set, '[REVISAR-EAN]%'
  ) USING v_skus;

  GET DIAGNOSTICS v_n = ROW_COUNT;
  RAISE NOTICE 'Registros puestos en cuarentena: %', v_n;
END $fix$;

-- ── Stock a 0 desactivando sus lotes (el trigger de lotes recalcula
--    productos.stock). Casi siempre es la misma caja ya contada en su
--    producto real, asi que dejarlo activo seria doble conteo.
--    Las cantidades quedan intactas en el lote inactivo.
UPDATE public.lotes l SET activo = false
WHERE l.activo
  AND l.producto_id IN (
    SELECT id FROM public.productos
    WHERE sku IN ('FC-09740435','FC-24901059','FC-49022485','FC-27426982',
                  'FC-01165397','FC-01165724','FC-23111202','FC-11784029','FC-09763986')
  );

-- ── Las dos mitades contrarias: producto correcto pero sin EAN
UPDATE public.productos p SET
  descripcion = COALESCE(NULLIF(btrim(p.descripcion), '') || ' · ', '')
                || 'FALTA EAN: reenviar foto del codigo de barras'
WHERE p.sku IN ('FC-1FFBB505','FC-52D2A43A')
  AND COALESCE(p.descripcion, '') NOT ILIKE '%FALTA EAN%';

COMMIT;


-- ════════════════════════════════════════════════════════════════
-- FUNCION DE FUSION
-- Cuando identifiques a que producto pertenece un EAN huerfano:
--
--   SELECT public.fix_lote3_fusionar('FC-09740435', 'FC-1FFBB505');
--
--   1. Pasa el codigo de barras del fantasma al producto real.
--   2. Copia numero de lote y caducidad al lote del real si le faltan.
--   3. Elimina el fantasma. Su stock se descarta porque es la misma
--      caja ya contada. Si de verdad era mercancia aparte:
--      SELECT public.fix_lote3_fusionar('FC-xxx','FC-yyy', true);
-- ════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.fix_lote3_fusionar(
  p_sku_fantasma text,
  p_sku_real     text,
  p_sumar_stock  boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
AS $fn$
DECLARE
  v_f bigint; v_r bigint;
  v_ean text; v_ean_real text;
  v_lote text; v_cad date;
  v_movidos int := 0;
BEGIN
  SELECT id, codigo_barras INTO v_f, v_ean      FROM public.productos WHERE sku = p_sku_fantasma;
  SELECT id, codigo_barras INTO v_r, v_ean_real FROM public.productos WHERE sku = p_sku_real;

  IF v_f IS NULL THEN RAISE EXCEPTION 'SKU fantasma % no existe', p_sku_fantasma; END IF;
  IF v_r IS NULL THEN RAISE EXCEPTION 'SKU real % no existe', p_sku_real; END IF;
  IF v_f = v_r  THEN RAISE EXCEPTION 'Son el mismo producto'; END IF;
  IF v_ean IS NULL THEN RAISE EXCEPTION '% no tiene codigo de barras que transferir', p_sku_fantasma; END IF;
  IF v_ean_real IS NOT NULL AND v_ean_real <> v_ean THEN
    RAISE EXCEPTION 'El producto % ya tiene EAN % distinto de %. Revisar a mano.',
      p_sku_real, v_ean_real, v_ean;
  END IF;

  INSERT INTO public.fix_lote3_respaldo (motivo, producto_id, sku, producto, lotes)
  SELECT 'fusion hacia ' || p_sku_real, p.id, p.sku, to_jsonb(p),
         COALESCE(
           (SELECT jsonb_agg(to_jsonb(l)) FROM public.lotes l WHERE l.producto_id = p.id),
           '[]'::jsonb)
  FROM public.productos p WHERE p.id = v_f;

  -- lote y caducidad que venian en la foto del codigo de barras
  SELECT l.numero_lote, l.fecha_caducidad INTO v_lote, v_cad
  FROM public.lotes l WHERE l.producto_id = v_f ORDER BY l.id LIMIT 1;

  -- codigo_barras es UNIQUE: liberar el del fantasma antes de asignarlo
  UPDATE public.productos SET codigo_barras = NULL  WHERE id = v_f;
  UPDATE public.productos SET codigo_barras = v_ean WHERE id = v_r;

  UPDATE public.lotes l SET
    numero_lote     = COALESCE(NULLIF(btrim(l.numero_lote), ''), v_lote, l.numero_lote),
    fecha_caducidad = COALESCE(l.fecha_caducidad, v_cad)
  WHERE l.producto_id = v_r;

  IF p_sumar_stock THEN
    UPDATE public.lotes SET producto_id = v_r, activo = true WHERE producto_id = v_f;
    GET DIAGNOSTICS v_movidos = ROW_COUNT;
    IF to_regclass('public.movimientos_inventario') IS NOT NULL THEN
      EXECUTE 'UPDATE public.movimientos_inventario SET producto_id = $1 WHERE producto_id = $2'
        USING v_r, v_f;
    END IF;
  END IF;

  BEGIN
    DELETE FROM public.productos WHERE id = v_f;
  EXCEPTION WHEN foreign_key_violation THEN
    UPDATE public.productos SET activo = false WHERE id = v_f;
    IF EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_schema = 'public' AND table_name = 'productos'
                 AND column_name = 'visible_tienda') THEN
      EXECUTE 'UPDATE public.productos SET visible_tienda = false WHERE id = $1' USING v_f;
    END IF;
  END;

  UPDATE public.productos SET
    stock = (SELECT COALESCE(SUM(cantidad_actual), 0)
             FROM public.lotes WHERE producto_id = v_r AND activo)
  WHERE id = v_r;

  RETURN jsonb_build_object(
    'ok', true, 'sku_real', p_sku_real, 'ean_asignado', v_ean,
    'numero_lote', v_lote, 'caducidad', v_cad, 'lotes_movidos', v_movidos);
END;
$fn$;

GRANT EXECUTE ON FUNCTION public.fix_lote3_fusionar(text, text, boolean) TO authenticated;


-- ════════════════════════════════════════════════════════════════
-- VERIFICACION (ultimo SELECT: es el que muestra Supabase)
-- ════════════════════════════════════════════════════════════════

SELECT p.sku, p.nombre, p.codigo_barras, p.stock, p.activo,
       CASE WHEN p.codigo_barras IS NULL THEN 'falta EAN'
            ELSE 'falta identificar producto' END AS pendiente
FROM public.productos p
WHERE p.nombre LIKE '[REVISAR-EAN]%'
   OR p.descripcion ILIKE '%FALTA EAN%'
ORDER BY pendiente, p.sku;
