#!/usr/bin/env python3
"""Convierte captura_barcodes_manual.csv (rellenado) en SQL de UPDATE para Supabase."""

from __future__ import annotations

import csv
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CSV = ROOT / "sql" / "captura_barcodes_manual.csv"
OUT_SQL = ROOT / "sql" / "actualizar_barcodes_capturados_manual.sql"


def sql_quote(val: str) -> str:
    return "'" + val.replace("'", "''") + "'"


def main() -> None:
    csv_path = DEFAULT_CSV
    if not csv_path.exists():
        raise SystemExit(f"No existe {csv_path}. Rellena codigo_barras y vuelve a correr.")

    rows: list[tuple[str, str]] = []
    seen_bc: set[str] = set()

    with csv_path.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            sku = (row.get("sku") or "").strip()
            bc = re.sub(r"\D", "", row.get("codigo_barras") or "")
            if not sku or not bc:
                continue
            if bc in seen_bc:
                print(f"Omitido barcode duplicado {bc} (sku {sku})")
                continue
            seen_bc.add(bc)
            rows.append((sku, bc))

    if not rows:
        raise SystemExit("No hay filas con sku + codigo_barras. Escanea y rellena el CSV.")

    lines = [
        "-- Actualización manual de códigos de barras (escaneo físico)",
        f"-- Filas: {len(rows)}",
        "",
        "begin;",
        "",
    ]
    for sku, bc in rows:
        lines.append(
            f"update public.productos set codigo_barras = {sql_quote(bc)} "
            f"where sku = {sql_quote(sku)};"
        )

    lines.extend(["", "commit;", ""])
    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")
    print(f"Generado: {OUT_SQL} ({len(rows)} updates)")


if __name__ == "__main__":
    main()
