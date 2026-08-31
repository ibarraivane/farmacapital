#!/usr/bin/env python3
"""Pedido Nadro 1658128647824-01 (preparando, entrega mañana) → cola Recibir.

PDF del portal i22.nadro.mx. Sin lote ni MMAA. Dos nombres salieron cortados
en el pantallazo (IRBES y COMP B): se dejan así, no se adivina presentación.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_recepcion_sql, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_nadro_1658128647824.csv"
OUT_SQL = ROOT / "sql" / "patch_recepcion_nadro_1658128647824_corroborar.sql"

FOLIO = "1658128647824-01"
PROVEEDOR = "Nadro"
FECHA = "2026-08-30"
TOTAL_TICKET = 5617.17

# nombre, qty, subtotal, ean, sku, match
RAW = [
    ("OMEPRAZOL 20 MG FCO 60 CAPS LGEN", 2, 53.64, "", "", "sin_ean"),
    ("OMEPRAZOL 20 MG 14 CAPS LGEN", 2, 19.00, "", "", "sin_ean"),
    ("OMEPRAZOL 20MG 30 CAPS LGEN", 2, 32.26, "", "", "sin_ean"),
    ("IRBES (nombre cortado en el PDF)", 3, 178.98, "", "", "nombre_cortado"),
    ("IRBESARTAN 150MG 14 TAB LGEN", 2, 100.00, "", "", "sin_ean"),
    ("IRBESARTAN 150MG FCO 28 TAB LGEN", 2, 194.84, "", "", "sin_ean"),
    ("IRBESARTAN 150MG 28 TAB LGEN", 2, 184.72, "", "", "sin_ean"),
    ("Irbesartán + Hidroclorotiazida Camber 150/12.5 mg C/28", 1, 91.86, "", "", "sin_ean"),
    ("Talco Odolex Fresh 150 g", 1, 15.82, "7501361124013", "FC-61124013", "catalogo"),
    ("DOXICICLIN 100MG 10CAPS KEN LGEN", 1, 23.86, "", "", "sin_ean"),
    ("Roxidolin Doxiciclina 100 mg C/10", 1, 21.15, "", "", "sin_ean"),
    ("Oxitetraciclina 500 mg C/16 cápsulas", 2, 140.00, "", "", "sin_ean"),
    ("Klarix Claritromicina 250 mg C/10", 2, 89.76, "", "", "sin_ean"),
    ("Cefuroxima 750 mg FA + ampolleta 5 ml", 2, 85.12, "", "", "sin_ean"),
    ("CEFALOTINA 1G S INY FA 5ML LGEN", 2, 112.56, "", "", "sin_ean"),
    ("PIOGLITAZONA 15 MG 7 TAB LGEN", 3, 40.05, "", "", "sin_ean"),
    ("Bactrim F 800/160 mg 15 tabletas", 1, 331.87, "", "", "sin_ean"),
    ("OMEPRAZOL 40MG S.INY. AMP LGEN", 1, 29.06, "", "", "sin_ean"),
    ("Bactrim 200/40 mg suspensión 100 ml", 1, 188.44, "", "", "sin_ean"),
    ("Labello Fresa 4.8 g", 2, 109.74, "7501054507901", "FC-45079011", "catalogo"),
    ("Labello Clásico 4.8 g", 2, 109.74, "7501054504870", "FC-54504870", "catalogo"),
    ("CeraVe gel limpiador control imperfecciones 236 ml", 1, 273.91, "", "", "sin_ean"),
    ("Oxímetro Inhala Care pulso dedo FS10E", 1, 303.80, "", "", "sin_ean"),
    ("Toallas húmedas Tena para adulto", 1, 55.00, "", "", "sin_ean"),
    ("Crema corporal Nivea Milk", 4, 103.44, "7501054558682", "FC-54558682", "catalogo"),
    ("Labello Med Protection 4.8 g", 1, 54.87, "", "", "sin_ean"),
    ("Labello Caring Beauty Red 4.8 g", 1, 79.58, "", "", "sin_ean"),
    ("DEFLAZACORT 30 MG 10 TAB LGEN", 1, 110.89, "", "", "sin_ean"),
    ("Rexona Men Clinical Clean stick 46 g", 7, 389.76, "75073114", "", "ean_publico"),
    ("Suerox 8 iones Lima-Limón 630 ml", 1, 12.42, "6502400323252", "FC-40032325", "catalogo"),
    ("Rexona Women Clinical Classic stick 46 g", 3, 167.04, "", "", "sin_ean"),
    ("Electrolife Zero Uva 625 ml", 2, 38.72, "", "", "sin_ean"),
    ("Tampones Saba Compactos Super", 1, 31.39, "", "", "sin_ean"),
    ("Alli Triple 50/.25/50/50 mg C/6", 3, 239.61, "", "", "sin_ean"),
    ("Eucerin pH5 (nombre cortado en el PDF)", 1, 85.20, "", "", "nombre_cortado"),
    ("COMP B (nombre cortado en el PDF)", 1, 55.76, "", "", "nombre_cortado"),
    ("Parches Saba térmicos C/3", 1, 57.41, "", "", "sin_ean"),
    ("Picot-Plus 9 sobres polvo efervescente", 1, 46.12, "", "", "sin_ean"),
    ("Panty protector Saba largo C/28", 1, 27.28, "", "", "sin_ean"),
    ("PIOGLITAZONA 30MG 7 TAB LGEN", 6, 106.56, "", "", "sin_ean"),
    ("Gentamicina 160 mg solución inyectable 2 ml Amsa", 1, 12.71, "", "", "sin_ean"),
    ("Buscapina 10 mg 24 grageas", 2, 344.08, "7501165011649", "", "ean_publico"),
    ("Buscapina Duo 10/500 mg C/10", 1, 122.36, "", "", "sin_ean"),
    ("Vitacilina ungüento 16 g", 2, 50.38, "", "", "sin_ean"),
    ("Vitacilina ungüento 28 g", 3, 112.71, "", "", "sin_ean"),
    ("Syncol 500/25/15 mg 12 comprimidos", 1, 97.12, "", "", "sin_ean"),
    ("Flanax 550 mg 6 tabletas", 1, 105.00, "7501008498866", "", "ean_publico"),
    ("Barmicil compuesto crema 40 g", 1, 21.08, "7502001166066", "FC-01166066", "catalogo"),
    ("Flanax Nocto 220/25 mg 20 comprimidos", 1, 130.50, "", "", "sin_ean"),
    ("Flanax 660 mg 8 tabletas", 1, 230.00, "", "", "sin_ean"),
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
        proveedor_ilike="nadro",
        fecha=FECHA,
        total=TOTAL_TICKET,
        notas=f"Pedido Nadro {FOLIO} · entrega 31-ago · cola Recibir; stock al confirmar pistola",
        rows=r,
    )
    print(f"csv  {OUT_TICKET}")
    print(f"sql  {OUT_SQL}")
    print(report(r, TOTAL_TICKET))
