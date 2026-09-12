#!/usr/bin/env python3
"""IFC F8 Tienda · ticket 123816 (12-sep-2026).

Fuente: ticket físico IFC F8 TIENDA · CJ 01 Fol 123816 · 12/09/2026 16:07 · Cliente LUIS.
MAYOREO + MENUDEO. Total $65.00 · 3 productos / 8 piezas.
P.PUBLICO = costo de compra. Sin lote ni MMAA.
Códigos IFC del ticket NO son EAN: altas sin código_barras (excepto aceite ya en catálogo).
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_recepcion_sql, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
PROVEEDOR = "IFC F8 Tienda"
PROVEEDOR_ILIKE = "ifc"
FECHA = "2026-09-12"
FOLIO = "123816"
TOTAL = 65.00

ROWS = [
    {
        "nombre": "Pinza tijera Lady Curtis chica",
        "desc_ticket": "PINZA DEPILAR LADY CHICA",
        "qty": 2,
        "pu": 7.50,
        "sub": 15.00,
        "ean": "",
        "sku": "FC-IFC-PINZACH",
        "match": "sin_ean",
        "marca": "Curtis",
        "presentacion": "Chica",
        "forma": "Accesorio",
        "categoria": "Cuidado personal",
        "foto": "https://www.farmacapital.mx/catalogo-propia/pinza-lady-curtis-chica.jpg",
        "receta": False,
        "alta": True,
    },
    {
        "nombre": "Pinza tijera Lady Curtis grande",
        "desc_ticket": "PINZA DEPILAR LADY GRANDE",
        "qty": 2,
        "pu": 8.00,
        "sub": 16.00,
        "ean": "",
        "sku": "FC-IFC-PINZAGR",
        "match": "sin_ean",
        "marca": "Curtis",
        "presentacion": "Grande",
        "forma": "Accesorio",
        "categoria": "Cuidado personal",
        "foto": "https://www.farmacapital.mx/catalogo-propia/pinza-lady-curtis-grande.jpg",
        "receta": False,
        "alta": True,
    },
    {
        # Ya en catálogo desde IFC1-080826
        "nombre": "Mercurio Aceite Almendras",
        "desc_ticket": "MERCURIO ACEITE ALMENDRAS C/25 790523 83051",
        "qty": 4,
        "pu": 8.50,
        "sub": 34.00,
        "ean": "",
        "sku": "FC-D4AC123B",
        "match": "sku_existente",
        "marca": "Mercurio",
        "presentacion": "C/25",
        "forma": "Aceite",
        "categoria": "Producto homeopatico / natural",
        "foto": None,
        "receta": False,
        "alta": False,
    },
]


def ceil_pvp(costo: float, factor: float = 1.6) -> float:
    return float(math.ceil(costo * factor))


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


def write_carga_sql(path: Path) -> None:
    lines = [
        "-- IFC F8 Tienda · folio 123816 (2026-09-12) — altas de catálogo.",
        "-- SIN bloques dollar-quote. Stock = 0; entra al escanear en Recibir.",
        "-- Sin EAN público (códigos IFC del ticket no son GS1). codigo_barras = null.",
        "-- Aceite almendras ya existe (FC-D4AC123B): solo actualiza costo.",
        "-- Fotos Curtis Lady en catalogo-propia/.",
        "-- Orden: 1) este archivo  2) patch_recepcion_ifc_123816.sql",
        "-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
    ]
    for r in ROWS:
        if not r.get("alta"):
            pvp = ceil_pvp(r["pu"])
            lines += [
                f"-- {r['sku']} | {r['nombre']} (ya existía)",
                "update public.productos set",
                f"  costo = {r['pu']:.2f},",
                f"  precio = case when coalesce(precio, 0) <= 0 then {pvp:.2f} else precio end",
                f"where sku = {sql_str(r['sku'])};",
                "",
            ]
            continue
        pvp = ceil_pvp(r["pu"])
        foto_sql = sql_str(r["foto"]) if r.get("foto") else "null"
        marca_sql = sql_str(r["marca"]) if r.get("marca") else "null"
        lines += [
            f"-- {r['sku']} | {r['nombre']}",
            "insert into public.productos (",
            "  nombre, sku, codigo_barras, categoria, tipo, descripcion,",
            "  costo, precio, stock, stock_minimo, activo, requiere_receta,",
            "  marca, presentacion, forma_farmaceutica, imagen_url",
            ")",
            "select",
            f"  {sql_str(r['nombre'])},",
            f"  {sql_str(r['sku'])},",
            "  null,",
            f"  {sql_str(r['categoria'])},",
            "  'marca',",
            f"  {sql_str('Ticket IFC 123816 · Farma Centre · ' + r['desc_ticket'] + ' · falta EAN de caja')},",
            f"  {r['pu']:.2f}, {pvp:.2f}, 0, 1, true, {'true' if r['receta'] else 'false'},",
            f"  {marca_sql},",
            f"  {sql_str(r['presentacion'])},",
            f"  {sql_str(r['forma'])},",
            f"  {foto_sql}",
            f"where not exists (select 1 from public.productos where sku = {sql_str(r['sku'])});",
            "",
            "update public.productos set",
            f"  costo = {r['pu']:.2f},",
            f"  precio = case when coalesce(precio, 0) <= 0 then {pvp:.2f} else precio end,",
            f"  marca = coalesce(nullif(btrim(marca), ''), {marca_sql}),",
            f"  presentacion = coalesce(nullif(btrim(presentacion), ''), {sql_str(r['presentacion'])}),",
            f"  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), {sql_str(r['forma'])}),",
            f"  categoria = coalesce(nullif(btrim(categoria), ''), {sql_str(r['categoria'])}),",
            f"  imagen_url = coalesce(nullif(btrim(imagen_url), ''), {foto_sql})",
            f"where sku = {sql_str(r['sku'])};",
            "",
        ]

    skus = ", ".join(sql_str(r["sku"]) for r in ROWS)
    lines += [
        "commit;",
        "",
        "select sku, codigo_barras as ean, left(nombre, 48) as nombre, costo, precio, stock,",
        "  left(coalesce(imagen_url, '(sin foto)'), 64) as foto",
        "from public.productos",
        f"where sku in ({skus})",
        "order by sku;",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def rows_rx() -> list[dict]:
    return [
        {
            "nombre": r["nombre"],
            "qty": r["qty"],
            "sub": r["sub"],
            "pu": r["pu"],
            "ean": r["ean"],
            "sku": r["sku"],
            "match": r["match"],
        }
        for r in ROWS
    ]


def main() -> None:
    data = rows_rx()
    out_csv = ROOT / "sql" / "generated" / f"ticket_ifc_{FOLIO}.csv"
    out_rx = ROOT / "sql" / f"patch_recepcion_ifc_{FOLIO}.sql"
    out_carga = ROOT / "sql" / f"patch_carga_ifc_{FOLIO}.sql"

    write_ticket_csv(out_csv, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL, rows=data)
    write_recepcion_sql(
        out_rx,
        folio=FOLIO,
        proveedor=PROVEEDOR,
        proveedor_ilike=PROVEEDOR_ILIKE,
        fecha=FECHA,
        total=TOTAL,
        notas=(
            f"Farma Centre / IFC F8 Tienda · folio {FOLIO} · MAYOREO+MENUDEO · "
            "12-sep-2026 16:07 · sin EAN GS1 (códigos IFC) · "
            "cola Recibir; stock al confirmar pistola · ligar EAN de caja"
        ),
        rows=data,
    )
    write_carga_sql(out_carga)

    suma = sum(r["sub"] for r in data)
    piezas = sum(r["qty"] for r in data)
    print(report(data, TOTAL))
    print(f"piezas={piezas} esperado=8 ok={piezas == 8}")
    print(f"suma=${suma:.2f} total=${TOTAL:.2f} delta={suma - TOTAL:.2f}")
    print(f"csv={out_csv}")
    print(f"carga={out_carga}")
    print(f"rx={out_rx}")
    if piezas != 8 or abs(suma - TOTAL) >= 0.02:
        raise SystemExit("totales no cuadran")


if __name__ == "__main__":
    main()
