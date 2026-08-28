#!/usr/bin/env python3
"""Cruza el catálogo con iNadro (VTEX) por EAN.

- Fotos: públicas. Solo las pone si el producto no tiene imagen_url ni
  producto_imagenes.
- Precio de compra: el portal sin sesión manda $100 falso o «precio público».
  Eso NO se escribe en Referencias. El costo de cliente pide NADRO_USER /
  NADRO_PASSWORD (aún no se usa aquí).

    python3 scripts/sync_nadro.py
    python3 scripts/sync_nadro.py --limit 20
"""
from __future__ import annotations

import argparse
import json
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUCKET = "productos"
SEARCH = "https://i22.nadro.mx/api/io/_v/api/intelligent-search/product_search"
UA = "FarmaCapitalPricingBot/1.0 (+https://www.farmacapital.mx)"


def load_env():
    env = {}
    for line in (ROOT / ".env").read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip().strip('"').strip("'")
    return env


ENV = load_env()
URL = ENV["REACT_APP_SUPABASE_URL"].rstrip("/")
KEY = ENV["SUPABASE_SERVICE_ROLE_KEY"]


def digits(s):
    return "".join(c for c in str(s or "") if c.isdigit())


def http(url, data=None, headers=None, method=None, timeout=45):
    req = urllib.request.Request(url, data=data, method=method or ("POST" if data else "GET"))
    req.add_header("User-Agent", UA)
    for k, v in (headers or {}).items():
        req.add_header(k, v)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.status, r.read(), r.headers


def supa(metodo, path, body=None, prefer=None, raw=None, content_type=None, base="rest/v1"):
    data = raw if raw is not None else (json.dumps(body).encode() if body is not None else None)
    headers = {
        "apikey": KEY,
        "Authorization": f"Bearer {KEY}",
        "Content-Type": content_type or "application/json",
    }
    if prefer:
        headers["Prefer"] = prefer
    _st, crudo, _h = http(f"{URL}/{base}/{path}", data=data, headers=headers, method=metodo)
    if not crudo:
        return None
    if (content_type or "").startswith("image"):
        return None
    try:
        return json.loads(crudo)
    except json.JSONDecodeError:
        return None


def page(path):
    out, start = [], 0
    while True:
        rows = supa("GET", f"{path}{'&' if '?' in path else '?'}limit=1000&offset={start}") or []
        if not rows:
            break
        out.extend(rows)
        if len(rows) < 1000:
            break
        start += 1000
    return out


def buscar(ean, intentos=5):
    q = digits(ean)
    url = f"{SEARCH}?q={urllib.parse.quote(q)}&count=8"
    ultimo = None
    for i in range(intentos):
        try:
            _st, raw, _h = http(url, headers={"Accept": "application/json"}, timeout=20)
            data = json.loads(raw)
            break
        except urllib.error.HTTPError as e:
            ultimo = e.code
            if e.code in (429, 503):
                time.sleep(4 * (i + 1))
                continue
            return None
        except Exception as e:  # noqa: BLE001
            ultimo = str(e)
            time.sleep(1.5)
    else:
        print(f"  !!  {q}  búsqueda falló ({ultimo})", flush=True)
        return None
    for p in data.get("products") or []:
        items = p.get("items") or [{}]
        item = items[0] if items else {}
        if digits(item.get("ean")) != q:
            continue
        imgs = []
        for im in item.get("images") or []:
            u = str((im or {}).get("imageUrl") or "").split("?")[0]
            if u and "placehold" not in u.lower():
                imgs.append(u)
        if not imgs:
            return None
        return {"nombre": p.get("productName"), "imagenes": imgs, "ean": q}
    return None


def productos_sin_foto():
    prods = page(
        "productos?select=id,nombre,codigo_barras,imagen_url,principio_activo,tipo,categoria&activo=eq.true"
    )
    gal = {r["producto_id"] for r in page("producto_imagenes?select=producto_id")}
    out = []
    for p in prods:
        ean = digits(p.get("codigo_barras"))
        if len(ean) < 8:
            continue
        if str(p.get("imagen_url") or "").strip():
            continue
        if p["id"] in gal:
            continue
        out.append({
            "producto_id": p["id"],
            "ean": ean,
            "nombre": p.get("nombre") or "",
            "med": bool(str(p.get("principio_activo") or "").strip())
            or str(p.get("tipo") or "").lower() in ("generico", "genérico", "marca")
            or "medic" in str(p.get("categoria") or "").lower(),
        })
    out.sort(key=lambda x: (not x["med"], x["nombre"]))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", type=int, default=0)
    args = ap.parse_args()
    cand = productos_sin_foto()
    if args.limit:
        cand = cand[: args.limit]
    print(f"sin foto con EAN: {len(cand)}")
    ok, fail = 0, 0
    filas = []
    for i, it in enumerate(cand, 1):
        try:
            hit = buscar(it["ean"])
            if not hit:
                print(f"  --  {it['ean']}  no está en Nadro  {it['nombre'][:40]}", flush=True)
                fail += 1
                time.sleep(0.15)
                continue
            _st, blob, hdrs = http(hit["imagenes"][0], timeout=40)
            if len(blob) < 800:
                raise RuntimeError("imagen vacía")
            ct = (hdrs.get("Content-Type") or "image/jpeg").split(";")[0]
            ext = "png" if "png" in ct else "webp" if "webp" in ct else "jpg"
            ruta = f"distribuidor/nadro-{it['ean']}.{ext}"
            req = urllib.request.Request(
                f"{URL}/storage/v1/object/{BUCKET}/{ruta}",
                data=blob,
                method="POST",
            )
            req.add_header("apikey", KEY)
            req.add_header("Authorization", f"Bearer {KEY}")
            req.add_header("Content-Type", ct)
            req.add_header("x-upsert", "true")
            with urllib.request.urlopen(req, timeout=60):
                pass
            filas.append({
                "producto_id": it["producto_id"],
                "url": f"{URL}/storage/v1/object/public/{BUCKET}/{ruta}",
                "storage_path": ruta,
                "posicion": 1,
                "es_principal": True,
                "origen": "distribuidor",
            })
            ok += 1
            print(f"  ok  {it['ean']}  {hit['nombre'][:44]}", flush=True)
            time.sleep(0.8)
        except Exception as e:  # noqa: BLE001
            fail += 1
            print(f"  --  {it['ean']}  {e}", flush=True)
            time.sleep(0.8)
    if filas:
        for i in range(0, len(filas), 40):
            supa(
                "POST",
                "producto_imagenes?on_conflict=producto_id,url",
                filas[i:i + 40],
                prefer="return=minimal,resolution=ignore-duplicates",
            )
    print(f"\nfotos nuevas: {ok} | sin match/fallo: {fail}")


if __name__ == "__main__":
    main()
