#!/usr/bin/env python3
"""
Genera SQL idempotente para CARGAR productos faltantes del ticket.
Parte en archivos pequeños para Supabase SQL Editor.

  python3 scripts/generar_patch_cargar_faltantes.py

Salida:
  sql/patch_cargar_faltantes_0_fix_rpcs.sql  (ejecutar primero en Supabase)
  sql/patch_cargar_faltantes_1_farmalive.sql   (~143 productos barcode, ticket FL)
  sql/patch_cargar_faltantes_2_bodega_ifc.sql  (SKUs sin barcode: 440393, IFC, etc.)
  sql/patch_cantidades_tickets_completo.sql    (regenerado; ejecutar al final)
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

from auditar_cantidades_vs_pdfs import (  # noqa: E402
    SQL_GLOB,
    generate_patch_sql,
    load_carga_sql_text,
    collect_all_ticket_rows,
    build_targets,
    load_carga_sql_quantities,
    merge_targets,
    filter_sku_targets,
    is_garbage_sku_target,
)

OUT1 = ROOT / "sql" / "patch_cargar_faltantes_1_farmalive.sql"
OUT2 = ROOT / "sql" / "patch_cargar_faltantes_2_bodega_ifc.sql"
OUT_QTY = ROOT / "sql" / "patch_cantidades_tickets_completo.sql"

EJECUTAR_FL = [
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_3.sql",
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_4.sql",
]
EJECUTAR_BODEGA = [
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_1.sql",
    ROOT / "sql" / "carga_inventario_tickets_EJECUTAR_2.sql",
]


def strip_receive_else_branch(block: str) -> str:
    """Si el producto ya existe, no crear lote duplicado (cantidades van en patch 3)."""
    return re.sub(
        r"\s+else\s+perform lote_id from receive_merchandise_lote\([\s\S]*?\);\s+(?=end if;)",
        "\n  ",
        block,
    )


def patch_block_qty(block: str, qty: int) -> str:
    out = block
    out = re.sub(
        r"(from create_producto_with_lote\([\s\S]*?\)),\s*\d+,\s*('TK-)",
        rf"\1,\n      {qty},\n      \2",
        out,
        count=1,
    )
    out = re.sub(
        r"(create_producto_with_lote\([\s\S]*?\)),\s*\d+,\s*('TK-)",
        rf"\1,\n      {qty},\n      \2",
        out,
        count=1,
    )
    out = re.sub(
        r"receive_merchandise_lote\(\s*v_pid,\s*\d+,",
        f"receive_merchandise_lote(\n      v_pid, {qty},",
        out,
    )
    return out


def normalize_create_call_casts(block: str) -> str:
    """Casts explícitos en los 3 últimos args → evita error 42725."""
    if "null::text" in block:
        return block

    m = re.search(
        r"(create_producto_with_lote\([\s\S]*?\)),\s*"
        r"(\d+),\s*"
        r"('[^']*'),\s*"
        r"(NULL|'[^']+'),\s*"
        r"([\d.]+),\s*"
        r"null(\s*(\)\s*f;|\)\s*f|\)\s*;))",
        block,
        flags=re.IGNORECASE,
    )
    if not m:
        return block

    prefix, qty, lote, fecha, costo, _null, closing = m.groups()
    if fecha.strip().upper() == "NULL":
        fecha_cast = "NULL::date"
    elif fecha.endswith("::date"):
        fecha_cast = fecha
    else:
        fecha_cast = f"{fecha}::date"

    replacement = (
        f"{prefix},\n      {qty},\n      {lote},\n      {fecha_cast},\n      {costo},\n"
        f"      null::bigint,\n      null::text{closing}"
    )
    return block[: m.start()] + replacement + block[m.end() :]


def finalize_block(block: str, qty: int) -> str:
    return normalize_create_call_casts(strip_receive_else_branch(patch_block_qty(block, qty)))


def extract_do_blocks(text: str) -> list[tuple[str | None, str | None, str]]:
    blocks: list[tuple[str | None, str | None, str]] = []
    for m in re.finditer(r"do \$\$[\s\S]*?end \$\$;", text):
        block = m.group(0)
        bc_m = re.search(r"codigo_barras\s*=\s*'(\d{8,14})'", block)
        bc_m2 = re.search(r"'codigo_barras',\s*'(\d{8,14})'", block)
        sku_m = re.search(r"'sku',\s*'([^']+)'", block)
        bc = (bc_m or bc_m2).group(1) if (bc_m or bc_m2) else None
        sku = sku_m.group(1) if sku_m else None
        blocks.append((bc, sku, block))
    return blocks


def extract_plain_create_blocks(text: str) -> list[tuple[str | None, str | None, str]]:
    blocks: list[tuple[str | None, str | None, str]] = []
    for m in re.finditer(
        r"--[^\n]*\nselect producto_id, lote_id from create_producto_with_lote\([\s\S]*?\);\s*",
        text,
    ):
        block = m.group(0)
        bc_m = re.search(r"'codigo_barras',\s*(?:NULL|'(\d{8,14})')", block)
        sku_m = re.search(r"'sku',\s*'([^']+)'", block)
        bc = bc_m.group(1) if bc_m and bc_m.group(1) else None
        sku = sku_m.group(1) if sku_m else None
        blocks.append((bc, sku, block))
    return blocks


def wrap_plain_idempotent(block: str, bc: str | None, sku: str) -> str:
    inner = block.strip()
    m = re.search(r"create_producto_with_lote\(([\s\S]*)\);", inner)
    if not m:
        return inner
    args = m.group(1)
    if bc:
        return (
            f"\n-- idempotente {sku} / {bc}\n"
            "do $$\n"
            "declare v_pid bigint; v_lid bigint;\n"
            "begin\n"
            "  if exists (select 1 from public.productos where codigo_barras = "
            f"'{bc}' or sku = '{sku}') then\n"
            "    return;\n"
            "  end if;\n"
            "  select f.producto_id, f.lote_id into v_pid, v_lid\n"
            "  from create_producto_with_lote(\n"
            f"{args}\n"
            "  ) f;\n"
            "end $$;\n"
        )
    return (
        f"\n-- idempotente {sku}\n"
        "do $$\n"
        "declare v_pid bigint; v_lid bigint;\n"
        "begin\n"
        f"  if exists (select 1 from public.productos where sku = '{sku}') then\n"
        "    return;\n"
        "  end if;\n"
        "  select f.producto_id, f.lote_id into v_pid, v_lid\n"
        "  from create_producto_with_lote(\n"
        f"{args}\n"
        "  ) f;\n"
        "end $$;\n"
    )


def read_files(paths: list[Path]) -> str:
    return "\n".join(p.read_text(encoding="utf-8", errors="replace") for p in paths if p.exists())


def header_sql(title: str, detail: str, *, batch: int, total_batches: int) -> str:
    return f"""-- ============================================================================
-- {title}
-- {detail}
-- Lote {batch}/{total_batches} · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;

"""


def footer_sql(*, batch: int, total_batches: int) -> str:
    tail = f"""
commit;

select {batch} as lote_ok, {total_batches} as lotes_total;
"""
    if batch == total_batches:
        tail += """
-- Al terminar todos los lotes de este archivo:
select count(*) as productos_fc from public.productos where sku like 'FC-%';
"""
    return tail


def write_batched_sql(path: Path, title: str, detail: str, blocks: list[str], batch_size: int = 25) -> None:
    if not blocks:
        path.write_text(f"-- {title}\n-- Sin bloques.\n", encoding="utf-8")
        return
    chunks = [blocks[i : i + batch_size] for i in range(0, len(blocks), batch_size)]
    total = len(chunks)
    parts: list[str] = []
    for i, chunk in enumerate(chunks, start=1):
        parts.append(header_sql(title, detail, batch=i, total_batches=total))
        parts.append("\n".join(chunk))
        parts.append(footer_sql(batch=i, total_batches=total))
    path.write_text("\n".join(parts), encoding="utf-8")


def collect_blocks(
    text: str,
    bc_qty: dict[str, int],
    sku_qty: dict[str, int],
    sku_names: dict[str, str],
    *,
    barcodes_only: bool,
    skus_only: bool,
) -> list[str]:
    seen_bc: set[str] = set()
    seen_sku: set[str] = set()
    out: list[str] = []

    for bc, sku, block in extract_do_blocks(text) + extract_plain_create_blocks(text):
        if "do $$" in block:
            raw = block
        else:
            raw = wrap_plain_idempotent(block, bc, sku or "")

        if bc and bc in bc_qty and not skus_only:
            if bc in seen_bc:
                continue
            seen_bc.add(bc)
            out.append(finalize_block(raw, bc_qty[bc]))
        elif (not bc) and sku and sku in sku_qty and not barcodes_only:
            if is_garbage_sku_target({"nombre": sku_names.get(sku, "")}):
                continue
            if sku in seen_sku:
                continue
            seen_sku.add(sku)
            out.append(finalize_block(raw, sku_qty[sku]))

    return out


def main() -> None:
    rows = collect_all_ticket_rows()
    ocr_bc, ocr_sku = build_targets(rows)
    sql_bc, sql_sku = load_carga_sql_quantities()
    bc_targets, sku_targets = merge_targets(ocr_bc, ocr_sku, sql_bc, sql_sku)
    sku_targets = filter_sku_targets(sku_targets)

    bc_qty = {x["barcode"]: x["qty_ticket"] for x in bc_targets}
    sku_qty = {x["sku"]: x["qty_ticket"] for x in sku_targets}
    sku_names = {x["sku"]: x["nombre"] for x in sku_targets}

    text_fl = read_files(EJECUTAR_FL)
    text_bd = read_files(EJECUTAR_BODEGA)

    blocks1 = collect_blocks(text_fl, bc_qty, sku_qty, sku_names, barcodes_only=True, skus_only=False)
    blocks2 = collect_blocks(text_bd, bc_qty, sku_qty, sku_names, barcodes_only=False, skus_only=True)
    blocks2_extra = collect_blocks(text_fl, bc_qty, sku_qty, sku_names, barcodes_only=False, skus_only=True)
    # Evitar duplicados si un SKU aparece en 1 y 3
    seen2 = {re.search(r"'sku',\s*'([^']+)'", b).group(1) for b in blocks2 if re.search(r"'sku',\s*'([^']+)'", b)}
    for b in blocks2_extra:
        m = re.search(r"'sku',\s*'([^']+)'", b)
        if m and m.group(1) not in seen2:
            seen2.add(m.group(1))
            blocks2.append(b)

    write_batched_sql(
        OUT1,
        "CARGAR faltantes — FarmaLive + barcode (EJECUTAR 3 y 4)",
        f"{len(blocks1)} bloques · Aspirina, Bepanthen, Desenfriol, etc.",
        blocks1,
        batch_size=25,
    )

    write_batched_sql(
        OUT2,
        "CARGAR faltantes — Bodega 440393 + IFC + SKU sin barcode (EJECUTAR 1, 2 y SKU-only de 3)",
        f"{len(blocks2)} bloques · Mercurio, medicamentos Bodega, etc.",
        blocks2,
        batch_size=25,
    )

    OUT_QTY.write_text(
        generate_patch_sql(bc_targets, sku_targets),
        encoding="utf-8",
    )

    print(f"1_farmalive: {OUT1} ({len(blocks1)} bloques, {OUT1.stat().st_size//1024} KB)")
    print(f"2_bodega_ifc: {OUT2} ({len(blocks2)} bloques, {OUT2.stat().st_size//1024} KB)")
    print(f"cantidades: {OUT_QTY} ({OUT_QTY.stat().st_size//1024} KB)")
    print("\nEjecutar en Supabase EN ORDEN:")
    print("  0. patch_cargar_faltantes_0_fix_rpcs.sql")
    print("  1. patch_cargar_faltantes_1_farmalive.sql")
    print("  2. patch_cargar_faltantes_2_bodega_ifc.sql")
    print("  3. patch_cantidades_tickets_completo.sql")


if __name__ == "__main__":
    main()
