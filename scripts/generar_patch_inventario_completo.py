#!/usr/bin/env python3
"""
Genera UN solo SQL con todo lo pendiente del inventario:
  - Corrección barcodes mal aplicados (p. ej. Derman)
  - Metadata corregida (PA, presentación, etc.)
  - Renombres legibles (delta vs catálogo live)
  - Campos vacíos restantes
  - INSERT ONLY de productos faltantes en tickets

  python3 scripts/exportar_catalogo_supabase.py   # recomendado primero
  python3 scripts/generar_patch_inventario_completo.py

Salida:
  sql/patch_inventario_completo.sql
  sql/generated/auditoria_inventario_completo.md
"""

from __future__ import annotations

import csv
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

CATALOG_CSV = ROOT / "sql/preview_catalogo_campos_y_precios.csv"
OUT_SQL = ROOT / "sql/patch_inventario_completo.sql"
OUT_MD = ROOT / "sql/generated/auditoria_inventario_completo.md"

# Barcode correcto confirmado (SKU comercial 354312225027 → EAN-13)
DERMAN_BC = "3543122250276"

# sku → barcode nuevo (corrige errores del patch OCR anterior)
BARCODE_FIXES: dict[str, dict] = {
    "FC-12225027": {
        "barcode": DERMAN_BC,
        "nota": "OCR mezcló Tempra+Derman (7501354312225027). Código real Derman 50 g: 3543122250276",
    },
    "FC-71829601": {
        "barcode": "7501537182960",
        "nota": "Tribedoce 50000 Amp C/5 — OCR 75015015371829601; patch anterior dejó 7501501537161 (incorrecto)",
    },
}

# sku → campos a fijar (incluye correcciones de datos erróneos, no solo vacíos)
PRODUCT_FIXES: dict[str, dict] = {
    "FC-12225027": {
        "nombre": "Derman Crema 50 g",
        "marca": "Derman",
        "presentacion": "50 G",
        "principio_activo": "Ácido undecilénico + Undecilenato de zinc",
        "concentracion": "18/5 G/100G",
        "forma_farmaceutica": "CREMA",
        "categoria": "Medicamentos",
        "tipo": "MEDICAMENTO",
    },
    "FC-71829601": {
        "nombre": "Tribedoce 50000 UI Amp C/5",
        "marca": "Bruluart",
        "presentacion": "Amp C/5",
        "principio_activo": "Hidroxocobalamina + Tiamina + Piridoxina",
        "concentracion": "50000 UI / 100 mg / 50 mg",
        "forma_farmaceutica": "AMPOLLETA",
        "categoria": "Medicamentos",
        "tipo": "MEDICAMENTO",
    },
}
MANUAL_INSERTS: list[dict] = [
    {
        "sku": "FC-37164713",
        "barcode": "7501537164713",
        "nombre": "Tribedoce Compuesto grageas C/30",
        "marca": "Bruluart",
        "presentacion": "C/30 grageas",
        "principio_activo": "Diclofenaco + Complejo B (Tiamina, Piridoxina, Cianocobalamina)",
        "concentracion": "50/50/1/50 mg",
        "forma_farmaceutica": "GRAGEAS",
        "categoria": "Medicamentos",
        "tipo": "MEDICAMENTO",
        "requiere_receta": True,
        "costo": 0,
        "precio": 0,
        "qty": 0,
        "ticket": "manual",
        "nota": "Alta manual — EAN 7501537164713 (grageas oral). Ajustar costo/precio/stock en inventario.",
    },
    {
        "sku": "FC-37163266",
        "barcode": "7501537163266",
        "nombre": "Tribedoce Compuesto Amp C/3",
        "marca": "Bruluart",
        "presentacion": "Amp C/3",
        "principio_activo": "Diclofenaco + Complejo B (Tiamina, Piridoxina, Cianocobalamina)",
        "concentracion": "75/5/100 mg",
        "forma_farmaceutica": "SOLUCION INYECTABLE",
        "categoria": "Medicamentos",
        "tipo": "MEDICAMENTO",
        "requiere_receta": True,
        "costo": 54.10,
        "precio": 73.04,
        "qty": 2,
        "ticket": "FL-080826",
        "nota": "Ticket FarmaLive COMPUESTO 4266C/3 — IV TRIBEDOCE AMP ×2 cajas, costo unit s/IVA $54.10",
    },
]


def sql_quote(s: str) -> str:
    return "'" + str(s).replace("'", "''") + "'"


def sql_assign(field: str, val: str | None, force: bool = False) -> str:
    v = (val or "").strip()
    if not v:
        return ""
    if force:
        return f"{field} = {sql_quote(v)}"
    return (
        f"{field} = CASE WHEN {field} IS NULL OR btrim({field}) = '' "
        f"THEN {sql_quote(v)} ELSE {field} END"
    )


def load_active_catalog() -> list[dict]:
    rows = []
    with CATALOG_CSV.open(encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if (row.get("activo") or "").lower() not in ("true", "1", "t"):
                continue
            rows.append(row)
    return rows


def run_generators() -> None:
    subprocess.run([sys.executable, str(ROOT / "scripts/generar_patch_nombres_legibles.py")], check=True)
    subprocess.run([sys.executable, str(ROOT / "scripts/generar_patch_completar_campos.py")], check=True)
    subprocess.run([sys.executable, str(ROOT / "scripts/generar_sql_solo_faltantes.py")], check=True)


def parse_update_lines(sql_path: Path, field: str = "nombre") -> list[tuple[str, str]]:
    if not sql_path.exists():
        return []
    out: list[tuple[str, str]] = []
    for line in sql_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line.upper().startswith("UPDATE PUBLIC.PRODUCTOS SET"):
            continue
        if f" {field} = " not in line and f" {field}=" not in line:
            continue
        if " WHERE sku = " not in line:
            continue
        try:
            left, right = line.split(" WHERE sku = ", 1)
            sku = right.split(" AND ", 1)[0].strip().strip("'")
            val_part = left.split(f" {field} = ", 1)[1]
            val = val_part.strip().strip("'")
            out.append((sku, val))
        except (IndexError, ValueError):
            continue
    return out


def read_campos_updates(sql_path: Path) -> list[str]:
    if not sql_path.exists():
        return []
    text = sql_path.read_text(encoding="utf-8")
    blocks = re.findall(
        r"update public\.productos set.*?where sku = '[^']+'.*?\);",
        text,
        flags=re.IGNORECASE | re.DOTALL,
    )
    return [b.strip() for b in blocks if b.strip()]


def read_insert_blocks(sql_path: Path) -> list[str]:
    if not sql_path.exists():
        return []
    text = sql_path.read_text(encoding="utf-8")
    parts = re.findall(r"do \$\$.*?end \$\$;", text, flags=re.IGNORECASE | re.DOTALL)
    return [p.strip() for p in parts if "create_producto_with_lote" in p]


def sql_manual_insert(p: dict, n: int) -> str:
    receta = "true" if p.get("requiere_receta") else "false"
    desc = f"{p['nombre']} — {p.get('nota', p.get('ticket', 'manual'))}"
    return f"""
-- [M{n}] {p['sku']} · {p['barcode']} · {p['nombre'][:50]}
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (
    select 1 from public.productos
    where codigo_barras = {sql_quote(p['barcode'])} or sku = {sql_quote(p['sku'])}
  ) then
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(
    jsonb_build_object(
      'nombre', {sql_quote(p['nombre'])},
      'sku', {sql_quote(p['sku'])},
      'codigo_barras', {sql_quote(p['barcode'])},
      'categoria', {sql_quote(p.get('categoria') or 'GENERAL')},
      'tipo', {sql_quote(p.get('tipo') or 'GENERICO')},
      'descripcion', {sql_quote(desc[:200])},
      'costo', {float(p.get('costo') or 0):.2f},
      'precio', {float(p.get('precio') or 0):.2f},
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', {receta}
    ),
    {max(0, int(p.get('qty') or 0))},
    {sql_quote(f"MAN-{p['sku']}")},
    NULL::date,
    {float(p.get('costo') or 0):.2f},
    null::bigint,
    null::text
  ) f;

  update public.productos set
    marca = {sql_quote(p.get('marca') or '')},
    presentacion = {sql_quote(p.get('presentacion') or '')},
    principio_activo = {sql_quote(p.get('principio_activo') or '')},
    concentracion = {sql_quote(p.get('concentracion') or '')},
    forma_farmaceutica = {sql_quote(p.get('forma_farmaceutica') or '')}
  where id = v_pid;
end $$;"""


def main() -> int:
    if not CATALOG_CSV.exists():
        print("Falta catálogo. Ejecuta: python3 scripts/exportar_catalogo_supabase.py")
        return 1

    run_generators()

    catalog = load_active_catalog()
    sku_to_row = {r["sku"]: r for r in catalog}

    renames_path = ROOT / "sql/patch_nombres_legibles_v2.sql"
    campos_path = ROOT / "sql/patch_completar_campos_vacios.sql"
    insert_path = ROOT / "sql/patch_solo_insertar_faltantes.sql"

    renames = parse_update_lines(renames_path, "nombre")
    rename_by_sku = dict(renames)

    # Derman: nombre autoritativo en PRODUCT_FIXES pisa el rename genérico
    if "FC-12225027" in PRODUCT_FIXES:
        rename_by_sku["FC-12225027"] = PRODUCT_FIXES["FC-12225027"]["nombre"]

    lines: list[str] = [
        "-- ============================================================================",
        "-- PATCH INVENTARIO COMPLETO — ejecutar una sola vez en Supabase SQL Editor",
        f"-- Generado: {datetime.now():%Y-%m-%d %H:%M}",
        "-- Incluye: barcodes, metadata, renombres, campos vacíos, inserts faltantes",
        "-- NO toca precio, costo ni stock salvo productos NUEVOS (insert-only)",
        "-- ============================================================================",
        "",
        "begin;",
        "",
        "-- ── 1. Barcodes corregidos (errores patch OCR anterior) ──",
        "",
    ]

    barcode_count = 0
    for sku, fix in BARCODE_FIXES.items():
        bc = fix["barcode"]
        lines.append(f"-- {sku}: {fix['nota']}")
        lines.append(
            f"update public.productos p set codigo_barras = {sql_quote(bc)} "
            f"where p.sku = {sql_quote(sku)} and p.activo = true "
            f"and coalesce(p.codigo_barras, '') <> {sql_quote(bc)} "
            f"and not exists (select 1 from public.productos o "
            f"where o.codigo_barras = {sql_quote(bc)} and o.id <> p.id);"
        )
        lines.append("")
        barcode_count += 1

    lines += ["-- ── 2. Metadata corregida (PA, presentación, etc.) ──", ""]
    meta_count = 0
    for sku, fields in PRODUCT_FIXES.items():
        assigns = []
        for k, v in fields.items():
            assigns.append(sql_assign(k, v, force=True))
        assigns = [a for a in assigns if a]
        if not assigns:
            continue
        nombre = fields.get("nombre") or sku_to_row.get(sku, {}).get("nombre", sku)
        lines.append(f"-- {sku} · {nombre[:60]}")
        lines.append(
            f"update public.productos set {', '.join(assigns)} "
            f"where sku = {sql_quote(sku)} and activo = true;"
        )
        lines.append("")
        meta_count += 1

    lines += ["-- ── 3. Renombres legibles (delta) ──", ""]
    rename_count = 0
    for sku, new_name in sorted(rename_by_sku.items()):
        old = (sku_to_row.get(sku, {}).get("nombre") or "").strip()
        if old == new_name.strip():
            continue
        lines.append(
            f"update public.productos set nombre = {sql_quote(new_name)} "
            f"where sku = {sql_quote(sku)} and activo = true;"
        )
        rename_count += 1
    lines.append("")

    lines += ["-- ── 4. Campos vacíos (solo rellena NULL/vacío) ──", ""]
    campos_updates = read_campos_updates(campos_path)
    lines.extend(campos_updates)
    lines.append("")

    lines += ["-- ── 5. Productos faltantes (INSERT ONLY) ──", ""]
    insert_blocks = read_insert_blocks(insert_path)
    # No insertar Derman si ya existe FC-12225027 (solo corregimos barcode arriba)
    skip_insert_bc = {DERMAN_BC}
    insert_count = 0
    for block in insert_blocks:
        if any(f"'{bc}'" in block for bc in skip_insert_bc):
            lines.append(f"-- omitido insert duplicado barcode {DERMAN_BC} (ya existe FC-12225027)")
            lines.append("")
            continue
        lines.append(block)
        lines.append("")
        insert_count += 1

    manual_count = 0
    existing_skus = set(sku_to_row)
    existing_bcs = {(r.get("codigo_barras") or "").strip() for r in catalog}
    for i, p in enumerate(MANUAL_INSERTS, 1):
        if p["sku"] in existing_skus or p["barcode"] in existing_bcs:
            lines.append(
                f"-- omitido manual {p['sku']} (ya existe en catálogo exportado)"
            )
            lines.append("")
            continue
        lines.append(sql_manual_insert(p, i).strip())
        lines.append("")
        manual_count += 1

    lines += [
        "commit;",
        "",
        "-- Verificación rápida",
        "select sku, nombre, codigo_barras, principio_activo, presentacion",
        "from public.productos where sku in ('FC-12225027', 'FC-37164713', 'FC-37163266', 'FC-71829601') and activo = true;",
        "",
        "select count(*) filter (where presentacion is null or btrim(presentacion) = '') as sin_pres,",
        "       count(*) filter (where principio_activo is null or btrim(principio_activo) = '') as sin_pa",
        "from public.productos where activo = true;",
        "",
    ]

    OUT_SQL.parent.mkdir(parents=True, exist_ok=True)
    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")

    md = [
        "# Patch inventario completo",
        "",
        f"Archivo: `{OUT_SQL.name}`",
        "",
        "| Sección | Acciones |",
        "|---------|----------|",
        f"| Barcodes corregidos | {barcode_count} |",
        f"| Metadata forzada | {meta_count} |",
        f"| Renombres | {rename_count} |",
        f"| Updates campos vacíos | {len(campos_updates)} |",
        f"| Inserts tickets | {insert_count} |",
        f"| Altas manuales | {manual_count} |",
        "",
        "## Tribedoce Compuesto grageas",
        "",
        "- EAN escaneado: `7501537164713` (C/30 grageas oral — **no estaba en inventario**)",
        "- Distinto de `FC-71829601` (Tribedoce 50000 Amp C/5) y `FC-88947797` (Tribedoce tabletas)",
        "- Alta manual `FC-37164713` — ajustar costo/precio/stock después",
        "",
        "## Tribedoce Compuesto Amp C/3",
        "",
        "- EAN: `7501537163266` — ticket FL-080826, qty 2, costo $54.10 c/u",
        "- Alta `FC-37163266` (inyectable Complejo B + diclofenaco)",
        "",
        "## Derman Crema",
        "",
        f"- Barcode correcto: `{DERMAN_BC}` (SKU comercial 354312225027)",
        "- El OCR del ticket mezcló la línea de Tempra: `1354312225027] DERMAN CREMA 50`",
        "- El patch anterior de barcodes lo dejó en `7501354312250` (incorrecto)",
        "- Buscar por `354312225027`, `543122250227` o nombre **Derman** tras ejecutar",
        "",
        "## Ejecutar",
        "",
        "1. Supabase → SQL Editor",
        f"2. Pegar y ejecutar `{OUT_SQL}`",
        "3. Recargar pestaña Inventario",
        "",
    ]
    OUT_MD.parent.mkdir(parents=True, exist_ok=True)
    OUT_MD.write_text("\n".join(md), encoding="utf-8")

    print(f"SQL completo → {OUT_SQL}")
    print(f"Auditoría   → {OUT_MD}")
    print(f"  barcodes: {barcode_count} | metadata: {meta_count} | renombres: {rename_count}")
    print(f"  campos: {len(campos_updates)} | inserts: {insert_count} | manual: {manual_count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
