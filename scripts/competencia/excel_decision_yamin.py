#!/usr/bin/env python3
"""Genera Excel de decisión FarmaCapital vs Farmacia Yamin.

Pestañas:
  1. Resumen
  2. Ellos sí · Nosotros no
  3. Nosotros más caros
  4. Diff mínima (±5% o ±$5)
  5. Nosotros más baratos
  6. Todos los matches
  7. Revisar (outliers / empaque dudoso)

Uso:
  python3 scripts/competencia/excel_decision_yamin.py \\
    --yamin pricing/reportes/yamin_20261007/yamin_productos.csv \\
    --matches pricing/reportes/yamin_20261007/matches.csv \\
    --fc /tmp/fc_productos.json \\
    --out pricing/reportes/yamin_20261007/FarmaCapital_vs_Yamin_decision.xlsx
"""
from __future__ import annotations

import argparse
import csv
import json
import re
from pathlib import Path

from openpyxl import Workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.formatting.rule import FormulaRule, CellIsRule
from openpyxl.utils import get_column_letter
from openpyxl.worksheet.table import Table, TableStyleInfo

ROOT = Path(__file__).resolve().parents[2]

# Colores FarmaCapital-ish
FILL_HEADER = PatternFill("solid", fgColor="0F172A")
FONT_HEADER = Font(color="FFFFFF", bold=True, name="Calibri", size=11)
FILL_ROJO = PatternFill("solid", fgColor="FEE2E2")
FILL_VERDE = PatternFill("solid", fgColor="DCFCE7")
FILL_AMARILLO = PatternFill("solid", fgColor="FEF9C3")
FILL_AZUL = PatternFill("solid", fgColor="DBEAFE")
FILL_GRIS = PatternFill("solid", fgColor="F1F5F9")
THIN = Border(
    left=Side(style="thin", color="CBD5E1"),
    right=Side(style="thin", color="CBD5E1"),
    top=Side(style="thin", color="CBD5E1"),
    bottom=Side(style="thin", color="CBD5E1"),
)


def num(v):
    try:
        if v is None or v == "":
            return None
        return float(v)
    except Exception:
        return None


def margen_sobre_venta(precio, costo):
    p, c = num(precio), num(costo)
    if p is None or c is None or p <= 0:
        return None
    return round((p - c) / p * 100, 1)


def recargo_sobre_costo(precio, costo):
    p, c = num(precio), num(costo)
    if p is None or c is None or c <= 0:
        return None
    return round((p - c) / c * 100, 1)


def margen_si_igualamos_yamin(yamin_precio, costo):
    """Margen FC si bajáramos al precio de Yamin."""
    return margen_sobre_venta(yamin_precio, costo)


def vs_texto(yamin, fc):
    y, f = num(yamin), num(fc)
    if y is None or f is None:
        return ""
    return f"Yamin ${y:,.2f}  vs  FC ${f:,.2f}"


def accion_caro(row):
    """Sugerencia para filas donde FC es más caro."""
    diff = num(row.get("diff_$")) or 0
    pct = num(row.get("diff_%")) or 0
    margen_actual = num(row.get("margen_fc_%"))
    margen_al_yamin = num(row.get("margen_si_igualamos_yamin_%"))
    costo = num(row.get("costo_fc"))
    yamin = num(row.get("precio_yamin"))

    if abs(pct) >= 150 or abs(diff) >= 200:
        return "Revisar empaque / ficha (outlier)"
    if costo is not None and yamin is not None and costo >= yamin:
        return "No igualar: costo ≥ precio Yamin"
    if margen_al_yamin is not None and margen_al_yamin < 15:
        return "Cuidado: margen <15% si igualamos"
    if margen_al_yamin is not None and margen_al_yamin >= 20 and diff >= 5:
        return "Candidato a bajar hacia Yamin"
    if diff >= 10:
        return "Evaluar baja parcial"
    return "Monitorear"


def accion_barato(row):
    diff = abs(num(row.get("diff_$")) or 0)
    if diff >= 30:
        return "Ventaja fuerte — no subir"
    if diff >= 10:
        return "Ventaja — mantener"
    return "Cerca — mantener"


def style_header(ws, ncols):
    for col in range(1, ncols + 1):
        cell = ws.cell(1, col)
        cell.fill = FILL_HEADER
        cell.font = FONT_HEADER
        cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        cell.border = THIN
    ws.row_dimensions[1].height = 32
    ws.freeze_panes = "A2"
    ws.auto_filter.ref = f"A1:{get_column_letter(ncols)}1"


def autosize(ws, min_w=10, max_w=42):
    for col in ws.columns:
        letter = get_column_letter(col[0].column)
        length = 0
        for cell in col[:80]:
            if cell.value is None:
                continue
            length = max(length, len(str(cell.value)))
        ws.column_dimensions[letter].width = max(min_w, min(max_w, length + 2))


def write_sheet(ws, headers, rows, money_cols=None, pct_cols=None):
    money_cols = set(money_cols or [])
    pct_cols = set(pct_cols or [])
    for j, h in enumerate(headers, 1):
        ws.cell(1, j, h)
    for i, row in enumerate(rows, 2):
        for j, h in enumerate(headers, 1):
            val = row.get(h)
            cell = ws.cell(i, j, val)
            cell.border = THIN
            cell.alignment = Alignment(vertical="center", wrap_text=False)
            if h in money_cols and isinstance(val, (int, float)):
                cell.number_format = '"$"#,##0.00'
            if h in pct_cols and isinstance(val, (int, float)):
                cell.number_format = '0.0"%"'
    style_header(ws, len(headers))
    autosize(ws)
    if rows:
        # zebra light
        for i in range(2, len(rows) + 2):
            if i % 2 == 0:
                for j in range(1, len(headers) + 1):
                    c = ws.cell(i, j)
                    if c.fill.fgColor is None or c.fill.fgColor.rgb == "00000000":
                        c.fill = FILL_GRIS


def load_csv(path: Path):
    with path.open(encoding="utf-8") as f:
        return list(csv.DictReader(f))


def enrich_matches(matches, fc_by_id, fc_by_ean):
    out = []
    for m in matches:
        fc_id = m.get("fc_id")
        p = None
        if fc_id not in (None, ""):
            try:
                p = fc_by_id.get(int(float(fc_id)))
            except Exception:
                p = fc_by_id.get(fc_id)
        if not p:
            ean = re.sub(r"\D", "", str(m.get("yamin_sku") or m.get("fc_ean") or ""))
            p = fc_by_ean.get(ean)

        yamin = num(m.get("yamin_precio"))
        fc_precio = num(m.get("fc_precio"))
        costo = num(m.get("fc_costo"))
        if p:
            if costo is None:
                costo = num(p.get("costo"))
            if fc_precio is None:
                fc_precio = num(p.get("precio"))

        diff = None
        pct = None
        if yamin is not None and fc_precio is not None:
            diff = round(fc_precio - yamin, 2)
            pct = round((fc_precio - yamin) / yamin * 100, 1) if yamin else None

        quien = "igual"
        if diff is not None:
            if diff > 0.01:
                quien = "FC más caro"
            elif diff < -0.01:
                quien = "FC más barato"

        row = {
            "ean": m.get("yamin_sku") or m.get("fc_ean"),
            "nombre_yamin": m.get("yamin_nombre"),
            "nombre_fc": m.get("fc_nombre") or (p or {}).get("nombre"),
            "marca_fc": m.get("fc_marca") or (p or {}).get("marca"),
            "presentacion_fc": (p or {}).get("presentacion"),
            "tipo_fc": m.get("fc_tipo") or (p or {}).get("tipo"),
            "categoria_fc": m.get("fc_categoria") or (p or {}).get("categoria"),
            "depto_yamin": m.get("yamin_departamento"),
            "precio_yamin": yamin,
            "precio_fc": fc_precio,
            "Vs": vs_texto(yamin, fc_precio),
            "diff_$": diff,
            "diff_%": pct,
            "quien": quien,
            "costo_fc": costo,
            "margen_fc_%": margen_sobre_venta(fc_precio, costo),
            "recargo_fc_%": recargo_sobre_costo(fc_precio, costo),
            "margen_si_igualamos_yamin_%": margen_si_igualamos_yamin(yamin, costo),
            "stock_fc": num(m.get("fc_stock") if m.get("fc_stock") not in (None, "") else (p or {}).get("stock")),
            "stock_yamin": num(m.get("yamin_stock")),
            "sku_fc": m.get("fc_sku") or (p or {}).get("sku"),
            "match": m.get("match_type"),
        }
        row["accion_sugerida"] = (
            accion_caro(row) if quien == "FC más caro" else accion_barato(row) if quien == "FC más barato" else "Empate — mantener"
        )
        out.append(row)
    return out


def build_gaps(yamin_sin_match, fc_by_ean):
    """Ellos tienen, nosotros no (por EAN)."""
    rows = []
    for r in yamin_sin_match:
        ean = re.sub(r"\D", "", str(r.get("yamin_sku") or ""))
        # si el "sku" no es EAN numérico largo, igual lo listamos (sueltos)
        ya_en_fc = bool(ean and len(ean) >= 8 and ean in fc_by_ean)
        if ya_en_fc:
            continue
        rows.append(
            {
                "ean_o_codigo_yamin": r.get("yamin_sku"),
                "nombre_yamin": r.get("yamin_nombre"),
                "precio_yamin": num(r.get("yamin_precio")),
                "stock_yamin": num(r.get("yamin_stock")),
                "departamento": r.get("yamin_departamento"),
                "categoria": r.get("yamin_categoria"),
                "nota": (
                    "Código no-EAN (suelto / interno Yamin)"
                    if not ean or len(ean) < 8
                    else "No está en catálogo FC por este EAN"
                ),
                "prioridad": (
                    "Alta"
                    if (num(r.get("yamin_stock")) or 0) >= 20
                    else "Media"
                    if (num(r.get("yamin_stock")) or 0) >= 5
                    else "Baja"
                ),
            }
        )
    rows.sort(key=lambda x: (-(x["stock_yamin"] or 0), -(x["precio_yamin"] or 0)))
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--yamin", type=Path, default=ROOT / "pricing/reportes/yamin_20261007/yamin_productos.csv")
    ap.add_argument("--matches", type=Path, default=ROOT / "pricing/reportes/yamin_20261007/matches.csv")
    ap.add_argument("--sin-match", type=Path, default=ROOT / "pricing/reportes/yamin_20261007/yamin_sin_match_fc.csv")
    ap.add_argument("--fc", type=Path, default=Path("/tmp/fc_productos.json"))
    ap.add_argument(
        "--out",
        type=Path,
        default=ROOT / "pricing/reportes/yamin_20261007/FarmaCapital_vs_Yamin_decision.xlsx",
    )
    args = ap.parse_args()

    matches_raw = load_csv(args.matches)
    sin_match = load_csv(args.sin_match)
    fc = json.loads(args.fc.read_text(encoding="utf-8"))
    fc_by_id = {}
    fc_by_ean = {}
    for p in fc:
        fc_by_id[p.get("id")] = p
        ean = re.sub(r"\D", "", str(p.get("codigo_barras") or ""))
        if len(ean) >= 8:
            fc_by_ean[ean] = p

    enriched = enrich_matches(matches_raw, fc_by_id, fc_by_ean)
    gaps = build_gaps(sin_match, fc_by_ean)

    caros = sorted(
        [r for r in enriched if r["quien"] == "FC más caro"],
        key=lambda r: -(r["diff_$"] or 0),
    )
    baratos = sorted(
        [r for r in enriched if r["quien"] == "FC más barato"],
        key=lambda r: (r["diff_$"] or 0),
    )
    # Diff mínima: |%| <= 5 o |$| <= 5
    minima = sorted(
        [
            r
            for r in enriched
            if r["diff_$"] is not None
            and (abs(r["diff_%"] or 999) <= 5 or abs(r["diff_$"]) <= 5)
        ],
        key=lambda r: abs(r["diff_$"] or 0),
    )
    outliers = sorted(
        [
            r
            for r in enriched
            if r["diff_$"] is not None
            and (abs(r["diff_%"] or 0) >= 150 or abs(r["diff_$"]) >= 200)
        ],
        key=lambda r: -(abs(r["diff_$"] or 0)),
    )

    money = ["precio_yamin", "precio_fc", "diff_$", "costo_fc"]
    pcts = ["diff_%", "margen_fc_%", "recargo_fc_%", "margen_si_igualamos_yamin_%"]
    headers_match = [
        "ean",
        "nombre_yamin",
        "nombre_fc",
        "marca_fc",
        "presentacion_fc",
        "tipo_fc",
        "categoria_fc",
        "depto_yamin",
        "precio_yamin",
        "precio_fc",
        "Vs",
        "diff_$",
        "diff_%",
        "quien",
        "costo_fc",
        "margen_fc_%",
        "recargo_fc_%",
        "margen_si_igualamos_yamin_%",
        "stock_fc",
        "stock_yamin",
        "sku_fc",
        "accion_sugerida",
        "match",
    ]

    wb = Workbook()

    # —— Resumen ——
    ws = wb.active
    ws.title = "Resumen"
    ws["A1"] = "FarmaCapital vs Farmacia Yamin — Herramienta de decisión"
    ws["A1"].font = Font(bold=True, size=16, color="0F172A")
    ws.merge_cells("A1:F1")
    ws["A2"] = "Fuente: farmaciayamin.sicarx.shop · Match por EAN · Márgenes = (precio−costo)/precio"
    ws["A2"].font = Font(italic=True, color="64748B")

    kpis = [
        ("Productos Yamin scrapeados", len(load_csv(args.yamin))),
        ("Matches totales", len(enriched)),
        ("Ellos sí / nosotros no", len(gaps)),
        ("Nosotros más caros", len(caros)),
        ("Diff mínima (±5% o ±$5)", len(minima)),
        ("Nosotros más baratos", len(baratos)),
        ("Outliers a revisar", len(outliers)),
        (
            "Diff mediana (FC−Yamin) en matches",
            (
                sorted([r["diff_$"] for r in enriched if r["diff_$"] is not None])[
                    len([r for r in enriched if r["diff_$"] is not None]) // 2
                ]
                if enriched
                else None
            ),
        ),
        (
            "Candidatos a bajar (acción)",
            sum(1 for r in caros if r["accion_sugerida"] == "Candidato a bajar hacia Yamin"),
        ),
        (
            "No igualar (costo ≥ Yamin)",
            sum(1 for r in caros if r["accion_sugerida"] == "No igualar: costo ≥ precio Yamin"),
        ),
    ]
    ws["A4"] = "KPI"
    ws["B4"] = "Valor"
    style_header(ws, 2)
    for i, (k, v) in enumerate(kpis, 5):
        ws.cell(i, 1, k).border = THIN
        cell = ws.cell(i, 2, v)
        cell.border = THIN
        if isinstance(v, float) and "mediana" in k.lower():
            cell.number_format = '"$"#,##0.00'

    ws["A16"] = "Cómo usar este Excel"
    ws["A16"].font = Font(bold=True, size=12)
    tips = [
        "1. Empieza por «Nosotros más caros»: ordenado por $ de diferencia. Mira «margen_si_igualamos_yamin_%» antes de bajar.",
        "2. Si margen al precio Yamin queda ≥20% (marca) o ≥35% (genérico), es candidato a igualar.",
        "3. «Diff mínima» = casi empatados; no gastes tiempo ahí salvo inventario muerto.",
        "4. «Ellos sí · Nosotros no» = oportunidades de alta/surtido (prioridad por stock que ellos mueven).",
        "5. «Revisar outliers» = diffs absurdos (empaque distinto o ficha mal). No bajes precio a ciegas.",
        "6. margen_fc_% = margen real sobre venta. recargo_fc_% = markup sobre costo. No son lo mismo.",
        "7. Filtra por tipo_fc / categoria_fc / accion_sugerida con los filtros de la fila 1.",
    ]
    for i, t in enumerate(tips, 17):
        ws.cell(i, 1, t)
        ws.merge_cells(start_row=i, start_column=1, end_row=i, end_column=6)
    ws.column_dimensions["A"].width = 52
    ws.column_dimensions["B"].width = 18

    # —— Gaps ——
    ws_g = wb.create_sheet("Ellos sí · Nosotros no")
    write_sheet(
        ws_g,
        [
            "ean_o_codigo_yamin",
            "nombre_yamin",
            "precio_yamin",
            "stock_yamin",
            "departamento",
            "categoria",
            "prioridad",
            "nota",
        ],
        gaps,
        money_cols=["precio_yamin"],
    )
    # highlight Alta
    for i, r in enumerate(gaps, 2):
        if r["prioridad"] == "Alta":
            for j in range(1, 9):
                ws_g.cell(i, j).fill = FILL_AMARILLO

    # —— Más caros ——
    ws_c = wb.create_sheet("Nosotros más caros")
    write_sheet(ws_c, headers_match, caros, money_cols=money, pct_cols=pcts)
    for i, r in enumerate(caros, 2):
        # pintar accion
        acc = r["accion_sugerida"]
        fill = None
        if acc.startswith("Candidato"):
            fill = FILL_ROJO
        elif acc.startswith("No igualar"):
            fill = FILL_AMARILLO
        elif acc.startswith("Revisar"):
            fill = FILL_AZUL
        if fill:
            ws_c.cell(i, headers_match.index("accion_sugerida") + 1).fill = fill
        # diff positiva en rojo suave
        ws_c.cell(i, headers_match.index("diff_$") + 1).fill = FILL_ROJO

    # —— Diff mínima ——
    ws_m = wb.create_sheet("Diff mínima")
    write_sheet(ws_m, headers_match, minima, money_cols=money, pct_cols=pcts)
    for i in range(2, len(minima) + 2):
        ws_m.cell(i, headers_match.index("diff_$") + 1).fill = FILL_AMARILLO

    # —— Más baratos ——
    ws_b = wb.create_sheet("Nosotros más baratos")
    write_sheet(ws_b, headers_match, baratos, money_cols=money, pct_cols=pcts)
    for i in range(2, len(baratos) + 2):
        ws_b.cell(i, headers_match.index("diff_$") + 1).fill = FILL_VERDE

    # —— Todos ——
    ws_t = wb.create_sheet("Todos los matches")
    todos = sorted(enriched, key=lambda r: -(abs(r["diff_$"] or 0)))
    write_sheet(ws_t, headers_match, todos, money_cols=money, pct_cols=pcts)

    # —— Outliers ——
    ws_o = wb.create_sheet("Revisar outliers")
    write_sheet(ws_o, headers_match, outliers, money_cols=money, pct_cols=pcts)
    for i in range(2, len(outliers) + 2):
        for j in range(1, len(headers_match) + 1):
            if ws_o.cell(i, j).fill.fgColor is None or True:
                ws_o.cell(i, j).fill = FILL_AZUL

    # —— Glosario ——
    ws_gl = wb.create_sheet("Glosario")
    glosario = [
        ("Vs", "Precio Yamin vs precio FarmaCapital en una sola celda."),
        ("diff_$", "precio_fc − precio_yamin. Positivo = nosotros más caros."),
        ("diff_%", "(precio_fc − precio_yamin) / precio_yamin × 100."),
        ("margen_fc_%", "Margen real sobre venta: (precio − costo) / precio. Lo que usa el dashboard."),
        ("recargo_fc_%", "Markup sobre costo: (precio − costo) / costo. Lo que usa Recibir (+25%/+60%)."),
        ("margen_si_igualamos_yamin_%", "Margen que nos quedaría si bajáramos al precio de Yamin. Clave para decidir."),
        ("Diff mínima", "Filas con |diff_%| ≤ 5% o |diff_$| ≤ $5. Empate práctico."),
        ("Candidato a bajar", "FC más caro, margen al igualar Yamin ≥20%, y no es outlier."),
        ("No igualar", "Nuestro costo ya es ≥ al precio de Yamin: igualar sería pérdida."),
        ("Outlier", "|diff_%| ≥ 150% o |diff_$| ≥ $200 → probablemente empaque distinto o ficha mal."),
    ]
    ws_gl["A1"] = "Campo"
    ws_gl["B1"] = "Significado"
    style_header(ws_gl, 2)
    for i, (a, b) in enumerate(glosario, 2):
        ws_gl.cell(i, 1, a).border = THIN
        ws_gl.cell(i, 2, b).border = THIN
    ws_gl.column_dimensions["A"].width = 34
    ws_gl.column_dimensions["B"].width = 100

    args.out.parent.mkdir(parents=True, exist_ok=True)
    wb.save(args.out)
    print(f"OK → {args.out}")
    print(
        f"caros={len(caros)} minima={len(minima)} baratos={len(baratos)} gaps={len(gaps)} outliers={len(outliers)}"
    )


if __name__ == "__main__":
    main()
