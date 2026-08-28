-- Referencias de venta nuevas, verificadas con el comparador corregido
-- Generado 2026-08-15 · fuente: API de Farmacias Similares (VTEX)
--
-- Solo productos que hoy NO tienen ninguna referencia. Cada una trae el nombre del
-- producto competidor y el detalle de que se verifico, para que se pueda auditar.
--
-- De 391 productos consultados, 49 dieron match y 40 aguantaron la revision final.
-- De esos, 6 son de productos sin referencia previa: es la ganancia de cobertura.
--
-- Descartados en la revision final, por si dudas del criterio:
--   Talco Rexona y Talco Mennen -> OXIDO DE ZINC PASTA (un talco no es una pasta)
--   Lidocaina unguento          -> NAPROXENO/LIDOCAINA (el suyo trae naproxeno de mas)
--   Supratex levodropropizina   -> LEVODROPROPIZINA/AMBROXOL (trae ambroxol de mas)
--   Sedalmerck C/20             -> AGRIFEN con cafeina 25 mg (el nuestro trae 50 mg)

BEGIN;

INSERT INTO importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
VALUES ('similares', 'venta', '2026-08-15', 'job_vtex_similares_verificado', 6,
        'sync_precios_similares.py --solo-verificables · umbral 85 · reglas: activo faltante o sobrante descalifica, concentracion por subconjunto, formas por familia');

INSERT INTO producto_precios_referencia
  (producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, import_id, notas)
SELECT v.producto_id, 'similares', 'venta', v.precio, '2026-08-15'::date, v.nombre_fuente,
       v.confianza, 'job_vtex', (select max(id) from importaciones_referencia), v.notas
FROM (VALUES
  (476, 51.00, 'METAMIZOL SODICO  5G/100ML JARABE 120ML  1 PIEZA', 100, 'piezas_fuente:1 | termino:metamizol sodico 100ml | principios activos completos; concentracion coincide; forma coincide'),
  (777, 103.00, 'REPELENTE INSEC(DEET 15%) 170GR AEROSOL 1 PIEZA', 100, 'piezas_fuente:1 | termino:deet | principios activos completos; concentracion coincide; forma coincide'),
  (731, 23.00, 'VASELINA PARA BEBE 60 GR 1 PIEZA', 98, 'piezas_fuente:1 | termino:vaselina | principios activos completos; concentracion coincide'),
  (750, 66.00, 'LEVODROPROPIZINA SOLUCION 120 ML 1 PIEZA', 92, 'piezas_fuente:1 | termino:levodropropizina 120ml | principios activos completos; concentracion coincide; forma equivalente jarabe~solucion'),
  (675, 49.00, 'BIFONAZOL UNGÜENTO 20 GR 1 PIEZA', 92, 'piezas_fuente:1 | termino:bifonazol | principios activos completos; concentracion coincide; forma equivalente crema~unguento'),
  (598, 34.00, 'TERBINAFINA CLORHIDRATO CREMA 15 GR 1 PIEZA', 85, 'piezas_fuente:1 | termino:terbinafina | principios activos completos; concentracion coincide; forma equivalente gel~crema')
) AS v(producto_id, precio, nombre_fuente, confianza, notas)
WHERE NOT EXISTS (
  SELECT 1 FROM producto_precios_referencia r
  WHERE r.producto_id = v.producto_id AND r.tipo = 'venta' AND r.fuente = 'similares'
    AND r.fecha = '2026-08-15'
);

COMMIT;

select fuente, count(*) refs, count(nombre_fuente) con_evidencia, round(avg(confianza)) conf_prom
from producto_precios_referencia where tipo='venta' group by fuente;
