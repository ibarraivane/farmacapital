#!/usr/bin/env python3
"""Exporta producto_precios_referencia_actual → CSV (solo lectura).

Requiere .env con REACT_APP_SUPABASE_URL + REACT_APP_SUPABASE_ANON_KEY.
No corre si faltan credenciales. No escribe en Supabase.

  python3 scripts/exportar_referencias_precio.py
"""
from __future__ import annotations

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
OUT = ROOT / "sql" / "historial"


def cargar_env() -> dict[str, str]:
    valores: dict[str, str] = {}
    path = ROOT / ".env"
    if path.exists():
        for linea in path.read_text(encoding="utf-8").splitlines():
            linea = linea.strip()
            if not linea or linea.startswith("#") or "=" not in linea:
                continue
            k, _, v = linea.partition("=")
            valores[k.strip()] = v.strip().strip('"').strip("'")
    valores.update({k: v for k, v in os.environ.items() if v})
    return valores


def main() -> None:
    env = cargar_env()
    url = env.get("REACT_APP_SUPABASE_URL")
    key = env.get("REACT_APP_SUPABASE_ANON_KEY")
    if not url or not key or "replace_me" in str(key):
        sys.exit(
            "Faltan REACT_APP_SUPABASE_URL / REACT_APP_SUPABASE_ANON_KEY.\n"
            "No pegues la service_role. Usa la anon key en .env local o en Secrets."
        )

    endpoint = f"{url.rstrip('/')}/rest/v1/producto_precios_referencia_actual"
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Range": "0-9999",
    }
    params = {
        "select": "producto_id,fuente,tipo,precio,fecha,origen,confianza,nombre_fuente",
        "order": "producto_id.asc,fuente.asc",
    }
    print(f"Consultando {endpoint} ...")
    resp = requests.get(endpoint, headers=headers, params=params, timeout=60)
    resp.raise_for_status()
    filas = resp.json()
    if not filas:
        sys.exit("0 filas. Revisa RLS de producto_precios_referencia_actual o la vista.")

    OUT.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d_%H%M")
    dest = OUT / f"referencias_precio_{stamp}.csv"
    cols = sorted({k for f in filas for k in f.keys()})
    with dest.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=cols)
        w.writeheader()
        w.writerows(filas)
    print(f"OK {len(filas)} refs → {dest}")


if __name__ == "__main__":
    main()
