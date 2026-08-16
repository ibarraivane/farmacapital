#!/usr/bin/env python3
"""Reconstruye el orden original de fotos que AirDrop revolvió.

AirDrop no respeta el orden al copiar varias fotos, pero cada archivo conserva
en su metadata la hora exacta de captura. Ordenando por ahí se recupera la
secuencia en que se dispararon, sin importar cómo se hayan llamado al llegar.

Uso previsto: fotografiar cada producto en pares — primero la carátula, luego
el código de barras — y recuperar esos pares aquí.

    python3 scripts/ordenar_fotos_por_captura.py ~/Desktop/lote5
    python3 scripts/ordenar_fotos_por_captura.py ~/Desktop/lote5 --aplicar

Sin --aplicar solo muestra el orden propuesto; no toca nada.

Con --verificar usa el detector de códigos de barras para comprobar que la
segunda foto de cada par realmente trae código y la primera no. Así se detecta
si en algún punto se saltó una foto y el pareo se recorrió.
"""
import argparse
import os
import plistlib
import re
import shutil
import subprocess
import sys
from datetime import datetime

EXTENSIONES = {".jpg", ".jpeg", ".png", ".heic", ".heif", ".tif", ".tiff"}


def fecha_por_exif(ruta):
    """Hora de captura vía EXIF. Devuelve None si no aplica al formato."""
    try:
        from PIL import Image, ExifTags
    except ImportError:
        return None
    try:
        with Image.open(ruta) as img:
            exif = img.getexif()
            if not exif:
                return None
            tags = {ExifTags.TAGS.get(k, k): v for k, v in exif.items()}
            ifd = exif.get_ifd(0x8769) or {}
            tags.update({ExifTags.TAGS.get(k, k): v for k, v in ifd.items()})

            crudo = tags.get("DateTimeOriginal") or tags.get("DateTime")
            if not crudo:
                return None
            base = datetime.strptime(str(crudo), "%Y:%m:%d %H:%M:%S")
            # Los disparos seguidos caen en el mismo segundo; el subsegundo
            # es lo único que los desempata.
            sub = str(tags.get("SubsecTimeOriginal") or tags.get("SubsecTime") or "0")
            sub = re.sub(r"\D", "", sub)[:6].ljust(6, "0")
            return base.replace(microsecond=int(sub))
    except Exception:
        return None


def fecha_por_spotlight(ruta):
    """Hora de captura vía macOS. Cubre HEIC, que Pillow no lee sin plugin."""
    try:
        salida = subprocess.run(
            ["mdls", "-plist", "-", "-name", "kMDItemContentCreationDate", ruta],
            capture_output=True, timeout=10,
        ).stdout
        valor = plistlib.loads(salida).get("kMDItemContentCreationDate")
        if isinstance(valor, datetime):
            return valor.replace(tzinfo=None)
    except Exception:
        pass
    return None


def hora_captura(ruta):
    """(fecha, origen). Cae a la fecha de archivo solo si no queda opción."""
    f = fecha_por_exif(ruta)
    if f:
        return f, "exif"
    f = fecha_por_spotlight(ruta)
    if f:
        return f, "macos"
    return datetime.fromtimestamp(os.path.getmtime(ruta)), "archivo"


def tiene_codigo(ruta):
    """True si se decodifica un código de barras. None si no se pudo evaluar."""
    try:
        import cv2
    except ImportError:
        return None
    img = cv2.imread(ruta)
    if img is None:
        return None  # cv2 no abre HEIC
    if img.shape[0] > 1600:
        escala = 1600 / img.shape[0]
        img = cv2.resize(img, None, fx=escala, fy=escala, interpolation=cv2.INTER_AREA)
    detector = cv2.barcode.BarcodeDetector()
    for variante in (img,
                     cv2.rotate(img, cv2.ROTATE_90_CLOCKWISE),
                     cv2.rotate(img, cv2.ROTATE_180),
                     cv2.rotate(img, cv2.ROTATE_90_COUNTERCLOCKWISE)):
        try:
            ok, info, _, _ = detector.detectAndDecodeWithType(variante)
            if ok and any(str(c).strip() for c in info):
                return True
        except Exception:
            continue
    return False


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("carpeta", help="carpeta con las fotos recibidas")
    ap.add_argument("--salida", help="destino de las copias (default: <carpeta>/ordenadas)")
    ap.add_argument("--aplicar", action="store_true", help="copiar; sin esto solo muestra")
    ap.add_argument("--verificar", action="store_true",
                    help="revisar con el lector de códigos que los pares estén bien")
    args = ap.parse_args()

    if not os.path.isdir(args.carpeta):
        sys.exit(f"No existe la carpeta: {args.carpeta}")

    fotos = [os.path.join(args.carpeta, n) for n in os.listdir(args.carpeta)
             if os.path.splitext(n)[1].lower() in EXTENSIONES]
    if not fotos:
        sys.exit(f"No hay imágenes en {args.carpeta}")

    registros = []
    for ruta in fotos:
        fecha, origen = hora_captura(ruta)
        registros.append({"ruta": ruta, "fecha": fecha, "origen": origen})
    registros.sort(key=lambda r: r["fecha"])

    origenes = {}
    for r in registros:
        origenes[r["origen"]] = origenes.get(r["origen"], 0) + 1
    print(f"{len(registros)} fotos · fuente de la hora: "
          + ", ".join(f"{k}={v}" for k, v in sorted(origenes.items())))
    if origenes.get("archivo"):
        print("  ⚠️  Algunas no traen hora de captura y se ordenaron por fecha de")
        print("      archivo, que AirDrop sí altera. Revísalas a mano.")
    print()

    salida = args.salida or os.path.join(args.carpeta, "ordenadas")
    if args.aplicar:
        os.makedirs(salida, exist_ok=True)

    problemas = []
    for i, r in enumerate(registros):
        par, papel = i // 2 + 1, "portada" if i % 2 == 0 else "codigo"
        ext = os.path.splitext(r["ruta"])[1].lower()
        r["nombre"] = f"{par:04d}_{'a' if i % 2 == 0 else 'b'}_{papel}{ext}"

        nota = ""
        if args.verificar:
            hay = tiene_codigo(r["ruta"])
            if hay is None:
                nota = "  (no evaluable)"
            elif hay != (papel == "codigo"):
                nota = "  ⚠️  NO COINCIDE"
                problemas.append(r)

        print(f"  {r['fecha']:%H:%M:%S.%f}  {os.path.basename(r['ruta']):<28} "
              f"→ {r['nombre']}{nota}")

        if args.aplicar:
            shutil.copy2(r["ruta"], os.path.join(salida, r["nombre"]))

    print()
    if len(registros) % 2:
        print("⚠️  Número impar de fotos: falta una del último par.")
    if problemas:
        print(f"⚠️  {len(problemas)} foto(s) no cuadran con su papel. Suele significar")
        print("    que se saltó una toma y de ahí en adelante el pareo se recorrió.")
    if args.aplicar:
        print(f"✅ Copiadas a {salida} (los originales no se tocaron)")
    else:
        print("Nada se copió. Repite con --aplicar cuando el orden se vea bien.")


if __name__ == "__main__":
    main()
