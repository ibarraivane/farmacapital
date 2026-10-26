#!/usr/bin/env python3
"""Busca packshot por EAN para lo que la lista ME Piel no trae en Dermaexpress.

Fuente: Farmatodo (VTEX). Rechaza hotlink de Fahorro.
No pisa una foto que ya esté en mepiel_fotos_extra_2026.csv.
"""
from __future__ import annotations

import csv
import json
import sys
import time
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SIN = ROOT / "docs/catalogos/mepiel_sin_foto_2026.csv"
OUT = ROOT / "docs/catalogos/mepiel_fotos_extra_2026.csv"
UA = "FarmaCapitalCatalog/1.0 (+https://www.farmacapital.mx)"


def get_json(url: str):
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=25) as r:
        return json.loads(r.read().decode())


def imagen_ok(url: str) -> bool:
    u = (url or "").strip()
    if not u.startswith("https://"):
        return False
    host = urllib.parse.urlparse(u).hostname or ""
    if host.endswith("fahorro.com"):
        return False
    low = u.lower()
    if "placeholder" in low or "no-disponible" in low or "imagen-no" in low:
        return False
    return True


def buscar(ean: str, nombre: str) -> dict | None:
    url = (
        "https://www.farmatodo.com.mx/api/catalog_system/pub/products/search"
        f"?fq=alternateIds_Ean:{ean}"
    )
    try:
        data = get_json(url)
    except Exception:
        return None
    if not isinstance(data, list) or not data:
        return None
    prod = data[0]
    for item in prod.get("items") or []:
        item_ean = "".join(ch for ch in str(item.get("ean") or "") if ch.isdigit())
        if item_ean != ean:
            continue
        for im in item.get("images") or []:
            raw = (im.get("imageUrl") or "").split("?")[0]
            if imagen_ok(raw):
                return {
                    "ean": ean,
                    "imagen_url": raw,
                    "nombre": (prod.get("productName") or nombre or "").strip(),
                    "marca": (prod.get("brand") or "").strip(),
                    "origen": "farmatodo",
                }
    return None


def main() -> None:
    if not SIN.exists():
        print(f"Falta {SIN}. Corre generar-alta-mepiel.js primero.", file=sys.stderr)
        sys.exit(1)
    rows = list(csv.DictReader(SIN.open(encoding="utf-8")))
    ya = {}
    if OUT.exists():
        for row in csv.DictReader(OUT.open(encoding="utf-8")):
            if row.get("ean") and row.get("imagen_url"):
                ya[row["ean"]] = row
    pendientes = [r for r in rows if r.get("ean") and r["ean"] not in ya]
    print(f"sin foto {len(rows)} ya {len(ya)} a buscar {len(pendientes)}", flush=True)
    hits = list(ya.values())
    found = 0
    with ThreadPoolExecutor(max_workers=8) as pool:
        futs = {pool.submit(buscar, r["ean"], r.get("nombre") or ""): r for r in pendientes}
        done = 0
        for fut in as_completed(futs):
            done += 1
            hit = fut.result()
            if hit:
                hits.append(hit)
                found += 1
            if done % 40 == 0:
                print(f"  {done}/{len(pendientes)} hits {found}", flush=True)
            time.sleep(0.02)
    cols = ["ean", "imagen_url", "nombre", "marca", "origen"]
    with OUT.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=cols)
        w.writeheader()
        for row in hits:
            w.writerow({c: row.get(c, "") for c in cols})
    print(json.dumps({"hits": len(hits), "nuevos": found}))


if __name__ == "__main__":
    main()
