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

sys.path.insert(0, str(ROOT))
from lib.pricing.normalize import extraer_tamano, tamanos_equivalentes  # noqa: E402

TOL_TAMANO_IMPORT = 0.05


FUENTE_TIPO = {
    "exprezo": "compra",
    "marzam": "compra",
    "nadro": "compra",
    "levic": "compra",
    "farmalive": "compra",
    "similares": "venta",
    "fahorro": "venta",
    "otros_venta": "venta",
}

FUENTE_ALIASES = {
    "otros": "otros_venta",
    "otros_venta": "otros_venta",
    "similares": "similares",
    "fahorro": "fahorro",
}


def normalize_fuente(raw: str | None, fallback: str) -> str:
    s = (raw or fallback or "similares").strip().lower()
    s = FUENTE_ALIASES.get(s, s)
    if s not in FUENTE_TIPO:
        sys.exit(f"Fuente desconocida en CSV: {raw!r} (usa: {', '.join(FUENTE_TIPO)})")
    return s

CONFIDENCIA_TEXTO = {
    "alta": 85,
    "media": 75,
    "dudoso": 60,
    "sin_dato": 0,
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

    tam_fuente = extraer_tamano(nombre_fuente)
    if tam_fuente is not None:
        mismos = []
        for p in pool:
            tam_cat = extraer_tamano(
                f"{p.get('presentacion') or ''} {p.get('nombre') or ''}"
            )
            if tam_cat is None:
                mismos.append(p)
            elif tamanos_equivalentes(tam_fuente, tam_cat, TOL_TAMANO_IMPORT):
                mismos.append(p)
        pool = mismos

    choices = [
        (
            p["id"],
            norm(f"{p.get('marca') or ''} {p.get('nombre') or ''} {p.get('presentacion') or ''}"),
        )
        for p in pool
    ]
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


def parse_confianza(val, fallback: int) -> int:
    if val is None:
        return fallback
    s = str(val).strip().lower()
    if not s:
        return fallback
    if s.isdigit():
        return max(0, min(100, int(s)))
    return CONFIDENCIA_TEXTO.get(s, fallback)


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
        conf_col = next(
            (c for c in reader.fieldnames or [] if c.lower().strip() in ("confianza", "confianza_match")),
            None,
        )
        notas_col = next((c for c in reader.fieldnames or [] if c.lower().strip() == "notas"), None)
        fuente_col = next((c for c in reader.fieldnames or [] if c.lower().strip() == "fuente"), None)
        if not precio_col:
            sys.exit(f"CSV genérico: falta columna precio. Columnas: {reader.fieldnames}")
        for i, row in enumerate(reader, start=2):
            precio = parse_money(row.get(precio_col))
            if precio is None:
                continue
            conf_raw = row.get(conf_col) if conf_col else None
            rows.append({
                "line": i,
                "sku": (row.get(sku_col) or "").strip() if sku_col else "",
                "nombre_fuente": (row.get(nombre_col) or "").strip() if nombre_col else "",
                "precio": precio,
                "confianza_csv": parse_confianza(conf_raw, 100 if (row.get(sku_col) or "").strip() else 75),
                "notas": (row.get(notas_col) or "").strip() if notas_col else "",
                "fuente_csv": (row.get(fuente_col) or "").strip() if fuente_col else "",
            })
    return rows


def match_rows(fuente: str, archivo: Path, productos: list[dict], precio_col: str) -> list[dict]:
    sku_idx = build_sku_index(productos)
    # CSV ya con sku FC- (capturas Claude / plantilla genérica)
    with archivo.open(newline="", encoding="utf-8") as f:
        peek = f.read(512)
    if "sku" in peek.lower() and fuente != "exprezo":
        raw = parse_generico_rows(archivo)
    elif fuente == "exprezo" and "Producto" not in peek and "sku" in peek.lower():
        raw = parse_generico_rows(archivo)
    elif fuente == "exprezo":
        raw = parse_exprezo_rows(archivo, precio_col)
    else:
        raw = parse_generico_rows(archivo)

    matched = []
    for row in raw:
        prod = None
        score = 0
        if row.get("sku") and row["sku"] in sku_idx:
            prod = sku_idx[row["sku"]]
            score = row.get("confianza_csv") or 100
        elif row.get("nombre_fuente"):
            prod, score = fuzzy_match_producto(row["nombre_fuente"], "", productos)
            if row.get("confianza_csv"):
                score = min(score, row["confianza_csv"]) if score else row["confianza_csv"]

        if not prod:
            continue
        matched.append({
            **row,
            "producto_id": prod["id"],
            "sku": prod.get("sku"),
            "nombre_catalogo": prod.get("nombre"),
            "confianza": score,
            "fuente": normalize_fuente(row.get("fuente_csv"), fuente),
        })
    return matched


def group_by_fuente(matched: list[dict]) -> dict[str, list[dict]]:
    out: dict[str, list[dict]] = {}
    for m in matched:
        out.setdefault(m["fuente"], []).append(m)
    return out


def sql_quote(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def generate_sql(fuente: str, fecha: str, archivo: str, matched: list[dict]) -> str:
    tipo = FUENTE_TIPO[fuente]
    use_sku_join = all(m.get("sku") for m in matched)
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
    ]
    if use_sku_join:
        lines.extend([
            "insert into public.producto_precios_referencia (",
            "  producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza, notas",
            ")",
            "select",
            "  p.id,",
            f"  {sql_quote(fuente)},",
            f"  {sql_quote(tipo)},",
            "  v.precio,",
            f"  {sql_quote(fecha)}::date,",
            "  'import_csv',",
            "  imp.id,",
            "  v.confianza,",
            "  v.notas",
            "from imp, (values",
        ])
        value_rows = []
        for m in matched:
            notas = sql_quote(m.get("notas") or "")
            value_rows.append(
                f"  ({sql_quote(m['sku'])}, {m['precio']}::numeric, {m['confianza']}::smallint, {notas})"
            )
        lines.append(",\n".join(value_rows) if value_rows else "  (null::text, null::numeric, null::smallint, null::text)")
        lines.extend([
            ") as v(sku, precio, confianza, notas)",
            "join public.productos p on p.sku = v.sku and p.activo = true",
            "where v.sku is not null;",
        ])
    else:
        lines.extend([
            "insert into public.producto_precios_referencia (",
            "  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, import_id, notas",
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
            "  imp.id,",
            "  v.notas",
            "from imp, (values",
        ])
        value_rows = []
        for m in matched:
            nf = sql_quote(m.get("nombre_fuente") or m.get("nombre_catalogo") or "")
            notas = sql_quote(m.get("notas") or "")
            value_rows.append(
                f"  ({m['producto_id']}::bigint, {m['precio']}::numeric, {nf}, {m['confianza']}::smallint, {notas})"
            )
        if not value_rows:
            lines.append("  (null::bigint, null::numeric, null::text, null::smallint, null::text) -- sin filas")
        else:
            lines.append(",\n".join(value_rows))
        lines.extend([
            ") as v(producto_id, precio, nombre_fuente, confianza, notas)",
            "where v.producto_id is not null;",
        ])
    lines.extend(["", "commit;", ""])
    return "\n".join(lines)


def ensure_fuentes(url: str, key: str, fuentes: set[str]) -> None:
    if not requests:
        return
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates",
    }
    presets = {
        "otros_venta": {
            "id": "otros_venta",
            "nombre": "Otros (venta)",
            "tipo": "venta",
            "metodo": "manual",
            "notas": "Promedio de mercado o consulta manual (Claude, Google, etc.)",
        },
        "otros_compra": {
            "id": "otros_compra",
            "nombre": "Otros (compra)",
            "tipo": "compra",
            "metodo": "manual",
            "notas": "Promedio de mercado o consulta manual (Claude, Google, etc.)",
        },
        "farmalive": {
            "id": "farmalive",
            "nombre": "Farmalive",
            "tipo": "compra",
            "metodo": "import_archivo",
            "notas": "Lista normal Club Iztapalapa. Precio base (2%), no campañas de día.",
        },
    }
    payload = [presets[f] for f in sorted(fuentes) if f in presets]
    if not payload:
        return
    r = requests.post(
        f"{url}/rest/v1/fuentes_precio",
        headers=headers,
        json=payload,
        timeout=30,
    )
    if r.status_code not in (200, 201):
        print(f"AVISO: no se pudieron registrar fuentes {payload}: {r.status_code} {r.text[:200]}")


def generate_sql_multi(fecha: str, archivo: str, grouped: dict[str, list[dict]]) -> str:
    parts = [
        f"-- Import referencias consolidado — {sum(len(v) for v in grouped.values())} filas",
        f"-- Archivo: {archivo}",
        "-- Requiere fuentes otros_* (incluido abajo si falta en Supabase)",
        "",
        "begin;",
        "",
        "insert into public.fuentes_precio (id, nombre, tipo, metodo, notas) values",
        "  ('otros_compra', 'Otros (compra)', 'compra', 'manual', 'Promedio de mercado o consulta manual (Claude, Google, etc.)'),",
        "  ('otros_venta', 'Otros (venta)', 'venta', 'manual', 'Promedio de mercado o consulta manual (Claude, Google, etc.)')",
        "on conflict (id) do update set",
        "  nombre = excluded.nombre,",
        "  tipo = excluded.tipo,",
        "  metodo = excluded.metodo,",
        "  notas = excluded.notas;",
        "",
    ]
    for fuente, rows in sorted(grouped.items()):
        block = generate_sql(fuente, fecha, archivo, rows)
        inner = block.split("begin;", 1)[1].rsplit("commit;", 1)[0].strip()
        parts.append(f"-- ── {fuente} ({len(rows)} filas) ──")
        parts.append(inner)
        parts.append("")
    parts.extend(["commit;", ""])
    return "\n".join(parts)


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
                "notas": m.get("notas") or None,
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
    parser.add_argument("--fuente", default="similares", choices=list(FUENTE_TIPO.keys()),
                        help="Fuente por defecto si el CSV no trae columna fuente")
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
    grouped = group_by_fuente(matched)
    alta = sum(1 for m in matched if m["confianza"] >= 85)
    media = sum(1 for m in matched if 70 <= m["confianza"] < 85)
    print(f"Matches: {len(matched)} (alta confianza ≥85: {alta}, media 70–84: {media})")
    for fuente, rows in sorted(grouped.items()):
        print(f"  {fuente}: {len(rows)} filas")

    if args.dry_run:
        for m in matched[:15]:
            print(f"  [{m['confianza']}%] {m.get('sku')} ← {m.get('nombre_fuente','')[:50]}")
        if len(matched) > 15:
            print(f"  … y {len(matched) - 15} más")
        return

    multi = len(grouped) > 1
    date_tag = args.fecha.replace("-", "")
    stem = args.archivo.stem
    batch_suffix = ""
    if re.search(r"_\d+$", stem) and not stem.endswith(date_tag):
        batch_suffix = "_" + stem.rsplit("_", 1)[-1]
    if multi:
        sql_text = generate_sql_multi(args.fecha, args.archivo.name, grouped)
        out_name = f"import_referencias_consolidado_{date_tag}{batch_suffix}.sql"
    else:
        fuente = next(iter(grouped)) if grouped else args.fuente
        sql_text = generate_sql(fuente, args.fecha, args.archivo.name, matched)
        out_name = f"import_referencias_{fuente}_{args.fecha.replace('-', '')}.sql"
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_sql = OUT_DIR / out_name
    out_sql.write_text(sql_text, encoding="utf-8")
    print(f"SQL generado: {out_sql}")

    if args.apply:
        print("Aplicando vía REST…")
        ensure_fuentes(url, key, set(grouped.keys()))
        for fuente, rows in sorted(grouped.items()):
            print(f"  Fuente {fuente} ({len(rows)} filas)…")
            apply_rest(url, key, fuente, args.fecha, args.archivo.name, rows)
        print("Listo.")
    elif not args.sql_only:
        print("Ejecuta el SQL en Supabase o re-corre con --apply")


if __name__ == "__main__":
    main()
