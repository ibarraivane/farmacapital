#!/usr/bin/env python3
"""
Audita cantidades de TODOS los tickets PDF (OCR) vs inventario cargado.
Genera reporte markdown + SQL idempotente para que stock = lo comprado en tickets.

El SQL ajusta el lote principal (TK-*) y pone otros lotes del mismo producto en 0,
para que sum(lotes) = cantidad ticket sin duplicar.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

from homologar_tickets_a_excel import (  # noqa: E402
    load_ocr_from_pdfs,
    parse_bodega,
    parse_farmalive,
    parse_farma_mx,
    parse_ifc,
    parse_surtidor,
    sku_for_row,
)

OCR_DIR = ROOT / ".tmp_ocr_vision"
OCR_BY_PDF = {
    "FL-080826": "FarmaLive.pdf",
    "440393": "Bodega F-42.pdf",
    "77827": "Bodega F-42.pdf",
    "112558": "El surtidor de su farmacia.pdf",
    "IFC1-080826": "IFC 1.pdf",
    "IFC2-080826": "IFC 2.pdf",
    "FMX-080826": "Farma Mx.pdf",
}
SQL_GLOB = [
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_1.sql",
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_2.sql",
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_3.sql",
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_4.sql",
]
OUT_MD = ROOT / "sql" / "generated" / "auditoria_cantidades_todos_tickets.md"
OUT_SQL = ROOT / "sql" / "patch_cantidades_tickets_completo.sql"


def norm_barcode(raw: str | None) -> str | None:
    if not raw:
        return None
    digits = re.sub(r"\D", "", str(raw))
    return digits if len(digits) >= 8 else None


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


def infer_qty_from_ocr_block(ocr: str, barcode: str) -> int | None:
    """Cantidad explícita o total÷unitario cuando el parser dejó 1."""
    idx = ocr.find(barcode)
    if idx < 0:
        return None
    block = ocr[idx : idx + 400]
    lines = [ln.strip() for ln in block.splitlines() if ln.strip()]

    for ln in lines[1:14]:
        m = re.match(r"^(\d{1,2})$", ln)
        if m:
            q = int(m.group(1))
            if 2 <= q <= 50:
                return q
        m = re.match(r"^(\d{1,2})\s+[\$#฿]", ln)
        if m:
            q = int(m.group(1))
            if 2 <= q <= 50:
                return q

    money = []
    for x in re.findall(r"[\$#฿]\s*([\d.,]+)", block):
        v = parse_money(x)
        if v and 0 < v < 5000:
            money.append(v)
    if len(money) < 2:
        return None
    unit = min(money)
    total = max(money)
    if unit <= 0 or total <= unit * 1.35:
        return None
    ratio = round(total / unit)
    if ratio < 2 or ratio > 50:
        return None
    if abs(total - unit * ratio) > max(0.75, unit * 0.06):
        return None
    return ratio


def load_carga_sql_text() -> str:
    parts = []
    for p in SQL_GLOB:
        if p.exists():
            parts.append(p.read_text(encoding="utf-8", errors="replace"))
    return "\n".join(parts)


def load_carga_sql_quantities() -> tuple[dict[str, dict], dict[str, dict]]:
    """Cantidades previstas en SQL de carga (627 líneas homologadas)."""
    text = load_carga_sql_text()
    by_bc: dict[str, dict] = {}
    by_sku: dict[str, dict] = {}

    for m in re.finditer(
        r"create_producto_with_lote\(\s*jsonb_build_object\(([\s\S]*?)\),\s*(\d+),\s*'",
        text,
    ):
        block, qty_s = m.group(1), m.group(2)
        qty = int(qty_s)
        sku_m = re.search(r"'sku',\s*'([^']+)'", block)
        bc_m = re.search(r"'codigo_barras',\s*(?:NULL|'(\d+)')", block, re.I)
        name_m = re.search(r"'nombre',\s*'([^']*)'", block)
        if not sku_m:
            continue
        sku = sku_m.group(1)
        bc = bc_m.group(1) if bc_m and bc_m.group(1) else None
        nombre = (name_m.group(1) if name_m else sku)[:80]
        entry = {"sku": sku, "nombre": nombre, "qty_ticket": qty, "ticket": "carga SQL"}

        if bc:
            prev = by_bc.get(bc)
            if not prev or qty > prev["qty_ticket"]:
                by_bc[bc] = {**entry, "barcode": bc}
        else:
            prev = by_sku.get(sku)
            if not prev or qty > prev["qty_ticket"]:
                by_sku[sku] = entry

    return by_bc, by_sku


def collect_all_ticket_rows() -> list[tuple]:
    ocr = load_ocr_from_pdfs(force=False)
    rows: list[tuple] = []
    if (OCR_DIR / "Bodega F-42.txt").exists():
        rows.extend(parse_bodega(ocr.get("Bodega F-42.pdf", "")))
    if (OCR_DIR / "El surtidor de su farmacia.txt").exists():
        rows.extend(parse_surtidor(ocr.get("El surtidor de su farmacia.pdf", "")))
    if (OCR_DIR / "IFC 1.txt").exists():
        rows.extend(parse_ifc(ocr.get("IFC 1.pdf", ""), "IFC1-080826", "118217"))
    if (OCR_DIR / "IFC 2.txt").exists():
        rows.extend(parse_ifc(ocr.get("IFC 2.pdf", ""), "IFC2-080826", "118216"))
    if (OCR_DIR / "Farma Mx.txt").exists():
        rows.extend(parse_farma_mx(ocr.get("Farma Mx.pdf", "")))
    if (OCR_DIR / "FarmaLive.txt").exists():
        rows.extend(parse_farmalive(ocr.get("FarmaLive.pdf", "")))
    return rows


def build_targets(rows: list[tuple]) -> tuple[list[dict], list[dict]]:
    """Agrega cantidades por barcode (suma tickets) y por SKU sin barcode."""
    ocr = load_ocr_from_pdfs(force=False)
    by_bc: dict[str, dict] = {}
    by_sku: dict[str, dict] = {}

    for r in rows:
        bc = norm_barcode(r[1])
        sku = sku_for_row(r)
        ticket = str(r[16] or "")
        nombre = str(r[4] or "")[:80]
        qty = max(1, int(r[8] or 1))

        if qty == 1 and bc:
            pdf = OCR_BY_PDF.get(ticket)
            if pdf:
                inferred = infer_qty_from_ocr_block(ocr.get(pdf, ""), bc)
                if inferred and inferred > qty:
                    qty = inferred

        if bc:
            prev = by_bc.get(bc)
            if not prev:
                by_bc[bc] = {
                    "barcode": bc,
                    "sku": sku,
                    "nombre": nombre,
                    "qty_ticket": qty,
                    "tickets": {ticket},
                }
            else:
                prev["qty_ticket"] += qty
                prev["tickets"].add(ticket)
                if len(nombre) > len(prev.get("nombre", "")):
                    prev["nombre"] = nombre
        else:
            prev = by_sku.get(sku)
            if not prev:
                by_sku[sku] = {
                    "sku": sku,
                    "nombre": nombre,
                    "qty_ticket": qty,
                    "tickets": {ticket},
                }
            else:
                prev["qty_ticket"] += qty
                prev["tickets"].add(ticket)

    bc_list = [
        {**v, "ticket": ", ".join(sorted(v.pop("tickets")))}
        for v in by_bc.values()
    ]
    sku_list = [
        {**v, "ticket": ", ".join(sorted(v.pop("tickets")))}
        for v in by_sku.values()
    ]
    return bc_list, sku_list


GARBAGE_NAME = re.compile(r"^FC\s+\d{2}/", re.I)


def is_garbage_sku_target(row: dict) -> bool:
    name = str(row.get("nombre") or "")
    if GARBAGE_NAME.match(name.strip()):
        return True
    if name.strip().lower() in {"producto ifc 3", "clave 302174", "clave 300591"}:
        return True
    return False


def filter_sku_targets(sku_targets: list[dict]) -> list[dict]:
    return [x for x in sku_targets if not is_garbage_sku_target(x)]


def merge_targets(
    ocr_bc: list[dict], ocr_sku: list[dict], sql_bc: dict[str, dict], sql_sku: dict[str, dict]
) -> tuple[list[dict], list[dict]]:
    """Une OCR + SQL de carga; gana la cantidad mayor (tickets + inferencia OCR)."""
    bc_map: dict[str, dict] = {x["barcode"]: dict(x) for x in ocr_bc}
    for bc, row in sql_bc.items():
        prev = bc_map.get(bc)
        if not prev:
            bc_map[bc] = dict(row)
        elif row["qty_ticket"] > prev["qty_ticket"]:
            prev["qty_ticket"] = row["qty_ticket"]
            prev["ticket"] = row.get("ticket", prev.get("ticket", ""))

    sku_map: dict[str, dict] = {x["sku"]: dict(x) for x in ocr_sku}
    for sku, row in sql_sku.items():
        prev = sku_map.get(sku)
        if not prev:
            sku_map[sku] = dict(row)
        elif row["qty_ticket"] > prev["qty_ticket"]:
            prev["qty_ticket"] = row["qty_ticket"]
            prev["ticket"] = row.get("ticket", prev.get("ticket", ""))

    return list(bc_map.values()), list(sku_map.values())


def sql_escape(s: str) -> str:
    return s.replace("'", "''")


def generate_patch_sql(bc_targets: list[dict], sku_targets: list[dict]) -> str:
    lines = [
        "-- ============================================================================\n",
        "-- CORRECCIÓN GLOBAL: stock = cantidades compradas en tickets PDF\n",
        "-- Generado por scripts/auditar_cantidades_vs_pdfs.py\n",
        "--\n",
        "-- Qué hace:\n",
        "--   1. Por cada código de barras / SKU del ticket, objetivo = suma de cantidades.\n",
        "--   2. Lote principal = TK-* si existe, si no el más reciente.\n",
        "--   3. Otros lotes activos del mismo producto → 0 (evita duplicar stock).\n",
        "--   4. Lote principal → cantidad objetivo. Trigger sincroniza productos.stock.\n",
        "--\n",
        "-- Idempotente: ejecutar de nuevo no cambia nada si ya está correcto.\n",
        "-- ============================================================================\n",
        "\nbegin;\n\n",
        "create temp table _fc_qty_ticket (\n",
        "  codigo_barras text,\n",
        "  sku text,\n",
        "  qty integer not null check (qty > 0),\n",
        "  nota text\n",
        ") on commit drop;\n\n",
        "insert into _fc_qty_ticket (codigo_barras, sku, qty, nota) values\n",
    ]

    value_rows: list[str] = []
    for it in sorted(bc_targets, key=lambda x: x["barcode"]):
        note = sql_escape(it["nombre"][:55])
        value_rows.append(
            f"  ('{it['barcode']}', null, {it['qty_ticket']}, '{note}')"
        )
    for it in sorted(sku_targets, key=lambda x: x["sku"]):
        note = sql_escape(it["nombre"][:55])
        value_rows.append(
            f"  (null, '{it['sku']}', {it['qty_ticket']}, '{note}')"
        )

    if not value_rows:
        value_rows.append("  (null, null, 1, 'sin datos')")

    lines.append(",\n".join(value_rows))
    lines.append(
        ";\n\n"
        "-- Resolver producto_id desde barcode o SKU\n"
        "create temp table _fc_qty_producto as\n"
        "select distinct on (coalesce(t.codigo_barras, t.sku))\n"
        "  p.id as producto_id,\n"
        "  t.qty,\n"
        "  t.nota,\n"
        "  coalesce(t.codigo_barras, p.codigo_barras) as codigo_barras,\n"
        "  p.sku\n"
        "from _fc_qty_ticket t\n"
        "join public.productos p on (\n"
        "  (t.codigo_barras is not null and p.codigo_barras = t.codigo_barras)\n"
        "  or (t.sku is not null and p.sku = t.sku)\n"
        ")\n"
        "where coalesce(p.activo, true) = true\n"
        "order by coalesce(t.codigo_barras, t.sku), p.id;\n\n"
        "-- Lote principal por producto\n"
        "create temp table _fc_qty_primary_lote as\n"
        "select distinct on (qp.producto_id)\n"
        "  qp.producto_id,\n"
        "  qp.qty,\n"
        "  qp.nota,\n"
        "  qp.sku,\n"
        "  l.id as lote_id\n"
        "from _fc_qty_producto qp\n"
        "join public.lotes l\n"
        "  on l.producto_id = qp.producto_id\n"
        " and coalesce(l.activo, true) = true\n"
        "order by\n"
        "  qp.producto_id,\n"
        "  case when l.numero_lote ilike 'TK-%' then 0 else 1 end,\n"
        "  l.created_at desc nulls last,\n"
        "  l.id desc;\n\n"
        "-- Productos del ticket que NO existen en BD (solo informativo)\n"
        "select t.codigo_barras, t.sku, t.qty, t.nota\n"
        "from _fc_qty_ticket t\n"
        "where not exists (\n"
        "  select 1 from _fc_qty_producto qp\n"
        "  where (t.codigo_barras is not null and qp.codigo_barras = t.codigo_barras)\n"
        "     or (t.sku is not null and qp.sku = t.sku)\n"
        ");\n\n"
        "-- Cero en lotes secundarios\n"
        "update public.lotes l\n"
        "set cantidad_actual = 0\n"
        "from _fc_qty_primary_lote pl\n"
        "where l.producto_id = pl.producto_id\n"
        "  and l.id <> pl.lote_id\n"
        "  and coalesce(l.activo, true) = true\n"
        "  and coalesce(l.cantidad_actual, 0) <> 0;\n\n"
        "-- Cantidad correcta en lote principal\n"
        "update public.lotes l\n"
        "set cantidad_actual = pl.qty\n"
        "from _fc_qty_primary_lote pl\n"
        "where l.id = pl.lote_id\n"
        "  and coalesce(l.cantidad_actual, 0) is distinct from pl.qty;\n\n"
        "-- Verificación: stock producto vs objetivo ticket\n"
        "select\n"
        "  p.sku,\n"
        "  left(p.nombre, 40) as nombre,\n"
        "  p.codigo_barras,\n"
        "  pl.qty as qty_ticket,\n"
        "  p.stock as stock_producto,\n"
        "  coalesce(sum(l.cantidad_actual) filter (where coalesce(l.activo, true)), 0) as sum_lotes,\n"
        "  case\n"
        "    when p.stock = pl.qty then 'OK'\n"
        "    else 'REVISAR'\n"
        "  end as estado\n"
        "from _fc_qty_primary_lote pl\n"
        "join public.productos p on p.id = pl.producto_id\n"
        "left join public.lotes l on l.producto_id = p.id\n"
        "group by p.id, p.sku, p.nombre, p.codigo_barras, pl.qty, p.stock\n"
        "having p.stock is distinct from pl.qty\n"
        "order by p.nombre\n"
        "limit 50;\n\n"
        "commit;\n"
    )
    return "".join(lines)


def main() -> None:
    rows = collect_all_ticket_rows()
    ocr_bc, ocr_sku = build_targets(rows)
    sql_bc, sql_sku = load_carga_sql_quantities()
    bc_targets, sku_targets = merge_targets(ocr_bc, ocr_sku, sql_bc, sql_sku)
    sku_targets = filter_sku_targets(sku_targets)

    OUT_MD.parent.mkdir(parents=True, exist_ok=True)

    md = [
        "# Auditoría cantidades — todos los tickets PDF\n",
        f"Productos con barcode: **{len(bc_targets)}** · Sin barcode (por SKU): **{len(sku_targets)}**\n",
        f"Piezas totales barcode: **{sum(x['qty_ticket'] for x in bc_targets)}** · ",
        f"Sin barcode: **{sum(x['qty_ticket'] for x in sku_targets)}**\n",
        f"Fuente: OCR tickets + cantidades homologadas en `carga_inventario_tickets_EJECUTAR_*.sql`\n\n",
        "## Top cantidades (barcode)\n",
        "| Qty | Barcode | SKU | Producto | Tickets |\n",
        "|-----|---------|-----|----------|--------|\n",
    ]
    for it in sorted(bc_targets, key=lambda x: -x["qty_ticket"])[:40]:
        md.append(
            f"| **{it['qty_ticket']}** | `{it['barcode']}` | `{it['sku']}` | "
            f"{it['nombre'][:45]} | {it['ticket']} |\n"
        )

    md.append("\n## Sin barcode (ajuste por SKU en BD)\n")
    md.append("| Qty | SKU | Producto | Tickets |\n")
    md.append("|-----|-----|----------|--------|\n")
    for it in sorted(sku_targets, key=lambda x: -x["qty_ticket"])[:30]:
        md.append(
            f"| **{it['qty_ticket']}** | `{it['sku']}` | {it['nombre'][:50]} | {it['ticket']} |\n"
        )

    OUT_MD.write_text("".join(md), encoding="utf-8")
    OUT_SQL.write_text(generate_patch_sql(bc_targets, sku_targets), encoding="utf-8")

    print(f"OCR barcode: {len(ocr_bc)} · SQL barcode: {len(sql_bc)} · merged: {len(bc_targets)}")
    print(f"OCR sku: {len(ocr_sku)} · SQL sku: {len(sql_sku)} · merged: {len(sku_targets)}")
    print(f"Markdown: {OUT_MD}")
    print(f"SQL patch: {OUT_SQL}")


if __name__ == "__main__":
    main()
