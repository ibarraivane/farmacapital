#!/usr/bin/env python3
"""
Un solo SQL idempotente: ticket FL-080826 completo + altas verificadas en empaque.

  python3 scripts/auditar_lista_farmalive.py
  python3 scripts/generar_patch_farmalive_completo.py

Salida: sql/patch_farmalive_completo_20260815.sql
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

from auditar_lista_farmalive import OUT_SQL as AUDIT_SQL, PRODUCTOS, sql_block  # noqa: E402
from generar_patch_catalogo_canonico import sql_fix  # noqa: E402
from datos_barcodes_canonicos import CORRECCIONES, ALTAS_MANUALES, ProductoCanonico, sku_from_bc  # noqa: E402
from generar_patch_catalogo_canonico import sql_insert  # noqa: E402

OUT = ROOT / "sql" / "patch_farmalive_completo_20260815.sql"

# Bloques DO $$ con lote/caducidad verificados en empaque (prioridad sobre genérico)
EMPAQUE_EXTRA = ROOT / "sql" / "patch_altas_farmalive_anexos_20260815.sql"
TABCIN = ROOT / "sql" / "patch_tabcin_linea_20260815.sql"


def strip_transaction(sql: str) -> str:
    s = re.sub(r"^begin;\s*", "", sql, flags=re.I | re.M)
    s = re.sub(r"^commit;\s*", "", s, flags=re.I | re.M)
    return s.strip()


def extract_do_blocks(path: Path) -> str:
    if not path.exists():
        return ""
    return strip_transaction(path.read_text(encoding="utf-8"))


def barcodes_auditoria() -> set[str]:
    return {(p.get("bc") or "").strip() for p in PRODUCTOS if p.get("bc")}


def main() -> None:
    # Regenerar bloques ticket si hace falta
    if not AUDIT_SQL.exists():
        import auditar_lista_farmalive

        auditar_lista_farmalive.main()

    audit_body = AUDIT_SQL.read_text(encoding="utf-8")
    # Quitar header/footer del patch 1b; conservar temp table + bloques
    audit_body = re.sub(
        r"^-- =+\n.*?\n\nbegin;\n\n",
        "",
        audit_body,
        count=1,
        flags=re.S,
    )
    audit_body = re.sub(r"\ncommit;\n\nselect count.*$", "", audit_body, flags=re.S)

    bc_audit = barcodes_auditoria()
    canon_inserts: list[str] = []
    for p in ALTAS_MANUALES:
        if p.barcode in bc_audit:
            continue
        canon_inserts.extend(sql_insert(p))

    fixes: list[str] = []
    for p in CORRECCIONES:
        fixes.extend(sql_fix(p))

    empaque = extract_do_blocks(EMPAQUE_EXTRA)
    tabcin = extract_do_blocks(TABCIN)

    all_bcs = sorted(
        bc_audit
        | {p.barcode for p in ALTAS_MANUALES}
        | {p.barcode for p in CORRECCIONES}
        | {"7501088579615", "7501537103521", "7502209747366"}
        | {"7501008485316", "7501008499702", "7501008485408", "7501008499689"}
    )
    bc_list = ",\n  ".join(f"'{b}'" for b in all_bcs if b)

    parts = [
        "-- ═══════════════════════════════════════════════════════════════════",
        "-- FARMA LIVE FL-080826 — CARGA COMPLETA (UN SOLO PEGADO EN SUPABASE)",
        "-- Idempotente: si el producto ya existe, no duplica.",
        "-- Generado: scripts/generar_patch_farmalive_completo.py",
        "-- ═══════════════════════════════════════════════════════════════════",
        "",
        "begin;",
        "",
        "create temp table if not exists _fc_carga_map (",
        "  codigo_barras text primary key,",
        "  producto_id bigint",
        ") on commit preserve rows;",
        "",
        "insert into _fc_carga_map (codigo_barras, producto_id)",
        "select codigo_barras, id from public.productos",
        "where codigo_barras is not null and btrim(codigo_barras) <> ''",
        "on conflict (codigo_barras) do nothing;",
        "",
        "-- ── 1) Corregir barcodes OCR en productos que ya existían ──",
        "",
        *fixes,
        "-- ── 2) Productos del ticket (Genomma 65024…, OCR truncado, etc.) ──",
        "",
        audit_body,
        "-- ── 3) Altas verificadas en empaque (Topron, Brunadol, Veridex) ──",
        "",
        empaque,
        "-- ── 4) Línea Tabcin (4 EAN distintos) ──",
        "",
        tabcin,
        "-- ── 5) Otros del anaquel no listados en ticket OCR ──",
        "",
        *canon_inserts,
        "commit;",
        "",
        "-- Verificación: cuenta por barcode clave del ticket + fotos",
        "SELECT p.sku, p.nombre, p.codigo_barras, p.stock, p.precio, p.activo",
        "FROM public.productos p",
        "WHERE p.codigo_barras IN (",
        f"  {bc_list}",
        ")",
        "ORDER BY p.nombre;",
        "",
    ]

    OUT.write_text("\n".join(parts) + "\n", encoding="utf-8")
    print(f"Generado: {OUT}")
    print(f"  correcciones: {len(CORRECCIONES)}")
    print(f"  ticket (auditoría): {len(bc_audit)} barcodes en lista")
    print(f"  canon extra (no en lista): {len(canon_inserts) // 20}")


if __name__ == "__main__":
    main()
