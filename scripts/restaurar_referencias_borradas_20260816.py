#!/usr/bin/env python3
"""
Restaura referencias de venta borradas el 15-ago.

NO borra ni actualiza filas existentes. Solo inserta las que falten
(producto + fuente). Fuentes: backup UI del 14, CSVs de import, SQL Claude,
Excel de farmacias.

Uso:
  python3 scripts/restaurar_referencias_borradas_20260816.py
  python3 scripts/restaurar_referencias_borradas_20260816.py --apply
"""
from __future__ import annotations

import argparse
import csv
import importlib.util
import re
import sys
from collections import defaultdict
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

spec = importlib.util.spec_from_file_location(
    "resto_backup", ROOT / "scripts" / "restaurar_referencias_desde_backup.py"
)
resto = importlib.util.module_from_spec(spec)
spec.loader.exec_module(resto)

import requests  # noqa: E402

CONF = {"alta": 85, "media": 75, "dudoso": 60, "sin_dato": 0}
FUENTE_OK = {"similares", "fahorro", "otros_venta", "otros"}


def load_env():
    env = {}
    for line in (ROOT / ".env").read_text(encoding="utf-8").splitlines():
        if "=" in line and not line.strip().startswith("#"):
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip().strip('"').strip("'")
    return env


def fetch_all(url, key, table, select):
    h = {"apikey": key, "Authorization": f"Bearer {key}"}
    out = []
    offset = 0
    while True:
        r = requests.get(
            f"{url}/rest/v1/{table}",
            headers={**h, "Range": f"{offset}-{offset + 999}"},
            params={"select": select},
            timeout=60,
        )
        r.raise_for_status()
        batch = r.json()
        out.extend(batch)
        if len(batch) < 1000:
            break
        offset += 1000
    return out


def add(cand, sku, fuente, precio, confianza, notas, origen, prioridad):
    if not sku or precio is None:
        return
    try:
        precio = float(precio)
    except (TypeError, ValueError):
        return
    if precio <= 0:
        return
    fuente = "otros_venta" if fuente == "otros" else fuente
    if fuente not in ("similares", "fahorro", "otros_venta"):
        return
    key = (sku.strip(), fuente)
    prev = cand.get(key)
    row = {
        "sku": sku.strip(),
        "fuente": fuente,
        "precio": round(precio, 2),
        "confianza": int(confianza),
        "notas": (notas or "")[:500],
        "origen": origen,
        "prioridad": prioridad,
    }
    if prev is None or row["prioridad"] < prev["prioridad"]:
        cand[key] = row


def from_backup(cand, prods):
    text = (ROOT / "pricing/importados/backup_tabla_referencias_usuario_20260814.txt").read_text(
        encoding="utf-8"
    )
    parsed = resto.parse_backup(text)
    matched = 0
    for row in parsed:
        p = resto.match_product(row, prods)
        if not p:
            continue
        matched += 1
        if row.get("fahorro"):
            add(cand, p["sku"], "fahorro", row["fahorro"], 100, "Restaurado backup UI 2026-08-14", "manual", 1)
        if row.get("similares"):
            add(cand, p["sku"], "similares", row["similares"], 100, "Restaurado backup UI 2026-08-14", "manual", 1)
    print(f"  backup UI: {len(parsed)} filas, {matched} matcheadas a SKU")


def from_csv_simple(cand, path, fuente, origen, prioridad):
    p = Path(path)
    if not p.exists():
        return
    n = 0
    with p.open(newline="", encoding="utf-8-sig") as f:
        r = csv.DictReader(f)
        for row in r:
            sku = (row.get("sku") or "").strip()
            precio = row.get("precio") or row.get("precio_ref")
            add(cand, sku, fuente, precio, 90, f"Restaurado {p.name}", origen, prioridad)
            n += 1
    print(f"  {p.name}: {n} filas")


def from_consolidado(cand, path):
    p = Path(path)
    if not p.exists():
        return
    n = 0
    with p.open(newline="", encoding="utf-8-sig") as f:
        r = csv.DictReader(f)
        for row in r:
            sku = (row.get("sku") or "").strip()
            precio = row.get("precio")
            fuente = (row.get("fuente") or "similares").strip().lower()
            conf = CONF.get((row.get("confianza_match") or "").strip().lower(), 75)
            notas = row.get("notas") or f"Restaurado {p.name}"
            add(cand, sku, fuente, precio, conf, notas, "import_csv", 2)
            n += 1
    print(f"  {p.name}: {n} filas")


def from_excel(cand):
    p = ROOT / "pricing/reportes/excel_precios_2026-08-15.csv"
    if not p.exists():
        return
    n = 0
    with p.open(newline="", encoding="utf-8-sig") as f:
        r = csv.DictReader(f)
        for row in r:
            notas = f"excel:articulos_farmacias.xlsx | {row.get('razones') or ''} | {row.get('fila_excel') or ''}"
            add(
                cand,
                row.get("sku"),
                "similares",
                row.get("precio"),
                row.get("confianza") or 80,
                notas,
                "import_csv",
                3,
            )
            n += 1
    print(f"  {p.name}: {n} filas")


def from_claude_sql(cand):
    p = ROOT / "sql/pricing/generated/import_claude_referencias_alta_media_20260815.sql"
    text = p.read_text(encoding="utf-8")
    blocks = re.findall(
        r"SELECT p\.id, '([^']+)', 'venta', ([0-9.]+), CURRENT_DATE, 'manual', (\d+),\n"
        r"  '([^']*)', p\.nombre\nFROM public\.productos p\nWHERE p\.sku = '([^']+)'",
        text,
    )
    for fuente, precio, conf, notas, sku in blocks:
        add(cand, sku, fuente, precio, conf, notas, "manual", 2)
    print(f"  import_claude SQL: {len(blocks)} inserts")


def from_fahorro_sql(cand, sku_by_id):
    p = ROOT / "sql/pricing/generated/import_referencias_fahorro_20260814.sql"
    if not p.exists():
        return
    text = p.read_text(encoding="utf-8")
    rows = re.findall(
        r"\((\d+)::bigint, ([0-9.]+)::numeric, '([^']*)', (\d+)::smallint\)",
        text,
    )
    n = 0
    for pid, precio, nombre, conf in rows:
        sku = sku_by_id.get(int(pid))
        if not sku:
            continue
        add(cand, sku, "fahorro", precio, conf, f"Del Ahorro · {nombre}", "import_csv", 2)
        n += 1
    print(f"  import_fahorro SQL: {n} filas")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    args = ap.parse_args()

    env = load_env()
    url = env["REACT_APP_SUPABASE_URL"].rstrip("/")
    key = env["REACT_APP_SUPABASE_ANON_KEY"]

    productos = fetch_all(url, key, "productos", "id,sku,nombre,concentracion,presentacion,precio,principio_activo")
    refs = fetch_all(
        url, key, "producto_precios_referencia", "id,producto_id,fuente,tipo,precio,origen,notas"
    )
    sku_by_id = {p["id"]: p["sku"] for p in productos}
    id_by_sku = {p["sku"]: p["id"] for p in productos}

    actuales = set()
    for r in refs:
        if r.get("tipo") != "venta":
            continue
        if (r.get("notas") or "") == "__anulado__":
            continue
        sku = sku_by_id.get(r["producto_id"])
        if sku:
            actuales.add((sku, r["fuente"]))

    print(f"En vivo: {len(productos)} productos, {len(actuales)} refs de venta")
    print("Recolectando fuentes locales…")

    cand = {}
    from_backup(cand, productos)
    from_csv_simple(cand, ROOT / "pricing/importados/import_fahorro_listo.csv", "fahorro", "import_csv", 2)
    from_csv_simple(cand, ROOT / "pricing/importados/import_fahorro_matched.csv", "fahorro", "import_csv", 2)
    from_consolidado(cand, ROOT / "pricing/importados/referencias_venta_consolidado_20260815_2.csv")
    from_excel(cand)
    from_claude_sql(cand)
    from_fahorro_sql(cand, sku_by_id)

    faltan = []
    ya = 0
    sin_sku = 0
    for par, row in cand.items():
        if par in actuales:
            ya += 1
            continue
        pid = id_by_sku.get(row["sku"])
        if not pid:
            sin_sku += 1
            continue
        row["producto_id"] = pid
        faltan.append(row)

    por_fuente = defaultdict(int)
    for r in faltan:
        por_fuente[r["fuente"]] += 1

    print(f"Candidatos únicos: {len(cand)}")
    print(f"Ya están en vivo: {ya}")
    print(f"SKU no encontrado: {sin_sku}")
    print(f"A restaurar: {len(faltan)}  {dict(por_fuente)}")

    out_csv = ROOT / "pricing/importados/restaurar_referencias_borradas_20260816.csv"
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["sku", "producto_id", "fuente", "precio", "confianza", "origen", "notas"])
        w.writeheader()
        for r in sorted(faltan, key=lambda x: (x["fuente"], x["sku"])):
            w.writerow({k: r[k] for k in w.fieldnames})
    print(f"CSV → {out_csv}")

    out_sql = ROOT / "sql/pricing/generated/restaurar_referencias_borradas_20260816.sql"
    lines = [
        "-- Restaurar referencias de venta borradas el 15-ago (limpieza no comparables).",
        f"-- {len(faltan)} inserts. NO borra ni pisa filas existentes.",
        "-- Ejecutar en Supabase SQL Editor si no usas --apply.",
        "",
        "BEGIN;",
        "",
        "INSERT INTO public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)",
        f"VALUES ('similares', 'venta', '{date.today().isoformat()}', 'restaurar_referencias_borradas_20260816', {len(faltan)},",
        "        'restauracion backup UI + imports Claude/Excel/Fahorro. insert only');",
        "",
    ]
    for r in sorted(faltan, key=lambda x: (x["fuente"], x["sku"])):
        notas = r["notas"].replace("'", "''")
        lines.append(
            "INSERT INTO public.producto_precios_referencia "
            "(producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)"
        )
        lines.append(
            f"SELECT {r['producto_id']}, '{r['fuente']}', 'venta', {r['precio']:.2f}, "
            f"'{date.today().isoformat()}'::date, '{r['origen']}', {r['confianza']}, '{notas}'"
        )
        lines.append(
            "WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x "
            f"WHERE x.producto_id = {r['producto_id']} AND x.fuente = '{r['fuente']}' AND x.tipo = 'venta');"
        )
        lines.append("")
    lines += [
        "COMMIT;",
        "",
        "SELECT fuente, count(*) refs FROM public.producto_precios_referencia",
        "WHERE tipo = 'venta' GROUP BY fuente ORDER BY refs DESC;",
        "",
    ]
    out_sql.write_text("\n".join(lines), encoding="utf-8")
    print(f"SQL → {out_sql}")

    if not args.apply:
        print("Dry-run. Usa --apply para escribir en Supabase.")
        return 0

    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    }
    payload = []
    for r in faltan:
        payload.append(
            {
                "producto_id": r["producto_id"],
                "fuente": r["fuente"],
                "tipo": "venta",
                "precio": r["precio"],
                "fecha": date.today().isoformat(),
                "origen": r["origen"],
                "confianza": r["confianza"],
                "notas": r["notas"],
            }
        )
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
            print(f"Error lote {i}: {resp.status_code} {resp.text[:400]}")
            resp.raise_for_status()
        hechos += len(chunk)
        print(f"  insertados {hechos}/{len(payload)}")
    print(f"Listo: {hechos} referencias restauradas.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
