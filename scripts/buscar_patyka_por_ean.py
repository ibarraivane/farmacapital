#!/usr/bin/env python3
"""Candidatos de foto en el sitio oficial de Patyka, por código de barras.

Lee sql/generated/senti2_sin_foto_20260925.csv (marca Senti2, EAN 3700591…).
Busca en patyka.com y solo acepta la variante cuyo barcode coincide.

No descarga la imagen ni escribe productos.imagen_url. La foto del fabricante
sigue sin permiso verificado: el CSV es para revisión, no para publicar.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CSV_IN = ROOT / "sql" / "generated" / "senti2_sin_foto_20260925.csv"
CSV_OUT = ROOT / "sql" / "generated" / "candidatos_patyka_oficial_20260925.csv"
UA = "FarmaCapitalCatalog/1.0 (+https://www.farmacapital.mx)"
ORIGIN = "https://patyka.com"
LICENCIA = (
    "fabricante patyka.com; permiso no verificado; "
    "no hotlink en producción; no descargada ni subida a Storage"
)


def get(url: str, accept: str = "application/json") -> tuple[int, bytes]:
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": accept})
    try:
        with urllib.request.urlopen(req, timeout=40) as r:
            return r.status, r.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read()


def variante_por_ean(product: dict, ean: str) -> dict | None:
    wanted = (ean or "").strip()
    if not wanted:
        return None
    for variant in product.get("variants") or []:
        barcode = str(variant.get("barcode") or "").strip()
        if barcode == wanted:
            return variant
    return None


def url_imagen(variant: dict, product: dict) -> str:
    featured = variant.get("featured_image") or {}
    if isinstance(featured, dict):
        src = (featured.get("src") or "").strip()
        if src:
            return _abs(src)
    images = product.get("images") or []
    if not images:
        return ""
    first = images[0]
    if isinstance(first, str):
        return _abs(first)
    if isinstance(first, dict):
        return _abs(first.get("src") or "")
    return ""


def _abs(src: str) -> str:
    src = (src or "").strip()
    if src.startswith("//"):
        return "https:" + src
    return src


def mililitros(texto: str) -> float | None:
    match = re.search(r"(\d+(?:[.,]\d+)?)\s*ml\b", texto or "", re.I)
    if not match:
        return None
    return float(match.group(1).replace(",", "."))


def tamano_distinto(presentacion: str, oficial: str) -> bool:
    """True si ambos lados dicen ml y no coinciden, o solo uno trae ml."""
    nuestro = mililitros(presentacion)
    suyo = mililitros(oficial)
    if nuestro is None and suyo is None:
        return False
    if nuestro is None or suyo is None:
        return True
    return nuestro != suyo


def buscar_handles(ean: str) -> list[str]:
    url = (
        f"{ORIGIN}/search/suggest.json?q={ean}"
        "&resources[type]=product&resources[limit]=10"
    )
    status, raw = get(url)
    if status != 200:
        return []
    data = json.loads(raw.decode())
    products = ((data.get("resources") or {}).get("results") or {}).get("products") or []
    handles = []
    for product in products:
        handle = (product.get("handle") or "").strip()
        if handle and handle not in handles:
            handles.append(handle)
    return handles


def ficha(handle: str) -> dict | None:
    status, raw = get(f"{ORIGIN}/products/{handle}.js")
    if status != 200:
        return None
    return json.loads(raw.decode())


def hotlink(url: str) -> str:
    if not url:
        return ""
    req = urllib.request.Request(
        url,
        method="HEAD",
        headers={"User-Agent": UA, "Accept": "image/*,*/*"},
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return str(r.status)
    except urllib.error.HTTPError as e:
        return str(e.code)
    except Exception as e:  # noqa: BLE001
        return type(e).__name__


def clasificar(row: dict, pause: float) -> dict:
    ean = (row.get("codigo_barras") or "").strip()
    base = {
        "producto_id": row.get("id") or row.get("producto_id") or "",
        "sku": row.get("sku") or "",
        "codigo_barras": ean,
        "nombre": row.get("nombre") or "",
        "marca_actual": row.get("marca") or "",
        "presentacion": row.get("presentacion") or "",
        "estado": "SIN_CANDIDATA",
        "url_imagen": "",
        "pagina_origen": "",
        "fuente": "patyka.com",
        "confianza": "",
        "licencia": LICENCIA,
        "nombre_oficial": "",
        "presentacion_oficial": "",
        "hotlink": "",
        "nota": "",
    }
    if not ean:
        base["nota"] = "sin código de barras"
        return base
    handles = buscar_handles(ean)
    time.sleep(pause)
    matches = []
    for handle in handles:
        product = ficha(handle)
        time.sleep(pause)
        if not product:
            continue
        variant = variante_por_ean(product, ean)
        if variant:
            matches.append((product, variant))
    if not matches:
        base["nota"] = "el sitio oficial no devolvió una variante con este EAN"
        return base
    if len(matches) > 1:
        base["estado"] = "REVISAR_VISUALMENTE"
        base["nota"] = f"{len(matches)} fichas oficiales con el mismo EAN"
        return base
    product, variant = matches[0]
    handle = product.get("handle") or ""
    imagen = url_imagen(variant, product)
    oficial = (variant.get("title") or variant.get("option1") or "").strip()
    nuestra = (row.get("presentacion") or "").strip()
    titulo = (product.get("title") or "").strip()
    nota = "barcode de la variante = EAN del catálogo"
    estado = "EAN_EXACTO"
    confianza = "EAN_EXACTO"
    if tamano_distinto(nuestra, oficial):
        estado = "REVISAR_VISUALMENTE"
        confianza = "EAN_EXACTO_TAMAÑO_DISTINTO"
        nota += (
            f"; el EAN es de «{titulo}» {oficial}, "
            f"el catálogo dice «{row.get('nombre') or ''}» {nuestra}"
        )
    elif oficial and nuestra and oficial.lower().replace(" ", "") != nuestra.lower().replace(" ", ""):
        nota += f"; presentación oficial «{oficial}»"
    base.update(
        {
            "estado": estado,
            "url_imagen": imagen,
            "pagina_origen": f"{ORIGIN}/products/{handle}",
            "confianza": confianza,
            "nombre_oficial": titulo,
            "presentacion_oficial": oficial,
            "hotlink": hotlink(imagen),
            "nota": nota,
        }
    )
    time.sleep(pause)
    return base


def self_test() -> None:
    product = {
        "handle": "fluido",
        "images": ["//cdn.shopify.com/s/files/1/x/pack.jpg"],
        "variants": [
            {"barcode": "3700591913341", "title": "40 ml", "featured_image": None},
            {
                "barcode": "3700591913358",
                "title": "40 ml",
                "featured_image": {"src": "https://cdn.shopify.com/s/files/1/x/frente.jpg"},
            },
        ],
    }
    assert variante_por_ean(product, "3700591913358")["title"] == "40 ml"
    assert variante_por_ean(product, "000") is None
    assert url_imagen(product["variants"][1], product).endswith("frente.jpg")
    assert url_imagen(product["variants"][0], product).startswith("https://cdn.shopify.com")
    assert mililitros("200 ml") == mililitros("200ml") == 200
    assert not tamano_distinto("200 ml", "200ml")
    assert tamano_distinto("200 ml", "15 ml")
    assert tamano_distinto("50 ml", "1 utilisation")
    print("self-test ok")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--pausa", type=float, default=0.35)
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return
    rows = list(csv.DictReader(CSV_IN.open(encoding="utf-8")))
    out_rows = [clasificar(row, args.pausa) for row in rows]
    fields = list(out_rows[0].keys()) if out_rows else []
    with CSV_OUT.open("w", encoding="utf-8", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=fields)
        writer.writeheader()
        writer.writerows(out_rows)
    exactos = sum(1 for r in out_rows if r["estado"] == "EAN_EXACTO")
    revisar = sum(1 for r in out_rows if r["estado"] == "REVISAR_VISUALMENTE")
    print(f"{exactos} EAN_EXACTO, {revisar} REVISAR_VISUALMENTE, de {len(out_rows)} → {CSV_OUT}")


if __name__ == "__main__":
    main()
