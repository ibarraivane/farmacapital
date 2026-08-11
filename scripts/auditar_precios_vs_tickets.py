#!/usr/bin/env python3
"""
Audita costos/precios del inventario vs tickets OCR.
Genera reporte + SQL de corrección completa.

  python3 scripts/auditar_precios_vs_tickets.py
"""

from __future__ import annotations

import csv
import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

from auditar_cantidades_vs_pdfs import collect_all_ticket_rows, norm_barcode  # noqa: E402
from homologar_tickets_a_excel import HEADERS, load_ocr_from_pdfs, sku_for_row  # noqa: E402

SQL_GLOB = [
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_1.sql",
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_2.sql",
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_3.sql",
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_4.sql",
]
CATALOGO_CSV = ROOT / "sql" / "preview_catalogo_campos_y_precios.csv"
PRICING_CSV = ROOT / "sql" / "pricing" / "generated" / "preview_precios_productos.csv"
OUT_MD = ROOT / "sql" / "generated" / "auditoria_precios_vs_tickets.md"
OUT_CSV = ROOT / "sql" / "generated" / "auditoria_precios_fixes.csv"
OUT_SQL = ROOT / "sql" / "patch_fix_costos_ocr_tickets_completo.sql"

SUSPICIOUS_UNIT_COST = 200.0
KNOWN_BAD_COSTS = {405.32, 7271.27, 8405.32, 1134.05}


def parse_money(raw: str) -> float | None:
    s = str(raw or "").strip().replace("$", "").replace(" ", "")
    if not s:
        return None
    if "," in s and "." in s:
        if s.rfind(",") > s.rfind("."):
            s = s.replace(".", "").replace(",", ".")
        else:
            s = s.replace(",", "")
    elif "," in s:
        s = s.replace(",", ".")
    try:
        v = float(s)
        return v if v > 0 else None
    except ValueError:
        return None


def extract_raw_unit_cost_from_ocr(ocr_by_pdf: dict[str, str], barcode: str) -> float | None:
    """Primer precio unitario en OCR crudo, antes de Subtotal; respeta (xN)."""
    bc = norm_barcode(barcode)
    if not bc:
        return None
    for text in ocr_by_pdf.values():
        idx = text.find(bc)
        if idx < 0:
            continue
        block = text[idx : idx + 260]
        block = re.split(r"(?i)\nsubtotal\n", block, maxsplit=1)[0]
        qty_m = re.search(r"\([xX](\d+)\)", block)
        qty = max(1, int(qty_m.group(1)) if qty_m else 1)

        amounts: list[float] = []
        for m in re.finditer(r"\$\s*([\d,]+(?:\.\d{1,3})?)", block):
            v = parse_money(m.group(1))
            if v and 0.5 < v < 500:
                amounts.append(v)
        if not amounts:
            continue

        if len(amounts) >= 2 and abs(amounts[0] - amounts[1]) < 0.06:
            return round(amounts[1], 2)

        if qty > 1:
            for a in amounts[:3]:
                unit = round(a / qty, 2)
                if 0.5 < unit < 300:
                    for b in amounts[:3]:
                        if abs(b - a) < 0.06:
                            return unit
                    if a > 15 and unit < a * 0.85:
                        return unit

        return round(amounts[0], 2)
    return None


def idx(name: str) -> int:
    return HEADERS.index(name)


def load_sql_costs() -> dict[str, dict]:
    text = "\n".join(
        p.read_text(encoding="utf-8", errors="replace") for p in SQL_GLOB if p.exists()
    )
    out: dict[str, dict] = {}
    for m in re.finditer(
        r"create_producto_with_lote\(\s*jsonb_build_object\(([\s\S]*?)\),\s*(\d+),",
        text,
    ):
        block = m.group(1)
        sku_m = re.search(r"'sku',\s*'([^']+)'", block)
        bc_m = re.search(r"'codigo_barras',\s*(?:NULL|'(\d+)')", block, re.I)
        cost_m = re.search(r"'costo',\s*([\d.]+)", block)
        name_m = re.search(r"'nombre',\s*'([^']*)'", block)
        if not sku_m or not cost_m:
            continue
        sku = sku_m.group(1)
        out[sku] = {
            "sku": sku,
            "barcode": bc_m.group(1) if bc_m and bc_m.group(1) else None,
            "nombre": (name_m.group(1) if name_m else sku)[:60],
            "costo_sql": float(cost_m.group(1)),
        }
    return out


def load_csv_map(path: Path, key: str) -> dict[str, dict]:
    if not path.exists():
        return {}
    out: dict[str, dict] = {}
    with path.open(encoding="utf-8") as f:
        for row in csv.DictReader(f):
            k = row.get(key, "").strip()
            if k:
                out[k] = row
    return out


def build_ticket_costs(rows: list[tuple]) -> tuple[dict[str, dict], dict[str, dict]]:
    by_bc: dict[str, dict] = {}
    by_sku: dict[str, dict] = {}
    for r in rows:
        bc = norm_barcode(r[idx("Código de barras")])
        sku = sku_for_row(r)
        cost = float(r[idx("Costo unitario s/IVA")] or 0)
        if cost <= 0:
            continue
        entry = {
            "sku": sku,
            "barcode": bc,
            "nombre": str(r[idx("Nombre / variante")] or "")[:60],
            "ticket": str(r[idx("N.º ticket / orden")] or ""),
            "costo_parser": cost,
            "qty": int(r[idx("Cantidad")] or 1),
        }
        if bc:
            prev = by_bc.get(bc)
            if not prev or cost < prev["costo_parser"]:
                by_bc[bc] = entry
        by_sku[sku] = entry
    return by_bc, by_sku


def best_ticket_cost(
    entry: dict,
    barcode: str | None,
    ocr: dict[str, str],
) -> float:
    parser = entry["costo_parser"]
    if barcode:
        raw = extract_raw_unit_cost_from_ocr(ocr, barcode)
        if raw:
            if parser in KNOWN_BAD_COSTS or (parser > SUSPICIOUS_UNIT_COST and raw < 150):
                return raw
            if abs(raw - parser) / max(raw, parser) > 0.15:
                return raw
            return raw
    if parser in KNOWN_BAD_COSTS:
        return parser
    return parser


def precio_from_regla(costo: float, recargo_pct: float) -> float:
    if costo <= 0:
        return 0.0
    return math.ceil(costo * (1 + recargo_pct / 100.0))


def classify_diff(ticket: float, loaded: float) -> str:
    if loaded in KNOWN_BAD_COSTS or (loaded > SUSPICIOUS_UNIT_COST and ticket < 150):
        return "CRITICO_OCR"
    if ticket <= 0:
        return "sin_ticket"
    diff = abs(loaded - ticket)
    pct = diff / ticket * 100 if ticket else 999
    if diff <= 0.05:
        return "ok"
    if pct <= 8 and diff <= 2:
        return "ok_redondeo"
    if pct <= 20:
        return "menor"
    if pct <= 60:
        return "moderado"
    return "grave"


def main() -> None:
    rows = collect_all_ticket_rows()
    by_bc, by_sku = build_ticket_costs(rows)
    ocr = load_ocr_from_pdfs(force=False)
    sql = load_sql_costs()
    catalogo = load_csv_map(CATALOGO_CSV, "sku")
    pricing = load_csv_map(PRICING_CSV, "sku")

    issues: list[dict] = []
    ok_count = 0
    seen_skus: set[str] = set()

    def process(sku: str, s: dict, t: dict) -> None:
        if sku in seen_skus:
            return
        seen_skus.add(sku)

        cat = catalogo.get(sku, {})
        pr = pricing.get(sku, {})
        recargo = float(pr["recargo_pct"]) if pr.get("recargo_pct") else 60.0
        if not pr.get("recargo_pct") and cat.get("margen_pct"):
            recargo = float(cat["margen_pct"])

        inv_cost = float(pr["costo"]) if pr.get("costo") else float(
            cat.get("costo") or s.get("costo_sql", 0)
        )
        precio_actual = float(pr["precio_actual"]) if pr.get("precio_actual") else None

        ticket_cost = best_ticket_cost(t, s.get("barcode"), ocr)
        sev = classify_diff(ticket_cost, inv_cost)

        if sev.startswith("ok"):
            nonlocal ok_count
            ok_count += 1
            return

        precio_corr = precio_from_regla(ticket_cost, recargo)
        issues.append(
            {
                "sev": sev,
                "sku": sku,
                "barcode": s.get("barcode") or "",
                "nombre": s.get("nombre") or str(pr.get("nombre") or sku)[:60],
                "ticket": t["ticket"],
                "costo_ticket": ticket_cost,
                "costo_parser": t["costo_parser"],
                "costo_inv": inv_cost,
                "precio_actual": precio_actual,
                "precio_corr": precio_corr,
                "recargo_pct": recargo,
                "diff": round(inv_cost - ticket_cost, 2),
            }
        )

    for sku, s in sql.items():
        t = None
        if s.get("barcode") and s["barcode"] in by_bc:
            t = by_bc[s["barcode"]]
        elif sku in by_sku:
            t = by_sku[sku]
        if not t:
            continue
        process(sku, s, t)

    issues.sort(
        key=lambda x: (
            {"CRITICO_OCR": 0, "grave": 1, "moderado": 2, "menor": 3}.get(x["sev"], 9),
            -abs(x["diff"]),
        )
    )

    crit = sum(1 for i in issues if i["sev"] == "CRITICO_OCR")
    grave = sum(1 for i in issues if i["sev"] == "grave")
    moder = sum(1 for i in issues if i["sev"] == "moderado")
    menor = sum(1 for i in issues if i["sev"] == "menor")

    OUT_MD.parent.mkdir(parents=True, exist_ok=True)
    OUT_MD.write_text(
        "\n".join(
            [
                "# Auditoría precios — tickets vs inventario",
                "",
                f"- OK: **{ok_count}**",
                f"- Correcciones: **{len(issues)}** (crítico {crit}, grave {grave}, moderado {moder}, menor {menor})",
                "",
                f"SQL: `{OUT_SQL.name}`",
                f"CSV: `{OUT_CSV.name}`",
            ]
        ),
        encoding="utf-8",
    )

    with OUT_CSV.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "sku",
                "barcode",
                "ticket",
                "sev",
                "costo_ticket",
                "costo_inv",
                "precio_actual",
                "precio_corr",
                "nombre",
            ],
        )
        w.writeheader()
        for i in issues:
            w.writerow(
                {
                    "sku": i["sku"],
                    "barcode": i["barcode"],
                    "ticket": i["ticket"],
                    "sev": i["sev"],
                    "costo_ticket": f"{i['costo_ticket']:.2f}",
                    "costo_inv": f"{i['costo_inv']:.2f}",
                    "precio_actual": f"{i['precio_actual'] or 0:.2f}",
                    "precio_corr": f"{i['precio_corr']:.2f}",
                    "nombre": i["nombre"],
                }
            )

    sql_lines = [
        "-- ============================================================",
        "-- CORRECCIÓN COMPLETA: costos y precios vs tickets PDF",
        f"-- {len(issues)} productos · generado por auditar_precios_vs_tickets.py",
        "-- Fuente costo: OCR crudo del PDF (primer precio antes de Subtotal)",
        "-- Precio venta: costo × (1 + recargo% regla pricing)",
        "--",
        "-- Ejecutar UNA vez en Supabase SQL Editor.",
        "-- ============================================================",
        "",
        "begin;",
        "",
    ]

    for i in issues:
        sql_lines.append(
            f"-- [{i['sev']}] {i['sku']} ticket {i['ticket']} | "
            f"${i['costo_inv']:.2f} → ${i['costo_ticket']:.2f} | precio → ${i['precio_corr']:.2f}"
        )
        sql_lines.append(
            f"update public.productos set costo = {i['costo_ticket']:.2f}, "
            f"precio = {i['precio_corr']:.2f} where sku = '{i['sku']}';"
        )
        sql_lines.append(
            f"update public.lotes set costo_unitario = {i['costo_ticket']:.2f} "
            f"where producto_id = (select id from public.productos where sku = '{i['sku']}' limit 1);"
        )
        sql_lines.append("")

    sql_lines += [
        "commit;",
        "",
        "-- Verificación rápida",
        "select sku, left(nombre, 36) as nombre, costo, precio",
        "from public.productos",
        "where sku in ('FC-48690800','FC-48690909','FC-48691005','FC-48691104','FC-40171550')",
        "order by sku;",
        "",
        "select count(*) as aun_mal from public.productos",
        "where costo in (405.32, 7271.27, 8405.32);",
    ]
    OUT_SQL.write_text("\n".join(sql_lines), encoding="utf-8")

    # Mantener alias corto
    (ROOT / "sql" / "patch_fix_costos_ocr_tickets.sql").write_text(
        OUT_SQL.read_text(encoding="utf-8"), encoding="utf-8"
    )

    print(f"OK: {ok_count} · Fixes: {len(issues)}")
    print(f"SQL: {OUT_SQL}")
    print(f"CSV: {OUT_CSV}")


if __name__ == "__main__":
    main()
