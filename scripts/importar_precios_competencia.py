#!/usr/bin/env python3
"""Importa precios Similares / Del Ahorro desde CSV (sku, precio_similares, precio_del_ahorro)."""

from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CSV = ROOT / "sql" / "plantilla_precios_competencia.csv"
OUT_SQL = ROOT / "sql" / "actualizar_precios_competencia.sql"


def sql_quote(val: str) -> str:
    return "'" + val.replace("'", "''") + "'"


def main() -> None:
    csv_path = DEFAULT_CSV
    if not csv_path.exists():
        raise SystemExit(f"Crea y llena {csv_path}")

    rows: list[tuple[str, str, str]] = []
    with csv_path.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            sku = (row.get("sku") or "").strip()
            sim = (row.get("precio_similares") or "").strip()
            aho = (row.get("precio_del_ahorro") or "").strip()
            if not sku or (not sim and not aho):
                continue
            rows.append((sku, sim, aho))

    if not rows:
        raise SystemExit("No hay filas con sku y al menos un precio de competencia.")

    lines = [
        "-- Precios referencia Similares / Del Ahorro",
        f"-- Filas: {len(rows)}",
        "",
        "begin;",
        "",
    ]
    for sku, sim, aho in rows:
        parts = ["fecha_actualizacion_precios = current_date"]
        if sim:
            parts.append(f"precio_similares = {float(sim)}")
        if aho:
            parts.append(f"precio_del_ahorro = {float(aho)}")
        lines.append(
            f"update public.productos set {', '.join(parts)} where sku = {sql_quote(sku)};"
        )

    lines.extend(["", "commit;", ""])
    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")
    print(f"Generado: {OUT_SQL} ({len(rows)} updates)")


if __name__ == "__main__":
    main()
