#!/usr/bin/env python3
"""Catálogo auxiliar de imágenes para Rappi / DiDi / tienda web.

Solo lee el snapshot de productos. No escribe a producción.
"""
from __future__ import annotations

import csv
import json
import re
import subprocess
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path("/Users/ibarra/farmacapital")
BASE = ROOT / "catalogo-imagenes"
TRABAJO = BASE / "_trabajo"
APROBADAS = BASE / "aprobadas"
REVISAR = BASE / "revisar"
FOTOGRAFIAR = BASE / "fotografiar"

COLS = [
    "sku", "codigo_barras", "producto", "nombre_comercial", "principio_activo",
    "concentracion", "presentacion", "contenido", "laboratorio", "marca",
    "categoria", "subcategoria", "imagen_encontrada", "url_imagen", "url_fuente",
    "tipo_fuente", "confianza_imagen", "coincide_codigo_barras",
    "coincide_presentacion", "descargar_imagen", "fotografiar_en_farmacia",
    "motivo_fotografia", "nombre_archivo_imagen", "observaciones",
]

FOTO_COLS = ["sku", "codigo_barras", "producto", "laboratorio", "presentacion", "motivo_fotografia"]


def fold(s: str) -> str:
    s = unicodedata.normalize("NFKD", s or "")
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = s.lower()
    s = re.sub(r"[^a-z0-9]+", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def extract_contenido(nombre: str, presentacion: str) -> str:
    text = f"{nombre or ''} {presentacion or ''}"
    pats = [
        r"(\d+[\.,]?\d*\s*(?:mg|mcg|g|ml|mL|ML|l|L|ui|UI)\s*/\s*\d+[\.,]?\d*\s*(?:ml|mL|g))",
        r"(\d+[\.,]?\d*\s*(?:mg|mcg|g|ml|mL|ML|l|kg)\b)",
        r"(c/?\s*\d+\s*(?:tab|tabs|tabletas?|caps|cápsulas?|capsulas?|comp|sobres?|pz|pzas?|piezas?))",
        r"(\d+\s*(?:tabletas?|cápsulas?|capsulas?|comprimidos?|sobres?|ampolletas?|aplicadores?))",
    ]
    for p in pats:
        m = re.search(p, text, re.I)
        if m:
            return re.sub(r"\s+", " ", m.group(1)).strip()
    return ""


LAB_BY_MARCA = {
    "amsa": "AMSA",
    "amsa / pisa": "AMSA / PiSA",
    "maver": "Maver",
    "mercurio": "Mercurio",
    "prudence": "Prudence",
    "protec": "Protec",
    "son's": "Química Son's",
    "quimica son's": "Química Son's",
    "química son's": "Química Son's",
    "dibar": "Dibar",
    "suerox": "Genomma Lab",
    "nivea": "Beiersdorf",
    "labello": "Beiersdorf",
    "novag": "Novag",
    "axe": "Unilever",
    "sedal": "Unilever",
    "rexona": "Unilever",
    "dove": "Unilever",
    "obao": "Unilever",
    "ponds": "Unilever",
    "vaseline": "Unilever",
    "quirmex": "Quirmex",
    "collins": "Collins",
    "jaloma": "Jaloma",
    "biomep": "Biomep",
    "vitacilina": "Genomma Lab",
    "asepxia": "Genomma Lab",
    "xl-3": "Genomma Lab",
    "teatrical": "Genomma Lab",
    "tukol-d": "Genomma Lab",
    "lomecan": "Genomma Lab",
    "genoprazol": "Genomma Lab",
    "ultra bengue": "Genomma Lab",
    "next": "Genomma Lab",
    "alliviax": "Genomma Lab",
    "silka": "Genomma Lab",
    "nasalub": "Genomma Lab",
    "nestle": "Nestlé",
    "nido": "Nestlé",
    "nestum": "Nestlé",
    "mavi": "MAVI",
    "beadvance": "beadvance",
    "loeffler": "Loeffler",
    "loeffler / russek": "Loeffler / Russek",
    "grisi": "Laboratorios Grisi",
    "ricitos de oro": "Laboratorios Grisi",
    "hinds": "Laboratorios Grisi",
    "palmolive": "Colgate-Palmolive",
    "mennen": "Colgate-Palmolive",
    "colgate": "Colgate-Palmolive",
    "speed stick": "Colgate-Palmolive",
    "pantene": "Procter & Gamble",
    "head & shoulders": "Procter & Gamble",
    "herbal essences": "Procter & Gamble",
    "old spice": "Procter & Gamble",
    "oral-b": "Procter & Gamble",
    "metamucil": "Procter & Gamble",
    "ajolotius": "Ajolotius",
    "gelcavit": "Gelcavit",
    "wandel": "Wandel",
    "clamoxin": "Clamoxin",
    "electrolit": "Laboratorios PiSA",
    "pisa": "Laboratorios PiSA",
    "pisacaina": "Laboratorios PiSA",
    "sico": "Sico / Reckitt",
    "aspirina": "Bayer",
    "cafiaspirina": "Bayer",
    "bayer": "Bayer",
    "bepanthen": "Bayer",
    "canesten v": "Bayer",
    "redoxon": "Bayer",
    "alka-seltzer": "Bayer",
    "alka-seltzer boost": "Bayer",
    "sensimedical": "SensiMedical",
    "sensi medical": "SensiMedical",
    "sensi medical": "SensiMedical",
    "escudo": "Colgate-Palmolive",
    "caprice": "Unilever",
    "tempra": "Johnson & Johnson / Kenvue",
    "tylenol": "Johnson & Johnson / Kenvue",
    "motrin": "Johnson & Johnson / Kenvue",
    "listerine": "Johnson & Johnson / Kenvue",
    "lubriderm": "Johnson & Johnson / Kenvue",
    "pepto-bismol": "Procter & Gamble / Haleon",
    "tabcin": "Bayer",
    "ultra": "Ultra Laboratorios",
    "raam": "Raam",
    "odolex": "Odolex",
    "pedialyte": "Abbott",
    "ensure": "Abbott",
    "pediasure": "Abbott",
    "glucerna": "Abbott",
    "gum": "Sunstar GUM",
    "cintapore": "Cintapore",
    "quimpharma": "Quimpharma",
    "liferpal md": "Liferpal",
    "degort's chemical": "Degort's Chemical",
    "alpharma": "Alpharma",
    "fármacos continentales": "Fármacos Continentales",
    "quifa": "Quifa",
    "avitus": "Avitus",
    "cmd": "CMD",
    "gelpharma": "Gelpharma",
    "nuvel": "Nuvel",
    "sensodyne": "Haleon",
    "centrum": "Haleon",
    "theraflu": "Haleon",
    "corega": "Haleon",
    "tums": "Haleon",
    "evenflo": "Evenflo",
    "dermodine": "Dermodine",
    "vicks": "P&G / Haleon",
    "nyquil": "P&G / Haleon",
    "senosiain": "Laboratorios Senosiain",
    "sedalmerck": "Sedalmerck",
    "progela": "Progela / Genomma Lab",
    "naturex": "Naturex",
    "playboy": "Playboy",
    "wermar": "Wermar",
    "hispanoamericana": "Hispanoamericana",
    "offenbach": "Offenbach",
    "psicofarma": "Psicofarma",
    "kotex": "Kimberly-Clark",
    "kleenex": "Kimberly-Clark",
    "huggies": "Kimberly-Clark",
    "saba": "Essity / Saba",
    "naturella": "Procter & Gamble",
    "kleenbebe": "KleenBebé",
    "garnier": "L'Oréal",
    "fructis": "L'Oréal",
    "chinoin": "Chinoin",
    "antiflu-des": "Chinoin",
    "scabisan": "Chinoin",
    "armstrong": "Armstrong",
    "herklin": "Armstrong",
    "sanfer": "Sanfer",
    "syncol max": "Sanfer",
    "picot": "Sanfer / Bristol",
    "sal de uvas": "Sanfer",
    "hipoglos": "Genomma Lab",
    "graneodin": "Genomma Lab / Sanofi",
    "neo-melubrina": "Sanofi",
    "bisolvon": "Sanofi / Opella",
    "histiacil": "Opella / Sanofi",
    "histiacil opella": "Opella / Sanofi",
    "trojan": "Church & Dwight",
    "neurobion": "P&G Health / Merck",
    "dolo-neurobion": "P&G Health / Merck",
    "pharmaton": "P&G Health",
    "aderogyl": "Sanofi",
    "riopan": "Takeda",
    "nazil": "Sophia",
    "sophia": "Laboratorios Sophia",
    "cicloferon": "Cicloferon",
    "lotrimin-uno": "Bayer",
    "curitas": "Beiersdorf",
    "off!": "SC Johnson",
    "mertiolate": "Kohn",
    "kohn": "Kohn",
    "afrin": "Bayer / Haleon",
    "desenfriol": "Bayer",
    "contac": "Haleon / GSK",
    "johnson": "Johnson & Johnson",
    "bebin super": "Bebin",
    "diapro": "Diapro",
    "serral": "Serral",
    "edigar": "Edigar",
    "bruluart": "Bruluart",
    "broncolin": "Broncolin",
    "landsteiner": "Landsteiner",
    "neolpharma": "Neolpharma",
    "eurofarma": "Eurofarma",
    "accord": "Accord",
    "opko": "OPKO",
    "rayere": "Rayere",
    "grin": "Laboratorios Grin",
    "andromaco": "Andrómaco",
    "tecnofarma / valeant": "Tecnofarma / Valeant",
}

GENERIC_LABS = {
    "amsa", "maver", "mercurio", "novag", "quirmex", "dibar", "loeffler",
    "biomep", "wandel", "clamoxin", "beadvance", "ultra", "alpharma",
    "gelpharma", "avitus", "quifa", "raam", "odolex", "quimpharma",
    "liferpal md", "liferpal", "degort's chemical", "fármacos continentales",
    "farmacos continentales", "cmd", "wermar", "hispanoamericana", "offenbach",
    "psicofarma", "naturex", "progela", "sedalmerck", "edigar", "bruluart",
    "serral", "landsteiner", "neolpharma", "codifarma", "ifa", "templus",
    "loeffler / russek", "amsa / pisa", "mavi", "mavi farmacéutica",
    "mavi / sanfer", "gel pharma", "gelpharma",
}

SUEROX_IMG = {
    "coco pina": ("https://suerox.com/hubfs/Suerox/COCO%20PINA.jpg", "https://suerox.com/"),
    "uva mora azul": ("https://suerox.com/hubfs/Suerox/UVA%20MORA%20AZUL.jpg", "https://suerox.com/"),
    "fresa kiwi": ("https://suerox.com/hubfs/Suerox/FRESA%20KIWI.jpg", "https://suerox.com/"),
    "eresa kiwi": ("https://suerox.com/hubfs/Suerox/FRESA%20KIWI.jpg", "https://suerox.com/"),
    "naranja mandarina": ("https://suerox.com/hubfs/Suerox/NARANJA%20MANDARINA.jpg", "https://suerox.com/"),
    "lima limon": ("https://suerox.com/hubfs/Suerox/LIMA%20LIMON.jpg", "https://suerox.com/"),
    "mora azul": ("https://suerox.com/hubfs/Suerox/MORA%20AZUL.jpg", "https://suerox.com/"),
    "manzana": ("https://suerox.com/hubfs/Suerox/MANZANA.jpg", "https://suerox.com/"),
    "fresa": ("https://suerox.com/hubfs/Suerox/FRESA.jpg", "https://suerox.com/"),
    "uva": ("https://suerox.com/hubfs/Suerox/UVA.jpg", "https://suerox.com/"),
    "coco": ("https://suerox.com/hubfs/Suerox/COCO.jpg", "https://suerox.com/"),
}

ELECTROLIT_IMG = {
    "uva": "https://electrolit.com.mx/wp-content/uploads/2026/07/uva.png",
    "coco": "https://electrolit.com.mx/wp-content/uploads/2026/07/coco.png",
    "fresa kiwi": "https://electrolit.com.mx/wp-content/uploads/2026/07/fresa-kiwi.png",
    "fresa": "https://electrolit.com.mx/wp-content/uploads/2026/07/main-slide-fresa.jpg",
    "mora azul": "https://electrolit.com.mx/wp-content/uploads/2026/07/mora-azul.png",
    "naranja mandarina": "https://electrolit.com.mx/wp-content/uploads/2026/07/naranja-mandarina.png",
}

PRUDENCE_MATCHES = [
    # (needles in folded name, official title needle, count token, image key substring)
    (("extra pleasure", "c 3"), "extra pleasure c/3", "c/3"),
    (("condones uva", "c 3"), "sabor uva c/3", "c/3"),
    (("uva c 3",), "sabor uva c/3", "c/3"),
    (("fresa", "c 3"), "sabor y aroma fresa c/3", "c/3"),
    (("prudence fresa",), "sabor y aroma fresa c/3", "c/3"),
]


def lab_for(marca: str, nombre: str, tipo: str) -> str:
    m = fold(marca)
    n = fold(nombre)
    if m in LAB_BY_MARCA:
        return LAB_BY_MARCA[m]
    for k, v in LAB_BY_MARCA.items():
        if k and (k in m or k in n):
            return v
    if marca:
        return marca.strip()
    if (tipo or "").lower().startswith("gener"):
        return "Genérico (laboratorio no capturado)"
    return ""


def filename_for(ean: str, sku: str) -> str:
    e = (ean or "").strip()
    if e and e.isdigit() and len(e) >= 8:
        return f"{e}.jpg"
    return f"{sku}.jpg"


def load_prudence():
    path = TRABAJO / "prudence_catalog.json"
    if not path.exists():
        return []
    return json.loads(path.read_text())


def prudence_image(title_needle: str) -> tuple[str, str] | None:
    needle = fold(title_needle)
    for p in load_prudence():
        if needle in fold(p.get("title") or "") and p.get("image"):
            return p["image"], p.get("url") or "https://tienda.prudence.com.mx/"
    return None


def load_off():
    path = ROOT / "sql/generated/fotos_openfacts_20260818.json"
    if not path.exists():
        return {}
    data = json.loads(path.read_text())
    by_sku = {}
    for bucket in ("hit", "revisar"):
        rows = data.get(bucket) or []
        if bucket == "hit":
            # hits may be in a list at top
            pass
    # file structure: hit is int count, hits might be elsewhere
    hits = data.get("hits") or data.get("hit_rows") or []
    if isinstance(data.get("hit"), list):
        hits = data["hit"]
    for r in hits:
        by_sku[r.get("sku")] = r
    for r in data.get("revisar") or []:
        by_sku.setdefault(r.get("sku"), r)
    # also scan if hit is a number and products listed under another key
    if not hits and isinstance(data.get("resultados"), list):
        for r in data["resultados"]:
            by_sku[r.get("sku")] = r
    return by_sku, data


def off_index():
    path = ROOT / "sql/generated/fotos_openfacts_20260818.json"
    if not path.exists():
        return {}
    data = json.loads(path.read_text())
    idx = {}
    for r in data.get("revisar") or []:
        if r.get("sku"):
            idx[r["sku"]] = r
    # HIT products are often in a separate list; search all list values
    for v in data.values():
        if isinstance(v, list) and v and isinstance(v[0], dict) and "sku" in v[0]:
            for r in v:
                if r.get("estado") == "HIT" or r.get("match") == "nombre":
                    idx.setdefault(r["sku"], r)
    csv_path = ROOT / "sql/generated/fotos_openfacts_20260818.csv"
    if csv_path.exists():
        with csv_path.open(newline="", encoding="utf-8") as f:
            for row in csv.DictReader(f):
                sku = row.get("sku")
                if sku:
                    idx[sku] = row
    return idx


def classify(p: dict, off: dict) -> dict:
    sku = p.get("sku") or ""
    nombre = (p.get("nombre") or "").strip()
    marca = (p.get("marca") or "").strip()
    ean = (p.get("codigo_barras") or "").strip()
    tipo = (p.get("tipo") or "").strip()
    presentacion = (p.get("presentacion") or "").strip()
    pa = (p.get("principio_activo") or "").strip()
    conc = (p.get("concentracion") or "").strip()
    cat = (p.get("categoria") or "").strip()
    sub = (p.get("subcategoria") or "").strip()
    lab = lab_for(marca, nombre, tipo)
    contenido = extract_contenido(nombre, presentacion)
    fn = filename_for(ean, sku)
    fnombre = fold(nombre)
    fmarca = fold(marca)
    fpres = fold(presentacion)

    row = {
        "sku": sku,
        "codigo_barras": ean,
        "producto": nombre,
        "nombre_comercial": marca or nombre.split()[0] if nombre else "",
        "principio_activo": pa,
        "concentracion": conc,
        "presentacion": presentacion,
        "contenido": contenido,
        "laboratorio": lab,
        "marca": marca,
        "categoria": cat,
        "subcategoria": sub,
        "imagen_encontrada": "NO",
        "url_imagen": "",
        "url_fuente": "",
        "tipo_fuente": "",
        "confianza_imagen": "BAJA",
        "coincide_codigo_barras": "NO",
        "coincide_presentacion": "NO",
        "descargar_imagen": "NO",
        "fotografiar_en_farmacia": "SI",
        "motivo_fotografia": "",
        "nombre_archivo_imagen": fn,
        "observaciones": "",
        "_revision": False,
        "_diff_presentacion": False,
    }

    def oficial(url, fuente, pres_ok, extra_obs="", alta=False):
        row["imagen_encontrada"] = "SI"
        row["url_imagen"] = url
        row["url_fuente"] = fuente
        row["tipo_fuente"] = "IMAGEN_OFICIAL"
        row["coincide_presentacion"] = "SI" if pres_ok else "NO"
        row["observaciones"] = extra_obs
        if alta and pres_ok:
            row["confianza_imagen"] = "ALTA"
            row["descargar_imagen"] = "SI"
            row["fotografiar_en_farmacia"] = "NO"
            row["motivo_fotografia"] = ""
        else:
            row["confianza_imagen"] = "BAJA"
            row["descargar_imagen"] = "NO"
            row["fotografiar_en_farmacia"] = "SI"
            row["_revision"] = True

    # --- Suerox 630 ml: packshot oficial de sabor ---
    if fmarca == "suerox" or "suerox" in fnombre:
        if "vitamin" in fnombre:
            row["motivo_fotografia"] = "Suerox Vitamins es otra línea; el packshot de Suerox 8 Iones no aplica"
            row["url_fuente"] = "https://suerox.com/"
            row["_revision"] = True
            row["_diff_presentacion"] = True
            return row
        if "frutos rojos" in fnombre:
            row["motivo_fotografia"] = "Sitio oficial muestra FRESA FRUTOS ROJOS, no Frutos Rojos a secas; confirmar empaque físico"
            row["url_fuente"] = "https://suerox.com/"
            row["_revision"] = True
            row["_diff_presentacion"] = True
            return row
        flavor_key = None
        for k in sorted(SUEROX_IMG, key=len, reverse=True):
            if k in fnombre:
                flavor_key = k
                break
        if "630" in fnombre + fpres and flavor_key:
            url, src = SUEROX_IMG[flavor_key]
            oficial(
                url, src, True,
                "Packshot de sabor en sitio oficial de Suerox (Genomma Lab). "
                "Inventario declara 630 ml, que es la presentación actual de Suerox 8 Iones. "
                "El sitio no publica el EAN.",
                alta=True,
            )
            return row
        if flavor_key:
            url, src = SUEROX_IMG[flavor_key]
            oficial(url, src, False, "Sitio oficial muestra el sabor; no confirmamos mililitros.")
            row["motivo_fotografia"] = "Sitio oficial de Suerox no confirma el contenido en ml de esta SKU"
            row["_diff_presentacion"] = True
            return row
        row["motivo_fotografia"] = "Sabor de Suerox no localizado de forma unívoca en el sitio oficial"
        return row

    # --- Prudence tienda oficial ---
    if fmarca == "prudence" or "prudence" in fnombre:
        hit = None
        if "extra pleasure" in fnombre and ("c 3" in fnombre or "c/3" in fold(nombre)):
            hit = prudence_image("PRUDENCE EXTRA PLEASURE C/3")
            label = "Extra Pleasure C/3"
        elif "uva" in fnombre and "c 3" in fnombre:
            hit = prudence_image("PRUDENCE PRESERVATIVOS SABOR UVA C/3")
            label = "Uva C/3"
        elif "fresa" in fnombre and "lubric" not in fnombre and "c 3" in fnombre:
            hit = prudence_image("CONDONES CON COLOR, SABOR Y AROMA FRESA C/3")
            label = "Fresa C/3"
        elif "ultra sensitive" in fnombre and "c 3" in fnombre:
            hit = prudence_image("PRUDENCE FULL SENSITIVE C/3")
            if hit:
                oficial(hit[0], hit[1], False,
                        "En tienda oficial la línea se llama Full Sensitive C/3, no Ultra Sensitive. Revisar empaque físico.")
                row["motivo_fotografia"] = "Posible diferencia de nombre de línea (Ultra vs Full Sensitive) respecto al catálogo oficial"
                row["_revision"] = True
                row["_diff_presentacion"] = True
                return row
        elif "grosella" in fnombre:
            hit30 = prudence_image("Lub Grosella 30ml")
            hit75 = prudence_image("Lub Grosella")
            row["motivo_fotografia"] = "Sitio oficial tiene lubricante Grosella en 30 ml y otra presentación; nuestro inventario no declara ml"
            row["url_fuente"] = "https://tienda.prudence.com.mx/collections/prudence-lub"
            row["observaciones"] = "Identificado en tienda oficial Prudence; no descargar hasta confirmar contenido."
            row["_revision"] = True
            row["_diff_presentacion"] = True
            return row
        elif "lubricante" in fnombre and "natural" in fnombre:
            row["motivo_fotografia"] = "Sitio oficial tiene Lub Natural; no confirma mililitros de nuestra SKU"
            row["url_fuente"] = "https://tienda.prudence.com.mx/"
            row["_revision"] = True
            return row
        if hit:
            oficial(
                hit[0], hit[1], True,
                f"Imagen de tienda oficial Prudence México para {label}. El catálogo de Shopify no publica EAN.",
                alta=True,
            )
            return row
        row["motivo_fotografia"] = "Variante Prudence no emparejada de forma exacta con la tienda oficial (conteo o línea)"
        row["url_fuente"] = "https://tienda.prudence.com.mx/"
        row["_revision"] = True
        return row

    # --- Electrolit: sabor oficial, tamaño no declarado ---
    if fmarca == "electrolit" or (fnombre.startswith("electrolit") and "voldratol" not in fnombre):
        flavor = None
        for k in sorted(ELECTROLIT_IMG, key=len, reverse=True):
            if k in fnombre:
                flavor = k
                break
        if flavor:
            oficial(
                ELECTROLIT_IMG[flavor],
                "https://electrolit.com.mx/",
                False,
                "PiSA publica el sabor en electrolit.com.mx; el inventario no declara ml (hay 250–1150 ml). No descargar.",
            )
            row["motivo_fotografia"] = "Imagen oficial del sabor existe, pero no confirmamos el tamaño de envase de nuestro inventario"
            row["_diff_presentacion"] = True
            return row
        row["motivo_fotografia"] = "Electrolit: sabor no localizado en el sitio oficial de PiSA"
        return row

    # --- Nivea: catálogo oficial con varias tallas ---
    if fmarca == "nivea" or "nivea" in fnombre:
        row["url_fuente"] = "https://www.nivea.com.mx/productos"
        row["_revision"] = True
        if "pearl" in fnombre:
            row["motivo_fotografia"] = "Nivea.com.mx tiene Pearl & Beauty spray 150 ml y roll-on; inventario no declara formato/ml"
            row["_diff_presentacion"] = True
        elif "softmilk" in fnombre or "soft milk" in fnombre:
            row["motivo_fotografia"] = "Nivea.com.mx tiene Soft Milk en 100, 220 y 625 ml; inventario no declara contenido"
            row["_diff_presentacion"] = True
        elif "tarro" in fnombre or "crist" in fnombre:
            row["motivo_fotografia"] = "Nivea.com.mx tiene Creme tarro 200/400/500 ml y tarro vidrio 400 ml; no confirmamos cuál tenemos"
            row["_diff_presentacion"] = True
        elif "7 en 1" in nombre.lower() or "7en1" in fnombre:
            row["motivo_fotografia"] = "Nivea.com.mx tiene Cuidado Facial 7 en 1 Efecto Mate 200 ml; inventario no declara ml"
            row["_diff_presentacion"] = True
        elif "hialuron" in fnombre:
            row["motivo_fotografia"] = "Nivea.com.mx tiene gel hialurónico 100 ml y 200 ml; inventario no declara contenido"
            row["_diff_presentacion"] = True
        elif "milk" in fnombre:
            row["motivo_fotografia"] = "Nivea Body Milk Nutritiva existe en 100 y 200 ml en el sitio oficial; falta contenido en inventario"
            row["_diff_presentacion"] = True
        else:
            row["motivo_fotografia"] = "Producto Nivea: sitio oficial existe, pero no hay coincidencia unívoca de presentación"
        row["observaciones"] = "Fuente oficial consultada: nivea.com.mx. No se descarga porque el contenido/formato no es único."
        return row

    # --- Hinds: sitio oficial muestra 400 ml; inventario tiene 90 ml en varios ---
    if fmarca == "hinds" or "hinds" in fnombre:
        row["url_fuente"] = "https://www.hinds.com.mx/productos"
        row["_revision"] = True
        row["_diff_presentacion"] = True
        if "90" in fnombre + fpres or "90 ml" in nombre.lower():
            row["motivo_fotografia"] = "Sitio oficial Hinds exhibe cremas de 400 ml; nuestro inventario es 90 ml — no usar esa foto"
        else:
            row["motivo_fotografia"] = "Hinds: sitio oficial tiene la línea, pero no confirmamos la presentación (90 vs 400 ml / líquida vs tarro)"
        row["observaciones"] = "Posible diferencia entre empaque físico (90 ml u otras) y catálogo online (400 ml)."
        return row

    # --- Grisi jabones: catálogo oficial con gramajes múltiples ---
    if fmarca == "grisi" or "grisi" in fnombre:
        row["url_fuente"] = "https://www.grisiapp.com/jabones_grisi.html"
        row["_revision"] = True
        row["motivo_fotografia"] = "Catálogo oficial Grisi tiene el jabón en varios gramajes (90/100/125/150/200 g); inventario no declara g"
        row["_diff_presentacion"] = True
        return row

    # --- Sico ---
    if fmarca in {"sico"} or ( "sico" in fnombre and "psicofarma" not in fmarca):
        row["url_fuente"] = "https://www.sico.com.mx/products"
        row["_revision"] = True
        if "cereza" in fnombre:
            row["motivo_fotografia"] = "Sico.com.mx tiene lubricante Play Cereza; confirmar ml (oficial no equivale automáticamente a 50 ml)"
            row["_diff_presentacion"] = True
        elif "calor" in fnombre:
            row["motivo_fotografia"] = "Sico.com.mx tiene Play Sensación de Calor; confirmar presentación/ml"
        elif "softlube" in fnombre or "soft lube" in fnombre:
            row["motivo_fotografia"] = "Sico.com.mx tiene Soft Lube Original; confirmar mililitros"
        elif "condon" in fnombre or "condón" in nombre.lower():
            row["motivo_fotografia"] = "Sico tiene varias líneas de condón; el nombre de inventario no identifica la SKU exacta ni el conteo"
        else:
            row["motivo_fotografia"] = "Producto Sico: sitio oficial existe, falta coincidencia exacta de SKU"
        return row

    # --- Asepxia ---
    if "asepxia" in fmarca or "asepxia" in fnombre:
        row["url_fuente"] = "https://asepxia.com/"
        row["_revision"] = True
        row["motivo_fotografia"] = "Sitio oficial Asepxia muestra Regenerador/Suavizante/Neutroderma; no coincide con Bicarbon o Exfoliante de inventario"
        row["_diff_presentacion"] = True
        return row

    # --- Ensure / Pediasure / Glucerna: marca oficial, sabor sin packshot de lata ---
    if fmarca in {"ensure", "pediasure", "glucerna"} or any(x in fnombre for x in ("ensure", "pediasure", "glucerna")):
        row["url_fuente"] = "https://www.contigo.abbott/es-mx/marca/" + (fmarca or "ensure")
        row["_revision"] = True
        row["motivo_fotografia"] = "Abbott publica la marca en contigo.abbott, pero no un packshot por sabor/presentación de nuestra SKU"
        return row

    # --- Aspirina / Bayer consumer ---
    if fmarca in {"aspirina", "cafiaspirina", "bayer", "bepanthen", "redoxon", "alka-seltzer", "tabcin"} or any(
        x in fnombre for x in ("aspirina", "cafiaspirina", "bepanthen", "redoxon", "alka-seltzer")
    ):
        row["url_fuente"] = "https://www.aspirina.com.mx/"
        row["_revision"] = True
        row["motivo_fotografia"] = "Sitio Bayer/Aspirina existe pero bloquea scrapers y no confirma tabletas/presentación de esta SKU"
        return row

    # Genéricos / labs chicos
    tipo_l = tipo.lower()
    if tipo_l.startswith("gener") or fmarca in GENERIC_LABS or not marca:
        bits = []
        if tipo_l.startswith("gener") or fmarca in GENERIC_LABS:
            bits.append("laboratorio genérico o de marca propia con cajas muy parecidas entre concentraciones")
        if not marca:
            bits.append("marca/laboratorio no capturado en ficha")
        bits.append("no hay packshot oficial verificable de esta presentación")
        row["motivo_fotografia"] = "; ".join(bits)
        if not ean:
            row["observaciones"] = "Sin código de barras; el archivo de imagen usará el SKU."
        off_row = off.get(sku)
        if off_row and (off_row.get("estado") == "HIT" or str(off_row.get("estado", "")).upper() == "HIT"):
            row["observaciones"] = (
                (row["observaciones"] + " " if row["observaciones"] else "")
                + "Open Food Facts tiene una foto comunitaria (NO USAR; no es fuente oficial ni de distribuidor)."
            )
        return row

    # Marca comercial sin packshot oficial localizado
    row["motivo_fotografia"] = (
        "No se localizó packshot oficial del laboratorio/marca para esta presentación exacta "
        "(concentración, contenido o conteo). No se usaron fotos de otras farmacias ni Google."
    )
    if not ean:
        row["observaciones"] = "Sin código de barras; el archivo de imagen usará el SKU."
    off_row = off.get(sku)
    if off_row:
        est = str(off_row.get("estado") or "")
        if est.upper() in {"HIT", "REVISAR"}:
            row["observaciones"] = (
                (row["observaciones"] + " " if row["observaciones"] else "")
                + f"Open Facts {est} (referencia visual únicamente; no descargar)."
            )
            row["_revision"] = True
    # Labs pequeños de marca
    if fmarca in GENERIC_LABS:
        row["motivo_fotografia"] = "Laboratorio pequeño/genérico; fotografiar empaque físico para evitar confusión de concentración"
    return row


def download(url: str, dest: Path) -> bool:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists() and dest.stat().st_size > 8000:
        return True
    cmd = [
        "curl", "-sL", "--max-time", "40",
        "-A", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) FarmaCapitalCatalog/1.0",
        "-o", str(dest), url,
    ]
    r = subprocess.run(cmd, capture_output=True)
    if r.returncode != 0 or not dest.exists() or dest.stat().st_size < 8000:
        if dest.exists():
            dest.unlink()
        return False
    # skip html error pages
    head = dest.read_bytes()[:32]
    if head.startswith(b"<!DOCTYPE") or head.startswith(b"<html") or head.startswith(b"{"):
        dest.unlink()
        return False
    return True


def main():
    for d in (APROBADAS, REVISAR, FOTOGRAFIAR, TRABAJO):
        d.mkdir(parents=True, exist_ok=True)

    productos = json.loads((TRABAJO / "catalogo_vivo_20260818.json").read_text())
    off = off_index()
    rows = [classify(p, off) for p in productos]

    # downloads
    dl_ok = 0
    dl_fail = 0
    for row in rows:
        if row["descargar_imagen"] != "SI":
            continue
        dest = APROBADAS / row["nombre_archivo_imagen"]
        ok = download(row["url_imagen"], dest)
        if ok:
            dl_ok += 1
            row["observaciones"] = (row["observaciones"] + " " if row["observaciones"] else "") + f"Descargada a catalogo-imagenes/aprobadas/{row['nombre_archivo_imagen']}."
        else:
            dl_fail += 1
            row["descargar_imagen"] = "NO"
            row["fotografiar_en_farmacia"] = "SI"
            row["confianza_imagen"] = "BAJA"
            row["motivo_fotografia"] = "La imagen oficial no se pudo descargar con calidad suficiente; fotografiar en farmacia"
            row["_revision"] = True

    # write master csv
    master = BASE / "catalogo_imagenes_farmacapital.csv"
    with master.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=COLS, extrasaction="ignore")
        w.writeheader()
        for row in rows:
            w.writerow(row)

    foto_rows = [r for r in rows if r["fotografiar_en_farmacia"] == "SI"]
    foto_rows.sort(key=lambda r: (
        fold(r["laboratorio"] or "zzz"),
        fold(r["categoria"] or "zzz"),
        fold(r["producto"] or ""),
    ))
    foto_path = BASE / "productos_para_fotografiar.csv"
    with foto_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=FOTO_COLS, extrasaction="ignore")
        w.writeheader()
        for r in foto_rows:
            w.writerow(r)

    # copy photo list into fotografiar/
    with (FOTOGRAFIAR / "lista.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=FOTO_COLS, extrasaction="ignore")
        w.writeheader()
        for r in foto_rows:
            w.writerow(r)

    rev_rows = [r for r in rows if r.get("_revision") and r["descargar_imagen"] != "SI"]
    with (REVISAR / "productos_a_revisar.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=COLS, extrasaction="ignore")
        w.writeheader()
        for r in rev_rows:
            w.writerow(r)

    diff_rows = [r for r in rows if r.get("_diff_presentacion")]
    with (REVISAR / "posible_diferencia_presentacion.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=COLS, extrasaction="ignore")
        w.writeheader()
        for r in diff_rows:
            w.writerow(r)

    eans = [(r["codigo_barras"] or "").strip() for r in rows]
    ean_counts = Counter(e for e in eans if e)
    dups = sum(1 for v in ean_counts.values() if v > 1)
    sin_ean = sum(1 for e in eans if not e)
    n = len(rows)
    oficial = sum(1 for r in rows if r["tipo_fuente"] == "IMAGEN_OFICIAL")
    oficial_alta = sum(1 for r in rows if r["tipo_fuente"] == "IMAGEN_OFICIAL" and r["confianza_imagen"] == "ALTA" and r["descargar_imagen"] == "SI")
    dist = sum(1 for r in rows if r["tipo_fuente"] == "IMAGEN_DISTRIBUIDOR")
    revisar_n = len(rev_rows)
    foto_n = len(foto_rows)
    resueltos = sum(1 for r in rows if r["fotografiar_en_farmacia"] == "NO")

    resumen = {
        "skus_analizados": n,
        "imagen_oficial": oficial,
        "imagen_oficial_alta_descargada": oficial_alta,
        "imagen_distribuidor": dist,
        "requieren_revision": revisar_n,
        "fotografiar_en_farmacia": foto_n,
        "resueltos_automaticamente": resueltos,
        "pct_resuelto": round(100.0 * resueltos / n, 2) if n else 0,
        "pct_fotografiar": round(100.0 * foto_n / n, 2) if n else 0,
        "sin_codigo_barras": sin_ean,
        "codigos_barras_duplicados": dups,
        "posible_diferencia_presentacion": len(diff_rows),
        "descargas_ok": dl_ok,
        "descargas_fallidas": dl_fail,
        "nota": (
            "No se modificó la base de producción. No se descargaron fotos de otras farmacias, "
            "Google, Pinterest ni Open Food Facts. Icecat no devolvió fichas para los EAN de prueba. "
            "La mayoría del catálogo son genéricos mexicanos sin packshot oficial público."
        ),
    }
    (TRABAJO / "resumen_catalogo_imagenes.json").write_text(json.dumps(resumen, ensure_ascii=False, indent=2))
    print(json.dumps(resumen, ensure_ascii=False, indent=2))
    print("master", master)
    print("foto", foto_path)
    print("aprobadas", list(APROBADAS.glob("*.jpg"))[:20], "n", len(list(APROBADAS.glob("*"))))


if __name__ == "__main__":
    main()
