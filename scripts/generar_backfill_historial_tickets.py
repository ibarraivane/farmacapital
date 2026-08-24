#!/usr/bin/env python3
"""Backfill de la Historia de compras con los tickets iniciales.

Toma los CSV que ya se habían cruzado contra el catálogo y genera un patch
que crea la recepción de cada ticket con sus renglones (producto, cantidad,
costo). Solo escribe en recepciones/recepcion_items: no toca stock, ni
costos, ni referencias de precio.

    python3 scripts/generar_backfill_historial_tickets.py
"""
import csv
import os

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SALIDA = os.path.join(RAIZ, "sql", "patch_backfill_historial_tickets_20260824.sql")

# Fecha confirmada por el OCR de cada ticket (.tmp_ocr_vision/*.txt).
# Equilibrio no trae fecha legible; queda marcada como supuesta en notas.
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
         fecha_supuesta=True),
    dict(archivo="sql/generated/ticket_farmamx_CAICA1CA108588.csv",
         proveedor="Farma MX", folio="CAICA1CA108588", fecha="2026-08-08", modo="farmamx"),
]

MARCA = "backfill ticket inicial"


def num(v):
    try:
        return float(str(v).replace(",", "").strip())
    except (TypeError, ValueError):
        return 0.0


def q(s):
    """Literal SQL: comilla simple duplicada, NULL si viene vacío."""
    s = str(s or "").strip()
    return "NULL" if not s else "'" + s.replace("'", "''") + "'"


def leer(t):
    """→ [(sku, codigo, descripcion, cantidad, costo)] ya filtrado."""
    ruta = os.path.join(RAIZ, t["archivo"])
    filas = []
    with open(ruta, encoding="utf-8-sig") as fh:
        for r in csv.DictReader(fh):
            if t["modo"] == "comparacion":
                sku = (r.get("sku") or "").strip()
                codigo = (r.get("ean_ticket") or r.get("clave_ticket") or "").strip()
                desc = (r.get("descripcion_ticket") or "").strip()
                cant, costo = num(r.get("cantidad")), num(r.get("costo_ticket"))
            elif t["modo"] == "equilibrio":
                cod = (r.get("codigo_prov") or "").strip()
                sku = "EQ-" + cod if cod else ""
                codigo = cod
                desc = (r.get("descripcion") or "").strip()
                cant, costo = num(r.get("cantidad")), num(r.get("costo_unitario"))
            else:  # farmamx
                cod = (r.get("clave") or "").strip()
                sku = "FMX-" + cod if cod else ""
                codigo = cod
                desc = (r.get("descripcion") or "").strip()
                cant, costo = num(r.get("cantidad")), num(r.get("precio_unitario"))
            if not sku or cant <= 0 or costo <= 0:
                continue
            filas.append((sku, codigo, desc, int(round(cant)), round(costo, 2)))
    return filas


def bloque(t, filas):
    nota = MARCA + (" (fecha del ticket sin confirmar)" if t.get("fecha_supuesta") else "")
    values = ",\n      ".join(
        "({}, {}, {}, {}, {})".format(q(s), q(c), q(d), n, p)
        for s, c, d, n, p in filas
    )
    return f"""
-- ── {t['proveedor']} · folio {t['folio']} · {len(filas)} renglones ──────────
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
    VALUES ({q(t['proveedor'])}, {q(t['folio'])}, DATE {q(t['fecha'])}, 'confirmada', {q(nota)}, now())
    RETURNING id INTO v_id;
  ELSE
    -- Re-ejecutable: se rehacen los renglones del propio backfill.
    DELETE FROM public.recepcion_items WHERE recepcion_id = v_id;
  END IF;

  INSERT INTO public.recepcion_items
    (recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
     cantidad, costo_estimado, confirmado, pendiente_alta)
  SELECT v_id, p.id, d.codigo, d.descripcion, d.cantidad, d.costo, true, false
  FROM (VALUES
      {values}
  ) AS d(sku, codigo, descripcion, cantidad, costo)
  JOIN public.productos p ON p.sku = d.sku;

  GET DIAGNOSTICS v_n = ROW_COUNT;
  RAISE NOTICE '{t['proveedor']} {t['folio']}: % de {len(filas)} renglones enlazados', v_n;
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
