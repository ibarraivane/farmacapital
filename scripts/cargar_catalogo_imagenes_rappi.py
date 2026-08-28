#!/usr/bin/env python3
"""Carga catalogo_imagenes_rappi por API (PostgREST) y vincula producto_id.

Reemplaza el importador de CSV del Table Editor, que se corta a mitad de la
carga. Solo toca la tabla auxiliar public.catalogo_imagenes_rappi: no escribe
en productos, precios ni stock.

Uso:
    python3 scripts/cargar_catalogo_imagenes_rappi.py CSV_LIMPIO [--reset] [--vincular]
"""
from __future__ import annotations

import csv
import json
import re
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TABLA = "catalogo_imagenes_rappi"
LOTE = 200


def load_env():
    env = {}
    for line in (ROOT / ".env").read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip()
    return env


ENV = load_env()
URL = ENV["REACT_APP_SUPABASE_URL"].rstrip("/")
KEY = ENV["SUPABASE_SERVICE_ROLE_KEY"]


def api(metodo, path, body=None, prefer=None, timeout=120, intentos=5):
    """Llama a PostgREST reintentando cortes de conexion y 5xx transitorios."""
    data = json.dumps(body).encode() if body is not None else None
    ultimo = None
    for intento in range(intentos):
        req = urllib.request.Request(f"{URL}/rest/v1/{path}", data=data, method=metodo)
        req.add_header("apikey", KEY)
        req.add_header("Authorization", f"Bearer {KEY}")
        req.add_header("Content-Type", "application/json")
        if prefer:
            req.add_header("Prefer", prefer)
        try:
            with urllib.request.urlopen(req, timeout=timeout) as r:
                crudo = r.read()
                return r.status, r.headers.get("Content-Range"), (json.loads(crudo) if crudo else None)
        except urllib.error.HTTPError as e:
            detalle = e.read()[:500].decode()
            if e.code < 500:
                raise SystemExit(f"[{metodo} {path}] HTTP {e.code}: {detalle}")
            ultimo = f"HTTP {e.code}: {detalle}"
        except (urllib.error.URLError, ConnectionError, TimeoutError) as e:
            ultimo = str(e)
        time.sleep(0.5 * (2 ** intento))
    raise SystemExit(f"[{metodo} {path}] sin exito tras {intentos} intentos: {ultimo}")


def contar():
    return api("GET", f"{TABLA}?select=id&limit=1", prefer="count=exact")[1]


def normalizar(v):
    return re.sub(r"[^0-9]", "", v or "")


def leer_csv(ruta):
    with open(ruta, encoding="utf-8-sig", newline="") as f:
        filas = list(csv.DictReader(f))
    salida = []
    for x in filas:
        salida.append({
            "ean": x["ean"].strip(),
            "sku_local": x["sku_local"].strip() or None,
            "nombre_local": x["nombre_local"].strip() or None,
            "rappi_product_id": int(x["rappi_product_id"]) if x["rappi_product_id"].strip() else None,
            "nombre_rappi": x["nombre_rappi"].strip() or None,
            "posicion": int(x["posicion"]),
            "es_principal_sugerida": x["es_principal_sugerida"].strip().lower() == "true",
            "ruta_original": x["ruta_original"].strip(),
            "url_origen": x["url_origen"].strip(),
            "estado_revision": x["estado_revision"].strip() or "pendiente",
        })
    return salida


def insertar(filas):
    total = 0
    for i in range(0, len(filas), LOTE):
        bloque = filas[i:i + LOTE]
        api("POST", TABLA, bloque, prefer="return=minimal,resolution=ignore-duplicates")
        total += len(bloque)
        print(f"  insertadas {total}/{len(filas)}", flush=True)
    return total


def traer_productos():
    mapa, off = {}, 0
    while True:
        _, _, rows = api("GET", f"productos?select=id,codigo_barras&codigo_barras=not.is.null&order=id&offset={off}&limit=1000")
        if not rows:
            break
        for r in rows:
            k = normalizar(r["codigo_barras"])
            if k:
                mapa.setdefault(k, []).append(r["id"])
        off += 1000
        if len(rows) < 1000:
            break
    return mapa


def vincular():
    mapa = traer_productos()
    _, _, filas = api("GET", f"{TABLA}?select=ean&producto_id=is.null&limit=5000")
    eans = sorted({f["ean"] for f in filas})
    unicos, ambiguos, huerfanos = {}, [], []
    for ean in eans:
        ids = mapa.get(normalizar(ean), [])
        if len(ids) == 1:
            unicos[ean] = ids[0]
        elif len(ids) > 1:
            ambiguos.append((ean, ids))
        else:
            huerfanos.append(ean)

    def patch(item):
        ean, pid = item
        api("PATCH", f"{TABLA}?ean=eq.{ean}&producto_id=is.null",
            {"producto_id": pid}, prefer="return=minimal")
        return ean

    hechos = 0
    with ThreadPoolExecutor(max_workers=4) as ex:
        futs = [ex.submit(patch, it) for it in unicos.items()]
        for f in as_completed(futs):
            f.result()
            hechos += 1
            if hechos % 100 == 0:
                print(f"  vinculados {hechos}/{len(unicos)} eans", flush=True)
    return unicos, ambiguos, huerfanos


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    flags = {a for a in sys.argv[1:] if a.startswith("--")}
    csv_path = args[0] if args else None

    print("estado inicial:", contar())

    if "--reset" in flags:
        api("DELETE", f"{TABLA}?id=gt.0", prefer="return=minimal")
        print("tabla vaciada:", contar())

    if csv_path:
        filas = leer_csv(csv_path)
        print(f"insertando {len(filas)} filas...")
        insertar(filas)
        print("estado tras insertar:", contar())

    if "--vincular" in flags:
        print("vinculando producto_id...")
        unicos, ambiguos, huerfanos = vincular()
        print(f"eans vinculados: {len(unicos)} | ambiguos: {len(ambiguos)} | sin match: {len(huerfanos)}")
        if ambiguos:
            print("AMBIGUOS (ean repetido en productos):")
            for ean, ids in ambiguos:
                print(f"  {ean} -> productos {ids}")


if __name__ == "__main__":
    main()
