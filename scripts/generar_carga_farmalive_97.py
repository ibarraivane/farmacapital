#!/usr/bin/env python3
"""Ticket Farmalive 97 (2026-09-10) → CSV + SQL cola Recibir.

Fuente: ticket físico FARMA live Club Iztapalapa 1 · TICKET DE VENTA No. 97.
28 artículos impresos / 62 unidades. Total a pagar $2,483.41
(subtotal $2,548.72 − descuento $65.31).
Costo = precio neto (después del descuento de línea: 2%, 5% o 15%).
Pharmaton promo $0.01 x2 consolidado en 2 pzas a $0.02.
Sin lote ni MMAA.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_recepcion_sql, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_CSV = ROOT / "sql" / "generated" / "ticket_farmalive_97.csv"
OUT_SQL = ROOT / "sql" / "patch_recepcion_farmalive_97_corroborar.sql"

FOLIO = "97"
PROVEEDOR = "Farmalive"
FECHA = "2026-09-10"
TOTAL_TICKET = 2483.41
PIEZAS_ESPERADAS = 62

# descripcion ticket, qty, subtotal_neto, ean
# Pharmaton: 2 líneas promo @$0.01 → 2 pzas / $0.02
RAW = [
    ("PAÑUELOS KLEENEX PACK C/8 | KIMBERLY CLARK", 1, 32.83, "7501017362998"),
    ("ANT (WA) TERRAMICINA TROCISCOS C/24 | UPJOHN PHARMA", 2, 373.18, "7501287630506"),
    ("MOUSSE HERBAL ESSENCES RIZOS 200 R 2PACK | PG PERF", 1, 114.95, "7500435182041"),
    ("AGUA OXIGENADA DERMOCLEEN 480ML | DEGASA", 3, 44.10, "7501048335305"),
    ("ENJ BUCAL ORAL B 100% 250 ML | P&G PERF", 3, 147.88, "7500435179980"),
    ("ENJ BUCAL ORAL B COMPLET 250 ML | PG PERF", 2, 98.00, "7891051037878"),
    ("ALMOHADILLAS RETANGULARES QUIRMEX C/100 | QUIRMEX", 2, 65.66, "7506552900247"),
    ("TORUNDA DE ALGODON QUIRMEX 75 GR | QUIRMEX", 4, 70.17, "7503003406785"),
    ("TORUNDA PROTEC C/150 BOLITAS | DEGASA", 2, 40.38, "7501048621408"),
    ("TOA SANIT ALWAYS NOC ALAS C/8 | P&G PERF", 2, 54.49, "056100024798"),
    ("PROTECTORES SABA TRADICIONAL LARGO C/28 | SCA", 2, 51.55, "7501019068911"),
    ("COND SICO ROJO FEEL CART C/3 | RB HEALTH", 1, 62.23, "7501058368126"),
    ("TARMIN 2 MG C/12 TAB | BRULUAGSA", 3, 19.11, "7502208891549"),
    ("CEPILLO ORAL-B COMPLET MED 2X1 | PG PERF", 2, 60.76, "7501006719932"),
    ("CEPILLO ORAL-B CLASICO 60 SUAVE | PG PERF", 2, 45.86, "7501086494286"),
    ("CRE HINDS ROSA RESECA 230 ML | GRISI HNOS", 1, 35.28, "037836041266"),
    ("AGUA OXIGENADA DERMOCLEEN 230ML | DEGASA", 3, 30.58, "7501048335169"),
    ("CRE HINDS NAT RESECA 230 ML | GRISI HNOS", 1, 35.28, "037836041358"),
    ("MICRODACYN 60 SOL 120 ML | MORE PHARMA", 1, 168.56, "7503006698316"),
    ("CRE DEPILADORA NAIR P SENSIBLE 150 ML | CHURCH & DWIGHTND", 1, 81.60, "7501080921139"),
    # EAN-13 con dígito verificador (el ticket imprime 12; el catálogo ya tiene 13).
    ("SUEROX VITAMINS MANZANA V-LIMON 630 ML | GENOMMA LAB", 2, 29.45, "6502400721541"),
    ("SUEROX 8IONES UVA 630 ML | GENOMMA LAB", 2, 29.45, "6502400322712"),
    ("VASO RECOLECTOR DIBAR 100ml | DIBAR", 5, 24.99, "7501868950702"),
    ("VASO RECOLECTOR QUIRMEX | QUIRMEX", 4, 14.90, "7506552900322"),
    ("BUSCAPINA FEM TAB C/10 | OPELLA", 3, 391.02, "7501165011656"),
    ("PHARMATON COMPLETE TAB C/100 | OPELLA", 2, 0.02, "3664798062243"),
    ("IV NEOMELUBRINA TAB C/10 | OPELLA", 5, 361.13, "7501165000230"),
]


def rows() -> list[dict]:
    out = []
    for nombre, qty, sub, ean in RAW:
        out.append(
            {
                "nombre": nombre,
                "qty": qty,
                "sub": sub,
                "pu": round(sub / qty, 2),
                "ean": ean,
                "sku": "",
                "match": "ticket",
            }
        )
    return out


def main() -> None:
    data = rows()
    write_ticket_csv(
        OUT_CSV,
        folio=FOLIO,
        fecha=FECHA,
        proveedor=PROVEEDOR,
        total=TOTAL_TICKET,
        rows=data,
    )
    write_recepcion_sql(
        OUT_SQL,
        folio=FOLIO,
        proveedor=PROVEEDOR,
        proveedor_ilike="farmalive",
        fecha=FECHA,
        total=TOTAL_TICKET,
        notas=(
            f"Pedido Farmalive {FOLIO} · Club Iztapalapa 1 · "
            "EAN del ticket · precio neto (2%/5%/15%) · Pharmaton promo consolidada · "
            "cola Recibir; stock al confirmar pistola"
        ),
        rows=data,
    )
    suma = sum(r["sub"] for r in data)
    piezas = sum(r["qty"] for r in data)
    print(report(data, TOTAL_TICKET))
    print(f"piezas={piezas} esperado={PIEZAS_ESPERADAS} ok={piezas == PIEZAS_ESPERADAS}")
    print(f"suma=${suma:.2f} total=${TOTAL_TICKET:.2f} delta={suma - TOTAL_TICKET:.2f}")
    print(f"lineas={len(data)} (28 impresas; Pharmaton 2 líneas promo → 1 renglón)")
    print(f"csv={OUT_CSV}")
    print(f"sql={OUT_SQL}")
    if piezas != PIEZAS_ESPERADAS or abs(suma - TOTAL_TICKET) >= 0.02:
        raise SystemExit("totales no cuadran")


if __name__ == "__main__":
    main()
