-- Completar el «quién» de la columna Costo desde los tickets ya recibidos.
--
-- 485 productos muestran «sin proveedor» porque su referencia de compra
-- nunca guardó el nombre de la tienda. Ahora la Historia sí sabe dónde se
-- compró cada uno, así que se puede rellenar.
--
-- NO cambia ningún precio: copia el costo vigente tal cual y solo le agrega
-- el nombre. De los tickets donde aparece el producto se elige aquel cuyo
-- costo se parece más al vigente, que es el que le dio ese precio.
--
-- Es re-ejecutable: un producto que ya tiene tienda no entra.

BEGIN;

WITH sin_quien AS (
  SELECT a.producto_id, a.precio
  FROM public.producto_precios_referencia_actual a
  WHERE a.fuente = 'ultima_compra'
    AND a.precio IS NOT NULL
    AND a.precio > 0
    AND coalesce(btrim(a.nombre_fuente), '') = ''
),
elegido AS (
  SELECT DISTINCT ON (s.producto_id)
    s.producto_id,
    s.precio,
    btrim(r.proveedor) AS proveedor,
    r.folio
  FROM sin_quien s
  JOIN public.recepcion_items i
    ON i.producto_id = s.producto_id
   AND i.confirmado
   AND NOT i.pendiente_alta
   AND i.costo_estimado IS NOT NULL
   AND i.costo_estimado > 0
  JOIN public.recepciones r
    ON r.id = i.recepcion_id
   AND coalesce(btrim(r.proveedor), '') <> ''
  ORDER BY s.producto_id, abs(i.costo_estimado - s.precio), i.costo_estimado, r.fecha
)
INSERT INTO public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas)
SELECT
  e.producto_id, 'ultima_compra', 'compra',
  e.precio,                       -- el mismo costo: esto no encarece nada
  CURRENT_DATE,
  e.proveedor,
  100, 'manual',
  'completar quien desde ticket ' || coalesce(e.folio, 's/folio')
FROM elegido e;

COMMIT;

-- Cómo quedó la columna Costo.
SELECT
  count(*)                                                          AS con_costo,
  count(*) FILTER (WHERE coalesce(btrim(nombre_fuente), '') <> '')   AS con_tienda,
  count(*) FILTER (WHERE coalesce(btrim(nombre_fuente), '') = '')    AS sin_tienda
FROM public.producto_precios_referencia_actual
WHERE fuente = 'ultima_compra' AND precio > 0;
