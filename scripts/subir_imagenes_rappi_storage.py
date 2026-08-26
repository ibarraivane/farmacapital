#!/usr/bin/env python3
"""Baja las fotos de catalogo_imagenes_rappi desde el CDN y las sube al bucket.

Los archivos originales no estan en disco: solo tenemos url_origen. Este script
descarga cada imagen, la sube a storage/productos/rappi/{ean}/{posicion}.{ext} y
escribe storage_bucket, storage_path, url_storage y fecha_importacion en la fila.

Es idempotente: salta las filas que ya tienen url_storage. Los fallos quedan en
error_importacion para reintentarlos despues.

Los cortes "Connection refused" son locales (demasiadas conexiones abiertas a
la vez), no del CDN ni de Supabase: se resuelven repitiendo con --hilos bajo.

Uso:
    python3 scripts/subir_imagenes_rappi_storage.py [--limite=N] [--hilos=N]
"""
from __future__ import annotations

import json
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
from pathlib import Path
from threading import Lock

ROOT = Path(__file__).resolve().parent.parent
TABLA = "catalogo_imagenes_rappi"
BUCKET = "productos"
PREFIJO = "rappi"
HILOS = 6
UA = "FarmaCapitalCatalog/1.0"
EXT_POR_MIME = {"image/webp": "webp", "image/jpeg": "jpg", "image/png": "png"}


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
LOCK = Lock()


def supa(metodo, path, body=None, prefer=None, raw=None, content_type=None,
         base="rest/v1", timeout=120, intentos=5, extra=None):
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
            with urllib.request.urlopen(req, timeout=timeout) as r:
                crudo = r.read()
                return json.loads(crudo) if crudo and r.headers.get("Content-Type", "").startswith("application/json") else None
        except urllib.error.HTTPError as e:
            detalle = e.read()[:300].decode(errors="replace")
            if e.code < 500 and e.code != 429:
                raise RuntimeError(f"HTTP {e.code}: {detalle}")
            ultimo = f"HTTP {e.code}: {detalle}"
        except (urllib.error.URLError, ConnectionError, TimeoutError) as e:
            ultimo = str(e)
        time.sleep(0.5 * (2 ** intento))
    raise RuntimeError(f"sin exito tras {intentos} intentos: {ultimo}")


def bajar(url, intentos=4):
    ultimo = None
    for intento in range(intentos):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=60) as r:
                return r.read(), (r.headers.get("Content-Type") or "").split(";")[0].strip()
        except Exception as e:  # noqa: BLE001 - el CDN devuelve varios tipos de error
            ultimo = str(e)
            time.sleep(0.5 * (2 ** intento))
    raise RuntimeError(f"descarga fallida: {ultimo}")


def procesar(fila):
    fid, ean, pos, origen = fila["id"], fila["ean"], fila["posicion"], fila["url_origen"]
    try:
        blob, mime = bajar(origen)
        if mime not in EXT_POR_MIME:
            mime = "image/webp" if blob[:4] == b"RIFF" else "image/jpeg"
        ruta = f"{PREFIJO}/{ean}/{pos}.{EXT_POR_MIME[mime]}"
        supa("POST", f"object/{BUCKET}/{ruta}", raw=blob, content_type=mime,
             base="storage/v1", prefer="return=minimal", extra={"x-upsert": "true"})
        publica = f"{URL}/storage/v1/object/public/{BUCKET}/{ruta}"
        supa("PATCH", f"{TABLA}?id=eq.{fid}", {
            "storage_bucket": BUCKET,
            "storage_path": ruta,
            "url_storage": publica,
            "error_importacion": None,
            "fecha_importacion": datetime.now(timezone.utc).isoformat(),
        }, prefer="return=minimal")
        return True, fid, len(blob)
    except Exception as e:  # noqa: BLE001 - queremos registrar y seguir
        try:
            supa("PATCH", f"{TABLA}?id=eq.{fid}",
                 {"error_importacion": str(e)[:400]}, prefer="return=minimal")
        except Exception:  # noqa: BLE001
            pass
        return False, fid, str(e)[:120]


def main():
    flags = {a for a in sys.argv[1:] if a.startswith("--")}
    limite = None
    global HILOS
    for a in sys.argv[1:]:
        if a.startswith("--limite"):
            limite = int(a.split("=")[1])
        if a.startswith("--hilos"):
            HILOS = int(a.split("=")[1])

    filtro = "url_storage=is.null"
    if "--reintentar" in flags:
        filtro = "url_storage=is.null"
    tope = f"&limit={limite}" if limite else "&limit=5000"
    filas = supa("GET", f"{TABLA}?select=id,ean,posicion,url_origen&{filtro}&order=id{tope}")
    print(f"pendientes: {len(filas)}", flush=True)
    if not filas:
        return

    ok = err = bytes_tot = 0
    fallos = []
    with ThreadPoolExecutor(max_workers=HILOS) as ex:
        futs = [ex.submit(procesar, f) for f in filas]
        for fut in as_completed(futs):
            exito, fid, info = fut.result()
            with LOCK:
                if exito:
                    ok += 1
                    bytes_tot += info
                else:
                    err += 1
                    fallos.append((fid, info))
                if (ok + err) % 100 == 0:
                    print(f"  {ok + err}/{len(filas)} — ok {ok}, fallos {err}", flush=True)

    print(f"\nsubidas: {ok} | fallos: {err} | {bytes_tot / 1_048_576:.1f} MB")
    for fid, motivo in fallos[:20]:
        print(f"  id {fid}: {motivo}")


if __name__ == "__main__":
    main()
