#!/usr/bin/env python3
"""Importa fichas Marzam (PDF) → producto_precios_referencia (compra).

El PDF de «Fichas» exporta mal los EAN (notación científica de Excel), así que el
cruce es por coincidencia revisada nombre/presentación (mapa MANUAL + CSV matched).

  python3 scripts/importar_marzam_fichas.py --dry-run
  python3 scripts/importar_marzam_fichas.py --sql-only
  python3 scripts/importar_marzam_fichas.py --apply
"""
from __future__ import annotations

import argparse
import csv
import os
import re
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql" / "pricing" / "generated"
CSV_LISTA = ROOT / "pricing" / "precios_proveedores" / "Marzam_fichas_202609.csv"
CSV_MATCHED = ROOT / "pricing" / "importados" / "import_marzam_fichas_202609_matched.csv"
DEFAULT_PDF = ROOT / "pricing" / "precios_proveedores" / "Marzam_fichas_202609.pdf"
FECHA_LISTA = "2026-09-01"
FUENTE = "marzam"

# Coincidencias revisadas a mano (misma marca / misma presentación).
# Ampliá este mapa cuando haya más fichas o un Excel con EAN legibles.
MANUAL_SKU = {
    "ACEMETACINA 90MG CAPS C14": "FC-C9F4ACCC",
    "ACICLOVIR 400MG TAB C35": "FC-FD845E68",
    "AFLUSIL 120ML": "FC-11780359",
    "AGRIFEN TAB C10": "FC-25116810",
    "ALIN AMP 2ML C1": "FC-8505003",
    "ALLI-TRIPLE TAB C10": "FC-053610",
    "ALLIVIAX 550MG TAB C10": "FC-40013805",
    "AMCEF IM 1G IM 3.5ML": "FC-BE76D409",
    "AMCEF IM 500MG SOL 2ML": "FC-07F04F88",
    "AMLODIPINO 5MG TAB C100": "FC-4A0245DA",
    "AMLODIPINO 5MG TAB C30": "FC-3B001F9B",
    "AMOXICILINA 500MG CAP C12": "FC-A0D320D1",
    "AMPICILINA 1G TAB C10": "FC-F82A6E4B",
    "ANARA TAB C20": "FC-88508929",
    "ANTIFLU DES CAP C24": "FC-01508201",
    "ANTIFLU DES JR SOL 60ML": "FC-85097661",
    "ANTIFLU DES PED 30ML": "FL-8509810",
}


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


def fetch_productos(url: str, key: str) -> dict[str, dict]:
    import requests

    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    rows: list[dict] = []
    offset = 0
    while True:
        h = {**headers, "Range": f"{offset}-{offset + 999}"}
        r = requests.get(
            f"{url}/rest/v1/productos",
            headers=h,
            params={
                "select": "id,sku,nombre,marca,presentacion,codigo_barras,costo,activo",
                "activo": "eq.true",
                "order": "id.asc",
            },
            timeout=60,
        )
        r.raise_for_status()
        batch = r.json()
        rows.extend(batch)
        if len(batch) < 1000:
            break
        offset += 1000
    return {p["sku"]: p for p in rows if p.get("sku")}


def leer_lista_csv(path: Path) -> list[dict]:
    rows = []
    with path.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            try:
                precio = float(row["precio"])
            except (KeyError, TypeError, ValueError):
                continue
            if precio <= 0:
                continue
            rows.append(row)
    return rows


def matchear(lista: list[dict], by_sku: dict[str, dict]) -> tuple[list[dict], list[dict]]:
    matched: list[dict] = []
    unmatched: list[dict] = []
    used: set[int] = set()
    for row in lista:
        desc = (row.get("descripcion") or "").strip()
        sku = MANUAL_SKU.get(desc)
        if not sku:
            unmatched.append(row)
            continue
        prod = by_sku.get(sku)
        if not prod or prod["id"] in used:
            unmatched.append(row)
            continue
        used.add(prod["id"])
        matched.append(
            {
                "producto_id": prod["id"],
                "sku": prod["sku"],
                "nombre_catalogo": prod.get("nombre"),
                "ean_fc": prod.get("codigo_barras") or "",
                "costo": prod.get("costo"),
                "nombre_fuente": desc,
                "sku_externo": (row.get("codigo_marzam") or "").strip(),
                "precio": round(float(row["precio"]), 2),
                "confianza": 100,
            }
        )
    return matched, unmatched


def sql_quote(s: str) -> str:
    return "'" + str(s).replace("'", "''") + "'"


def generate_sql(matched: list[dict], archivo: str) -> str:
    lines = [
        f"-- Marzam fichas {FECHA_LISTA} · {len(matched)} matches · precio farmacia con oferta",
        f"-- Archivo: {archivo}",
        "-- Generado: scripts/importar_marzam_fichas.py",
        "",
        "begin;",
        "",
        "insert into public.fuentes_precio (id, nombre, tipo, metodo, notas) values",
        "  ('marzam', 'Marzam', 'compra', 'import_archivo',",
        "   'Fichas / lista farmacia Marzam (precio con oferta). No es benchmark de mercado libre.')",
        "on conflict (id) do update set",
        "  nombre = excluded.nombre,",
        "  tipo = excluded.tipo,",
        "  metodo = excluded.metodo,",
        "  notas = excluded.notas;",
        "",
        "with imp as (",
        "  insert into public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)",
        f"  values ('marzam', 'compra', '{FECHA_LISTA}', {sql_quote(archivo)}, {len(matched)},",
        "          'importar_marzam_fichas.py · precio fcia con oferta · match revisado')",
        "  returning id",
        ")",
        "insert into public.producto_precios_referencia (",
        "  producto_id, fuente, tipo, precio, fecha, nombre_fuente, sku_externo,",
        "  confianza, origen, import_id, notas",
        ")",
        "select",
        f"  v.producto_id, 'marzam', 'compra', v.precio, '{FECHA_LISTA}'::date,",
        "  v.nombre_fuente, v.sku_externo, v.confianza, 'import_csv', imp.id,",
        "  'fichas sept-2026 · precio fcia con oferta'",
        "from imp, (values",
    ]
    value_rows = [
        f"  ({m['producto_id']}::bigint, {m['precio']}::numeric, "
        f"{sql_quote(m['nombre_fuente'])}, {sql_quote(m['sku_externo'])}, "
        f"{m['confianza']}::smallint)"
        for m in matched
    ]
    lines.append(",\n".join(value_rows))
    lines.extend(
        [
            ") as v(producto_id, precio, nombre_fuente, sku_externo, confianza);",
            "",
            "commit;",
            "",
        ]
    )
    return "\n".join(lines)


def apply_rest(url: str, key: str, matched: list[dict], archivo: str) -> int:
    import requests

    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=representation",
    }
    # fuentes_precio puede exigir service role; no bloquea el import
    requests.post(
        f"{url}/rest/v1/fuentes_precio",
        headers={**headers, "Prefer": "resolution=merge-duplicates,return=minimal"},
        json=[
            {
                "id": FUENTE,
                "nombre": "Marzam",
                "tipo": "compra",
                "metodo": "import_archivo",
                "notas": "Fichas / lista farmacia Marzam (precio con oferta).",
            }
        ],
        timeout=30,
    )

    imp = requests.post(
        f"{url}/rest/v1/importaciones_referencia",
        headers=headers,
        json={
            "fuente": FUENTE,
            "tipo": "compra",
            "fecha_lista": FECHA_LISTA,
            "archivo": archivo,
            "filas_ok": len(matched),
            "filas_error": 0,
            "notas": "importar_marzam_fichas.py · precio fcia con oferta · match revisado",
        },
        timeout=60,
    )
    imp.raise_for_status()
    import_id = imp.json()[0]["id"]

    for i in range(0, len(matched), 80):
        chunk = matched[i : i + 80]
        payload = [
            {
                "producto_id": m["producto_id"],
                "fuente": FUENTE,
                "tipo": "compra",
                "precio": m["precio"],
                "fecha": FECHA_LISTA,
                "nombre_fuente": m["nombre_fuente"],
                "sku_externo": m["sku_externo"],
                "confianza": m["confianza"],
                "origen": "import_csv",
                "import_id": import_id,
                "notas": "fichas sept-2026 · precio fcia con oferta",
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
        print(f"  Insertadas {min(i + 80, len(matched))}/{len(matched)}")
        time.sleep(0.1)
    return import_id


def escribir_matched_csv(matched: list[dict]) -> None:
    CSV_MATCHED.parent.mkdir(parents=True, exist_ok=True)
    with CSV_MATCHED.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "sku",
                "precio",
                "confianza",
                "nombre_fuente",
                "sku_externo",
                "ean_fc",
                "nombre",
                "costo",
            ],
        )
        w.writeheader()
        for m in matched:
            w.writerow(
                {
                    "sku": m["sku"],
                    "precio": m["precio"],
                    "confianza": m["confianza"],
                    "nombre_fuente": m["nombre_fuente"],
                    "sku_externo": m["sku_externo"],
                    "ean_fc": m.get("ean_fc") or "",
                    "nombre": m.get("nombre_catalogo") or "",
                    "costo": m.get("costo") if m.get("costo") is not None else "",
                }
            )


def main() -> int:
    parser = argparse.ArgumentParser(description="Importar fichas Marzam a referencias de compra")
    parser.add_argument("--lista-csv", type=Path, default=CSV_LISTA)
    parser.add_argument("--archivo-nombre", default=DEFAULT_PDF.name)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--sql-only", action="store_true")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()

    if not args.lista_csv.exists():
        sys.exit(
            f"No existe {args.lista_csv}. Parseá antes el PDF a CSV "
            f"(pricing/precios_proveedores/Marzam_fichas_202609.csv)."
        )

    env = cargar_env()
    url = env.get("REACT_APP_SUPABASE_URL") or env.get("SUPABASE_URL") or ""
    key = (
        env.get("SUPABASE_SERVICE_ROLE_KEY")
        or env.get("REACT_APP_SUPABASE_ANON_KEY")
        or ""
    )
    if not url or not key:
        sys.exit("Falta URL/key de Supabase en .env")

    print("Catálogo Supabase…")
    by_sku = fetch_productos(url, key)
    print(f"  {len(by_sku)} SKUs activos")

    lista = leer_lista_csv(args.lista_csv)
    print(f"Lista Marzam: {len(lista)} renglones")
    matched, unmatched = matchear(lista, by_sku)

    mas_barato = 0
    for m in matched:
        try:
            costo = float(m["costo"]) if m.get("costo") is not None else None
        except (TypeError, ValueError):
            costo = None
        if costo and m["precio"] < costo - 0.05:
            mas_barato += 1

    print(f"Matches revisados: {len(matched)}")
    print(f"Sin match: {len(unmatched)}")
    print(f"Más baratos que tu costo: {mas_barato}")
    for m in matched:
        print(f"  {m['sku']}  ${m['precio']:.2f}  {m['nombre_fuente']} → {m['nombre_catalogo']}")

    escribir_matched_csv(matched)
    print(f"CSV matched: {CSV_MATCHED}")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_sql = OUT_DIR / f"import_referencias_marzam_{FECHA_LISTA.replace('-', '')}.sql"
    out_sql.write_text(generate_sql(matched, args.archivo_nombre), encoding="utf-8")
    print(f"SQL: {out_sql}")

    if args.dry_run or (not args.apply and not args.sql_only):
        if not args.apply:
            print("Para cargar: python3 scripts/importar_marzam_fichas.py --apply")
        return 0

    if args.sql_only:
        return 0

    print("Aplicando…")
    import_id = apply_rest(url, key, matched, args.archivo_nombre)
    print(f"Listo. import_id={import_id}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
