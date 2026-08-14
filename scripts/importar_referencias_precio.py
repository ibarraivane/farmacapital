#!/usr/bin/env python3
"""
Importa precios de referencia (compra/venta) desde CSV → Supabase.

Formatos soportados:
  - Exprezo: Categoria, Producto, Precio Mayoreo, Precio por Unidad
  - Genérico: sku + precio  OR  nombre + precio (+ sku opcional)

Uso:
  python3 scripts/importar_referencias_precio.py --fuente exprezo \\
    --archivo pricing/precios_proveedores/Exprezo_20260812.csv \\
    --precio-col mayoreo

  python3 scripts/importar_referencias_precio.py --fuente fahorro \\
    --archivo mi_lista_fda.csv --dry-run

  python3 scripts/importar_referencias_precio.py --fuente exprezo ... --apply
    (escribe en Supabase vía REST; requiere .env con REACT_APP_SUPABASE_*)

  python3 scripts/importar_referencias_precio.py ... --sql-only
    (genera sql/pricing/generated/import_referencias_<fuente>.sql)
"""
from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
import time
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / ".env"
OUT_DIR = ROOT / "sql" / "pricing" / "generated"

try:
    import requests
except ImportError:
    requests = None

try:
    from rapidfuzz import fuzz, process
except ImportError:
    sys.exit("Falta rapidfuzz. Instala: pip install rapidfuzz")


FUENTE_TIPO = {
    "exprezo": "compra",
    "marzam": "compra",
    "nadro": "compra",
    "levic": "compra",
    "similares": "venta",
    "fahorro": "venta",
}


def norm(s: str) -> str:
    return re.sub(r"\s+", " ", str(s).lower().replace("-", " ").replace("/", " ")).strip()


def parse_money(val) -> float | None:
    if val is None or val == "":
        return None
    s = str(val).replace("$", "").replace(",", "").strip()
    try:
        n = float(s)
        return n if n >= 0 else None
    except ValueError:
        return None


def cargar_env() -> dict[str, str]:
    out: dict[str, str] = {}
    if ENV_PATH.exists():
        for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, _, v = line.partition("=")
            out[k.strip()] = v.strip()
    out.setdefault("REACT_APP_SUPABASE_URL", os.environ.get("REACT_APP_SUPABASE_URL", ""))
    out.setdefault("REACT_APP_SUPABASE_ANON_KEY", os.environ.get("REACT_APP_SUPABASE_ANON_KEY", ""))
    return out


def fetch_productos(url: str, key: str) -> list[dict]:
    if not requests:
        sys.exit("Falta requests para consultar Supabase")
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    rows: list[dict] = []
    offset = 0
    while True:
        h = {**headers, "Range": f"{offset}-{offset + 499}"}
        r = requests.get(
            f"{url}/rest/v1/productos",
            headers=h,
            params={"select": "id,sku,nombre,marca,codigo_barras,principio_activo", "activo": "eq.true"},
            timeout=60,
        )
        r.raise_for_status()
        batch = r.json()
        rows.extend(batch)
        if len(batch) < 500:
            break
        offset += 500
    return rows


def build_sku_index(productos: list[dict]) -> dict[str, dict]:
    return {(p.get("sku") or "").strip(): p for p in productos if p.get("sku")}


def fuzzy_match_producto(
    nombre_fuente: str,
    marca: str,
    productos: list[dict],
    min_score: int = 70,
) -> tuple[dict | None, int]:
    query = norm(f"{marca} {nombre_fuente}")
    if not query:
        return None, 0

    pool = productos
    if marca.strip():
        m = norm(marca)
        filtered = [p for p in productos if m in norm(p.get("marca") or "")]
        if filtered:
            pool = filtered

    choices = [(p["id"], norm(f"{p.get('marca') or ''} {p.get('nombre') or ''}")) for p in pool]
    if not choices:
        return None, 0

    best = process.extractOne(query, [c[1] for c in choices], scorer=fuzz.token_set_ratio)
    if not best or best[1] < min_score:
        return None, best[1] if best else 0

    _, score, idx = best
    pid = choices[idx][0]
    prod = next(p for p in pool if p["id"] == pid)
    return prod, int(score)


def parse_exprezo_rows(path: Path, precio_col: str) -> list[dict]:
    rows = []
    with path.open(newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader, start=2):
            producto = (row.get("Producto") or "").strip()
            if not producto:
                continue
            may = parse_money(row.get("Precio Mayoreo"))
            uni = parse_money(row.get("Precio por Unidad"))
            if precio_col == "unidad":
                precio = uni
            else:
                precio = may
            if precio is None:
                continue
            # Heurística OCR: mayoreo absurdo vs unidad
            if may and uni and may > uni * 2 and precio_col == "mayoreo":
                if uni > 0 and may > uni * 2:
                    precio = uni  # fallback a unidad
            rows.append({
                "line": i,
                "nombre_fuente": producto,
                "precio": precio,
                "mayoreo": may,
                "unidad": uni,
            })
    return rows


def parse_generico_rows(path: Path) -> list[dict]:
    rows = []
    with path.open(newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        sku_col = next((c for c in reader.fieldnames or [] if c.lower().strip() in ("sku", "sku_farmacapital")), None)
        nombre_col = next(
            (c for c in reader.fieldnames or [] if c.lower().strip() in ("nombre", "producto", "descripcion")),
            None,
        )
        precio_col = next(
            (c for c in reader.fieldnames or [] if c.lower().strip() in ("precio", "precio_ref", "precio_mayoreo")),
            None,
        )
        if not precio_col:
            sys.exit(f"CSV genérico: falta columna precio. Columnas: {reader.fieldnames}")
        for i, row in enumerate(reader, start=2):
            precio = parse_money(row.get(precio_col))
            if precio is None:
                continue
            rows.append({
                "line": i,
                "sku": (row.get(sku_col) or "").strip() if sku_col else "",
                "nombre_fuente": (row.get(nombre_col) or "").strip() if nombre_col else "",
                "precio": precio,
            })
    return rows


def match_rows(fuente: str, archivo: Path, productos: list[dict], precio_col: str) -> list[dict]:
    sku_idx = build_sku_index(productos)
    if fuente == "exprezo":
        raw = parse_exprezo_rows(archivo, precio_col)
    else:
        raw = parse_generico_rows(archivo)

    matched = []
    for row in raw:
        prod = None
        score = 0
        if row.get("sku") and row["sku"] in sku_idx:
            prod = sku_idx[row["sku"]]
            score = 100
        elif row.get("nombre_fuente"):
            prod, score = fuzzy_match_producto(row["nombre_fuente"], "", productos)

        if not prod:
            continue
        matched.append({
            **row,
            "producto_id": prod["id"],
            "sku": prod.get("sku"),
            "nombre_catalogo": prod.get("nombre"),
            "confianza": score,
        })
    return matched


def sql_quote(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def generate_sql(fuente: str, fecha: str, archivo: str, matched: list[dict]) -> str:
    tipo = FUENTE_TIPO[fuente]
    lines = [
        f"-- Import referencias {fuente} — {len(matched)} filas",
        f"-- Archivo: {archivo}",
        "",
        "begin;",
        "",
        "with imp as (",
        "  insert into public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)",
        f"  values ({sql_quote(fuente)}, {sql_quote(tipo)}, {sql_quote(fecha)}, {sql_quote(archivo)}, {len(matched)}, 'importar_referencias_precio.py')",
        "  returning id",
        ")",
        "insert into public.producto_precios_referencia (",
        "  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, import_id",
        ")",
        "select",
        "  v.producto_id,",
        f"  {sql_quote(fuente)},",
        f"  {sql_quote(tipo)},",
        "  v.precio,",
        f"  {sql_quote(fecha)}::date,",
        "  v.nombre_fuente,",
        "  v.confianza,",
        "  'import_csv',",
        "  imp.id",
        "from imp, (values",
    ]
    value_rows = []
    for m in matched:
        nf = sql_quote(m.get("nombre_fuente") or m.get("nombre_catalogo") or "")
        value_rows.append(
            f"  ({m['producto_id']}::bigint, {m['precio']}::numeric, {nf}, {m['confianza']}::smallint)"
        )
    if not value_rows:
        lines.append("  (null::bigint, null::numeric, null::text, null::smallint) -- sin filas")
    else:
        lines.append(",\n".join(value_rows))
    lines.extend([
        ") as v(producto_id, precio, nombre_fuente, confianza)",
        "where v.producto_id is not null;",
        "",
        "commit;",
        "",
    ])
    return "\n".join(lines)


def apply_rest(url: str, key: str, fuente: str, fecha: str, archivo: str, matched: list[dict]) -> None:
    if not requests:
        sys.exit("Falta requests")
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=representation",
    }
    tipo = FUENTE_TIPO[fuente]
    imp_resp = requests.post(
        f"{url}/rest/v1/importaciones_referencia",
        headers=headers,
        json={
            "fuente": fuente,
            "tipo": tipo,
            "fecha_lista": fecha,
            "archivo": archivo,
            "filas_ok": len(matched),
            "filas_error": 0,
            "notas": "importar_referencias_precio.py --apply",
        },
        timeout=60,
    )
    imp_resp.raise_for_status()
    import_id = imp_resp.json()[0]["id"]

    batch_size = 100
    for i in range(0, len(matched), batch_size):
        chunk = matched[i : i + batch_size]
        payload = [
            {
                "producto_id": m["producto_id"],
                "fuente": fuente,
                "tipo": tipo,
                "precio": m["precio"],
                "fecha": fecha,
                "nombre_fuente": m.get("nombre_fuente") or m.get("nombre_catalogo"),
                "confianza": m["confianza"],
                "origen": "import_csv",
                "import_id": import_id,
            }
            for m in chunk
        ]
        r = requests.post(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=headers,
            json=payload,
            timeout=120,
        )
        r.raise_for_status()
        print(f"  Insertadas {min(i + batch_size, len(matched))}/{len(matched)}")
        time.sleep(0.2)


def main() -> None:
    parser = argparse.ArgumentParser(description="Importar referencias de precio a Supabase")
    parser.add_argument("--fuente", required=True, choices=list(FUENTE_TIPO.keys()))
    parser.add_argument("--archivo", required=True, type=Path)
    parser.add_argument("--precio-col", choices=["mayoreo", "unidad"], default="mayoreo",
                        help="Solo Exprezo: columna de precio")
    parser.add_argument("--fecha", default=date.today().isoformat())
    parser.add_argument("--min-score", type=int, default=70)
    parser.add_argument("--dry-run", action="store_true", help="Solo muestra estadísticas")
    parser.add_argument("--sql-only", action="store_true", help="Genera SQL sin aplicar")
    parser.add_argument("--apply", action="store_true", help="Inserta vía REST API")
    args = parser.parse_args()

    if not args.archivo.exists():
        sys.exit(f"No existe: {args.archivo}")

    env = cargar_env()
    url = env.get("REACT_APP_SUPABASE_URL", "")
    key = env.get("REACT_APP_SUPABASE_ANON_KEY", "")
    if not url or not key:
        sys.exit("Faltan REACT_APP_SUPABASE_URL / REACT_APP_SUPABASE_ANON_KEY en .env")

    print("Cargando catálogo desde Supabase…")
    productos = fetch_productos(url, key)
    print(f"  {len(productos)} productos activos")

    matched = match_rows(args.fuente, args.archivo, productos, args.precio_col)
    alta = sum(1 for m in matched if m["confianza"] >= 85)
    media = sum(1 for m in matched if 70 <= m["confianza"] < 85)
    print(f"Matches: {len(matched)} (alta confianza ≥85: {alta}, media 70–84: {media})")

    if args.dry_run:
        for m in matched[:15]:
            print(f"  [{m['confianza']}%] {m.get('sku')} ← {m.get('nombre_fuente','')[:50]}")
        if len(matched) > 15:
            print(f"  … y {len(matched) - 15} más")
        return

    sql_text = generate_sql(args.fuente, args.fecha, args.archivo.name, matched)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_sql = OUT_DIR / f"import_referencias_{args.fuente}_{args.fecha.replace('-', '')}.sql"
    out_sql.write_text(sql_text, encoding="utf-8")
    print(f"SQL generado: {out_sql}")

    if args.apply:
        print("Aplicando vía REST…")
        apply_rest(url, key, args.fuente, args.fecha, args.archivo.name, matched)
        print("Listo.")
    elif not args.sql_only:
        print("Ejecuta el SQL en Supabase o re-corre con --apply")


if __name__ == "__main__":
    main()
