#!/usr/bin/env python3
"""Limpia el CSV de imagenes de Rappi antes de importarlo a Supabase.

El export original traia 6 filas duplicadas (mismo ean + ruta_original) que
chocan contra el indice unico de public.catalogo_imagenes_rappi: la importacion
se corta a la mitad con "already exists". Tambien traia saltos de linea al final
de nombre_rappi, que rompen parsers de CSV menos tolerantes.

Uso:
    python3 scripts/limpiar_csv_imagenes_rappi.py ENTRADA.csv [SALIDA.csv] [--partes N]
"""
import csv
import sys
from pathlib import Path

COLUMNAS = [
    "ean", "sku_local", "nombre_local", "rappi_product_id", "nombre_rappi",
    "posicion", "es_principal_sugerida", "ruta_original", "url_origen",
    "estado_revision",
]


def limpiar(rows):
    vistos = set()
    limpias, descartadas = [], []
    for row in rows:
        fila = {c: (row.get(c) or "").strip() for c in COLUMNAS}
        clave = (fila["ean"], fila["ruta_original"])
        if clave in vistos:
            descartadas.append(fila)
            continue
        vistos.add(clave)
        limpias.append(fila)
    return limpias, descartadas


def escribir(destino, filas):
    with open(destino, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=COLUMNAS, quoting=csv.QUOTE_ALL)
        w.writeheader()
        w.writerows(filas)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    partes = 0
    for a in sys.argv[1:]:
        if a.startswith("--partes"):
            partes = int(a.split("=")[1]) if "=" in a else 4

    entrada = Path(args[0])
    salida = Path(args[1]) if len(args) > 1 else entrada.with_name(entrada.stem + "_dedup.csv")

    with open(entrada, encoding="utf-8-sig", newline="") as f:
        filas = list(csv.DictReader(f))

    limpias, descartadas = limpiar(filas)
    escribir(salida, limpias)

    eans = {r["ean"] for r in limpias}
    principales = sum(1 for r in limpias if r["es_principal_sugerida"] == "true")
    print(f"entrada: {len(filas)} filas")
    print(f"duplicadas descartadas: {len(descartadas)}")
    print(f"salida: {len(limpias)} filas | {len(eans)} eans | {principales} principales")
    print(f"-> {salida}")

    if partes:
        # Corta por producto: ningun ean queda repartido entre dos archivos.
        tam = -(-len(limpias) // partes)
        bloque, indice = [], 1
        for i, fila in enumerate(limpias):
            bloque.append(fila)
            siguiente = limpias[i + 1]["ean"] if i + 1 < len(limpias) else None
            if len(bloque) >= tam and fila["ean"] != siguiente:
                p = salida.with_name(f"{salida.stem}_parte{indice}.csv")
                escribir(p, bloque)
                print(f"-> {p} ({len(bloque)} filas)")
                bloque, indice = [], indice + 1
        if bloque:
            p = salida.with_name(f"{salida.stem}_parte{indice}.csv")
            escribir(p, bloque)
            print(f"-> {p} ({len(bloque)} filas)")


if __name__ == "__main__":
    main()
