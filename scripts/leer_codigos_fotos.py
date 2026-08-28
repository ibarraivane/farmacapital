#!/usr/bin/env python3
"""Decodifica códigos de barras EAN/UPC de un lote de fotos de producto.

Clasifica cada foto en:
  - CODIGO  : se pudo decodificar al menos un código de barras
  - PORTADA : no hay código legible (foto de la cara principal del empaque)

El detector se intenta sobre la imagen completa y sobre versiones rotadas,
porque las fotos de anaquel suelen venir con el empaque de lado.
"""
import csv
import os
import sys

import cv2
import numpy as np


def ean13_valido(codigo: str) -> bool:
    if len(codigo) != 13 or not codigo.isdigit():
        return False
    suma = sum(int(d) * (3 if i % 2 else 1) for i, d in enumerate(codigo[:12]))
    return (10 - suma % 10) % 10 == int(codigo[12])


def decodificar(ruta: str, detector) -> list[str]:
    img = cv2.imread(ruta)
    if img is None:
        return []
    alto = img.shape[0]
    if alto > 1600:
        escala = 1600 / alto
        img = cv2.resize(img, None, fx=escala, fy=escala, interpolation=cv2.INTER_AREA)

    variantes = [img,
                 cv2.rotate(img, cv2.ROTATE_90_CLOCKWISE),
                 cv2.rotate(img, cv2.ROTATE_180),
                 cv2.rotate(img, cv2.ROTATE_90_COUNTERCLOCKWISE)]
    # Un realce de contraste ayuda con las cajas brillantes y el flash.
    gris = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8)).apply(gris)
    variantes.append(cv2.cvtColor(clahe, cv2.COLOR_GRAY2BGR))

    encontrados = []
    for v in variantes:
        try:
            ok, infos, tipos, _ = detector.detectAndDecodeMulti(v)
        except Exception:
            continue
        if not ok:
            continue
        for texto in infos:
            texto = (texto or "").strip()
            if texto and texto not in encontrados:
                encontrados.append(texto)
        if encontrados:
            break
    return encontrados


def main(directorio: str, archivos: list[str], salida: str) -> None:
    detector = cv2.barcode.BarcodeDetector()
    filas = []
    for i, nombre in enumerate(archivos, 1):
        ruta = os.path.join(directorio, nombre)
        codigos = decodificar(ruta, detector)
        validos = [c for c in codigos if ean13_valido(c)]
        filas.append({
            "orden": i,
            "archivo": nombre,
            "tipo": "CODIGO" if codigos else "PORTADA",
            "ean": validos[0] if validos else "",
            "todos": "|".join(codigos),
            "ean_valido": "si" if validos else ("no" if codigos else ""),
        })
        print(f'{i:>3} {nombre:<45} {filas[-1]["tipo"]:<8} {filas[-1]["ean"]}', flush=True)

    with open(salida, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(filas[0].keys()))
        w.writeheader()
        w.writerows(filas)

    con = sum(1 for f in filas if f["tipo"] == "CODIGO")
    print(f"\ntotal {len(filas)} | con código {con} | portadas {len(filas) - con}")
    print(f"CSV: {salida}")


if __name__ == "__main__":
    lista = sys.argv[1]
    with open(lista) as fh:
        archivos = [l.strip() for l in fh if l.strip()]
    main(os.path.expanduser("~/Downloads"), archivos, sys.argv[2])
