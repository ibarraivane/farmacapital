-- Referencias venta Claude · solo confianza alta/media · sin hash-SKUs
-- Tabla correcta: producto_precios_referencia (NO referencias_precios)
-- Ejecutar DESPUÉS de patch_producto_precios_referencia.sql
-- Filas: 207 de 462 originales

BEGIN;

INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 84.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · GEL LUBRICANTE VAGINAL 113GR.. (Score: 67%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-01015141'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 84.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 28.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Vicks Vaporub pomada 12g - precio base', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-01246730'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 28.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 61.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Fasiclor Cefaclor 125mg suspensión 75ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-01B2F362'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 61.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'fahorro', 'venta', 175.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Vicks Vaporub ungüento 100g', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-02012475'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'fahorro'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 175.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 62.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Valclan 500/125mg (12 en lugar de 10)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-022543CD'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 62.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 74.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · ESCITALOPRAM 10MG 14TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-04D83B46'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 74.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 54.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMOXICILINA/BROM 250MG SUSP 60ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-05965071'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 54.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-06209862'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 69.01, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · DESODORANTE AER CAB 150ML OLD SPICE.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-06213906'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 69.01
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-06244795'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-06245686'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 79.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CEFTRIAXONA 1GR 1AMP.. (Score: 71%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-07F04F88'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 79.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 36.59, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Lactopram 430MG C/20', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-08344488'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 36.59
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 53.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Afrodit 400 UI - 30 cápsulas', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-08344747'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 53.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 109.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Flanax Gel 40g (Naproxeno 5.5%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-08426944'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 109.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 308.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Alka-Seltzer C/100 - precio base recomendado', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-08443026'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 308.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 132.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · SALES DE POTASIO 50TAB  EFERVESCENTES.. (Score: 68%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-08485316'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 132.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 97.89, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Vitau.mx - Aspirina 500mg genérica 40 tabletas (tu presentación es 80)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-08491074'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 97.89
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 128.9, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Cafiaspirina Tar C/100', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-08491096'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 128.9
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 36.38, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · ACIDO ACETILSALICILICO 500MG 12 TABLETAS EFERVESCENTES ASPIRINA -- coincidencia exacta de marca, mg y cantidad.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-08496701'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 36.38
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 25.5, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Match generico: DEXPANTENOL 5/100GR CREMA 30GR SIMIBABY (equivalente generico de Bepanthen Multiusos Pomada, misma concentracion 5% y mismo tamano 30g)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-08498798'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 25.5
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 19.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · OXIDO DE ZINC 25GR/100GR 30GR.. (Score: 74%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-0ACC5B6A'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 19.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 117.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Clamoxin 600/42.9mg suspensión 50ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-0E0A9E42'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 117.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 56.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · JABON DE AZUFRE CON LANOLINA 100GR.. (Score: 67%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-14119032'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 56.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 24.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AC ACETILSALICILICO 100MG AD 30COMP.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-17376CAE'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 24.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 17.5, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · FLUOCINOLONA CREMA 20GR.. (Score: 82%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-1BF03D35'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 17.5
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 56.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · BETAMETASONA DIP/BETA FOS 1AMP.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-1CF27DC9'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 56.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 18.75, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Confirmado por fuente externa que Cloxan = Ambroxol 30mg; match exacto AMBROXOL 30 MG 20 COMPRIMIDOS, misma cantidad de piezas (20)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-1DA570E3'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 18.75
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 38.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Amikacina 500mg/2ml ampolleta', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-1FEA2FB7'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 38.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 84.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · LEVODROP/AMBROX 0.6/0.3GR/100ML SOL120ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-1FFBB505'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 84.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 94.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMPICILINA/MET/GUA/CLO AD 3AMP+3JER.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-2001A890'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 94.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 88.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · CEFOTAXIMA 1GR SOL INY.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-22B18244'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 88.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 99.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Similares: búsqueda por categoría Producto. Precio base estimado.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-23001331'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 99.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 25.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Silica Shine/Nat Gloss 120ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-24511711'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 25.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 65.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Similares: búsqueda limitada por Electrolit. Precio estimado.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-25104268'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 65.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 23.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · AGRIFEN CLORFENAMINA 10TAB.. (Score: 67%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-25116810'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 23.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 80.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Irbesartán 150mg', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-262F2A30'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 80.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 26.9, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Chupón Ternura Ortodóntico 3Pack Miel - AlSuper. SKU exacto no verificado en catálogos públicos.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-26462061'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 26.9
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 79.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TOBRAMICINA/DEXAMET 5ML SOL OFT.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-26EA40A4'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 79.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 69.01, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · DESODORANTE AER CAB 150ML OLD SPICE.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-27250612'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 69.01
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-27286017'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 24.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · HIDROCLOROTIAZIDA 25MG 20TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-28A424E5'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 24.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 60.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · CETIRIZINA 10MG 10TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-29670370'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 60.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 93.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · HIERRO DEXTRAN 100MG/2ML 3AMP.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-2E79C2D8'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 93.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 127.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Cefagen Cefalexina tabletas', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-2EDC6E3B'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 127.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 57.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Similares: búsqueda por categoría Otro. Precio base estimado.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-30133021'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 57.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-30622622'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 184.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Similares: búsqueda por categoría Suplemento. Precio base estimado.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-33950063'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 184.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 66.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Vitau.mx - Ensure Advance 237ml (referencia similar)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-33950070'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 66.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 61.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Ensure chocolate 236ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-33950100'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 61.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 66.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Vitau.mx - Ensure Advance 237ml (referencia)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-33954078'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 66.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 25.5, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · ELECTROLITO PED UVA 500ML.. (Score: 84%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-33956775'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 25.5
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 25.5, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · ELECTROLITO PED UVA 500ML.. (Score: 75%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-33961373'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 25.5
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 22.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TELA ADHESIVA SEDOSA 1.25CMX5MTS.. (Score: 76%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-34062421'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 22.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 28.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Amikacina 100mg/2ml ampolleta', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-347A49C7'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 28.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 276.94, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Beneventol 400mg 6 cápsulas', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-369D1689'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 276.94
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 61.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Similares: búsqueda por categoría Producto. Precio base estimado.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-38CAFE6B'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 61.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 21.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · BENCILPENICILI PROCAI 400000UI/2ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-3A4583F3'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 21.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 63.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · GLIMEPIRIDA 2MG 30TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-3D0ED22B'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 63.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 58.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · METOCARBAMOL/IBUPRO 375/200MG 12CAP.. (Score: 71%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-3D0F54B7'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 58.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 59.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · CLOTRIMAZOL DUAL (CREM VAG 10GR 3 OVU).. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-40025839'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 59.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 59.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CLOTRIMAZOL DUAL (CREM VAG 10GR 3 OVU).. (Score: 75%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-40030338'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 59.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 90.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · CEFALEXINA 1GR 12TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-40CE757D'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 90.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 39.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Nivea Cuidada Aclarado Natural 200ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-42270027'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 39.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 40.52, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · GIMALXINA 500mg 12 cápsulas', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-428A228F'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 40.52
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 35.26, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Match generico: toallitas humedas para bebe SIMIBABY 80 piezas, equivalente generico de Huggies Toallitas Cuidado Puro, misma cantidad C/80', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-43454811'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 35.26
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 285.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Cefagen Cefalexina 500mg 10 tabletas', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-443C330E'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 285.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 59.25, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Match exacto de marca: BALSAMO LABIAL LABELLO 1 PIEZA', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-45079011'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 59.25
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 84.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · PARCHE LEON ARNICA 3% 12X18CM.. (Score: 87%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-45307181'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 84.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 58.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Similares: búsqueda por categoría Producto. Precio base estimado.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-47AAF23B'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 58.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 17.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · AGUA OXIGENADA SOL 224ML.. (Score: 74%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-48335305'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 17.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 10.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · VENDA ELASTICA 5CMX5MTS DR SIMI.. (Score: 75%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-48690800'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 10.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 11.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · VENDA ELASTICA 7.5CMX5MTS DR SIMI.. (Score: 76%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-48690909'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 11.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 16.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · VENDA ELASTICA 10CMX5MTS DR SIMI.. (Score: 76%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-48691005'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 16.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 22.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · VENDA ELASTICA 15CMX5MTS DR SIMI.. (Score: 76%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-48691104'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 22.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 90.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · CEFALEXINA 1GR 12TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-492D652F'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 90.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 35.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMLODIPINO 5MG 10TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-4A0245DA'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 35.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 224.29, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Beneventol 400mg 3 cápsulas', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-4BD80686'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 224.29
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 39.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Vanmoxol 250/15mg', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-4C621D07'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 39.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 27.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMBROXOL 0.3G/100ML SOL 120ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-4F737E93'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 27.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 139.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · METAMIZOL 5G/100ML JBE100ML NEOMELUBRINA.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-50002301'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 139.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMPICILINA 1GR 10TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-50587FA6'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 150.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Farmacias referencia - Centrum Multivitamínico 30 tabletas (verificar en Fahorro/Walmart)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-50959781'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 150.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 42.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · LORATADINA/BETAMETASONA 10TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-50AC2C82'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 42.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 111.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · GABAPENTINA 300MG 15CAP.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-50D044FF'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 111.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 63.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CIPROFLOXA/HIDRO/LIDO OTICA 10ML.. (Score: 78%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-51067711'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 63.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 109.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · FORMULA LACTEA 0-6MESES 230GR NAN 1.. (Score: 71%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-51078461'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 109.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 48.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMOXICILINA/ACIDO CLAVULANICO 400/57 SUSPENSION 50-60 ML -- coincide concentracion exacta (recuperada del inventario original: CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50ML).', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-516C2E89'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 48.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 26.5, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Farmatodo.com.mx - Electrolit suero oral 625ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-51747971'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 26.5
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 70%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-52844825'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-52876406'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 70%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-52933307'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 63.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · GLIMEPIRIDA 2MG 30TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-52D2A43A'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 63.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 6.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Tempra 500mg C/10 no esta como marca en Similares; se usa el generico PARACETAMOL 500 MG 10 TABLETAS (PICK UP), misma concentracion y cantidad exacta.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-54521161'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 6.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 56.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · CREMA CORP NIVEA PIEL EXT SECA 220ML.. (Score: 82%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-54549819'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 56.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 56.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CREMA CORP NIVEA PIEL EXT SECA 220ML.. (Score: 78%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-54558682'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 56.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 40.5, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Obao Men Tattoo Intense Rebel 65g', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-55280956'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 40.5
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 18.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TOALLA HUMEDA ANTIBAC P/MANOS.. (Score: 69%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-56034041'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 18.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 84.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CREMA HUMECTANTE P/ TATUAJES 74ML.. (Score: 71%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-56326142'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 84.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 85%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-56360429'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 16.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · GLIBENCLAMIDA 5MG 50TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-57925EF3'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 16.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 84.02, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Tempra C/12', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-58792792'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 84.02
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 84.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · GEL LUBRICANTE VAGINAL 113GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-58793249'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 84.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 63.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CIPROFLOXA/HIDRO/LIDO OTICA 10ML.. (Score: 78%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-59225411'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 63.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 23.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Gelubrin 10 CAPSULAS', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-5C8C9C11'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 23.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 59.25, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Norquinol = marca de Norfloxacino. Match generico: NORFLOXACINO 400 MG 20 TABLETAS, misma concentracion y cantidad.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-5D9DFA3D'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 59.25
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 112.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Clamoxin 500/125mg 10 tabletas', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-5F30F9D4'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 112.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 51.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · PARACETAMOL 300MG 6 SUPOS.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-60101231'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 51.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 60.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · VITAMINAS A/D/ALANTO POM 40GR SIMIBABY.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-60101521'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 60.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 59.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · BEZAFIBRATO 200MG 30TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-6074BB64'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 59.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 85%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-61123009'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · JERINGA PERA NO.3 1PZA SIMIBABY.. (Score: 71%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-614E4F82'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 93.9, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · TUMS Carbonato de Calcio precio base', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-65054135'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 93.9
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'fahorro', 'venta', 135.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Centrum Tab C/30 - versión estándar', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-65095947'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'fahorro'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 135.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 37.5, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Match generico: PRUEBA DE EMBARAZO ANALOGA (PICK UP), equivalente generico de prueba Meditest, presentacion C/1 pieza asumida equivalente', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-66055303'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 37.5
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 26.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Colgate Total 12 Clean Mint 50ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-66534951'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 26.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 16.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CREMA DE ARNICA 30GR.. (Score: 75%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-66873531'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 16.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 21.5, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Blumen Cherry Blossom 221ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-67905131'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 21.5
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 25.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Blumen Coconut Paradise 221ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-67905186'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 25.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 199.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Similares: búsqueda por categoría Botiquín. Precio base estimado.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-68960257'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 199.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 199.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Similares: búsqueda por categoría Botiquín. Precio base estimado.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-68990023'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 199.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 119.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AC FUSIDICO/BETA 20/1MG CREMA.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-697EEAD0'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 119.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 45.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMBROXOL/SALBUTAMOL SOL 120ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-69A3C416'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 45.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 69.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Similares: búsqueda por categoría GENERAL. Precio base estimado.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-6B2ADEE9'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 69.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 110.25, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Interpretando ''125 Mg/Ml'' como 0.125 mg/ml (formato comun de captura sin punto decimal), coincide con BUDESONIDA SUSPENSION 0.250MG/2ML O 0.125MG/ML PARA NEBULIZACION 5 AMPOLLETAS, mismo numero de amp', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-6C2878CF'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 110.25
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 75.42, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CEPOBROM Cefadroxil/Bromhexina encontrado', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-6EAD98A9'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 75.42
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 43.5, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Match generico: NEOMICINA / CAOLIN / PECTINA 20 TABLETAS, equivalente generico de Treda (confirmado por fuentes externas que Treda = neomicina/caolin/pectina), misma cantidad C/20', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-70612368'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 43.5
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 124.95, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Ting polvo decolorante 85g', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-72300171'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 124.95
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 339.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · AC URSODEOXICOLICO 250MG 50CAP.. (Score: 67%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-75001865'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 339.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-75062897'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-75062927'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 23.9, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Evenflo Biberón Colors Flujo Lento 4oz/120ml - Disponible. SKU público: 466510', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-75125811'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 23.9
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 111.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · GABAPENTINA 300MG 15CAP.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-759A5EF9'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 111.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 234.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CREMA ANTIARRUGAS 40+ 50GR ETERNAL SEC.. (Score: 68%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-76000253'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 234.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 60.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Similares: búsqueda por categoría Producto. Precio base estimado.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-76000284'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 60.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 79.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Similares: búsqueda por categoría Producto. Precio base estimado.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-77FE5C83'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 79.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMPICILINA 1GR 10TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-7AA38F97'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 300.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Neurobion DC 100/100/25mg C/1 inyectable. Precio base estimado $300 (rango $274-$312 según fuente). SKU FC-82176351 no encontrado en catálogos; posible discrepancia de SKU interno.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-82176351'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 300.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 54.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · ALGESTONA/ESTRADIOL 1AMP 1ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-830BF3FB'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 54.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 17.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · AGUA OXIGENADA SOL 224ML.. (Score: 74%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-83351381'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 17.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 17.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AGUA OXIGENADA SOL 224ML.. (Score: 80%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-83351691'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 17.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 260.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Farmacias San Isidro - Alka-Seltzer Boost 50 tabletas efervescentes', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-84999001'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 260.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 111.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · PERMETRINA 5G/100ML SOL 100ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-85592111'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 111.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 54.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMOXICILINA/BROM 250MG SUSP 60ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-85BDBD3D'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 54.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 51.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · PROBIOTICOS 30TAB MAST UVA SIMIPROBIOT.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-86167151'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 51.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 63.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TERMOMETRO DIGITAL 1PZA.. (Score: 74%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-86708021'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 63.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 62.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · ERITROMICINA 500MG 20TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-86A95D07'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 62.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 119.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · BENZOCAINA 10MG 24PAST GRANEODIN B.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-87154871'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 119.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 379.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · GOTAS LUBRICANTES OCULARES 10ML.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-87932321'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 379.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 15.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AC FOLICO 5MG 20TAB.. (Score: 82%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-88923551'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 15.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 112.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · HIDROXOCOBALAMINA 50000UI 5AMP.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-88947797'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 112.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-93022567'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-93025797'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 69.01, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · DESODORANTE AER CAB 150ML OLD SPICE.. (Score: 67%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-93025865'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 69.01
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-93025919'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-93037806'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 82.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · SPRAY DESODORANTE PARA PIES 160ML.. (Score: 66%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-93038223'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 82.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 60.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · VITAMINAS A/D/ALANTO POM 40GR SIMIBABY.. (Score: 76%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-95201021'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 60.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 197.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Fasiclor Cefaclor 250mg suspensión 75ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-9538F7D6'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 197.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 58.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · SAL DE UVAS PICOT 10+2 SOB POLVO EFER.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-95451096'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 58.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 18.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AC ACETILSALICILICO 300MG 20TAB  EFERV.. (Score: 80%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-95779436'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 18.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 57.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Gimalxina 250mg/5ml suspensión 75ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-974EE5FD'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 57.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 35.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMLODIPINO 5MG 10TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-97BEFA1A'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 35.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 339.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Dolo-Neurobión Diclofenaco Complejo B', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-98217659'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 339.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 328.57, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Beneventol suspensión 50ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-9B93AC4C'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 328.57
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 38.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · DICLOXACILINA SUSP 60ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-9F67BB73'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 38.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 29.25, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMOXICILINA 500 MG 12 CAPSULAS -- coincidencia exacta.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-A0D320D1'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 29.25
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Zitriasol 100mg 15 cápsulas', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-A23F290E'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 128.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Cefagen suspensión 250mg', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-A455EE80'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 128.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · JERINGA PERA NO.3 1PZA SIMIBABY.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-A871D831'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 66.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · ATORVASTATINA 10MG 20TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-A909ABC0'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 66.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 54.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · ALGESTONA/ESTRADIOL 1AMP 1ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-AA905BF7'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 54.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 31.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · TRIMETOPRI/SULFA 800/4000MG SUSP 120ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-AE5EEDF7'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 31.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 34.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AC MEFENAMICO 500MG 20TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-AEA8C8DA'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 34.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 81.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · ALENDRONATO 70MG 4TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-B2123139'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 81.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 79.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · ACICLOVIR 4GR/100ML SUSP 120ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-B25094C4'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 79.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 229.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · LEVOFLOXACINO 750MG 7TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-B25B4654'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 229.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 144.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · FEXOFENADINA 180MG PIRQUET 10COMP.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-B3B8F9BB'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 144.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 79.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · ACICLOVIR 4GR/100ML SUSP 120ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-B69FCBF4'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 79.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMPICILINA 1GR 10TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-B72A6420'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · JERINGA PERA NO.3 1PZA SIMIBABY.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-BCF59548'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 79.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CEFTRIAXONA 1GR 1AMP.. (Score: 71%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-BE76D409'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 79.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · JERINGA PERA NO.3 1PZA SIMIBABY.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-C22EBFE6'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 79.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · CEFTRIAXONA 1GR 1AMP.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-C636D8EA'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 79.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 90.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · CLINDAMICINA 300 MG 16 CAPSULAS -- coincidencia exacta.', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-CF18C740'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 90.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 54.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Diclephen Diclofenaco 500mg', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-CF719C07'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 54.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 52.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Ampicilina 1g ampolleta', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-D210172A'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 52.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 131.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CREMA ACEITE DE ALMENDRA 225ML.. (Score: 68%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-D4AC123B'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 131.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 38.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · DICLOXACILINA SUSP 60ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-D5AC44CA'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 38.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 34.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · TERBINAFINA CLORHIDRATO 15GR.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-DA34D88D'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 34.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 37.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · BETAMETASONA 8MG/2ML 1AMP+JER.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-DB3B2584'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 37.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 76.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CALCIO/VIT A/VIT D2 60COMP.. (Score: 75%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-DB4A39AE'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 76.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 45.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · AMANTADINA/CLOR/PARA 60ML INF.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-DE106642'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 45.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 96.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Cefagen suspensión 125mg', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-E374F23E'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 96.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 13.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · FUROSEMIDA 40MG 20TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-E535DE28'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 13.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 176.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Nalixone/Fenazopiridina', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-E6112F15'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 176.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 79.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · LINCOMICINA 600MG/2ML 6AMP.. (Score: 81%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-E826D304'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 79.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 65.43, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Vitau.mx - Ciprofloxacino genérico 500mg 14 tabletas', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-E9C38DC4'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 65.43
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 21.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · BENCILPENICILI PROCAI 400000UI/2ML.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-F183C6E9'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 21.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 135.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Clamoxin 875/125mg 10 tabletas', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-F22C72BE'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 135.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 117.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Fasiclor Cefaclor', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-F3E734A0'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 117.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 92.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · Clamoxin 250/62.5mg suspensión 60ml', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-F48FF7EF'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 92.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · BIFONAZOL UNGUENTO 20GR.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-F817BC3A'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'otros_venta', 'venta', 67.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · Vitau.mx - Ampicilina genérica 1g 10 tabletas', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-F82A6E4B'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'otros_venta'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 67.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 39.0, CURRENT_DATE, 'manual', 90,
  'Claude 20260815 · TRIMETO/SULF 160/800MG 14TAB.. (Score: 100%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-F8691496'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 39.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 170.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · CALCITRIOL 0.25MCG 50CAP.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-FA3D96E6'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 170.0
  );
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, confianza, notas, nombre_fuente
)
SELECT p.id, 'similares', 'venta', 49.0, CURRENT_DATE, 'manual', 70,
  'Claude 20260815 · JERINGA PERA NO.3 1PZA SIMIBABY.. (Score: 65%)', p.nombre
FROM public.productos p
WHERE p.sku = 'FC-FFC25DD1'
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r2
    WHERE r2.producto_id = p.id AND r2.fuente = 'similares'
      AND r2.origen = 'manual' AND r2.fecha = CURRENT_DATE
      AND r2.precio = 49.0
  );

COMMIT;

SELECT fuente, count(*) FROM public.producto_precios_referencia
WHERE notas LIKE 'Claude 20260815%'
GROUP BY fuente;
