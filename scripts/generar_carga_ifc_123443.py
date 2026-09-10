#!/usr/bin/env python3
"""IFC F8 Tienda · ticket 123443 (10-sep-2026).

Fuente: ticket físico IFC F8 TIENDA · CJ 01 Fol 123443 · 10/09/2026 16:51 · Cliente LUIS.
MAYOREO + MENUDEO. Total $571.50 · 9 productos / 17 piezas.
P.PUBLICO = costo de compra. Sin lote ni MMAA.
Códigos IFC del ticket (82084, 83947, …) NO son EAN: altas sin código_barras;
ligar el de la caja al escanear.
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
FECHA = "2026-09-10"
FOLIO = "123443"
TOTAL = 571.50

# URL propia tras deploy Vercel
FOTO = "https://www.farmacapital.mx/catalogo-propia/{}"

ROWS = [
    {
        "nombre": "Brocha para tinte con peine de cola",
        "desc_ticket": "BROCHA TINTE C/PEINE DE COLA SK2220 82084",
        "qty": 4,
        "pu": 5.50,
        "sub": 22.00,
        "ean": "",
        "sku": "FC-IFC-82084",
        "match": "sin_ean",
        "marca": "",
        "presentacion": "Pieza",
        "forma": "Accesorio",
        "categoria": "Cuidado personal",
        "foto": None,  # TODO foto: packshot de la brocha de la caja
        "receta": False,
    },
    {
        "nombre": "Guantes de nitrilo negro mediano C/100",
        "desc_ticket": "GUANTE NITRILO NEGRO MEDIANO C/100 PZS 052025 83947",
        "qty": 1,
        "pu": 104.00,
        "sub": 104.00,
        "ean": "",
        "sku": "FC-IFC-83947",
        "match": "sin_ean",
        "marca": "",
        "presentacion": "C/100",
        "forma": "Guante",
        "categoria": "Botiquín",
        "foto": FOTO.format("guantes-nitrilo-negro-c100.jpg"),
        "receta": False,
    },
    {
        "nombre": "Guantes de nitrilo azul chico C/100",
        "desc_ticket": "GUANTE NITRILO CHICO AZUL C/100 07202595 83490",
        "qty": 1,
        "pu": 92.00,
        "sub": 92.00,
        "ean": "",
        "sku": "FC-IFC-83490",
        "match": "sin_ean",
        "marca": "",
        "presentacion": "C/100",
        "forma": "Guante",
        "categoria": "Botiquín",
        "foto": FOTO.format("guantes-nitrilo-azul-c100.jpg"),
        "receta": False,
    },
    {
        "nombre": "Venda Stick cohesiva 3 pulg × 4.5 m piel",
        "desc_ticket": "VENDA STICK 3P X 4.5 MTS PIEL 7CM 221206+2 82912",
        "qty": 1,
        "pu": 45.00,
        "sub": 45.00,
        "ean": "",
        "sku": "FC-IFC-82912P",
        "match": "sin_ean",
        "marca": "Stick",
        "presentacion": "3\" × 4.5 m",
        "forma": "Venda",
        "categoria": "Botiquín",
        "foto": FOTO.format("venda-cohesiva-stick.png"),
        "receta": False,
    },
    {
        "nombre": "Venda Stick cohesiva 3 pulg × 4.5 m azul",
        "desc_ticket": "VENDA STICK 3P X 4.5 MTS AZUL 7CM 221205-1 82912",
        "qty": 1,
        "pu": 47.50,
        "sub": 47.50,
        "ean": "",
        "sku": "FC-IFC-82912A",
        "match": "sin_ean",
        "marca": "Stick",
        "presentacion": "3\" × 4.5 m",
        "forma": "Venda",
        "categoria": "Botiquín",
        "foto": FOTO.format("venda-cohesiva-stick.png"),
        "receta": False,
    },
    {
        "nombre": "Venditas adhesivas redondas Jayor C/100",
        "desc_ticket": "JAYOR VENDITAS ADHESIVAS REDONDAS C/100 15L24 83613",
        "qty": 1,
        "pu": 52.50,
        "sub": 52.50,
        "ean": "",
        "sku": "FC-IFC-83613",
        "match": "sin_ean",
        "marca": "Jayor",
        "presentacion": "C/100",
        "forma": "Vendita",
        "categoria": "Botiquín",
        "foto": FOTO.format("venditas-adhesivas-redondas-c100.jpg"),
        "receta": False,
    },
    {
        "nombre": "Venda Stick cohesiva 2 pulg × 4.5 m rojo",
        "desc_ticket": "VENDA STICK 2P X 4.5 MTS ROJO 5CM 240306-1 83552",
        "qty": 2,
        "pu": 29.50,
        "sub": 59.00,
        "ean": "",
        "sku": "FC-IFC-83552",
        "match": "sin_ean",
        "marca": "Stick",
        "presentacion": "2\" × 4.5 m",
        "forma": "Venda",
        "categoria": "Botiquín",
        "foto": FOTO.format("venda-cohesiva-stick.png"),
        "receta": False,
    },
    {
        "nombre": "Guantes de nitrilo azul grande C/100",
        "desc_ticket": "GUANTE NITRILO GRANDE AZUL C/100 07202595 83125",
        "qty": 1,
        "pu": 92.00,
        "sub": 92.00,
        "ean": "",
        "sku": "FC-IFC-83125",
        "match": "sin_ean",
        "marca": "",
        "presentacion": "C/100",
        "forma": "Guante",
        "categoria": "Botiquín",
        "foto": FOTO.format("guantes-nitrilo-azul-c100.jpg"),
        "receta": False,
    },
    {
        "nombre": "Gel sanitizante Dibar 50 ml",
        "desc_ticket": "DIBAR GEL SANITIZANTE 50 ML C/24 1C056C05 83368",
        "qty": 5,
        "pu": 11.50,
        "sub": 57.50,
        "ean": "",
        "sku": "FC-IFC-83368",
        "match": "sin_ean",
        "marca": "Dibar",
        "presentacion": "50 ml",
        "forma": "Gel",
        "categoria": "Cuidado personal",
        "foto": FOTO.format("dibar-gel-sanitizante-50ml.jpg"),
        "receta": False,
    },
]


def ceil_pvp(costo: float, factor: float = 1.6) -> float:
    return float(math.ceil(costo * factor))


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


def write_carga_sql(path: Path) -> None:
    """Altas stock 0. Sin EAN. SIN do $$. Foto propia tras deploy (excepto brocha pendiente)."""
    lines = [
        "-- IFC F8 Tienda · folio 123443 (2026-09-10) — altas de catálogo.",
        "-- SIN bloques dollar-quote. Stock = 0; entra al escanear en Recibir.",
        "-- Sin EAN público (códigos IFC del ticket no son GS1). codigo_barras = null.",
        "-- Ligar EAN de la caja al escanear / editar ficha.",
        "-- TODO foto: FC-IFC-82084 brocha tinte (falta packshot de la pieza).",
        "-- Orden: 1) este archivo  2) patch_recepcion_ifc_123443.sql",
        "-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
    ]
    for r in ROWS:
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
            f"  {sql_str('Ticket IFC 123443 · Farma Centre · ' + r['desc_ticket'] + ' · falta EAN de caja')},",
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
            "10-sep-2026 16:51 · sin EAN GS1 (códigos IFC) · "
            "cola Recibir; stock al confirmar pistola · ligar EAN de caja"
        ),
        rows=data,
    )
    write_carga_sql(out_carga)

    suma = sum(r["sub"] for r in data)
    piezas = sum(r["qty"] for r in data)
    print(report(data, TOTAL))
    print(f"piezas={piezas} esperado=17 ok={piezas == 17}")
    print(f"suma=${suma:.2f} total=${TOTAL:.2f} delta={suma - TOTAL:.2f}")
    print(f"csv={out_csv}")
    print(f"carga={out_carga}")
    print(f"rx={out_rx}")
    if piezas != 17 or abs(suma - TOTAL) >= 0.02:
        raise SystemExit("totales no cuadran")


if __name__ == "__main__":
    main()
