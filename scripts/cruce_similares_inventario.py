#!/usr/bin/env python3
"""Cruza el surtido de Farmacias Similares contra el inventario vivo de FarmaCapital.

El Excel original (`pricing/fuentes/articulos_farmacias.xlsx`) no se versiona.
Si está en disco se usa; si no, se baja el catálogo público VTEX
(https://www.farmaciasdesimilares.com) — la misma lista de artículos de farmacia.

Compara por genérico (principio + concentración + forma), no por marca comercial:
si Similares vende ibuprofeno 400 mg 10 tabletas y nosotros tenemos AMSA/Ultra
del mismo PA/dosis/forma, cuenta como cubierto.

Uso:
  python3 scripts/cruce_similares_inventario.py
  python3 scripts/cruce_similares_inventario.py --excel pricing/fuentes/articulos_farmacias.xlsx
"""
from __future__ import annotations

import argparse
import csv
import importlib.util
import json
import re
import sys
import time
import unicodedata
import urllib.parse
import urllib.request
from collections import Counter, defaultdict
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXCEL_DEFAULT = ROOT / "pricing" / "fuentes" / "articulos_farmacias.xlsx"
VTEX_SEARCH = "https://www.farmaciasdesimilares.com/api/catalog_system/pub/products/search"
HOY = date.today().isoformat()
REPORTE_DIR = ROOT / "pricing" / "reportes"
SNAPSHOT_DIR = ROOT / "pricing" / "importados"

spec = importlib.util.spec_from_file_location(
    "sync_excel", ROOT / "scripts" / "sync_precios_excel_farmacias.py"
)
ex = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ex)
sync = ex.sync
sync.SINONIMOS.setdefault("cla", "clavulanico")
sync.SINONIMOS.setdefault("clavulanico", "clavulanico")
sync.SINONIMOS.setdefault("tioctico", "tioctico")

UMBRAL_CUBIERTO = 80
UMBRAL_EQUIV = 70

CLASE_A = {
    "paracetamol", "ibuprofeno", "naproxeno", "diclofenaco", "ketorolaco", "metamizol",
    "omeprazol", "pantoprazol", "ranitidina",
    "metformina", "glibenclamida",
    "losartan", "amlodipino", "enalapril", "captopril",
    "amoxicilina", "ampicilina", "ciprofloxacino", "metronidazol", "trimetoprima",
    "azitromicina",
    "loratadina", "cetirizina", "clorfenamina",
    "atorvastatina",
    "acetilsalicilico",
    "salbutamol", "ambroxol",
    "clotrimazol",
    "furosemida",
    "sildenafil",
}

MARCA_PROPIA_SIMI = re.compile(
    r"\b(simi\s?flex|simi\s?fx|simiflex|simibacil|simipro|simifibra|simifila|"
    r"simialoe|dr simi|multigomi|gomitas|nopal/chia|pick up)\b",
    re.I,
)

SKIP_CAT_RE = re.compile(
    r"souvenir|perfumer|alimento|promocional|materiales diversos|juguete",
    re.I,
)
INCLUDE_CAT_RE = re.compile(
    r"medicamento|curaci[oó]n|suplemento|salud sexual|maternidad|herbolar|"
    r"vitamin|diabetes|cardio|analg[eé]sic|antibi[oó]tic|respirator|"
    r"antihist|estomac|gastro|dermato|oftal|otic|ginecol|urolog|"
    r"material de curaci|botiqu[ií]n|primeros auxilios",
    re.I,
)

FORMA_FAMILIA = {
    "tableta": "oral_solido",
    "capsula": "oral_solido",
    "comprimido": "oral_solido",
    "gragea": "oral_solido",
    "suspension": "oral_liq",
    "jarabe": "oral_liq",
    "solucion": "oral_liq",
    "polvo": "oral_liq",
    "crema": "topico",
    "gel": "topico",
    "unguento": "topico",
    "pomada": "topico",
}

MARCAS_CASA_SIMI = {
    "pick up", "generico", "genérico", "farmacias similares", "similares",
    "dr simi", "simi",
}

# Palabras que aparecen en el nombre pero no identifican al fármaco.
# Sin esto, "AGUA DE MAR" pegaba con "Agua oxigenada" por el token "agua".
PA_DEBIL = {
    "agua", "mar", "gel", "crema", "solucion", "tableta", "capsula", "polvo",
    "sobre", "pieza", "piezas", "vitamina", "vitaminas", "acido", "sabor",
    "color", "calcetin", "parche", "balsamo", "barra", "protect", "dual",
    "generico", "infantil", "adulto", "spray", "jabon", "desodorante",
    "jeringa", "desechable", "insulina", "adhesivo", "pomada", "unguento",
    "micelar", "isotonica", "neutro", "repelente",
}

NO_CLASE_A = re.compile(
    r"\b(calcetin|calcetines|parche termico|unisex|repelente|gotas oftal|"
    r"solucion oftal|barra topica|balsamo en barra)\b",
    re.I,
)


def formas_compatibles(a: str | None, b: str | None) -> bool:
    if not a or not b:
        return True
    if a == b:
        return True
    return FORMA_FAMILIA.get(a) == FORMA_FAMILIA.get(b) and FORMA_FAMILIA.get(a) is not None


def norm(s: str) -> str:
    s = unicodedata.normalize("NFKD", str(s or ""))
    s = "".join(c for c in s if not unicodedata.combining(c))
    return re.sub(r"\s+", " ", s.lower()).strip()


def activos_sim(desc: str) -> list[str]:
    """Moléculas del genérico Similares: cabeza de cada segmento antes de la dosis."""
    cabeza = re.split(r"\d", desc or "", maxsplit=1)[0]
    ings = sync.ingredientes(cabeza.replace("/", " + "))
    return [x for x in ings if x not in PA_DEBIL and len(x) >= 5]


def clase_y_stock(sim: dict) -> tuple[str, int, int]:
    forma = (sim.get("forma") or "")
    jer = sim.get("jerarquia") or ""
    precio = float(sim.get("precio") or 0)
    desc = " ".join([sim.get("descripcion") or "", sim.get("marca") or ""])
    nd = norm(desc)

    linea_n = norm(sim.get("linea") or "")
    if NO_CLASE_A.search(desc):
        return "C", 2, 3
    if linea_n in {"higiene", "belleza"} or "shampoo" in nd or "desodorante" in nd:
        return "C", 2, 3
    if MARCA_PROPIA_SIMI.search(desc) or "suplement" in norm(jer):
        return "C", 2, 3
    if precio >= 250:
        return "C", 1, 2
    if precio >= 120:
        return "B", 2, 4
    if "inyect" in (forma or "") or "ampolleta" in nd or "ampolla" in nd:
        return "INY", 2, 3
    if "material de curaci" in linea_n or linea_n == "material de curacion":
        return "CUR", 6, 10
    if any(tok in nd for tok in CLASE_A):
        return "A", 6, 10
    linea = norm(sim.get("linea") or "")
    if any(x in linea for x in ("analges", "diabet", "cardio", "estomac", "gastro", "antihist")):
        return "A", 5, 8
    if any(x in linea for x in ("antibiot", "respirator", "antimicot")):
        return "B", 3, 6
    return "C", 2, 4


def _vtex_get(url: str) -> tuple[list, str]:
    req = urllib.request.Request(
        url,
        headers={"Accept": "application/json", "User-Agent": "Mozilla/5.0 (FarmaCapital cruce)"},
    )
    with urllib.request.urlopen(req, timeout=40) as resp:
        resources = resp.headers.get("resources") or resp.headers.get("Resources") or ""
        return json.loads(resp.read()), resources


def cargar_similares_vtex() -> list[dict]:
    """Catálogo público VTEX, paginado de 50 en 50."""
    out: dict[str, dict] = {}
    start = 0
    page = 50
    total = None
    while True:
        end = start + page - 1
        url = f"{VTEX_SEARCH}?_from={start}&_to={end}"
        items, resources = _vtex_get(url)
        if total is None and "/" in resources:
            try:
                total = int(resources.split("/")[-1])
            except ValueError:
                total = None
        if not items:
            break
        for it in items:
            rec = vtex_a_fila(it)
            if rec:
                out[rec["sim_sku"]] = rec
        print(f"  VTEX {start}-{start + len(items) - 1}" + (f" / {total}" if total else ""), flush=True)
        start += page
        if total is not None and start >= total:
            break
        if len(items) < page:
            break
        time.sleep(0.15)
    return list(out.values())


def vtex_a_fila(it: dict) -> dict | None:
    nombre = (it.get("productName") or "").strip()
    if not nombre:
        return None
    cats = it.get("categories") or []
    cat_txt = " ".join(cats)
    if SKIP_CAT_RE.search(cat_txt):
        return None
    jerarquia = ""
    linea = ""
    if cats:
        partes = [p for p in cats[0].split("/") if p]
        jerarquia = partes[0] if partes else ""
        linea = partes[1] if len(partes) > 1 else partes[0] if partes else ""
    items = it.get("items") or [{}]
    sellers = (items[0].get("sellers") or [])
    precio = 0.0
    if sellers:
        precio = float(sellers[0].get("commertialOffer", {}).get("Price") or 0)
    sku = str(it.get("productReference") or it.get("productId") or "").strip()
    marca = (it.get("brand") or "").strip()
    if norm(marca) in MARCAS_CASA_SIMI:
        marca = ""
    return {
        "sim_sku": sku,
        "fuente": "vtex",
        "marca": marca,
        "marca_norm": sync.normalizar(marca),
        "descripcion": nombre,
        "desc_norm": sync.normalizar(nombre),
        "precio": precio,
        "concentracion": "",
        "contenido": "",
        "presentacion": (items[0].get("name") or ""),
        "linea": linea,
        "jerarquia": jerarquia,
        "grupo": "",
        "concentraciones": sync.extraer_concentraciones(nombre),
        "cantidad": sync.extraer_cantidad(nombre),
        "forma": sync.extraer_forma(nombre),
        "ingredientes": activos_sim(nombre),
        "n_marcas": 1,
        "link": it.get("link") or "",
        "requiere_receta": ",".join(it.get("Requiere Receta") or []),
    }


def cargar_similares_excel(ruta: Path) -> list[dict]:
    import openpyxl

    wb = openpyxl.load_workbook(ruta, read_only=True, data_only=True)
    ws = wb[wb.sheetnames[0]]
    by_sku: dict[str, dict] = {}
    for fila in ws.iter_rows(min_row=3, values_only=True):
        sku = str(fila[0] or "").strip()
        if not sku or sku == "None":
            continue
        estatus = str(fila[13] or "").strip().upper() if len(fila) > 13 else "ACTIVO"
        if estatus and estatus not in ("ACTIVO", ""):
            continue
        marca = (fila[1] or "").strip() if isinstance(fila[1], str) else ""
        desc = (fila[2] or "").strip() if isinstance(fila[2], str) else ""
        if not desc:
            continue
        try:
            precio = float(str(fila[3]).replace("$", "").replace(",", ""))
        except (TypeError, ValueError):
            precio = 0.0
        concentracion = str(fila[4] or "").strip()
        contenido = str(fila[5] or "").strip()
        presentacion = str(fila[7] or "").strip() if len(fila) > 7 else ""
        linea = str(fila[9] or "").strip() if len(fila) > 9 else ""
        jerarquia = str(fila[10] or "").strip() if len(fila) > 10 else ""
        grupo = str(fila[11] or "").strip() if len(fila) > 11 else ""
        if SKIP_CAT_RE.search(f"{jerarquia} {linea}"):
            continue
        if jerarquia and not INCLUDE_CAT_RE.search(jerarquia) and jerarquia.upper() not in {
            "MEDICAMENTOS", "MATERIAL DE CURACION", "SUPLEMENTOS", "SALUD SEXUAL",
            "MATERNIDAD", "REMEDIOS HERBOLARIOS",
        }:
            continue
        cand = {
            "sim_sku": sku,
            "fuente": "excel",
            "marca": marca,
            "marca_norm": sync.normalizar(marca),
            "descripcion": desc,
            "desc_norm": sync.normalizar(desc),
            "precio": precio,
            "concentracion": concentracion,
            "contenido": contenido,
            "presentacion": presentacion,
            "linea": linea,
            "jerarquia": jerarquia,
            "grupo": grupo,
            "concentraciones": sync.extraer_concentraciones(f"{concentracion} {desc}"),
            "cantidad": sync.extraer_cantidad(contenido) or sync.extraer_cantidad(desc),
            "forma": sync.extraer_forma(presentacion) or sync.extraer_forma(desc),
            "ingredientes": activos_sim(desc),
            "n_marcas": 1,
            "link": "",
            "requiere_receta": "",
        }
        prev = by_sku.get(sku)
        if prev is None:
            by_sku[sku] = cand
        else:
            prev["n_marcas"] += 1
            if len(desc) > len(prev["descripcion"]):
                cand["n_marcas"] = prev["n_marcas"]
                by_sku[sku] = cand
    wb.close()
    return list(by_sku.values())


def fetch_productos_stock(url: str, key: str) -> list[dict]:
    H = {"apikey": key, "Authorization": f"Bearer {key}"}
    out = []
    start = 0
    while True:
        req = urllib.request.Request(
            url + "/rest/v1/productos?select=id,sku,nombre,principio_activo,marca,presentacion,"
            "forma_farmaceutica,concentracion,costo,precio,categoria,tipo,stock,stock_minimo,activo"
            "&activo=eq.true&order=nombre",
            headers={**H, "Range": f"{start}-{start + 999}"},
        )
        with urllib.request.urlopen(req, timeout=90) as r:
            chunk = json.loads(r.read())
        out.extend(chunk)
        if len(chunk) < 1000:
            break
        start += 1000
    return out


def token_index(productos: list[dict], atts: list[dict]) -> dict[str, list[int]]:
    idx: dict[str, list[int]] = defaultdict(list)
    for i, (_p, att) in enumerate(zip(productos, atts)):
        toks = set(sync.tokens_utiles(att["texto"]))
        toks.update(att["ingredientes"])
        for t in toks:
            if len(t) >= 4:
                idx[t].append(i)
    return idx


def nuestros_atts(productos: list[dict]) -> list[dict]:
    atts = []
    for p in productos:
        att = ex.nuestros_atributos(p)
        extra = " ".join(filter(None, [
            str(p.get("concentracion") or ""),
            str(p.get("forma_farmaceutica") or ""),
        ]))
        if extra:
            att["texto"] = (att["texto"] + " " + extra).strip()
            att["concentraciones"] |= sync.extraer_concentraciones(extra)
            att["cantidad"] = att["cantidad"] or sync.extraer_cantidad(att["texto"])
            att["forma"] = att["forma"] or sync.extraer_forma(extra)
        atts.append(att)
    return atts


def cruzar(sim: list[dict], productos: list[dict]) -> tuple[list[dict], list[dict], list[dict]]:
    freq: Counter[str] = Counter()
    for c in sim:
        freq.update(set(sync.tokens_utiles(c["descripcion"])))
    minimo = max(25, int(len(sim) * 0.02))
    vagos = {t for t, n in freq.items() if n >= minimo}

    atts = nuestros_atts(productos)
    idx = token_index(productos, atts)

    covered: dict[str, dict] = {}
    for s in sim:
        toks = set(sync.tokens_utiles(s["descripcion"]))
        toks.update(s.get("ingredientes") or [])
        cand_i: set[int] = set()
        for t in toks:
            if len(t) >= 4:
                cand_i.update(idx.get(t, []))
        best = None
        best_score = 0
        best_raz: list[str] = []
        best_equiv = False
        for i in cand_i:
            score, razones, _ = ex.evaluar(atts[i], s, vagos)
            sim_ing = [
                sync.canonico(x)
                for x in (s.get("ingredientes") or [])
                if x not in vagos and x not in PA_DEBIL and len(x) >= 5
            ]
            fc_ing = [
                sync.canonico(x) for x in atts[i]["ingredientes"]
                if x not in PA_DEBIL and len(x) >= 5
            ]
            fc_txt = " ".join(atts[i]["ingredientes"] + sync.tokens_utiles(atts[i]["texto"]))
            faltan = []
            if sim_ing:
                faltan = [x for x in sim_ing if x not in fc_ing and x not in fc_txt]
                if faltan:
                    score = min(score, 55)
                    razones = razones + [f"faltan en tu ficha: {', '.join(faltan)}"]
                if len(sim_ing) >= 2 and len(fc_ing) == 1:
                    score = min(score, 58)
                    razones = razones + ["combinado Similares vs monofármaco tuyo"]
            pa_ok = bool(sim_ing) and not faltan
            conc_ok = bool(atts[i]["concentraciones"] & s["concentraciones"]) if (
                atts[i]["concentraciones"] and s["concentraciones"]
            ) else False
            forma_ok = formas_compatibles(atts[i]["forma"], s["forma"])
            fc_nom = sync.normalizar(productos[i].get("nombre") or "")
            nombre_set = ex.fuzz.token_set_ratio(s["desc_norm"], fc_nom)
            nombre_ratio = ex.fuzz.ratio(s["desc_norm"], fc_nom)
            # token_set_ratio("tempra", "paracetamol 80mg ... tempra") = 100
            # y un SKU vago no puede tapar 4 presentaciones distintas.
            nombre_corto = len(fc_nom.split()) <= 2
            if nombre_corto and not conc_ok:
                pass
            elif nombre_set >= 88 and nombre_ratio >= 55:
                score = max(score, 82)
                razones = razones + [f"nombre muy parecido ({nombre_set:.0f}/{nombre_ratio:.0f})"]
            elif nombre_set >= 80 and nombre_ratio >= 48 and (conc_ok or not s["concentraciones"]):
                score = max(score, 76)
                razones = razones + [f"nombre parecido ({nombre_set:.0f}/{nombre_ratio:.0f})"]
            # Jeringas / material: el volumen tiene que coincidir, no basta la palabra.
            nd = norm(s["descripcion"])
            if "jeringa" in nd and s["concentraciones"] and not conc_ok:
                score = min(score, 50)
                razones = razones + ["volumen de jeringa no coincide"]
            equiv = pa_ok and conc_ok and forma_ok and bool(sim_ing)
            if equiv and score < UMBRAL_EQUIV:
                score = max(score, UMBRAL_EQUIV)
                razones = razones + ["equivalente PA+concentración+forma"]
            if score == 0 or (razones == ["sin identidad comprobable"] and nombre_sim < 80):
                continue
            if score > best_score:
                best_score = score
                best = productos[i]
                best_raz = razones
                best_equiv = equiv
        if best is not None and (best_score >= UMBRAL_CUBIERTO or best_equiv):
            covered[s["sim_sku"]] = {
                "score": best_score,
                "razones": "; ".join(best_raz),
                "prod": best,
                "equiv": best_equiv,
            }

    huecos, rellenar, ok = [], [], []
    for s in sim:
        clase, minimo_s, objetivo = clase_y_stock(s)
        rec = {**s, "clase": clase, "minimo": minimo_s, "objetivo": objetivo}
        hit = covered.get(s["sim_sku"])
        if not hit:
            rec.update({
                "estado": "HUECO",
                "fc_sku": "",
                "fc_nombre": "",
                "fc_marca": "",
                "fc_pa": "",
                "stock": 0,
                "pedir": minimo_s,
                "match": 0,
                "razones": "",
            })
            huecos.append(rec)
            continue
        p = hit["prod"]
        stock = int(p.get("stock") or 0)
        rec.update({
            "fc_sku": p.get("sku") or "",
            "fc_nombre": p.get("nombre") or "",
            "fc_marca": p.get("marca") or "",
            "fc_pa": p.get("principio_activo") or "",
            "stock": stock,
            "match": hit["score"],
            "razones": hit["razones"],
        })
        if stock < minimo_s:
            rec["estado"] = "RELLENAR"
            rec["pedir"] = minimo_s - stock
            rellenar.append(rec)
        else:
            rec["estado"] = "OK"
            rec["pedir"] = 0
            ok.append(rec)
    return huecos, rellenar, ok


def prio_key(r: dict):
    order = {"A": 0, "INY": 1, "CUR": 2, "B": 3, "C": 4}
    return (order.get(r["clase"], 9), -(r.get("precio") or 0), r["descripcion"])


def escribir_csv(path: Path, rows: list[dict], extra_fc: bool) -> None:
    headers = [
        "prioridad", "estado", "clase", "pedir", "sku_similares", "generico_similares",
        "concentraciones", "piezas", "forma", "linea", "jerarquia",
        "precio_similares", "min_sucursal", "objetivo",
    ]
    if extra_fc:
        headers += ["fc_sku", "fc_nombre", "fc_marca", "stock", "match", "razones"]
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(headers)
        for i, r in enumerate(rows, start=1):
            conc = " ".join(sorted(r.get("concentraciones") or []))
            vals = [
                i, r.get("estado"), r["clase"], r.get("pedir") or 0, r["sim_sku"],
                r["descripcion"], conc, r.get("cantidad") or "", r.get("forma") or "",
                r.get("linea") or "", r.get("jerarquia") or "",
                r.get("precio") or 0, r["minimo"], r["objetivo"],
            ]
            if extra_fc:
                vals += [
                    r.get("fc_sku") or "", r.get("fc_nombre") or "",
                    r.get("fc_marca") or "", r.get("stock") or 0,
                    r.get("match") or 0, r.get("razones") or "",
                ]
            w.writerow(vals)


def escribir_snapshot(path: Path, sim: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=[
            "sim_sku", "descripcion", "marca", "precio", "linea", "jerarquia",
            "forma", "cantidad", "concentraciones", "ingredientes", "link", "fuente",
        ])
        w.writeheader()
        for r in sim:
            w.writerow({
                "sim_sku": r["sim_sku"],
                "descripcion": r["descripcion"],
                "marca": r.get("marca") or "",
                "precio": r.get("precio") or 0,
                "linea": r.get("linea") or "",
                "jerarquia": r.get("jerarquia") or "",
                "forma": r.get("forma") or "",
                "cantidad": r.get("cantidad") or "",
                "concentraciones": " ".join(sorted(r.get("concentraciones") or [])),
                "ingredientes": " + ".join(r.get("ingredientes") or []),
                "link": r.get("link") or "",
                "fuente": r.get("fuente") or "",
            })


def escribir_md(path: Path, resumen: dict, huecos: list[dict]) -> None:
    por_linea: Counter[str] = Counter()
    for r in huecos:
        if r["clase"] in ("A", "B", "CUR"):
            por_linea[r.get("linea") or r.get("jerarquia") or "Sin línea"] += 1
    lineas = [
        f"# Cruce FarmaCapital vs surtido Similares ({resumen['fecha']})",
        "",
        "El Excel de artículos (`pricing/fuentes/articulos_farmacias.xlsx`) no se versiona.",
        f"Este cruce usó el catálogo público de Similares (VTEX) del {resumen['fecha']}: la misma lista de farmacia, precios al día.",
        "",
        "El match es por **genérico** (principio + concentración + forma), no por marca comercial.",
        "Si Similares vende ibuprofeno 400 mg 10 tabletas y nosotros tenemos AMSA/Ultra de esa misma presentación, cuenta como cubierto.",
        "",
        "## Resumen",
        "",
        f"- Artículos únicos Similares (farmacia, sin souvenirs/perfumería/alimentos): **{resumen['similares_unicos']}**",
        f"- Productos activos en nuestro inventario: **{resumen['inventario_activo']}**",
        f"- Ya cubiertos (los tenemos, aunque sea otra marca): **{resumen['cubiertos']}** ({resumen['cobertura_pct']}%)",
        f"  - con stock suficiente: **{resumen['ok']}**",
        f"  - hay que rellenar (bajo el mínimo sucursal): **{resumen['rellenar']}**",
        f"- Huecos (Similares lo vende y nosotros no): **{resumen['huecos']}**",
        f"  - clase A (rotación alta): **{resumen['huecos_a']}**",
        f"  - clase B: **{resumen['huecos_b']}**",
        f"  - clase C: **{resumen['huecos_c']}**",
        f"  - inyectables: **{resumen['huecos_iny']}**",
        f"  - curación: **{resumen['huecos_cur']}**",
        "",
        "Para igualar el surtido de mostrador de Similares, el pedido útil es **clase A + B + curación**",
        f"({resumen['huecos_a'] + resumen['huecos_b'] + resumen['huecos_cur']} huecos).",
        "Clase C (especialidad / marca propia Simi) se pide de 2 en 2 cuando ya hay consulta.",
        "",
        "Archivos:",
        "",
        f"- `{resumen['csv_prioridad']}` — huecos A + B + curación (comprar primero)",
        f"- `{resumen['csv_huecos']}` — resto de huecos (especialidad)",
        f"- `{resumen['csv_rellenar']}` — ya los tenemos, stock bajo el mínimo",
        f"- `{resumen['csv_cubiertos']}` — ya cubiertos",
        "",
        "## Huecos prioridad por línea",
        "",
        "| Línea | Huecos A/B/curación |",
        "| --- | ---: |",
    ]
    for linea, n in por_linea.most_common(20):
        lineas.append(f"| {linea} | {n} |")
    lineas += [
        "",
        "## Huecos clase A (muestra)",
        "",
        "| Pedir | Precio Simi | Genérico | Línea |",
        "| ---: | ---: | --- | --- |",
    ]
    n = 0
    for r in huecos:
        if r["clase"] != "A":
            continue
        lineas.append(
            f"| {r['pedir']} | ${r['precio']:.0f} | {r['descripcion'][:70]} | {r.get('linea') or ''} |"
        )
        n += 1
        if n >= 40:
            break
    if n == 0:
        lineas.append("| — | — | (no hubo huecos clase A) | — |")
    path.write_text("\n".join(lineas) + "\n", encoding="utf-8")


def cargar_snapshot_csv(ruta: Path) -> list[dict]:
    out = []
    with ruta.open(encoding="utf-8") as f:
        for row in csv.DictReader(f):
            desc = row.get("descripcion") or ""
            concs = set((row.get("concentraciones") or "").split())
            ings = activos_sim(desc)
            out.append({
                "sim_sku": row.get("sim_sku") or "",
                "fuente": row.get("fuente") or "snapshot",
                "marca": row.get("marca") or "",
                "marca_norm": sync.normalizar(row.get("marca") or ""),
                "descripcion": desc,
                "desc_norm": sync.normalizar(desc),
                "precio": float(row.get("precio") or 0),
                "concentracion": "",
                "contenido": "",
                "presentacion": "",
                "linea": row.get("linea") or "",
                "jerarquia": row.get("jerarquia") or "",
                "grupo": "",
                "concentraciones": concs or sync.extraer_concentraciones(desc),
                "cantidad": int(row["cantidad"]) if str(row.get("cantidad") or "").isdigit() else sync.extraer_cantidad(desc),
                "forma": row.get("forma") or sync.extraer_forma(desc),
                "ingredientes": ings or activos_sim(desc),
                "n_marcas": 1,
                "link": row.get("link") or "",
                "requiere_receta": "",
            })
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--excel", default="", help="Ruta al Excel de artículos (opcional)")
    ap.add_argument("--snapshot", default="", help="CSV VTEX ya bajado (salta la API)")
    args = ap.parse_args()

    env = sync.cargar_env()
    url = env.get("REACT_APP_SUPABASE_URL", "").rstrip("/")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY") or env.get("REACT_APP_SUPABASE_ANON_KEY", "")
    if not url or not key:
        sys.exit("Faltan credenciales Supabase en .env")

    excel = Path(args.excel).expanduser() if args.excel else EXCEL_DEFAULT
    snap = Path(args.snapshot).expanduser() if args.snapshot else Path()
    if excel.exists():
        print(f"Usando Excel {excel}")
        sim = cargar_similares_excel(excel)
        fuente = f"excel:{excel.name}"
    elif snap.exists():
        print(f"Usando snapshot {snap}")
        sim = cargar_snapshot_csv(snap)
        fuente = f"vtex:farmaciasdesimilares.com ({snap.name})"
    else:
        print("Excel no está en disco (gitignored). Bajando catálogo VTEX de Similares…")
        sim = cargar_similares_vtex()
        fuente = "vtex:farmaciasdesimilares.com"

    print(f"Similares únicos: {len(sim)}")
    productos = fetch_productos_stock(url, key)
    print(f"Inventario activo: {len(productos)}")

    huecos, rellenar, ok = cruzar(sim, productos)
    huecos.sort(key=prio_key)
    rellenar.sort(key=prio_key)
    ok.sort(key=lambda r: r["descripcion"])

    tag = HOY.replace("-", "")
    csv_prioridad = f"pricing/reportes/cruce_similares_{tag}_prioridad.csv"
    csv_huecos = f"pricing/reportes/cruce_similares_{tag}_huecos.csv"
    csv_rellenar = f"pricing/reportes/cruce_similares_{tag}_rellenar.csv"
    csv_cubiertos = f"pricing/reportes/cruce_similares_{tag}_cubiertos.csv"
    md_path = REPORTE_DIR / f"cruce_similares_{tag}.md"
    snap_path = SNAPSHOT_DIR / f"similares_catalogo_{tag}.csv"

    p1 = [r for r in huecos if r["clase"] in ("A", "B", "CUR")]
    p_resto = [r for r in huecos if r["clase"] not in ("A", "B", "CUR")]

    escribir_csv(ROOT / csv_prioridad, p1, extra_fc=False)
    escribir_csv(ROOT / csv_huecos, p_resto, extra_fc=False)
    escribir_csv(ROOT / csv_rellenar, rellenar, extra_fc=True)
    escribir_csv(ROOT / csv_cubiertos, ok, extra_fc=True)
    escribir_snapshot(snap_path, sim)

    resumen = {
        "fecha": HOY,
        "fuente": fuente,
        "similares_unicos": len(sim),
        "inventario_activo": len(productos),
        "cubiertos": len(ok) + len(rellenar),
        "ok": len(ok),
        "rellenar": len(rellenar),
        "huecos": len(huecos),
        "huecos_a": sum(1 for r in huecos if r["clase"] == "A"),
        "huecos_b": sum(1 for r in huecos if r["clase"] == "B"),
        "huecos_c": sum(1 for r in huecos if r["clase"] == "C"),
        "huecos_iny": sum(1 for r in huecos if r["clase"] == "INY"),
        "huecos_cur": sum(1 for r in huecos if r["clase"] == "CUR"),
        "cobertura_pct": round(100 * (len(ok) + len(rellenar)) / len(sim), 1) if sim else 0,
        "csv_prioridad": csv_prioridad,
        "csv_huecos": csv_huecos,
        "csv_rellenar": csv_rellenar,
        "csv_cubiertos": csv_cubiertos,
    }
    escribir_md(md_path, resumen, huecos)
    print(json.dumps({k: v for k, v in resumen.items() if not str(k).startswith("csv")}, indent=2))
    print("md", md_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
