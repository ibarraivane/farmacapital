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
import tempfile
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


def _a_jpeg_temporal(ruta):
    """Convierte HEIC a un JPEG temporal, porque OpenCV no abre HEIC.

    Devuelve (ruta_a_usar, temporal_a_borrar). macOS trae sips, así que sale
    más barato convertir al vuelo que arrastrar una dependencia nueva.
    """
    if os.path.splitext(ruta)[1].lower() not in {".heic", ".heif"}:
        return ruta, None
    tmp = tempfile.NamedTemporaryFile(suffix=".jpg", delete=False)
    tmp.close()
    try:
        r = subprocess.run(["sips", "-s", "format", "jpeg", ruta, "--out", tmp.name],
                           capture_output=True, timeout=60)
        if r.returncode == 0 and os.path.getsize(tmp.name) > 0:
            return tmp.name, tmp.name
    except Exception:
        pass
    try: os.unlink(tmp.name)
    except OSError: pass
    return None, None


def tiene_codigo(ruta):
    """True si se decodifica un código de barras. None si no se pudo evaluar."""
    try:
        import cv2
    except ImportError:
        return None
    ruta_cv, tmp = _a_jpeg_temporal(ruta)
    try:
        return _detectar(ruta_cv) if ruta_cv else None
    finally:
        if tmp:
            try: os.unlink(tmp)
            except OSError: pass


def _detectar(ruta):
    import cv2
    img = cv2.imread(ruta)
    if img is None:
        return None
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


class NoSePudoLeer(Exception):
    """Demasiadas fotos ilegibles: emparejar por códigos daría basura."""
    def __init__(self, sin_evaluar, total):
        self.sin_evaluar, self.total = sin_evaluar, total
        super().__init__(f"{sin_evaluar} de {total} fotos no se pudieron leer")


def asignar_roles(rutas, ventana=11):
    """Decide portada/código foto por foto leyendo los códigos de barras.

    Asumir que la secuencia alterna portada/código falla en cuanto se cuela o
    se pierde una toma: de ahí en adelante todo queda desfasado. Aquí en vez de
    asumirlo se mide, con dos precauciones:

    - El detector se equivoca en ~10% (hay portadas que muestran el código, y
      códigos que no alcanza a leer). Por eso la fase no se decide con la foto
      suelta sino por mayoría en una ventana de vecinas.
    - La fase puede cambiar a media sesión. La ventana es deslizante, así que
      cada tramo se resuelve con su propia fase.
    """
    crudo = [tiene_codigo(r) for r in rutas]
    # None significa "no se pudo evaluar", que NO es lo mismo que "no tiene
    # código". Confundirlos hace que todas las fotos parezcan portadas y el
    # pareo salga inservible, sin que nada avise.
    sin_evaluar = sum(1 for d in crudo if d is None)
    if sin_evaluar > len(rutas) * 0.2:
        raise NoSePudoLeer(sin_evaluar, len(rutas))

    det = [bool(d) for d in crudo]
    roles, fases = [], []
    for i in range(len(rutas)):
        lo, hi = max(0, i - ventana), min(len(rutas), i + ventana + 1)
        # fase A: las posiciones pares son portada. fase B: al revés.
        a = sum(1 for j in range(lo, hi) if det[j] == (j % 2 == 1))
        fase = "A" if a >= (hi - lo) - a else "B"
        es_codigo = (i % 2 == 1) if fase == "A" else (i % 2 == 0)
        roles.append("codigo" if es_codigo else "portada")
        fases.append(fase)
    return det, roles, fases


def emparejar(rutas, roles):
    """Agrupa cada portada con el código que le sigue.

    Devuelve [(portada, codigo)], con None donde falte una de las dos: así los
    productos incompletos quedan señalados en vez de arrastrar el desfase.
    """
    pares, i = [], 0
    while i < len(rutas):
        if roles[i] == "portada":
            if i + 1 < len(rutas) and roles[i + 1] == "codigo":
                pares.append((rutas[i], rutas[i + 1]))
                i += 2
            else:
                pares.append((rutas[i], None))
                i += 1
        else:
            pares.append((None, rutas[i]))
            i += 1
    return pares


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("carpeta", help="carpeta con las fotos recibidas")
    ap.add_argument("--salida", help="destino de las copias (default: <carpeta>/ordenadas)")
    ap.add_argument("--aplicar", action="store_true", help="copiar; sin esto solo muestra")
    ap.add_argument("--emparejar", action="store_true",
                    help="decidir portada/código leyendo los códigos de barras, "
                         "en vez de asumir que la secuencia alterna")
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

    rutas = [r["ruta"] for r in registros]

    if args.emparejar:
        print("Leyendo códigos de barras para decidir el papel de cada foto…")
        try:
            _, roles, fases = asignar_roles(rutas)
            pares = emparejar(rutas, roles)
            cortes = [i + 1 for i in range(1, len(fases)) if fases[i] != fases[i - 1]]
        except NoSePudoLeer as e:
            sys.exit(
                f"\n✗ {e}.\n"
                "  Sin poder leer los códigos no se puede decidir el papel de cada\n"
                "  foto, y forzarlo daría un pareo inservible. Corre sin --emparejar\n"
                "  para asumir que la secuencia alterna, o convierte las fotos a JPG.\n")
    else:
        roles = ["portada" if i % 2 == 0 else "codigo" for i in range(len(rutas))]
        pares = [(rutas[i], rutas[i + 1] if i + 1 < len(rutas) else None)
                 for i in range(0, len(rutas), 2)]
        cortes = []

    por_ruta = {r["ruta"]: r for r in registros}
    incompletos = []
    for n, (portada, codigo) in enumerate(pares, 1):
        if not portada or not codigo:
            incompletos.append(n)
        for ruta, papel, letra in ((portada, "portada", "a"), (codigo, "codigo", "b")):
            if not ruta:
                print(f"  {'—':<16}  {'(falta)':<40} → {n:04d}_{letra}_{papel}  ⚠️")
                continue
            ext = os.path.splitext(ruta)[1].lower()
            nombre = f"{n:04d}_{letra}_{papel}{ext}"
            por_ruta[ruta]["nombre"] = nombre
            print(f"  {por_ruta[ruta]['etiqueta']:<16}  "
                  f"{os.path.basename(ruta):<40} → {nombre}")
            if args.aplicar:
                shutil.copy2(ruta, os.path.join(salida, nombre))

    print()
    print(f"{len(pares)} productos · {len(rutas)} fotos")
    if cortes:
        print(f"\n⚠️  El orden portada/código se invierte en la(s) foto(s) "
              f"{', '.join(map(str, cortes))}.")
        print("    Ahí se coló o se perdió una toma. El pareo ya se ajustó solo,")
        print("    pero vale la pena revisar esos productos a ojo.")
    if incompletos:
        print(f"\n⚠️  {len(incompletos)} producto(s) sin su par completo: "
              f"{', '.join(f'{n:04d}' for n in incompletos[:15])}"
              f"{'…' if len(incompletos) > 15 else ''}")
    if args.aplicar:
        print(f"✅ Copiadas a {salida} (los originales no se tocaron)")
    else:
        print("Nada se copió. Repite con --aplicar cuando el orden se vea bien.")


if __name__ == "__main__":
    main()
