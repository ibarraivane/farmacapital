#!/usr/bin/env python3
"""Baja packshots YA confirmados (Farmatodo _01, FESA reales, extras)."""
from __future__ import annotations

import csv
import io
import re
import time
import unicodedata
import urllib.request
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
DEST = ROOT / "public" / "catalogo-propia"
MANIFEST = ROOT / "sql" / "generated" / "fotos_confirmadas_20260915.csv"
UA = "FarmaCapitalCatalog/1.0 (+https://www.farmacapital.mx)"

# Prefer _01 frente. No placeholders. No costado legal como principal.
FILAS = [
    # Farmatodo EAN exacto — portada _01
    ("1758", "7501349020122", "Clonixinato de lisina AMSA 5 amp 100 mg/2 mL",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7007507/7501349020122_01.jpg", "farmatodo", 1, True),
    ("1763", "7506022315038", "Navontec Jayor ondansetrón 3 amp 8 mg/4 mL",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7012799/7506022315038_01.jpg", "farmatodo", 1, True),
    ("1764", "7502009742798", "Laritol EX Maver loratadina/ambroxol solución 30 mL",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7007248/7502009742798_01.jpg", "farmatodo", 1, True),
    ("1765", "7502009747274", "Dolver Maver ibuprofeno 10 tab 600 mg",
     "https://curitekcom.b-cdn.net/wp-content/uploads/2023/09/DOLVER-IBUPROFENO.jpg", "curitek", 1, True),
    ("1770", "7501258203593", "Lonixer Serral clonixinato 10 tab 125 mg",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7007583/7501258203593_01.jpg", "farmatodo", 1, True),
    ("1772", "7501122960201", "Arretin tretinoína crema 0.05% 30 g",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7000091/7501122960201_01.jpg", "farmatodo", 1, True),
    ("1777", "7501299309278", "Tusigen NF ambroxol/dextrometorfano C/20 Liomont",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7006094/7501299309278_01.jpg", "farmatodo", 1, True),
    ("1778", "7501349020979", "Ketoprofeno 100 mg C/15 cápsulas AMSA",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7007596/7501349020979_01.jpg", "farmatodo", 1, True),
    ("1786", "7502009744884", "Odivitor atorvastatina 10 mg C/20 Maver",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7006817/7502009744884_01.jpg", "farmatodo", 1, True),
    ("1788", "7502009747328", "Lapriver itoprida 50 mg C/30 Maver",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7010080/7502009747328_01.jpg", "farmatodo", 1, True),
    ("1792", "7502216793439", "Sucralfato 1 g C/40 Ultra",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7006872/7502216793439_01.jpg", "farmatodo", 1, True),
    ("1793", "7502216796348", "Felodipino LP 5 mg C/20 Ultra",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7006738/7502216796348_01.jpg", "farmatodo", 1, True),
    ("1794", "7502216803893", "Ketorolaco 10 mg C/10 Avivia",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7007679/7502216803893_01.jpg", "farmatodo", 1, True),
    ("1811", "7503003738671", "Sepia itraconazol 33.3 mg / secnidazol 166.6 mg C/16 cápsulas",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7006601/7503003738671_01.jpg", "farmatodo", 1, True),
    ("1814", "7501258208550", "Valaciclovir Serral 500 mg C/10 tabletas",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7006610/7501258208550_01.jpg", "farmatodo", 1, True),
    ("1768", "7501563380415", "Tretinoína Randall crema 0.05% 20 g",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7013108/7501563380415_01.jpg", "farmatodo", 1, True),
    ("1795", "7502226291871", "Hidropharm clortalidona 50 mg C/30 Alpharma",
     "https://gruporfp.vteximg.com.br/arquivos/ids/7006832/7502226291871_01.jpg", "farmatodo", 1, True),
    # FESA EAN en path, foto distinta al placeholder
    ("1757", "7506335701214", "HT-Bloc Accord ondansetrón 1 amp 4 mg/2 mL",
     "https://www.farmaciasespecializadas.com/media/catalog/product/7/5/7506335701214_1_1.jpg", "fesa", 1, True),
    # Super D'Todo — Gerber EAN en ficha (ya validadas visualmente)
    ("1317", "7506475102476", "Gerber Etapa 2 durazno 100 g",
     "https://superdtodo.com/assets/uploads/c67e4046098df860a370dde43b6fc1da.png", "superdtodo", 1, True),
    ("1319", "7506475102469", "Gerber Etapa 2 mango 100 g",
     "https://superdtodo.com/assets/uploads/aef13bb45d575d9e7e8ad40407b8095a.png", "superdtodo", 1, True),
    # Sanorim / Phemedica / Curitek — Farmatodo no las tiene
    ("1766", "7502009748035", "Tinitrend Maver tretinoína crema 0.05% 30 g",
     "https://sanorim.mx/cdn/shop/files/tinitrend.jpg", "sanorim", 1, True),
    ("1774", "7501075711035", "Debisor sublingual 5 mg C/20 Novag",
     "https://phemedica.com.mx/wp-content/uploads/2024/12/imgi_78_DEBISOR-5-MG-C-20-768x768-1.png", "phemedica", 1, True),
    ("1813", "7502009749469", "Tribenósido 5% / lidocaína 2% crema rectal 30 g",
     "https://sanorim.mx/cdn/shop/files/Tribenosido.jpg", "sanorim", 1, True),
]


def slug(nombre: str, ean: str) -> str:
    s = unicodedata.normalize("NFKD", nombre)
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r"[^a-zA-Z0-9]+", "-", s).strip("-").lower()[:48].strip("-")
    return f"{s}-{ean}.jpg"


def bajar(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "image/*,*/*"})
    with urllib.request.urlopen(req, timeout=40) as r:
        return r.read()


def normalizar(blob: bytes) -> bytes:
    im = Image.open(io.BytesIO(blob))
    im.load()
    if min(im.size) < 200:
        raise ValueError(f"resolucion baja {im.size}")
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


def main() -> None:
    DEST.mkdir(parents=True, exist_ok=True)
    out = []
    for pid, ean, nombre, url, fuente, pos, principal in FILAS:
        etiqueta = f"{pid} {nombre[:40]}"
        try:
            blob = normalizar(bajar(url))
        except Exception as e:  # noqa: BLE001
            print(f"  ✗ {etiqueta} — {e}")
            continue
        archivo = slug(nombre, ean)
        (DEST / archivo).write_bytes(blob)
        out.append({
            "producto_id": pid,
            "codigo_barras": ean,
            "nombre": nombre,
            "archivo": archivo,
            "fuente": fuente,
            "posicion": pos,
            "es_principal": "SI" if principal else "NO",
            "url_origen": url,
            "bytes": len(blob),
        })
        print(f"  ✓ {etiqueta} — {archivo} ({len(blob)//1024} KB)")
        time.sleep(0.15)
    with MANIFEST.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(out[0].keys()))
        w.writeheader()
        w.writerows(out)
    print(f"\n{len(out)} fotos → {MANIFEST}")


if __name__ == "__main__":
    main()
