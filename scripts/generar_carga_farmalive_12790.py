#!/usr/bin/env python3
"""Ticket Farmalive 12790 (2026-09-15) → CSV + SQL cola Recibir.

Fuente: ticket físico FARMA live Club Iztapalapa 1 · TICKET DE VENTA No. 12790.
32 artículos / 65 unidades. Subtotal $3,623.22 − descuento $89.11 = $3,534.11.
Costo = precio neto (después del descuento de línea: 2%, 5% u 8%).
Advil PR346 y PR347: clave interna + «Compra 3 a Precio Especial».
PR346 C/6: lista $227.00 · 2% · neto $222.46 → 3 cajas · $74.15.
PR347 caps C/10: lista $141.00 · 2% · neto $138.18 → 3 cajas · $46.06.
Advil 200 mg TAB C/12 (EAN 7501065013767): 1 caja $42.14 — no es promo.
Aspirina C/40 3PACK: empaque Bayer (EAN 7501008499429), se vende el pack.
El pie cuenta cada promo como 1 (65); Recibir usa 3+3 cajas (69).
Promos Prudence @$0.01 se dejan como renglón aparte (mismo EAN).
Gargax −$0.01 para absorber redondeo de % por línea ($3534.12 → $3534.11).
Sin lote ni MMAA.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_recepcion_sql, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_CSV = ROOT / "sql" / "generated" / "ticket_farmalive_12790.csv"
OUT_SQL = ROOT / "sql" / "patch_recepcion_farmalive_12790.sql"

FOLIO = "12790"
PROVEEDOR = "Farmalive"
FECHA = "2026-09-15"
TOTAL_TICKET = 3534.11
# Pie del ticket: 65 (PR346+PR347 = 1 c/u). Recibir: 69 (3+3 cajas).
PIEZAS_ESPERADAS = 69
ARTICULOS = 32

# descripcion mostrador, qty, subtotal_neto, ean
RAW = [
    ("Advil 12 Horas ibuprofeno 600 mg C/6 | Haleon", 3, 222.46, "7501065065322"),
    ("Advil ibuprofeno 200 mg cápsulas C/10 | Haleon", 3, 138.18, "7501108763468"),
    ("Tampax Super Plus tampones C/10 | P&G", 2, 86.24, "020800600347"),
    ("Kleenex pañuelos pack C/8 | Kimberly-Clark", 1, 32.83, "7501017362998"),
    ("Aspirina GO sobres C/10 | Bayer", 10, 588.00, "7501008499245"),
    ("Mejoral tabletas C/12 | Haleon", 4, 108.58, "7501065028785"),
    ("Aspirina tabletas C/40 3-pack | Bayer", 1, 115.15, "7501008499429"),
    ("Lubricante Prudence uva 75 mL | DKT", 1, 70.17, "7502214983207"),
    ("Condón Durex Sico Retardante C/3 | RB Health", 1, 46.75, "7506460101460"),
    ("Estomaquil sobres C/10 | Lab Higia", 2, 121.07, "7501369200085"),
    ("Losec A omeprazol 20 mg C/14 | Genomma", 1, 29.40, "7501098603867"),
    ("Tinte Koleston #50 castaño claro | Wella", 2, 107.80, "3614225108785"),
    ("Ensure líquido chocolate 237 mL | Abbott", 1, 42.63, "7501033954061"),
    ("Espaven Alcalino suspensión 360 mL | Bausch + Lomb", 1, 173.26, "7501122962816"),
    ("Gotinal spray adulto 15 mL | Chinoin", 1, 127.30, "7501088509926"),
    ("Collifrin solución nasal adulto 20 mL | Collins", 3, 106.13, "780083144302"),
    ("Parche Garnier anti-acné invisible C/22 | L'Oréal", 2, 212.46, "3600542641074"),
    ("Kaopectate tabletas C/10 | Genomma", 1, 57.53, "650240036187"),
    ("Lubricante Prudence gel natural 100 mL | DKT", 1, 101.33, "7502214986031"),
    ("Crema Teatrical rosa (lanolina) 52 g | Genomma", 3, 93.20, "650240013898"),
    ("Crema Teatrical azul 19 g | Genomma", 3, 45.32, "650240078996"),
    ("Crema Teatrical azul 52 g | Genomma", 3, 93.20, "650240013850"),
    ("Ensure líquido fresa 237 mL | Abbott", 1, 42.63, "7501033954078"),
    ("Crema Teatrical rosa (lanolina) 19 g | Genomma", 3, 45.32, "650240079009"),
    ("Anillo vibrador Prudence | DKT", 1, 86.04, "7502214982446"),
    ("Advil ibuprofeno 200 mg tabletas C/12 | Haleon", 1, 42.14, "7501065013767"),
    ("QG5 tabletas C/30 | Genomma", 1, 15.68, "650240069277"),
    ("Gargax bucofaríngeo solución 60 mL | Genomma", 2, 242.25, "650240028335"),
    ("Condón Prudence fresa C/3 | DKT", 3, 102.90, "7502214982477"),
    ("Condón Prudence fresa C/3 (promo) | DKT", 1, 0.01, "7502214982477"),
    ("Condón Prudence retardante C/3 | DKT", 5, 238.14, "7502214982439"),
    ("Condón Prudence retardante C/3 (promo) | DKT", 1, 0.01, "7502214982439"),
]


def rows() -> list[dict]:
    out = []
    for nombre, qty, sub, ean in RAW:
        out.append(
            {
                "nombre": nombre,
                "qty": qty,
                "sub": sub,
                "pu": round(sub / qty, 2),
                "ean": ean,
                "sku": "",
                "match": "ticket",
            }
        )
    return out


def main() -> None:
    data = rows()
    write_ticket_csv(
        OUT_CSV,
        folio=FOLIO,
        fecha=FECHA,
        proveedor=PROVEEDOR,
        total=TOTAL_TICKET,
        rows=data,
    )
    write_recepcion_sql(
        OUT_SQL,
        folio=FOLIO,
        proveedor=PROVEEDOR,
        proveedor_ilike="farmalive",
        fecha=FECHA,
        total=TOTAL_TICKET,
        notas=(
            f"Pedido Farmalive {FOLIO} · Club Iztapalapa 1 · 15-sep-2026 · "
            "Advil PR346 3×$74.15 · PR347 3×$46.06 · precio neto (2%/5%/8%) · "
            "promos Prudence @$0.01 · cola Recibir; stock al confirmar pistola"
        ),
        rows=data,
    )
    suma = sum(r["sub"] for r in data)
    piezas = sum(r["qty"] for r in data)
    print(report(data, TOTAL_TICKET))
    print(f"piezas={piezas} esperado={PIEZAS_ESPERADAS} ok={piezas == PIEZAS_ESPERADAS}")
    print(f"articulos={len(data)} esperado={ARTICULOS} ok={len(data) == ARTICULOS}")
    print(f"suma=${suma:.2f} total=${TOTAL_TICKET:.2f} delta={suma - TOTAL_TICKET:.2f}")
    print(f"csv={OUT_CSV}")
    print(f"sql={OUT_SQL}")
    if piezas != PIEZAS_ESPERADAS or len(data) != ARTICULOS or abs(suma - TOTAL_TICKET) >= 0.05:
        raise SystemExit("totales no cuadran")


if __name__ == "__main__":
    main()
