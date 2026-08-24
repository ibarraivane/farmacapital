#!/usr/bin/env python3
"""Rellena fuente ultima_compra desde tickets Recibir y, si falta, desde lotes."""
from __future__ import annotations

import os
import re
import sys
import time
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parents[1]


def cargar_env() -> dict[str, str]:
    out: dict[str, str] = {}
    for env_path in (ROOT / ".env", ROOT.parent / "farmacapital" / ".env", Path("/Users/ibarra/farmacapital/.env")):
        if not env_path.exists():
            continue
        for line in env_path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, _, v = line.partition("=")
            out[k.strip()] = v.strip().strip('"').strip("'")
        break
    out.update({k: v for k, v in os.environ.items() if v})
    return out


def norm_prov(nombre: str) -> str:
    n = (nombre or "").strip()
    if not n:
        return ""
    if re.search(r"cityfarma|farma\s*city", n, re.I):
        return "Farma City"
    if re.search(r"farmalive|farmalife", n, re.I):
        return "Farmalive"
    if re.search(r"^levic\b", n, re.I):
        return "Levic"
    if re.search(r"exprezo|zorro", n, re.I):
        return "Exprezo"
    if re.search(r"equilibrio", n, re.I):
        return "Equilibrio"
    if re.search(r"surtidor", n, re.I):
        return "El Surtidor"
    if re.search(r"bodega|f-?42", n, re.I):
        return "Bodega F-42"
    if re.search(r"\bifc\b", n, re.I):
        return "IFC"
    if re.search(r"farma\s*mx|farmamx", n, re.I):
        return "Farma MX"
    return n


def fetch_all(url: str, key: str, table: str, select: str, extra: str = "") -> list[dict]:
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    rows: list[dict] = []
    offset = 0
    while True:
        h = {**headers, "Range": f"{offset}-{offset + 499}"}
        q = f"select={select}"
        if extra:
            q += f"&{extra}"
        r = requests.get(f"{url}/rest/v1/{table}?{q}", headers=h, timeout=60)
        r.raise_for_status()
        batch = r.json()
        rows.extend(batch)
        if len(batch) < 500:
            break
        offset += 500
    return rows


def main() -> int:
    env = cargar_env()
    url = env.get("REACT_APP_SUPABASE_URL") or env.get("SUPABASE_URL") or ""
    key = env.get("SUPABASE_SERVICE_ROLE_KEY") or env.get("REACT_APP_SUPABASE_ANON_KEY") or ""
    if not url or not key:
        sys.exit("Falta URL/key de Supabase")

    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates,return=minimal",
    }
    r = requests.post(
        f"{url}/rest/v1/fuentes_precio",
        headers=headers,
        json=[{
            "id": "ultima_compra",
            "nombre": "Última compra",
            "tipo": "compra",
            "metodo": "manual",
            "notas": "Precio pagado en el último ticket de Recibir. No es lista.",
        }],
        timeout=30,
    )
    if not r.ok:
        sys.exit(f"fuentes_precio: {r.status_code} {r.text[:200]}")

    recs = {row["id"]: row for row in fetch_all(url, key, "recepciones", "id,proveedor,folio,fecha")}
    items = fetch_all(
        url, key, "recepcion_items",
        "id,recepcion_id,producto_id,costo_estimado,confirmado,pendiente_alta",
        "confirmado=eq.true&pendiente_alta=eq.false&producto_id=not.is.null",
    )
    provs = {row["id"]: row["nombre"] for row in fetch_all(url, key, "proveedores", "id,nombre")}
    lotes = fetch_all(
        url, key, "lotes",
        "id,producto_id,costo_unitario,proveedor_id,created_at",
        "costo_unitario=gt.0",
    )

    best: dict[int, dict] = {}
    for it in items:
        precio = it.get("costo_estimado")
        try:
            precio = float(precio)
        except (TypeError, ValueError):
            continue
        if precio <= 0:
            continue
        rec = recs.get(it["recepcion_id"]) or {}
        fecha = rec.get("fecha") or "1970-01-01"
        pid = it["producto_id"]
        prev = best.get(pid)
        if prev and (prev["fecha"], prev["_id"]) >= (fecha, it["id"]):
            continue
        best[pid] = {
            "producto_id": pid,
            "precio": round(precio, 2),
            "fecha": fecha,
            "nombre_fuente": norm_prov(rec.get("proveedor") or "") or rec.get("proveedor"),
            "sku_externo": rec.get("folio"),
            "notas": f"ticket {rec.get('folio')}" if rec.get("folio") else "recepcion",
            "_id": it["id"],
        }

    for lote in lotes:
        pid = lote["producto_id"]
        try:
            precio = float(lote["costo_unitario"])
        except (TypeError, ValueError):
            continue
        fecha = (lote.get("created_at") or "")[:10] or "1970-01-01"
        prev = best.get(pid)
        if prev and prev["fecha"] >= fecha:
            continue
        best[pid] = {
            "producto_id": pid,
            "precio": round(precio, 2),
            "fecha": fecha,
            "nombre_fuente": norm_prov(provs.get(lote.get("proveedor_id")) or "") or None,
            "sku_externo": None,
            "notas": "lote",
            "_id": lote["id"],
        }

    filas = []
    for row in best.values():
        if not row.get("nombre_fuente"):
            row["nombre_fuente"] = "Ticket"
        filas.append({
            "producto_id": row["producto_id"],
            "fuente": "ultima_compra",
            "tipo": "compra",
            "precio": row["precio"],
            "fecha": row["fecha"],
            "nombre_fuente": row["nombre_fuente"],
            "sku_externo": row.get("sku_externo"),
            "confianza": 100,
            "origen": "manual",
            "notas": row["notas"],
        })

    print(f"Productos con última compra: {len(filas)}")
    ins_headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    }
    n = 0
    for i in range(0, len(filas), 80):
        chunk = filas[i : i + 80]
        r = requests.post(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=ins_headers,
            json=chunk,
            timeout=120,
        )
        r.raise_for_status()
        n += len(chunk)
        print(f"  Insertadas {n}/{len(filas)}")
        time.sleep(0.12)
    print("Listo.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
