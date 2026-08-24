#!/usr/bin/env python3
"""Costo vigente = primera compra (quién + precio). Solo se pisa si otra bajó el precio."""
from __future__ import annotations

import os
import re
import sys
import time
from datetime import date
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parents[1]


def cargar_env() -> dict[str, str]:
    out: dict[str, str] = {}
    for env_path in (ROOT / ".env", Path("/Users/ibarra/farmacapital/.env")):
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


def mas_barato(actual, nuevo) -> bool:
    try:
        n = float(nuevo)
    except (TypeError, ValueError):
        return False
    if n <= 0:
        return False
    try:
        a = float(actual)
    except (TypeError, ValueError):
        return True
    if a <= 0:
        return True
    return n < a - 0.005


def elegir_vigente(eventos: list[dict]) -> dict | None:
    evs = []
    for e in eventos:
        try:
            precio = float(e["precio"])
        except (TypeError, ValueError):
            continue
        if precio <= 0:
            continue
        evs.append({
            "precio": precio,
            "proveedor": norm_prov(e.get("proveedor") or "") or (e.get("proveedor") or "").strip(),
            "fecha": e.get("fecha") or "",
            "id": e.get("id") or 0,
            "notas": e.get("notas") or "",
        })
    evs.sort(key=lambda x: (x["fecha"], x["id"]))
    if not evs:
        return None
    vigente = evs[0]
    for ev in evs[1:]:
        if mas_barato(vigente["precio"], ev["precio"]):
            vigente = ev
    return vigente


def main() -> int:
    env = cargar_env()
    url = env.get("REACT_APP_SUPABASE_URL") or env.get("SUPABASE_URL") or ""
    key = env.get("SUPABASE_SERVICE_ROLE_KEY") or ""
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
            "nombre": "Costo de compra",
            "tipo": "compra",
            "metodo": "manual",
            "notas": "Primera compra (quién + precio). Solo se pisa si Recibir trae uno más barato.",
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
    productos = fetch_all(url, key, "productos", "id,costo", "activo=eq.true")

    por_prod: dict[int, list[dict]] = {}
    for it in items:
        rec = recs.get(it["recepcion_id"]) or {}
        por_prod.setdefault(it["producto_id"], []).append({
            "id": it["id"],
            "precio": it.get("costo_estimado"),
            "proveedor": rec.get("proveedor"),
            "fecha": rec.get("fecha") or "",
            "notas": f"ticket {rec.get('folio')}" if rec.get("folio") else "recepcion",
        })
    for lote in lotes:
        por_prod.setdefault(lote["producto_id"], []).append({
            "id": lote["id"],
            "precio": lote.get("costo_unitario"),
            "proveedor": provs.get(lote.get("proveedor_id")),
            "fecha": (lote.get("created_at") or "")[:10],
            "notas": "lote",
        })
    for p in productos:
        if p["id"] in por_prod:
            continue
        if p.get("costo") is None:
            continue
        por_prod[p["id"]] = [{
            "id": 0,
            "precio": p.get("costo"),
            "proveedor": p.get("proveedor"),
            "fecha": "1970-01-01",
            "notas": "catalogo",
        }]

    hoy = date.today().isoformat()
    filas = []
    for pid, eventos in por_prod.items():
        vigente = elegir_vigente(eventos)
        if not vigente:
            continue
        if not vigente["proveedor"]:
            vigente["proveedor"] = ""
        filas.append({
            "producto_id": pid,
            "fuente": "ultima_compra",
            "tipo": "compra",
            "precio": round(vigente["precio"], 2),
            "fecha": hoy,
            "nombre_fuente": vigente["proveedor"] or "Sin proveedor",
            "confianza": 100,
            "origen": "manual",
            "notas": f"vigente {vigente['fecha']} · {vigente['notas']}",
        })

    print(f"Costos vigentes: {len(filas)}")
    ins = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    }
    n = 0
    for i in range(0, len(filas), 80):
        chunk = filas[i : i + 80]
        resp = requests.post(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=ins,
            json=chunk,
            timeout=120,
        )
        resp.raise_for_status()
        n += len(chunk)
        print(f"  Insertadas {n}/{len(filas)}")
        time.sleep(0.12)
    print("Listo.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
