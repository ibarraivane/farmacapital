#!/usr/bin/env python3
"""Restaura las 462 referencias que Claude capturó ficha por ficha.

No filtra por alta/media/dudoso. Solo inserta las que falten (sku+fuente).
No pisa precios que ya estén en vivo.
"""
from __future__ import annotations

import csv
from collections import Counter
from datetime import date
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parents[1]
CSV = Path("/Users/ibarra/Downloads/referencias_venta_final_462_20260815.csv")
CONF = {"alta": 90, "media": 75, "dudoso": 60}


def load_env():
    env = {}
    for line in (ROOT / ".env").read_text().splitlines():
        if "=" in line and not line.strip().startswith("#"):
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip().strip('"').strip("'")
    return env


def fetch(url, key, table, select):
    h = {"apikey": key, "Authorization": f"Bearer {key}"}
    out, off = [], 0
    while True:
        r = requests.get(
            f"{url}/rest/v1/{table}",
            headers={**h, "Range": f"{off}-{off + 999}"},
            params={"select": select},
            timeout=60,
        )
        r.raise_for_status()
        batch = r.json()
        out.extend(batch)
        if len(batch) < 1000:
            break
        off += 1000
    return out


def map_fuente(raw: str) -> str:
    s = (raw or "").strip().lower()
    if s.startswith("similares"):
        return "similares"
    if "ahorro" in s or s.startswith("fahorro"):
        return "fahorro"
    return "otros_venta"


def main() -> int:
    env = load_env()
    url = env["REACT_APP_SUPABASE_URL"].rstrip("/")
    anon = env["REACT_APP_SUPABASE_ANON_KEY"]

    prods = fetch(url, anon, "productos", "id,sku,nombre")
    refs = fetch(url, anon, "producto_precios_referencia", "id,producto_id,fuente,tipo,precio,notas")
    id_by_sku = {p["sku"]: p["id"] for p in prods}
    sku_by_id = {p["id"]: p["sku"] for p in prods}

    vivos = {}
    for r in refs:
        if r.get("tipo") != "venta":
            continue
        if (r.get("notas") or "") == "__anulado__":
            continue
        sku = sku_by_id.get(r["producto_id"])
        if sku:
            vivos[(sku, r["fuente"])] = float(r["precio"])

    with CSV.open(newline="", encoding="utf-8-sig") as f:
        rows = list(csv.DictReader(f))

    cand = {}
    for row in rows:
        sku = (row.get("sku") or "").strip()
        try:
            precio = float(row["precio"])
        except (TypeError, ValueError):
            continue
        if precio <= 0:
            continue
        fuente = map_fuente(row.get("fuente"))
        conf = CONF.get((row.get("confianza_match") or "").strip().lower(), 70)
        notas = (row.get("notas") or "").strip()
        if not notas.startswith("Claude "):
            notas = f"Claude 20260815 · {notas}"
        rec = {
            "sku": sku,
            "fuente": fuente,
            "precio": round(precio, 2),
            "confianza": conf,
            "notas": notas[:500],
            "origen_csv": (row.get("fuente") or "").strip(),
            "etiqueta": (row.get("confianza_match") or "").strip(),
        }
        prev = cand.get((sku, fuente))
        if prev is None or rec["confianza"] > prev["confianza"]:
            cand[(sku, fuente)] = rec

    faltan, ya_igual, ya_distinto, sin_sku = [], 0, [], 0
    for par, rec in cand.items():
        pid = id_by_sku.get(rec["sku"])
        if not pid:
            sin_sku += 1
            continue
        rec["producto_id"] = pid
        if par in vivos:
            if abs(vivos[par] - rec["precio"]) < 0.02:
                ya_igual += 1
            else:
                rec["precio_vivo"] = vivos[par]
                ya_distinto.append(rec)
            continue
        faltan.append(rec)

    print(f"CSV {len(rows)} → únicos sku+fuente {len(cand)}")
    print(f"sin SKU en catálogo {sin_sku}")
    print(f"ya en vivo mismo precio {ya_igual}")
    print(f"ya en vivo otro precio {len(ya_distinto)}")
    print(f"FALTAN {len(faltan)} {dict(Counter(r['fuente'] for r in faltan))}")
    print(f"faltan por etiqueta {dict(Counter(r['etiqueta'] for r in faltan))}")
    for r in ya_distinto[:8]:
        print(f"  distinto {r['sku']} {r['fuente']} csv={r['precio']} vivo={r['precio_vivo']}")

    out = ROOT / "pricing/importados/restaurar_claude_462_faltantes.csv"
    with out.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(
            f,
            fieldnames=["sku", "producto_id", "fuente", "precio", "confianza", "etiqueta", "origen_csv", "notas"],
        )
        w.writeheader()
        for r in sorted(faltan, key=lambda x: (x["fuente"], x["sku"])):
            w.writerow({k: r[k] for k in w.fieldnames})
    print(f"CSV → {out}")

    headers = {
        "apikey": anon,
        "Authorization": f"Bearer {anon}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    }
    payload = [
        {
            "producto_id": r["producto_id"],
            "fuente": r["fuente"],
            "tipo": "venta",
            "precio": r["precio"],
            "fecha": date.today().isoformat(),
            "origen": "manual",
            "confianza": r["confianza"],
            "notas": r["notas"],
        }
        for r in faltan
    ]
    hechos = 0
    for i in range(0, len(payload), 80):
        chunk = payload[i : i + 80]
        resp = requests.post(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=headers,
            json=chunk,
            timeout=120,
        )
        if resp.status_code >= 400:
            print("ERROR", resp.status_code, resp.text[:400])
            resp.raise_for_status()
        hechos += len(chunk)
        print(f"insertados {hechos}/{len(payload)}")
    print(f"OK restauradas {hechos}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
