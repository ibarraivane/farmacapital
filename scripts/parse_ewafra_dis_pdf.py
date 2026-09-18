#!/usr/bin/env python3
"""Parsea lista DIS agosto (Ewafra / Julio César Sánchez Santos) → CSV.

El PDF pone cada campo en su propia línea: código, descripción, precio, unidad.
"""
from __future__ import annotations

import csv
import re
import sys
from pathlib import Path

import pymupdf

HEADER = re.compile(
    r"^(JULIO CESAR|Lista de precios|Desde el producto|Hasta el producto|"
    r"Producto|Descripci|U\. S\.|LISTA 6|Fecha y |Usuario Pág|ADMINISTRADOR|"
    r"-- \d+|ZC3711$)",
    re.I,
)
PRECIO = re.compile(r"^\d{1,3}(?:,\d{3})*\.\d{2,4}$")
CODIGO = re.compile(r"^[A-Z0-9][A-Z0-9.\-/]{0,18}$", re.I)
UNIDAD = re.compile(r"^(C/\d+|PZA|PZ|CAJA|LTR|LT|KG|LITRO|ml|cm)$", re.I)


def parse_pdf(path: Path) -> list[dict]:
    doc = pymupdf.open(path)
    tokens: list[str] = []
    for page in doc:
        for raw in page.get_text("text").splitlines():
            line = " ".join(raw.split()).strip()
            if not line or HEADER.search(line):
                continue
            tokens.append(line)

    rows: list[dict] = []
    seen: set[str] = set()
    i = 0
    while i < len(tokens) - 3:
        codigo, desc, precio_s, unidad = tokens[i : i + 4]
        if (
            CODIGO.match(codigo)
            and not PRECIO.match(codigo)
            and not UNIDAD.match(codigo)
            and len(desc) >= 6
            and not PRECIO.match(desc)
            and PRECIO.match(precio_s)
            and UNIDAD.match(unidad)
        ):
            key = codigo.upper()
            if key not in seen:
                seen.add(key)
                precio = float(precio_s.replace(",", ""))
                rows.append(
                    {
                        "codigo": codigo,
                        "descripcion": desc,
                        "costo_lista6": f"{precio:.4f}".rstrip("0").rstrip("."),
                        "unidad": unidad,
                    }
                )
            i += 4
            continue
        i += 1
    return rows


def main() -> int:
    src = Path(sys.argv[1] if len(sys.argv) > 1 else "")
    dest = Path(sys.argv[2] if len(sys.argv) > 2 else "docs/catalogos/ewafra_dis_agosto_2026.csv")
    if not src.is_file():
        print(f"No existe PDF: {src}", file=sys.stderr)
        return 2
    dest.parent.mkdir(parents=True, exist_ok=True)
    rows = parse_pdf(src)
    with dest.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["codigo", "descripcion", "costo_lista6", "unidad"])
        w.writeheader()
        w.writerows(rows)
    print(f"{len(rows)} filas → {dest}")
    return 0 if rows else 1


if __name__ == "__main__":
    raise SystemExit(main())
