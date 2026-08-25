#!/usr/bin/env python3
"""Cruza el catálogo vivo con Open Food / Beauty / Products Facts.

Solo lectura + escritura local. No sube a Storage ni toca Supabase.
Uso: python3 scripts/buscar_fotos_openfacts.py
"""
from __future__ import annotations

import json
import re
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_CSV = ROOT / "sql" / "generated" / "fotos_openfacts_20260818.csv"
OUT_JSON = ROOT / "sql" / "generated" / "fotos_openfacts_20260818.json"
PROGRESS = ROOT / "sql" / "generated" / "fotos_openfacts_progress.json"

UA = "FarmaCapitalCatalog/1.0 (EAN photo match for own inventory; polite 1 req/product)"
STOP = {
    "para", "caja", "con", "tabletas", "tableta", "capsulas", "capsula",
    "crema", "solucion", "jarabe", "frasco", "unguento", "pieza", "piezas",
    "adulto", "infantil", "sabor", "mg", "ml", "tab", "cap",
}


def load_env():
    env = {}
    for line in (ROOT / ".env").read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, _, v = line.partition("=")
        env[k.strip()] = v.strip()
    return env


def digits(s: str) -> str:
    return "".join(c for c in (s or "") if c.isdigit())


def pad13(ean: str) -> str:
    e = digits(ean)
    if 8 <= len(e) < 13:
        return e.zfill(13)
    return e


def fold(s: str) -> str:
    s = unicodedata.normalize("NFKD", s or "")
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = s.lower()
    return re.sub(r"[^a-z0-9]+", " ", s)


def tokens(s: str) -> set[str]:
    return {t for t in fold(s).split() if len(t) >= 4 and t not in STOP}


def name_status(ours: str, theirs: str) -> str:
    if not theirs:
        return "sin_nombre_off"
    a, b = tokens(ours), tokens(theirs)
    if not a or not b:
        # fallback: first 5-char prefix
        of, tf = fold(ours), fold(theirs)
        if of[:6] and of[:6] in tf:
            return "coincide"
        return "revisar_nombre"
    inter = a & b
    if inter:
        return "coincide"
    # one token is prefix of the other (pantene / pantenes)
    for x in a:
        if any(y.startswith(x) or x.startswith(y) for y in b if len(y) >= 5):
            return "coincide"
    return "revisar_nombre"


def fetch_json(url: str):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            return json.loads(r.read().decode()), None
    except urllib.error.HTTPError as e:
        return None, f"http {e.code}"
    except Exception as e:
        return None, str(e)[:120]


def lookup(ean: str, host: str):
    url = f"https://{host}/api/v2/product/{urllib.parse.quote(ean)}.json?fields=code,product_name,generic_name,brands,image_front_url,image_url,image_front_small_url"
    data, err = fetch_json(url)
    if err or not data:
        return None, err
    if data.get("status") != 1:
        return None, None
    p = data.get("product") or {}
    img = p.get("image_front_url") or p.get("image_url") or p.get("image_front_small_url")
    if not img:
        return None, None
    return {
        "host": host,
        "off_name": p.get("product_name") or p.get("generic_name") or "",
        "brands": p.get("brands") or "",
        "img": img,
        "code": str(p.get("code") or ean),
    }, None


def pick_hosts(categoria: str):
    cat = (categoria or "").lower()
    if cat in {"higiene", "cuidado personal"}:
        return [
            "world.openbeautyfacts.org",
            "world.openfoodfacts.org",
            "world.openproductsfacts.org",
        ]
    if cat in {"bebidas", "suplemento", "vitaminas"}:
        return [
            "world.openfoodfacts.org",
            "world.openbeautyfacts.org",
            "world.openproductsfacts.org",
        ]
    return [
        "world.openfoodfacts.org",
        "world.openproductsfacts.org",
        "world.openbeautyfacts.org",
    ]


def src_label(host: str) -> str:
    if "beauty" in host:
        return "openbeautyfacts"
    if "products" in host:
        return "openproductsfacts"
    return "openfoodfacts"


def main():
    env = load_env()
    url = env["REACT_APP_SUPABASE_URL"].rstrip("/")
    key = env["REACT_APP_SUPABASE_ANON_KEY"]
    rows = []
    start = 0
    while True:
        req = urllib.request.Request(
            url + "/rest/v1/productos?select=id,sku,nombre,marca,categoria,codigo_barras&activo=eq.true&order=id.asc",
            headers={
                "apikey": key,
                "Authorization": f"Bearer {key}",
                "Range": f"{start}-{start + 999}",
                "Prefer": "count=exact",
            },
        )
        with urllib.request.urlopen(req, timeout=45) as r:
            chunk = json.loads(r.read().decode())
        rows.extend(chunk)
        if len(chunk) < 1000:
            break
        start += 1000

    catalog = []
    for p in rows:
        ean = digits(p.get("codigo_barras"))
        if len(ean) < 8:
            continue
        catalog.append(p | {"ean": ean})

    done = {}
    if PROGRESS.exists():
        try:
            done = json.loads(PROGRESS.read_text())
        except Exception:
            done = {}

    print(f"catalogo {len(rows)} con_ean {len(catalog)} ya_hechos {len(done)}", flush=True)

    results = list(done.values()) if done else []
    n_ok = 0
    for i, p in enumerate(catalog, 1):
        keyp = p["ean"]
        if keyp in done:
            continue
        hit = None
        last_err = None
        tried = []
        for host in pick_hosts(p.get("categoria")):
            for code in dict.fromkeys([p["ean"], pad13(p["ean"])]):
                if code in tried:
                    continue
                tried.append(code)
                hit, last_err = lookup(code, host)
                time.sleep(0.18)
                if hit:
                    hit["src"] = src_label(host)
                    hit["ean_consultado"] = code
                    break
            if hit:
                break
        if hit:
            match = name_status(p.get("nombre") or "", hit["off_name"])
            rec = {
                "estado": "HIT" if match == "coincide" else "REVISAR",
                "match": match,
                "sku": p.get("sku"),
                "nombre": p.get("nombre"),
                "marca": p.get("marca"),
                "categoria": p.get("categoria"),
                "ean": p["ean"],
                "src": hit["src"],
                "off_name": hit["off_name"],
                "brands": hit["brands"],
                "img": hit["img"],
            }
        else:
            rec = {
                "estado": "MISS",
                "match": last_err or "no_esta",
                "sku": p.get("sku"),
                "nombre": p.get("nombre"),
                "marca": p.get("marca"),
                "categoria": p.get("categoria"),
                "ean": p["ean"],
                "src": "",
                "off_name": "",
                "brands": "",
                "img": "",
            }
        done[keyp] = rec
        results.append(rec)
        if rec["estado"] != "MISS":
            n_ok += 1
        if i % 25 == 0:
            PROGRESS.write_text(json.dumps(done, ensure_ascii=False))
            print(f"  {i}/{len(catalog)} hits+revisar={sum(1 for r in done.values() if r['estado']!='MISS')}", flush=True)

    PROGRESS.write_text(json.dumps(done, ensure_ascii=False))

    hits = [r for r in done.values() if r["estado"] == "HIT"]
    revisar = [r for r in done.values() if r["estado"] == "REVISAR"]
    miss = [r for r in done.values() if r["estado"] == "MISS"]

    cols = ["estado", "match", "sku", "nombre", "marca", "categoria", "ean", "src", "off_name", "brands", "img"]
    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    lines = [",".join(cols)]
    for r in sorted(done.values(), key=lambda x: (x["estado"], x.get("nombre") or "")):
        def q(v):
            s = str(v or "").replace('"', '""')
            return f'"{s}"'
        lines.append(",".join(q(r.get(c)) for c in cols))
    OUT_CSV.write_text("\n".join(lines) + "\n", encoding="utf-8")

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "total_con_ean": len(catalog),
        "hit": len(hits),
        "revisar": len(revisar),
        "miss": len(miss),
        "por_fuente": dict(Counter(r["src"] for r in hits + revisar if r.get("src"))),
        "hits": hits,
        "revisar": revisar,
    }
    OUT_JSON.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    print("\nRESUMEN", flush=True)
    print("HIT", len(hits), "REVISAR", len(revisar), "MISS", len(miss), flush=True)
    print("fuentes", payload["por_fuente"], flush=True)
    print("CSV", OUT_CSV, flush=True)


if __name__ == "__main__":
    main()
