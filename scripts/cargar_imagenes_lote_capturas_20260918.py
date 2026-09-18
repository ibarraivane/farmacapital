#!/usr/bin/env python3
"""Normaliza packshots del lote de capturas (18-sep-2026) a catalogo-propia.

Uso:
    python3 scripts/cargar_imagenes_lote_capturas_20260918.py
"""
from __future__ import annotations

import csv
import hashlib
import io
import re
import sys
import unicodedata
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
from lib.imagen_competencia import (  # noqa: E402
    es_placeholder_imagen_competencia,
    es_url_imagen_competencia,
)

DEST = ROOT / "public" / "catalogo-propia"
SQL_OUT = ROOT / "sql" / "patch_fotos_lote_capturas_20260918.sql"
MANIFEST = ROOT / "sql" / "generated" / "carga_imagenes_lote_capturas_20260918_manifest.csv"
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"
MIN_LADO = 200

# origen, archivo_src, ean, sku, nombre, fuente, origen_sql
FILAS = [
    (
        "/opt/cursor/artifacts/assets/cubrebocas-tricapa-negro-generico.png",
        "2008500100013",
        "FC-00100013",
        "Cubrebocas tricapa desechable negro C/100",
        "generica-negra",
        "propia",
    ),
    (
        "/tmp/fotos-lote-internos/dona-chongo-esponja-negra-2008550100018.jpg",
        "2008550100018",
        "",
        "Dona / bolsa IJJ-10 C/12",
        "dansking",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-internos/copa-lavaojos-vidrio-2008490100017.jpg",
        "2008490100017",
        "",
        "Copa lavaojos de vidrio",
        "farmavrim",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-meds/dorixina-forte-250-mg-c-20-7501300422750.jpg",
        "7501300422750",
        "",
        "Dorixina Forte clonixinato de lisina 250 mg C/20",
        "farmatodo",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-meds/dosteril-lisinopril-10-mg-c-30-7501573925071.jpg",
        "7501573925071",
        "",
        "Dosteril lisinopril 10 mg C/30 tabletas",
        "bspharma",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-meds/dolxen-naproxeno-250-mg-c-20-7502009740176.jpg",
        "7502009740176",
        "EQ-MAV028",
        "Dolxen naproxeno 250 mg C/20 Maver",
        "bspharma",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-meds/dolac-ketorolaco-sublingual-30-mg-c-6-7501300420824.jpg",
        "7501300420824",
        "",
        "Dolac ketorolaco sublingual 30 mg C/6",
        "farmatodo",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-meds/debisor-10-mg-c-20-novag-7501075711011.jpg",
        "7501075711011",
        "EQ-NOV007",
        "Debisor 10 mg C/20 Novag",
        "bspharma",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-meds/contraxen-carisoprodol-naproxeno-200-250-c-30-7501836003140.jpg",
        "7501836003140",
        "FC-36003140",
        "Contraxen carisoprodol/naproxeno 200/250 mg C/30",
        "farmaciaherrera",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-meds/coniax-citicolina-500-mg-c-10-7502009749322.jpg",
        "7502009749322",
        "EQ-MAV394",
        "Coniax Citicolina 500 mg C/10 Maver",
        "sanorim",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-deos/savile-manzanilla-stick-45g-75065102.jpg",
        "75065102",
        "",
        "Savilé desodorante manzanilla stick 45 g",
        "delsol",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-deos/savile-sabila-nacar-spray-150ml-7506306215511.jpg",
        "7506306215511",
        "",
        "Savilé desodorante sábila y nácar spray 150 ml",
        "dax",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-deos/savile-manzanilla-spray-150ml-7506306209763.jpg",
        "7506306209763",
        "",
        "Savilé desodorante manzanilla spray 150 ml",
        "delsol",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-deos/rexona-women-bamboo-rollon-50ml-78924345.jpg",
        "78924345",
        "",
        "Rexona Women Bamboo roll-on 50 ml",
        "delsol",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-deos/old-spice-mar-profundo-spray-150ml-7500435141796.jpg",
        "7500435141796",
        "",
        "Old Spice Mar Profundo spray 150 ml",
        "delsol",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-deos/lady-speed-stick-powder-fresh-rollon-50ml-7509546060477.jpg",
        "7509546060477",
        "",
        "Lady Speed Stick Powder Fresh roll-on 50 ml",
        "delsol",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-deos/lady-speed-stick-powder-fresh-spray-60g-7509546071275.jpg",
        "7509546071275",
        "",
        "Lady Speed Stick Powder Fresh spray 60 g",
        "farmaciasanjorge",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-deos/gillette-arctic-ice-spray-150ml-7506309864822.jpg",
        "7506309864822",
        "",
        "Gillette Arctic Ice spray 150 ml",
        "farmacorp",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-deos/gillette-cool-wave-rollon-60g-7702018913954.jpg",
        "7702018913954",
        "",
        "Gillette Cool Wave roll-on 60 g",
        "delsol",
        "distribuidor",
    ),
    (
        "/tmp/fotos-lote-malas/trojan-pro-tech-clasico-enzimatico-c3-7501080950139.jpg",
        "7501080950139",
        "FC-80950139",
        "Condones Trojan Pro-Tech C/3",
        "wecarepharma",
        "distribuidor",
    ),
]


def slug(nombre: str, ean: str) -> str:
    s = unicodedata.normalize("NFKD", nombre or "producto")
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r"[^a-zA-Z0-9]+", "-", s).strip("-").lower()[:48].strip("-")
    return f"{s}-{ean}.jpg" if ean else f"{s}.jpg"


def sql_escape(s: str) -> str:
    return (s or "").replace("'", "''")


def normalizar_jpg(blob: bytes) -> bytes:
    if es_placeholder_imagen_competencia(blob):
        raise ValueError("placeholder Fahorro")
    im = Image.open(io.BytesIO(blob))
    im.load()
    if min(im.size) < MIN_LADO:
        raise ValueError(f"resolucion baja {im.size[0]}x{im.size[1]}")
    if im.mode in ("RGBA", "LA", "P"):
        im = im.convert("RGBA")
        fondo = Image.new("RGB", im.size, (255, 255, 255))
        fondo.paste(im, mask=im.split()[-1])
        im = fondo
    else:
        im = im.convert("RGB")
    lado = max(im.size)
    lienzo = Image.new("RGB", (lado, lado), (255, 255, 255))
    lienzo.paste(im, ((lado - im.size[0]) // 2, (lado - im.size[1]) // 2))
    if lado > 1200:
        lienzo = lienzo.resize((1200, 1200), Image.LANCZOS)
    buf = io.BytesIO()
    lienzo.save(buf, "JPEG", quality=88, optimize=True)
    out = buf.getvalue()
    if es_placeholder_imagen_competencia(out):
        raise ValueError("placeholder Fahorro tras normalizar")
    return out


def main() -> int:
    DEST.mkdir(parents=True, exist_ok=True)
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    listas = []
    for src, ean, sku, nombre, fuente, origen in FILAS:
        path = Path(src)
        if not path.exists():
            print(f"  ✗ falta {path}")
            return 1
        blob = path.read_bytes()
        if es_url_imagen_competencia(str(path)):
            print(f"  ✗ url competencia {path}")
            return 1
        try:
            jpg = normalizar_jpg(blob)
        except ValueError as exc:
            print(f"  ✗ {nombre}: {exc}")
            return 1
        dest_name = slug(nombre, ean)
        (DEST / dest_name).write_bytes(jpg)
        listas.append({
            "ean": ean,
            "sku": sku,
            "nombre": nombre,
            "archivo": dest_name,
            "fuente": fuente,
            "origen": origen,
            "bytes": len(jpg),
            "md5": hashlib.md5(jpg).hexdigest(),
        })
        print(f"  ✓ {dest_name} ({len(jpg)//1024} KB) {fuente}")

    with MANIFEST.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(listas[0].keys()))
        w.writeheader()
        w.writerows(listas)

    values = []
    for it in listas:
        ean = sql_escape(it["ean"])
        sku = sql_escape(it["sku"])
        url = sql_escape(f"{FOTO_BASE}/{it['archivo']}")
        values.append(f"  ('{ean}', '{sku}', '{url}', '{it['origen']}')")

    eans = ", ".join(f"'{sql_escape(it['ean'])}'" for it in listas if it["ean"])
    skus = ", ".join(f"'{sql_escape(it['sku'])}'" for it in listas if it["sku"])

    lineas = [
        "-- Fotos lote capturas tienda (2026-09-18).",
        "-- Packshots en public/catalogo-propia/. ORDEN: 1) merge/deploy  2) este SQL.",
        "-- origen SOLO admite rappi | distribuidor | propia | gs1 | otro.",
        "-- Idempotente: no duplica la misma URL. Reemplaza portada vacía,",
        "-- Fahorro, o una portada distinta de este lote (Trojan lifestyle, etc.).",
        "-- Match por EAN o SKU (sin ids fijos: los de Equilibrio/internos varían).",
        "",
        "begin;",
        "",
        "create temporary table tmp_foto_cap (",
        "  ean text,",
        "  sku text,",
        "  url text not null,",
        "  origen text not null",
        ") on commit drop;",
        "",
        "insert into tmp_foto_cap (ean, sku, url, origen) values",
        ",\n".join(values) + ";",
        "",
        "-- Coniax: el ticket Equilibrio a veces llega sin EAN",
        "update public.productos",
        "set codigo_barras = '7502009749322'",
        "where sku = 'EQ-MAV394'",
        "  and (codigo_barras is null or btrim(codigo_barras) = '');",
        "",
        "update public.productos p",
        "set imagen_url = t.url,",
        "    imagen_mobile_url = t.url",
        "from tmp_foto_cap t",
        "where (",
        "    (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))",
        "    or (t.sku <> '' and p.sku = t.sku)",
        "  )",
        "  and (",
        "    p.imagen_url is null",
        "    or btrim(p.imagen_url) = ''",
        "    or p.imagen_url ilike '%fahorro%'",
        "    or p.imagen_url not like '%' || regexp_replace(t.url, '^.*/', '') || '%'",
        "  );",
        "",
        "insert into public.producto_imagenes",
        "  (producto_id, url, storage_path, posicion, es_principal, origen)",
        "select",
        "  p.id,",
        "  t.url,",
        "  'catalogo-propia/' || regexp_replace(t.url, '^.*/', ''),",
        "  coalesce((select max(i.posicion) from public.producto_imagenes i",
        "            where i.producto_id = p.id), 0) + 1,",
        "  false,",
        "  t.origen",
        "from tmp_foto_cap t",
        "join public.productos p",
        "  on (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))",
        "  or (t.sku <> '' and p.sku = t.sku)",
        "where not exists (",
        "  select 1 from public.producto_imagenes i",
        "  where i.producto_id = p.id and i.url = t.url",
        ");",
        "",
        "update public.producto_imagenes i",
        "set es_principal = false",
        "from tmp_foto_cap t, public.productos p",
        "where i.producto_id = p.id",
        "  and i.es_principal",
        "  and i.url not in (select url from tmp_foto_cap)",
        "  and (",
        "    (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))",
        "    or (t.sku <> '' and p.sku = t.sku)",
        "  );",
        "",
        "update public.producto_imagenes i",
        "set es_principal = true",
        "where i.url in (select url from tmp_foto_cap)",
        "  and not i.es_principal;",
        "",
        "commit;",
        "",
        "select p.id, p.sku, p.codigo_barras, p.nombre, left(coalesce(p.imagen_url, ''), 100) as imagen",
        "from public.productos p",
        f"where p.codigo_barras in ({eans})",
        f"   or p.sku in ({skus})",
        "order by p.nombre;",
        "",
    ]
    SQL_OUT.write_text("\n".join(lineas), encoding="utf-8")
    print(f"SQL: {SQL_OUT}")
    print(f"manifest: {MANIFEST}")
    print(f"fotos: {len(listas)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
