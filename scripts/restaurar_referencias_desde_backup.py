#!/usr/bin/env python3
"""
Compara backup de pestaña Referencias (TSV pegado por usuario) vs Supabase
y genera SQL para restaurar referencias faltantes (fahorro / similares).

Uso:
  python3 scripts/restaurar_referencias_desde_backup.py
  python3 scripts/restaurar_referencias_desde_backup.py --apply   # escribe en Supabase

Entrada:
  pricing/importados/backup_tabla_referencias_usuario_20260814.txt
"""
from __future__ import annotations

import argparse
import csv
import re
import sys
from collections import defaultdict
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKUP = ROOT / "pricing/importados/backup_tabla_referencias_usuario_20260814.txt"
OUT_SQL = ROOT / "sql/pricing/generated/restaurar_referencias_backup_usuario_20260814.sql"
OUT_CSV = ROOT / "pricing/importados/restaurar_referencias_pendientes.csv"

try:
    import requests
except ImportError:
    requests = None

NOTE_MARKERS = (
    "Sin referencias",
    "Competir:",
    "Competitivo",
    "Competencia",
    "Tu precio ya",
    "A $",
    "Manual bajo",
)


def parse_money(s: str) -> float | None:
    s = (s or "").strip()
    if not s or s == "—":
        return None
    m = re.search(r"(\d+(?:\.\d+)?)", s.replace(",", ""))
    return float(m.group(1)) if m else None


def norm_key(s: str) -> str:
    return re.sub(r"[^a-z0-9]+", "", (s or "").lower())


def parse_backup(text: str) -> list[dict]:
    lines = text.splitlines()
    products: list[dict] = []
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line or line.startswith("Producto\t"):
            i += 1
            continue
        if line in ("Aplicar", "—") or line.startswith("↺") or line.startswith("$"):
            i += 1
            continue
        if "\t" in line or line.startswith("PA:") or "·" in line:
            i += 1
            continue

        name = line
        i += 1
        pa = ""
        if i < len(lines) and lines[i].startswith("PA:"):
            pa = lines[i].strip()
            i += 1

        pres = ""
        if i < len(lines) and "·" in lines[i]:
            pres = lines[i].strip()
            i += 1
        elif i < len(lines) and lines[i].strip() and not lines[i].startswith("$") and "\t" not in lines[i]:
            # presentación corta (SPRAY, C/10, etc.)
            if lines[i].strip() not in ("Aplicar", "—") and not any(m in lines[i] for m in NOTE_MARKERS):
                pres = lines[i].strip()
                i += 1

        chunk: list[str] = []
        note = ""
        while i < len(lines):
            l = lines[i]
            st = l.strip()
            if st in ("Aplicar", "—") or st.startswith("↺"):
                i += 1
                break
            if any(m in l for m in NOTE_MARKERS):
                note = l.strip()
                i += 1
                if i < len(lines) and lines[i].strip() in ("Aplicar", "—"):
                    i += 1
                break
            chunk.append(l)
            i += 1

        if not chunk:
            continue

        first = chunk[0]
        parts = first.split("\t")
        tu = parse_money(parts[0]) if parts else None
        fah = parse_money(parts[2]) if len(parts) > 2 else None
        sim = parse_money(parts[3]) if len(parts) > 3 else None

        ref_prices: list[float] = []
        for l in chunk[1:]:
            m = re.match(r"^\$(\d+(?:\.\d+)?)", l.strip())
            if m and "vs ref" not in l:
                ref_prices.append(float(m.group(1)))

        del_ahorro_col = parts[2].strip() if len(parts) > 2 else ""
        if fah is None and sim is None and len(ref_prices) == 2:
            fah, sim = ref_prices
        elif fah is None and sim is None and len(ref_prices) == 1:
            # Una sola ref en columna siguiente:
            # · col Del Ahorro = "—" → el precio es Similares (ej. 12H $99)
            # · col Del Ahorro vacía → el precio es Del Ahorro (ej. Afrin $113)
            if del_ahorro_col == "—":
                sim = ref_prices[0]
            else:
                fah = ref_prices[0]
        elif fah is None and len(ref_prices) >= 1:
            fah = ref_prices[0]
            if sim is None and len(ref_prices) >= 2:
                sim = ref_prices[1]
        elif sim is None and len(ref_prices) >= 1 and del_ahorro_col == "—":
            sim = ref_prices[0]

        if not fah and not sim:
            continue

        products.append(
            {
                "name": name,
                "pa": pa.replace("PA:", "").strip(),
                "pres": pres,
                "tu": tu,
                "fahorro": fah,
                "similares": sim,
                "note": note,
            }
        )
    return products


def load_supabase():
    env = {}
    for line in (ROOT / ".env").read_text(encoding="utf-8").splitlines():
        if "=" in line and not line.strip().startswith("#"):
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip().strip('"').strip("'")
    url = env["REACT_APP_SUPABASE_URL"].rstrip("/")
    key = env["REACT_APP_SUPABASE_ANON_KEY"]
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    prods = requests.get(
        f"{url}/rest/v1/productos",
        headers={**headers, "Range": "0-4999"},
        params={"select": "id,sku,nombre,concentracion,presentacion,precio,principio_activo"},
        timeout=60,
    ).json()
    refs = requests.get(
        f"{url}/rest/v1/producto_precios_referencia_actual",
        headers={**headers, "Range": "0-4999"},
        params={"select": "producto_id,fuente,precio,notas"},
        timeout=60,
    ).json()
    ref_map: dict[int, dict[str, float]] = defaultdict(dict)
    for r in refs:
        if r.get("notas") == "__anulado__":
            continue
        ref_map[r["producto_id"]][r["fuente"]] = float(r["precio"])
    return url, headers, prods, ref_map


def match_product(row: dict, prods: list[dict]) -> dict | None:
    name_n = row["name"].lower()
    conc = row["pres"].split("·")[0].strip() if "·" in row["pres"] else row["pres"]
    conc_n = norm_key(conc)
    cands = []
    for p in prods:
        if name_n not in p["nombre"].lower():
            continue
        blob = norm_key((p.get("concentracion") or "") + (p.get("presentacion") or ""))
        if conc_n and len(conc_n) >= 4 and conc_n not in blob and blob[:8] not in conc_n:
            continue
        cands.append(p)
    if not cands:
        return None
    if len(cands) == 1:
        return cands[0]
    if row.get("tu"):
        cands.sort(key=lambda x: abs(float(x.get("precio") or 0) - row["tu"]))
    return cands[0]


def sql_quote(s: str) -> str:
    return "'" + str(s).replace("'", "''") + "'"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="Insertar en Supabase vía REST")
    ap.add_argument("--backup", type=Path, default=BACKUP)
    args = ap.parse_args()

    if not args.backup.exists():
        sys.exit(f"No encontré backup: {args.backup}")

    text = args.backup.read_text(encoding="utf-8")
    parsed = parse_backup(text)
    print(f"Backup: {len(parsed)} productos con referencia FDA/Similares")

    if requests is None:
        sys.exit("Falta requests")

    _, headers, prods, ref_map = load_supabase()
    fecha = date.today().isoformat()

    restores: list[dict] = []
    ok = 0
    for row in parsed:
        p = match_product(row, prods)
        if not p:
            continue
        cur = ref_map.get(p["id"], {})
        for fuente, key in (("fahorro", "fahorro"), ("similares", "similares")):
            want = row.get(key)
            if want is None:
                continue
            have = cur.get(fuente)
            if have is not None and abs(have - want) < 0.02:
                ok += 1
                continue
            restores.append(
                {
                    "sku": p["sku"],
                    "producto_id": p["id"],
                    "nombre": p["nombre"],
                    "fuente": fuente,
                    "precio_backup": want,
                    "precio_actual": have,
                }
            )

    print(f"Ya coinciden: {ok} | A restaurar: {len(restores)}")

    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    with OUT_CSV.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(
            f,
            fieldnames=["sku", "producto_id", "nombre", "fuente", "precio_backup", "precio_actual"],
        )
        w.writeheader()
        w.writerows(restores)

    lines = [
        "-- Restaurar referencias de precio desde backup usuario 2026-08-14",
        f"-- {len(restores)} inserts (solo faltantes o distintos; no borra nada)",
        "-- Ejecutar en Supabase SQL Editor",
        "",
        "BEGIN;",
        "",
    ]
    for r in restores:
        tipo = "venta"
        lines.append(
            "INSERT INTO public.producto_precios_referencia "
            "(producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)"
        )
        lines.append(
            f"VALUES ({r['producto_id']}, {sql_quote(r['fuente'])}, {sql_quote(tipo)}, "
            f"{r['precio_backup']:.2f}, {sql_quote(fecha)}::date, 'manual', 100, "
            f"'Restaurado desde backup UI {fecha}');"
        )
        lines.append("")

    lines.append("COMMIT;")
    lines.append("")
    OUT_SQL.parent.mkdir(parents=True, exist_ok=True)
    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")
    print(f"SQL → {OUT_SQL}")
    print(f"CSV → {OUT_CSV}")

    if args.apply and restores:
        url = headers["Authorization"].split()[-1]
        base = None
        for line in (ROOT / ".env").read_text().splitlines():
            if line.startswith("REACT_APP_SUPABASE_URL="):
                base = line.split("=", 1)[1].strip().rstrip("/")
        inserts = []
        for r in restores:
            inserts.append(
                {
                    "producto_id": r["producto_id"],
                    "fuente": r["fuente"],
                    "tipo": "venta",
                    "precio": r["precio_backup"],
                    "fecha": fecha,
                    "origen": "manual",
                    "confianza": 100,
                    "notas": f"Restaurado desde backup UI {fecha}",
                }
            )
        resp = requests.post(
            f"{base}/rest/v1/producto_precios_referencia",
            headers={**headers, "Content-Type": "application/json", "Prefer": "return=minimal"},
            json=inserts,
            timeout=120,
        )
        resp.raise_for_status()
        print(f"Apply OK: {len(inserts)} filas insertadas")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
