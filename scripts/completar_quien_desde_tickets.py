#!/usr/bin/env python3
"""Completa el quién de ultima_compra desde los CSV de tickets originales.

No sube el costo vigente. No pisa un proveedor que ya esté puesto.
"""
from __future__ import annotations

import csv
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from collections import defaultdict
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GEN = ROOT / "sql" / "generated"


def cargar_env() -> dict[str, str]:
    out: dict[str, str] = {}
    env_path = ROOT / ".env"
    if env_path.exists():
        for line in env_path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, _, v = line.partition("=")
            out[k.strip()] = v.strip().strip('"').strip("'")
    out.update({k: v for k, v in os.environ.items() if v})
    return out


def norm_prov(nombre: str) -> str:
    n = (nombre or "").strip()
    if not n or re.match(r"^sin proveedor$", n, re.I):
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


def digits(s: str) -> str:
    return re.sub(r"\D", "", str(s or ""))


def prov_desde_archivo(name: str) -> str:
    n = name.lower()
    if "cityfarma" in n or "farma_city" in n:
        return "Farma City"
    if "farmalive" in n:
        return "Farmalive"
    if "levic" in n:
        return "Levic"
    if "surtidor" in n:
        return "El Surtidor"
    if "bodega" in n or "f42" in n or "f-42" in n:
        return "Bodega F-42"
    if "equilibrio" in n:
        return "Equilibrio"
    if "farmamx" in n or "farma_mx" in n:
        return "Farma MX"
    if "ifc" in n:
        return "IFC"
    return ""


def rest(url: str, key: str, path: str, method: str = "GET", body=None, extra=None):
    data = None if body is None else json.dumps(body).encode()
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        **(extra or {}),
    }
    req = urllib.request.Request(f"{url}/rest/v1/{path}", data=data, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=120) as r:
        raw = r.read().decode()
        return json.loads(raw) if raw else None


def fetch_all(url: str, key: str, table: str, select: str, extra: str = "") -> list[dict]:
    rows: list[dict] = []
    offset = 0
    while True:
        q = f"{table}?select={select}"
        if extra:
            q += f"&{extra}"
        q += f"&limit=1000&offset={offset}"
        batch = rest(url, key, q) or []
        rows.extend(batch)
        if len(batch) < 1000:
            break
        offset += 1000
    return rows


def leer_csv(path: Path) -> list[dict]:
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def eventos_desde_archivos() -> list[dict]:
    out: list[dict] = []
    for path in sorted(GEN.glob("import_inventario_*.csv")):
        quien = prov_desde_archivo(path.name)
        for row in leer_csv(path):
            quien_row = norm_prov(row.get("Proveedor") or quien)
            if not quien_row:
                continue
            out.append({
                "sku": (row.get("SKU") or "").strip(),
                "ean": digits(row.get("Codigo_Barras") or ""),
                "proveedor": quien_row,
                "origen": path.name,
            })
    for path in sorted(GEN.glob("ticket_*.csv")):
        quien = prov_desde_archivo(path.name)
        for row in leer_csv(path):
            quien_row = norm_prov(row.get("proveedor") or quien)
            if not quien_row:
                continue
            sku = (row.get("sku_farmacapital") or row.get("sku") or "").strip()
            ean = digits(row.get("ean") or row.get("ean_ticket") or "")
            if not sku and not ean:
                continue
            out.append({"sku": sku, "ean": ean, "proveedor": quien_row, "origen": path.name})
    for path in sorted(GEN.glob("comparacion_*.csv")):
        quien = prov_desde_archivo(path.name)
        if not quien:
            continue
        for row in leer_csv(path):
            estado = (row.get("estado") or "").strip().lower()
            sku = (row.get("sku") or "").strip()
            ean = digits(row.get("ean_bd") or row.get("ean_ticket") or "")
            if not sku:
                continue
            if estado in {"falta", "ean_duplicado_en_bd"}:
                continue
            out.append({"sku": sku, "ean": ean, "proveedor": quien, "origen": path.name})
    return out


def main() -> int:
    aplicar = "--aplicar" in sys.argv
    env = cargar_env()
    url = env.get("REACT_APP_SUPABASE_URL") or env.get("SUPABASE_URL") or ""
    key = env.get("SUPABASE_SERVICE_ROLE_KEY") or ""
    if not url or not key:
        sys.exit("Falta URL/key de Supabase")

    eventos = eventos_desde_archivos()
    productos = fetch_all(url, key, "productos", "id,sku,codigo_barras,costo,activo")
    vigs = fetch_all(
        url, key, "producto_precios_referencia_actual",
        "producto_id,precio,nombre_fuente,fecha,notas",
        "fuente=eq.ultima_compra",
    )
    vig_by = {v["producto_id"]: v for v in vigs}

    by_sku: dict[str, list[dict]] = defaultdict(list)
    by_ean: dict[str, list[dict]] = defaultdict(list)
    for p in productos:
        if p.get("sku"):
            by_sku[str(p["sku"]).strip().upper()].append(p)
        ean = digits(p.get("codigo_barras") or "")
        if len(ean) >= 8:
            by_ean[ean].append(p)
            if len(ean) == 13:
                by_ean[ean[1:]].append(p)

    def match_prod(ev: dict) -> dict | None:
        sku = (ev.get("sku") or "").strip().upper()
        if sku and sku in by_sku and len(by_sku[sku]) == 1:
            return by_sku[sku][0]
        ean = ev.get("ean") or ""
        if len(ean) >= 8:
            hits = by_ean.get(ean) or []
            uniq = {h["id"]: h for h in hits}
            if len(uniq) == 1:
                return next(iter(uniq.values()))
            if len(ean) >= 12:
                hits12 = by_ean.get(ean[-12:]) or []
                uniq12 = {h["id"]: h for h in hits12}
                if len(uniq12) == 1:
                    return next(iter(uniq12.values()))
        return None

    # producto_id -> primer proveedor de ticket
    quien_por_prod: dict[int, dict] = {}
    sin_match = 0
    for ev in eventos:
        p = match_prod(ev)
        if not p:
            sin_match += 1
            continue
        pid = p["id"]
        if pid in quien_por_prod:
            continue
        quien_por_prod[pid] = ev

    hoy = date.today().isoformat()
    filas = []
    ya_tenian = 0
    for pid, ev in quien_por_prod.items():
        actual = vig_by.get(pid)
        quien_act = norm_prov((actual or {}).get("nombre_fuente") or "")
        if quien_act:
            ya_tenian += 1
            continue
        precio = None
        if actual and actual.get("precio"):
            try:
                precio = float(actual["precio"])
            except (TypeError, ValueError):
                precio = None
        if not precio:
            prod = next((x for x in productos if x["id"] == pid), None)
            try:
                precio = float((prod or {}).get("costo") or 0)
            except (TypeError, ValueError):
                precio = 0
        if not precio or precio <= 0:
            continue
        filas.append({
            "producto_id": pid,
            "fuente": "ultima_compra",
            "tipo": "compra",
            "precio": round(precio, 2),
            "fecha": hoy,
            "nombre_fuente": ev["proveedor"],
            "confianza": 100,
            "origen": "manual",
            "notas": f"ticket {ev['origen']} · completar quien",
        })

    print(f"Eventos en CSV: {len(eventos)}")
    print(f"Productos matcheados: {len(quien_por_prod)}  (filas CSV sin match único: {sin_match})")
    print(f"Ya tenían quién: {ya_tenian}")
    print(f"A completar: {len(filas)}")
    from collections import Counter
    print("  por proveedor:", Counter(f["nombre_fuente"] for f in filas).most_common())
    if not aplicar:
        print("Dry-run. Corre con --aplicar para escribir.")
        return 0

    n = 0
    for i in range(0, len(filas), 80):
        chunk = filas[i : i + 80]
        rest(
            url, key, "producto_precios_referencia",
            method="POST",
            body=chunk,
            extra={"Prefer": "return=minimal"},
        )
        n += len(chunk)
        print(f"  Insertadas {n}/{len(filas)}")
        time.sleep(0.12)

    # lotes.proveedor_id vacíos de esos productos
    provs = {row["nombre"]: row["id"] for row in fetch_all(url, key, "proveedores", "id,nombre")}
    id_por_norm = {norm_prov(n): i for n, i in provs.items()}
    lotes = fetch_all(url, key, "lotes", "id,producto_id,proveedor_id")
    patch_ids_by_prov: dict[int, list[int]] = defaultdict(list)
    pids_ok = {f["producto_id"] for f in filas}
    quien_f = {f["producto_id"]: f["nombre_fuente"] for f in filas}
    for l in lotes:
        if l.get("proveedor_id") or l["producto_id"] not in pids_ok:
            continue
        pid_prov = id_por_norm.get(quien_f[l["producto_id"]])
        if pid_prov:
            patch_ids_by_prov[pid_prov].append(l["id"])
    lotes_n = 0
    for proveedor_id, ids in patch_ids_by_prov.items():
        for i in range(0, len(ids), 80):
            chunk = ids[i : i + 80]
            in_list = ",".join(str(x) for x in chunk)
            rest(
                url, key,
                f"lotes?id=in.({in_list})",
                method="PATCH",
                body={"proveedor_id": proveedor_id},
                extra={"Prefer": "return=minimal"},
            )
            lotes_n += len(chunk)
            time.sleep(0.08)
    print(f"Lotes con proveedor_id: {lotes_n}")
    print("Listo.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except urllib.error.HTTPError as e:
        print(e.read().decode()[:500], file=sys.stderr)
        raise
