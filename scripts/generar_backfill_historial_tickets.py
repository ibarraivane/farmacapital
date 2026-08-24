#!/usr/bin/env python3
"""Backfill de la Historia de compras con los tickets iniciales.

Toma los CSV de los tickets y genera un patch que crea la recepción de cada
uno con sus renglones (producto, cantidad, costo). Solo escribe en
recepciones/recepcion_items: no toca stock, ni costos, ni referencias.

Para saber a qué producto va cada renglón usa, en orden, las huellas que
dejó la carga original del ticket:

  1. el SKU (los CSV de cruce ya lo traen; Equilibrio y Farma MX lo arman
     con su convención EQ-/FMX- + código de proveedor),
  2. el código de barras, para lo que se dio de alta después del cruce,
  3. el lote que la carga registró, si apunta a un solo producto.

Si ninguna resuelve, el renglón se queda fuera en vez de adivinar.

    python3 scripts/generar_backfill_historial_tickets.py
"""
import csv
import os

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SALIDA = os.path.join(RAIZ, "sql", "patch_backfill_historial_tickets_20260824.sql")

# Fecha confirmada por el OCR de cada ticket (.tmp_ocr_vision/*.txt).
# Equilibrio no la trae legible; el dueño confirmó que es el mismo día.
TICKETS = [
    dict(archivo="sql/generated/comparacion_bodega_f42_77827.csv",
         proveedor="Bodega F-42", folio="77827", fecha="2026-08-08", modo="comparacion"),
    dict(archivo="sql/generated/comparacion_farmalive_9861.csv",
         proveedor="Farmalive", folio="9861", fecha="2026-08-08", modo="comparacion"),
    dict(archivo="sql/generated/comparacion_ifc1_118217.csv",
         proveedor="IFC", folio="118217", fecha="2026-08-08", modo="comparacion"),
    dict(archivo="sql/generated/comparacion_ifc2_118216.csv",
         proveedor="IFC", folio="118216", fecha="2026-08-08", modo="comparacion"),
    dict(archivo="sql/generated/comparacion_surtidor_112558.csv",
         proveedor="El Surtidor", folio="112558", fecha="2026-08-08", modo="comparacion"),
    dict(archivo="sql/generated/ticket_equilibrio_440393.csv",
         proveedor="Equilibrio", folio="440393", fecha="2026-08-08", modo="equilibrio",
         prefijo="EQ-"),
    dict(archivo="sql/generated/ticket_farmamx_CAICA1CA108588.csv",
         proveedor="Farma MX", folio="CAICA1CA108588", fecha="2026-08-08", modo="farmamx",
         prefijo="FMX-"),
]

MARCA = "backfill ticket inicial"


def num(v):
    try:
        return float(str(v).replace(",", "").strip())
    except (TypeError, ValueError):
        return 0.0


def q(s):
    """Literal SQL para datos: comilla duplicada, NULL si viene vacío."""
    s = str(s or "").strip()
    return "NULL" if not s else "'" + s.replace("'", "''") + "'"


def leer(t):
    """→ [(sku, codigo, ean, lote, descripcion, cantidad, costo)] ya filtrado.

    `ean` solo se llena cuando el CSV trae código de barras de verdad. Los
    tickets de IFC traen clave de proveedor en esa columna, y empatarla
    contra codigo_barras daría falsos positivos.
    """
    ruta = os.path.join(RAIZ, t["archivo"])
    filas = []
    with open(ruta, encoding="utf-8-sig") as fh:
        for r in csv.DictReader(fh):
            if t["modo"] == "comparacion":
                sku = (r.get("sku") or "").strip()
                ean = (r.get("ean_ticket") or "").strip()
                codigo = ean or (r.get("clave_ticket") or "").strip()
                lote = ""
                desc = (r.get("descripcion_ticket") or "").strip()
                cant, costo = num(r.get("cantidad")), num(r.get("costo_ticket"))
            else:
                campo = "codigo_prov" if t["modo"] == "equilibrio" else "clave"
                precio = "costo_unitario" if t["modo"] == "equilibrio" else "precio_unitario"
                codigo = (r.get(campo) or "").strip()
                ean = ""
                sku = t["prefijo"] + codigo if codigo else ""
                lote = (r.get("lote") or "").strip()
                desc = (r.get("descripcion") or "").strip()
                cant, costo = num(r.get("cantidad")), num(r.get(precio))
            if cant <= 0 or costo <= 0:
                continue
            if not sku and not ean:
                continue
            filas.append((sku, codigo, ean, lote, desc, int(round(cant)), round(costo, 2)))
    return filas


def resolucion(t):
    """SQL que devuelve el producto_id de un renglón, o NULL si no se puede.

    Tres huellas, en orden de confianza. `ean` viene vacío en Equilibrio y
    Farma MX (sus tickets no traen código de barras) y `lote` viene vacío en
    los CSV de cruce, así que cada cláusula solo actúa donde tiene con qué.

    No se busca por la nota «Código proveedor …» que escribía la carga
    original: productos.notas no existe en este esquema, así que esa columna
    nunca se llenó. Por descripción tampoco rescata ninguno — se midió.
    """
    return """COALESCE(
        (SELECT p.id FROM public.productos p WHERE p.sku = d.sku LIMIT 1),
        -- Un producto puede haberse dado de alta después de generarse el CSV
        -- de cruce. 12 dígitos mínimo para no confundir el código de barras
        -- con una clave corta de proveedor.
        (SELECT CASE WHEN count(*) = 1 THEN min(p.id) END
           FROM public.productos p
          WHERE d.ean IS NOT NULL AND length(d.ean) >= 12
            AND p.codigo_barras = d.ean),
        -- El lote que registró la carga original del ticket, con su costo.
        (SELECT CASE WHEN count(DISTINCT l.producto_id) = 1 THEN min(l.producto_id) END
           FROM public.lotes l
          WHERE d.lote IS NOT NULL
            AND l.numero_lote = d.lote
            AND abs(coalesce(l.costo_unitario, -1) - d.costo) < 0.005)
      )"""


def bloque(t, filas):
    values = ",\n        ".join(
        "({}, {}, {}, {}, {}, {}, {})".format(q(s), q(c), q(e), q(lo), q(de), n, p)
        for s, c, e, lo, de, n, p in filas
    )
    return f"""
-- ── {t['proveedor']} · folio {t['folio']} · {len(filas)} renglones del ticket ──
DO $$
DECLARE
  v_id   bigint;
  v_nota text;
  v_n    integer;
BEGIN
  SELECT id, coalesce(notas, '') INTO v_id, v_nota
  FROM public.recepciones
  WHERE folio = {q(t['folio'])}
  ORDER BY id LIMIT 1;

  IF v_id IS NOT NULL AND v_nota NOT LIKE {q(MARCA + '%')} THEN
    RAISE NOTICE '{t['proveedor']} {t['folio']}: ya existe como recepción real (id %), no se toca', v_id;
    RETURN;
  END IF;

  IF v_id IS NULL THEN
    INSERT INTO public.recepciones (proveedor, folio, fecha, estado, notas, cerrado_en)
    VALUES ({q(t['proveedor'])}, {q(t['folio'])}, DATE {q(t['fecha'])}, 'confirmada', {q(MARCA)}, now())
    RETURNING id INTO v_id;
  ELSE
    -- Re-ejecutable: se rehacen los renglones del propio backfill.
    DELETE FROM public.recepcion_items WHERE recepcion_id = v_id;
  END IF;

  WITH d(sku, codigo, ean, lote, descripcion, cantidad, costo) AS (
    VALUES
        {values}
  ),
  res AS (
    SELECT d.*, {resolucion(t)} AS producto_id
    FROM d
  ),
  -- Un renglón por producto: si el ticket lo trae en varias líneas se suma
  -- la cantidad y se queda el costo más barato de esas líneas.
  agrupado AS (
    SELECT producto_id,
           min(codigo)      AS codigo,
           min(descripcion) AS descripcion,
           sum(cantidad)    AS cantidad,
           min(costo)       AS costo
    FROM res
    WHERE producto_id IS NOT NULL
    GROUP BY producto_id
  )
  INSERT INTO public.recepcion_items
    (recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
     cantidad, costo_estimado, confirmado, pendiente_alta)
  SELECT v_id, a.producto_id, a.codigo, a.descripcion, a.cantidad, a.costo, true, false
  FROM agrupado a;

  GET DIAGNOSTICS v_n = ROW_COUNT;
  RAISE NOTICE '{t['proveedor']} {t['folio']}: % productos enlazados de {len(filas)} renglones', v_n;
END $$;
"""


def main():
    partes = [
        "-- Backfill de la Historia de compras — tickets iniciales.",
        "--",
        "-- ARCHIVO GENERADO. Se produce con",
        "--   python3 scripts/generar_backfill_historial_tickets.py",
        "--",
        "-- Crea la recepción de cada ticket viejo con sus renglones para que la",
        "-- pestaña Historia (Recibir) muestre desde qué precio arrancó cada",
        "-- producto. NO toca stock, ni productos.costo, ni las referencias de",
        "-- precio: solo escribe en recepciones y recepcion_items.",
        "--",
        "-- Cada renglón busca su producto por SKU, por la nota «Código proveedor",
        "-- …» que dejó la carga original y por número de lote, en ese orden. Lo",
        "-- que no resuelve se queda fuera en vez de adivinar.",
        "--",
        "-- Es re-ejecutable. Si un folio ya existe como recepción de verdad,",
        "-- lo respeta y lo salta.",
        "--",
        "-- Requiere sql/patch_recepcion_historial_20260824.sql ya aplicado.",
        "",
    ]
    total = 0
    for t in TICKETS:
        filas = leer(t)
        total += len(filas)
        partes.append(bloque(t, filas))
        print(f"{t['proveedor']:14} {t['folio']:16} {len(filas):4} renglones")

    partes.append(f"""
-- Qué quedó cargado.
SELECT r.fecha, r.proveedor, r.folio,
       count(i.id) AS renglones,
       sum(i.cantidad) AS piezas,
       round(sum(i.cantidad * i.costo_estimado), 2) AS importe
FROM public.recepciones r
JOIN public.recepcion_items i ON i.recepcion_id = r.id
WHERE r.notas LIKE {q(MARCA + '%')}
GROUP BY r.fecha, r.proveedor, r.folio
ORDER BY r.fecha, r.proveedor;
""")
    with open(SALIDA, "w", encoding="utf-8") as fh:
        fh.write("\n".join(partes))
    print(f"\n{total} renglones → {os.path.relpath(SALIDA, RAIZ)}")


if __name__ == "__main__":
    main()
