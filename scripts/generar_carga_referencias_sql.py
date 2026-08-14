#!/usr/bin/env python3
"""Regenera sql/pricing/generated/carga_inicial_referencias_YYYYMMDD.sql desde CSV listos."""
from __future__ import annotations

import csv
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FECHA = "2026-08-14"
OUT = ROOT / "sql/pricing/generated/carga_inicial_referencias_20260814.sql"
CONF_MAP = {"alta": 85, "media": 75, "dudoso": 60}


def sql_quote(s: str) -> str:
    return "'" + str(s).replace("'", "''") + "'"


def load_listo(path: Path) -> list[tuple]:
    rows = []
    with path.open(newline="", encoding="utf-8") as f:
        for r in csv.DictReader(f):
            sku = (r.get("sku") or "").strip()
            precio = r.get("precio")
            if not sku or not precio:
                continue
            rows.append((sku, float(precio), r.get("confianza_match") or r.get("confianza"), r.get("notas", "")))
    return rows


def block(fuente, tipo, archivo, notas, rows, with_notas=False):
    lines = [
        "",
        f"-- {fuente.upper()} ({len(rows)} SKUs)",
        "WITH imp AS (",
        "  INSERT INTO public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)",
        f"  VALUES ({sql_quote(fuente)}, {sql_quote(tipo)}, {sql_quote(FECHA)}, {sql_quote(archivo)}, {len(rows)}, {sql_quote(notas)})",
        "  RETURNING id",
        ")",
    ]
    if with_notas:
        lines.append(
            "INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza, notas)"
        )
        lines.append(
            f"SELECT p.id, {sql_quote(fuente)}, {sql_quote(tipo)}, v.precio, {sql_quote(FECHA)}::date, 'import_csv', imp.id, v.confianza, v.notas"
        )
    else:
        lines.append(
            "INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza)"
        )
        lines.append(
            f"SELECT p.id, {sql_quote(fuente)}, {sql_quote(tipo)}, v.precio, {sql_quote(FECHA)}::date, 'import_csv', imp.id, v.confianza"
        )
    lines.append("FROM imp, (VALUES")
    vals = []
    for sku, precio, conf, nota in rows:
        c = CONF_MAP.get(str(conf).lower(), int(conf) if str(conf).isdigit() else 85)
        if with_notas:
            vals.append(f"  ({sql_quote(sku)}, {precio}::numeric, {c}::smallint, {sql_quote(nota or '')})")
        else:
            vals.append(f"  ({sql_quote(sku)}, {precio}::numeric, {c}::smallint)")
    lines.append(",\n".join(vals))
    lines.append(") AS v(sku, precio, confianza" + (", notas)" if with_notas else ")"))
    lines.append("JOIN public.productos p ON p.sku = v.sku AND p.activo = true;")
    return lines


def main() -> None:
    fah = load_listo(ROOT / "pricing/importados/import_fahorro_listo.csv")
    exp = load_listo(ROOT / "pricing/importados/import_exprezo_listo.csv")
    sim = load_listo(ROOT / "pricing/importados/import_similares_lote1_listo.csv")

    migrate = (ROOT / "sql/migrate_precios_competencia_a_referencias.sql").read_text(encoding="utf-8")
    migrate_lines = [
        ln for ln in migrate.splitlines()
        if ln.strip().upper() not in ("BEGIN;", "COMMIT;") and not ln.startswith("-- ═")
    ]

    parts = [
        "-- Carga inicial referencias de precio — FarmaCapital",
        f"-- Generado {date.today().isoformat()} — fahorro {len(fah)}, exprezo {len(exp)}, similares {len(sim)}",
        "-- Ejecutar en Supabase SQL Editor (una sola vez)",
        "",
        "BEGIN;",
        "",
        "GRANT USAGE, SELECT ON SEQUENCE public.importaciones_referencia_id_seq TO anon, authenticated;",
        "GRANT USAGE, SELECT ON SEQUENCE public.producto_precios_referencia_id_seq TO anon, authenticated;",
        "",
        *migrate_lines,
    ]
    parts.extend(block("fahorro", "venta", "import_fahorro_listo.csv", "Claude capturas FDA", fah))
    parts.extend(block("exprezo", "compra", "import_exprezo_listo.csv", "Claude + lista Exprezo", exp))
    sim_rows = [(s, p, CONF_MAP.get(str(c).lower(), 85), n) for s, p, c, n in sim]
    parts.extend(block("similares", "venta", "import_similares_lote1_listo.csv", "Claude lote1 Similares", sim_rows, with_notas=True))
    parts.extend(["", "COMMIT;", ""])

    OUT.write_text("\n".join(parts), encoding="utf-8")
    print(f"OK → {OUT} ({len(fah)+len(exp)+len(sim)} referencias)")


if __name__ == "__main__":
    main()
