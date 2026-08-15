#!/usr/bin/env python3
"""
Genera UN solo SQL idempotente: corrige barcodes + altas faltantes verificadas.

  python3 scripts/generar_patch_catalogo_canonico.py

Salida: sql/patch_catalogo_canonico_una_vez.sql
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

from datos_barcodes_canonicos import CORRECCIONES, ALTAS_MANUALES, ProductoCanonico, sku_from_bc  # noqa: E402

OUT = ROOT / "sql" / "patch_catalogo_canonico_una_vez.sql"
MARGEN = 0.35


def q(s: str) -> str:
    return "'" + (s or "").replace("'", "''") + "'"


def precio(costo: float, override: float) -> float:
    if override > 0:
        return override
    if costo <= 0:
        return 0.0
    return math.ceil(costo * (1 + MARGEN) * 100) / 100


def sql_fix(p: ProductoCanonico) -> list[str]:
    sku = p.fix_sku or p.sku
    lines = [
        f"-- FIX {sku} → {p.barcode} · {p.nombre}",
        "UPDATE public.productos SET",
        f"  codigo_barras = {q(p.barcode)},",
        f"  nombre = {q(p.nombre)},",
    ]
    if p.marca:
        lines.append(f"  marca = {q(p.marca)},")
    if p.presentacion:
        lines.append(f"  presentacion = {q(p.presentacion)},")
    if p.principio_activo:
        lines.append(f"  principio_activo = {q(p.principio_activo)},")
    if p.forma_farmaceutica:
        lines.append(f"  forma_farmaceutica = {q(p.forma_farmaceutica)},")
    if p.action == "fix_and_stock" and p.stock >= 0:
        lines.append(f"  stock = {p.stock},")
        lines.append(f"  stock_unidades = {p.stock},")
    lines.append(f"  descripcion = coalesce(nullif(btrim(descripcion), ''), {q(p.notas or p.nombre)})")
    lines.append(f"WHERE sku = {q(sku)}")
    lines.append(f"  AND NOT EXISTS (")
    lines.append(f"    SELECT 1 FROM public.productos o")
    lines.append(f"    WHERE o.codigo_barras = {q(p.barcode)} AND o.id <> public.productos.id")
    lines.append("  );")
    lines.append("")
    return lines


def sql_insert(p: ProductoCanonico) -> list[str]:
    sku = p.sku or sku_from_bc(p.barcode)
    costo = p.costo
    prec = precio(costo, p.precio)
    qty = max(0, int(p.stock))
    desc = p.descripcion or f"{p.nombre} — alta canonica EAN {p.barcode}"
    lines = [
        f"-- INSERT {sku} · {p.barcode} · {p.nombre}",
        "DO $$",
        "DECLARE v_pid bigint; v_lid bigint;",
        "BEGIN",
        "  SELECT id INTO v_pid FROM public.productos",
        f"  WHERE sku = {q(sku)} OR codigo_barras = {q(p.barcode)} LIMIT 1;",
        "  IF v_pid IS NULL THEN",
        "    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid",
        "    FROM public.create_producto_with_lote(",
        "      jsonb_build_object(",
        f"        'nombre', {q(p.nombre)},",
        f"        'sku', {q(sku)},",
        f"        'codigo_barras', {q(p.barcode)},",
        f"        'categoria', {q(p.categoria)},",
        f"        'tipo', {q(p.tipo)},",
        f"        'descripcion', {q(desc)},",
        f"        'costo', {costo:.2f},",
        f"        'precio', {prec:.2f},",
        f"        'stock_minimo', {p.stock_minimo},",
        "        'activo', true,",
        f"        'requiere_receta', {'true' if p.requiere_receta else 'false'}",
        "      ),",
        f"      {qty}, NULL, NULL, {costo:.2f}, NULL",
        "    ) f;",
        "    UPDATE public.productos SET",
    ]
    extras = []
    if p.marca:
        extras.append(f"marca = {q(p.marca)}")
    if p.presentacion:
        extras.append(f"presentacion = {q(p.presentacion)}")
    if p.principio_activo:
        extras.append(f"principio_activo = {q(p.principio_activo)}")
    if p.forma_farmaceutica:
        extras.append(f"forma_farmaceutica = {q(p.forma_farmaceutica)}")
    if p.subcategoria:
        extras.append(f"subcategoria = {q(p.subcategoria)}")
    if qty > 0:
        extras.append(f"stock = {qty}")
        extras.append(f"stock_unidades = {qty}")
    if extras:
        lines.append("      " + ",\n      ".join(extras))
    lines.append("    WHERE id = v_pid;")
    lines.extend([
        "  ELSE",
        "    UPDATE public.productos SET",
        f"      codigo_barras = {q(p.barcode)},",
        f"      nombre = {q(p.nombre)},",
        "      activo = true",
        "    WHERE id = v_pid;",
        "  END IF;",
        "END $$;",
        "",
    ])
    return lines


def main() -> None:
    parts = [
        "-- Catálogo canónico: barcodes verificados + altas Farmalive",
        "-- Ejecutar UNA vez en Supabase SQL Editor (copiar archivo completo, Cmd+A)",
        "-- Fuente: scripts/datos_barcodes_canonicos.py",
        "",
        "-- ═══ 1. Corregir barcodes / stock en productos existentes ═══",
        "",
    ]
    for p in CORRECCIONES:
        parts.extend(sql_fix(p))
    parts.append("-- ═══ 2. Altas que nunca entraron por OCR ═══")
    parts.append("")
    for p in ALTAS_MANUALES:
        parts.extend(sql_insert(p))
    parts.extend([
        "-- Verificación",
        "SELECT sku, nombre, codigo_barras, stock, precio",
        "FROM public.productos",
        "WHERE sku IN (",
        "  'FC-00740024','FC-58715517','FC-69200016','FC-8062229','FC-9525015',",
        "  'FC-5112881','FC-8421321','FC-8497593'",
        ") OR codigo_barras IN (",
        "  '650240007408','7501095409004','7501369200016','3664798062229',",
        "  '7501159525015','7501125112881','7501008421321','7501008497593'",
        ")",
        "ORDER BY sku;",
    ])
    OUT.write_text("\n".join(parts) + "\n", encoding="utf-8")
    print(f"Generado: {OUT}")
    print(f"  correcciones: {len(CORRECCIONES)}")
    print(f"  altas: {len(ALTAS_MANUALES)}")


if __name__ == "__main__":
    main()
