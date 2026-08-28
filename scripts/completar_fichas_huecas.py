#!/usr/bin/env python3
"""Completa marca / presentación / principio activo en fichas huecas.

Fuentes, en este orden:
  1. OCR de portada (lotes fotografiadados) — PA entre paréntesis + lab
  2. Catálogo Levic (laboratorio + descripción)
  3. Parser del nombre Equilibrio (N Tab/Cap + concentración)

No pisa campos que ya tienen valor. Dry-run por defecto; --apply escribe en REST.
"""
from __future__ import annotations

import csv
import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from parse_nombre_producto import FORM_MAP, parse_nombre_producto  # noqa: E402

FORM_ES = {
    "TABLETA": ("tableta", "tabletas"),
    "CAPSULA": ("cápsula", "cápsulas"),
    "CAPSULAS": ("cápsula", "cápsulas"),
    "COMPRIMIDO": ("comprimido", "comprimidos"),
    "COMP": ("comprimido", "comprimidos"),
    "GRAGEA": ("gragea", "grageas"),
    "GRAG": ("gragea", "grageas"),
    "SUPOSITORIO": ("supositorio", "supositorios"),
    "OVULO": ("óvulo", "óvulos"),
    "OVULOS": ("óvulo", "óvulos"),
    "AMPOLLETA": ("ampolleta", "ampolletas"),
    "AMP": ("ampolleta", "ampolletas"),
    "FRASCO AMPULA": ("frasco ámpula", "frascos ámpula"),
    "FA": ("frasco ámpula", "frascos ámpula"),
    "SOLUCION": ("solución", "soluciones"),
    "SUSPENSION": ("suspensión", "suspensiones"),
    "JARABE": ("frasco", "frascos"),
    "CREMA": ("tubo", "tubos"),
    "GEL": ("tubo", "tubos"),
    "UNGUEENTO": ("tubo", "tubos"),
    "UNGUENTO": ("tubo", "tubos"),
}

LAB_CANON = {
    "AVITUS": "Avitus",
    "NOVAG": "Novag",
    "AMSA": "AMSA",
    "BE ADVANCE": "Be Advance",
    "BEADVANCE": "Be Advance",
    "MAVER": "Maver",
    "MAVI": "Mavi",
    "ULTRA": "Ultra",
    "SON'S": "Son's",
    "SON´S": "Son's",
    "SON´S": "Son's",
    "SONS": "Son's",
    "ANTIBIOTICOS DE MEXICO": "AMSA",
    "ANTIBIÓTICOS DE MÉXICO": "AMSA",
    "ANTIBIOTICOS DE MÉXICO": "AMSA",
    "FARMACOS CONT": "Fármacos Continentales",
    "FARMACOS CONTINENTALES": "Fármacos Continentales",
    "CMD": "CMD",
    "QUIFA": "Quifa",
    "IQUIFA": "Quifa",
    "BIOMEP": "Biomep",
    "LOEFFLER": "Loeffler",
    "BRULUART": "Bruluart",
    "BRULUAGSA": "Bruluart",
    "ALPHARMA": "Alpharma",
    "NUCITEC": "Nucitec",
    "SERRAL": "Serral",
    "LIFERPAL": "Liferpal",
    "PSICOFARMA": "Psicofarma",
    "TEMPUS": "Tempus",
    "IFA": "IFA",
    "AVIVIA": "Avivia",
    "WANDEL": "Wandel",
    "SOLARA": "Solara",
    "COLUMBIA": "Columbia",
    "PISA": "Pisa",
    "SANFER": "Sanfer",
    "CHINOIN": "Chinoin",
    "BAYER": "Bayer",
    "LIOMONT": "Liomont",
    "SENOSIAIN": "Senosiain",
    "SIEGfRIED": "Siegfried",
    "SIEGBFRIED": "Siegfried",
    "SIEGfRIED RHEIN": "Siegfried",
    "ULTRA LABORATORIOS": "Ultra",
}


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
            k, v = k.strip(), v.strip().strip('"').strip("'")
            os.environ.setdefault(k, v)


def blank(v) -> bool:
    return v is None or str(v).strip() == ""


def title_lab(s: str | None) -> str | None:
    if blank(s):
        return None
    raw = str(s).strip().replace("´", "'").replace("’", "'")
    u = re.sub(r"\s+", " ", raw).upper()
    u = re.sub(r"\bLABORATORIOS?\b", "", u).strip()
    if u in LAB_CANON:
        return LAB_CANON[u]
    if "GENERICO" in u and "NO CAPTURADO" in u:
        return None
    if len(u) <= 2:
        return None
    return raw.title() if raw.isupper() else raw


def caja_con(qty: int | str, forma: str) -> str:
    n = int(qty)
    key = forma.upper().replace("Á", "A").replace("É", "E").replace("Í", "I").replace("Ó", "O").replace("Ú", "U")
    key = key.replace("CAPSULA", "CAPSULA").rstrip("S")
    pair = None
    for k, v in FORM_ES.items():
        if k.replace("Á", "A") in key or key in k.replace("Á", "A"):
            pair = v
            break
    if pair is None:
        uno, muchos = forma.lower(), forma.lower() + ("s" if not forma.lower().endswith("s") else "")
    else:
        uno, muchos = pair
    palabra = uno if n == 1 else muchos
    if "ampolleta" in palabra or "ámpula" in palabra or "frasco" in palabra:
        return f"Caja con {n} {palabra}"
    return f"Caja con {n} {palabra}"


def fetch_all(url: str, key: str, select: str) -> list[dict]:
    import urllib.parse
    import urllib.request

    rows, offset = [], 0
    while True:
        qs = urllib.parse.urlencode({
            "select": select,
            "activo": "eq.true",
            "order": "id",
            "offset": offset,
            "limit": 1000,
        })
        req = urllib.request.Request(
            f"{url}/rest/v1/productos?{qs}",
            headers={
                "apikey": key,
                "Authorization": f"Bearer {key}",
                "Prefer": "count=exact",
            },
        )
        with urllib.request.urlopen(req) as resp:
            chunk = json.loads(resp.read().decode())
        rows.extend(chunk)
        if len(chunk) < 1000:
            break
        offset += 1000
    return rows


def load_fotos() -> dict[str, dict]:
    """sku/ean -> {pa, marca, presentacion, concentracion, forma, fuente}"""
    out: dict[str, dict] = {}
    photo_re = re.compile(r"^(?P<brand>.+?)\s+\((?P<pa>[^)]*)\)\s+(?P<body>.+)$")
    c_re = re.compile(
        r"\bC/\s*(\d+)(?!\s*mL)\b|"
        r"\bCaja(?:\s+de\s+cart[oó]n)?\s+con\s+(\d+)\s+"
        r"(?:tabletas?|c[áa]psulas?|comprimidos?|grageas?|óvulos?|ovulos?|ampolletas?)\b",
        re.I,
    )
    vol_re = re.compile(r"\bC/\s*(\d+(?:[.,]\d+)?)\s*mL\b", re.I)
    conc_re = re.compile(
        r"(\d+(?:[.,]\d+)?(?:\s*/\s*\d+(?:[.,]\d+)?)*)\s*(mg|mcg|g|ml|ui|%)(?:\s*/\s*(\d+(?:[.,]\d+)?)\s*(ml|mL))?",
        re.I,
    )
    forma_re = re.compile(
        r"\b(Tabletas?|C[áa]psulas?|Comprimidos?|Grageas?|Supositorios?|"
        r"[ÓO]vulos?|Suspensi[oó]n|Soluci[oó]n|Jarabe|Gotas|Crema|Gel|"
        r"Ung[üu]ento|Pomada|Inyectable|Frasco\s+[ÁA]mpula|Ampolleta)\b",
        re.I,
    )
    skip_sku_estados = {"otra_presentacion", "falso"}

    def store(key: str, rec: dict, rank: int) -> None:
        prev = out.get(key)
        if prev is None or rank > prev.get("_rank", 0):
            stored = dict(rec)
            stored["_rank"] = rank
            out[key] = stored

    for path in sorted((ROOT / "sql" / "generated").glob("*pares*.csv")):
        with path.open(newline="", encoding="utf-8") as f:
            for row in csv.DictReader(f):
                nombre = (row.get("nombre_foto") or "").strip()
                if not nombre:
                    continue
                estado = (row.get("estado") or "").strip()
                nota = (row.get("nota") or "").lower()
                rank = 1
                if estado in {"eq_sin_ean", "fc_sin_ean", "en_inventario", "corregido a mano"}:
                    rank = 3
                if estado in skip_sku_estados or nota.startswith("falso"):
                    rank = 0
                m = photo_re.match(nombre)
                rec: dict = {"fuente": path.name}
                if m:
                    pa = m.group("pa").strip()
                    body = m.group("body").strip()
                    if pa and pa not in {"", "?"}:
                        rec["pa"] = re.sub(r"\s*,\s*", " / ", pa).strip()
                    tokens = body.split()
                    if tokens:
                        rec["marca"] = title_lab(tokens[-1])
                    fm = forma_re.search(body)
                    if fm:
                        rec["forma"] = fm.group(1).title().replace("Capsula", "Cápsula")
                    vm = vol_re.search(body)
                    if vm:
                        rec["presentacion"] = f"Frasco con {vm.group(1)} mL"
                    else:
                        cm = c_re.search(body)
                        qty = next((g for g in cm.groups() if g), None) if cm else None
                        if qty and rec.get("forma"):
                            rec["presentacion"] = caja_con(qty, rec["forma"])
                        elif rec.get("forma") and re.search(r"tubo", body, re.I):
                            rec["presentacion"] = body.split(rec.get("marca") or "ZZZ")[0].strip()
                    km = conc_re.search(body)
                    if km:
                        rec["concentracion"] = re.sub(r"\s+", " ", km.group(0)).replace(",", ".")
                sku = (row.get("sku") or "").strip()
                ean = re.sub(r"\D", "", row.get("ean") or "")
                if sku and rank > 0:
                    store(f"sku:{sku}", rec, rank)
                if ean:
                    store(f"ean:{ean}", rec, max(rank, 2))
    for rec in out.values():
        rec.pop("_rank", None)
    return out


def load_levic() -> tuple[dict[str, dict], dict[str, dict]]:
    by_clave, by_ean = {}, {}
    path = ROOT / "catalogo-imagenes" / "_trabajo" / "levic_catalogo.tsv"
    if not path.exists():
        return by_clave, by_ean
    with path.open(encoding="utf-8") as f:
        for line in f:
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 4:
                continue
            clave, ean, lab, desc = parts[0].strip(), parts[1].strip(), parts[2].strip(), parts[3].strip()
            rec = {
                "clave": clave,
                "ean": ean,
                "marca": title_lab(lab),
                "desc": desc,
            }
            if clave:
                by_clave[clave.upper()] = rec
            eand = re.sub(r"\D", "", ean)
            if eand:
                by_ean[eand] = rec
    return by_clave, by_ean


def clave_from_sku(sku: str) -> str | None:
    m = re.match(r"^EQ-(.+)$", sku or "", re.I)
    return m.group(1).upper() if m else None


def looks_med(p: dict) -> bool:
    blob = " ".join([
        str(p.get("nombre") or ""),
        str(p.get("categoria") or ""),
        str(p.get("tipo") or ""),
        str(p.get("sku") or ""),
    ])
    if re.search(r"\b(TAB|CAP|COMP|GRAG|SUSP|GOT|AMP|FA|JBE|MG|ML)\b", blob, re.I):
        return True
    if str(p.get("sku") or "").upper().startswith("EQ-"):
        return True
    cat = str(p.get("categoria") or "").lower()
    return any(x in cat for x in ("medicamento", "analgésico", "antibiot", "gastro", "diabetes"))


def hueca(p: dict) -> bool:
    return blank(p.get("marca")) or blank(p.get("presentacion")) or blank(p.get("principio_activo"))


def presentacion_ok(pres: str) -> bool:
    p = str(pres or "").strip()
    if len(p) < 8:
        return False
    if re.match(r"^C/(?!\d)", p, re.I):
        return False
    return bool(re.search(
        r"(Caja con \d+|C/\d+|Frasco|Tubo|Ampolleta|óvulo|Ovulo|Blister)",
        p, re.I,
    ))


def first_token_generic(nombre: str) -> bool:
    from parse_nombre_producto import _looks_generic

    head = re.split(r"[\s(/]", str(nombre or "").strip())
    return bool(head and _looks_generic(head[0]))


def nice_pa(s: str) -> str:
    t = re.sub(r"\s+", " ", str(s).strip())
    t = t.replace(" - ", " / ")
    if t.isupper() or t.islower():
        t = t.title()
    return t.replace(" / ", " / ")


def conc_compatible(nombre: str, conc: str) -> bool:
    """Rechaza 50 mg en un producto cuyo nombre dice 100 mg."""
    name_nums = {n.replace(",", ".") for n in re.findall(r"\d+(?:[.,]\d+)?", nombre or "")}
    conc_nums = {n.replace(",", ".") for n in re.findall(r"\d+(?:[.,]\d+)?", conc or "")}
    dosis = conc_nums - {"1", "5"}  # /5 mL es vehículo, no la dosis del nombre
    if not dosis or not name_nums:
        return True
    return bool(dosis & name_nums)


def merge(p: dict, foto: dict | None, levic: dict | None) -> dict:
    parsed = parse_nombre_producto(p.get("nombre") or "", p.get("tipo"))
    out = {}
    fuentes = []

    marca = None
    if levic and levic.get("marca"):
        marca = levic["marca"]
        fuentes.append("levic")
    elif foto and foto.get("marca"):
        marca = foto["marca"]
        fuentes.append("foto")
    if marca and blank(p.get("marca")):
        out["marca"] = marca

    pa = None
    if foto and foto.get("pa"):
        pa = nice_pa(foto["pa"])
        fuentes.append("foto-pa")
    elif parsed.principio_activo and first_token_generic(p.get("nombre") or ""):
        pa = nice_pa(parsed.principio_activo)
        fuentes.append("parser-pa")
    if pa and blank(p.get("principio_activo")):
        # No copiar basura del parser ("AMANTADINA(ROSEL)", "1 SOL 3/2").
        if re.search(r"[()]", pa) or re.search(r"\b\d+\s+(TAB|SOL|SUSP|JBE)\b", pa, re.I):
            pa = None
    if pa and blank(p.get("principio_activo")):
        out["principio_activo"] = pa
        if blank(p.get("denominacion_generica")):
            out["denominacion_generica"] = pa

    pres = None
    forma = None
    conc = None
    if foto and foto.get("presentacion"):
        pres = foto["presentacion"]
        forma = foto.get("forma")
        conc = foto.get("concentracion")
        if conc and not conc_compatible(p.get("nombre") or "", conc):
            conc = None
        fuentes.append("foto-pres")
    elif parsed.presentacion:
        m = re.match(r"^(\d+)\s+(.+)$", parsed.presentacion)
        if m and parsed.forma_farmaceutica:
            pres = caja_con(m.group(1), parsed.forma_farmaceutica)
        else:
            pres = parsed.presentacion.title() if parsed.presentacion.isupper() else parsed.presentacion
        forma = parsed.forma_farmaceutica
        conc = parsed.concentracion
        fuentes.append("parser-pres")
    if not conc and parsed.concentracion:
        conc = parsed.concentracion
    elif parsed.concentracion and conc:
        if len(re.findall(r"\d+", parsed.concentracion)) > len(re.findall(r"\d+", conc)):
            conc = parsed.concentracion
    if pres and blank(p.get("presentacion")) and presentacion_ok(pres):
        out["presentacion"] = pres
    if forma and blank(p.get("forma_farmaceutica")):
        out["forma_farmaceutica"] = forma.title() if forma.isupper() else forma
    if conc and blank(p.get("concentracion")):
        c = conc.replace("MG", "mg").replace("ML", "mL")
        out["concentracion"] = c

    out["_fuentes"] = ",".join(dict.fromkeys(fuentes))
    return out


def patch_one(url: str, key: str, pid: int, fields: dict) -> None:
    import urllib.request

    body = json.dumps(fields).encode()
    req = urllib.request.Request(
        f"{url}/rest/v1/productos?id=eq.{pid}",
        data=body,
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
    if not url or not key:
        print("Falta SUPABASE URL / SERVICE_ROLE_KEY", file=sys.stderr)
        return 1

    productos = fetch_all(
        url, key,
        "id,sku,nombre,marca,presentacion,principio_activo,denominacion_generica,"
        "concentracion,forma_farmaceutica,codigo_barras,categoria,tipo,precio,stock",
    )
    fotos = load_fotos()
    levic_clave, levic_ean = load_levic()

    huecas = [p for p in productos if hueca(p)]
    meds = [p for p in huecas if looks_med(p)]

    propuestas = []
    sin_fuente = []
    for p in meds:
        sku = p.get("sku") or ""
        ean = re.sub(r"\D", "", p.get("codigo_barras") or "")
        foto = (fotos.get(f"ean:{ean}") if ean else None) or fotos.get(f"sku:{sku}")
        clave = clave_from_sku(sku)
        levic = None
        if ean and ean in levic_ean:
            levic = levic_ean[ean]
        elif clave and clave in levic_clave:
            levic = levic_clave[clave]
        fields = merge(p, foto, levic)
        meta = fields.pop("_fuentes", "")
        usable = {k: v for k, v in fields.items() if v}
        if not usable:
            sin_fuente.append(p)
            continue
        if (
            "marca" not in usable
            and "principio_activo" not in usable
            and not str(sku).upper().startswith("EQ-")
        ):
            sin_fuente.append(p)
            continue
        propuestas.append((p, usable, meta))

    print(f"activos={len(productos)} huecas={len(huecas)} meds_huecas={len(meds)}")
    print(f"propuestas={len(propuestas)} sin_fuente={len(sin_fuente)}")
    print()
    for p, fields, meta in propuestas:
        bits = " · ".join(f"{k}={v}" for k, v in fields.items())
        print(f"{p['sku']:<16} ${p.get('precio') or 0}  {p['nombre']}")
        print(f"                 {bits}")

    if sin_fuente:
        print()
        print(f"— {len(sin_fuente)} medicamentos huecos sin fuente (no se tocan):")
        for p in sin_fuente[:40]:
            miss = [k for k in ("marca", "presentacion", "principio_activo") if blank(p.get(k))]
            print(f"  {p['sku']:<16} falta {','.join(miss):<40} {p['nombre']}")
        if len(sin_fuente) > 40:
            print(f"  … +{len(sin_fuente) - 40}")

    sql_path = ROOT / "sql" / "patch_fichas_huecas_20260818.sql"
    lines = [
        "-- Completar marca / presentación / PA en fichas Equilibrio huecas.",
        "-- Fuentes: OCR de portada, catálogo Levic, parser de nombre.",
        "begin;",
        "",
    ]
    for p, fields, meta in propuestas:
        assignments = []
        for k, v in fields.items():
            lit = str(v).replace("'", "''")
            assignments.append(f"    {k} = coalesce(nullif({k}, ''), '{lit}')")
        lines.append(f"-- {p['sku']} · {p['nombre']} · {meta}")
        lines.append("update public.productos set")
        lines.append(",\n".join(assignments))
        lines.append(f" where sku = '{p['sku']}';")
        lines.append("")
    lines.append("commit;")
    sql_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print()
    print(f"SQL → {sql_path}")

    if apply:
        for p, fields, meta in propuestas:
            patch_one(url, key, p["id"], fields)
            print(f"OK {p['sku']} {fields}")
        print(f"aplicadas={len(propuestas)}")
    else:
        print("dry-run · pasa --apply para escribir en vivo")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
