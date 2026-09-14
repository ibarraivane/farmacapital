#!/usr/bin/env python3
"""Pares curados: ficha pobre sin EAN (carga inicial) → ficha completa que ya existe.

No suma stock al desactivar: en varios el mismo lote se contó en los dos SKUs.
"""
from __future__ import annotations

import csv
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPORTE = ROOT / "pricing" / "reportes"
HOY = date.today().isoformat().replace("-", "")

# sku_pobre, nombre_pobre, stock_pobre, sku_bueno, nombre_bueno, ean, stock_bueno, nota
DUPLICADOS = [
    ("FC-A0D320D1", "Amoxicilina 500 mg 12 cápsulas", 5,
     "FC-49021570", "Amoxicilina 500 mg Caja con 12 cápsulas AMSA", "7501349021570", 4,
     "Misma caja AMSA. La ficha pobre es solo el genérico."),
    ("FC-022543CD", "Valclan 500/125 mg 10 tabletas", 3,
     "FC-01007199", "Valclan 500 mg / 125 mg Caja con 10 tabletas Wandel", "7503001007199", 3,
     "Misma presentación 500/125. No confundir con Valclan 875."),
    ("FC-7D1D9857", "Acetilsalicilico 100 mg 30 tabletas", 5,
     "FC-42803524", "Ácido acetilsalicílico 100 mg Caja con 30 tabletas beadvance", "7501342803524", 5,
     "Es AAS 100 mg, no Aspirina 500. El EAN de Aspirina ya se le había quitado."),
    ("FC-95779436", "Ácido acetilsalicílico efervescente 300 mg C/20", 5,
     "EQ-ALP0300", "Acido Acetilsalicilico Ef 20 Tab 300 Mg", "7501384504908", 5,
     "Misma caja Psicofarma 300 mg × 20."),
    ("FC-B25B4654", "Cina (Ciprofloxacino) 750 mg 7 tabletas", 2,
     "FC-52200809", "Cina 750 mg Caja con 7 tabletas Landsteiner", "7502225092486", 2,
     "Cina es levofloxacino; la ficha pobre puso ciprofloxacino."),
    ("FC-6C2878CF", "Budenova budesonida 0.125 mg/ml 5 amp × 2 ml", 1,
     "EQ-NOV165", "Budenova Susp .125 Mg/Ml 5 Amp 2ml", "7501075726251", 1,
     "Misma Budenova Novag."),
    ("FC-26EA40A4", "Raamcinet cetirizina 10 mg C/10", 6,
     "FC-27872123", "Raamcinet cetirizina 10 mg", "7502227872123", 4,
     "Misma caja C/10. Stocks 6 y 4: probable doble conteo."),
    ("FC-44B6751A", "LAÜR Adulto solución inyectable C/3", 1,
     "EQ-SON264", "Laur Solución Inyectable", "7502001166981", 1,
     "Adulto. El infantil (7502001167001) es otro SKU."),
    ("FC-1321B34F", "Hidroxin hidroxizina 10 mg C/30", 1,
     "EQ-MAI099", "Hidroxin", "785120754681", 1,
     "Misma Hidroxin Mavi 10 mg C/30."),
    ("FC-AA7B0686", "Drosequim Adulto jarabe 300/160 mg 200 ml", 1,
     "EQ-QUM070", "Drosequim Ad 1 Jbe 300/160/200 Ml", "7502223111400", 1,
     "Mismo jarabe adulto Quimpharma."),
    ("FC-926099D3", "Merthiolate Rojo Kohn 20 ml", 5,
     "FC-46601138", "Merthiolate Rojo Kohn 20 ml", "7506346601138", 5,
     "Mismo nombre. Stocks 5 y 5: probable doble conteo."),
    ("EQ-MAV401", "Dexpantenol 1 Cma 5% 30 G", 2,
     "FC-09749421", "Dexpantenol crema 5% 30 g (Maver Tattoo)", "7502009749421", 2,
     "Misma crema Maver 5% 30 g. Pamedan es otra marca."),
    ("EQ-BRL072-1", "Lo Bruquin 2 Tab 150/200 Mg", 10,
     "EQ-BRL072", "Lo Bruquin Quinfamida, Albendazol", "7502208894915", 10,
     "SKU -1 sin EAN. Ambos con stock 10: el mismo lote contado dos veces."),
    ("FMX-501619", "Eucalin-Miel Jarabe C/120 Ml", 1,
     "FC-08100013", "Eucalín jarabe miel y propóleo 120 ml", "714908100013", 1,
     "Carga Farma MX vs ficha completa."),
    ("FMX-502465", "Colageno-Naturex Tabletas C/60", 1,
     "FC-9741524", "Naturex colágeno hidrolizado tabletas C/60", "7502009741524", 1,
     "Carga Farma MX vs ficha Naturex."),
    ("FMX-301136", "Cintapore cinta microporosa piel 2.5 cm x 5 m", 2,
     "FC-84500546", "Cintapore cinta microporosa piel 2.5 cm x 5m", "7506484500546", 0,
     "El de EAN tiene stock 0: pasar las 2 piezas a ese SKU."),
    ("FMX-501000", "Gelcavit-Colors Capsulas C/30", 1,
     "FC-30713547", "Gelcavit Colors capsulas 0.62 g C/30", "7501130713547", 1,
     "Misma variante Colors."),
    ("FMX-500998", "Gelcavit-Platinum Capsulas C/30", 1,
     "FC-30713851", "Gelcavit Platinum capsulas 1.39 g C/30", "7501130713851", 1,
     "Misma variante Platinum."),
    ("FMX-501003", "Gelcavit-Q-10 Capsulas C/30", 1,
     "FC-13071164", "Gelcavit Q-10 coenzima Q10 jalea real C/30", "7501130711642", 1,
     "Misma variante Q-10."),
    ("FMX-505937", "Pleniform-40 Tabletas C/30", 1,
     "FC-1041884", "Biomiral Pleniform 40 isoflavonas soya C/30", "7503181041884", 1,
     "Mismo Pleniform 40."),
    ("FMX-302947", "Citrato Magnesio/Lecitina Soya-Naturex Capsulas C/30", 1,
     "FC-9892403", "Naturex citrato de magnesio y lecitina de soya C/30", "7502259892403", 2,
     "Misma Naturex citrato + lecitina."),
    ("FMX-506935", "Normogotero-Sensimedical Piezas C/1 S/Aguja", 5,
     "FC-22322395", "Normogotero Sensi Medical", "7506022322395", 5,
     "Mismo gotero. Stocks 5 y 5: probable doble conteo."),
    ("FC-89F00320", "Mercurio Arnica C/25", 5,
     "FC-00003920", "Arnica Mercurio", "3311000003944", 8,
     "Árnica Mercurio en glóbulos C/25."),
]

# Sin EAN pero NO son el mismo producto que otro SKU (les falta código, no desactivar).
UNICOS_SIN_EAN = [
    ("FC-DB4A39AE", "Eferox (Cefalexina) 500 mg 12 comprimidos", 1, "No hay otra Eferox. Solo falta EAN."),
    ("FC-63975795", "Gentamicina 1 mg 25 comprimidos", 3, "No es la gentamicina inyectable 160 mg AMSA."),
    ("FC-262F2A30", "Irbesartan 150 mg 14 tabletas AMSA", 3, "Los LGEN son 28 tabletas; AMSA 300 mg es otra dosis."),
    ("FC-2E5B7248", "Reumatol 60 g", 2, "Único. Sin pareja con EAN."),
    ("FC-3E863E37", "Tratidri gel 500/50 mg 60 g", 1, "Único."),
    ("FC-405A75E3", "Ursodesoxicolico 250 mg 50 cápsulas", 1, "Único."),
    ("EQ-SON225", "Norkin 7 Caps 40 Mg", 2, "Único."),
    ("EQ-AMS234", "Pregabalina 150 mg C/28 cápsulas AMSA", 1, "Hay 75 mg con EAN; esta dosis 150 no."),
    ("FC-C22EBFE6", "Perilla N2", 2, "Tamaño distinto a la N1 (sí tiene EAN)."),
    ("FC-614E4F82", "Perilla N3", 2, "Tamaño distinto a la N1."),
    ("FC-FFC25DD1", "Perilla N4", 2, "Tamaño distinto a la N1."),
    ("FC-A871D831", "Perilla N6", 2, "Tamaño distinto a la N1."),
    ("FC-9A1C64E7", "Perilla Edigar N O Caja", 2, "Revisar si es caja o pieza; no es la N1."),
    ("FC-C8B741F6", "FC producto botiquín", 2, "Ficha vacía. Identificar qué pieza es."),
    ("FMX-301721", "Vita/Kid/C Jarabe C/240 Ml", 1, "Único."),
    ("FMX-302884", "Sol-Sun Crema C/50 Gr 50-Fps", 2, "Único."),
    ("FMX-502700", "La-Femme Capsulas C/30", 1, "Único."),
    ("FMX-301138", "Cinta-Microporosa-Codifarma 2.5 cm × 5 m blanco", 17, "Otra marca (Codifarma), no Cintapore."),
]


def escribir_xlsx(path: Path) -> None:
    from openpyxl import Workbook
    from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
    from openpyxl.utils import get_column_letter

    wb = Workbook()
    fill_h = PatternFill("solid", fgColor="1A1A1A")
    font_h = Font(name="Calibri", bold=True, color="FFFFFF", size=10)
    thin = Border(
        left=Side(style="thin", color="DDDDDD"),
        right=Side(style="thin", color="DDDDDD"),
        top=Side(style="thin", color="DDDDDD"),
        bottom=Side(style="thin", color="DDDDDD"),
    )
    fill_alt = PatternFill("solid", fgColor="FFF8E7")
    fill_pass = PatternFill("solid", fgColor="D5F5E3")

    def header(ws, headers):
        for i, h in enumerate(headers, 1):
            c = ws.cell(1, i, h)
            c.fill = fill_h
            c.font = font_h
            c.alignment = Alignment(wrap_text=True, vertical="center")
        ws.freeze_panes = "A2"
        ws.row_dimensions[1].height = 24
        ws.auto_filter.ref = f"A1:{get_column_letter(len(headers))}1"

    res = wb.active
    res.title = "Resumen"
    res["A1"] = "SKUs sin código de barras que ya existen (carga inicial)"
    res["A1"].font = Font(name="Calibri", bold=True, size=16)
    res.merge_cells("A1:B1")
    res["A2"] = (
        "Son las fichas de agosto (hex FC-… / FMX / EQ-…) con poco o ningún dato. "
        "La pieza ya está en el catálogo con EAN y nombre de mostrador. "
        "Desactiva la ficha pobre. No sumes stock: en varios el mismo lote se contó dos veces "
        "(Lo Bruquin 10+10, Merthiolate 5+5, Raamcinet 6+4, Normogotero 5+5)."
    )
    res.merge_cells("A2:B5")
    res["A2"].alignment = Alignment(wrap_text=True, vertical="top")
    filas = [
        ("Fecha", date.today().isoformat()),
        ("Duplicados confirmados (desactivar el sin EAN)", len(DUPLICADOS)),
        ("Sin EAN pero únicos (solo falta código)", len(UNICOS_SIN_EAN)),
        ("Único caso para pasar stock", "Cintapore FMX-301136 → FC-84500546 (el de EAN tiene 0)"),
    ]
    res["A7"] = "Métrica"
    res["B7"] = "Valor"
    for col in range(1, 3):
        res.cell(7, col).fill = fill_h
        res.cell(7, col).font = font_h
    for i, (a, b) in enumerate(filas, start=8):
        res.cell(i, 1, a)
        res.cell(i, 2, b)
    res.column_dimensions["A"].width = 64
    res.column_dimensions["B"].width = 56

    ws = wb.create_sheet("DESACTIVAR_ya_existen")
    headers = [
        "Acción", "SKU sin EAN (quitar)", "Nombre pobre", "Stock pobre",
        "SKU que se queda", "Nombre completo", "EAN", "Stock del bueno",
        "¿Pasar stock?", "Nota",
    ]
    header(ws, headers)
    for r_i, row in enumerate(DUPLICADOS, start=2):
        pobre, nom_p, stk_p, bueno, nom_b, ean, stk_b, nota = row
        pasar = "SÍ — el de EAN tiene 0" if stk_b == 0 else "NO — no sumar (posible doble conteo)"
        vals = ["Desactivar ficha pobre", pobre, nom_p, stk_p, bueno, nom_b, ean, stk_b, pasar, nota]
        for c_i, v in enumerate(vals, 1):
            cell = ws.cell(r_i, c_i, v)
            cell.border = thin
            if r_i % 2 == 0:
                cell.fill = fill_alt
            if c_i == 9 and stk_b == 0:
                cell.fill = fill_pass
    widths = [22, 16, 44, 12, 16, 52, 16, 14, 36, 56]
    for i, w in enumerate(widths, 1):
        ws.column_dimensions[get_column_letter(i)].width = w
    ws.auto_filter.ref = f"A1:J{len(DUPLICADOS)+1}"

    ws2 = wb.create_sheet("UNICOS_falta_EAN")
    header(ws2, ["SKU", "Nombre", "Stock", "Por qué no es duplicado"])
    for r_i, row in enumerate(UNICOS_SIN_EAN, start=2):
        for c_i, v in enumerate(row, 1):
            cell = ws2.cell(r_i, c_i, v)
            cell.border = thin
            if r_i % 2 == 0:
                cell.fill = fill_alt
    for i, w in enumerate([16, 52, 10, 56], 1):
        ws2.column_dimensions[get_column_letter(i)].width = w

    path.parent.mkdir(parents=True, exist_ok=True)
    wb.save(path)


def escribir_csv(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow([
            "accion", "sku_pobre", "nombre_pobre", "stock_pobre",
            "sku_bueno", "nombre_bueno", "ean", "stock_bueno", "pasar_stock", "nota",
        ])
        for row in DUPLICADOS:
            pobre, nom_p, stk_p, bueno, nom_b, ean, stk_b, nota = row
            pasar = "si" if stk_b == 0 else "no"
            w.writerow(["desactivar", pobre, nom_p, stk_p, bueno, nom_b, ean, stk_b, pasar, nota])


def escribir_sql(path: Path) -> None:
    lines = [
        "-- Desactiva fichas pobres sin EAN que ya existen con código de barras.",
        "-- NO suma stock (salvo Cintapore: el de EAN tiene 0).",
        "-- Revisar anaquel antes de correr. Idempotente: solo toca si sigue activo y sin EAN.",
        "begin;",
        "",
    ]
    for pobre, nom_p, stk_p, bueno, nom_b, ean, stk_b, nota in DUPLICADOS:
        lines.append(f"-- {pobre} ({nom_p}, stk {stk_p}) → {bueno} / {ean}")
        lines.append(f"-- {nota}")
        if stk_b == 0 and stk_p:
            lines += [
                "update public.productos p",
                "   set stock = coalesce(p.stock, 0) + (",
                "     select coalesce(stock, 0) from public.productos",
                f"      where sku = '{pobre}' and activo = true",
                "       and (codigo_barras is null or btrim(codigo_barras) = '')",
                "   )",
                f" where p.sku = '{bueno}';",
            ]
        lines += [
            "update public.productos",
            "   set activo = false",
            f" where sku = '{pobre}'",
            "   and activo = true",
            "   and (codigo_barras is null or btrim(codigo_barras) = '');",
            "",
        ]
    lines.append("commit;")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    tag = HOY
    xlsx = REPORTE / f"duplicados_sin_barcode_{tag}.xlsx"
    csv_p = REPORTE / f"duplicados_sin_barcode_{tag}.csv"
    sql_p = ROOT / "sql" / f"patch_desactivar_duplicados_sin_barcode_{tag}.sql"
    escribir_xlsx(xlsx)
    escribir_csv(csv_p)
    escribir_sql(sql_p)
    print(xlsx)
    print(csv_p)
    print(sql_p)
    print("duplicados", len(DUPLICADOS), "unicos_sin_ean", len(UNICOS_SIN_EAN))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
