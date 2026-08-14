#!/usr/bin/env python3
"""
Exporta el catálogo actual de Supabase (tabla `productos`) a CSV.

Requiere que el archivo .env del proyecto tenga:
  REACT_APP_SUPABASE_URL=...
  REACT_APP_SUPABASE_ANON_KEY=...

Uso:
  python3 scripts/exportar_catalogo_supabase.py

Este script SOLO puede correr en una máquina con salida a internet hacia
Supabase (tu computadora / Cursor). No corre dentro de Cowork porque ese
entorno tiene la red bloqueada hacia dominios externos por seguridad.

Salida:
  sql/preview_catalogo_campos_y_precios.csv   (se sobreescribe, es el que usa
                                                pricing_pipeline.py)
  sql/historial/catalogo_YYYYMMDD_HHMM.csv    (copia con fecha, para historial)
"""
import csv
import os
import sys
from datetime import datetime
from pathlib import Path

try:
    import requests
except ImportError:
    sys.exit("Falta 'requests'. Instala con: pip install requests")

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / ".env"
OUT_CURRENT = ROOT / "sql" / "preview_catalogo_campos_y_precios.csv"
OUT_HISTORY_DIR = ROOT / "sql" / "historial"


def cargar_env(path):
    valores = {}
    if not path.exists():
        sys.exit(f"No encontré {path}")
    for linea in path.read_text(encoding="utf-8").splitlines():
        linea = linea.strip()
        if not linea or linea.startswith("#") or "=" not in linea:
            continue
        clave, _, valor = linea.partition("=")
        valores[clave.strip()] = valor.strip()
    return valores


def main():
    env = cargar_env(ENV_PATH)
    url = env.get("REACT_APP_SUPABASE_URL")
    key = env.get("REACT_APP_SUPABASE_ANON_KEY")
    if not url or not key:
        sys.exit("Faltan REACT_APP_SUPABASE_URL / REACT_APP_SUPABASE_ANON_KEY en .env")

    endpoint = f"{url}/rest/v1/productos"
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Range": "0-4999",  # cubre hasta 5000 filas; el catálogo hoy es ~560-700
    }
    print(f"Consultando {endpoint} ...")
    resp = requests.get(endpoint, headers=headers, params={"select": "*"}, timeout=30)
    resp.raise_for_status()
    filas = resp.json()
    if not filas:
        sys.exit("La consulta regresó 0 filas -- revisa las políticas RLS de la tabla productos o la anon key.")

    columnas = sorted({k for fila in filas for k in fila.keys()})
    # updated_at primero si existe, para que sea fácil ver la frescura del dato
    if "updated_at" in columnas:
        columnas.remove("updated_at")
        columnas.insert(0, "updated_at")

    OUT_CURRENT.parent.mkdir(parents=True, exist_ok=True)
    with OUT_CURRENT.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=columnas)
        writer.writeheader()
        for fila in filas:
            writer.writerow(fila)
    print(f"Guardado: {OUT_CURRENT} ({len(filas)} productos)")

    OUT_HISTORY_DIR.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M")
    copia = OUT_HISTORY_DIR / f"catalogo_{ts}.csv"
    copia.write_text(OUT_CURRENT.read_text(encoding="utf-8"), encoding="utf-8")
    print(f"Copia de historial: {copia}")
    print(f"Exportado el: {datetime.now().isoformat(timespec='seconds')}")


if __name__ == "__main__":
    main()
