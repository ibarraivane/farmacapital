#!/usr/bin/env python3
"""Pedido Exprezo / Zorro 1279718 (entrega 31-ago) → cola Recibir.

PDF de Mis compras. Sin lote ni MMAA: salen de la caja al escanear.
El cargo de surtido ($97) no es producto; va en el total del ticket.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_recepcion_sql, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_exprezo_1279718.csv"
OUT_SQL = ROOT / "sql" / "patch_recepcion_exprezo_1279718_corroborar.sql"

FOLIO = "1279718"
PROVEEDOR = "Exprezo"
FECHA = "2026-08-30"
TOTAL_TICKET = 1981.55
SURTIDO = 97.00

# nombre, qty, subtotal, ean, sku, match
RAW = [
    ("Jabón Palmolive Naturals Neutro Balance 100 g 8 Pack", 1, 114.40, "", "", "sin_ean"),
    ("Tira Shampoo Head & Shoulders 24 sachets 10 ml", 1, 51.21, "", "", "sin_ean"),
    ("Shampoo Caprice Acti-Ceramidas 200 ml", 1, 19.30, "7509546073033", "FC-46073033", "catalogo"),
    ("Pack 48 sobres Shampoo Palmolive Optims 10 ml", 1, 75.30, "", "", "sin_ean"),
    ("Flanax 550 mg 12 Tabs", 3, 568.96, "7501008497340", "FC-84973401", "catalogo"),
    ("Gerber Etapa 2 Manzana 100 g", 3, 32.04, "7506475102421", "", "ean_publico"),
    ("Gerber Etapa 2 Mango 100 g", 3, 32.04, "", "", "sin_ean"),
    ("Gerber Etapa 2 Pera 100 g", 3, 32.04, "", "", "sin_ean"),
    ("Gerber Etapa 2 Durazno 100 g", 3, 32.04, "", "", "sin_ean"),
    ("Gerber Etapa 2 Comida Casera Pollo 100 g", 4, 42.72, "", "", "sin_ean"),
    ("Gerber Etapa 2 Comida Casera Res 100 g", 4, 42.72, "", "", "sin_ean"),
    ("Papilla Heinz Pouch Manzana 113 g", 3, 43.19, "", "", "sin_ean"),
    ("GERBER POUCH JR FRUT MIXT 95 g", 3, 38.38, "", "", "sin_ean"),
    ("Enfagrow Premium Etapa 3 lata 800 g", 1, 306.00, "7506205809248", "", "ean_publico"),
    ("Alliviax Desinflamatorio 550 mg C/10", 3, 301.50, "650240013805", "", "ean_publico"),
    ("Jabón Dove blanco 90 g", 6, 111.80, "7506306246652", "", "ean_publico"),
    ("Jabón Escudo Azul 135 g", 3, 40.94, "7506425652716", "FC-25652716", "catalogo"),
]


def rows():
    out = []
    for nombre, qty, sub, ean, sku, match in RAW:
        out.append({
            "nombre": nombre,
            "qty": qty,
            "sub": sub,
            "pu": round(sub / qty, 2),
            "ean": ean,
            "sku": sku,
            "match": match,
        })
    return out


if __name__ == "__main__":
    r = rows()
    write_ticket_csv(OUT_TICKET, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL_TICKET, rows=r)
    write_recepcion_sql(
        OUT_SQL,
        folio=FOLIO,
        proveedor=PROVEEDOR,
        proveedor_ilike="exprezo",
        fecha=FECHA,
        total=TOTAL_TICKET,
        notas=f"Pedido Exprezo {FOLIO} · entrega 31-ago · cola Recibir; stock al confirmar pistola · surtido ${SURTIDO:.0f} no es renglón",
        rows=r,
    )
    suma = sum(x["sub"] for x in r)
    print(f"csv  {OUT_TICKET}")
    print(f"sql  {OUT_SQL}")
    print(report(r, TOTAL_TICKET))
    print(f"productos ${suma:.2f} + surtido ${SURTIDO:.2f} = ${suma + SURTIDO:.2f} (ticket ${TOTAL_TICKET:.2f})")
