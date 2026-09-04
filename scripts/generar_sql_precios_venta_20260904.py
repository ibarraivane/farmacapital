#!/usr/bin/env python3
"""Genera SQL de ajuste de PVP a partir de 07_diagnostico_sku.csv.

Reglas de seguridad (no aplicar outliers de presentación):
  - nuevo > costo
  - subida ≤ 30%
  - bajada ≤ 20%
  - revisar_compra (piso > mercado) va a un archivo aparte

  python3 scripts/generar_sql_precios_venta_20260904.py
"""
from __future__ import annotations

import csv
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIAG = ROOT / "pricing" / "reportes" / "diagnostico_20260904" / "07_diagnostico_sku.csv"
SQL_DIR = ROOT / "sql"
MAX_SUBIDA = 0.30
MAX_BAJADA = 0.20


def fnum(v):
    if v is None or str(v).strip() == "":
        return None
    try:
        n = float(str(v).replace(",", ""))
    except ValueError:
        return None
    return n if math.isfinite(n) else None


def esc(s: str) -> str:
    return str(s or "").replace("'", "''")


def main() -> None:
    rows = list(csv.DictReader(DIAG.open(encoding="utf-8")))
    aplicar = []
    outliers = []
    revisar = []

    for r in rows:
        sku = r.get("sku") or ""
        actual = fnum(r.get("precio"))
        nuevo = fnum(r.get("sugerido_nuevo"))
        costo = fnum(r.get("costo"))
        if actual is None or nuevo is None or costo is None:
            continue
        if abs(nuevo - actual) < 1.5:
            continue
        if nuevo <= costo:
            outliers.append((r, "nuevo_no_cubre_costo"))
            continue
        delta = (nuevo - actual) / actual
        motivo = r.get("accion_precio") or ""
        if motivo == "revisar_compra":
            revisar.append((r, delta))
            continue
        if delta > MAX_SUBIDA:
            outliers.append((r, f"subida_{delta*100:.0f}pct_posible_otra_presentacion"))
            continue
        if delta < -MAX_BAJADA:
            outliers.append((r, f"bajada_{abs(delta)*100:.0f}pct"))
            continue
        aplicar.append((r, delta))

    def block(items, comment_motivo=False):
        lines = []
        for r, extra in items:
            actual = fnum(r["precio"])
            nuevo = int(fnum(r["sugerido_nuevo"]))
            costo = fnum(r["costo"])
            delta = (nuevo - actual) / actual * 100
            tag = extra if isinstance(extra, str) else r.get("accion_precio")
            lines.append(
                f"-- {esc(r.get('nombre'))} · {r.get('sku')} · "
                f"${actual:.2f} → ${nuevo} ({delta:+.1f}%) · costo ${costo:.2f} · {tag}\n"
                f"update public.productos\n"
                f"   set precio = {nuevo}\n"
                f" where sku = '{esc(r.get('sku'))}'\n"
                f"   and costo is not null and costo > 0\n"
                f"   and {nuevo} > costo\n"
                f"   and abs(coalesce(precio, 0) - {nuevo}) >= 1.5;"
            )
        return lines

    bak = """-- Backup de PVP antes de aplicar. Idempotente.
create table if not exists public.productos_precio_backup_20260904 as
select id, sku, nombre, precio, costo, codigo_barras, now() as respaldado_en
from public.productos
where false;

insert into public.productos_precio_backup_20260904 (id, sku, nombre, precio, costo, codigo_barras, respaldado_en)
select p.id, p.sku, p.nombre, p.precio, p.costo, p.codigo_barras, now()
from public.productos p
where not exists (
  select 1 from public.productos_precio_backup_20260904 b where b.id = p.id
);
"""

    aplicar_sql = SQL_DIR / "patch_precios_venta_aplicar_20260904.sql"
    aplicar_sql.write_text(
        "-- PVP dentro de ±30% / −20%, siempre arriba del costo.\n"
        "-- Generado por scripts/generar_sql_precios_venta_20260904.py\n"
        f"-- {len(aplicar)} productos\n"
        "begin;\n\n"
        + bak
        + "\n"
        + "\n".join(block(aplicar))
        + "\n\ncommit;\n",
        encoding="utf-8",
    )

    revisar_sql = SQL_DIR / "patch_precios_venta_revisar_compra_20260904.sql"
    revisar_sql.write_text(
        "-- Piso > mercado. Aplica el PISO (no el min de Similares).\n"
        "-- Revísalo: te puede dejar caro vs Similares. No corre en el lote seguro.\n"
        f"-- {len(revisar)} productos\n"
        "begin;\n\n"
        + bak
        + "\n"
        + "\n".join(block(revisar))
        + "\n\ncommit;\n",
        encoding="utf-8",
    )

    out_sql = SQL_DIR / "patch_precios_venta_outliers_NO_CORRER_20260904.sql"
    lines = [
        "-- NO CORRER. Refs de otra presentación (caja vs FA, 10 vs 30 tabs, etc.).",
        f"-- {len(outliers)} productos. Ejemplo: Amlodipino $12 → $282.",
        "-- Solo documentación.",
        "",
    ]
    for r, why in outliers:
        actual = fnum(r["precio"])
        nuevo = fnum(r["sugerido_nuevo"])
        lines.append(
            f"-- BLOQUEADO {r.get('sku')} {r.get('nombre')} "
            f"${actual:.2f} → ${nuevo:.0f} · {why} · sim={r.get('precio_similares')} fah={r.get('precio_fahorro')}"
        )
    out_sql.write_text("\n".join(lines) + "\n", encoding="utf-8")

    master = SQL_DIR / "APLICAR_CATALOGO_20260904.sql"
    master.write_text(
        f"""-- FarmaCapital — lote 2026-09-04
-- Orquesta: backup + EAN + duplicados + laboratorio + PVP seguro.
-- Corre en Supabase SQL Editor. No incluye outliers ni revisar_compra.
--
-- Orden:
--  1) este archivo (PVP seguro + backup)
--  2) patch_barcodes_exactos_20260904.sql
--  3) patch_barcodes_duplicados_20260904.sql
--  4) patch_laboratorio_columna_20260904.sql
-- Opcional, a mano:
--  5) patch_precios_venta_revisar_compra_20260904.sql
-- Nunca:
--     patch_precios_venta_outliers_NO_CORRER_20260904.sql

\\echo 'Usa los 4 archivos en orden, o pega este PVP y luego los otros 3.'

-- Ver patch_precios_venta_aplicar_20260904.sql ({len(aplicar)} updates)
""",
        encoding="utf-8",
    )

    print(f"aplicar={len(aplicar)}  revisar_compra={len(revisar)}  outliers={len(outliers)}")
    print(aplicar_sql)
    print(revisar_sql)
    print(out_sql)


if __name__ == "__main__":
    main()
