#!/usr/bin/env python3
"""Genera el SQL de carga del ticket Equilibrio 440393 completo a partir del CSV."""
import csv
import os

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TICKET = os.path.join(RAIZ, "sql/generated/ticket_equilibrio_440393.csv")
PLANTILLA = os.path.join(RAIZ, "scripts/plantilla_carga_ticket.sql")
SALIDA = os.path.join(RAIZ, "sql/CARGA_TICKET_EQUILIBRIO_440393.sql")


def lit(valor) -> str:
    if valor is None or valor == "":
        return "null"
    return "'" + str(valor).replace("'", "''") + "'"


def num(valor) -> str:
    return "null" if valor in (None, "") else str(valor)


def main() -> None:
    with open(TICKET) as fh:
        filas = list(csv.DictReader(fh))

    renglones = []
    for f in filas:
        caducidad = f"{lit(f['caducidad'])}::date" if f["caducidad"] else "null::date"
        renglones.append(
            "  (" + ", ".join([
                num(f["pagina"]), lit(f["codigo_prov"]), lit(f["descripcion"]),
                lit(f["lote"]), caducidad, num(f["cantidad"] or 1),
                num(f["precio_lista"]), num(f["costo_unitario"]),
                num(f["subtotal"]), num(f["total"]),
            ]) + ")"
        )

    with open(PLANTILLA) as fh:
        plantilla = fh.read()
    with open(SALIDA, "w") as fh:
        fh.write(plantilla.replace("{{RENGLONES}}", ",\n".join(renglones)))

    total = sum(float(f["costo_unitario"] or 0) * int(f["cantidad"] or 1) for f in filas)
    piezas = sum(int(f["cantidad"] or 1) for f in filas)
    print(f"{len(filas)} líneas · {piezas} piezas · costo total ${total:,.2f}")
    print(f"SQL: {SALIDA}")


if __name__ == "__main__":
    main()
