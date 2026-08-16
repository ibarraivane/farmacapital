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
from datetime import datetime, timezone

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
            # Las fechas de un plist vienen en UTC. Hay que pasarlas a hora
            # local o quedarían 6 h adelantadas frente a las de EXIF, y al
            # mezclar ambas fuentes el orden saldría revuelto.
            return valor.replace(tzinfo=timezone.utc).astimezone().replace(tzinfo=None)
    except Exception:
        pass
    return None


def numero_iphone(ruta):
    """El #### de IMG_####.JPG. El iPhone los asigna en orden de captura, así
    que sirve de respaldo cuando la foto viene sin EXIF."""
    m = re.match(r"IMG_(\d+)\.", os.path.basename(ruta), re.I)
    return int(m.group(1)) if m else None


def hora_captura(ruta):
    """(fecha, origen). Cae a la fecha de archivo solo si no queda opción."""
    f = fecha_por_exif(ruta)
    if f:
        return f, "exif"
    f = fecha_por_spotlight(ruta)
    if f:
        return f, "macos"
    return datetime.fromtimestamp(os.path.getmtime(ruta)), "archivo"


def clave_orden(ruta):
    """(grupo, valor, etiqueta) para ordenar.

    Dos señales distintas del mismo orden, según lo que traiga la foto:
    la hora de captura del EXIF, o el consecutivo del nombre del iPhone.
    No son comparables entre sí, por eso viajan en grupos separados: mezclar
    fotos de las dos clases en una misma corrida daría un orden sin sentido.
    """
    f = fecha_por_exif(ruta)
    if f:
        return "exif", f, f"{f:%H:%M:%S.%f}"

    n = numero_iphone(ruta)
    if n is not None:
        return "nombre", n, f"IMG_{n}"

    f = fecha_por_spotlight(ruta)
    if f:
        return "macos", f, f"{f:%H:%M:%S}"

    f = datetime.fromtimestamp(os.path.getmtime(ruta))
    return "archivo", f, f"{f:%H:%M:%S}"


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
    ap.add_argument("--grupo", choices=["exif", "nombre", "macos", "archivo"],
                    help="procesar solo las fotos que se ordenan por esta vía")
    ap.add_argument("--sesion", type=int, metavar="N",
                    help="procesar solo la sesión N (sin esto, las lista)")
    args = ap.parse_args()

    if not os.path.isdir(args.carpeta):
        sys.exit(f"No existe la carpeta: {args.carpeta}")

    fotos = [os.path.join(args.carpeta, n) for n in os.listdir(args.carpeta)
             if os.path.splitext(n)[1].lower() in EXTENSIONES]
    if not fotos:
        sys.exit(f"No hay imágenes en {args.carpeta}")

    registros = []
    for ruta in fotos:
        grupo, valor, etiqueta = clave_orden(ruta)
        registros.append({"ruta": ruta, "grupo": grupo, "valor": valor,
                          "etiqueta": etiqueta})

    grupos = {}
    for r in registros:
        grupos.setdefault(r["grupo"], []).append(r)

    NOMBRES = {"exif": "hora de captura (EXIF)",
               "nombre": "consecutivo IMG_#### del iPhone",
               "macos": "fecha de macOS",
               "archivo": "fecha de archivo"}
    print(f"{len(registros)} fotos en {args.carpeta}")
    for g, rs in sorted(grupos.items(), key=lambda kv: -len(kv[1])):
        print(f"  {len(rs):4d} por {NOMBRES[g]}")

    if len(grupos) > 1:
        print()
        print("⚠️  Hay fotos que conservan el orden por vías distintas, y no son")
        print("    comparables entre sí: son lotes separados. Procesa uno a la vez")
        print("    con --grupo, o muévelos a carpetas distintas.")
        if not args.grupo:
            print()
            print("    Ejemplo:  --grupo " + max(grupos, key=lambda g: len(grupos[g])))
            sys.exit(1)

    if args.grupo:
        if args.grupo not in grupos:
            sys.exit(f"No hay fotos del grupo '{args.grupo}'. Hay: {', '.join(grupos)}")
        registros = grupos[args.grupo]
        print(f"\n→ Procesando solo el grupo '{args.grupo}' ({len(registros)} fotos)")

    if any(r["grupo"] == "archivo" for r in registros):
        print("  ⚠️  Algunas se ordenaron por fecha de archivo, que AirDrop sí")
        print("      altera. Revísalas a mano.")
    registros.sort(key=lambda r: r["valor"])

    # Una carpeta de Descargas acumula fotos de muchos días. Un salto grande
    # entre dos fotos consecutivas marca dónde termina una sesión y empieza otra.
    sesiones, actual = [], [registros[0]]
    for previo, r in zip(registros, registros[1:]):
        if r["grupo"] == "nombre":
            salto = r["valor"] - previo["valor"] > 20
        else:
            salto = (r["valor"] - previo["valor"]).total_seconds() > 1800
        if salto:
            sesiones.append(actual)
            actual = []
        actual.append(r)
    sesiones.append(actual)

    if len(sesiones) > 1 and not args.sesion:
        print(f"\n{len(sesiones)} sesiones detectadas (fotos tomadas de corrido):\n")
        for i, s in enumerate(sesiones, 1):
            print(f"  {i:2d}. {len(s):4d} fotos   {s[0]['etiqueta']} → {s[-1]['etiqueta']}"
                  f"{'' if len(s) % 2 == 0 else '   ⚠️ impar'}")
        print("\nElige una con --sesion N")
        sys.exit(0)

    if args.sesion:
        if not 1 <= args.sesion <= len(sesiones):
            sys.exit(f"--sesion debe estar entre 1 y {len(sesiones)}")
        registros = sesiones[args.sesion - 1]
        print(f"→ Sesión {args.sesion}: {len(registros)} fotos "
              f"({registros[0]['etiqueta']} → {registros[-1]['etiqueta']})")
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

        print(f"  {r['etiqueta']:<16}  {os.path.basename(r['ruta']):<40} "
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
