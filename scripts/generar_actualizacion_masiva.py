#!/usr/bin/env python3
"""Genera SQL de actualización masiva del inventario (todo en 2 archivos)."""

from __future__ import annotations

import subprocess
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SQL = ROOT / "sql"

PARTS = [
    (
        "ACTUALIZACION_MASIVA_1_preparacion_catalogo.sql",
        [
            "patch_productos_campos_catalogo.sql",
            "patch_proveedor_tienda_en_lotes.sql",
            "actualizar_catalogo_campos_y_precios.sql",
        ],
    ),
    (
        "ACTUALIZACION_MASIVA_2_barcodes_proveedores.sql",
        [
            "actualizar_codigos_barras_tickets.sql",
            "actualizar_proveedor_lotes_tickets.sql",
        ],
    ),
]

VERIFY = """-- ═══════════════════════════════════════════════════════════
-- VERIFICACIÓN FINAL
-- ═══════════════════════════════════════════════════════════

select count(*) as productos_fc
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';

select sum(cantidad_actual) as piezas_en_lotes from public.lotes where coalesce(activo, true);

select
  count(*) filter (where codigo_barras is not null and btrim(codigo_barras) <> '') as con_barcode,
  count(*) filter (where marca is not null and btrim(marca) <> '') as con_marca,
  count(*) filter (where presentacion is not null and btrim(presentacion) <> '') as con_presentacion
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';

select
  count(*) as lotes_activos,
  count(*) filter (where proveedor_id is not null) as lotes_con_tienda
from public.lotes
where coalesce(activo, true);
"""


def run_generators() -> None:
    scripts = [
        "actualizar_inventario_catalogo.py",
        "generar_barcodes_desde_excel.py",
        "actualizar_proveedor_lotes_tickets.py",
    ]
    for name in scripts:
        path = ROOT / "scripts" / name
        print(f"→ {name}")
        subprocess.run([sys.executable, str(path)], check=True)


def strip_outer_transaction(content: str) -> str:
    lines = content.splitlines()
    out: list[str] = []
    for line in lines:
        low = line.strip().lower()
        if low in {"begin;", "commit;"}:
            continue
        out.append(line)
    return "\n".join(out).strip()


def merge_files(sources: list[str], header: str) -> str:
    chunks = [header, "", "begin;", ""]
    for src in sources:
        path = SQL / src
        if not path.exists():
            raise SystemExit(f"Falta: {path}")
        chunks.append(f"-- ── {src} ──")
        chunks.append(strip_outer_transaction(path.read_text(encoding="utf-8")))
        chunks.append("")
    chunks.extend(["commit;", "", VERIFY])
    return "\n".join(chunks) + "\n"


def main() -> None:
    run_generators()

    stamp = date.today().isoformat()
    header = f"""-- FarmaCapital — ACTUALIZACIÓN MASIVA INVENTARIO
-- Generado: {stamp}
-- Fuente: Excel homologado de tickets (627 líneas)
--
-- ORDEN EN SUPABASE SQL EDITOR:
--   1) ACTUALIZACION_MASIVA_1_preparacion_catalogo.sql  ← columnas + funciones + catálogo
--   2) ACTUALIZACION_MASIVA_2_barcodes_proveedores.sql
--
-- Si falló antes: ejecuta primero sql/patch_productos_campos_catalogo.sql
-- y sql/patch_proveedor_tienda_en_lotes.sql por separado.
--
-- Incluye:
--   • Parche RPCs (proveedor tienda en lotes)
--   • Catálogo: nombre, marca, presentación, PA, precios 60%/30%
--   • Códigos de barras del ticket (349 con EAN)
--   • Proveedor del lote = tienda de compra (627 mapeos)
"""

    for out_name, sources in PARTS:
        out_path = SQL / out_name
        out_path.write_text(merge_files(sources, header), encoding="utf-8")
        kb = out_path.stat().st_size / 1024
        print(f"✓ {out_path.name} ({kb:.0f} KB)")

    print("\nEjecuta en Supabase en este orden:")
    for out_name, _ in PARTS:
        print(f"  sql/{out_name}")


if __name__ == "__main__":
    main()
