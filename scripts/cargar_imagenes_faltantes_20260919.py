#!/usr/bin/env python3
"""Normaliza packshots del lote 19-sep-2026 (ligas del dueño + fotos feas de vitrina).

Uso:
    python3 scripts/cargar_imagenes_faltantes_20260919.py
"""
from __future__ import annotations

import csv
import hashlib
import io
import re
import sys
import unicodedata
from pathlib import Path

from PIL import Image, ImageEnhance, ImageOps

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
from lib.imagen_competencia import (  # noqa: E402
    es_placeholder_imagen_competencia,
)

DEST = ROOT / "public" / "catalogo-propia"
SQL_OUT = ROOT / "sql" / "patch_fotos_faltantes_urls_20260919.sql"
LEERME = ROOT / "sql" / "LEERME_fotos_faltantes_urls_20260919.md"
MANIFEST = ROOT / "sql" / "generated" / "carga_imagenes_faltantes_20260919_manifest.csv"
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"
MIN_LADO = 200
SRC = Path("/tmp/fotos-lote-user")

# src, ean, sku, nombre, fuente, origen_sql, extra_eans, name_ilike, name_not_ilike, modo
FILAS = [
    (
        ROOT / "public/catalogo-propia/dibar-azul-500ml.jpg",
        "7501868901124",
        "FC-68901124",
        "Alcohol etílico Dibar azul 71.5° 500 ml",
        "propia-recortada",
        "propia",
        (),
        "",
        "",
        "trim_black",
    ),
    (
        SRC / "levoflox-amsa-nadro.jpg",
        "7501349021419",
        "FC-C721E8D7",
        "Levofloxacino AMSA 500 mg C/7 tabletas",
        "nadro",
        "distribuidor",
        (),
        "",
        "",
        "brighten",
    ),
    (
        SRC / "buscapina-fem-ft.jpg",
        "7501165011656",
        "FC-65011656",
        "Buscapina Fem hioscina/ibuprofeno 20/400 mg C/10",
        "farmatodo",
        "distribuidor",
        (),
        "%buscapina%fem%",
        "",
        "normal",
    ),
    (
        SRC / "cetilver-ml-F.webp",
        "7502009748448",
        "EQ-MAV392",
        "Cetilver pirfenidona gel 8% tubo 10 g",
        "mercadolibre",
        "distribuidor",
        (),
        "%cetilver%",
        "",
        "normal",
    ),
    (
        SRC / "secret-lavanda-ched.jpg",
        "7500435129367",
        "FC-35129367",
        "Secret gel invisible lavanda 45 g",
        "chedraui",
        "distribuidor",
        (),
        "%secret%lavanda%",
        "",
        "normal",
    ),
    (
        SRC / "desrotan-nadro.jpg",
        "7502227875568",
        "FC-B3B8F9BB",
        "Desrotan fexofenadina 180 mg C/10",
        "nadro",
        "distribuidor",
        (),
        "%desrotan%",
        "",
        "normal",
    ),
    (
        SRC / "flor-aire-almendras-125.jpg",
        "",
        "",
        "Aceite de almendras dulces Flor de Aire 125 ml",
        "flordeaire",
        "distribuidor",
        (),
        "%almendras dulces%125%",
        "",
        "normal",
    ),
    (
        SRC / "nuvel-aceite-bebe-250-ched.jpg",
        "7501082780246",
        "",
        "Aceite para bebé Nuvel 250 ml",
        "chedraui",
        "distribuidor",
        ("750108278024",),
        "%aceite%nuvel%250%",
        "",
        "normal",
    ),
    (
        SRC / "advil-200-10caps-ft.jpg",
        "7501108763475",
        "",
        "Advil ibuprofeno 200 mg C/10 cápsulas",
        "farmatodo",
        "distribuidor",
        (),
        "%advil%200%10%capsul%",
        "",
        "normal",
    ),
    (
        SRC / "ampigrin-pfc-caps-plm.webp",
        "",
        "",
        "Ampigrin PFC cápsulas C/24",
        "plm",
        "distribuidor",
        (),
        "%ampigrin pfc%caps%",
        "",
        "normal",
    ),
    (
        SRC / "betahistina-amsa-30-ched.jpg",
        "7501349029965",
        "",
        "Betahistina AMSA 24 mg C/30 tabletas",
        "chedraui",
        "distribuidor",
        ("750134902996",),
        "%betahistina%amsa%24%",
        "",
        "normal",
    ),
    (
        SRC / "broxtorfan-adulto-sufarmed.jpg",
        "7501573907992",
        "",
        "Broxtorfan adulto ambroxol/dextrometorfano jarabe 120 ml",
        "sufarmed",
        "distribuidor",
        (),
        "%broxtorfan%adult%",
        "",
        "normal",
    ),
    (
        SRC / "calaffler.jpg",
        "7502211784180",
        "FC-11784180",
        "Calaffler diclofenaco gotas 15 mg/ml Loeffler",
        "ifarma",
        "distribuidor",
        (),
        "%calaffler%",
        "",
        "normal",
    ),
    (
        SRC / "canula-nasal-ped-promexsa.webp",
        "",
        "",
        "Cánula nasal pediátrica 2 mm x 1.80 m Sensi Medical",
        "promexsa",
        "distribuidor",
        (),
        "%nula nasal%ped%",
        "",
        "normal",
    ),
    (
        SRC / "carnitina-ml-2X.webp",
        "",
        "",
        "Carnitina fibra y complejo B Naturex 30 cápsulas 560 mg",
        "mercadolibre",
        "distribuidor",
        (),
        "%carnitina%naturex%",
        "",
        "crop_bottle",
    ),
    (
        SRC / "teatrical-lanolina-400g.jpg",
        "",
        "",
        "Teatrical crema suavizante con lanolina tarro 400 g",
        "mercadolibre",
        "distribuidor",
        (),
        "%teatrical%lanolin%400%",
        "%rosas%",
        "normal",
    ),
    (
        SRC / "teatrosas-2X.webp",
        "",
        "",
        "Teatrical crema suavizante con lanolina y rosas tarro 400 g",
        "mercadolibre",
        "distribuidor",
        (),
        "%teatrical%rosas%400%",
        "",
        "normal",
    ),
]


def slug(nombre: str, ean: str) -> str:
    s = unicodedata.normalize("NFKD", nombre or "producto")
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r"[^a-zA-Z0-9]+", "-", s).strip("-").lower()[:52].strip("-")
    return f"{s}-{ean}.jpg" if ean else f"{s}.jpg"


def sql_escape(s: str) -> str:
    return (s or "").replace("'", "''")


def abrir(blob: bytes) -> Image.Image:
    if es_placeholder_imagen_competencia(blob):
        raise ValueError("placeholder Fahorro")
    im = Image.open(io.BytesIO(blob))
    im.load()
    if im.mode in ("RGBA", "LA", "P"):
        im = im.convert("RGBA")
        fondo = Image.new("RGB", im.size, (255, 255, 255))
        fondo.paste(im, mask=im.split()[-1] if im.mode == "RGBA" else None)
        return fondo
    return im.convert("RGB")


def recortar_bordes_oscuros(im: Image.Image, umbral: int = 40) -> Image.Image:
    """Quita columnas/filas casi negras (letterbox del alcohol Dibar)."""
    px = im.load()
    w, h = im.size

    def col_oscura(x: int) -> bool:
        vals = [px[x, y][0] + px[x, y][1] + px[x, y][2] for y in range(0, h, max(1, h // 80))]
        return (sum(vals) / len(vals)) < umbral * 3

    def fila_oscura(y: int) -> bool:
        vals = [px[x, y][0] + px[x, y][1] + px[x, y][2] for x in range(0, w, max(1, w // 80))]
        return (sum(vals) / len(vals)) < umbral * 3

    left = 0
    while left < w // 4 and col_oscura(left):
        left += 1
    right = w - 1
    while right > w * 3 // 4 and col_oscura(right):
        right -= 1
    top = 0
    while top < h // 6 and fila_oscura(top):
        top += 1
    bottom = h - 1
    while bottom > h * 5 // 6 and fila_oscura(bottom):
        bottom -= 1
    if right - left < 80 or bottom - top < 80:
        return im
    return im.crop((left, top, right + 1, bottom + 1))


def recortar_botella_carnitina(im: Image.Image) -> Image.Image:
    """Saca el frasco del montaje con logos Farmadealta / pesas."""
    w, h = im.size
    left = int(w * 0.36)
    right = int(w * 0.64)
    top = int(h * 0.16)
    bottom = int(h * 0.90)
    crop = im.crop((left, top, right, bottom))
    px = crop.load()
    cw, ch = crop.size
    for y in range(ch):
        for x in range(cw):
            r, g, b = px[x, y]
            # Fondo de gimnasio / mesa: claros o grises cálidos, no el frasco ni la etiqueta.
            if r > 170 and g > 160 and b > 150:
                px[x, y] = (255, 255, 255)
            elif abs(r - g) < 18 and abs(g - b) < 18 and r > 140:
                px[x, y] = (255, 255, 255)
    return ImageOps.expand(crop, border=10, fill=(255, 255, 255))


def a_cuadrado(im: Image.Image, pad_frac: float = 0.08) -> Image.Image:
    if pad_frac:
        extra = int(max(im.size) * pad_frac)
        im = ImageOps.expand(im, border=extra, fill=(255, 255, 255))
    lado = max(im.size)
    lienzo = Image.new("RGB", (lado, lado), (255, 255, 255))
    lienzo.paste(im, ((lado - im.size[0]) // 2, (lado - im.size[1]) // 2))
    if lado > 1200:
        lienzo = lienzo.resize((1200, 1200), Image.LANCZOS)
    return lienzo


def normalizar(blob: bytes, modo: str) -> bytes:
    im = abrir(blob)
    if min(im.size) < MIN_LADO:
        raise ValueError(f"resolucion baja {im.size[0]}x{im.size[1]}")
    if modo == "trim_black":
        im = recortar_bordes_oscuros(im)
        im = a_cuadrado(im, pad_frac=0.14)
    elif modo == "crop_bottle":
        im = recortar_botella_carnitina(im)
        im = a_cuadrado(im, pad_frac=0.12)
    elif modo == "brighten":
        im = ImageEnhance.Brightness(im).enhance(1.12)
        im = ImageEnhance.Contrast(im).enhance(1.04)
        im = a_cuadrado(im, pad_frac=0.06)
    else:
        im = a_cuadrado(im, pad_frac=0.06)
    buf = io.BytesIO()
    im.save(buf, "JPEG", quality=88, optimize=True)
    out = buf.getvalue()
    if es_placeholder_imagen_competencia(out):
        raise ValueError("placeholder Fahorro tras normalizar")
    return out


def main() -> int:
    DEST.mkdir(parents=True, exist_ok=True)
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    listas = []
    for src, ean, sku, nombre, fuente, origen, extra_eans, name_ilike, name_not, modo in FILAS:
        path = Path(src)
        if not path.exists():
            print(f"  ✗ falta {path}")
            return 1
        try:
            jpg = normalizar(path.read_bytes(), modo)
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
            "extra_eans": "|".join(extra_eans),
            "name_ilike": name_ilike,
            "name_not_ilike": name_not,
            "bytes": len(jpg),
            "md5": hashlib.md5(jpg).hexdigest(),
        })
        print(f"  ✓ {dest_name} ({len(jpg)//1024} KB) {fuente}")

    with MANIFEST.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(listas[0].keys()))
        w.writeheader()
        w.writerows(listas)

    # tmp_foto: una fila por (ean|sku|ilike) para no depender de ids fijos
    value_rows = []
    for it in listas:
        url = sql_escape(f"{FOTO_BASE}/{it['archivo']}")
        origen = it["origen"]
        eans = [it["ean"]] if it["ean"] else []
        eans.extend([e for e in it["extra_eans"].split("|") if e])
        if not eans:
            eans = [""]
        sku = sql_escape(it["sku"])
        ilike = sql_escape(it["name_ilike"])
        notlike = sql_escape(it["name_not_ilike"])
        for e in eans:
            value_rows.append(
                f"  ('{sql_escape(e)}', '{sku}', '{ilike}', '{notlike}', '{url}', '{origen}')"
            )

    eans_sql = ", ".join(
        f"'{sql_escape(e)}'"
        for it in listas
        for e in ([it["ean"]] if it["ean"] else []) + [x for x in it["extra_eans"].split("|") if x]
    )
    skus_sql = ", ".join(f"'{sql_escape(it['sku'])}'" for it in listas if it["sku"])

    sql = f"""-- Fotos faltantes / feas (19-sep-2026) — ligas que pasó el dueño + vitrina.
-- Packshots en public/catalogo-propia/. ORDEN: 1) merge/deploy  2) este SQL.
-- origen SOLO admite rappi | distribuidor | propia | gs1 | otro.
-- Idempotente: no duplica la misma URL. Reemplaza portada vacía, Fahorro
-- o una portada distinta de este lote (alcohol cortado, Cetilver con marca
-- de agua, Buscapina de espaldas, Desrotan/Secret de celular).
-- Match por EAN, SKU o nombre (sin ids fijos).

begin;

create temporary table tmp_foto_fal (
  ean text,
  sku text,
  name_ilike text,
  name_not_ilike text,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_fal (ean, sku, name_ilike, name_not_ilike, url, origen) values
{',\n'.join(value_rows)};

create temporary table tmp_foto_hit (
  producto_id bigint primary key,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_hit (producto_id, url, origen)
select distinct on (p.id)
  p.id,
  t.url,
  t.origen
from public.productos p
join tmp_foto_fal t
  on (
    (t.ean <> '' and (p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0')))
    or (t.sku <> '' and p.sku = t.sku)
    or (
      t.name_ilike <> ''
      and p.nombre ilike t.name_ilike
      and (t.name_not_ilike = '' or p.nombre not ilike t.name_not_ilike)
    )
  )
order by p.id, t.url;

update public.productos p
set imagen_url = h.url,
    imagen_mobile_url = h.url
from tmp_foto_hit h
where p.id = h.producto_id
  and (
    p.imagen_url is null
    or btrim(p.imagen_url) = ''
    or p.imagen_url ilike '%fahorro%'
    or p.imagen_url not like '%' || regexp_replace(h.url, '^.*/', '') || '%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  h.producto_id,
  h.url,
  'catalogo-propia/' || regexp_replace(h.url, '^.*/', ''),
  coalesce((select max(i.posicion) from public.producto_imagenes i
            where i.producto_id = h.producto_id), 0) + 1,
  false,
  h.origen
from tmp_foto_hit h
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = h.producto_id and i.url = h.url
);

update public.producto_imagenes i
set es_principal = false
from tmp_foto_hit h
where i.producto_id = h.producto_id
  and i.es_principal
  and i.url <> h.url;

update public.producto_imagenes i
set es_principal = true
from tmp_foto_hit h
where i.producto_id = h.producto_id
  and i.url = h.url
  and not i.es_principal;

commit;

select p.id, p.sku, p.codigo_barras, p.nombre, left(coalesce(p.imagen_url, ''), 110) as imagen
from public.productos p
where p.codigo_barras in ({eans_sql})
   or p.sku in ({skus_sql})
   or p.nombre ilike '%cetilver%'
   or p.nombre ilike '%desrotan%'
   or p.nombre ilike '%buscapina%fem%'
   or p.nombre ilike '%calaffler%'
   or p.nombre ilike '%broxtorfan%'
   or p.nombre ilike '%teatrical%400%'
   or p.nombre ilike '%nula nasal%ped%'
   or p.nombre ilike '%carnitina%naturex%'
   or p.nombre ilike '%almendras dulces%'
   or p.nombre ilike '%aceite%nuvel%'
   or p.nombre ilike '%ampigrin pfc%'
   or p.nombre ilike '%betahistina%amsa%'
order by p.nombre;
"""
    SQL_OUT.write_text(sql, encoding="utf-8")

    filas_md = "\n".join(
        f"| {it['nombre']} | `{it['ean'] or '—'} ` | `{it['sku'] or '—'} ` | `{it['archivo']}` | {it['fuente']} |"
        for it in listas
    )
    LEERME.write_text(
        f"""# Fotos faltantes / feas 19-sep-2026

Ligas del dueño (Flor de Aire, Chedraui, Guadalajara, PLM, Sufarmed, iFarma, Promexsa, Mercado Libre) y las tarjetas de vitrina que salían cortadas, oscuras, de espaldas o con marca de agua.

## Qué hacer

1. Esperar el deploy de este PR (`public/catalogo-propia/…` en farmacapital.mx).
2. Pegar **todo** `sql/patch_fotos_faltantes_urls_20260919.sql` en Supabase → Run.
3. Recargar la tienda.

## Lote

{filas_md}

## Notas

- **Alcohol Dibar azul 500 ml:** se recortaron las franjas negras laterales y se dejó más aire blanco para que la botella no se vea cortada en la tarjeta.
- **Levofloxacino AMSA 500 mg C/7:** packshot Nadro de la caja blanca (la foto de celular estaba oscura). No se usa la caja verde de Farmatodo.
- **Buscapina Fem:** frente Farmatodo. Ya no sale el dorso con código de barras.
- **Cetilver:** caja + tubo de Mercado Libre, sin la marca de agua Gendiar.
- **Secret lavanda 45 g:** packshot Chedraui (misma liga/EAN 7500435129367). Sustituye la foto de celular.
- **Desrotan 180 mg C/10:** frente Nadro. No se usa la segunda foto de Nadro (es Frewer).
- **Broxtorfan de la liga Sufarmed es ADULTO 120 ml**, no el Broxtorfan infantil `EQ-BIO188`. El SQL solo pega si el nombre dice adulto o el EAN de la caja `7501573907992`.
- **Ampigrin PFC de PLM es cápsulas C/24**, no el jarabe infantil `EQ-COL213`.
- **Carnitina Naturex:** se recortó el frasco del montaje de Mercado Libre (quitamos logos Farmadealta / pesas) y se puso fondo blanco.
- **Advil 10 cápsulas:** Farmatodo (la de Guadalajara traía marca de agua de la cadena).
- Varias fichas (Nuvel, Betahistina, Teatrical 400 g, cánula, almendras) no tenían EAN/SKU fijo en el repo: el SQL las busca por código o por nombre.

No pisa foto si el producto no matchea EAN/SKU/nombre. No toca stock ni precio.
""",
        encoding="utf-8",
    )
    print(f"\nSQL {SQL_OUT}")
    print(f"LEERME {LEERME}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
