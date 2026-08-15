#!/usr/bin/env python3
"""
Audita inventario live (Supabase export) y genera SQL para completar SOLO campos vacíos:
  codigo_barras, presentacion, principio_activo, marca, concentracion, forma_farmaceutica

NO pisa precio, costo, stock ni campos que ya tengan valor.

  python3 scripts/exportar_catalogo_supabase.py   # primero, datos frescos
  python3 scripts/generar_patch_completar_campos.py

Salida:
  sql/generated/auditoria_campos_vacios_inventario.md
  sql/patch_completar_campos_vacios.sql
"""

from __future__ import annotations

import csv
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

from auditar_cantidades_vs_pdfs import norm_barcode  # noqa: E402
from datos_catalogo_faltantes import BARCODE_CATALOG, lookup_barcode_catalog  # noqa: E402
from datos_catalogo_inventario_web import lookup_sku_catalog  # noqa: E402
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

CATALOG_CSV = ROOT / "sql" / "preview_catalogo_campos_y_precios.csv"
LOTE2_CSV = ROOT / "pricing" / "importados" / "lote2_50_medicamentos_claude.csv"
OUT_MD = ROOT / "sql" / "generated" / "auditoria_campos_vacios_inventario.md"
OUT_SQL = ROOT / "sql" / "patch_completar_campos_vacios.sql"

BARCODE_ALIASES = {
    "750168517111": "7501685171113",
    "7501685171118": "7501685171113",
    "7501354312225027": "3543122250276",
    "7501354312250": "3543122250276",
    "75010506134531": "7501050613453",
    "750222503430721": "7502250343072",
}


def empty(val: str | None) -> bool:
    return not (val or "").strip()


def sql_quote(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def sql_str_or_keep(field: str, new_val: str | None) -> str:
    """Solo asigna si el campo está vacío en BD."""
    v = (new_val or "").strip()
    if not v:
        return f"{field} = {field}"
    expr = f"CASE WHEN {field} IS NULL OR btrim({field}) = '' THEN {sql_quote(v)} ELSE {field} END"
    return f"{field} = {expr}"


def load_lote2_by_sku() -> dict[str, dict]:
    if not LOTE2_CSV.exists():
        return {}
    out: dict[str, dict] = {}
    for row in csv.DictReader(LOTE2_CSV.open(encoding="utf-8")):
        sku = (row.get("sku") or "").strip()
        if sku:
            out[sku] = row
    return out


def norm_name(s: str) -> str:
    import re

    s = re.sub(r"\s+", " ", (s or "").upper().strip())
    return re.sub(r"[^A-Z0-9 ]", "", s)


def build_ticket_barcode_index() -> tuple[dict[str, dict], list[tuple[str, str, str]]]:
    """Por barcode y lista (bc_norm, bc, nombre) para fuzzy."""
    ocr = load_ocr_from_pdfs(force=False)
    idx_bc = HEADERS.index("Código de barras")
    idx_name = HEADERS.index("Nombre / variante")
    parsers = [
        (parse_bodega, "Bodega F-42.pdf"),
        (parse_surtidor, "El surtidor de su farmacia.pdf"),
        (lambda t: parse_ifc(t, "IFC1-080826", "118217"), "IFC 1.pdf"),
        (lambda t: parse_ifc(t, "IFC2-080826", "118216"), "IFC 2.pdf"),
        (parse_farma_mx, "Farma Mx.pdf"),
        (parse_farmalive, "FarmaLive.pdf"),
    ]
    by_bc: dict[str, dict] = {}
    fuzzy_pool: list[tuple[str, str, str]] = []
    for fn, key in parsers:
        for r in fn(ocr.get(key, "")):
            bc = norm_barcode(r[idx_bc])
            if not bc:
                continue
            bc = BARCODE_ALIASES.get(bc, bc)
            name = str(r[idx_name] or "")
            by_bc[bc] = {"nombre_ocr": name, "barcode": bc}
            fuzzy_pool.append((norm_name(name), bc, name))
    return by_bc, fuzzy_pool


def fuzzy_barcode_for_name(nombre: str, fuzzy_pool: list[tuple[str, str, str]]) -> str | None:
    if not nombre or len(fuzzy_pool) < 1:
        return None
    try:
        from rapidfuzz import fuzz, process
    except ImportError:
        sys.path.insert(0, str(ROOT / ".pip_packages"))
        from rapidfuzz import fuzz, process  # type: ignore

    ndb = norm_name(nombre)
    if len(ndb) < 5:
        return None
    best = process.extractOne(ndb, [x[0] for x in fuzzy_pool], scorer=fuzz.token_set_ratio)
    if not best or best[1] < 88:
        return None
    idx = [x[0] for x in fuzzy_pool].index(best[0])
    return fuzzy_pool[idx][1]


def meta_for_product(
    row: dict,
    ticket_by_bc: dict[str, dict],
    lote2_by_sku: dict[str, dict],
    fuzzy_pool: list[tuple[str, str, str]],
) -> dict:
    bc = (row.get("codigo_barras") or "").strip()
    bc = BARCODE_ALIASES.get(bc, bc) if bc else bc
    sku = (row.get("sku") or "").strip()
    nombre = (row.get("nombre") or "").strip()

    meta: dict = {}
    sku_meta = lookup_sku_catalog(sku, nombre=nombre, marca=(row.get("marca") or ""))
    if sku_meta:
        meta.update(sku_meta)

    cat = lookup_barcode_catalog(bc) if bc else None
    if cat:
        for k, v in cat.items():
            if v and k not in meta:
                meta[k] = v
    elif sku.startswith("FC-") and len(sku) > 3:
        suffix = sku[3:]
        for catalog_bc, cat_row in BARCODE_CATALOG.items():
            if catalog_bc.endswith(suffix) or suffix == catalog_bc[-8:]:
                for k, v in cat_row.items():
                    if v and k not in meta:
                        meta[k] = v
                if empty(bc):
                    meta.setdefault("_barcode", catalog_bc)
                break

    l2 = lote2_by_sku.get(sku, {})
    if l2:
        for src, dst in (
            ("principio_activo", "principio_activo"),
            ("presentacion", "presentacion"),
            ("concentracion", "concentracion"),
            ("marca", "marca"),
        ):
            if (l2.get(src) or "").strip() and dst not in meta:
                meta[dst] = l2[src].strip()

    src_name = meta.get("nombre") or nombre
    if bc and bc in ticket_by_bc:
        src_name = ticket_by_bc[bc].get("nombre_ocr") or src_name

    parsed = parse_nombre_producto(src_name, row.get("tipo"))

    if empty(bc):
        guess_bc = fuzzy_barcode_for_name(nombre, fuzzy_pool)
        if guess_bc:
            meta.setdefault("_barcode", guess_bc)
            guess_cat = lookup_barcode_catalog(guess_bc)
            if guess_cat:
                for k, v in guess_cat.items():
                    if v and k not in meta:
                        meta[k] = v

    out = {
        "codigo_barras": meta.get("_barcode") or meta.get("codigo_barras") or (bc if bc else None),
        "marca": (meta.get("marca") or parsed.marca or "").strip(),
        "presentacion": (meta.get("presentacion") or parsed.presentacion or "").strip(),
        "principio_activo": (meta.get("principio_activo") or parsed.principio_activo or "").strip(),
        "concentracion": (meta.get("concentracion") or parsed.concentracion or "").strip(),
        "forma_farmaceutica": (meta.get("forma_farmaceutica") or parsed.forma_farmaceutica or "").strip(),
    }
    if not out["codigo_barras"] and sku.startswith("FC-") and len(sku) >= 11:
        suf = sku[3:]
        for catalog_bc in BARCODE_CATALOG:
            if catalog_bc.endswith(suf):
                out["codigo_barras"] = catalog_bc
                break
    return out


def needs_update(row: dict, meta: dict) -> tuple[bool, list[str]]:
    fields = []
    if empty(row.get("codigo_barras")) and meta.get("codigo_barras"):
        fields.append("codigo_barras")
    for f in ("presentacion", "principio_activo", "marca", "concentracion", "forma_farmaceutica"):
        if empty(row.get(f)) and meta.get(f):
            fields.append(f)
    return bool(fields), fields


def sql_update_block(row: dict, meta: dict, fields: list[str], n: int) -> str:
    sku = row["sku"]
    sets = []
    if "codigo_barras" in fields:
        sets.append(sql_str_or_keep("codigo_barras", meta["codigo_barras"]))
    if "marca" in fields:
        sets.append(sql_str_or_keep("marca", meta["marca"]))
    if "presentacion" in fields:
        sets.append(sql_str_or_keep("presentacion", meta["presentacion"]))
    if "principio_activo" in fields:
        sets.append(sql_str_or_keep("principio_activo", meta["principio_activo"]))
    if "concentracion" in fields:
        sets.append(sql_str_or_keep("concentracion", meta["concentracion"]))
    if "forma_farmaceutica" in fields:
        sets.append(sql_str_or_keep("forma_farmaceutica", meta["forma_farmaceutica"]))

    nombre = (row.get("nombre") or "")[:40]
    set_clause = ",\n  ".join(sets)
    return f"""
-- [{n}] {sku} · {nombre}
update public.productos set
  {set_clause}
where sku = {sql_quote(sku)}
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );"""


def main() -> None:
    if not CATALOG_CSV.exists():
        sys.exit(f"Ejecuta primero: python3 scripts/exportar_catalogo_supabase.py\nNo hay {CATALOG_CSV}")

    ticket_by_bc, fuzzy_pool = build_ticket_barcode_index()
    lote2_by_sku = load_lote2_by_sku()
    rows = list(csv.DictReader(CATALOG_CSV.open(encoding="utf-8")))

    updates: list[tuple[dict, dict, list[str]]] = []
    stats = {
        "sin_bc": 0,
        "sin_pres": 0,
        "sin_pa": 0,
        "total": len(rows),
        "bc_desde_fuzzy": 0,
    }

    for row in rows:
        if empty(row.get("codigo_barras")):
            stats["sin_bc"] += 1
        if empty(row.get("presentacion")):
            stats["sin_pres"] += 1
        if empty(row.get("principio_activo")):
            stats["sin_pa"] += 1

        meta = meta_for_product(row, ticket_by_bc, lote2_by_sku, fuzzy_pool)
        if empty(row.get("codigo_barras")) and meta.get("codigo_barras"):
            stats["bc_desde_fuzzy"] += 1
        ok, fields = needs_update(row, meta)
        if ok:
            updates.append((row, meta, fields))

    # Priorizar: tienen barcode en ticket curado, luego medicamentos
    def priority(item):
        row, meta, fields = item
        has_curated = bool(
            (row.get("codigo_barras") or "") in BARCODE_CATALOG
            or meta.get("codigo_barras") in BARCODE_CATALOG
        )
        is_med = "principio_activo" in fields or "presentacion" in fields
        return (0 if has_curated else 1, 0 if is_med else 1, row.get("sku", ""))

    updates.sort(key=priority)

    OUT_MD.parent.mkdir(parents=True, exist_ok=True)
    md = [
        "# Auditoría campos vacíos — inventario live",
        "",
        f"Export: `{CATALOG_CSV.name}` · **{stats['total']}** productos",
        "",
        "| Métrica | Cantidad |",
        "|---------|----------|",
        f"| Sin código de barras | {stats['sin_bc']} |",
        f"| Sin presentación | {stats['sin_pres']} |",
        f"| Sin principio activo | {stats['sin_pa']} |",
        f"| **Parches SQL generados** | **{len(updates)}** |",
        f"| Barcodes inferidos (fuzzy ticket) | {stats['bc_desde_fuzzy']} |",
        "",
        "El SQL `patch_completar_campos_vacios.sql` solo rellena campos **vacíos**.",
        "No modifica precio, costo, stock ni valores ya capturados.",
        "",
        "## Top actualizaciones (FarmaLive / catálogo curado)",
        "",
        "| SKU | Nombre | Campos | PA | Presentación |",
        "|-----|--------|--------|-----|--------------|",
    ]
    shown = 0
    for row, meta, fields in updates:
        if shown >= 60:
            break
        bc = row.get("codigo_barras") or meta.get("codigo_barras") or ""
        if bc in BARCODE_CATALOG or any(
            f in fields for f in ("principio_activo", "presentacion", "codigo_barras")
        ):
            md.append(
                f"| {row['sku']} | {(row.get('nombre') or '')[:30]} | "
                f"{', '.join(fields)} | {(meta.get('principio_activo') or '—')[:30]} | "
                f"{(meta.get('presentacion') or '—')[:15]} |"
            )
            shown += 1

    md += [
        "",
        "## Sin barcode — requieren ticket/Farma MX manual",
        "",
        f"Total sin barcode: **{stats['sin_bc']}** · Fuzzy puede asignar ~**{stats['bc_desde_fuzzy']}**",
        "El resto son Farma MX / IFC / antibióticos sin EAN en OCR del ticket.",
        "",
        "### Acción requerida",
        "",
        "1. Ejecutar `sql/patch_completar_campos_vacios.sql` en Supabase SQL Editor",
        "2. Recargar pestaña Inventario",
        "3. Los ~47 medicamentos FarmaLive (Vitacilina, XL-3, Nasalub, etc.) quedarán con PA y presentación",
        "",
    ]
    OUT_MD.write_text("\n".join(md), encoding="utf-8")

    header = f"""-- ============================================================================
-- COMPLETAR campos vacíos — inventario (NO pisa precios ni nombres editados)
-- {len(updates)} updates · solo rellena NULL/vacío
-- Ejecutar después de exportar catálogo fresco
-- ============================================================================

begin;

"""
    blocks = [sql_update_block(row, meta, fields, i) for i, (row, meta, fields) in enumerate(updates, 1)]
    footer = """
commit;

select
  count(*) filter (where codigo_barras is null or btrim(codigo_barras) = '') as sin_barcode,
  count(*) filter (where presentacion is null or btrim(presentacion) = '') as sin_presentacion,
  count(*) filter (where principio_activo is null or btrim(principio_activo) = '') as sin_pa
from public.productos;
"""
    OUT_SQL.write_text(header + "\n".join(blocks) + footer, encoding="utf-8")

    print(f"Productos: {stats['total']}")
    print(f"Sin barcode: {stats['sin_bc']} | sin pres: {stats['sin_pres']} | sin PA: {stats['sin_pa']}")
    print(f"Updates SQL: {len(updates)}")
    print(f"Auditoría: {OUT_MD}")
    print(f"SQL:       {OUT_SQL}")


if __name__ == "__main__":
    main()
