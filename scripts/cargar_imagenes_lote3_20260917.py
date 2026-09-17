#!/usr/bin/env python3
"""Normaliza packshots del lote 3 a public/catalogo-propia/ y escribe SQL.

Uso:
    python3 scripts/cargar_imagenes_lote3_20260917.py
"""
from __future__ import annotations

import csv
import io
import re
import unicodedata
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
INSP = ROOT / "catalogo-imagenes" / "lote_20260917_insp"
DEST = ROOT / "public" / "catalogo-propia"
SQL_OUT = ROOT / "sql" / "patch_fotos_lote3_restantes_20260917.sql"
MANIFEST = ROOT / "sql" / "generated" / "carga_imagenes_lote3_20260917_manifest.csv"
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"
MIN_LADO = 200

# origen, archivo_insp, producto_id, ean_catalogo, nombre, fuente
FILAS = [
    ("243_7501001303464.jpg", 243, "7501001303454",
     "Pantene Pro-V Control Caída shampoo 400 ml", "farmatodo", "distribuidor"),
    ("339_7501868900226.webp", 339, "7501868900226",
     "Alcohol etílico Dibar 96° 250 ml", "promexsa", "distribuidor"),
    ("1270_7501846504859.jpg", 1270, "7501846504859",
     "Xiomara Pomada Black / Cera Black 60 g", "chedraui", "distribuidor"),
    ("1633_759684313295.jpg", 1633, "759684313295",
     "Jaloma Mertodol blanco atomizador", "almacenesfarah", "distribuidor"),
    ("1760_7502209850231.png", 1760, "7502209850231",
     "Zagapsol amlodipino 5 mg C/10", "phemedica", "distribuidor"),
    ("1762_6358975544000.png", 1762, "6358975544000",
     "Clorofil Jahvs solución 500 mL", "sanorim", "distribuidor"),
    ("1801_7506494600311.jpg", 1801, "7506494600311",
     "Cloropiramina Schoen 25 mg", "sanorim", "distribuidor"),
    ("1720_lady_chica.jpg", 1720, "7501370204584",
     "Pinza Lady Curtis mini 58LC", "curtis", "distribuidor"),
    ("1721_lady_grande.jpg", 1721, "7501370204577",
     "Pinza Lady Curtis maxi 57LC", "curtis", "distribuidor"),
    ("1315_gerber_res.png", 1315, "7506475102520",
     "Gerber Etapa 2 res verduras y arroz", "nestle", "distribuidor"),
    ("1316_gerber_pollo.png", 1316, "7506475102537",
     "Gerber Etapa 2 pollo verduras y arroz", "nestle", "distribuidor"),
    ("1317_gerber_durazno_oficial.png", 1317, "7506475102476",
     "Gerber Etapa 2 durazno", "nestle", "distribuidor"),
    ("1319_gerber_mango_oficial.png", 1319, "7506475102469",
     "Gerber Etapa 2 mango", "nestle", "distribuidor"),
]


def slug(nombre: str, ean: str) -> str:
    s = unicodedata.normalize("NFKD", nombre or "producto")
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r"[^a-zA-Z0-9]+", "-", s).strip("-").lower()[:48].strip("-")
    return f"{s}-{ean}.jpg" if ean else f"{s}.jpg"


def normalizar_jpg(blob: bytes) -> bytes:
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
    return buf.getvalue()


def sql_escape(s: str) -> str:
    return s.replace("'", "''")


def main() -> int:
    DEST.mkdir(parents=True, exist_ok=True)
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    listas = []
    for archivo, pid, ean, nombre, fuente, origen in FILAS:
        src = INSP / archivo
        if not src.exists():
            print(f"  ✗ falta {src}")
            return 1
        blob = normalizar_jpg(src.read_bytes())
        dest_name = slug(nombre, ean)
        (DEST / dest_name).write_bytes(blob)
        listas.append({
            "producto_id": pid,
            "codigo_barras": ean,
            "nombre": nombre,
            "archivo": dest_name,
            "fuente": fuente,
            "origen": origen,
            "bytes": len(blob),
        })
        print(f"  ✓ {pid} {dest_name} ({len(blob)//1024} KB)")

    # ya estaban en el repo
    extra = [
        (1771, "7506281106019", "Ferro-4 Streger 30 grageas",
         "ferro-4-30grag-7506281106019.jpg", "propia", "propia"),
        (1719, "074451166561", "Baby Einstein Neptune Busy Bubbles",
         "baby-einstein-neptunes-busy-bubbles-16656.jpg", "propia", "propia"),
    ]
    for pid, ean, nombre, dest_name, fuente, origen in extra:
        path = DEST / dest_name
        if not path.exists():
            print(f"  ✗ falta existente {path}")
            return 1
        listas.append({
            "producto_id": pid,
            "codigo_barras": ean,
            "nombre": nombre,
            "archivo": dest_name,
            "fuente": fuente,
            "origen": origen,
            "bytes": path.stat().st_size,
        })
        print(f"  · {pid} ya en repo {dest_name}")

    with MANIFEST.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(listas[0].keys()))
        w.writeheader()
        w.writerows(listas)

    ids = ", ".join(str(x["producto_id"]) for x in listas)
    values = []
    for it in listas:
        ean = sql_escape(it["codigo_barras"])
        url = sql_escape(f"{FOTO_BASE}/{it['archivo']}")
        values.append(
            f"  ({int(it['producto_id'])}, '{ean}', '{url}', 1, true, '{it['origen']}')"
        )

    lineas = [
        "-- Fotos lote 3 (2026-09-17): pendientes de siguen_sin_imagen_v2 +",
        "-- candidatos lote 2 que sí bajaron limpios.",
        "-- Packshots en public/catalogo-propia/. ORDEN: 1) merge/deploy  2) este SQL.",
        "-- origen SOLO admite rappi | distribuidor | propia | gs1 | otro.",
        "-- Idempotente: no duplica la misma URL.",
        "-- Portada: vacío O ya apuntaba a otro catalogo-propia de este lote.",
        "",
        "begin;",
        "",
        "create temporary table tmp_foto_lote3 (",
        "  producto_id bigint not null,",
        "  ean text,",
        "  url text not null,",
        "  posicion int not null,",
        "  es_principal boolean not null,",
        "  origen text not null",
        ") on commit drop;",
        "",
        "insert into tmp_foto_lote3 (producto_id, ean, url, posicion, es_principal, origen) values",
        ",\n".join(values) + ";",
        "",
        "-- portada",
        "update public.productos p",
        "set imagen_url = t.url,",
        "    imagen_mobile_url = t.url",
        "from tmp_foto_lote3 t",
        "where p.id = t.producto_id",
        "  and t.es_principal",
        "  and (",
        "    t.ean is null",
        "    or p.codigo_barras = t.ean",
        "    or p.codigo_barras = ltrim(t.ean, '0')",
        "    or (p.id = 243 and p.codigo_barras in ('7501001303454', '7501001303464'))",
        "    or (p.id = 1719 and p.codigo_barras in ('74451166561', '0074451166561', '074451166561'))",
        "  )",
        "  and (",
        "    p.imagen_url is null",
        "    or btrim(p.imagen_url) = ''",
        "    or p.imagen_url not like '%' || regexp_replace(t.url, '^.*/', '') || '%'",
        "  );",
        "",
        "-- nombre de mostrador: EAN 7501846504859 es Cera Black, no 'Pomada B'",
        "update public.productos",
        "set nombre = 'Xiomara Pomada Black / Cera Black 60 g',",
        "    marca = 'Xiomara',",
        "    presentacion = 'Tarro 60 g'",
        "where id = 1270",
        "  and codigo_barras = '7501846504859';",
        "",
        "insert into public.producto_imagenes",
        "  (producto_id, url, storage_path, posicion, es_principal, origen)",
        "select",
        "  t.producto_id,",
        "  t.url,",
        "  'catalogo-propia/' || regexp_replace(t.url, '^.*/', ''),",
        "  coalesce((select max(i.posicion) from public.producto_imagenes i",
        "            where i.producto_id = t.producto_id), 0) + t.posicion,",
        "  false,",
        "  t.origen",
        "from tmp_foto_lote3 t",
        "where not exists (",
        "  select 1 from public.producto_imagenes i",
        "  where i.producto_id = t.producto_id and i.url = t.url",
        ");",
        "",
        "update public.producto_imagenes i",
        "set es_principal = false",
        "where i.producto_id in (select producto_id from tmp_foto_lote3 where es_principal)",
        "  and i.es_principal",
        "  and i.url not in (select url from tmp_foto_lote3 where es_principal);",
        "",
        "update public.producto_imagenes i",
        "set es_principal = true",
        "where i.producto_id in (select producto_id from tmp_foto_lote3 where es_principal)",
        "  and i.url in (select url from tmp_foto_lote3 where es_principal)",
        "  and not i.es_principal;",
        "",
        "commit;",
        "",
        "select p.id, p.sku, p.codigo_barras, p.nombre, left(coalesce(p.imagen_url, ''), 90) as imagen",
        "from public.productos p",
        f"where p.id in ({ids})",
        "order by p.id;",
        "",
    ]
    SQL_OUT.write_text("\n".join(lineas), encoding="utf-8")
    print(f"SQL: {SQL_OUT}")
    print(f"manifest: {MANIFEST}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
