#!/usr/bin/env python3
"""
Genera SQL para corregir códigos de barras corruptos por OCR (longitud ≠ 13 o checksum inválido).

Solo propone cambios con EAN-13 válido y sin colisión con otro SKU.

  python3 scripts/exportar_catalogo_supabase.py   # opcional, catálogo fresco
  python3 scripts/generar_patch_corregir_barcodes_ocr.py

Salida:
  sql/patch_corregir_barcodes_ocr.sql
  sql/generated/auditoria_barcodes_corregidos.md
"""

from __future__ import annotations

import csv
from itertools import combinations
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "sql" / "preview_catalogo_campos_y_precios.csv"
OUT_SQL = ROOT / "sql" / "patch_corregir_barcodes_ocr.sql"
OUT_MD = ROOT / "sql" / "generated" / "auditoria_barcodes_corregidos.md"

# Confirmados / regla fija (OCR FarmaLive)
MANUAL: dict[str, str] = {
    "750222503430721": "7502250343072",  # Vitacilina 28 — escaneo físico
    "7501354312225027": "3543122250276",  # Derman 50 g — OCR mezcló Tempra
    "7501354312250": "3543122250276",  # mismo producto tras patch OCR erróneo
    "75015015371829601": "7501537182960",  # Tribedoce 50000 Amp C/5
    "7501501537161": "7501537182960",
    "65024000740024": "650240007408",
    "6502400074024": "650240007408",
}

# No “corregir” estos: el algoritmo elige EAN-13 inválido semánticamente
SKIP_AUTO_FIX: set[str] = {
    "7501354312225027",
    "7501354312250",
    "75015015371829601",
    "7501501537161",
}

# Renombres aparte (no tocan barcode)
NAME_FIXES: list[tuple[str, str, str]] = [
    (
        "FC-60101521",
        "Vitacilina",
        "Soft Lub Pleasure 56.7 g",
    ),
]


def ean13_check(d12: str) -> int:
    total = sum(int(d) * (1 if i % 2 == 0 else 3) for i, d in enumerate(d12))
    return (10 - (total % 10)) % 10


def valid_ean13(code: str) -> bool:
    d = "".join(c for c in code if c.isdigit())
    return len(d) == 13 and int(d[12]) == ean13_check(d[:12])


def candidates_delete_to_13(d: str) -> list[str]:
    n = len(d)
    if n == 12:
        out: list[str] = []
        prefixed = "0" + d
        if valid_ean13(prefixed):
            out.append(prefixed)
        with_chk = d + str(ean13_check(d))
        if valid_ean13(with_chk):
            out.append(with_chk)
        return list(dict.fromkeys(out))
    if n == 13:
        return [d] if valid_ean13(d) else []
    if n < 12 or n > 17:
        return []
    k = n - 13
    out = []
    for idxs in combinations(range(n), k):
        cand = "".join(d[i] for i in range(n) if i not in idxs)
        if valid_ean13(cand):
            out.append(cand)
    return list(dict.fromkeys(out))


def pick_best(original: str, cands: list[str]) -> str | None:
    if not cands:
        return None
    if len(cands) == 1:
        return cands[0]

    def prefix_score(c: str) -> int:
        s = 0
        for a, b in zip(original, c):
            if a == b:
                s += 1
            else:
                break
        if c.startswith(("750", "65024", "354", "780", "366")):
            s += 1
        return s

    ranked = sorted(cands, key=prefix_score, reverse=True)
    if prefix_score(ranked[0]) > prefix_score(ranked[1]):
        return ranked[0]
    return None


def sql_quote(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def main() -> None:
    if not CATALOG.exists():
        raise SystemExit(f"No existe catálogo: {CATALOG}")

    rows = list(csv.DictReader(CATALOG.open(encoding="utf-8")))
    bc_to_sku: dict[str, str] = {}
    for r in rows:
        d = "".join(c for c in (r.get("codigo_barras") or "") if c.isdigit())
        if d:
            bc_to_sku[d] = r["sku"]

    fixes: list[tuple[str, str, str, str]] = []
    pending: list[tuple[str, str, str]] = []

    reserved = set(bc_to_sku)

    for r in rows:
        bc = (r.get("codigo_barras") or "").strip()
        if not bc:
            continue
        d = "".join(c for c in bc if c.isdigit())
        if d in SKIP_AUTO_FIX and d not in MANUAL:
            pending.append((r["sku"], d, "requiere override manual"))
            continue
        if len(d) == 13 and valid_ean13(d):
            continue

        new = MANUAL.get(d)
        if not new:
            cands = [
                c
                for c in candidates_delete_to_13(d)
                if c not in reserved or bc_to_sku.get(c) == r["sku"]
            ]
            new = pick_best(d, cands)

        if not new or new == d:
            pending.append((r["sku"], d, (r.get("nombre") or "")[:50]))
            continue
        if new in reserved and bc_to_sku.get(new) != r["sku"]:
            pending.append((r["sku"], d, f"colisión con {bc_to_sku.get(new)}"))
            continue

        fixes.append((r["sku"], d, new, (r.get("nombre") or "")[:60]))
        reserved.discard(d)
        reserved.add(new)
        bc_to_sku[new] = r["sku"]

    OUT_MD.parent.mkdir(parents=True, exist_ok=True)

    md = f"""# Auditoría — corrección barcodes OCR

Catálogo: `{CATALOG.relative_to(ROOT)}`

| Métrica | Valor |
|---------|-------|
| Correcciones SQL | **{len(fixes)}** |
| Pendientes (revisar manual) | **{len(pending)}** |

## Reglas aplicadas
- EAN-13 válido (checksum GS1)
- Sin colisión con otro producto
- Overrides manuales: Vitacilina 28 `750222503430721` → `7502250343072`
- Solo actualiza `codigo_barras` (no precio, stock, lotes)

## Correcciones

| SKU | Antes | Después | Producto |
|-----|-------|---------|----------|
"""
    for sku, old, new, name in fixes:
        md += f"| `{sku}` | `{old}` | `{new}` | {name} |\n"

    if pending:
        md += "\n## Pendientes\n\n| SKU | Barcode | Nota |\n|-----|---------|------|\n"
        for sku, old, note in pending:
            md += f"| `{sku}` | `{old}` | {note} |\n"

    md += f"\nSQL: `{OUT_SQL.relative_to(ROOT)}`\n"
    OUT_MD.write_text(md, encoding="utf-8")

    lines = [
        "-- ============================================================================",
        "-- Corregir códigos de barras corruptos por OCR",
        f"-- {len(fixes)} productos · EAN-13 válido · sin colisión",
        "-- NO modifica precio, costo, stock ni lotes",
        "-- Generado por scripts/generar_patch_corregir_barcodes_ocr.py",
        "-- ============================================================================",
        "",
        "begin;",
        "",
    ]

    for sku, old, new, name in fixes:
        lines.extend(
            [
                f"-- {sku} · {name}",
                "update public.productos p",
                f"set codigo_barras = {sql_quote(new)}",
                f"where p.sku = {sql_quote(sku)}",
                f"  and p.codigo_barras = {sql_quote(old)}",
                "  and not exists (",
                "    select 1 from public.productos o",
                f"    where o.codigo_barras = {sql_quote(new)}",
                "      and o.id <> p.id",
                "  );",
                "",
            ]
        )

    for sku, old_name, new_name in NAME_FIXES:
        lines.extend(
            [
                f"-- Renombre · {sku}",
                "update public.productos",
                f"set nombre = {sql_quote(new_name)},",
                f"    descripcion = coalesce(nullif(btrim(descripcion), ''), {sql_quote(new_name + ' — catálogo')})",
                f"where sku = {sql_quote(sku)}",
                f"  and nombre = {sql_quote(old_name)};",
                "",
            ]
        )

    lines.extend(
        [
            "commit;",
            "",
            "-- Verificación (muestra)",
            "select sku, codigo_barras, length(regexp_replace(codigo_barras, '\\\\D', '', 'g')) as digits, nombre",
            "from public.productos",
            "where sku in ('FC-03430721', 'FC-03405381', 'FC-60101521')",
            "   or codigo_barras = '7502250343072'",
            "order by sku;",
        ]
    )

    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")
    print(f"Correcciones: {len(fixes)}")
    print(f"Pendientes:   {len(pending)}")
    print(f"SQL:          {OUT_SQL}")
    print(f"Auditoría:    {OUT_MD}")


if __name__ == "__main__":
    main()
