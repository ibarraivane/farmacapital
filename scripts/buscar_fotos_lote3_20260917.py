#!/usr/bin/env python3
"""Busca packshots por EAN en Farmatodo, Chedraui y Similares (VTEX)."""
from __future__ import annotations

import csv
import json
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PEND = Path("/home/ubuntu/.cursor/projects/workspace/uploads/siguen_sin_imagen_v2_20260917_90b9.csv")
# También los REVISAR del lote 2
EXTRA = [
    ("586", "7506484500522", "Cinta micropore blanca 2.5 cm x 5 m"),
    ("1270", "7501846504859", "Xiomara Pomada B"),
    ("1252", "2008490100017", "Copa lavaojos de vidrio"),
]
OUT = ROOT / "sql" / "generated" / "hits_lote3_20260917.csv"
UA = "FarmaCapitalCatalog/1.0 (+https://www.farmacapital.mx)"

APIS = [
    ("farmatodo", "https://www.farmatodo.com.mx/api/catalog_system/pub/products/search"),
    ("chedraui", "https://www.chedraui.com.mx/api/catalog_system/pub/products/search"),
    ("similares", "https://www.farmaciasdesimilares.com/api/catalog_system/pub/products/search"),
]


def get_json(url: str, timeout=25):
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.loads(r.read())


def eans() -> list[tuple[str, str, str]]:
    rows = []
    seen = set()
    for row in csv.DictReader(PEND.open(encoding="utf-8")):
        ean = (row.get("codigo_barras") or "").strip()
        if len(ean) < 8 or ean.startswith("2008") or ean in seen:
            continue
        seen.add(ean)
        rows.append((row["producto_id"], ean, row["nombre"]))
    for pid, ean, nombre in EXTRA:
        if ean.startswith("2008") or ean in seen:
            continue
        seen.add(ean)
        rows.append((pid, ean, nombre))
    # EAN probable de Pantene (typo conocido)
    rows.append(("243", "7501001303464", "Pantene Control caída anticaída (EAN probable)"))
    return rows


def item_eans(prod: dict) -> set[str]:
    found = set()
    for it in prod.get("items") or []:
        if it.get("ean"):
            found.add(str(it["ean"]).strip())
        for ref in it.get("reference") or []:
            if isinstance(ref, dict) and ref.get("Value"):
                found.add(str(ref["Value"]).strip())
    for key in ("EAN", "ean", "productEan"):
        if prod.get(key):
            found.add(str(prod[key]).strip())
    return found


def imagenes(prod: dict) -> list[str]:
    out = []
    for it in prod.get("items") or []:
        for im in it.get("images") or []:
            u = (im.get("imageUrl") or "").split("?")[0]
            if u and "placeholder" not in u.lower() and "no-disponible" not in u.lower():
                out.append(u)
    return out


def main() -> None:
    hits = []
    for pid, ean, nombre in eans():
        found_any = False
        for fuente, api in APIS:
            url = f"{api}?fq=alternateIds_Ean:{urllib.parse.quote(ean)}"
            try:
                data = get_json(url)
            except Exception as e:  # noqa: BLE001
                print(f"  ! {fuente} {ean} {type(e).__name__}: {e}")
                time.sleep(0.3)
                continue
            if not data:
                time.sleep(0.15)
                continue
            prod = data[0]
            eans_found = item_eans(prod)
            imgs = imagenes(prod)
            match = ean in eans_found or ean.lstrip("0") in {x.lstrip("0") for x in eans_found}
            if not match:
                print(f"  ~ {fuente} {ean} otro: {prod.get('productName')} eans={eans_found}")
                time.sleep(0.15)
                continue
            if not imgs:
                print(f"  ✗ {fuente} {ean} sin imagen {prod.get('productName')}")
                time.sleep(0.15)
                continue
            print(f"  ✓ {fuente} {ean} {str(prod.get('productName'))[:55]}")
            print(f"      {imgs[0]}")
            hits.append({
                "producto_id": pid,
                "codigo_barras": ean,
                "nombre": nombre,
                "nombre_fuente": prod.get("productName"),
                "url_origen": imgs[0],
                "galeria": " | ".join(imgs[1:4]),
                "fuente": fuente,
                "confianza": "EAN_EXACTO",
            })
            found_any = True
            break
        if not found_any:
            print(f"  · {ean} {nombre[:50]}")
        time.sleep(0.2)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w", newline="", encoding="utf-8") as fh:
        if hits:
            w = csv.DictWriter(fh, fieldnames=list(hits[0].keys()))
            w.writeheader()
            w.writerows(hits)
    print(f"\nhits {len(hits)} → {OUT}")


if __name__ == "__main__":
    main()
