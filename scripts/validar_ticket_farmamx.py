#!/usr/bin/env python3
"""Revisa la transcripción del ticket Farma MX antes de generar el SQL de carga.

El ticket son seis fotos sin capa de texto, así que la transcripción se hizo a
ojo y hay que probarla. Dos comprobaciones la cierran contra los totales que el
propio ticket imprime: la suma de los subtotales y la suma de las cantidades.
Si ambas dan, es prácticamente imposible que quede un renglón mal leído.

Además revisa renglón por renglón que cantidad x precio - descuento dé el
subtotal, y que las caducidades sean posteriores a la fecha de compra.
"""
import csv
import os
import sys
from collections import defaultdict
from datetime import date

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV = os.path.join(RAIZ, "sql/generated/ticket_farmamx_CAICA1CA108588.csv")
FECHA_TICKET = date(2026, 8, 8)
TOLERANCIA = 0.02  # el ticket redondea a dos decimales

# Totales impresos al pie del ticket, en la página 6.
SUBTOTAL_TICKET = 5310.35
ARTICULOS_TICKET = 233
# El ticket calcula los descuentos sobre el bruto y redondea; nuestra resta
# renglón por renglón se desvía unos centavos contra el subtotal general.
TOLERANCIA_TOTAL = 0.10


def main() -> int:
    with open(CSV) as fh:
        filas = list(csv.DictReader(fh))

    problemas = []
    total = 0.0
    articulos = 0
    por_clave = defaultdict(list)

    for i, f in enumerate(filas, 2):
        etiqueta = f'pág {f["pagina"]} clave {f["clave"]} {f["descripcion"][:38]}'

        try:
            cant = float(f["cantidad"])
            precio = float(f["precio_unitario"])
            desc = float(f["descuento"] or 0)
            sub = float(f["subtotal"])
        except ValueError:
            problemas.append(f"{etiqueta}: montos ilegibles en la línea {i}")
            continue

        esperado = cant * precio - desc
        if abs(esperado - sub) > TOLERANCIA:
            problemas.append(
                f"{etiqueta}: {cant} x {precio} - {desc} = {esperado:.2f}, "
                f"pero el ticket dice {sub:.2f}"
            )
        total += sub
        articulos += cant

        if not f["lote"]:
            problemas.append(f"{etiqueta}: sin lote")

        if f["caducidad"]:
            y, m, d = (int(x) for x in f["caducidad"].split("-"))
            if date(y, m, d) <= FECHA_TICKET:
                problemas.append(f'{etiqueta}: caducidad {f["caducidad"]} anterior al ticket')
        else:
            problemas.append(f"{etiqueta}: sin caducidad")

        por_clave[f["clave"]].append(f)

    for clave, grupo in por_clave.items():
        if len(grupo) > 1:
            descs = {g["descripcion"] for g in grupo}
            if len(descs) > 1:
                problemas.append(f"clave {clave} repetida con descripciones distintas: {descs}")
            else:
                print(f"aviso: clave {clave} aparece {len(grupo)} veces ({grupo[0]['descripcion'][:40]})")

    print(f"\nrenglones: {len(filas)} | claves distintas: {len(por_clave)}")

    # --- Contra los totales impresos del ticket ---
    dif = total - SUBTOTAL_TICKET
    ok_total = abs(dif) <= TOLERANCIA_TOTAL
    print(f'subtotal:  transcrito {total:>10,.2f} | ticket {SUBTOTAL_TICKET:>10,.2f} | '
          f'diferencia {dif:+.2f}  {"ok" if ok_total else "NO CUADRA"}')
    articulos = int(round(articulos))
    ok_art = articulos == ARTICULOS_TICKET
    print(f'artículos: transcrito {articulos:>10,} | ticket {ARTICULOS_TICKET:>10,} | '
          f'{"ok" if ok_art else "NO CUADRA"}')

    if not ok_total:
        problemas.append(f"la suma de subtotales se aleja {dif:+.2f} del subtotal del ticket")
    if not ok_art:
        problemas.append(
            f"faltan o sobran {ARTICULOS_TICKET - articulos:+d} piezas contra el ticket")

    if problemas:
        print(f"\n{len(problemas)} cosas que revisar:")
        for p in problemas:
            print("  -", p)
        return 1

    print("\ntodo cuadra")
    return 0


if __name__ == "__main__":
    sys.exit(main())
