#!/usr/bin/env python3
"""Exporta unidades vendidas por SKU (12 meses), sin clientes ni teléfonos.

Solo lectura. Requiere .env (anon key). Si RLS bloquea pedido_items,
el SELECT agregado puede devolver 0 — en ese caso corre el SQL del plan
en el SQL Editor y guarda el CSV a mano.

  python3 scripts/exportar_ventas_sku.py
"""
from __future__ import annotations

import csv
import os
import sys
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from pathlib import Path

try:
    import requests
except ImportError:
    sys.exit("Falta 'requests'. Instala con: pip install requests")

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "sql" / "historial"
MESES = 12
ESTADOS_EXCLUIDOS = {"cancelado", "anulado", "cancelled"}


def cargar_env() -> dict[str, str]:
    valores: dict[str, str] = {}
    path = ROOT / ".env"
    if path.exists():
        for linea in path.read_text(encoding="utf-8").splitlines():
            linea = linea.strip()
            if not linea or linea.startswith("#") or "=" not in linea:
                continue
            k, _, v = linea.partition("=")
            valores[k.strip()] = v.strip().strip('"').strip("'")
    valores.update({k: v for k, v in os.environ.items() if v})
    return valores


def fetch_all(url: str, key: str, table: str, select: str, extra: dict | None = None) -> list[dict]:
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    rows: list[dict] = []
    offset = 0
    while True:
        h = {**headers, "Range": f"{offset}-{offset + 999}"}
        params = {"select": select, "order": "id.asc"}
        if extra:
            params.update(extra)
        r = requests.get(f"{url.rstrip('/')}/rest/v1/{table}", headers=h, params=params, timeout=60)
        r.raise_for_status()
        chunk = r.json()
        rows.extend(chunk)
        if len(chunk) < 1000:
            break
        offset += 1000
    return rows


def main() -> None:
    env = cargar_env()
    url = env.get("REACT_APP_SUPABASE_URL")
    key = env.get("REACT_APP_SUPABASE_ANON_KEY")
    if not url or not key or "replace_me" in str(key):
        sys.exit(
            "Faltan REACT_APP_SUPABASE_URL / REACT_APP_SUPABASE_ANON_KEY.\n"
            "Alternativa segura: corre el SELECT agregado del plan en SQL Editor "
            "(sku, unidades, venta_mxn — sin clientes) y guarda el CSV."
        )

    desde = (datetime.now(timezone.utc) - timedelta(days=365)).isoformat()
    print("Leyendo pedidos (solo id, created_at, estado) ...")
    try:
        pedidos = fetch_all(
            url,
            key,
            "pedidos",
            "id,created_at,estado",
            {"created_at": f"gte.{desde}"},
        )
    except requests.HTTPError as e:
        sys.exit(f"No pude leer pedidos ({e}). Usa el SQL Editor y exporta CSV agregado.")

    ok_ids = {
        str(p["id"])
        for p in pedidos
        if str(p.get("estado") or "").lower() not in ESTADOS_EXCLUIDOS
    }
    print(f"Pedidos en ventana: {len(pedidos)}  válidos: {len(ok_ids)}")
    if not ok_ids:
        sys.exit("0 pedidos válidos en 12 meses. CSV no generado.")

    print("Leyendo pedido_items (producto_id, cantidad, precio) ...")
    try:
        items = fetch_all(
            url,
            key,
            "pedido_items",
            "id,pedido_id,producto_id,cantidad,precio_unitario",
        )
    except requests.HTTPError as e:
        sys.exit(f"No pude leer pedido_items ({e}). Usa el SQL Editor.")

    productos = {
        str(p["id"]): p
        for p in fetch_all(url, key, "productos", "id,sku,nombre")
    }

    agg: dict[str, dict] = defaultdict(lambda: {"unidades": 0.0, "venta_mxn": 0.0, "tickets": set()})
    for it in items:
        pid = str(it.get("pedido_id") or "")
        if pid not in ok_ids:
            continue
        prod = str(it.get("producto_id") or "")
        cant = float(it.get("cantidad") or 0)
        precio = float(it.get("precio_unitario") or 0)
        a = agg[prod]
        a["unidades"] += cant
        a["venta_mxn"] += cant * precio
        a["tickets"].add(pid)

    filas = []
    for prod_id, a in agg.items():
        meta = productos.get(prod_id, {})
        filas.append(
            {
                "producto_id": prod_id,
                "sku": meta.get("sku") or "",
                "nombre": meta.get("nombre") or "",
                "unidades": f"{a['unidades']:.2f}",
                "venta_mxn": f"{a['venta_mxn']:.2f}",
                "tickets": len(a["tickets"]),
            }
        )
    filas.sort(key=lambda r: -float(r["unidades"]))

    OUT.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d_%H%M")
    dest = OUT / f"ventas_sku_12m_{stamp}.csv"
    with dest.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=["producto_id", "sku", "nombre", "unidades", "venta_mxn", "tickets"],
        )
        w.writeheader()
        w.writerows(filas)
    print(f"OK {len(filas)} SKUs → {dest}")
    print("Este archivo no incluye clientes ni teléfonos.")


if __name__ == "__main__":
    main()
