#!/usr/bin/env python3
"""
Audita TODOS los tickets OCR vs catálogo y genera SQL INSERT-ONLY.
No modifica nombre, precio, costo ni stock de productos que ya existen.

  python3 scripts/generar_sql_solo_faltantes.py

Salida:
  sql/generated/auditoria_faltantes_todos_tickets.md
  sql/patch_solo_insertar_faltantes.sql
"""

from __future__ import annotations

import csv
import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

from auditar_cantidades_vs_pdfs import norm_barcode  # noqa: E402
from datos_catalogo_faltantes import BARCODE_CATALOG  # noqa: E402
from homologar_tickets_a_excel import (  # noqa: E402
    HEADERS,
    load_ocr_from_pdfs,
    parse_bodega,
    parse_farma_mx,
    parse_farmalive,
    parse_ifc,
    parse_surtidor,
    sku_for_row,
)

from parse_nombre_producto import parse_nombre_producto  # noqa: E402

OUT_MD = ROOT / "sql" / "generated" / "auditoria_faltantes_todos_tickets.md"
OUT_SQL = ROOT / "sql" / "patch_solo_insertar_faltantes.sql"
MARGEN_VENTA = 0.35

# Alias → barcode canónico (OCR truncado)
BARCODE_ALIASES: dict[str, str] = {
    "750168517111": "7501685171113",
    "7501685171118": "7501685171113",
    "7501354312225027": "3543122250276",
    "7501354312250": "3543122250276",
    "543122250227": "3543122250276",
}

# Costos unitarios corregidos (OCR a veces captura total de línea)
COSTO_OVERRIDE: dict[str, float] = {
    "6502400525451": 30.38,
    "6502400170941": 36.26,
}
BARCODE_SUPPLEMENT: list[dict] = [
    {"barcode": "650240017100", "costo": 88.20, "qty": 2, "ticket": "FL-080826"},
    {"barcode": "65024000740024", "costo": 80.56, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "75029650608272", "costo": 32.34, "qty": 2, "ticket": "FL-080826"},
    {"barcode": "7503854221482", "costo": 42.41, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "75015015371829601", "costo": 73.11, "qty": 2, "ticket": "FL-080826"},
    {"barcode": "7501537163266", "costo": 54.10, "qty": 2, "ticket": "FL-080826"},
    {"barcode": "7507201092730451", "costo": 268.72, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "75010954525051", "costo": 113.93, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "6502400315021", "costo": 126.91, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "7501210734092301", "costo": 88.69, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "7501058715517", "costo": 42.64, "qty": 5, "ticket": "FL-080826"},
    {"barcode": "750525301508201", "costo": 149.35, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "7503050071598", "costo": 170.32, "qty": 2, "ticket": "FL-080826"},
    {"barcode": "7509854054221", "costo": 140.53, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "75012501050724298", "costo": 166.19, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "7501064560163", "costo": 70.07, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "75010583683367", "costo": 54.71, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "7501058367129", "costo": 54.71, "qty": 1, "ticket": "FL-080826"},
    {"barcode": "7501685171113", "costo": 71.25, "qty": 1, "ticket": "FL-080826"},
]

# Catálogo local más reciente (snapshot; el SQL no pisa lo que ya exista en Supabase)
CATALOG_CSVS = [
    ROOT / "sql" / "historial" / "catalogo_20260814_1155.csv",
    ROOT / "sql" / "preview_catalogo_campos_y_precios.csv",
]


def precio_venta(costo: float) -> float:
    if costo <= 0:
        return 0.0
    return math.ceil(costo * (1 + MARGEN_VENTA) * 100) / 100


def sql_quote(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def sql_text_or_null(val: str | None, max_len: int = 200) -> str:
    s = (val or "").strip()
    if not s:
        return "NULL"
    return sql_quote(s[:max_len])


def catalog_label(meta: dict) -> str:
    return (meta.get("nombre") or "").strip()


def enrich(entry: dict) -> dict:
    bc = entry["barcode"]
    meta = dict(BARCODE_CATALOG.get(bc, {}))
    parsed = parse_nombre_producto(entry.get("nombre_ocr") or catalog_label(meta))

    nombre = catalog_label(meta) or parsed.nombre or entry["nombre_ocr"][:120]
    presentacion = (meta.get("presentacion") or parsed.presentacion or "").strip()
    principio_activo = (meta.get("principio_activo") or parsed.principio_activo or "").strip()
    concentracion = (meta.get("concentracion") or parsed.concentracion or "").strip()
    forma = (meta.get("forma_farmaceutica") or parsed.forma_farmaceutica or "").strip()
    marca = (meta.get("marca") or parsed.marca or "").strip()
    categoria = meta.get("categoria") or parsed.categoria or "GENERAL"
    tipo = meta.get("tipo") or ("MEDICAMENTO" if categoria == "Medicamentos" else "GENERICO")
    requiere_receta = bool(meta.get("requiere_receta", False))

    return {
        **entry,
        "nombre": nombre[:200],
        "marca": marca,
        "presentacion": presentacion,
        "principio_activo": principio_activo,
        "concentracion": concentracion,
        "forma_farmaceutica": forma,
        "categoria": categoria,
        "tipo": tipo,
        "requiere_receta": requiere_receta,
    }


def load_catalog() -> tuple[set[str], set[str], dict[str, dict]]:
    bcs: set[str] = set()
    skus: set[str] = set()
    by_bc: dict[str, dict] = {}
    for path in CATALOG_CSVS:
        if not path.exists():
            continue
        with path.open(encoding="utf-8") as f:
            for row in csv.DictReader(f):
                bc = (row.get("codigo_barras") or "").strip()
                sku = (row.get("sku") or "").strip()
                if bc:
                    bcs.add(bc)
                    by_bc[bc] = row
                if sku:
                    skus.add(sku)
    return bcs, skus, by_bc


def in_catalog(bc: str, sku: str, cat_bc: set[str], cat_sku: set[str]) -> bool:
    if bc in cat_bc or sku in cat_sku:
        return True
    for c in cat_bc:
        if len(bc) >= 10 and len(c) >= 10 and (c.endswith(bc[-10:]) or bc.endswith(c[-10:])):
            return True
    return False


def collect_ticket_rows() -> dict[str, dict]:
    ocr = load_ocr_from_pdfs(force=False)
    idx_bc = HEADERS.index("Código de barras")
    idx_name = HEADERS.index("Nombre / variante")
    idx_cost = HEADERS.index("Costo unitario s/IVA")
    idx_qty = HEADERS.index("Cantidad")
    idx_ticket = HEADERS.index("N.º ticket / orden")

    parsers = [
        (parse_bodega, "Bodega F-42.pdf"),
        (parse_surtidor, "El surtidor de su farmacia.pdf"),
        (lambda t: parse_ifc(t, "IFC1-080826", "118217"), "IFC 1.pdf"),
        (lambda t: parse_ifc(t, "IFC2-080826", "118216"), "IFC 2.pdf"),
        (parse_farma_mx, "Farma Mx.pdf"),
        (parse_farmalive, "FarmaLive.pdf"),
    ]

    by_bc: dict[str, dict] = {}
    for fn, key in parsers:
        for r in fn(ocr.get(key, "")):
            bc = norm_barcode(r[idx_bc])
            if not bc:
                continue
            sku = sku_for_row(r)
            entry = {
                "barcode": bc,
                "sku": sku,
                "nombre_ocr": str(r[idx_name] or "")[:120],
                "costo": float(r[idx_cost] or 0),
                "qty": max(1, int(r[idx_qty] or 1)),
                "ticket": str(r[idx_ticket] or ""),
            }
            prev = by_bc.get(bc)
            if not prev or entry["qty"] > prev["qty"]:
                by_bc[bc] = entry

    for sup in BARCODE_SUPPLEMENT:
        bc = BARCODE_ALIASES.get(sup["barcode"], sup["barcode"])
        sup = {**sup, "barcode": bc}
        if bc not in by_bc:
            by_bc[bc] = {
                "barcode": bc,
                "sku": f"FC-{bc[-8:]}" ,
                "nombre_ocr": catalog_label(BARCODE_CATALOG.get(bc, {})) or bc,
                "costo": sup["costo"],
                "qty": sup["qty"],
                "ticket": sup["ticket"],
            }
        else:
            by_bc[bc]["costo"] = max(by_bc[bc]["costo"], sup["costo"])
            by_bc[bc]["qty"] = max(by_bc[bc]["qty"], sup["qty"])

    merged: dict[str, dict] = {}
    for bc, entry in by_bc.items():
        canon = BARCODE_ALIASES.get(bc, bc)
        e = {**entry, "barcode": canon, "sku": f"FC-{canon[-8:]}"}
        if canon in COSTO_OVERRIDE:
            e["costo"] = COSTO_OVERRIDE[canon]
        prev = merged.get(canon)
        if not prev or e["qty"] > prev["qty"]:
            merged[canon] = e
        elif prev and e["costo"] > prev["costo"]:
            merged[canon]["costo"] = e["costo"]

    return merged


def sql_insert_block(p: dict, n: int) -> str:
    bc = p["barcode"]
    sku = p["sku"]
    costo = round(float(p["costo"]), 2)
    precio = precio_venta(costo)
    qty = max(1, int(p["qty"]))
    ticket = p["ticket"]
    nombre = p["nombre"][:200]
    desc = f"{nombre} — Ticket {ticket} (insert-only)"

    receta_sql = "true" if p.get("requiere_receta") else "false"

    return f"""
-- [{n}] {ticket} · {bc} · {nombre[:50]}
-- PA: {(p.get('principio_activo') or '—')[:60]} | Pres: {p.get('presentacion') or '—'}
do $$
declare v_pid bigint; v_lid bigint;
begin
  -- NO tocar productos que ya existen (respeta tus cambios de nombre/precio)
  if exists (
    select 1 from public.productos
    where codigo_barras = {sql_quote(bc)} or sku = {sql_quote(sku)}
  ) then
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(
    jsonb_build_object(
      'nombre', {sql_quote(nombre)},
      'sku', {sql_quote(sku)},
      'codigo_barras', {sql_quote(bc)},
      'categoria', {sql_quote(p.get('categoria') or 'GENERAL')},
      'tipo', {sql_quote(p.get('tipo') or 'GENERICO')},
      'descripcion', {sql_quote(desc)},
      'costo', {costo:.2f},
      'precio', {precio:.2f},
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', {receta_sql}
    ),
    {qty},
    {sql_quote(f'TK-{ticket}-{n}')},
    NULL::date,
    {costo:.2f},
    null::bigint,
    null::text
  ) f;

  -- Campos de catálogo (solo fila recién creada)
  update public.productos set
    marca = {sql_text_or_null(p.get('marca'), 120)},
    presentacion = {sql_text_or_null(p.get('presentacion'))},
    principio_activo = {sql_text_or_null(p.get('principio_activo'))},
    concentracion = {sql_text_or_null(p.get('concentracion'))},
    forma_farmaceutica = {sql_text_or_null(p.get('forma_farmaceutica'))}
  where id = v_pid;
end $$;"""


def main() -> None:
    cat_bc, cat_sku, cat_by_bc = load_catalog()
    ticket_rows = collect_ticket_rows()

    missing: list[dict] = []
    already: list[dict] = []

    for bc, raw in sorted(ticket_rows.items()):
        p = enrich(raw)
        if in_catalog(bc, p["sku"], cat_bc, cat_sku):
            row = cat_by_bc.get(bc, {})
            already.append(
                {
                    **p,
                    "sku_cat": row.get("sku", ""),
                    "nombre_cat": (row.get("nombre") or row.get("nombre_comercial") or "")[:50],
                }
            )
        else:
            missing.append(p)

    OUT_MD.parent.mkdir(parents=True, exist_ok=True)

    md_lines = [
        "# Auditoría faltantes — todos los tickets PDF",
        "",
        "Comparado contra export local del catálogo (no pisa lo que ya tengas en Supabase).",
        "",
        f"- Líneas únicas por barcode en tickets: **{len(ticket_rows)}**",
        f"- Ya en catálogo (CSV): **{len(already)}**",
        f"- Faltan insertar: **{len(missing)}**",
        "",
        "## SQL generado",
        "",
        f"`{OUT_SQL.name}` — **INSERT ONLY**: si el barcode o SKU ya existe, `return` sin cambios.",
        "",
        "Precio/costo inicial solo en filas nuevas (costo ticket + 35% margen). Ajusta después en inventario.",
        "",
        "## Faltantes por ticket",
        "",
        "| Ticket | Barcode | Nombre | Presentación | Principio activo | Costo | Qty |",
        "|--------|---------|--------|--------------|------------------|-------|-----|",
    ]
    for p in missing:
        md_lines.append(
            f"| {p['ticket']} | `{p['barcode']}` | {p['nombre'][:30]} | "
            f"{(p.get('presentacion') or '—')[:20]} | "
            f"{(p.get('principio_activo') or '—')[:35]} | "
            f"${p['costo']:.2f} | {p['qty']} |"
        )

    md_lines += [
        "",
        "## Ya registrados (no se tocan)",
        "",
        f"Total: {len(already)} productos — el SQL los omite automáticamente.",
        "",
    ]

    OUT_MD.write_text("\n".join(md_lines), encoding="utf-8")

    header = f"""-- ============================================================================
-- INSERT ONLY — productos faltantes de tickets PDF
-- {len(missing)} bloques · NO actualiza filas existentes
-- Incluye marca, presentación, PA, forma (solo productos nuevos)
-- Precio inicial = costo ticket × 1.35 (solo filas nuevas)
-- PASO 0 previo (si aplica): sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

"""
    blocks = [sql_insert_block(p, i) for i, p in enumerate(missing, 1)]
    footer = """
commit;

-- Verificación: cuántos se insertaron depende de lo que ya tengas en Supabase
select count(*) as total_productos from public.productos;
"""
    OUT_SQL.write_text(header + "\n".join(blocks) + footer, encoding="utf-8")

    print(f"Tickets parseados: {len(ticket_rows)} barcodes únicos")
    print(f"Ya en catálogo CSV: {len(already)}")
    print(f"Faltantes (SQL): {len(missing)}")
    print(f"Auditoría: {OUT_MD}")
    print(f"SQL:       {OUT_SQL}")


if __name__ == "__main__":
    main()
