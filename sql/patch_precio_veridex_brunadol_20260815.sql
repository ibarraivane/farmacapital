-- ════════════════════════════════════════════════════════════════
-- Veridex + Brunadol · fotos 2026-08-15
--
-- Ninguno de los dos estaba en la base (aparecen como "falta cargar"
-- en auditoria_lista_usuario_farmalive.md). Este patch los busca por
-- EAN, SKU o nombre y los CREA si no existen; si ya existen, solo
-- corrige los campos.
--
-- Costo = valor del ticket FL-080826.
-- El precio impreso en la caja (PMP) NO se usa.
--
-- Abrir desde DISCO · Cmd+A · pegar completo en Supabase.
-- NO copiar desde chat (trunca -> error 42601).
-- Idempotente: se puede correr mas de una vez.
-- ════════════════════════════════════════════════════════════════

BEGIN;

-- ── Veridex ivermectina 6 mg C/4 · Maver · 7502209747366
--    costo 75.46 (ticket) · precio 101.88 · lote 261181 · cad 2028-02-28
--    '75020027471' es el barcode truncado que dejaba el OCR de FarmaLive
DO $blk$
DECLARE v_pid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7502209747366','75020097473660','75020027471')
     OR sku IN ('FC-09747366','FC-9747366')
     OR nombre ILIKE '%veridex%'
  LIMIT 1;

  IF v_pid IS NULL THEN
    INSERT INTO public.productos (sku, nombre, codigo_barras, categoria, tipo,
                                  precio, costo, stock, requiere_receta, activo)
    VALUES ('FC-09747366', 'Veridex ivermectina 6 mg C/4', '7502209747366',
            'Medicamentos', 'marca', 101.88, 75.46, 0, true, true)
    RETURNING id INTO v_pid;
    RAISE NOTICE 'Veridex CREADO · id %', v_pid;
  ELSE
    RAISE NOTICE 'Veridex ya existia · id %', v_pid;
  END IF;

  UPDATE public.productos SET
    sku                = 'FC-09747366',
    codigo_barras      = '7502209747366',
    nombre             = 'Veridex ivermectina 6 mg C/4',
    marca              = 'Veridex',
    presentacion       = 'C/4 tabletas 6 mg',
    principio_activo   = 'Ivermectina 6 mg',
    forma_farmaceutica = 'Tabletas',
    subcategoria       = 'Antiparasitario',
    categoria          = 'Medicamentos',
    tipo               = 'marca',
    costo              = 75.46,
    precio             = 101.88,
    requiere_receta    = true,
    activo             = true,
    descripcion        = 'Maver · Ivermectina 6 mg 4 tabletas · costo ticket FL-080826 · precio de ticket, no PMP caja'
  WHERE id = v_pid;

  IF EXISTS (SELECT 1 FROM public.lotes WHERE producto_id = v_pid) THEN
    UPDATE public.lotes SET
      numero_lote     = COALESCE(NULLIF(btrim(numero_lote), ''), '261181'),
      fecha_caducidad = COALESCE(fecha_caducidad, '2028-02-28'::date),
      costo_unitario  = COALESCE(costo_unitario, 75.46)
    WHERE producto_id = v_pid;
  ELSE
    INSERT INTO public.lotes (producto_id, numero_lote, cantidad_inicial, cantidad_actual,
                              fecha_caducidad, costo_unitario, activo)
    VALUES (v_pid, '261181', 1, 1, '2028-02-28'::date, 75.46, true);
    RAISE NOTICE 'Veridex · lote 261181 creado con 1 pieza';
  END IF;
END $blk$;

-- ── Brunadol paracetamol 300 mg + naproxeno 275 mg C/10 · Bruluart
--    7501537103521 · costo 19.31 · precio 72.00 · lote 604188 · cad 2028-04-06
--    En la foto se ven 4 cajas, que es la cantidad del ticket
DO $blk$
DECLARE v_pid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE codigo_barras IN ('7501537103521','75015371035210')
     OR sku IN ('FC-103521','FC-37103521')
     OR nombre ILIKE '%brunadol%'
  LIMIT 1;

  IF v_pid IS NULL THEN
    INSERT INTO public.productos (sku, nombre, codigo_barras, categoria, tipo,
                                  precio, costo, stock, requiere_receta, activo)
    VALUES ('FC-103521', 'Brunadol paracetamol/naproxeno C/10', '7501537103521',
            'Medicamentos', 'generico', 72.00, 19.31, 0, false, true)
    RETURNING id INTO v_pid;
    RAISE NOTICE 'Brunadol CREADO · id %', v_pid;
  ELSE
    RAISE NOTICE 'Brunadol ya existia · id %', v_pid;
  END IF;

  UPDATE public.productos SET
    sku                = 'FC-103521',
    codigo_barras      = '7501537103521',
    nombre             = 'Brunadol paracetamol/naproxeno C/10',
    marca              = 'Brunadol',
    presentacion       = 'C/10 tabletas',
    principio_activo   = 'Paracetamol 300 mg + Naproxeno 275 mg',
    forma_farmaceutica = 'Tabletas',
    subcategoria       = 'Analgesico / antipiretico / antinflamatorio',
    categoria          = 'Medicamentos',
    tipo               = 'generico',
    costo              = 19.31,
    activo             = true,
    descripcion        = 'Bruluart · Paracetamol 300 mg + Naproxeno 275 mg 10 tabletas · costo ticket FL-080826'
  WHERE id = v_pid;

  IF EXISTS (SELECT 1 FROM public.lotes WHERE producto_id = v_pid) THEN
    UPDATE public.lotes SET
      numero_lote     = COALESCE(NULLIF(btrim(numero_lote), ''), '604188'),
      fecha_caducidad = COALESCE(fecha_caducidad, '2028-04-06'::date),
      costo_unitario  = COALESCE(costo_unitario, 19.31)
    WHERE producto_id = v_pid;
  ELSE
    INSERT INTO public.lotes (producto_id, numero_lote, cantidad_inicial, cantidad_actual,
                              fecha_caducidad, costo_unitario, activo)
    VALUES (v_pid, '604188', 4, 4, '2028-04-06'::date, 19.31, true);
    RAISE NOTICE 'Brunadol · lote 604188 creado con 4 piezas';
  END IF;
END $blk$;

COMMIT;


-- ── Verificación: deben salir 2 filas
SELECT p.sku, p.nombre, p.codigo_barras, p.costo, p.precio, p.stock, p.activo,
       l.numero_lote, l.fecha_caducidad, l.cantidad_actual,
       ROUND((p.precio - p.costo) / NULLIF(p.costo, 0) * 100, 1) AS margen_pct
FROM public.productos p
LEFT JOIN public.lotes l ON l.producto_id = p.id AND COALESCE(l.activo, true)
WHERE p.codigo_barras IN ('7502209747366','7501537103521')
ORDER BY p.nombre;
