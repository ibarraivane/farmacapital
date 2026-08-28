#!/usr/bin/env python3
"""Sube packshots aprobados al bucket `productos` y pega imagen_url en la tabla.

Usa REACT_APP_SUPABASE_* del .env. El PATCH de productos requiere
SUPABASE_SERVICE_ROLE_KEY (si no está, las fotos quedan en Storage y se escribe
un SQL para pegar en el editor).
"""
from __future__ import annotations

import csv
import json
import ssl
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path("/Users/ibarra/farmacapital")
BASE = ROOT / "catalogo-imagenes"
APROBADAS = BASE / "aprobadas"
V2 = BASE / "catalogo_imagenes_farmacapital_v2.csv"
MANIFEST = BASE / "_trabajo" / "carga_imagenes_supabase.json"
SQL_OUT = ROOT / "sql" / "generated" / "carga_imagenes_aprobadas_20260818.sql"

CTX = ssl.create_default_context()
UA = "FarmaCapitalCatalog/1.0"


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


def ean_key(e: str) -> str:
    e = (e or "").strip()
    if e.isdigit():
        return e.lstrip("0") or "0"
    return e


def rest(url, key, method, path, data=None, content_type="application/json", extra=None):
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "User-Agent": UA,
    }
    if content_type:
        headers["Content-Type"] = content_type
    if extra:
        headers.update(extra)
    body = data if isinstance(data, (bytes, bytearray)) else (None if data is None else json.dumps(data).encode())
    req = urllib.request.Request(url + path, data=body, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, context=CTX, timeout=90) as r:
            raw = r.read()
            return r.status, raw
    except urllib.error.HTTPError as e:
        return e.code, e.read()


def public_url(base, product_id):
    return f"{base}/storage/v1/object/public/productos/{product_id}/desktop.jpg"


def main():
    env = load_env()
    base = (env.get("REACT_APP_SUPABASE_URL") or env.get("SUPABASE_URL") or "").rstrip("/")
    anon = env.get("REACT_APP_SUPABASE_ANON_KEY") or env.get("SUPABASE_ANON_KEY") or ""
    service = env.get("SUPABASE_SERVICE_ROLE_KEY") or ""
    if service.startswith("[") or len(service) < 40:
        service = ""
    if not base or not anon:
        raise SystemExit("Faltan REACT_APP_SUPABASE_URL / REACT_APP_SUPABASE_ANON_KEY")

    status, raw = rest(
        base, anon, "GET",
        "/rest/v1/productos?select=id,sku,nombre,codigo_barras,imagen_url,imagen_mobile_url&limit=5000",
    )
    if status >= 400:
        raise SystemExit(f"No pude leer productos: {status} {raw[:300]!r}")
    productos = json.loads(raw)
    by_sku = {(p.get("sku") or "").strip(): p for p in productos if p.get("sku")}
    by_ean = {}
    for p in productos:
        k = ean_key(p.get("codigo_barras") or "")
        if k and k != "0":
            by_ean.setdefault(k, p)

    v2 = list(csv.DictReader(V2.open(encoding="utf-8")))
    jobs = []
    missing_file = []
    missing_prod = []
    skip_already = []
    for row in v2:
        if not (row.get("estado_v2") or "").startswith("APROBADA"):
            continue
        local = (row.get("archivo_local_v2") or "").strip()
        path = BASE / local if local else None
        if not path or not path.exists():
            ean = (row.get("codigo_barras") or "").strip()
            sku = row.get("sku") or ""
            cand = APROBADAS / f"{ean}.jpg" if ean else None
            alt = APROBADAS / f"{sku}.jpg"
            path = cand if cand and cand.exists() else (alt if alt.exists() else None)
        if not path or not path.exists():
            missing_file.append(row.get("sku"))
            continue
        prod = by_sku.get((row.get("sku") or "").strip()) or by_ean.get(ean_key(row.get("codigo_barras") or ""))
        if not prod:
            missing_prod.append(row.get("sku"))
            continue
        if (prod.get("imagen_url") or "").strip():
            skip_already.append(prod["sku"])
            continue
        jobs.append({"row": row, "path": path, "prod": prod})

    print(json.dumps({
        "aprobadas_csv": sum(1 for r in v2 if (r.get("estado_v2") or "").startswith("APROBADA")),
        "jobs": len(jobs),
        "missing_file": len(missing_file),
        "missing_prod": len(missing_prod),
        "skip_already": len(skip_already),
        "has_service_role": bool(service),
    }, ensure_ascii=False))

    def upload(job):
        pid = job["prod"]["id"]
        data = job["path"].read_bytes()
        object_path = f"/{pid}/desktop.jpg"
        st, raw = rest(
            base, anon, "POST",
            f"/storage/v1/object/productos{object_path}",
            data=data,
            content_type="image/jpeg",
            extra={"x-upsert": "true"},
        )
        # some gateways want PUT for upsert
        if st in (400, 409):
            st, raw = rest(
                base, anon, "PUT",
                f"/storage/v1/object/productos{object_path}",
                data=data,
                content_type="image/jpeg",
                extra={"x-upsert": "true"},
            )
        return job, st, raw

    patch_only = "--patch-only" in __import__("sys").argv
    uploaded = []
    failed = []
    t0 = time.time()
    if patch_only:
        prev = json.loads(MANIFEST.read_text(encoding="utf-8"))
        uploaded = prev.get("uploaded") or []
        print(f"patch-only: {len(uploaded)} urls from manifest")
    else:
        with ThreadPoolExecutor(12) as ex:
            futs = [ex.submit(upload, j) for j in jobs]
            for i, f in enumerate(as_completed(futs), 1):
                job, st, raw = f.result()
                rec = {
                    "id": job["prod"]["id"],
                    "sku": job["prod"].get("sku"),
                    "nombre": job["prod"].get("nombre"),
                    "url": public_url(base, job["prod"]["id"]),
                    "status": st,
                }
                if 200 <= st < 300:
                    uploaded.append(rec)
                else:
                    rec["error"] = raw[:180].decode("utf-8", "replace")
                    failed.append(rec)
                if i % 50 == 0 or i == len(jobs):
                    print(f"upload {i}/{len(jobs)} ok={len(uploaded)} fail={len(failed)}")

    patched = []
    patch_fail = []
    if service and uploaded:
        for rec in uploaded:
            payload = {"imagen_url": rec["url"], "imagen_mobile_url": rec["url"]}
            st, raw = rest(
                base, service, "PATCH",
                f"/rest/v1/productos?id=eq.{rec['id']}",
                data=payload,
                extra={"Prefer": "return=minimal"},
            )
            if 200 <= st < 300:
                patched.append(rec["id"])
            else:
                patch_fail.append({"id": rec["id"], "status": st, "error": raw[:180].decode("utf-8", "replace")})

    sql_lines = [
        "-- FarmaCapital: pegar imagen_url de packshots aprobados (oficiales + Levic).",
        "-- Inventario y tienda leen la misma columna. No toca precios ni stock.",
        "begin;",
        "",
    ]
    for rec in uploaded:
        url = rec["url"].replace("'", "''")
        sql_lines.append(
            f"update public.productos set imagen_url = '{url}', imagen_mobile_url = '{url}' "
            f"where id = {rec['id']} and coalesce(btrim(imagen_url), '') = '';"
        )
    sql_lines += ["", "commit;", ""]
    SQL_OUT.parent.mkdir(parents=True, exist_ok=True)
    SQL_OUT.write_text("\n".join(sql_lines), encoding="utf-8")

    summary = {
        "uploaded": len(uploaded),
        "upload_failed": len(failed),
        "patched": len(patched),
        "patch_failed": len(patch_fail),
        "missing_file": missing_file[:20],
        "missing_prod": missing_prod[:20],
        "sql": str(SQL_OUT),
        "seconds": round(time.time() - t0, 1),
        "fail_sample": failed[:8],
        "patch_fail_sample": patch_fail[:5],
    }
    MANIFEST.write_text(json.dumps({"summary": summary, "uploaded": uploaded}, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
