#!/usr/bin/env python3
"""
Sincroniza precios de venta de Farmacias Similares (VTEX público) → producto_precios_referencia.

API: https://www.farmaciasdesimilares.com/api/catalog_system/pub/products/search/{termino}

Uso:
  python3 scripts/sync_precios_similares.py --dry-run --limit 20
  python3 scripts/sync_precios_similares.py --apply
  python3 scripts/sync_precios_similares.py --apply --limit 50

Rate limit: ~1 req/s (configurable). Cache de términos fallidos en el mismo run.
"""
from __future__ import annotations

import argparse
import os
import re
import sys
import time
import urllib.parse
import urllib.request
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / ".env"

VTEX_SEARCH = "https://www.farmaciasdesimilares.com/api/catalog_system/pub/products/search/{query}"

try:
    import requests
except ImportError:
    requests = None


def cargar_env() -> dict[str, str]:
    out: dict[str, str] = {}
    if ENV_PATH.exists():
        for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, _, v = line.partition("=")
            out[k.strip()] = v.strip()
    out.setdefault("REACT_APP_SUPABASE_URL", os.environ.get("REACT_APP_SUPABASE_URL", ""))
    out.setdefault("REACT_APP_SUPABASE_ANON_KEY", os.environ.get("REACT_APP_SUPABASE_ANON_KEY", ""))
    return out


def fetch_productos(url: str, key: str) -> list[dict]:
    if not requests:
        sys.exit("Falta requests")
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    rows: list[dict] = []
    offset = 0
    while True:
        h = {**headers, "Range": f"{offset}-{offset + 499}"}
        r = requests.get(
            f"{url}/rest/v1/productos",
            headers=h,
            params={
                "select": "id,sku,nombre,principio_activo,marca,presentacion",
                "activo": "eq.true",
            },
            timeout=60,
        )
        r.raise_for_status()
        batch = r.json()
        rows.extend(batch)
        if len(batch) < 500:
            break
        offset += 500
    return rows


def search_term_for_product(p: dict) -> str:
    pa = (p.get("principio_activo") or "").strip()
    if pa and len(pa) >= 4:
        return pa.split()[0][:40]
    nombre = (p.get("nombre") or "").strip()
    # primeras palabras significativas
    parts = re.split(r"\s+", nombre)
    stop = {"tab", "c/", "mg", "ml", "gr", "g", "de", "con", "sin", "x"}
    words = [w for w in parts if len(w) > 2 and w.lower() not in stop][:3]
    return " ".join(words)[:50] if words else nombre[:40]


def vtex_price(term: str, cache_fail: set[str]) -> tuple[float | None, str | None]:
    if term in cache_fail:
        return None, None
    q = urllib.parse.quote(term)
    url = VTEX_SEARCH.format(query=q)
    try:
        req = urllib.request.Request(url, headers={"Accept": "application/json", "User-Agent": "FarmaCapital/1.0"})
        with urllib.request.urlopen(req, timeout=20) as resp:
            data = resp.read()
        import json
        items = json.loads(data)
        if not items:
            cache_fail.add(term)
            return None, None
        item = items[0]
        product_id = str(item.get("productId") or item.get("productReference") or "")
        sellers = (item.get("items") or [{}])[0].get("sellers") or []
        if not sellers:
            cache_fail.add(term)
            return None, product_id or None
        price = sellers[0].get("commertialOffer", {}).get("Price")
        if price is None:
            cache_fail.add(term)
            return None, product_id or None
        return float(price), product_id or None
    except Exception:
        cache_fail.add(term)
        return None, None


def apply_rows(url: str, key: str, fecha: str, rows: list[dict]) -> None:
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=representation",
    }
    imp = requests.post(
        f"{url}/rest/v1/importaciones_referencia",
        headers=headers,
        json={
            "fuente": "similares",
            "tipo": "venta",
            "fecha_lista": fecha,
            "archivo": "job_vtex_similares",
            "filas_ok": len(rows),
            "notas": "sync_precios_similares.py",
        },
        timeout=60,
    )
    imp.raise_for_status()
    import_id = imp.json()[0]["id"]
    payload = [
        {
            "producto_id": r["producto_id"],
            "fuente": "similares",
            "tipo": "venta",
            "precio": r["precio"],
            "fecha": fecha,
            "nombre_fuente": r.get("nombre_fuente"),
            "sku_externo": r.get("vtex_id"),
            "confianza": r.get("confianza", 75),
            "origen": "job_vtex",
            "import_id": import_id,
            "notas": f"termino:{r.get('termino')}",
        }
        for r in rows
    ]
    for i in range(0, len(payload), 100):
        chunk = payload[i : i + 100]
        r = requests.post(f"{url}/rest/v1/producto_precios_referencia", headers=headers, json=chunk, timeout=120)
        r.raise_for_status()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--limit", type=int, default=0, help="Máx productos a consultar (0=todos)")
    parser.add_argument("--delay", type=float, default=1.0, help="Segundos entre requests VTEX")
    args = parser.parse_args()

    env = cargar_env()
    sb_url = env.get("REACT_APP_SUPABASE_URL", "")
    sb_key = env.get("REACT_APP_SUPABASE_ANON_KEY", "")
    if not sb_url or not sb_key:
        sys.exit("Faltan credenciales Supabase en .env")

    productos = fetch_productos(sb_url, sb_key)
    if args.limit:
        productos = productos[: args.limit]
    print(f"Productos a consultar: {len(productos)}")

    cache_fail: set[str] = set()
    found: list[dict] = []
    fecha = date.today().isoformat()

    for i, p in enumerate(productos, start=1):
        term = search_term_for_product(p)
        if not term:
            continue
        price, vtex_id = vtex_price(term, cache_fail)
        if price is not None:
            found.append({
                "producto_id": p["id"],
                "sku": p.get("sku"),
                "nombre": p.get("nombre"),
                "precio": price,
                "termino": term,
                "vtex_id": vtex_id,
                "confianza": 75,
                "nombre_fuente": term,
            })
        if args.dry_run and found:
            last = found[-1]
            print(f"  [{i}/{len(productos)}] {last.get('sku')} ← ${last['precio']:.2f} ({term})")
        elif i % 25 == 0:
            print(f"  Progreso {i}/{len(productos)} — encontrados: {len(found)}")
        time.sleep(args.delay)

    print(f"Precios Similares encontrados: {len(found)} / {len(productos)}")

    if args.dry_run or not args.apply:
        if not args.dry_run:
            print("Usa --apply para guardar en Supabase")
        return

    if not found:
        print("Nada que insertar.")
        return

    apply_rows(sb_url, sb_key, fecha, found)
    print("Guardado en producto_precios_referencia.")


if __name__ == "__main__":
    main()
