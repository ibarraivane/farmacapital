#!/usr/bin/env python3
"""Copia las fotos ya subidas al bucket hacia public.producto_imagenes.

Lee catalogo_imagenes_rappi (las filas que ya tienen url_storage) y las inserta
en la tabla que consume la app. Idempotente: repite sin duplicar gracias al
indice unico (producto_id, url).

Uso:
    python3 scripts/sembrar_producto_imagenes.py
"""
from __future__ import annotations

import json
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOTE = 300


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


def api(metodo, path, body=None, prefer=None, intentos=5):
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
            with urllib.request.urlopen(req, timeout=120) as r:
                crudo = r.read()
                return r.headers.get("Content-Range"), (json.loads(crudo) if crudo else None)
        except urllib.error.HTTPError as e:
            detalle = e.read()[:400].decode(errors="replace")
            if e.code < 500:
                raise SystemExit(f"[{metodo} {path}] HTTP {e.code}: {detalle}")
            ultimo = detalle
        except Exception as e:  # noqa: BLE001
            ultimo = str(e)
        time.sleep(0.5 * (2 ** intento))
    raise SystemExit(f"[{metodo} {path}] sin exito: {ultimo}")


def main():
    origen = api("GET", "catalogo_imagenes_rappi"
                        "?select=producto_id,posicion,es_principal_sugerida,url_storage,storage_path"
                        "&producto_id=not.is.null&url_storage=not.is.null&order=producto_id,posicion&limit=5000")[1]
    print(f"fotos listas en el bucket: {len(origen)}")

    filas = [{
        "producto_id": r["producto_id"],
        "url": r["url_storage"],
        "storage_path": r["storage_path"],
        "posicion": r["posicion"],
        "es_principal": bool(r["es_principal_sugerida"]),
        "origen": "rappi",
    } for r in origen]

    # Si la principal sugerida no llego a subir (foto muerta en el CDN), el
    # producto se quedaria con fotos pero sin ninguna marcada: las rejillas del
    # POS buscan la principal y no encontrarian nada. Promovemos la de menor
    # posicion.
    por_producto = {}
    for f in filas:
        por_producto.setdefault(f["producto_id"], []).append(f)
    promovidas = 0
    for grupo in por_producto.values():
        if any(f["es_principal"] for f in grupo):
            continue
        min(grupo, key=lambda f: f["posicion"])["es_principal"] = True
        promovidas += 1
    if promovidas:
        print(f"principales promovidas por foto caida: {promovidas}")

    for i in range(0, len(filas), LOTE):
        bloque = filas[i:i + LOTE]
        api("POST", "producto_imagenes?on_conflict=producto_id,url", bloque,
            prefer="return=minimal,resolution=ignore-duplicates")
        print(f"  sembradas {min(i + LOTE, len(filas))}/{len(filas)}", flush=True)

    total = api("GET", "producto_imagenes?select=id&limit=1", prefer="count=exact")[0]
    prods = api("GET", "producto_imagenes?select=producto_id&limit=5000")[1]
    print(f"\nproducto_imagenes: {total.split('/')[1]} filas | {len({p['producto_id'] for p in prods})} productos")


if __name__ == "__main__":
    main()
