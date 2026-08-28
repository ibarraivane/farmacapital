#!/usr/bin/env python3
"""Vuelve a cruzar los 103 productos del lote 4 contra el ticket Equilibrio.

El ticket abrevia los nombres ("FLOROGLU/TRIMETILFLORO" por floroglucinol), así
que buscar la palabra completa deja fuera coincidencias válidas. Aquí se compara
por prefijo de la primera palabra y se muestran los candidatos para revisarlos a
mano, en vez de decidir solo.
"""
import csv
import difflib
import os
import re
import unicodedata

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TICKET = os.path.join(RAIZ, "sql/generated/ticket_equilibrio_440393.csv")
CARGA = os.path.join(RAIZ, "sql/CARGA_LOTE4_COMPLETA.sql")

# Palabras del nombre comercial que no sirven para identificar.
RUIDO = {"de", "la", "el", "con", "sin", "para", "y", "mg", "ml", "gr", "g",
         "caja", "frasco", "tubo", "sobre", "sobres", "solucion", "solución",
         "jarabe", "crema", "gel", "gotas", "tabletas", "tableta", "capsulas",
         "cápsulas", "adulto", "infantil", "susp", "suspension", "suspensión"}


def normalizar(texto: str) -> str:
    t = unicodedata.normalize("NFKD", texto or "").encode("ascii", "ignore").decode()
    return re.sub(r"[^A-Z0-9 ]", " ", t.upper())


def claves(nombre: str) -> list[str]:
    """Palabras significativas del nombre, la primera es la marca."""
    palabras = [p for p in normalizar(nombre).split()
                if len(p) >= 4 and p.lower() not in RUIDO]
    return palabras[:3]


def leer_carga() -> list[dict]:
    filas = []
    for linea in open(CARGA):
        if not linea.startswith("  ('"):
            continue
        campos = re.findall(r"'((?:[^']|'')*)'", linea)
        if len(campos) < 2:
            continue
        tiene_costo = not re.search(r"::date, null, ", linea)
        filas.append({
            "ean": campos[0],
            "nombre": campos[1].replace("''", "'"),
            "con_costo": tiene_costo,
        })
    return filas


def main() -> None:
    ticket = list(csv.DictReader(open(TICKET)))
    for t in ticket:
        t["norm"] = normalizar(t["descripcion"])

    carga = leer_carga()
    sin_costo = [c for c in carga if not c["con_costo"]]
    print(f"{len(carga)} productos en la carga · {len(sin_costo)} sin costo\n")

    for c in sin_costo:
        ks = claves(c["nombre"])
        candidatos = []
        for t in ticket:
            for k in ks:
                # Prefijo de 5 letras: aguanta las abreviaturas del ticket.
                if len(k) >= 5 and k[:5] in t["norm"]:
                    candidatos.append(t)
                    break
        if not candidatos:
            # Última red: parecido difuso contra la descripción completa.
            base = normalizar(c["nombre"])
            candidatos = [t for t in ticket
                          if difflib.SequenceMatcher(None, base[:20], t["norm"][:20]).ratio() > 0.62]

        print(f'{c["nombre"][:58]:<58} {c["ean"]}')
        if not candidatos:
            print("    sin candidatos en el ticket")
        for t in candidatos[:4]:
            print(f'    {t["codigo_prov"]:<8} {t["descripcion"][:44]:<44} '
                  f'lote {t["lote"]:<12} cad {t["caducidad"]} '
                  f'cant {t["cantidad"]:>2} costo {t["costo_unitario"]:>8}')
        print()


if __name__ == "__main__":
    main()
