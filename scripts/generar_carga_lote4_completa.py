#!/usr/bin/env python3
"""Consolida los dos SQL de staging del lote 4 en un solo archivo de carga.

Toma los renglones de patch_lote4_1_STAGING.sql y patch_lote4_2_STAGING_PARTE2.sql,
les pega la cantidad comprada del ticket Equilibrio 440393 (cruzando por código de
proveedor y lote) y emite un único script que da de alta todo en public.productos.
"""
import csv
import os
import re

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FUENTES = [
    os.path.join(RAIZ, "sql/patch_lote4_1_STAGING.sql"),
    os.path.join(RAIZ, "sql/patch_lote4_2_STAGING_PARTE2.sql"),
]
TICKET = os.path.join(RAIZ, "sql/generated/ticket_equilibrio_440393.csv")
SALIDA = os.path.join(RAIZ, "sql/CARGA_LOTE4_COMPLETA.sql")

CAMPOS = ["ean", "nombre", "presentacion", "laboratorio", "codigo_prov", "lote",
          "caducidad", "costo", "pmp_etiqueta", "foto_portada", "foto_codigo",
          "confianza", "notas"]


def partir_tupla(texto: str) -> list[str]:
    """Separa los campos de una tupla SQL respetando comillas y '' escapadas."""
    campos, actual, en_cadena, i = [], [], False, 0
    while i < len(texto):
        c = texto[i]
        if en_cadena:
            if c == "'":
                if i + 1 < len(texto) and texto[i + 1] == "'":
                    actual.append("'")
                    i += 2
                    continue
                en_cadena = False
            else:
                actual.append(c)
        elif c == "'":
            en_cadena = True
        elif c == ",":
            campos.append("".join(actual).strip())
            actual = []
        else:
            actual.append(c)
        i += 1
    campos.append("".join(actual).strip())
    return campos


def leer_filas() -> list[dict]:
    filas = []
    for ruta in FUENTES:
        with open(ruta) as fh:
            texto = fh.read()
        # Sólo el bloque de values del insert al staging.
        bloque = texto.split("confianza, notas)\nvalues\n", 1)
        if len(bloque) < 2:
            raise SystemExit(f"no encontré el bloque values en {ruta}")
        cuerpo = bloque[1].split(";\n", 1)[0]
        for linea in cuerpo.splitlines():
            linea = linea.strip()
            if not linea.startswith("("):
                continue
            interior = linea[1:linea.rstrip(",;").rstrip().rfind(")")]
            valores = partir_tupla(interior)
            if len(valores) != len(CAMPOS):
                raise SystemExit(f"{len(valores)} campos en: {linea[:70]}")
            fila = {}
            for nombre, bruto in zip(CAMPOS, valores):
                fila[nombre] = None if bruto == "null" else bruto
            filas.append(fila)
    return filas


def leer_cantidades() -> dict:
    cantidades = {}
    with open(TICKET) as fh:
        for r in csv.DictReader(fh):
            clave = (r["codigo_prov"], r["lote"])
            cantidades[clave] = cantidades.get(clave, 0) + int(r["cantidad"] or 0)
    return cantidades


def lit(valor) -> str:
    if valor is None:
        return "null"
    return "'" + str(valor).replace("'", "''") + "'"


def num(valor) -> str:
    return "null" if valor is None else str(valor)


def main() -> None:
    filas = leer_filas()
    cantidades = leer_cantidades()

    vistos, unicas = set(), []
    for f in filas:
        if f["ean"] in vistos:
            print(f'EAN repetido, se omite el segundo: {f["ean"]} {f["nombre"][:40]}')
            continue
        vistos.add(f["ean"])
        f["cantidad"] = cantidades.get((f["codigo_prov"], f["lote"]), 1)
        unicas.append(f)

    con_costo = sum(1 for f in unicas if f["costo"])
    print(f"{len(unicas)} productos | con costo del ticket: {con_costo} | "
          f"sin costo: {len(unicas) - con_costo}")

    renglones = []
    for f in unicas:
        renglones.append(
            "  (" + ", ".join([
                lit(f["ean"]), lit(f["nombre"]), lit(f["presentacion"]),
                lit(f["laboratorio"]), lit(f["codigo_prov"]), lit(f["lote"]),
                (f'{lit(f["caducidad"])}::date' if f["caducidad"] else "null::date"),
                num(f["costo"]), num(f["pmp_etiqueta"]), str(f["cantidad"]),
                lit(f["confianza"]), lit(f["notas"]),
            ]) + ")"
        )

    with open(os.path.join(RAIZ, "scripts/plantilla_carga_lote4.sql")) as fh:
        plantilla = fh.read()

    with open(SALIDA, "w") as fh:
        fh.write(plantilla.replace("{{RENGLONES}}", ",\n".join(renglones)))

    print(f"SQL: {SALIDA}")


if __name__ == "__main__":
    main()
