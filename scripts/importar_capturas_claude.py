#!/usr/bin/env python3
"""
Convierte capturas Claude (nombre en columna sku) → CSV importable por SKU FarmaCapital.

Uso:
  python3 scripts/importar_capturas_claude.py \\
    --fahorro ~/Downloads/fahorro_captura_20260813*.csv \\
    --exprezo ~/Downloads/exprezo_match_20260813*.csv \\
    --comparativo ~/Downloads/comparativo_maestro*.csv

  python3 scripts/importar_capturas_claude.py ... --apply
"""
from __future__ import annotations

import argparse
import csv
import glob
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOGO = ROOT / "sql" / "preview_catalogo_campos_y_precios.csv"
OUT_DIR = ROOT / "pricing" / "importados"

try:
    from rapidfuzz import fuzz, process
except ImportError:
    sys.exit("Instala rapidfuzz: pip install rapidfuzz")


def norm(s: str) -> str:
    return re.sub(r"\s+", " ", str(s).lower().replace("-", " ").replace("$", "")).strip()


def load_catalog() -> tuple[list[dict], list[str]]:
    prods: list[dict] = []
    with CATALOGO.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if str(row.get("activo", "")).lower() == "false":
                continue
            prods.append(row)
    pool = [norm(p.get("nombre", "")) for p in prods]
    return prods, pool


def match_name(query: str, prods: list[dict], pool: list[str], min_score: int = 72):
    q = norm(query)
    if not q:
        return None, 0
    for p in prods:
        if norm(p.get("nombre", "")) == q:
            return p, 100
    best = process.extractOne(q, pool, scorer=fuzz.token_set_ratio)
    if not best or best[1] < min_score:
        return None, int(best[1]) if best else 0
    idx = pool.index(best[0])
    return prods[idx], int(best[1])


def parse_claude_csv(path: Path, prods, pool) -> dict[str, tuple[float, int]]:
    """sku -> (precio, score)"""
    out: dict[str, tuple[float, int]] = {}
    with path.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            key = (row.get("sku") or "").strip()
            precio = (row.get("precio") or "").strip()
            if not key or not precio:
                continue
            try:
                pval = float(precio)
            except ValueError:
                continue
            prod, score = match_name(key, prods, pool)
            if prod and score >= 72:
                sku = prod["sku"]
                if sku not in out or score > out[sku][1]:
                    out[sku] = (pval, score)
    return out


def parse_comparativo(path: Path, prods, pool) -> tuple[dict[str, tuple[float, int]], dict[str, tuple[float, int]]]:
    fda: dict[str, tuple[float, int]] = {}
    exp: dict[str, tuple[float, int]] = {}
    with path.open(newline="", encoding="utf-8") as f:
        rows = list(csv.reader(f))
    for row in rows[4:]:
        if len(row) < 5:
            continue
        nombre = (row[0] or "").strip()
        if not nombre:
            continue
        prod, score = match_name(nombre, prods, pool)
        if not prod or score < 72:
            continue
        sku = prod["sku"]

        def parse_money(s):
            s = (s or "").replace("$", "").replace(",", "").strip()
            if not s:
                return None
            try:
                return float(s)
            except ValueError:
                return None

        pf = parse_money(row[4])
        if pf is not None:
            if sku not in fda or score > fda[sku][1]:
                fda[sku] = (pf, score)
        pe = parse_money(row[2]) or parse_money(row[3])
        if pe is not None:
            if sku not in exp or score > exp[sku][1]:
                exp[sku] = (pe, score)
    return fda, exp


def merge_maps(*maps: dict[str, tuple[float, int]]) -> dict[str, float]:
    merged: dict[str, tuple[float, int]] = {}
    for m in maps:
        for sku, (p, sc) in m.items():
            if sku not in merged or sc > merged[sku][1]:
                merged[sku] = (p, sc)
    return {k: v[0] for k, v in merged.items()}


def write_import_csv(path: Path, prices: dict[str, float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["sku", "precio"])
        for sku in sorted(prices.keys()):
            w.writerow([sku, prices[sku]])


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fahorro", nargs="*", default=[])
    parser.add_argument("--exprezo", nargs="*", default=[])
    parser.add_argument("--comparativo", nargs="*", default=[])
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()

    if not CATALOGO.exists():
        sys.exit(f"Exporta catálogo primero: {CATALOGO}")

    prods, pool = load_catalog()
    print(f"Catálogo: {len(prods)} productos")

    fahorro_maps = []
    exprezo_maps = []

    for pattern in args.fahorro:
        for p in glob.glob(pattern):
            m = parse_claude_csv(Path(p), prods, pool)
            print(f"  fahorro {Path(p).name}: {len(m)} matches")
            fahorro_maps.append(m)

    for pattern in args.exprezo:
        for p in glob.glob(pattern):
            m = parse_claude_csv(Path(p), prods, pool)
            print(f"  exprezo {Path(p).name}: {len(m)} matches")
            exprezo_maps.append(m)

    for pattern in args.comparativo:
        for p in glob.glob(pattern):
            fda, exp = parse_comparativo(Path(p), prods, pool)
            print(f"  comparativo {Path(p).name}: FDA={len(fda)} Exprezo={len(exp)}")
            fahorro_maps.append(fda)
            exprezo_maps.append(exp)

    fahorro_prices = merge_maps(*fahorro_maps) if fahorro_maps else {}
    exprezo_prices = merge_maps(*exprezo_maps) if exprezo_maps else {}

    fahorro_out = OUT_DIR / "import_fahorro_listo.csv"
    exprezo_out = OUT_DIR / "import_exprezo_listo.csv"
    write_import_csv(fahorro_out, fahorro_prices)
    write_import_csv(exprezo_out, exprezo_prices)
    print(f"\nListo FDA:   {len(fahorro_prices)} SKUs → {fahorro_out}")
    print(f"Listo Exprezo: {len(exprezo_prices)} SKUs → {exprezo_out}")

    if args.apply:
        import subprocess
        for fuente, out in [("fahorro", fahorro_out), ("exprezo", exprezo_out)]:
            if not out.exists() or out.stat().st_size < 20:
                continue
            cmd = [
                sys.executable,
                str(ROOT / "scripts" / "importar_referencias_precio.py"),
                "--fuente", fuente,
                "--archivo", str(out),
                "--apply",
            ]
            print(f"\n→ {' '.join(cmd)}")
            subprocess.run(cmd, check=False)


if __name__ == "__main__":
    main()
