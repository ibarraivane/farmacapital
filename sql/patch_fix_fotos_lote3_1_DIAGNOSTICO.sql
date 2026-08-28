-- ════════════════════════════════════════════════════════════════
-- FIX fotos lote 3 · PASO 1 · DIAGNOSTICO (solo lecturas)
-- 2026-08-15
--
-- Problema: en el lote 3, nueve fotos de codigo de barras se
-- procesaron como productos independientes en vez de fusionarse con
-- su foto principal. Quedaron 9 registros con nombre inventado
-- ("Producto <lab> Reg. XXX") y 2 productos reales sin EAN.
--
-- Abrir desde DISCO · Cmd+A · pegar completo en Supabase.
-- NO copiar desde chat (trunca -> error 42601).
-- Es un solo SELECT: Supabase muestra todo en una sola tabla.
-- ════════════════════════════════════════════════════════════════

WITH fantasmas AS (
  SELECT p.id, p.sku, p.nombre, p.codigo_barras, p.stock, p.activo,
         p.created_at, left(p.codigo_barras, 8) AS prefijo
  FROM public.productos p
  WHERE p.sku IN ('FC-09740435','FC-24901059','FC-49022485','FC-27426982',
                  'FC-01165397','FC-01165724','FC-23111202','FC-11784029','FC-09763986')
),
huerfanos AS (
  SELECT p.id, p.sku, p.nombre, p.codigo_barras, p.stock
  FROM public.productos p
  WHERE p.sku IN ('FC-1FFBB505','FC-52D2A43A')
     OR (p.codigo_barras IS NULL AND p.descripcion ILIKE '%EAN pendiente%')
),
todo AS (
  -- 1 · Los 9 registros basura. Si "creado" es anterior a 2026-08-15
  --     significa que el patch RENOMBRO un producto que ya existia:
  --     ese nombre bueno se perdio y hay que recuperarlo (ver paso 1b).
  SELECT 1 AS orden, 'FANTASMA (EAN sin foto principal)' AS seccion,
         f.sku, f.nombre, f.codigo_barras, f.stock, f.activo,
         CASE WHEN f.created_at < '2026-08-15'::date
              THEN 'OJO: producto preexistente RENOMBRADO el ' || f.created_at::date
              ELSE 'creado nuevo por el patch' END AS detalle
  FROM fantasmas f

  UNION ALL

  -- 2 · La otra mitad: productos con nombre correcto pero sin codigo
  SELECT 2, 'HUERFANO (nombre sin EAN)',
         h.sku, h.nombre, h.codigo_barras, h.stock, true,
         'Le falta la foto del codigo de barras'
  FROM huerfanos h

  UNION ALL

  -- 3 · Candidatos a fusion: productos del mismo laboratorio (mismo
  --     prefijo GS1 de 8 digitos) que el EAN huerfano. Cruzar con las
  --     fotos para armar el par correcto.
  SELECT 3, 'CANDIDATO para ' || f.sku || ' (EAN ' || f.codigo_barras || ')',
         p.sku, p.nombre, p.codigo_barras, p.stock, p.activo,
         'Mismo prefijo GS1 ' || f.prefijo
  FROM fantasmas f
  JOIN public.productos p
    ON left(p.codigo_barras, 8) = f.prefijo
   AND p.id <> f.id

  UNION ALL

  -- 4 · Duplicado conocido: ML-PRIM quedo con dos EAN distintos
  SELECT 4, 'DUPLICADO ML-PRIM',
         p.sku, p.nombre, p.codigo_barras, p.stock, p.activo,
         'Solo uno de los dos EAN puede ser correcto'
  FROM public.productos p
  WHERE p.nombre ILIKE '%ML-PRIM%'
     OR p.codigo_barras IN ('7502227427392','7502211784029')

  UNION ALL

  -- 5 · Resumen de stock en riesgo (posible doble conteo)
  SELECT 5, 'RESUMEN', '-', 'Piezas en registros fantasma', NULL,
         (SELECT COALESCE(SUM(stock), 0)::int FROM fantasmas), true,
         'Si son duplicados, este stock esta contado dos veces'
)
SELECT seccion, sku, nombre, codigo_barras, stock, activo, detalle
FROM todo
ORDER BY orden, seccion, sku;


-- ════════════════════════════════════════════════════════════════
-- PASO 1b (OPCIONAL) · Recuperar nombres sobrescritos
-- Correr SOLO si en la seccion FANTASMA aparecio "producto
-- preexistente RENOMBRADO". Requiere audit_log_detallado.
-- Seleccionar unicamente este bloque y ejecutarlo aparte.
-- ════════════════════════════════════════════════════════════════
-- SELECT a.registro_id, a.created_at,
--        a.valores_antes->>'nombre'        AS nombre_original,
--        a.valores_despues->>'nombre'      AS nombre_actual,
--        a.valores_antes->>'codigo_barras' AS ean_original
-- FROM public.audit_log_detallado a
-- JOIN public.productos p ON p.id::text = a.registro_id
-- WHERE a.tabla = 'productos'
--   AND a.operacion = 'UPDATE'
--   AND p.sku IN ('FC-09740435','FC-24901059','FC-49022485','FC-27426982',
--                 'FC-01165397','FC-01165724','FC-23111202','FC-11784029','FC-09763986')
--   AND a.valores_antes->>'nombre' IS DISTINCT FROM a.valores_despues->>'nombre'
-- ORDER BY a.created_at DESC;
