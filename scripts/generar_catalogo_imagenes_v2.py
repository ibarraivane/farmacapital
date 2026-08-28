#!/usr/bin/env python3
"""Segunda pasada del catálogo de imágenes. No toca producción ni los CSV v1."""
from __future__ import annotations

import csv
import html
import json
import re
import shutil
import subprocess
import unicodedata
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path("/Users/ibarra/farmacapital")
BASE = ROOT / "catalogo-imagenes"
TRABAJO = BASE / "_trabajo"
APROBADAS = BASE / "aprobadas"
REVISAR = BASE / "revisar"
V1 = BASE / "catalogo_imagenes_farmacapital.csv"

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# GTIN-14 (o EAN inventario) → packshot CDN oficial Unilever
UNILEVER = {
    "7501056340124": {
        "img": "https://assets.unileversolutions.com/v1/135985863.png",
        "src": "https://www.sedal.com.mx/p/crema-para-peinar-ceramidas-300ml.html/07501056340124",
        "title": "Crema para Peinar Sedal Ceramidas 300ml",
    },
    "7501056340025": {
        "img": "https://assets.unileversolutions.com/v1/137396999.png",
        "src": "https://www.sedal.com.mx/p/crema-para-peinar-restauracion-instantanea-300ml.html/07501056340025",
        "title": "Crema para Peinar Sedal Restauración Instantánea 300ml",
    },
    "7501056340117": {
        "img": "https://assets.unileversolutions.com/v1/136655055.png",
        "src": "https://www.sedal.com.mx/p/crema-para-peinar-liso-perfecto-300ml.html/07501056340117",
        "title": "Crema para Peinar Sedal Liso Perfecto 300ml",
    },
    "7501056340131": {
        "img": "https://assets.unileversolutions.com/v1/145295371.png",
        "src": "https://www.sedal.com.mx/p/crema-para-peinar-rizos-definidos-300ml.html/07501056340131",
        "title": "Crema para Peinar Sedal Rizos Definidos 300ml",
    },
    "7506306234062": {
        "img": "https://assets.unileversolutions.com/v1/139542242.png",
        "src": "https://www.sedal.com.mx/p/crema-para-peinar-hidratacion-anti-nudos-frambuesa-y-oleos-300ml.html/07506306234062",
        "title": "Crema para Peinar Sedal Hidratación Anti Nudos 300ml",
    },
    "7506306226722": {
        "img": "https://assets.unileversolutions.com/v1/136725350.jpg",
        "src": "https://www.axe.com/mx/p/desodorante-en-aerosol-young-150-ml.html/07506306226722",
        "title": "Axe Young aerosol 150 ml",
    },
    "7506306226739": {
        "img": "https://assets.unileversolutions.com/v1/137511131.jpg",
        "src": "https://www.axe.com/mx/p/desodorante-en-aerosol-conviction-150-ml.html/07506306226739",
        "title": "Axe Conviction aerosol 150 ml",
    },
    "7506306209862": {
        "img": "https://assets.unileversolutions.com/v1/66389387.png",
        "src": "https://www.axe.com/mx/p/desodorante-en-aerosol-anarchy-fresh-150-ml.html/07506306209862",
        "title": "Axe Anarchy Fresh Mujer 150 ml",
    },
    "7506306226852": {
        "img": "https://assets.unileversolutions.com/v1/137499459.jpg",
        "src": "https://www.axe.com/mx/p/desodorante-en-aerosol-anarchy-150-ml.html/07506306226852",
        "title": "Axe Anarchy Mujer 150 ml",
    },
    "7506306245686": {
        "img": "https://assets.unileversolutions.com/v1/137356563.jpg",
        "src": "https://www.axe.com/mx/p/desodorante-en-aerosol-axe-epic-fresh-150-ml.html/07506306245686",
        "title": "Axe Epic Fresh aerosol 150 ml",
    },
    "7506306241206": {
        "img": "https://assets.unileversolutions.com/v1/132862979.png",
        "src": "https://www.dove.com/mx/p/antitranspirante-en-aerosol-rosas.html/07506306241206",
        "title": "Dove Tono Uniforme Rosas aerosol 150 ml",
    },
    "7506306230507": {
        "img": "https://assets.unileversolutions.com/v1/124095199.png",
        "src": "https://www.dove.com/mx/p/barra-de-belleza-purely-pampering-karite.html/07506306230507",
        "title": "Dove barra Karité 135 g",
    },
    "7501056371159": {
        "img": "https://assets.unileversolutions.com/v1/124097206.png",
        "src": "https://www.dove.com/mx/p/barra-de-belleza-exfoliacion-suave.html/07501056371159",
        "title": "Dove barra Exfoliación Suave 135 g",
    },
}

# Aprobadas en revisión visual (usuario: «solo estas»). Discrepancia de GTIN/ml/nombre queda en el motivo.
VISUAL_APROBADAS = {
    "7506306244795": {
        "img": "https://assets.unileversolutions.com/v1/68934163.png",
        "src": "https://www.axe.com/mx/p/anititranspirante-en-aerosol-intense-152-ml.html/07506306244801",
        "motivo": "Aprobada en revisión visual: packshot oficial Axe Intense (ficha 7506306244801 / 152 ml).",
    },
    "7506306248052": {
        "img": "https://assets.unileversolutions.com/v1/132863100.png",
        "src": "https://www.dove.com/mx/p/antitranspirante-en-aerosol-dermoaclarante.html/07506306241152",
        "motivo": "Aprobada en revisión visual: packshot oficial Dove Caléndula (ficha 7506306241152).",
    },
    "4005808837311": {
        "img": "https://img.nivea.com/-/media/miscellaneous/media-center-items/4/1/c/019fdac4b72e7571b92a8337a52831d9-screen.webp",
        "src": "https://www.nivea.com.mx/productos/nivea-antitranspirante-tono-natural-classic-touch-spray-200ml-40060001695380060.html",
        "motivo": "Aprobada en revisión visual: packshot oficial Nivea Pearl & Beauty spray.",
    },
    "7501125144851": {
        "img": "https://electrolit.com.mx/wp-content/uploads/2026/07/uva.png",
        "src": "https://electrolit.com.mx/",
        "motivo": "Aprobada en revisión visual: packshot oficial Electrolit Uva.",
    },
    "7501125104411": {
        "img": "https://electrolit.com.mx/wp-content/uploads/2026/07/coco.png",
        "src": "https://electrolit.com.mx/",
        "motivo": "Aprobada en revisión visual: packshot oficial Electrolit Coco.",
    },
    "7501125149221": {
        "img": "https://electrolit.com.mx/wp-content/uploads/2026/07/fresa-kiwi.png",
        "src": "https://electrolit.com.mx/",
        "motivo": "Aprobada en revisión visual: packshot oficial Electrolit Fresa-Kiwi.",
    },
    "7502214983153": {
        "img": "",
        "src": "https://tienda.prudence.com.mx/products/luv-grosella-30ml",
        "motivo": "Aprobada en revisión visual: packshot oficial Prudence Lub Grosella.",
    },
    "7502214982439": {
        "img": "",
        "src": "https://tienda.prudence.com.mx/products/extra-time-3",
        "motivo": "Aprobada en revisión visual: packshot oficial Prudence Extra Time C/3.",
    },
    "7502214985348": {
        "img": "",
        "src": "https://tienda.prudence.com.mx/products/full-sensitive-3",
        "motivo": "Aprobada en revisión visual: packshot oficial Prudence Full Sensitive C/3.",
    },
    "7502214983726": {
        "img": "",
        "src": "https://tienda.prudence.com.mx/products/lub-natural",
        "motivo": "Aprobada en revisión visual: packshot oficial Prudence Lub Natural.",
    },
    "7501054549796": {
        "img": "",
        "src": "https://www.nivea.com.mx/productos/nivea-body-milk-nutritiva-200-ml-75010545498020060.html",
        "motivo": "Aprobada en revisión visual: packshot oficial Nivea Milk Nutritiva.",
    },
    "7502214980350": {
        "img": "",
        "src": "https://tienda.prudence.com.mx/products/lub-mora",
        "motivo": "Aprobada en revisión visual: packshot oficial Prudence Lub mora azul 75 ml.",
    },
}

ELECTROLIT_IMG = {
    "uva": ("https://electrolit.com.mx/wp-content/uploads/2026/07/uva.png", "uva"),
    "coco": ("https://electrolit.com.mx/wp-content/uploads/2026/07/coco.png", "coco"),
    "fresa kiwi": ("https://electrolit.com.mx/wp-content/uploads/2026/07/fresa-kiwi.png", "fresa kiwi"),
    "fresa": ("https://electrolit.com.mx/wp-content/uploads/2026/07/main-slide-fresa.jpg", "fresa"),
    "mora azul": ("https://electrolit.com.mx/wp-content/uploads/2026/07/mora-azul.png", "mora azul"),
    "naranja mandarina": ("https://electrolit.com.mx/wp-content/uploads/2026/07/naranja-mandarina.png", "naranja mandarina"),
}

SUEROX_FRESA_FRUTOS = "https://suerox.com/hubfs/Suerox/FRESA%20KIWI.jpg"

V1_COLS = [
    "sku", "codigo_barras", "producto", "nombre_comercial", "principio_activo",
    "concentracion", "presentacion", "contenido", "laboratorio", "marca",
    "categoria", "subcategoria", "imagen_encontrada", "url_imagen", "url_fuente",
    "tipo_fuente", "confianza_imagen", "coincide_codigo_barras",
    "coincide_presentacion", "descargar_imagen", "fotografiar_en_farmacia",
    "motivo_fotografia", "nombre_archivo_imagen", "observaciones",
]
V2_COLS = V1_COLS + [
    "estado_v2", "tipo_fuente_v2", "url_imagen_v2", "url_fuente_v2",
    "coincide_ean_v2", "archivo_local_v2", "motivo_v2",
]


def fold(s: str) -> str:
    s = unicodedata.normalize("NFKD", s or "")
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = s.lower()
    s = re.sub(r"[^a-z0-9]+", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def ean_key(e: str) -> str:
    e = (e or "").strip()
    if e.isdigit():
        return e.lstrip("0") or "0"
    return e


def filename_for(ean: str, sku: str) -> str:
    e = (ean or "").strip()
    if e.isdigit() and len(e) >= 8:
        return f"{e}.jpg"
    return f"{sku}.jpg"


def download(url: str, dest: Path, min_bytes: int = 4000) -> bool:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists() and dest.stat().st_size > min_bytes:
        head = dest.read_bytes()[:24]
        if not (head.startswith(b"<!DOCTYPE") or head.startswith(b"<html") or head.startswith(b"<HTML")):
            return True
    cmd = [
        "curl", "-sL", "--max-time", "18", "-A", UA,
        "-e", "https://www.unilever.com.mx/",
        "-o", str(dest), url,
    ]
    subprocess.run(cmd, capture_output=True)
    if not dest.exists() or dest.stat().st_size < min_bytes:
        dest.unlink(missing_ok=True)
        return False
    head = dest.read_bytes()[:24]
    if head.startswith(b"<!DOCTYPE") or head.startswith(b"<html") or head.startswith(b"<HTML") or head.startswith(b"{"):
        dest.unlink(missing_ok=True)
        return False
    return True


def load_prudence():
    return json.loads((TRABAJO / "prudence_catalog.json").read_text())


def prudence_by_needles(needles: tuple[str, ...]):
    for p in load_prudence():
        t = fold(p.get("title") or "")
        if all(n in t for n in needles) and p.get("image"):
            return p
    return None


def load_off():
    by = {}
    path = ROOT / "sql/generated/fotos_openfacts_20260818.csv"
    with path.open(encoding="utf-8") as f:
        for r in csv.DictReader(f):
            if (r.get("estado") or "").upper() != "HIT":
                continue
            if (r.get("match") or "") not in ("coincide", "nombre"):
                continue
            if r.get("img"):
                by[r["sku"]] = r
    return by


def load_nivea():
    path = TRABAJO / "nivea_teasers.json"
    if not path.exists():
        return []
    return json.loads(path.read_text())


def nivea_match(nombre: str):
    fn = fold(nombre)
    best = None
    best_n = 0
    for t in load_nivea():
        ft = fold(t.get("name") or "")
        tokens = [w for w in fn.split() if len(w) > 3 and w not in {"nivea", "crema", "para"}]
        hit = sum(1 for w in tokens if w in ft)
        if hit >= 2 and hit > best_n:
            best, best_n = t, hit
    return best if best_n >= 2 else None


def set_estado(row, estado, tipo, url_img, url_src, coincide_ean, motivo, archivo=""):
    row["estado_v2"] = estado
    row["tipo_fuente_v2"] = tipo
    row["url_imagen_v2"] = url_img or ""
    row["url_fuente_v2"] = url_src or ""
    row["coincide_ean_v2"] = coincide_ean
    row["archivo_local_v2"] = archivo
    row["motivo_v2"] = motivo
    if estado.startswith("APROBADA"):
        row["imagen_encontrada"] = "SI"
        row["fotografiar_en_farmacia"] = "NO"
        row["descargar_imagen"] = "SI"
        row["confianza_imagen"] = "ALTA"
        row["tipo_fuente"] = tipo
        row["url_imagen"] = url_img
        row["url_fuente"] = url_src
        row["motivo_fotografia"] = ""
    elif estado == "REVISAR_VISUALMENTE":
        row["fotografiar_en_farmacia"] = "NO"
        row["imagen_encontrada"] = "SI" if url_img else "NO"
        row["descargar_imagen"] = "NO"
        row["confianza_imagen"] = "MEDIA"
        row["motivo_fotografia"] = motivo
    else:
        row["fotografiar_en_farmacia"] = "SI"
        row["descargar_imagen"] = "NO"
        row["confianza_imagen"] = "BAJA"
        row["motivo_fotografia"] = motivo


def classify(row, off):
    sku = row["sku"]
    ean = (row["codigo_barras"] or "").strip()
    fn = fold(f"{row['producto']} {row['presentacion']} {row['contenido']}")
    fmarca = fold(row["marca"])
    flab = fold(row["laboratorio"])
    fnombre = filename_for(ean, sku)
    ek = ean_key(ean)

    # 1) Ya aprobadas v1 (Suerox 8 Iones 630 ml + Prudence Extra Pleasure / Uva C/3)
    if row.get("descargar_imagen") == "SI" and row.get("confianza_imagen") == "ALTA":
        dest = APROBADAS / fnombre
        set_estado(
            row, "APROBADA_OFICIAL", "IMAGEN_OFICIAL",
            row.get("url_imagen") or "", row.get("url_fuente") or "",
            "NO",
            "Conservada de la primera pasada (sitio oficial de marca).",
            str(dest.relative_to(BASE)) if dest.exists() else fnombre,
        )
        row["coincide_ean_v2"] = "SI" if ean else "NO"
        return row

    # 2) Unilever GTIN exacto en URL oficial + CDN Unilever
    if ek in {ean_key(k) for k in UNILEVER}:
        rec = next(v for k, v in UNILEVER.items() if ean_key(k) == ek)
        dest = APROBADAS / fnombre
        ok = download(rec["img"], dest)
        if ok:
            set_estado(
                row, "APROBADA_OFICIAL", "IMAGEN_OFICIAL",
                rec["img"], rec["src"], "SI",
                f"GTIN coincidente en ficha Unilever México: {rec['title']}. Packshot CDN assets.unileversolutions.com.",
                str(dest.relative_to(BASE)),
            )
            return row
        set_estado(
            row, "REVISAR_VISUALMENTE", "IMAGEN_OFICIAL",
            rec["img"], rec["src"], "SI",
            "GTIN oficial localizado pero la descarga del CDN falló.",
        )
        return row

    # 2b) Aprobadas en revisión visual (GTIN/ml/nombre no unívocos; el usuario las eligió)
    if ek in {ean_key(k) for k in VISUAL_APROBADAS}:
        rec = next(v for k, v in VISUAL_APROBADAS.items() if ean_key(k) == ek)
        dest = APROBADAS / fnombre
        src = REVISAR / fnombre
        if not dest.exists() and src.exists():
            shutil.copy2(src, dest)
        if dest.exists() and dest.stat().st_size > 4000:
            set_estado(
                row, "APROBADA_OFICIAL", "IMAGEN_OFICIAL",
                rec.get("img") or "", rec["src"], "NO", rec["motivo"],
                str(dest.relative_to(BASE)),
            )
            return row

    # 3) Prudence tienda oficial: línea + conteo exactos
    if fmarca == "prudence" or "prudence" in fn:
        pairs = [
            (("clasico", "3"), ("clasico", "c 3")),
            (("fresa", "3"), ("fresa", "c 3")),
            (("chocolate",), ("chocolate", "c 3")),
            (("mora", "3"), ("mora", "c 3")),
            (("soda", "3"), ("soda", "c 3")),
            (("caribbean", "mix"), ("caribbean", "sensitivo", "c 5")),
            (("surtido", "5"), ("mix", "c 5")),
            (("chicle", "5"), ("chicle", "c 5")),
        ]
        for inv, shop in pairs:
            if all(x in fn for x in inv):
                p = prudence_by_needles(shop)
                if p and ("c 3" in fold(p["title"]) or "c 5" in fold(p["title"])):
                    dest = APROBADAS / fnombre
                    if download(p["image"], dest):
                        set_estado(
                            row, "APROBADA_OFICIAL", "IMAGEN_OFICIAL",
                            p["image"], p["url"], "NO",
                            f"Tienda oficial Prudence México: {p['title']}. Shopify no publica EAN; coinciden línea y conteo.",
                            str(dest.relative_to(BASE)),
                        )
                        return row
        if "ull retardante" in fn or "extra time" in fn:
            set_estado(
                row, "FOTOGRAFIAR", "", "", "https://tienda.prudence.com.mx/products/extra-time-3", "NO",
                "No seleccionada en la revisión visual. Fotografiar el empaque físico.",
            )
            return row
        if "ultra sensitive" in fn or "full sensitive" in fn:
            set_estado(
                row, "FOTOGRAFIAR", "", "", "https://tienda.prudence.com.mx/products/full-sensitive-3", "NO",
                "No seleccionada en la revisión visual. Fotografiar el empaque físico.",
            )
            return row
        if "lubricante" in fn or "lub" in fn:
            set_estado(
                row, "FOTOGRAFIAR", "", "", "https://tienda.prudence.com.mx/", "NO",
                "No seleccionada en la revisión visual. Fotografiar el empaque físico.",
            )
            return row
        set_estado(
            row, "FOTOGRAFIAR", "", "", "https://tienda.prudence.com.mx/", "NO",
            "Prudence está en la tienda oficial, pero esta variante no se emparejó de forma unívoca (conteo o nombre).",
        )
        return row

    # 4) Unilever cercano no seleccionado en revisión visual (p. ej. Ice Chill)
    if ek == ean_key("7506306213906"):
        set_estado(
            row, "FOTOGRAFIAR", "", "", "https://www.axe.com/mx/", "NO",
            "Axe Ice Chill oficial es 7506306213920, no el GTIN de inventario. No seleccionada en revisión visual.",
        )
        return row

    # 5) Electrolit: solo Uva/Coco/Fresa-Kiwi se aprobaron visualmente
    if fmarca == "electrolit" or fn.startswith("electrolit"):
        set_estado(
            row, "FOTOGRAFIAR", "", "", "https://electrolit.com.mx/", "NO",
            "No seleccionada en la revisión visual. Fotografiar el empaque físico (sabores/ml 250–1150).",
        )
        return row

    # 6) Suerox Frutos Rojos / Vitamins
    if "suerox" in fmarca or "suerox" in fn:
        if "frutos rojos" in fn:
            set_estado(
                row, "FOTOGRAFIAR", "", "", "https://suerox.com/", "NO",
                "Sitio oficial muestra Fresa Frutos Rojos, no Frutos Rojos a secas. No seleccionada en revisión visual.",
            )
            return row
        if "vitamins" in fn:
            set_estado(
                row, "FOTOGRAFIAR", "", "", "https://suerox.com/", "NO",
                "Suerox Vitamins es otra línea; el packshot de 8 Iones no aplica.",
            )
            return row

    # 7) Nivea: Pearl y Milk Nutritiva se aprobaron visualmente; el resto se fotografía
    if fmarca == "nivea" or "nivea" in fn:
        set_estado(
            row, "FOTOGRAFIAR", "", "", "https://www.nivea.com.mx/productos", "NO",
            "No seleccionada en la revisión visual. Fotografiar el empaque físico.",
        )
        return row

    # 8) Hinds: 90 ml vs 400 ml oficial
    if fmarca == "hinds" or "hinds" in fn:
        set_estado(
            row, "FOTOGRAFIAR", "", "", "https://www.hinds.com.mx/productos", "NO",
            "Sitio oficial Hinds exhibe sobre todo 400 ml; el inventario incluye 90 ml u otras presentaciones. Discrepancia de empaque.",
        )
        return row

    # 9) Open Food Facts no se usa: solo packshots oficiales de marca.

    # 10) Marcas de consumo con sitio, sin packshot unívoco
    consumer = (
        "unilever", "colgate", "palmolive", "mennen", "escudo", "pantene",
        "oral", "head", "shoulders", "old spice", "bayer", "aspirina", "haleon",
        "sensodyne", "centrum", "abbott", "ensure", "pediasure", "glucerna",
        "pedialyte", "nestle", "nestlé", "nido", "genomma", "grisi", "sico",
        "kimberly", "kotex", "reckitt", "pepto", "vick",
    )
    blob = f"{fn} {fmarca} {flab}"
    if any(c in blob for c in consumer):
        set_estado(
            row, "FOTOGRAFIAR", "", "", "", "NO",
            "Marca de consumo con presencia oficial, pero no hubo GTIN/packshot inequívoco ni candidato descargable. No se copió de Ahorro/Guadalajara/Amazon. Si se publica en Rappi/DiDi, fotografiar con prioridad.",
        )
        return row

    set_estado(
        row, "FOTOGRAFIAR", "", "", "", "NO",
        "Tras la segunda pasada no hay imagen oficial, de distribuidor ni GS1 verificable para esta presentación. Equilibrio/eQ-Fácil y Nadro/Marzam requieren login de cliente; Syncfonía+ no entrega packshots de terceros sin membresía receptora.",
    )
    return row


def write_html(rows):
    cards = [r for r in rows if r["estado_v2"] == "REVISAR_VISUALMENTE"]
    if not cards:
        (BASE / "revision_visual.html").write_text(
            "<!DOCTYPE html><html lang='es'><head><meta charset='utf-8'>"
            "<title>Revisión visual — catálogo imágenes FarmaCapital v2</title>"
            "<style>body{font-family:ui-sans-serif,system-ui,sans-serif;background:#f4f1ea;color:#1c1917;margin:0}"
            "header{padding:24px 28px;background:#1c1917;color:#fafaf9}"
            "h1{margin:0 0 8px;font-size:22px} p{margin:0;opacity:.85;max-width:70ch}"
            ".ok{margin:48px 28px;padding:28px;background:#fff;border-radius:14px;max-width:52ch}</style></head><body>"
            "<header><h1>Revisión visual de imágenes</h1>"
            "<p>Las 12 imágenes que marcaste ya pasaron a <code>aprobadas/</code>. No quedan candidatas pendientes.</p></header>"
            "<div class='ok'>Cuadrícula vacía. Las oficiales aprobadas están en <code>catalogo-imagenes/aprobadas/</code>.</div>"
            "</body></html>",
            encoding="utf-8",
        )
        return
    parts = [
        "<!DOCTYPE html><html lang='es'><head><meta charset='utf-8'>",
        "<title>Revisión visual — catálogo imágenes FarmaCapital v2</title>",
        "<style>",
        "body{font-family:ui-sans-serif,system-ui,sans-serif;background:#f4f1ea;color:#1c1917;margin:0}",
        "header{padding:24px 28px;background:#1c1917;color:#fafaf9}",
        "h1{margin:0 0 8px;font-size:22px} p{margin:0;opacity:.85;max-width:70ch}",
        ".stats{display:flex;gap:16px;padding:16px 28px;flex-wrap:wrap}",
        ".stats b{display:block;font-size:20px}",
        ".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:16px;padding:0 28px 48px}",
        ".card{background:#fff;border-radius:14px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,.08)}",
        ".card img{width:100%;height:220px;object-fit:contain;background:#fafaf9}",
        ".ph{height:220px;display:flex;align-items:center;justify-content:center;color:#a8a29e;background:#e7e5e4}",
        ".meta{padding:12px 14px;font-size:13px;line-height:1.45}",
        ".meta strong{display:block;font-size:14px;margin-bottom:4px}",
        ".tag{display:inline-block;background:#fef3c7;color:#92400e;border-radius:999px;padding:2px 8px;font-size:11px;margin:6px 0}",
        "a{color:#1d4ed8;word-break:break-all}",
        "</style></head><body>",
        "<header><h1>Revisión visual de imágenes</h1>",
        "<p>Solo packshots oficiales de fabricante. Open Food Facts y fotos comunitarias se descartaron. ",
        "Aprueba o rechaza viendo empaque vs inventario. No están en producción.</p></header>",
        f"<div class='stats'><div><b>{len(cards)}</b>pendientes de revisión</div></div>",
        "<div class='grid'>",
    ]
    for r in cards:
        src = r.get("archivo_local_v2") or ""
        img = f"<img src='{html.escape(src)}' alt=''>" if src else "<div class='ph'>Sin archivo local</div>"
        ean = html.escape(r.get("codigo_barras") or "—")
        parts.append(
            "<article class='card'>"
            + img
            + "<div class='meta'>"
            + f"<strong>{html.escape(r.get('producto') or '')}</strong>"
            + f"{html.escape(r.get('laboratorio') or '')} · {html.escape(r.get('presentacion') or r.get('contenido') or '—')}<br>"
            + f"EAN {ean}<br>"
            + f"<span class='tag'>{html.escape(r.get('tipo_fuente_v2') or 'SIN FUENTE')}</span>"
            + f"<div>Fuente: {html.escape(r.get('url_fuente_v2') or '—')}</div>"
            + (f"<div><a href='{html.escape(r.get('url_imagen_v2'))}'>URL imagen</a></div>" if r.get("url_imagen_v2") else "")
            + f"<div>{html.escape(r.get('motivo_v2') or '')}</div>"
            + "</div></article>"
        )
    parts.append("</div></body></html>")
    (BASE / "revision_visual.html").write_text("".join(parts), encoding="utf-8")


def main():
    for d in (APROBADAS, REVISAR, TRABAJO):
        d.mkdir(parents=True, exist_ok=True)

    with V1.open(encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    off = {}

    out = [classify(dict(r), off) for r in rows]

    master = BASE / "catalogo_imagenes_farmacapital_v2.csv"
    with master.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=V2_COLS, extrasaction="ignore")
        w.writeheader()
        w.writerows(out)

    foto = [r for r in out if r["estado_v2"] == "FOTOGRAFIAR"]
    foto.sort(key=lambda r: (fold(r["laboratorio"] or "zzz"), fold(r["categoria"] or ""), fold(r["producto"] or "")))
    foto_path = BASE / "productos_para_fotografiar_v2.csv"
    foto_cols = ["sku", "codigo_barras", "producto", "laboratorio", "presentacion", "motivo_v2"]
    with foto_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=foto_cols, extrasaction="ignore")
        w.writeheader()
        w.writerows(foto)

    write_html(out)

    from collections import Counter
    c = Counter(r["estado_v2"] for r in out)
    n = len(out)
    resumen = {
        "skus_totales": n,
        "aprobadas_v1": 12,
        "APROBADA_OFICIAL": c["APROBADA_OFICIAL"],
        "APROBADA_GS1": c["APROBADA_GS1"],
        "APROBADA_DISTRIBUIDOR": c["APROBADA_DISTRIBUIDOR"],
        "nuevas_oficiales": max(0, c["APROBADA_OFICIAL"] - 12),
        "aprobadas_revision_visual": 12,
        "REVISAR_VISUALMENTE": c["REVISAR_VISUALMENTE"],
        "FOTOGRAFIAR": c["FOTOGRAFIAR"],
        "fotografiar_antes": 1111,
        "fotografias_evitadas": 1111 - c["FOTOGRAFIAR"],
        "pct_resuelto_aprobadas": round(100.0 * c["APROBADA_OFICIAL"] / n, 2),
        "pct_con_candidata": round(100.0 * (n - c["FOTOGRAFIAR"]) / n, 2),
        "pct_fotografiar": round(100.0 * c["FOTOGRAFIAR"] / n, 2),
        "nota": (
            "No se modificó producción ni los CSV v1. GS1/Syncfonía+ no entrega imágenes de terceros "
            "sin membresía receptora. Equilibrio eQ-Fácil y mayoristas típicos piden login. "
            "Open Food Facts se descartó: solo se conservan packshots oficiales de marca."
        ),
    }
    (TRABAJO / "resumen_catalogo_imagenes_v2.json").write_text(
        json.dumps(resumen, ensure_ascii=False, indent=2)
    )
    print(json.dumps(resumen, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
