#!/usr/bin/env python3
"""
Vista previa de precios FarmaCapital (sin escribir en Supabase).
Genera CSV + resumen markdown.

Uso:
  python3 scripts/pricing_preview.py
  python3 scripts/pricing_preview.py --env /path/.env
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import os
import urllib.request
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "sql" / "pricing" / "generated"
OUT_CSV = OUT_DIR / "preview_precios_productos.csv"
OUT_MD = OUT_DIR / "preview_precios_resumen.md"


def load_env(path: Path) -> tuple[str, str]:
    url = os.environ.get("REACT_APP_SUPABASE_URL", "")
    key = os.environ.get("REACT_APP_SUPABASE_ANON_KEY", "")
    if path.exists():
        for line in path.read_text().splitlines():
            if line.startswith("REACT_APP_SUPABASE_URL="):
                url = line.split("=", 1)[1].strip()
            elif line.startswith("REACT_APP_SUPABASE_ANON_KEY="):
                key = line.split("=", 1)[1].strip()
    if not url or not key:
        raise SystemExit("Faltan REACT_APP_SUPABASE_URL / REACT_APP_SUPABASE_ANON_KEY")
    return url, key


def fetch_productos(url: str, key: str) -> list[dict]:
    cols = (
        "id,sku,nombre,categoria,tipo,costo,precio,requiere_receta,activo,marca,"
        "forma_farmaceutica,principio_activo,descuento_pct"
    )
    data: list[dict] = []
    offset = 0
    while True:
        req = urllib.request.Request(
            f"{url}/rest/v1/productos?select={cols}&offset={offset}&limit=500",
            headers={"apikey": key, "Authorization": f"Bearer {key}"},
        )
        with urllib.request.urlopen(req, timeout=60) as r:
            batch = json.loads(r.read())
        data.extend(batch)
        if len(batch) < 500:
            break
        offset += 500
    return data


def min_profit(c: float) -> float:
    if c < 20:
        return 5
    if c < 50:
        return 8
    return 0


def calc_price(costo: float, markup: float) -> int:
    base = costo * (1 + markup)
    floor = costo + min_profit(costo)
    return math.ceil(max(base, floor))


# Espejo simplificado de fn_pricing_clasificar_producto (Python)
def classify(p: dict) -> tuple[str, float, bool, str]:
    cat_l = (p.get("categoria") or "").lower()
    nombre = (p.get("nombre") or "").lower()
    tipo = (p.get("tipo") or "").lower()
    forma = (p.get("forma_farmaceutica") or "").lower()
    costo = float(p.get("costo") or 0)
    pa = (p.get("principio_activo") or "").strip()
    rx = bool(p.get("requiere_receta"))

    if costo <= 0:
        return "sin_costo", 0, True, "sin costo"
    if costo < 2:
        return "sin_clasificar", 0.35, True, "costo < $2"

    checks = [
        (lambda: cat_l in ("hidratación", "bebidas") or any(k in nombre for k in ("electrolit", "pedialyte", "suero oral", "oralit")), "bebidas_sueros", 0.30),
        (lambda: cat_l in ("bebés", "bebes") or any(k in nombre for k in ("pañal", "huggies", "nan ", "enfamil")), "bebe", 0.30),
        (lambda: cat_l in ("abarrotes", "minisuper"), "impulso", 0.40),
        (lambda: cat_l in ("suplemento", "vitaminas") or "vitamina" in nombre, "vitaminas", 0.45),
        (lambda: cat_l in ("botiquín", "botiquin") or any(k in nombre for k in ("venda", "gasa", "jeringa", "algodon", "guante")), "material_curacion", 0.50),
        (lambda: cat_l in ("higiene", "cuidado personal"), "higiene", 0.40),
    ]
    for cond, code, mk in checks:
        if cond():
            return code, mk, False, code

    if any(k in nombre for k in ("tensiometro", "glucometro", "nebulizador", "termometro", "oximetro")):
        return ("disp_med_alto", 0.30, False, "disp alto") if costo >= 300 else ("disp_med_bajo", 0.50, False, "disp bajo")

    med_form = any(x in forma for x in ("tableta", "capsula", "cápsula", "jarabe", "suspension", "solucion", "inyect", "comprim", "gragea"))

    if tipo in ("generico", "genérico") and pa and med_form:
        return "med_generico", 0.60, False, "generico+PA"
    if tipo == "marca" and rx:
        return "med_patente", 0.25, False, "marca+RX"
    if tipo == "marca" and med_form and not rx:
        return "med_otc_marca", 0.35, False, "otc marca"

    return "sin_clasificar", 0.35, True, "ambiguo"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--env", default=str(ROOT / ".env"))
    args = parser.parse_args()

    url, key = load_env(Path(args.env))
    productos = fetch_productos(url, key)
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    rows = []
    for p in productos:
        costo = float(p.get("costo") or 0)
        actual = float(p.get("precio") or 0)
        rule, mk, review, motivo = classify(p)
        if costo <= 0:
            prop = actual
        else:
            prop = calc_price(costo, mk)
            if prop < costo:
                prop = math.ceil(costo)
        util = prop - costo if costo > 0 else 0
        margen = ((prop - costo) / prop * 100) if prop > 0 and costo > 0 else 0
        var = ((prop - actual) / actual * 100) if actual > 0 else None
        legacy60 = math.ceil(costo * 1.6) if costo > 0 else None
        manual_like = (
            costo > 0
            and actual > 0
            and abs(actual - prop) > max(2, costo * 0.15)
            and legacy60 is not None
            and abs(actual - legacy60) > max(2, costo * 0.15)
        )
        rows.append(
            {
                "sku": p.get("sku"),
                "nombre": p.get("nombre"),
                "categoria": p.get("categoria"),
                "tipo": p.get("tipo"),
                "costo": round(costo, 2),
                "precio_actual": round(actual, 2),
                "precio_propuesto": prop,
                "regla": rule,
                "recargo_pct": round(mk * 100, 1),
                "utilidad_pesos": round(util, 2),
                "margen_bruto_pct": round(margen, 1),
                "variacion_pct": round(var, 1) if var is not None else "",
                "needs_review": review,
                "manual_like": manual_like,
                "motivo_regla": motivo,
            }
        )

    with OUT_CSV.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)

    by_rule = Counter(r["regla"] for r in rows)
    sube30 = sum(1 for r in rows if r["variacion_pct"] != "" and float(r["variacion_pct"]) > 30)
    baja = sum(1 for r in rows if r["variacion_pct"] != "" and float(r["variacion_pct"]) < -0.5)
    review = sum(1 for r in rows if r["needs_review"])
    manual = sum(1 for r in rows if r["manual_like"])

    md = f"""# Vista previa precios — {len(rows)} productos

## Totales
- Productos: **{len(rows)}**
- Sin costo válido: **{sum(1 for r in rows if r['regla']=='sin_costo')}**
- Revisión manual (clasificación): **{review}**
- Precio atípico (posible manual): **{manual}**
- Subida >30%: **{sube30}**
- Bajada de precio: **{baja}**

## Por regla
"""
    for k, v in by_rule.most_common():
        md += f"- `{k}`: {v}\n"

    md += f"\nCSV detallado: `{OUT_CSV.relative_to(ROOT)}`\n"
    OUT_MD.write_text(md, encoding="utf-8")
    print(md)


if __name__ == "__main__":
    main()
