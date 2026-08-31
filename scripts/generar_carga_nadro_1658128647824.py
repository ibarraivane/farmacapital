#!/usr/bin/env python3
"""Pedido Nadro 1658128647824-01 (preparando, entrega mañana) → cola Recibir.

EAN tomados de iNadro intelligent-search (2026-08-31), nombre oficial del portal.
Sin lote ni MMAA: salen de la caja al escanear.
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

# nombre oficial iNadro, qty, subtotal, ean portal, sku FarmaCapital, match
RAW = [
    ("OMEPRAZOL 20 MG FCO 60 CAPS LGEN", 2, 53.64, "7502216803800", "FC-16803800", "nadro"),
    ("OMEPRAZOL 20 MG 14 CAPS LGEN", 2, 19.00, "7502216792555", "", "nadro"),
    ("OMEPRAZOL 20MG 30 CAPS LGEN", 2, 32.26, "7502216792760", "", "nadro"),
    ("IRBESARTAN 300 MG 28 TAB LGEN", 3, 178.98, "7506442700629", "", "nadro"),
    ("IRBESARTAN 150MG 14 TAB LGEN", 2, 100.00, "7501349022454", "FC-262F2A30", "nadro"),
    ("IRBESARTAN 150MG FCO 28 TAB LGEN", 2, 194.84, "7502216804708", "", "nadro"),
    ("IRBESARTAN 150MG 28 TAB LGEN", 2, 184.72, "7501349022492", "", "nadro"),
    ("Irbesartán + Hidroclorotiazida Camber 150 mg + 12.5 mg Caja Con 28 Tabletas Genérico", 1, 91.86, "7506442700643", "", "nadro"),
    ("TCO ODOLEX FRESH 150G", 1, 15.82, "7501361124013", "FC-61124013", "nadro"),
    ("DOXICICLIN 100MG 10CAPS KEN LGEN", 1, 23.86, "7501493888302", "", "nadro"),
    ("Roxidolin Doxiciclina 100 mg Caja Con 10 Cápsulas", 1, 21.15, "7502227870259", "", "nadro"),
    ("Oxitetraciclina Caja Con 16 Cápsulas De 500 mg", 2, 140.00, "7502227879597", "", "nadro"),
    ("Klarix Claritromicina De 250 mg Caja Con 10 Tabletas", 2, 89.76, "7502009740442", "", "nadro"),
    ("Cefuroxima Caja Con Frasco Ámpula Con Polvo De 750mg y Ampolleta De 5ml", 2, 85.12, "7501125195105", "", "nadro"),
    ("CEFALOTINA 1G S INY FA 5ML LGEN", 2, 112.56, "7501349022768", "", "nadro"),
    ("PIOGLITAZONA 15 MG 7 TAB LGEN", 3, 40.05, "7502216796737", "EQ-ULT146", "nadro"),
    ("Bactrim F 800/160 Mg 15 Tabletas", 1, 331.87, "7501300450210", "", "nadro"),
    ("OMEPRAZOL 40MG S.INY. AMP LGEN", 1, 29.06, "7501349028234", "", "nadro"),
    ("Bactrim 200/40 Mg Suspensión 100 Ml", 1, 188.44, "7501300450227", "", "nadro"),
    ("POM LAB LABELLO FRESA 4.8 G", 2, 109.74, "7501054507901", "FC-45079011", "nadro"),
    ("POM LAB LABELLO CLAS 4.8G", 2, 109.74, "7501054504870", "FC-54504870", "nadro"),
    ("GEL CERAVE LIMP CONTR IMPER 236ML", 1, 273.91, "3337875784054", "", "nadro"),
    ("Oxímetro Inhala Care Pulso Dedo Pantalla Led FS10E", 1, 303.80, "7502256729917", "", "nadro"),
    ("TAS HUM TENA PARA ADULTO EG C", 1, 55.00, "7501019050473", "", "nadro"),
    ("CRA CORP NIV MILK N EX", 4, 103.44, "7501054549796", "FC-54549796", "nadro"),
    ("POM LAB LABELLO MED PROT4.8G", 1, 54.87, "7501054503637", "", "nadro"),
    ("POM LAB LABELLO CARING-B RED 4.8G", 1, 79.58, "4005900948670", "", "nadro"),
    ("DEFLAZACORT 30 MG 10 TAB LGEN", 1, 110.89, "7501349013223", "", "nadro"),
    ("DESOD REX MEN CLIN CLEAN STICK 46G", 7, 389.76, "75073114", "", "nadro"),
    ("SUEROX 8IONES LIMA-LIMON 630ML", 1, 12.42, "6502400323252", "FC-40032325", "nadro"),
    ("DESOD REX WOM CLIN CLASS STICK 46G", 3, 167.04, "75073107", "", "nadro"),
    ("ELECTROLIFE ZERO UVA 625 ML", 2, 38.72, "7502268541491", "", "nadro"),
    ("TAMPONES SABA COMPACTOS SUPER C", 1, 31.39, "7501019032424", "", "nadro"),
    ("Alli Triple 50/.25/50/50 Mg 6 Tabletas", 3, 239.61, "650240053634", "", "nadro"),
    ("POM LAB EUCERIN PHS P", 1, 85.20, "4005800631702", "", "nadro"),
    ("COMP B", 1, 55.76, "7501349029613", "", "nadro"),
    ("PARCHES SABA TERMICOS 3 PZ", 1, 57.41, "7501019039355", "", "nadro"),
    ("PICOT-PLUS 9 SB PVO EFERV", 1, 46.12, "7501058715913", "", "nadro"),
    ("PANTY PROT SABA LGO 28", 1, 27.28, "7501019068911", "", "nadro"),
    ("PIOGLITAZONA 30MG 7 TAB ULT LGEN", 6, 106.56, "7502216798878", "", "nadro"),
    ("Gentamicina 160 Mg Solución Inyectable 2 Ml Genérico Amsa", 1, 12.71, "7501349026377", "", "nadro"),
    ("BUSCAPINA 10MG 24 GRAG", 2, 344.08, "7501165011649", "", "nadro"),
    ("Buscapina Duo Sanofi Hioscina/Paracetamol 10 mg/500 mg Caja Con 10 Tabletas", 1, 122.36, "7502321440013", "", "nadro"),
    ("VITACILINA 16 G UNG", 2, 50.38, "354312225140", "", "nadro"),
    ("VITACILINA 28 G UNG", 3, 112.71, "354312225133", "", "nadro"),
    ("Syncol 500/25/15 Mg 12 Comprimidos", 1, 97.12, "7501070600709", "", "nadro"),
    ("FLANAX 550 MG 6 TAB", 1, 105.00, "7501008498866", "", "nadro"),
    ("BARMICIL COMP 40 G CRA SON LGEN", 1, 21.08, "7502001166066", "FC-01166066", "nadro"),
    ("Flanax Nocto 220/25 mg 20 Comprimidos", 1, 130.50, "7501008499092", "", "nadro"),
    ("FLANAX-660 660 MG 8 TAB", 1, 230.00, "7501008499412", "", "nadro"),
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
        notas=f"Pedido Nadro {FOLIO} · entrega 31-ago · EAN de iNadro · cola Recibir; stock al confirmar pistola",
        rows=r,
    )
    print(f"csv  {OUT_TICKET}")
    print(f"sql  {OUT_SQL}")
    print(report(r, TOTAL_TICKET))
