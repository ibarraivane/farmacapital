#!/usr/bin/env python3
"""Genera el SQL de carga del ticket Farma MX a partir de la transcripción.

Lee sql/generated/ticket_farmamx_CAICA1CA108588.csv, valida que cada renglón
cuadre y rellena la plantilla scripts/plantilla_carga_farmamx.sql.
"""
import csv
import os
import subprocess
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV = os.path.join(RAIZ, "sql/generated/ticket_farmamx_CAICA1CA108588.csv")
PLANTILLA = os.path.join(RAIZ, "scripts/plantilla_carga_farmamx.sql")
SALIDA = os.path.join(RAIZ, "sql/CARGA_TICKET_FARMAMX_108588.sql")


def lit(valor) -> str:
    if valor is None or valor == "":
        return "null"
    return "'" + str(valor).replace("'", "''") + "'"


def num(valor, defecto="null") -> str:
    return defecto if valor in (None, "") else str(valor)


def main() -> int:
    # No generar SQL sobre una transcripción que no cuadra.
    val = subprocess.run([sys.executable, os.path.join(RAIZ, "scripts/validar_ticket_farmamx.py")],
                         capture_output=True, text=True)
    print(val.stdout, end="")
    if val.returncode != 0:
        print("\nLa transcripción tiene pendientes. Reviso antes de generar el SQL.")
        print("Si los pendientes ya se revisaron a mano, correr con --forzar.")
        if "--forzar" not in sys.argv:
            return 1
        print("Continúo por --forzar.\n")

    with open(CSV) as fh:
        filas = list(csv.DictReader(fh))

    renglones = []
    for f in filas:
        cantidad = int(round(float(f["cantidad"])))
        renglones.append("  (" + ", ".join([
            f["pagina"],
            lit(f["clave"]),
            lit(f["descripcion"]),
            lit(f["lote"]),
            (f'{lit(f["caducidad"])}::date' if f["caducidad"] else "null::date"),
            str(cantidad),
            num(f["precio_unitario"]),
            num(f["descuento"], "0"),
            num(f["subtotal"]),
        ]) + ")")

    with open(PLANTILLA) as fh:
        plantilla = fh.read()

    sql = (plantilla
           .replace("{{N_LINEAS}}", str(len(filas)))
           .replace("{{RENGLONES}}", ",\n".join(renglones)))

    with open(SALIDA, "w") as fh:
        fh.write(sql)

    total = sum(float(f["subtotal"]) for f in filas)
    print(f"\n{len(filas)} renglones | suma de subtotales {total:,.2f}")
    print(f"SQL: {SALIDA}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
