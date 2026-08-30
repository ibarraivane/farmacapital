#!/usr/bin/env python3
"""Packshots oficiales de jaloma.com.mx para SKUs confirmados.

No adivina ni cruza marcas. La lista curada está en
sql/generated/jaloma_fotos_confirmadas_20260830.csv: solo entra un renglón
si el nombre y la presentación coinciden con la ficha de Jaloma (o el EAN
está documentado como esa presentación).

Uso:
    python3 scripts/cargar_imagenes_oficiales_jaloma.py --check
    python3 scripts/cargar_imagenes_oficiales_jaloma.py --aplicar
        # necesita SUPABASE_SERVICE_ROLE_KEY en .env
"""
from __future__ import annotations

import argparse
import csv
import json
import ssl
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CURADAS = ROOT / "sql/generated/jaloma_fotos_confirmadas_20260830.csv"
UA = "FarmaCapitalCatalog/1.0 (fotos oficiales Jaloma)"
CTX = ssl.create_default_context()


def load_env():
    vals = {}
    for name in (".env", ".env.local"):
        path = ROOT / name
        if not path.exists():
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, _, v = line.partition("=")
            vals.setdefault(k.strip(), v.strip().strip('"').strip("'"))
    return vals


def filas_curadas():
    with CURADAS.open(encoding="utf-8", newline="") as fh:
        return list(csv.DictReader(fh))


def foto_ok(url: str) -> tuple[int, str]:
    """Jaloma a veces responde 429 a HEAD; el GET sí entrega el PNG."""
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    try:
        with urllib.request.urlopen(req, context=CTX, timeout=30) as r:
            magic = r.read(16)
            ctype = r.headers.get("Content-Type", "")
            if magic.startswith(b"\x89PNG") or magic.startswith(b"\xff\xd8\xff") or magic.startswith(b"RIFF"):
                return r.status, ctype or "image/*"
            return r.status, ctype
    except urllib.error.HTTPError as e:
        return e.code, ""
    except urllib.error.URLError as e:
        return 0, str(e)


def check():
    filas = filas_curadas()
    if len(filas) != 5:
        raise SystemExit(f"se esperaban 5 matches curados, hay {len(filas)}")
    fallos = []
    for row in filas:
        if "jaloma.com.mx" not in row["permalink"] or "jaloma.com.mx" not in row["foto"]:
            fallos.append(f"{row['sku']}: URL no es jaloma.com.mx")
            continue
        code, ctype = foto_ok(row["foto"])
        if code != 200 or "image/" not in (ctype or ""):
            fallos.append(f"{row['sku']}: foto HTTP {code} {ctype} {row['foto']}")
            print(f"FAIL {row['sku']}  {row['oficial']}  {code} {ctype}")
            continue
        print(f"OK  {row['sku']}  {row['oficial']}  {code} {ctype}")
        time.sleep(0.4)
    if fallos:
        raise SystemExit("fallos:\n  " + "\n  ".join(fallos))
    print(f"{len(filas)} packshots oficiales vivos")


def rest(base, key, method, path, body=None, extra=None):
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "User-Agent": UA,
    }
    if extra:
        headers.update(extra)
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(base + path, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, context=CTX, timeout=60) as r:
            raw = r.read()
            return r.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as e:
        detalle = e.read()[:400].decode(errors="replace")
        raise SystemExit(f"{method} {path} HTTP {e.code}: {detalle}")


def aplicar():
    env = load_env()
    base = (env.get("REACT_APP_SUPABASE_URL") or env.get("SUPABASE_URL") or "").rstrip("/")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY") or ""
    if not base or not key:
        raise SystemExit(
            "falta SUPABASE_SERVICE_ROLE_KEY en .env. "
            "Mientras tanto corre sql/patch_fotos_jaloma_oficial_20260830.sql "
            "en el editor SQL de Supabase."
        )
    for row in filas_curadas():
        pid = int(row["producto_id"])
        sku = row["sku"]
        foto = row["foto"]
        status, actual = rest(
            base, key, "GET",
            f"/rest/v1/productos?select=id,sku,imagen_url&id=eq.{pid}&sku=eq.{sku}",
        )
        if not actual:
            raise SystemExit(f"no está el SKU {sku} id={pid}")
        if not (actual[0].get("imagen_url") or "").strip():
            rest(
                base, key, "PATCH",
                f"/rest/v1/productos?id=eq.{pid}&sku=eq.{sku}",
                {"imagen_url": foto, "imagen_mobile_url": foto},
                extra={"Prefer": "return=minimal"},
            )
            print(f"imagen_url  {sku}")
        else:
            print(f"imagen_url ya tenía foto  {sku} — no pisa")
        _, gal = rest(
            base, key, "GET",
            f"/rest/v1/producto_imagenes?select=id,url,posicion,es_principal&producto_id=eq.{pid}",
        )
        gal = gal or []
        ya = next((g for g in gal if g.get("url") == foto), None)
        if not ya:
            ocupadas = {int(g["posicion"]) for g in gal if g.get("posicion") is not None}
            pos = 0 if 0 not in ocupadas else (max(ocupadas) + 1 if ocupadas else 0)
            rest(
                base, key, "POST",
                "/rest/v1/producto_imagenes",
                {
                    "producto_id": pid,
                    "url": foto,
                    "posicion": pos,
                    "es_principal": False,
                    "origen": "distribuidor",
                },
                extra={"Prefer": "return=minimal"},
            )
            _, gal = rest(
                base, key, "GET",
                f"/rest/v1/producto_imagenes?select=id,url,posicion,es_principal&producto_id=eq.{pid}",
            )
            gal = gal or []
        for g in gal:
            if g.get("url") != foto and g.get("es_principal"):
                rest(
                    base, key, "PATCH",
                    f"/rest/v1/producto_imagenes?id=eq.{g['id']}",
                    {"es_principal": False},
                    extra={"Prefer": "return=minimal"},
                )
        for g in gal:
            if g.get("url") == foto and not g.get("es_principal"):
                rest(
                    base, key, "PATCH",
                    f"/rest/v1/producto_imagenes?id=eq.{g['id']}",
                    {"es_principal": True},
                    extra={"Prefer": "return=minimal"},
                )
        print(f"galería     {sku}  {row['oficial']}")
        time.sleep(0.15)
    print("listo")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="HEAD a las URLs oficiales")
    parser.add_argument("--aplicar", action="store_true", help="pega en Supabase (service role)")
    args = parser.parse_args()
    if args.check:
        check()
        return
    if args.aplicar:
        aplicar()
        return
    parser.print_help()
    sys.exit(2)


if __name__ == "__main__":
    main()
