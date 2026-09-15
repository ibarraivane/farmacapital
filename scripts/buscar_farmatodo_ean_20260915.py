#!/usr/bin/env python3
"""Busca packshots en Farmatodo VTEX por EAN exacto."""
from __future__ import annotations

import csv
import json
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CAND = ROOT / "sql" / "generated" / "candidatos_imagenes_20260915.csv"
PEND = ROOT / "sql" / "generated" / "siguen_sin_imagen_20260915.csv"
OUT = ROOT / "sql" / "generated" / "farmatodo_hits_20260915.csv"
UA = "FarmaCapitalCatalog/1.0 (+https://www.farmacapital.mx)"
API = "https://www.farmatodo.com.mx/api/catalog_system/pub/products/search"


def get_json(url: str):
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=20) as r:
        return json.loads(r.read())


def eans_from() -> list[tuple[str, str, str]]:
    seen, out = set(), []
    for path in (CAND, PEND):
        for row in csv.DictReader(path.open(encoding="utf-8")):
            ean = (row.get("codigo_barras") or "").strip()
            if len(ean) < 8 or ean.startswith("2008") or ean in seen:
                continue
            seen.add(ean)
            out.append((row["producto_id"], ean, row["nombre"]))
    return out


def item_eans(prod: dict) -> set[str]:
    found = set()
    for it in prod.get("items") or []:
        if it.get("ean"):
            found.add(str(it["ean"]).strip())
        for ref in it.get("reference") or []:
            if isinstance(ref, dict) and ref.get("Value"):
                found.add(str(ref["Value"]).strip())
    return found


def imagenes(prod: dict) -> list[str]:
    out = []
    for it in prod.get("items") or []:
        for im in it.get("images") or []:
            u = (im.get("imageUrl") or "").split("?")[0]
            if u and "placeholder" not in u.lower():
                out.append(u)
    return out


def main() -> None:
    hits = []
    for pid, ean, nombre in eans_from():
        url = f"{API}?fq=alternateIds_Ean:{urllib.parse.quote(ean)}"
        try:
            data = get_json(url)
        except Exception as e:  # noqa: BLE001
            print(f"  ! {ean} {e}")
            time.sleep(0.4)
            continue
        if not data:
            print(f"  ✗ {ean} {nombre[:40]}")
            time.sleep(0.25)
            continue
        prod = data[0]
        eans = item_eans(prod)
        imgs = imagenes(prod)
        match = ean in eans or ean.lstrip("0") in {x.lstrip("0") for x in eans}
        if not match:
            print(f"  ~ {ean} otro producto: {prod.get('productName')} eans={eans}")
            time.sleep(0.25)
            continue
        if not imgs:
            print(f"  ✗ {ean} sin imagen {prod.get('productName')}")
            time.sleep(0.25)
            continue
        print(f"  ✓ {ean} {prod.get('productName')[:50]} — {imgs[0]}")
        hits.append({
            "producto_id": pid,
            "codigo_barras": ean,
            "nombre": nombre,
            "nombre_farmatodo": prod.get("productName"),
            "url_origen": imgs[0],
            "galeria": " | ".join(imgs[1:4]),
            "fuente": "farmatodo",
            "confianza": "EAN_EXACTO",
        })
        time.sleep(0.3)
    with OUT.open("w", newline="", encoding="utf-8") as fh:
        if hits:
            w = csv.DictWriter(fh, fieldnames=list(hits[0].keys()))
            w.writeheader()
            w.writerows(hits)
    print(f"\nhits {len(hits)} → {OUT}")


if __name__ == "__main__":
    main()
