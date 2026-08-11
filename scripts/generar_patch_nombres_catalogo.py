#!/usr/bin/env python3
"""Genera patch SQL: nombres y campos de catálogo limpios (sin costo/precio)."""

from __future__ import annotations

import csv
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC_SQL = ROOT / "sql" / "actualizar_catalogo_campos_y_precios.sql"
SRC_REPORTE = ROOT / "sql" / "reporte_cobertura_parser.csv"
SRC_MANUAL = ROOT / "sql" / "patch_marca_manual_parser.sql"
OUT_SQL = ROOT / "sql" / "patch_nombres_catalogo_limpio.sql"
OUT_CSV = ROOT / "sql" / "generated" / "patch_nombres_catalogo_preview.csv"

SKIP_FIELDS = {"costo", "precio"}

CAT_MAP = {
    "Higiene bucal": "Higiene",
    "Higiene personal": "Higiene",
    "Higiene capilar": "Higiene",
    "Cuidado personal": "Cuidado personal",
    "Botiquín": "Botiquín",
    "Medicamento": "Otro",
    "Abarrotes": "Abarrotes",
    "Producto": "Producto",
}

OCR_MARKERS = re.compile(
    r"\$|descto|subtotal|\(a\)|\|\s*lab\b|/\s*\d+\s*\||^/\s*\d|dwightnd|pieza edigar|ticket\s+\d",
    re.I,
)

# Overrides con mejor UX que el parser automático (dimensiones, marcas, etc.)
MANUAL_BY_SKU: dict[str, dict[str, str]] = {
    "FC-48690800": {"marca": "Protec", "nombre": "Tensolastic Plus venda elástica 5 cm x 5 m", "presentacion": "5 CM x 5 M", "forma_farmaceutica": "Material de curación", "categoria": "Botiquín"},
    "FC-48690909": {"marca": "Protec", "nombre": "Tensolastic Plus venda elástica 7 cm x 5 m", "presentacion": "7 CM x 5 M", "forma_farmaceutica": "Material de curación", "categoria": "Botiquín"},
    "FC-48691005": {"marca": "Protec", "nombre": "Tensolastic Plus venda elástica 10 cm x 5 m", "presentacion": "10 CM x 5 M", "forma_farmaceutica": "Material de curación", "categoria": "Botiquín"},
    "FC-48691104": {"marca": "Protec", "nombre": "Tensolastic Plus venda elástica 15 cm x 5 m", "presentacion": "15 CM x 5 M", "forma_farmaceutica": "Material de curación", "categoria": "Botiquín"},
    "FC-48640775": {"marca": "Protec", "nombre": "Venda de yeso 10 cm x 2.75 m C/12", "categoria": "Botiquín"},
    "FC-48640799": {"marca": "Protec", "nombre": "Venda de yeso 15 cm x 2.75 m C/12", "categoria": "Botiquín"},
    "FC-46640629": {"marca": "Protec", "nombre": "Venda de yeso 20 cm x 2.75 m", "categoria": "Botiquín"},
    "FC-48640751": {"marca": "Protec", "nombre": "Venda de yeso 5 cm x 2.75 m C/12", "categoria": "Botiquín"},
    "FC-24227339": {"marca": "Loxcel", "nombre": "Loxcel adulto", "presentacion": "C/1", "forma_farmaceutica": "TABLETAS", "categoria": "Otro"},
    "FC-80950139": {"marca": "Lásico", "nombre": "Lásico enzimático", "categoria": "Producto"},
    "FC-70612368": {"marca": "Treda", "nombre": "Treda", "presentacion": "C/20", "forma_farmaceutica": "TABLETAS", "categoria": "Otro"},
    "FC-58793249": {"marca": "Sico", "nombre": "Lubricante sensación calor", "presentacion": "50 ML", "categoria": "Cuidado personal"},
    "FC-40171550": {"marca": "Sensodyne", "nombre": "Sensodyne rápido alivio", "presentacion": "100 G", "forma_farmaceutica": "Crema dental", "categoria": "Higiene"},
    # Parser marcó inválido o nombre sucio — corrección manual
    "FC-08344747": {"marca": "Afrodit", "nombre": "Afrodit", "presentacion": "400 UI", "categoria": "Producto", "tipo": "marca"},
    "FC-23272151": {"marca": "Jayor", "nombre": "Jeringa insulina 0.3 ml", "presentacion": "C/100", "forma_farmaceutica": "Jeringa", "categoria": "Botiquín", "tipo": "marca"},
    "FC-23273451": {"marca": "Jayor", "nombre": "Jeringa insulina 0.5 ml", "presentacion": "C/100", "forma_farmaceutica": "Jeringa", "categoria": "Botiquín", "tipo": "marca"},
    "FC-24511629": {"marca": "Silica Shine", "nombre": "Silica Shine uva", "presentacion": "120 ML", "categoria": "Higiene", "tipo": "marca"},
    "FC-26462078": {"marca": "Ternura", "nombre": "Chupón con miel", "presentacion": "18 PZAS", "categoria": "Cuidado personal", "tipo": "marca"},
    "FC-33961373": {"marca": "Pedialyte", "nombre": "Pedialyte fresa", "presentacion": "500 ML", "categoria": "Otro", "tipo": "marca"},
    "FC-34062421": {"marca": "Quirmex", "nombre": "Tela adhesiva", "presentacion": "1.25 CM x 1 M", "forma_farmaceutica": "Tela adhesiva", "categoria": "Botiquín", "tipo": "marca"},
    "FC-56034041": {"marca": "Escudo", "nombre": "Toallitas húmedas antibacterial", "presentacion": "C/50", "categoria": "Higiene", "tipo": "marca"},
    "FC-66534951": {"marca": "Colgate", "nombre": "Colgate Total", "presentacion": "1 tubo", "forma_farmaceutica": "Crema dental", "categoria": "Higiene", "tipo": "marca"},
    "FC-83351381": {"marca": "Dermocleen", "nombre": "Agua oxigenada", "presentacion": "100 ML", "forma_farmaceutica": "Agua oxigenada", "categoria": "Botiquín", "tipo": "marca"},
    "FC-98217659": {"marca": "Neurobion", "nombre": "Dolo-Neurobión", "presentacion": "C/3 · 3 ML", "forma_farmaceutica": "Inyectable", "categoria": "Otro", "tipo": "marca"},
    # Solo en carga tickets (no Excel homologado)
    "FC-65095718": {"marca": "Centrum", "nombre": "Centrum", "presentacion": "C/30", "forma_farmaceutica": "TABLETAS", "categoria": "Otro", "tipo": "marca"},
    "FC-95451096": {"marca": "Sal de Uvas", "nombre": "Sal de uvas", "presentacion": "C/10", "categoria": "Otro", "tipo": "generico"},
    "FC-A871D831": {"marca": "Edigar", "nombre": "Perilla N6", "presentacion": "PIEZA", "categoria": "Botiquín", "tipo": "generico"},
    # Nombres duplicados / OCR residual del parser
    "FC-01015141": {"marca": "Softlub", "nombre": "Lubricante original", "presentacion": "56.7 G", "categoria": "Higiene", "tipo": "marca"},
    "FC-2E5B7248": {"marca": "Del Viejito", "nombre": "Reumatol", "categoria": "Producto", "tipo": "marca"},
    "FC-43454811": {"marca": "Huggies", "nombre": "Toallitas húmedas cuidado puro", "presentacion": "C/80", "categoria": "Higiene", "tipo": "marca"},
    "FC-47640531": {"marca": "Pisa", "nombre": "Recuperador una uña amarilla", "presentacion": "15 ML", "categoria": "Cuidado personal", "tipo": "marca"},
    "FC-58203691": {"marca": "Gum", "nombre": "Hilo dental expanding", "presentacion": "0.9 M", "categoria": "Higiene", "tipo": "marca"},
    "FC-614E4F82": {"marca": "Edigar", "nombre": "Perilla N3", "presentacion": "PIEZA", "categoria": "Botiquín", "tipo": "generico"},
    "FC-68900127": {"marca": "Dibar", "nombre": "Gasa 10 x 10", "presentacion": "PAQ 10", "categoria": "Botiquín", "tipo": "marca"},
    "FC-98100381": {"marca": "Herklin", "nombre": "Shampoo Herklin", "presentacion": "20 ML", "categoria": "Higiene", "tipo": "marca"},
    "FC-BCF59548": {"marca": "Edigar", "nombre": "Perilla N1", "presentacion": "PIEZA", "categoria": "Botiquín", "tipo": "generico"},
    "FC-C22EBFE6": {"marca": "Edigar", "nombre": "Perilla N2", "presentacion": "PIEZA", "categoria": "Botiquín", "tipo": "generico"},
    "FC-FFC25DD1": {"marca": "Edigar", "nombre": "Perilla N4", "presentacion": "PIEZA", "categoria": "Botiquín", "tipo": "generico"},
    "FC-00E8A9C7": {"marca": "Fotosun", "nombre": "Fotosun UV100", "presentacion": "125 ML", "forma_farmaceutica": "Crema", "categoria": "Cuidado personal", "tipo": "marca"},
    "FC-B69FCBF4": {"marca": "Lesaclor", "nombre": "Lesaclor", "presentacion": "35 TABLETAS", "concentracion": "400 MG", "forma_farmaceutica": "TABLETAS", "categoria": "Otro", "tipo": "marca"},
}


def sql_quote(val: str | None) -> str:
    if val is None or str(val).strip() == "":
        return "NULL"
    return "'" + str(val).replace("'", "''") + "'"


def parse_update_line(line: str) -> tuple[str, dict[str, str | float]] | None:
    m = re.match(
        r"update public\.productos set (.+) where sku = '([^']+)';",
        line.strip(),
        re.I,
    )
    if not m:
        return None
    sku = m.group(2)
    parts: dict[str, str | float] = {}
    for chunk in re.finditer(r"(\w+) = ((?:'(?:''|[^'])*')|[-\d.]+)", m.group(1)):
        key = chunk.group(1)
        raw = chunk.group(2)
        if raw.startswith("'"):
            parts[key] = raw[1:-1].replace("''", "'")
        else:
            parts[key] = float(raw) if "." in raw else int(raw)
    return sku, parts


def load_reporte() -> dict[str, dict[str, str]]:
    out: dict[str, dict[str, str]] = {}
    if not SRC_REPORTE.exists():
        return out
    with SRC_REPORTE.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            sku = row["sku"].strip()
            cat = CAT_MAP.get(row.get("categoria") or "", row.get("categoria") or "")
            out[sku] = {
                "forma_farmaceutica": (row.get("forma") or "").strip(),
                "categoria": cat,
                "principio_activo": (row.get("principio_activo") or "").strip(),
                "presentacion": (row.get("presentacion") or "").strip(),
                "marca": (row.get("marca") or "").strip(),
            }
    return out


def load_manual_sql() -> dict[str, dict[str, str]]:
    out: dict[str, dict[str, str]] = {}
    if not SRC_MANUAL.exists():
        return out
    text = SRC_MANUAL.read_text(encoding="utf-8")
    for m in re.finditer(
        r"update public\.productos set (.+?) where sku = '([^']+)'",
        text,
        re.I | re.S,
    ):
        sku = m.group(2)
        patch: dict[str, str] = {}
        for chunk in re.finditer(r"(\w+) = '((?:''|[^'])*)'", m.group(1)):
            patch[chunk.group(1)] = chunk.group(2).replace("''", "'")
        out[sku] = patch
    return out


def looks_like_ocr_name(name: str) -> bool:
    if not name or len(name.strip()) < 3:
        return True
    if OCR_MARKERS.search(name):
        return True
    if len(name) > 80:
        return True
    return False


def build_catalog() -> list[dict]:
    reporte = load_reporte()
    manual_sql = load_manual_sql()
    by_sku: dict[str, dict[str, str | float]] = {}

    for line in SRC_SQL.read_text(encoding="utf-8").splitlines():
        parsed = parse_update_line(line)
        if not parsed:
            continue
        sku, fields = parsed
        clean = {k: v for k, v in fields.items() if k not in SKIP_FIELDS}
        by_sku[sku] = clean

    rows: list[dict] = []
    for sku in sorted(by_sku.keys()):
        row = dict(by_sku[sku])
        row["sku"] = sku

        extra = reporte.get(sku, {})
        for k, v in extra.items():
            if v and not row.get(k):
                row[k] = v

        for src in (manual_sql.get(sku, {}), MANUAL_BY_SKU.get(sku, {})):
            for k, v in src.items():
                if v:
                    row[k] = v

        nombre = str(row.get("nombre") or "").strip()
        if not nombre:
            continue
        row["descripcion"] = nombre[:240]
        rows.append(row)

    # SKUs solo en overrides (carga tickets / parser inválido)
    for sku, manual in MANUAL_BY_SKU.items():
        if sku in by_sku:
            continue
        row = {"sku": sku, **manual}
        extra = reporte.get(sku, {})
        for k, v in extra.items():
            if v and not row.get(k):
                row[k] = v
        nombre = str(row.get("nombre") or "").strip()
        if not nombre:
            continue
        row["descripcion"] = nombre[:240]
        rows.append(row)

    rows.sort(key=lambda r: r["sku"])
    return rows


def main() -> None:
    if not SRC_SQL.exists():
        raise SystemExit(f"No existe {SRC_SQL}")

    rows = build_catalog()
    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)

    lines = [
        "-- ============================================================",
        "-- Catálogo limpio: nombre, marca, presentación, descripción",
        f"-- {len(rows)} productos · NO modifica costo ni precio",
        "-- Fuente: actualizar_catalogo + parser + overrides manuales",
        "-- Ejecutar UNA vez en Supabase después del patch de precios.",
        "-- ============================================================",
        "",
        "begin;",
        "",
    ]

    preview_rows = []
    for row in rows:
        sku = row["sku"]
        nombre = str(row["nombre"])
        lines.append(f"-- {sku} | {nombre[:72]}")
        set_parts = []
        for key in (
            "nombre",
            "marca",
            "presentacion",
            "principio_activo",
            "concentracion",
            "forma_farmaceutica",
            "categoria",
            "tipo",
            "descripcion",
        ):
            if key not in row or row[key] in (None, ""):
                continue
            val = row[key]
            set_parts.append(f"{key} = {sql_quote(str(val))}")
        lines.append(
            f"update public.productos set {', '.join(set_parts)} where sku = {sql_quote(sku)};"
        )
        lines.append("")
        preview_rows.append(
            {
                "sku": sku,
                "nombre": nombre,
                "marca": row.get("marca", ""),
                "presentacion": row.get("presentacion", ""),
                "categoria": row.get("categoria", ""),
            }
        )

    lines.extend(
        [
            "commit;",
            "",
            "-- Verificación: nombres OCR que aún parezcan ticket",
            "select sku, left(nombre, 72) as nombre",
            "from public.productos",
            "where sku like 'FC-%'",
            "  and (",
            "    nombre ~* 'descto|\\\\$|\\\\(a\\\\)|\\\\|\\\\s*lab'",
            "    or length(nombre) > 90",
            "  )",
            "order by sku",
            "limit 30;",
            "",
            "-- Muestra Tensolastic + casos del screenshot",
            "select sku, nombre, presentacion, marca",
            "from public.productos",
            "where sku in (",
            "  'FC-48690909','FC-48690800','FC-48691005','FC-48691104',",
            "  'FC-24227339','FC-80950139','FC-70612368','FC-65095718','FC-95451096'",
            ")",
            "order by sku;",
            "",
        ]
    )

    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")
    with OUT_CSV.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(preview_rows[0].keys()))
        w.writeheader()
        w.writerows(preview_rows)

    ocr_like = sum(1 for r in preview_rows if looks_like_ocr_name(r["nombre"]))
    print(f"Productos: {len(rows)}")
    print(f"SQL: {OUT_SQL}")
    print(f"Preview: {OUT_CSV}")
    print(f"Nombres aún sospechosos OCR (heurística): {ocr_like}")


if __name__ == "__main__":
    main()
