#!/usr/bin/env python3
"""Baja los packshots del lote 2026-09-15 a public/catalogo-propia/ y
escribe sql/patch_fotos_lote_20260915.sql.

Patrón del repo: la URL ajena (ifarma, Mercurio, etc.) se copia al CDN propio.
El SQL se pega en Supabase DESPUÉS del deploy de Vercel.

El script original subía al bucket `productos`. Aquí no hace falta
SUPABASE_SERVICE_ROLE_KEY: las fotos van al repo y el SQL apunta a
https://www.farmacapital.mx/catalogo-propia/…

Uso:
    python3 scripts/cargar_imagenes_lote_20260915.py --dry-run
    python3 scripts/cargar_imagenes_lote_20260915.py
    python3 scripts/cargar_imagenes_lote_20260915.py --solo-ean-exacto
"""
from __future__ import annotations

import argparse
import csv
import io
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
from lib.imagen_competencia import (  # noqa: E402
    es_placeholder_imagen_competencia,
    es_url_imagen_competencia,
    mensaje_rechazo_imagen_competencia,
)

CSV_IN = ROOT / "sql" / "generated" / "candidatos_imagenes_20260915.csv"
DEST = ROOT / "public" / "catalogo-propia"
SQL_OUT = ROOT / "sql" / "patch_fotos_lote_20260915.sql"
MANIFEST = ROOT / "sql" / "generated" / "carga_imagenes_lote_20260915_manifest.csv"
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"

UA = "FarmaCapitalCatalog/1.0 (+catalogo de imagenes)"
MIN_BYTES = 3_000
MIN_LADO = 200
TIPOS_OK = {"image/jpeg", "image/png", "image/webp", "image/jpg"}


def slug(nombre: str, ean: str, pos: int) -> str:
    s = unicodedata.normalize("NFKD", nombre or "producto")
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r"[^a-zA-Z0-9]+", "-", s).strip("-").lower()[:48].strip("-")
    base = f"{s}-{ean}" if ean else s
    if pos > 1:
        return f"{base}-g{pos}"
    return base


def bajar(url: str) -> tuple[bytes | None, str, str]:
    if es_url_imagen_competencia(url):
        return None, "", mensaje_rechazo_imagen_competencia()
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "image/*,*/*"})
    try:
        with urllib.request.urlopen(req, timeout=90) as r:
            mime = (r.headers.get("Content-Type") or "").split(";")[0].strip().lower()
            blob = r.read()
    except Exception as e:  # noqa: BLE001
        return None, "", f"no se pudo bajar: {type(e).__name__}"
    if mime and mime not in TIPOS_OK and not mime.startswith("image/"):
        return None, mime, f"tipo inesperado ({mime or 'sin content-type'})"
    if len(blob) < MIN_BYTES:
        return None, mime, f"demasiado chica ({len(blob)} bytes), probable placeholder"
    if es_placeholder_imagen_competencia(blob):
        return None, mime, mensaje_rechazo_imagen_competencia()
    if not mime:
        if blob.startswith(b"\x89PNG"):
            mime = "image/png"
        elif blob.startswith(b"\xff\xd8\xff"):
            mime = "image/jpeg"
        elif blob[:4] == b"RIFF" and blob[8:12] == b"WEBP":
            mime = "image/webp"
        else:
            return None, "", "sin content-type y firma desconocida"
    return blob, mime, ""


def normalizar_jpg(blob: bytes) -> bytes:
    from PIL import Image  # type: ignore

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


def origen_sql(fuente: str) -> str:
    f = (fuente or "").lower()
    if "propia" in f:
        return "propia"
    return "distribuidor"


def escribir_sql(filas: list[dict]) -> None:
    lineas = [
        "-- Fotos lote 2026-09-15 (ifarma / Droguería Mercurio / Sanorim / Curitek /",
        "-- Phemedica / Farmasuper / Super D'Todo). Packshots copiados a",
        "-- public/catalogo-propia/. ORDEN: 1) merge/deploy  2) pegar este SQL.",
        "-- Galería: inserta es_principal=false y luego rota la principal",
        "-- (evita ux_producto_imagenes_una_principal).",
        "-- origen SOLO admite rappi | distribuidor | propia | gs1 | otro.",
        "-- Idempotente: no pisa una foto distinta; no duplica la misma URL.",
        "begin;",
        "",
        "create temporary table tmp_foto_lote (",
        "  producto_id bigint not null,",
        "  ean text,",
        "  url text not null,",
        "  posicion int not null,",
        "  es_principal boolean not null,",
        "  origen text not null",
        ") on commit drop;",
        "",
        "insert into tmp_foto_lote (producto_id, ean, url, posicion, es_principal, origen) values",
    ]
    values = []
    for it in filas:
        ean = sql_escape(it["codigo_barras"] or "")
        ean_sql = f"'{ean}'" if ean else "null"
        url = sql_escape(f"{FOTO_BASE}/{it['archivo']}")
        principal = "true" if it["es_principal"] == "SI" else "false"
        values.append(
            f"  ({int(it['producto_id'])}, {ean_sql}, '{url}', "
            f"{int(it['posicion'])}, {principal}, '{origen_sql(it['fuente'])}')"
        )
    lineas.append(",\n".join(values) + ";")
    lineas += [
        "",
        "-- portada: solo si imagen_url está vacío",
        "update public.productos p",
        "set imagen_url = t.url,",
        "    imagen_mobile_url = t.url",
        "from tmp_foto_lote t",
        "where p.id = t.producto_id",
        "  and t.es_principal",
        "  and (t.ean is null or p.codigo_barras = t.ean or p.codigo_barras = ltrim(t.ean, '0'))",
        "  and (p.imagen_url is null or btrim(p.imagen_url) = '');",
        "",
        "-- galería: insertar como NO principal",
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
        "from tmp_foto_lote t",
        "where not exists (",
        "  select 1 from public.producto_imagenes i",
        "  where i.producto_id = t.producto_id and i.url = t.url",
        ");",
        "",
        "-- rotar principal a la portada de este lote",
        "update public.producto_imagenes i",
        "set es_principal = false",
        "where i.producto_id in (select producto_id from tmp_foto_lote where es_principal)",
        "  and i.es_principal",
        "  and i.url not in (select url from tmp_foto_lote where es_principal);",
        "",
        "update public.producto_imagenes i",
        "set es_principal = true",
        "where i.producto_id in (select producto_id from tmp_foto_lote where es_principal)",
        "  and i.url in (select url from tmp_foto_lote where es_principal)",
        "  and not i.es_principal;",
        "",
        "commit;",
        "",
    ]
    SQL_OUT.write_text("\n".join(lineas), encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true", help="baja y valida; no escribe SQL")
    ap.add_argument(
        "--solo-ean-exacto",
        action="store_true",
        help="omite MARCA_OFICIAL_NOMBRE (Mercurio, sin EAN en la ficha)",
    )
    args = ap.parse_args()

    if not CSV_IN.exists():
        print(f"falta {CSV_IN}", file=sys.stderr)
        return 1

    DEST.mkdir(parents=True, exist_ok=True)

    filas = list(csv.DictReader(CSV_IN.open(encoding="utf-8")))
    if args.solo_ean_exacto:
        filas = [f for f in filas if f["confianza"] != "MARCA_OFICIAL_NOMBRE"]

    listas, descartadas = [], []
    for f in filas:
        pid, pos = f["producto_id"], int(f["posicion"])
        etiqueta = f"{pid} pos{pos} · {f['nombre'][:45]}"
        blob, mime, motivo = bajar(f["url_origen"])
        if blob is None:
            descartadas.append({**f, "motivo_descarte": motivo})
            print(f"  ✗ {etiqueta} — {motivo}")
            continue
        try:
            blob = normalizar_jpg(blob)
        except Exception as e:  # noqa: BLE001
            descartadas.append({**f, "motivo_descarte": str(e)})
            print(f"  ✗ {etiqueta} — {e}")
            continue
        nombre_archivo = slug(f["nombre"], f["codigo_barras"], pos) + ".jpg"
        (DEST / nombre_archivo).write_bytes(blob)
        listas.append({**f, "archivo": nombre_archivo, "bytes": len(blob)})
        print(f"  ✓ {etiqueta} — {nombre_archivo} ({len(blob)//1024} KB)")
        time.sleep(0.2)

    print(f"\ndescargadas {len(listas)} · descartadas {len(descartadas)}")
    if descartadas:
        rep = DEST / "_descartadas_lote_20260915.csv"
        with rep.open("w", newline="", encoding="utf-8") as fh:
            w = csv.DictWriter(fh, fieldnames=list(descartadas[0].keys()))
            w.writeheader()
            w.writerows(descartadas)
        print(f"detalle de descartes: {rep}")

    if listas:
        with MANIFEST.open("w", newline="", encoding="utf-8") as fh:
            w = csv.DictWriter(
                fh,
                fieldnames=[
                    "producto_id",
                    "codigo_barras",
                    "nombre",
                    "posicion",
                    "es_principal",
                    "archivo",
                    "fuente",
                    "confianza",
                    "bytes",
                ],
            )
            w.writeheader()
            w.writerows(listas)

    if args.dry_run:
        print("--dry-run: no se escribió SQL.")
        return 0 if listas else 1

    if not listas:
        print("nada que escribir", file=sys.stderr)
        return 1

    escribir_sql(listas)
    print(f"SQL: {SQL_OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
