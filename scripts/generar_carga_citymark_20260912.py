#!/usr/bin/env python3
"""Ticket City Mark 2026-09-12 → CSV + SQL cola Recibir.

Fuente: ticket físico «Cliente: PUBLICO EN GENERAL» (encabezado cortado).
Folio no venía en el recorte: usamos 20260912.
17 líneas / 22 piezas / $1,486.47. Sin lote ni MMAA.
EAN del ticket. Nombres de mostrador limpios (no el código crudo).
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_recepcion_sql, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
FOLIO = "20260912"
PROVEEDOR = "City Mark"
PROVEEDOR_ILIKE = "city mark"
FECHA = "2026-09-12"
TOTAL = 1486.47

# ean del ticket · nombre mostrador · desc ticket · qty · pu · sub
ROWS = [
    ("7501943476271", "Kleenex pañuelos bote C/50", "KLENNEX PAÑ BOTE C50", 2, 29.140, 58.28),
    ("070330731813", "BIC Soleil 3 Color Collection 12 pzas", "BIC SOLEIL 3 COLOR COLLECTION 12 PZS OFERTA 20%", 1, 155.320, 155.32),
    ("070330717541", "BIC Advance tira rastrillo 12 pzas", "BIC TIRA ADVANC TIRA RASTRILLO 12 PZS OFERTA 20%", 1, 169.600, 169.60),
    ("850040940602", "Grisi Organ Silver shampoo 400 ml + canas 130 ml", "GRISI 400ML SH ORGAN SILVER + 130ML CANAS P LATI", 1, 87.350, 87.35),
    ("810120500164", "Pert crema peinar kera + aguacate 100 ml", "CRA PERT KERA+AC AGU P/PEIN 100 ML", 2, 14.800, 29.60),
    ("7502254073371", "Seda Pure silica argán spray 300 ml", "SILICA SEDA PURE ARGAN SPY 300ML", 1, 69.040, 69.04),
    ("7502254073357", "Seda Pure silica uva spray 300 ml", "SILICA SEDA PURE UVA SPY300ML", 1, 69.050, 69.05),
    ("7506306208315", "St Ives colágeno y elastina 200 ml", "CRA S TIVES COLAGENO Y ELAS 200ML OCT26", 1, 32.310, 32.31),
    ("7501080111455", "Just For Men tinte barba/bigote negro", "TIN JUST F-MEN BARBA/B NEGRO", 2, 171.140, 342.28),
    ("7502254073715", "Seda Pure acondicionador kerat bifásico 250 ml", "ACOND SEDA PURE KERAT BIFAS 250ML", 1, 55.100, 55.10),
    ("810120500171", "Pert crema peinar oliva + aguacate 100 ml", "CRA PERT OLIV+AC AGU P/PEIN 100 ML", 2, 14.800, 29.60),
    ("7702031887928", "Listerine Care Zero menta 250 ml", "ENJ BUC LIST CARE ZERO MTA 250ML", 1, 63.530, 63.53),
    ("7891010974329", "Listerine Zero menta suave 250 ml", "ENJ BUC LIST ZERO MTA SVE 250ML", 1, 54.060, 54.06),
    ("7702035433299", "Listerine Defense 250 ml", "ENJ BUC LIST DEF/DYENC 250ML", 1, 63.860, 63.86),
    ("7501027233974", "L'Oréal Fix Inv ultra fijación gel 180 g", "GEL LOREAL FIX INV U/FIJ 180G", 1, 58.100, 58.10),
    ("7502254072831", "Seda Pure silica brillo extremo 125 ml", "SILICA SEDA PURE BRILLO EXTRE 125ML", 2, 58.540, 117.08),
    ("7506306208353", "St Ives avena y karité 200 ml", "CRA ST IVES AVENA Y KARITE 200ML NOV26", 1, 32.310, 32.31),
]


def rows_rx() -> list[dict]:
    out = []
    for ean, nombre, _desc, qty, pu, sub in ROWS:
        # Para match: Pert oliva en catálogo tiene check digit 8101205001716
        sku = "FC-20500171" if ean == "810120500171" else ""
        if ean == "7702031887928":
            sku = "FC-31887928"
        elif ean == "7891010974329":
            sku = "FC-10974329"
        out.append(
            {
                "nombre": nombre,
                "qty": qty,
                "sub": sub,
                "pu": pu,
                "ean": ean,
                "sku": sku,
                "match": "ticket",
            }
        )
    return out


def main() -> None:
    data = rows_rx()
    out_csv = ROOT / "sql" / "generated" / f"ticket_citymark_{FOLIO}.csv"
    out_rx = ROOT / "sql" / f"patch_recepcion_citymark_{FOLIO}.sql"

    write_ticket_csv(out_csv, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL, rows=data)
    write_recepcion_sql(
        out_rx,
        folio=FOLIO,
        proveedor=PROVEEDOR,
        proveedor_ilike=PROVEEDOR_ILIKE,
        fecha=FECHA,
        total=TOTAL,
        notas=(
            f"Pedido City Mark {FOLIO} · ticket PUBLICO EN GENERAL · "
            "encabezado cortado (folio/fecha estimados 12-sep-2026) · "
            "EAN del ticket · cola Recibir; stock al confirmar pistola · "
            "altas nuevas quedan en amarillo hasta ficha+foto"
        ),
        rows=data,
    )

    suma = sum(r["sub"] for r in data)
    piezas = sum(r["qty"] for r in data)
    print(report(data, TOTAL))
    print(f"piezas={piezas} esperado=22 ok={piezas == 22}")
    print(f"lineas={len(data)} esperado=17 ok={len(data) == 17}")
    print(f"suma=${suma:.2f} total=${TOTAL:.2f} delta={suma - TOTAL:.2f}")
    print(f"csv={out_csv}")
    print(f"rx={out_rx}")
    if piezas != 22 or len(data) != 17 or abs(suma - TOTAL) >= 0.02:
        raise SystemExit("totales no cuadran")


if __name__ == "__main__":
    main()
