#!/usr/bin/env python3
"""Cruza CSVs normalizados → producto_precios_referencia (solo matches A/B)."""

from __future__ import annotations

import os
import sys
import time
from datetime import date
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from lib.pricing.io_csv import leer_csv  # noqa: E402
from lib.pricing.match import (  # noqa: E402
    ProductoCatalogo,
    ProductoProveedor,
    enriquecer_catalogo,
    enriquecer_proveedor,
    matchear_fuente,
)
from lib.pricing.registro import todos_adapters  # noqa: E402

FUENTE_ID = {
    "Scorpion": "scorpion",
    "Abarrotero": "abarrotero",
    "MayoreoTotal": "mayoreototal",
    "Exprezo": "exprezo",
}


def cargar_env() -> dict:
    env = {}
    p = ROOT / ".env"
    if p.exists():
        for line in p.read_text(encoding="utf-8").splitlines():
            if "=" in line and not line.strip().startswith("#"):
                k, v = line.split("=", 1)
                env[k.strip()] = v.strip().strip('"').strip("'")
    env.update(os.environ)
    return env


def fetch_productos(url: str, key: str) -> list[dict]:
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    out, start = [], 0
    while True:
        r = requests.get(
            f"{url}/rest/v1/productos",
            headers=headers,
            params={
                "select": "id,sku,nombre,marca,presentacion,costo,tipo,categoria,activo",
                "activo": "eq.true",
                "order": "id.asc",
                "limit": 1000,
                "offset": start,
            },
            timeout=60,
        )
        r.raise_for_status()
        chunk = r.json()
        out.extend(chunk)
        if len(chunk) < 1000:
            break
        start += 1000
    return out


def upsert_fuentes(url: str, key: str) -> None:
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates",
    }
    payload = [
        {"id": "scorpion", "nombre": "Scorpion", "tipo": "compra", "metodo": "job_api"},
        {"id": "abarrotero", "nombre": "Abarrotero", "tipo": "compra", "metodo": "job_api"},
        {"id": "mayoreototal", "nombre": "MayoreoTotal", "tipo": "compra", "metodo": "job_api"},
    ]
    r = requests.post(f"{url}/rest/v1/fuentes_precio", headers=headers, json=payload, timeout=30)
    if not r.ok:
        print(f"  (fuentes_precio: {r.status_code} — ejecuta sql/patch_fuentes_scorpion_abarrotero.sql)")


def insertar(url: str, key: str, fuente: str, matched: list[dict], fecha: str) -> int:
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    }
    n = 0
    for i in range(0, len(matched), 80):
        chunk = matched[i : i + 80]
        payload = [
            {
                "producto_id": m["producto_id"],
                "fuente": fuente,
                "tipo": "compra",
                "precio": m["precio"],
                "fecha": fecha,
                "nombre_fuente": m["nombre_fuente"],
                "confianza": m["confianza"],
                "origen": "import_csv",
                "notas": m.get("notas") or f"match {m['nivel']}",
            }
            for m in chunk
        ]
        r = requests.post(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=headers,
            json=payload,
            timeout=120,
        )
        if not r.ok:
            print(f"  error insert {fuente}: {r.status_code} {r.text[:240]}")
            break
        n += len(chunk)
        time.sleep(0.15)
    return n


def main() -> int:
    env = cargar_env()
    url = env.get("REACT_APP_SUPABASE_URL") or env.get("SUPABASE_URL") or ""
    key = (
        env.get("SUPABASE_SERVICE_ROLE_KEY")
        or env.get("REACT_APP_SUPABASE_ANON_KEY")
        or ""
    )
    if not url or not key:
        sys.exit("Falta URL/key de Supabase en .env")

    print("Catálogo Supabase…")
    raw = fetch_productos(url, key)
    print(f"  {len(raw)} productos")
    catalogo = enriquecer_catalogo([
        ProductoCatalogo(
            sku=str(r.get("sku") or ""),
            nombre=r.get("nombre") or "",
            marca=r.get("marca") or "",
            presentacion=r.get("presentacion") or "",
            costo=float(r["costo"]) if r.get("costo") is not None else None,
            tipo=r.get("tipo") or r.get("categoria") or "",
        )
        for r in raw
        if r.get("sku")
    ])
    by_sku = {r["sku"]: r for r in raw if r.get("sku")}
    marcas = [c.marca for c in catalogo]
    upsert_fuentes(url, key)

    adapters = todos_adapters()
    fecha = date.today().isoformat()
    total = 0
    for nom in ("Scorpion", "Abarrotero", "MayoreoTotal", "Exprezo"):
        ad = adapters[nom.lower()]
        filas = ad.cargar_csv()
        if not filas:
            print(f"{nom}: sin CSV")
            continue
        provs = enriquecer_proveedor(
            [
                ProductoProveedor(
                    fuente=nom,
                    id_producto_proveedor=str(f.get("id_producto_proveedor") or ""),
                    producto_raw=f.get("producto_raw") or "",
                    marca=f.get("marca") or "",
                    presentacion=f.get("presentacion") or "",
                    precio_unitario=float(f["precio_unitario"]) if f.get("precio_unitario") not in (None, "") else None,
                    cantidad_empaque=int(float(f.get("cantidad_empaque") or 1)),
                )
                for f in filas
                if f.get("producto_raw")
            ],
            marcas,
        )
        matches = matchear_fuente(catalogo, provs, nom, {})
        buenos = []
        for m in matches:
            if m.nivel not in {"A", "B", "confirmado"} or not m.proveedor:
                continue
            if m.proveedor.precio_unitario is None:
                continue
            prod = by_sku.get(m.sku)
            if not prod:
                continue
            buenos.append({
                "producto_id": prod["id"],
                "precio": round(float(m.proveedor.precio_unitario), 4),
                "nombre_fuente": m.proveedor.producto_raw,
                "confianza": 90 if m.nivel in {"A", "confirmado"} else 80,
                "nivel": m.nivel,
                "notas": f"pipeline {m.nivel} score={m.score:.0f}",
            })
        print(f"{nom}: {len(buenos)} matches A/B de {len(filas)} filas")
        fid = FUENTE_ID[nom]
        n = insertar(url, key, fid, buenos, fecha)
        print(f"  insertadas {n}")
        total += n
    print(f"Listo: {total} referencias nuevas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
