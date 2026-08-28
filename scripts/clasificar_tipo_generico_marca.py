#!/usr/bin/env python3
"""Clasifica productos.tipo: generico vs marca (patente / marca de origen).

En el POS el valor de patente es `marca` (no existe 'patente' en el enum de UI).
"""
from __future__ import annotations

import json
import os
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from parse_nombre_producto import _looks_generic  # noqa: E402

GENERIC_LABS = {
    "amsa", "antibioticos de mexico", "antibioticos de mexico", "avitus",
    "be advance", "beadvance", "maver", "mavi", "ultra", "novag", "son's", "sons",
    "quifa", "iquifa", "biomep", "loeffler", "loeffler russek", "bruluart",
    "alpharma", "nucitec", "serral", "liferpal", "liferpal md", "psicofarma",
    "tempus", "wermar", "randall", "jayor", "progela", "exakta",
    "hispanoamericana", "farmacos continentales", "quimpharma", "dentilab",
    "wandel", "columbia", "solara", "ifa", "avivia", "gel pharma", "gelpharma",
    "suanca", "neolpharma", "cmd", "quimica son s", "quimica son's",
    "ultra laboratorios", "laboratorios ultra", "collins",
}

HOUSE_MARCA = {
    "mercurio", "edigar", "playboy", "sensimedical", "sensi medical",
    "jaloma", "protec", "dibar", "quirmex", "degasa", "cintapore",
    "sumitex", "codifarma",
}

# Marcas de origen / OTC de patente. No incluir labs genéricos ni similares.
PATENT_BRANDS = {
    "tempra", "tylenol", "advil", "aspirina", "cafiaspirina", "alka seltzer",
    "flanax", "saridon", "syncol", "agrifen", "desenfriol", "desenfriolito",
    "tabcin", "antiflu", "antiflu des", "xl 3", "xl3", "afrin", "vick", "vicks",
    "vaporub", "neurobion", "dolo neurobion", "bedoyecta", "buscapina",
    "electrolit", "pedialyte", "suerox", "ensure", "pediasure",
    "glucerna", "centrum", "lomecan", "asepxia", "vitacilina", "hipoglos",
    "bepanthen", "bepanthol", "graneodin", "microdacyn", "lotrimin", "canesten",
    "imodium", "pepto", "enterogermina", "smecta", "gaviscon", "redoxon",
    "berocca", "pharmaton", "nexium", "losec", "prilosec", "nizoral",
    "diflucan", "flagyl", "bactrim", "augmentin", "amoxil", "zithromax",
    "cataflam", "voltaren", "ponstan", "dolac", "viagra", "cialis", "levitra",
    "norvasc", "lipitor", "crestor", "cozaar", "aprovel", "yasmin", "diane",
    "microgynon", "primolut", "postinor", "plan b",
    "motrin", "nyquil", "theraflu", "bisolvon", "lomotil", "picot",
    "histiacil", "sedalmerck", "nazil", "treda", "tukol", "pasta lassar",
    "vaseline", "faseline", "moco de gorila", "mertiolate", "ultra bengue",
    "iodex", "riopan", "contac", "aderogyl",
    "hinds", "nivea", "axe", "rexona", "dove", "pantene", "sedal", "colgate",
    "oral b", "listerine", "sensodyne", "palmolive", "obao", "grisi", "escudo",
    "mennen", "fructis", "caprice", "ponds", "lubriderm", "teatrical",
    "herbal essences", "head shoulders", "old spice", "labello", "evenflo",
    "nestle", "nido", "nan", "nestum", "prudence", "trojan", "sico", "huggies",
    "kotex", "saba", "naturella", "kleenex", "ricitos de oro", "ajolotius",
    "broncolin", "dermodine", "tio nacho",
    "bayer", "kenvue", "abbott", "chinoin", "sanfer", "liomont", "senosiain",
    "armstrong", "genomma", "opella", "johnson",
}

ORIGINATOR_LABS = {
    "bayer", "pfizer", "gsk", "glaxosmithkline", "roche", "novartis",
    "astrazeneca", "sanofi", "boehringer", "merck", "msd", "lilly", "abbott",
    "abbvie", "chinoin", "sanfer", "liomont", "senosiain", "armstrong",
    "silanes", "genomma", "kenvue", "johnson", "opella", "reckitt",
}

CONSUMER_CATS = {
    "higiene", "cuidado personal", "abarrotes", "bebidas", "minisuper",
    "hidratacion", "hidratación",
}

MED_CATS = {
    "medicamentos", "medicamento", "analgésico", "analgesico", "antiinflamatorio",
    "antibiótico", "antibiotico", "gastro", "diabetes", "hipertensión",
    "hipertension", "alergia", "vitaminas", "suplemento", "herbolario",
    "cardiovascular", "respiratorio", "hormonales",
}


def fold(s: str) -> str:
    s = unicodedata.normalize("NFD", s or "")
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    return re.sub(r"[^a-z0-9]+", " ", s.lower()).strip()


def has_brand(blob: str, brands: set[str]) -> str | None:
    padded = f" {blob} "
    for b in sorted(brands, key=len, reverse=True):
        if f" {b} " in padded:
            return b
    return None


def clasificar(p: dict) -> str:
    nombre_f = fold(p.get("nombre") or "")
    marca_f = fold(p.get("marca") or "")
    pa_f = fold(p.get("principio_activo") or "")
    cat_f = fold(p.get("categoria") or "")
    sku = str(p.get("sku") or "")
    blob = f"{nombre_f} {marca_f}"

    hit = has_brand(blob, PATENT_BRANDS)
    if hit:
        return "marca"

    if marca_f in HOUSE_MARCA:
        return "marca"

    if sku.upper().startswith("EQ-"):
        return "generico"

    if marca_f in GENERIC_LABS or has_brand(marca_f, GENERIC_LABS):
        return "generico"

    first = (nombre_f.split() or [""])[0]
    if first == "next":
        return "marca"
    if first and first not in {"vaseline", "listerine", "iodine"} and (
        _looks_generic(first) or (pa_f and first == pa_f.split()[0])
    ):
        return "generico"

    if cat_f in CONSUMER_CATS:
        return "marca"

    if marca_f in ORIGINATOR_LABS:
        return "marca"

    if cat_f in MED_CATS or cat_f in {"otro", "producto", "productos", "general"}:
        # Similar / genérico de marca (Cefagen, Valclan, Acetif…).
        if cat_f in MED_CATS:
            return "generico"

    if cat_f in {"botiquin", "dispositivo medico", "dispositivo médico"}:
        return "marca"

    actual = (p.get("tipo") or "generico").lower()
    if actual in {"marca", "generico"}:
        return actual
    return "generico"


def load_env() -> None:
    for name in (".env", ".env.local"):
        p = ROOT / name
        if not p.exists():
            continue
        for line in p.read_text().splitlines():
            t = line.strip()
            if not t or t.startswith("#") or "=" not in t:
                continue
            k, v = t.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))


def fetch_all(url: str, key: str) -> list[dict]:
    import urllib.parse
    import urllib.request

    rows, offset = [], 0
    while True:
        qs = urllib.parse.urlencode({
            "select": "id,sku,nombre,marca,principio_activo,tipo,categoria,activo",
            "activo": "eq.true",
            "order": "id",
            "offset": offset,
            "limit": 1000,
        })
        req = urllib.request.Request(
            f"{url}/rest/v1/productos?{qs}",
            headers={"apikey": key, "Authorization": f"Bearer {key}"},
        )
        with urllib.request.urlopen(req) as resp:
            chunk = json.loads(resp.read().decode())
        rows.extend(chunk)
        if len(chunk) < 1000:
            break
        offset += 1000
    return rows


def patch_skus(url: str, key: str, skus: list[str], tipo: str) -> None:
    import urllib.parse
    import urllib.request

    for i in range(0, len(skus), 40):
        chunk = skus[i : i + 40]
        listed = ",".join('"' + s.replace('"', "") + '"' for s in chunk)
        qs = urllib.parse.quote(f"sku=in.({listed})", safe='=,()"')
        req = urllib.request.Request(
            f"{url}/rest/v1/productos?{qs}",
            data=json.dumps({"tipo": tipo}).encode(),
            method="PATCH",
            headers={
                "apikey": key,
                "Authorization": f"Bearer {key}",
                "Content-Type": "application/json",
                "Prefer": "return=minimal",
            },
        )
        with urllib.request.urlopen(req) as resp:
            resp.read()


def main() -> int:
    apply = "--apply" in sys.argv
    load_env()
    url = (os.environ.get("SUPABASE_URL") or os.environ.get("REACT_APP_SUPABASE_URL") or "").rstrip("/")
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or ""
    productos = fetch_all(url, key)

    to_gen, to_mar, same = [], [], []
    all_gen, all_mar = [], []
    for p in productos:
        want = clasificar(p)
        actual = (p.get("tipo") or "").lower()
        (all_gen if want == "generico" else all_mar).append(p)
        if actual != want:
            (to_gen if want == "generico" else to_mar).append(p)
        else:
            same.append(p)

    print(f"activos={len(productos)} igual={len(same)} →generico={len(to_gen)} →marca={len(to_mar)}")
    print("\n=== a GENÉRICO (hoy mal como marca/otro) ===")
    for p in to_gen:
        print(f"  {p['sku']:<16} {p.get('tipo'):<12} {p.get('marca') or '-':<18} {p['nombre'][:55]}")
    print("\n=== a MARCA/PATENTE (hoy mal como genérico) ===")
    for p in to_mar:
        print(f"  {p['sku']:<16} {p.get('tipo'):<12} {p.get('marca') or '-':<18} {p['nombre'][:55]}")

    fichas = (ROOT / "sql" / "patch_fichas_huecas_20260818.sql").read_text()
    if fichas.rstrip().endswith("commit;"):
        fichas = fichas[: fichas.rstrip().rfind("commit;")].rstrip() + "\n"

    lines = [fichas, "", "-- ── Tipo: genérico vs marca (patente de origen) ──────────────", ""]

    def emit(skus: list[str], tipo: str, comment: str) -> None:
        lines.append(f"-- {comment} ({len(skus)})")
        for i in range(0, len(skus), 80):
            chunk = skus[i : i + 80]
            listed = ", ".join("'" + s.replace("'", "''") + "'" for s in chunk)
            lines.append("update public.productos")
            lines.append(f"   set tipo = '{tipo}'")
            lines.append(f" where sku in ({listed})")
            lines.append(f"   and coalesce(tipo, '') is distinct from '{tipo}';")
            lines.append("")

    emit([p["sku"] for p in all_gen], "generico", "Similares / INN / laboratorio genérico")
    emit([p["sku"] for p in all_mar], "marca", "Patente u OTC de origen (valor UI: marca)")
    lines.append("commit;")

    out = ROOT / "sql" / "patch_fichas_huecas_y_tipo_20260818.sql"
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"\nSQL → {out}")

    if apply:
        patch_skus(url, key, [p["sku"] for p in to_gen], "generico")
        patch_skus(url, key, [p["sku"] for p in to_mar], "marca")
        print(f"aplicado generico={len(to_gen)} marca={len(to_mar)}")
    else:
        print("dry-run · pasa --apply para escribir tipo en vivo")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
