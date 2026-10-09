#!/usr/bin/env python3
"""Lee «ME Piel Lista de precios 2026» y escribe JSON de renglones crudos.

No asigna marca ni precio de venta: eso vive en src/lib/catalogoBajoPedido.js.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import openpyxl


def ean_de(valor) -> str:
    if isinstance(valor, bool) or valor is None:
        return ""
    if isinstance(valor, (int, float)):
        return str(int(valor))
    texto = str(valor).strip()
    digitos = "".join(ch for ch in texto if ch.isdigit())
    if len(digitos) >= 8 and digitos == texto.replace(".0", ""):
        return digitos
    return ""


def num(valor):
    if valor is None or valor == "":
        return None
    try:
        return float(valor)
    except (TypeError, ValueError):
        return None


def parsear(path: Path) -> dict:
    wb = openpyxl.load_workbook(path, data_only=True, read_only=True)
    ws = wb["LISTADO"]
    productos = []
    sin_codigo = []
    linea = ""
    for i, row in enumerate(ws.iter_rows(min_row=1, max_col=8, values_only=True), 1):
        codigo = row[1] if len(row) > 1 else None
        desc = row[2] if len(row) > 2 else None
        uni = row[3] if len(row) > 3 else None
        cliente_sin = row[4] if len(row) > 4 else None
        cliente_con = row[5] if len(row) > 5 else None
        publico_sin = row[6] if len(row) > 6 else None
        publico_con = row[7] if len(row) > 7 else None
        if codigo is None and desc is None:
            continue
        ean = ean_de(codigo)
        if ean:
            productos.append({
                "fila": i,
                "ean": ean,
                "descripcion": str(desc or "").strip(),
                "uni": str(uni or "").strip(),
                "cliente_sin": num(cliente_sin),
                "cliente_con": num(cliente_con),
                "publico_sin": num(publico_sin),
                "publico_con": num(publico_con),
                "linea": linea,
            })
            continue
        texto = str(codigo).strip() if codigo is not None else ""
        if texto in {"", "Código"} or texto.startswith("LISTA DE PRECIOS"):
            continue
        if desc is None:
            linea = texto.strip()
            continue
        sin_codigo.append({
            "fila": i,
            "codigo": texto,
            "descripcion": str(desc or "").strip(),
            "cliente_con": num(cliente_con),
            "linea": linea,
        })
    return {"productos": productos, "sin_codigo": sin_codigo}


def main() -> None:
    if len(sys.argv) < 3:
        print("uso: parse_mepiel_xlsx.py LISTA.xlsx salida.json", file=sys.stderr)
        sys.exit(2)
    data = parsear(Path(sys.argv[1]))
    Path(sys.argv[2]).write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    print(json.dumps({
        "filas": len(data["productos"]),
        "sin_codigo": len(data["sin_codigo"]),
    }))


if __name__ == "__main__":
    main()
