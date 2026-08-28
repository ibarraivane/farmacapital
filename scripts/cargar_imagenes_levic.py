#!/usr/bin/env python3
"""Sube al bucket las fotos del CDN de Levic para productos sin ninguna imagen.

Complementa la carga de Rappi: cubre productos que Rappi no tenía pero que sí
aparecen en el catálogo de Levic (visoti.mx). Entran como origen
'distribuidor', posición 1 y principal, porque son productos que hoy no tienen
ninguna foto.

Idempotente: producto_imagenes tiene índice único (producto_id, url).

Uso:
    python3 scripts/cargar_imagenes_levic.py CANDIDATOS.json
    # cada elemento: {"producto_id": 123, "ean": "750...", "clave": "MAV098"}
"""
from __future__ import annotations

import json
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUCKET = "productos"
PREFIJO = "distribuidor"
CDN = "https://visoti.mx/imagenes/Grande/{clave}.webp"
UA = "Mozilla/5.0"


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


def supa(metodo, path, body=None, prefer=None, raw=None, content_type=None,
         base="rest/v1", extra=None, intentos=5):
    data = raw if raw is not None else (json.dumps(body).encode() if body is not None else None)
    ultimo = None
    for intento in range(intentos):
        req = urllib.request.Request(f"{URL}/{base}/{path}", data=data, method=metodo)
        req.add_header("apikey", KEY)
        req.add_header("Authorization", f"Bearer {KEY}")
        req.add_header("Content-Type", content_type or "application/json")
        if prefer:
            req.add_header("Prefer", prefer)
        for k, v in (extra or {}).items():
            req.add_header(k, v)
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                crudo = r.read()
                return json.loads(crudo) if crudo and r.headers.get("Content-Type", "").startswith("application/json") else None
        except urllib.error.HTTPError as e:
            detalle = e.read()[:300].decode(errors="replace")
            if e.code < 500:
                raise RuntimeError(f"HTTP {e.code}: {detalle}")
            ultimo = detalle
        except Exception as e:  # noqa: BLE001
            ultimo = str(e)
        time.sleep(0.5 * (2 ** intento))
    raise RuntimeError(f"sin exito: {ultimo}")


def bajar(clave, intentos=3):
    u = CDN.format(clave=clave)
    ultimo = None
    for intento in range(intentos):
        try:
            req = urllib.request.Request(u, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=45) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            if e.code == 404:
                raise RuntimeError("404 en el CDN")
            ultimo = str(e)
        except Exception as e:  # noqa: BLE001
            ultimo = str(e)
        time.sleep(1.5 * (intento + 1))
    raise RuntimeError(f"descarga fallida: {ultimo}")


def main():
    candidatos = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    print(f"candidatos: {len(candidatos)}")

    filas, fallos = [], []
    for it in candidatos:
        try:
            blob = bajar(it["clave"])
            ruta = f"{PREFIJO}/{it['ean']}.webp"
            supa("POST", f"object/{BUCKET}/{ruta}", raw=blob, content_type="image/webp",
                 base="storage/v1", prefer="return=minimal", extra={"x-upsert": "true"})
            filas.append({
                "producto_id": it["producto_id"],
                "url": f"{URL}/storage/v1/object/public/{BUCKET}/{ruta}",
                "storage_path": ruta,
                "posicion": 1,
                "es_principal": True,
                "origen": "distribuidor",
            })
            print(f"  ok  {it['clave']}  {it['nombre'][:44]}", flush=True)
        except Exception as e:  # noqa: BLE001
            fallos.append((it, str(e)[:90]))
            print(f"  --  {it['clave']}  {e}", flush=True)

    if filas:
        supa("POST", "producto_imagenes?on_conflict=producto_id,url", filas,
             prefer="return=minimal,resolution=ignore-duplicates")

    print(f"\nsubidas: {len(filas)} | fallos: {len(fallos)}")


if __name__ == "__main__":
    main()
