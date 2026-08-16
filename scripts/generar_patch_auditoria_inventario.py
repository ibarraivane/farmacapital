#!/usr/bin/env python3
"""Genera sql/patch_auditoria_inventario_datos_20260816.sql desde el catálogo vivo."""
from __future__ import annotations

import math
import re
from collections import defaultdict
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "sql" / "patch_auditoria_inventario_datos_20260816.sql"

RULES = [
    ("Respiratorio", r"ambroxol|bromhexina|dextrometorfano|salbutamol|levodropropizina|dropropizina|bisolvon|antiflu|tabcin|theraflu|desenfriol|xl-?3|supratex|collifrin|oximetazolina|nesajar"),
    ("Cardiovascular", r"atorvastatina|simvastatina|rosuvastatina|clopidogrel|warfarina|\baas\b|acido acetilsalicilico 100|ácido acetilsalicílico 100"),
    ("Antibiótico", r"amoxicilina|amoxicil|clavul[aá]nico|ciprofloxacino|cefalexina|cefuroxima|ceftriaxona|cefotaxima|cefagen|cefaroxil|eferox|clindamicina|azitromicina|levofloxacino|ampicilina|dicloxacilina|trimetoprim|sulfametoxazol|metronidazol|gentamicina|amikacina|claritromicina|doxiciclina|fasiclor|clamoxin|valclan|gimalxina|ramcinet"),
    ("Analgésico", r"aspirina|cafiaspirina|naproxeno|ibuprofeno|ibupro|paracetamol|ketorolaco|diclofen|flanax|tempra|sedalmerck|brunadol|alliviax"),
    ("Antiinflamatorio", r"piroxicam|meloxicam|indometacina|celecoxib"),
    ("Gastro", r"omeprazol|pantoprazol|lansoprazol|ranitidina|loperamida|simeticona|magaldrato|dimeticona|alka.?seltzer|riopan|treda|melox plus|sal de uvas|galaver|mornin|trimebut|metoclopramida|ursodesoxicol|lomotil"),
    ("Diabetes", r"metformina|glimepirida|gliclazida|pioglitazona|zukedib|insulina(?!.*(jeringa|aguja))"),
    ("Hipertensión", r"enalapril|losart[aá]n|irbesart[aá]n|amlodipino|telmisart[aá]n|valsart[aá]n|captopril|nifedipino"),
    ("Alergia", r"loratadina|cetirizina|fexofenadina|clorfenamina|desloratadina"),
    ("Vitaminas", r"vitamina|redoxon|complejo b|neurobion|pharmaton|centrum|supradyn"),
    ("Suplemento", r"gelcavit|col[aá]geno|ensure|glucerna|omega.?3|calcio|hierro|prote[ií]na|la.?femme|pleniform"),
    ("Herbolario", r"[aá]rnica|manzanilla|eucalipto|eucalin|bicarbonato|mercurio|haba alcanfor|borax|bismuto|magnesia anisada|sulfatiazol"),
    ("Hidratación", r"electrolit|suero|cloruro de sodio|soluci[oó]n cs|pedialyte|vida suero"),
    ("Dispositivo médico", r"jeringa|aguja|cintapore|cinta.?microporosa|guante|gasas?|sonda|cat[eé]ter|normogotero"),
    ("Botiquín", r"curita|venda|tela adhesiva|micropore|perilla|algod[oó]n|alcohol|merthiolate|mertiolate|agua oxigenada|isodine"),
    ("Higiene", r"naturella|saba|toalla|pañal|diapro|jab[oó]n|shampoo|shampoo|pasta dental|hilo dental|enjuague"),
    ("Cuidado personal", r"dove|nivea|desodorante|obao|rastrillo|crema corporal|protector solar|sol.?sun|fotosun|bloqueador"),
    ("Bebidas", r"coca.?cola|pepsi|agua ciel|bonafont|jugo|electrolit sabor"),
]


def load_env():
    env = {}
    for line in (ROOT / ".env").read_text().splitlines():
        if "=" in line and not line.strip().startswith("#"):
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip().strip('"').strip("'")
    return env


def fetch_productos(url, headers):
    rows = []
    offset = 0
    while True:
        r = requests.get(
            f"{url}/rest/v1/productos",
            headers={**headers, "Range": f"{offset}-{offset+999}"},
            params={"select": "*", "activo": "eq.true", "order": "id.asc"},
            timeout=60,
        )
        r.raise_for_status()
        chunk = r.json()
        if not chunk:
            break
        rows.extend(chunk)
        if len(chunk) < 1000:
            break
        offset += 1000
    return rows


def fetch_refs(url, headers, ids):
    out = defaultdict(list)
    for i in range(0, len(ids), 80):
        part = ids[i : i + 80]
        r = requests.get(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=headers,
            params={
                "select": "producto_id,fuente,tipo,precio",
                "producto_id": f"in.({','.join(map(str, part))})",
                "tipo": "eq.venta",
            },
            timeout=60,
        )
        if r.status_code != 200:
            continue
        for row in r.json():
            try:
                out[int(row["producto_id"])].append(float(row["precio"]))
            except (TypeError, ValueError, KeyError):
                pass
    return out


def fnum(x):
    try:
        return float(x or 0)
    except (TypeError, ValueError):
        return 0


def sql_str(s):
    return "'" + str(s).replace("'", "''") + "'"


def hay(p, rx):
    blob = " ".join(
        str(p.get(k) or "")
        for k in ("nombre", "principio_activo", "denominacion_generica")
    )
    return re.search(rx, blob, re.I) is not None


def sugerir_cat(p):
    cur = (p.get("categoria") or "").strip()
    official = {
        "Analgésico",
        "Antiinflamatorio",
        "Antibiótico",
        "Gastro",
        "Diabetes",
        "Hipertensión",
        "Alergia",
        "Vitaminas",
        "Suplemento",
        "Herbolario",
        "Hidratación",
        "Cardiovascular",
        "Respiratorio",
        "Dispositivo médico",
        "Botiquín",
        "Higiene",
        "Bebidas",
        "Básicos",
        "Abarrotes",
        "Minisuper",
        "Cuidado personal",
    }
    alias = {
        "Botiquin": "Botiquín",
        "Suplementos": "Suplemento",
        "Digestivo": "Gastro",
        "Bebes": "Higiene",
        "Bebés": "Higiene",
    }
    if cur in alias:
        return alias[cur], "alias"
    dump = cur in {"Medicamentos", "Medicamento", "Otro", "Producto", "Productos", "GENERAL", ""}
    if cur in official and not dump:
        return None, "ok"
    for cat, rx in RULES:
        if hay(p, rx):
            return cat, "regla"
    if cur == "Medicamento":
        return None, "sin_regla"
    return None, "sin_regla"


def main():
    env = load_env()
    url = env["REACT_APP_SUPABASE_URL"].rstrip("/")
    anon = env["REACT_APP_SUPABASE_ANON_KEY"]
    h = {"apikey": anon, "Authorization": f"Bearer {anon}"}
    rows = fetch_productos(url, h)
    refs = fetch_refs(url, h, [p["id"] for p in rows])
    by_sku = {p["sku"]: p for p in rows if p.get("sku")}
    ean_map = defaultdict(list)
    for p in rows:
        ean = (p.get("codigo_barras") or "").strip()
        if ean:
            ean_map[ean].append(p)

    lines = [
        "-- Auditoría inventario 16-ago-2026",
        "-- Idempotente. No borra productos ni referencias de precio.",
        "-- Ejecutar en Supabase SQL Editor.",
        "",
        "begin;",
        "",
        "-- 1) Jeringas SensiMedical: el SKU es la PIEZA. Costo de caja invertido.",
        "",
    ]

    jeringas = [
        ("FC-22300881", 137.39, 100),
        ("FC-22300775", 139.50, 100),
        ("FMX-307657", 217.55, 100),
        ("FMX-307658", 204.96, 50),
        ("FMX-506389", 148.06, 100),
        ("FMX-506388", 139.50, 100),
        ("FMX-506386", 148.06, 100),
    ]
    for sku, costo_caja, upc in jeringas:
        p = by_sku.get(sku)
        if not p:
            lines.append(f"-- skip {sku}: no está en catálogo activo")
            continue
        costo = fnum(p["costo"])
        precio = fnum(p["precio"])
        if costo > precio and costo > 20:
            pieza = round(costo / upc, 2)
        else:
            pieza = round(costo_caja / upc, 2)
        pvp = max(math.ceil(pieza * 1.6), math.ceil(precio) if precio > 0.01 else 0)
        lines.append(
            "update public.productos set\n"
            f"  costo = {pieza},\n"
            f"  precio = {pvp},\n"
            "  venta_unidad = false,\n"
            "  precio_unidad = 0,\n"
            "  price_needs_review = false\n"
            f"where sku = {sql_str(sku)}\n"
            f"  and costo > precio and costo > 20;"
        )
        lines.append(
            "update public.lotes l set costo_unitario = p.costo\n"
            "from public.productos p\n"
            f"where l.producto_id = p.id and p.sku = {sql_str(sku)}\n"
            "  and coalesce(l.costo_unitario, 0) > coalesce(p.costo, 0) * 10;"
        )
        lines.append("")

    lines += [
        "-- 2) Mercurio óxido de zinc: costo de caja / 50 piezas",
        "update public.productos set",
        "  costo = round(costo / nullif(unidades_por_caja, 0), 2),",
        "  price_needs_review = true",
        "where sku = 'FC-0ACC5B6A'",
        "  and venta_unidad = true",
        "  and coalesce(unidades_por_caja, 0) > 1",
        "  and costo > precio;",
        "",
        "-- 3) Familia Aspirina / Alka-Seltzer (se reaplica al final para no pisarla)",
        "",
        "-- 4) Aliases de categoría",
        "update public.productos set categoria = 'Botiquín' where categoria = 'Botiquin';",
        "update public.productos set categoria = 'Suplemento' where categoria = 'Suplementos';",
        "update public.productos set categoria = 'Gastro' where categoria = 'Digestivo';",
        "update public.productos set categoria = 'Higiene' where categoria in ('Bebes', 'Bebés');",
        "",
    ]

    recat = []
    for p in rows:
        cat, why = sugerir_cat(p)
        if cat and why in {"regla", "alias"} and cat != (p.get("categoria") or ""):
            recat.append((p, cat, why))

    lines.append(f"-- 5) Recategorización por nombre/PA ({len(recat)} SKUs)")
    by_cat = defaultdict(list)
    for p, cat, why in recat:
        if why == "alias":
            continue
        by_cat[cat].append(p["sku"])
    for cat, skus in sorted(by_cat.items()):
        for i in range(0, len(skus), 40):
            chunk = ", ".join(sql_str(s) for s in skus[i : i + 40])
            lines.append(
                f"update public.productos set categoria = {sql_str(cat)}\n"
                f"where sku in ({chunk})\n"
                f"  and categoria is distinct from {sql_str(cat)};"
            )
        lines.append("")

    lines.append("-- 6) Precio de venta donde hay costo y el PVP está en cero")
    for p in rows:
        pr, co = fnum(p["precio"]), fnum(p["costo"])
        if pr > 0.01 or co <= 0.01:
            continue
        ref = refs.get(p["id"]) or []
        if ref:
            pvp = int(math.ceil(max(ref)))
        else:
            pvp = int(math.ceil(co * 1.6))
        if pvp < 1:
            continue
        lines.append(
            "update public.productos set\n"
            f"  precio = {pvp},\n"
            "  price_needs_review = true\n"
            f"where sku = {sql_str(p['sku'])}\n"
            "  and coalesce(precio, 0) <= 0.01\n"
            f"  and coalesce(costo, 0) > 0.01;"
        )
    lines.append("")

    lines.append("-- 7) Precio desde referencia de mercado (sin costo)")
    for p in rows:
        pr, co = fnum(p["precio"]), fnum(p["costo"])
        if pr > 0.01 or co > 0.01:
            continue
        ref = refs.get(p["id"]) or []
        if not ref:
            continue
        pvp = int(math.ceil(max(ref)))
        lines.append(
            "update public.productos set\n"
            f"  precio = {pvp},\n"
            "  price_needs_review = true\n"
            f"where sku = {sql_str(p['sku'])}\n"
            "  and coalesce(precio, 0) <= 0.01;"
        )
    lines.append("")

    lines.append("-- 8) EAN duplicados: se deja el más completo; al sombra se le quita el código")
    for ean, ps in sorted(ean_map.items()):
        if len(ps) < 2:
            continue
        scored = []
        for p in ps:
            score = 0
            sku = p.get("sku") or ""
            tail = re.sub(r"\D", "", sku)[-8:]
            if tail and ean.endswith(tail):
                score += 20
            if fnum(p["precio"]) > 0.01:
                score += 3
            if fnum(p["costo"]) > 0.01:
                score += 2
            if (p.get("nombre") or "").count(" ") >= 2:
                score += 1
            if fnum(p.get("stock")) > 0:
                score += 1
            scored.append((score, p))
        scored.sort(key=lambda x: (-x[0], x[1]["id"]))
        keep = scored[0][1]
        for _, p in scored[1:]:
            n1 = re.sub(r"\W+", " ", (p.get("nombre") or "").lower()).strip()
            n2 = re.sub(r"\W+", " ", (keep.get("nombre") or "").lower()).strip()
            same_family = n1 == n2
            if same_family:
                lines.append(
                    "-- sombra de "
                    f"{keep['sku']} {keep['nombre'][:40]}"
                )
                lines.append(
                    "update public.productos set\n"
                    "  codigo_barras = null,\n"
                    "  activo = false,\n"
                    "  price_needs_review = true\n"
                    f"where sku = {sql_str(p['sku'])}\n"
                    f"  and codigo_barras = {sql_str(ean)}\n"
                    f"  and sku is distinct from {sql_str(keep['sku'])};"
                )
            else:
                lines.append(
                    f"-- colisión distinta: {p['sku']} {p['nombre'][:40]} vs {keep['sku']}"
                )
                lines.append(
                    "update public.productos set\n"
                    "  codigo_barras = null,\n"
                    "  price_needs_review = true\n"
                    f"where sku = {sql_str(p['sku'])}\n"
                    f"  and codigo_barras = {sql_str(ean)};"
                )
        lines.append("")

    # EAN from sibling / SKU tail
    lines.append("-- 9) Códigos de barras recuperables (SKU FC-XXXXXXXX → EAN 7501… si un hermano lo confirma)")
    missing = [p for p in rows if not (p.get("codigo_barras") or "").strip()]
    used = {e for e in ean_map}
    filled = 0
    for p in missing:
        sku = p.get("sku") or ""
        m = re.fullmatch(r"FC-(\d{8})", sku)
        if not m:
            continue
        tail = m.group(1)
        candidates = []
        for ean, ps in ean_map.items():
            if ean.endswith(tail) and 12 <= len(ean) <= 14:
                candidates.append(ean)
        if len(candidates) != 1:
            continue
        ean = candidates[0]
        if ean in used:
            continue
        used.add(ean)
        filled += 1
        lines.append(
            "update public.productos set codigo_barras = "
            f"{sql_str(ean)}\n"
            f"where sku = {sql_str(sku)}\n"
            "  and (codigo_barras is null or btrim(codigo_barras) = '');"
        )
    lines.append(f"-- recuperados por cola de SKU: {filled}")
    lines.append("")
    lines += [
        "-- 11) Aspirina / Alka al final (no las pisa otra regla)",
        "update public.productos set categoria = 'Analgésico'",
        "where activo = true and categoria is distinct from 'Analgésico'",
        "  and nombre ~* 'aspirina|cafiaspirina';",
        "update public.productos set categoria = 'Gastro'",
        "where activo = true and categoria is distinct from 'Gastro'",
        "  and nombre ~* 'alka.?seltzer';",
        "update public.productos set categoria = 'Cardiovascular'",
        "where activo = true and categoria is distinct from 'Cardiovascular'",
        "  and nombre ~* 'acetilsalic' and nombre ~* '100\\s*mg';",
        "",
    ]

    # FMX known EANs from previous patch / photos
    known_ean = {
        "FMX-302884": "7502009749063",  # Sol Sun
        "FMX-501003": None,
        "FMX-500998": None,
        "FMX-501000": None,
        "FMX-301136": "7506484500546",  # Cintapore piel 2.5x5 — SKU foto FC-84500546
        "FMX-504321": None,
    }
    fc_cintapore = by_sku.get("FC-84500546")
    if fc_cintapore and (fc_cintapore.get("codigo_barras") or "").strip():
        known_ean["FMX-301136"] = fc_cintapore["codigo_barras"].strip()

    lines.append("-- 10) EAN conocidos de altas/fotos")
    for sku, ean in known_ean.items():
        if not ean or sku not in by_sku:
            continue
        if ean in used and sku not in {p["sku"] for p in ean_map.get(ean, [])}:
            # already owned by another active SKU — skip
            owners = ean_map.get(ean) or []
            if owners:
                lines.append(f"-- skip {sku}: EAN {ean} ya lo tiene {owners[0]['sku']}")
                continue
        lines.append(
            "update public.productos set codigo_barras = "
            f"{sql_str(ean)}\n"
            f"where sku = {sql_str(sku)}\n"
            "  and (codigo_barras is null or btrim(codigo_barras) = '');"
        )
    lines.append("")

    lines += [
        "commit;",
        "",
        "-- Verificación rápida",
        "select categoria, count(*) from public.productos where activo group by 1 order by 2 desc;",
        "select count(*) filter (where coalesce(precio,0) <= 0.01) as sin_precio,",
        "       count(*) filter (where codigo_barras is null or btrim(codigo_barras)='') as sin_ean",
        "from public.productos where activo;",
    ]

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {OUT} ({len(recat)} recategorizaciones, {len(rows)} activos)")


if __name__ == "__main__":
    main()
