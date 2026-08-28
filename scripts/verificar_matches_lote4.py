#!/usr/bin/env python3
"""Revisa los 103 renglones de la carga del lote 4 contra el ticket Equilibrio.

Tres comprobaciones:

  1. Integridad: el par (código de proveedor, lote) que le asigné a cada
     producto existe realmente en el ticket, y el costo es el de esa línea.
  2. Plausibilidad: el nombre del producto se parece a la descripción del
     ticket, tolerando las abreviaturas ("TOBR/DEXAM" por tobramicina).
  3. Colisiones: una misma línea del ticket asignada a dos productos distintos.

Nada de esto decide por sí solo; marca lo que hay que mirar a mano.
"""
import csv
import os
import re
import unicodedata

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TICKET = os.path.join(RAIZ, "sql/generated/ticket_equilibrio_440393.csv")
CARGA = os.path.join(RAIZ, "sql/CARGA_LOTE4_COMPLETA.sql")

RUIDO = {"caja", "frasco", "tubo", "sobre", "sobres", "solucion", "jarabe",
         "crema", "gel", "gotas", "tabletas", "tableta", "capsulas", "capsula",
         "adulto", "infantil", "susp", "suspension", "polvo", "aerosol",
         "atomizador", "efervescente", "masticable", "pastillas", "grageas",
         "supositorios", "electrolitos", "vitamina", "sabor", "para", "con"}


def normalizar(texto: str) -> str:
    t = unicodedata.normalize("NFKD", texto or "").encode("ascii", "ignore").decode()
    return re.sub(r"[^A-Z0-9]", " ", t.upper())


def significativas(nombre: str) -> list[str]:
    return [p for p in normalizar(nombre).split()
            if len(p) >= 4 and p.lower() not in RUIDO]


def parecido(nombre: str, descripcion: str) -> bool:
    """Alguna palabra del nombre aparece en la descripción, aunque abreviada."""
    desc = normalizar(descripcion)
    for palabra in significativas(nombre):
        for corte in (len(palabra), 7, 6, 5):
            if corte <= len(palabra) and palabra[:corte] in desc:
                return True
    return False


def leer_carga() -> list[dict]:
    filas = []
    for linea in open(CARGA):
        if not linea.startswith("  ('"):
            continue
        campos = linea.strip().rstrip(",;")[1:-1]
        piezas, actual, en_cadena, i = [], [], False, 0
        while i < len(campos):
            c = campos[i]
            if en_cadena:
                if c == "'":
                    if i + 1 < len(campos) and campos[i + 1] == "'":
                        actual.append("'")
                        i += 2
                        continue
                    en_cadena = False
                else:
                    actual.append(c)
            elif c == "'":
                en_cadena = True
            elif c == ",":
                piezas.append("".join(actual).strip())
                actual = []
            else:
                actual.append(c)
            i += 1
        piezas.append("".join(actual).strip())
        filas.append({
            "ean": piezas[0], "nombre": piezas[1], "codigo_prov": piezas[4],
            "lote": piezas[5],
            "costo": None if piezas[7] == "null" else float(piezas[7]),
        })
    return filas


def main() -> None:
    ticket = list(csv.DictReader(open(TICKET)))
    por_clave = {}
    for t in ticket:
        por_clave.setdefault((t["codigo_prov"], t["lote"]), []).append(t)

    carga = leer_carga()
    print(f"{len(carga)} productos en la carga · {len(ticket)} líneas en el ticket\n")

    inexistentes, costo_malo, nombre_raro, sin_ticket = [], [], [], []
    usadas = {}

    for c in carga:
        if not c["codigo_prov"] or c["codigo_prov"] == "null":
            sin_ticket.append(c)
            continue

        clave = (c["codigo_prov"], c["lote"])
        lineas = por_clave.get(clave)
        if not lineas:
            inexistentes.append(c)
            continue

        usadas.setdefault(clave, []).append(c["nombre"])

        linea = lineas[0]
        if c["costo"] is None or abs(c["costo"] - float(linea["costo_unitario"])) > 0.011:
            costo_malo.append((c, linea))

        if not parecido(c["nombre"], linea["descripcion"]):
            nombre_raro.append((c, linea))

    print("1) Par código+lote que NO existe en el ticket")
    for c in inexistentes:
        print(f'   {c["codigo_prov"]:<8} lote {c["lote"]:<12} {c["nombre"][:50]}')
    print(f'   -> {len(inexistentes)}\n')

    print("2) Costo distinto al de la línea del ticket")
    for c, t in costo_malo:
        print(f'   {c["nombre"][:44]:<44} carga {c["costo"]} vs ticket {t["costo_unitario"]}')
    print(f'   -> {len(costo_malo)}\n')

    print("3) El nombre no se parece a la descripción del ticket — revisar")
    for c, t in nombre_raro:
        print(f'   {c["nombre"][:44]:<44} {c["codigo_prov"]:<8} {t["descripcion"][:44]}')
    print(f'   -> {len(nombre_raro)}\n')

    print("4) Una misma línea del ticket asignada a dos productos")
    colisiones = {k: v for k, v in usadas.items() if len(v) > 1}
    for k, v in colisiones.items():
        print(f'   {k[0]} lote {k[1]}: ' + " | ".join(n[:34] for n in v))
    print(f'   -> {len(colisiones)}\n')

    print(f"5) Sin línea de ticket asignada: {len(sin_ticket)}")
    for c in sin_ticket:
        print(f'   {c["nombre"][:60]}')

    print(f"\nLíneas del ticket todavía sin producto: "
          f"{len(por_clave) - len(usadas)} de {len(por_clave)}")


if __name__ == "__main__":
    main()
