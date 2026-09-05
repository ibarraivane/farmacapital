#!/usr/bin/env python3
"""Ticket Farma Mayoreo 303033 (05-sep-2026) → catálogo + cola Recibir.

ID VENTA 303033 · Central de Abastos Iztapalapa · tarjeta.
P.U. ya trae IVA (suma renglones = $1,843.16 = TOTAL del ticket).
Fichas desde Fahorro / ficha de marca / Open Beauty Facts / catálogo local,
no el recorte del térmico (JBN LIQ, AC. FRUCTIS, AFRIN AD…).
Lote de fábrica del papel cuando no se repite en el renglón de abajo
(el POS a veces reimprime el Lt. anterior). Caducidad NO: MMAA de la caja.
Ting polvo 45 g trae FecCad 30-04-2026 (ya vencido el día del ticket).
"""
from __future__ import annotations

import csv
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_farmamayoreo_303033.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_farmamayoreo_303033.sql"

FOLIO = "303033"
PROVEEDOR = "Farma Mayoreo"
FECHA = "2026-09-05"
TOTAL_TICKET = 1843.16
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, factor: float = 1.25) -> int:
    return int(math.ceil(costo * factor))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


def foto(name: str | None) -> tuple[str | None, str | None]:
    if not name:
        return None, None
    path = ROOT / "public" / "catalogo-propia" / name
    if not path.exists() or path.stat().st_size < 4000:
        return None, None
    return f"{FOTO_BASE}/{name}", f"catalogo-propia/{name}"


# Fichas (no el código del ticket). ya=True si el EAN ya estaba en historial/altas.
ROWS = [
    {
        "ean": "7503007859648",
        "sku": sku_de("7503007859648"),
        "snap": "BLUMEN JABON LIQ",
        "nombre": "Blumen jabón líquido Cherry Blossom 525 ml",
        "qty": 1, "pu": 35.98, "sub": 35.98, "lote": None,
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Higiene", "forma": "Jabón líquido",
        "marca": "Blumen", "laboratorio": None,
        "presentacion": "Botella 525 ml",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "blumen-jabon-liquido-cherry-525ml.jpg",
    },
    {
        "ean": "7501943490598",
        "sku": sku_de("7501943490598"),
        "snap": "JBN LIQ ESCUDO P",
        "nombre": "Jabón líquido Escudo para manos",
        "qty": 1, "pu": 28.00, "sub": 28.00, "lote": None,
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Higiene", "forma": "Jabón líquido",
        "marca": "Escudo", "laboratorio": "P&G",
        "presentacion": None,
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "escudo-jabon-liquido.jpg",
    },
    {
        "ean": "7503002163023",
        "sku": sku_de("7503002163023"),
        "snap": "XTREME GEL PROFE",
        "nombre": "Xtreme gel Professional 250 g",
        "qty": 3, "pu": 22.98, "sub": 68.94, "lote": "K72556L428",
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Cabello", "forma": "Gel",
        "marca": "Xtreme", "laboratorio": None,
        "presentacion": "Envase 250 g",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "xtreme-gel-profesional-250g.jpg",
    },
    {
        "ean": "7501007528427",
        "sku": sku_de("7501007528427"),
        "snap": "LUBRIDERM REPARA",
        "nombre": "Lubriderm Reparación Intensiva 400 ml",
        "qty": 1, "pu": 90.98, "sub": 90.98, "lote": None,
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Piel", "forma": "Crema",
        "marca": "Lubriderm", "laboratorio": "Kenvue",
        "presentacion": "Frasco 400 ml",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "lubriderm-reparacion-intensiva-400ml.jpg",
    },
    {
        "ean": "7501004100435",
        "sku": sku_de("7501004100435"),
        "snap": "AFRIN AD 20 ML +",
        "nombre": "Afrin Adulto spray nasal 20 ml",
        "qty": 1, "pu": 83.92, "sub": 83.92, "lote": "20K0128",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Respiratorio", "forma": "Spray nasal",
        "marca": "Afrin", "laboratorio": "Bayer",
        "presentacion": "Frasco 20 ml",
        "principio": "Oximetazolina", "concentracion": "0.050%", "receta": False,
        "ya": False, "foto_file": "afrin-adulto-20ml.jpg",
        # EAN del ticket; el Afrin Adulto 20 ml del catálogo usa 7501050613453.
    },
    {
        "ean": "7501008499795",
        "sku": sku_de("7501008499795"),
        "snap": "AFRIN NODRIP NIÑ",
        "nombre": "Afrin No Drip Niños suspensión nasal 15 ml",
        "qty": 1, "pu": 96.98, "sub": 96.98, "lote": "2605493",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Respiratorio", "forma": "Suspensión nasal",
        "marca": "Afrin", "laboratorio": "Bayer",
        "presentacion": "Frasco nebulizador 15 ml",
        "principio": "Oximetazolina", "concentracion": "0.50 mg/ml", "receta": False,
        "ya": False, "foto_file": "afrin-nodrip-ninos-15ml.jpg",
    },
    {
        "ean": "7501088509810",
        "sku": "FL-8509810",
        "snap": "ANTIFLUDES SOL P",
        "nombre": "Antiflu-Des pediátrico solución 30 ml",
        "qty": 1, "pu": 145.98, "sub": 145.98, "lote": "BEK113",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Respiratorio", "forma": "Solución",
        "marca": "Antiflu-Des", "laboratorio": "CHINOIN",
        "presentacion": "Frasco 30 ml",
        "principio": "Paracetamol + clorfenamina + fenilefrina",
        "concentracion": None, "receta": False,
        "ya": True, "foto_file": "antiflu-des-pediatrico-30ml.jpg",
    },
    {
        "ean": "7501258216029",
        "sku": sku_de("7501258216029"),
        "snap": "SERRAL PROTECTOR",
        "nombre": "Protector solar Serral FPS 50+ 60 g",
        "qty": 1, "pu": 37.98, "sub": 37.98, "lote": "250653",
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Protector solar", "forma": "Crema",
        "marca": "Serral", "laboratorio": "Laboratorios Serral",
        "presentacion": "Tubo 60 g",
        "principio": None, "concentracion": "FPS 50+", "receta": False,
        "ya": False, "foto_file": None,
    },
    {
        "ean": "7506267905186",
        "sku": "FC-67905186",
        "snap": "JBN BLUMEN JL CP",
        "nombre": "Blumen jabón líquido Coconut 221 ml",
        "qty": 2, "pu": 17.69, "sub": 35.38, "lote": None,
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Higiene", "forma": "Jabón líquido",
        "marca": "Blumen", "laboratorio": None,
        "presentacion": "Botella 221 ml",
        "principio": None, "concentracion": None, "receta": False,
        "ya": True, "foto_file": "blumen-coconut-221ml.jpg",
    },
    {
        "ean": "7501001116187",
        "sku": sku_de("7501001116187"),
        "snap": "VICK 44 JBE 120M",
        "nombre": "Vick 44 jarabe todo tipo de tos 120 ml",
        "qty": 1, "pu": 115.98, "sub": 115.98, "lote": "60984354B0",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Respiratorio", "forma": "Jarabe",
        "marca": "Vick", "laboratorio": "P&G",
        "presentacion": "Frasco 120 ml",
        "principio": "Guaifenesina / dextrometorfano",
        "concentracion": "1.33 g / 0.133 g / 100 ml", "receta": False,
        "ya": False, "foto_file": "vick-44-jarabe-120ml.jpg",
    },
    {
        "ean": "7503002163610",
        "sku": sku_de("7503002163610"),
        "snap": "XTREME GEL ATTRA",
        "nombre": "Xtreme gel Attraction hombre 250 g",
        "qty": 3, "pu": 23.94, "sub": 71.82, "lote": "K72185L419",
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Cabello", "forma": "Gel",
        "marca": "Xtreme", "laboratorio": None,
        "presentacion": "Envase 250 g",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "xtreme-gel-attraction-250g.jpg",
    },
    {
        "ean": "070942306805",
        "sku": sku_de("070942306805"),
        "snap": "PALILLOS GUM C/HIL",
        "nombre": "Palillos GUM con hilo dental C/20",
        "qty": 1, "pu": 24.83, "sub": 24.83, "lote": None,
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Higiene bucal", "forma": "Hilo dental",
        "marca": "GUM", "laboratorio": "Sunstar",
        "presentacion": "Caja con 20",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "palillos-gum-hilo-c20.jpg",
    },
    {
        "ean": "7501065053121",
        "sku": sku_de("7501065053121"),
        "snap": "EMULSION DE SCOT",
        "nombre": "Emulsión de Scott naranja 200 ml",
        "qty": 1, "pu": 91.97, "sub": 91.97, "lote": "6U26",
        "tipo": "marca", "categoria": "Vitaminas",
        "subcategoria": "Suplemento", "forma": "Emulsión",
        "marca": "Scott", "laboratorio": "GSK",
        "presentacion": "Frasco 200 ml",
        "principio": "Vitamina A / D / calcio / fósforo",
        "concentracion": None, "receta": False,
        "ya": False, "foto_file": "emulsion-scott-naranja-200ml.jpg",
    },
    {
        "ean": "7501001116200",
        "sku": sku_de("7501001116200"),
        "snap": "VICK 44 EXP JBE",
        "nombre": "Vick 44 Exp Infantil jarabe 120 ml",
        "qty": 1, "pu": 115.98, "sub": 115.98, "lote": "60834354B1",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Respiratorio", "forma": "Jarabe",
        "marca": "Vick", "laboratorio": "P&G",
        "presentacion": "Frasco 120 ml",
        "principio": "Guaifenesina",
        "concentracion": "1.33 g / 100 ml", "receta": False,
        "ya": False, "foto_file": "vick-44-exp-infantil-120ml.jpg",
    },
    {
        "ean": "7501070613006",
        "sku": sku_de("7501070613006"),
        "snap": "ANDANTOL 4MG C/2",
        "nombre": "Andantol isotipendilo 4 mg C/20",
        "qty": 1, "pu": 162.98, "sub": 162.98, "lote": "170BD005V",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Alergia", "forma": "Tableta",
        "marca": "Andantol", "laboratorio": "Sanfer",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Isotipendilo", "concentracion": "4 mg", "receta": False,
        "ya": False, "foto_file": "andantol-4mg-c20.jpg",
    },
    {
        "ean": "7702031244493",
        "sku": sku_de("7702031244493"),
        "snap": "CRA LUBRIDERM P/",
        "nombre": "Lubriderm Humectación Diaria piel normal 200 ml",
        "qty": 1, "pu": 49.98, "sub": 49.98, "lote": None,
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Piel", "forma": "Crema",
        "marca": "Lubriderm", "laboratorio": "Kenvue",
        "presentacion": "Frasco 200 ml",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "lubriderm-humectacion-diaria-200ml.jpg",
    },
    {
        "ean": "7506339394733",
        "sku": sku_de("7506339394733"),
        "snap": "FIXODENT PLUS 35",
        "nombre": "Fixodent Plus adhesivo dental 35 g",
        "qty": 1, "pu": 91.97, "sub": 91.97, "lote": "6044028890",
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Higiene bucal", "forma": "Adhesivo",
        "marca": "Fixodent", "laboratorio": "P&G",
        "presentacion": "Tubo 35 g",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "fixodent-plus-35g.jpg",
    },
    {
        "ean": "5000174003963",
        "sku": sku_de("5000174003963"),
        "snap": "FIXODENT FRESH 4",
        "nombre": "Fixodent Fresh adhesivo dental 40 g",
        "qty": 1, "pu": 101.95, "sub": 101.95, "lote": "6054028890",
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Higiene bucal", "forma": "Adhesivo",
        "marca": "Fixodent", "laboratorio": "P&G",
        "presentacion": "Tubo 40 g",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "fixodent-fresh-40g.jpg",
    },
    {
        "ean": "7509552844160",
        "sku": sku_de("7509552844160"),
        "snap": "AC. FRUCTIS HAIR",
        "nombre": "Garnier Fructis Hair Food Banana acondicionador 300 ml",
        "qty": 1, "pu": 57.98, "sub": 57.98, "lote": None,
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Cabello", "forma": "Acondicionador",
        "marca": "Garnier Fructis", "laboratorio": "L'Oréal",
        "presentacion": "Frasco 300 ml",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "fructis-hair-food-banana-300ml.jpg",
    },
    {
        "ean": "7506306247468",
        "sku": "FC-06247468",
        "snap": "GEL EGO FRESH 20",
        "nombre": "Gel Ego Fresh 200 g",
        "qty": 2, "pu": 19.98, "sub": 39.96, "lote": "010528",
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Cabello", "forma": "Gel",
        "marca": "Ego", "laboratorio": None,
        "presentacion": "Envase 200 g",
        "principio": None, "concentracion": None, "receta": False,
        "ya": True, "foto_file": None,
    },
    {
        "ean": "7501417006133",
        "sku": sku_de("7501417006133"),
        "snap": "PASTA DE LASSAR",
        "nombre": "Pasta de Lassar óxido de zinc 145 g",
        "qty": 1, "pu": 44.94, "sub": 44.94, "lote": "LAS050125",
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Piel", "forma": "Pasta",
        "marca": "Pasta de Lassar", "laboratorio": None,
        "presentacion": "Tarro 145 g",
        "principio": "Óxido de zinc", "concentracion": None, "receta": False,
        "ya": False, "foto_file": "pasta-de-lassar-145g.jpg",
    },
    {
        "ean": "7501008409541",
        "sku": "FC-84095411",
        "snap": "SARIDON C/20 COM",
        "nombre": "Saridon C/20 tabletas",
        "qty": 1, "pu": 58.99, "sub": 58.99, "lote": "X26VD7",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Dolor", "forma": "Tableta",
        "marca": "Saridon", "laboratorio": "Bayer",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Paracetamol / propyfenazona / cafeína",
        "concentracion": None, "receta": False,
        "ya": True, "foto_file": "saridon-c20.jpg",
    },
    {
        "ean": "7506192506120",
        "sku": sku_de("7506192506120"),
        "snap": "SH SAVILE COLAGE",
        "nombre": "Savilé shampoo Colágeno control caída 180 ml",
        "qty": 1, "pu": 15.89, "sub": 15.89, "lote": "20260880",
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Cabello", "forma": "Shampoo",
        "marca": "Savilé", "laboratorio": None,
        "presentacion": "Frasco 180 ml",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "savile-colageno-180ml.jpg",
    },
    {
        "ean": "7506306254503",
        "sku": sku_de("7506306254503"),
        "snap": "SH SAVILE CELULA",
        "nombre": "Savilé shampoo Células Madre 180 ml",
        "qty": 1, "pu": 15.89, "sub": 15.89, "lote": "2026008",
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Cabello", "forma": "Shampoo",
        "marca": "Savilé", "laboratorio": None,
        "presentacion": "Frasco 180 ml",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": None,
    },
    {
        "ean": "7509552844184",
        "sku": sku_de("7509552844184"),
        "snap": "AC. FRUCTIS HAIR",
        "nombre": "Garnier Fructis Hair Food Aloe Vera acondicionador 300 ml",
        "qty": 1, "pu": 57.98, "sub": 57.98, "lote": None,
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Cabello", "forma": "Acondicionador",
        "marca": "Garnier Fructis", "laboratorio": "L'Oréal",
        "presentacion": "Frasco 300 ml",
        "principio": None, "concentracion": None, "receta": False,
        "ya": False, "foto_file": "fructis-hair-food-aloe-300ml.jpg",
    },
    {
        "ean": "7501072300164",
        "sku": sku_de("7501072300164"),
        "snap": "TING POLVO 45G",
        "nombre": "Ting polvo 45 g",
        "qty": 1, "pu": 69.95, "sub": 69.95, "lote": "378028",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Dermatología", "forma": "Polvo",
        "marca": "Ting", "laboratorio": "Hormona",
        "presentacion": "Bote 45 g",
        "principio": "Ácido undecilénico / undecilenato de zinc",
        "concentracion": None, "receta": False,
        "ya": False, "foto_file": "ting-polvo-45g.jpg",
    },
    {
        "ean": "7702031244486",
        "sku": "FC-31244486",
        "snap": "CRA LUBRIDERM P/",
        "nombre": "Lubriderm crema piel normal 120 ml",
        "qty": 1, "pu": 29.98, "sub": 29.98, "lote": None,
        "tipo": "marca", "categoria": "Cuidado personal",
        "subcategoria": "Piel", "forma": "Crema",
        "marca": "Lubriderm", "laboratorio": "Kenvue",
        "presentacion": "Frasco 120 ml",
        "principio": None, "concentracion": None, "receta": False,
        "ya": True, "foto_file": "lubriderm-piel-normal-120ml.jpg",
    },
]


def enrich(row: dict) -> dict:
    url, file = foto(row.get("foto_file"))
    row = dict(row)
    row["foto"] = url
    row["foto_rel"] = file
    row["precio"] = ceil_pvp(row["pu"])
    return row


def ticket_rows() -> list[dict]:
    out = []
    for r in ROWS:
        out.append({
            "ean": r["ean"],
            "sku": r["sku"],
            "nombre": r["snap"],
            "qty": r["qty"],
            "pu": r["pu"],
            "sub": r["sub"],
            "match": "catalogo" if r["ya"] else "ficha",
            "lote": r.get("lote") or "",
        })
    return out


def write_csv(path: Path, rows: list) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean",
            "descripcion_ticket", "nombre_mostrador", "cantidad",
            "precio_unitario", "subtotal", "lote", "caducidad",
            "sku_farmacapital", "total_ticket", "match",
        ])
        for i, r in enumerate(ROWS, start=1):
            w.writerow([
                i, FOLIO, FECHA, PROVEEDOR, r["ean"],
                r["snap"], r["nombre"], r["qty"],
                f"{r['pu']:.2f}", f"{r['sub']:.2f}",
                r.get("lote") or "", "",
                r["sku"], f"{TOTAL_TICKET:.2f}",
                "catalogo" if r["ya"] else "ficha",
            ])


def write_sql(path: Path) -> None:
    enriched = [enrich(r) for r in ROWS]
    vals = []
    for i, r in enumerate(enriched, start=1):
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo}, {precio}, "
            "{tipo}, {cat}, {subcat}, {forma}, {marca}, {lab}, {pres}, {pa}, {conc}, "
            "{receta}, {ya}, {foto}, {foto_file}, {lote})".format(
                linea=i,
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                qty=int(r["qty"]),
                costo=f"{r['pu']:.2f}",
                precio=r["precio"],
                tipo=sql_str(r["tipo"]),
                cat=sql_str(r["categoria"]),
                subcat=sql_str(r["subcategoria"]),
                forma=sql_str(r["forma"]),
                marca=sql_str(r["marca"]),
                lab=sql_str(r["laboratorio"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"]),
                conc=sql_str(r["concentracion"]),
                receta="true" if r["receta"] else "false",
                ya="true" if r["ya"] else "false",
                foto=sql_str(r["foto"]),
                foto_file=sql_str(r["foto_rel"]),
                lote=sql_str(r.get("lote")),
            )
        )
    eans = [sql_str(r["ean"]) for r in enriched]
    altas = sum(1 for r in enriched if not r["ya"])
    ya = sum(1 for r in enriched if r["ya"])
    sin_foto = [r["ean"] for r in enriched if not r["foto"] and not r["ya"]]
    body = f"""-- Farma Mayoreo · ID VENTA {FOLIO} · {FECHA} 12:51 · caja 3 · Alfred L. S.
-- RFC FMA180119D55 · sucursal FARMAMAYOREO CENTRAL (Canal de Apatlaco, CEDA).
-- Pago tarjeta. SUBTOTAL $1,725.16 + IVA $118.00 = TOTAL $1,843.16.
-- Los P.U. ya traen IVA (suma de renglones = total). 27 renglones / 33 pzas.
-- {altas} altas stock 0. {ya} ya estaban: solo costo, no PVP.
-- Fichas de Fahorro / marca / Open Beauty Facts, no el recorte del térmico.
-- Lote de fábrica sí (si no se repite en el renglón de abajo). Caducidad NO:
-- Recibir pide MMAA de la caja. 0000 es inválido.
-- Ting 45 g: el papel dice FecCad 30-04-2026 (vencido el día de la compra).
-- Afrin Adulto del ticket es EAN 7501004100435; el del catálogo 7501050613453
-- no se junta. Palillos GUM se guardan 070942306805 (el ticket recorta el 0).
-- Foto TODO (alta sin packshot en repo): {", ".join(sin_foto) or "ninguna"}.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fm303033 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_fm303033 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
{chr(10).join(v + ("," if i < len(vals) - 1 else ";") for i, v in enumerate(vals))}

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-FM-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farma Mayoreo {FOLIO} · {FECHA} · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from _fc_fm303033 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo de este ticket. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_fm303033 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_fm303033 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Saridon C/20: el nombre corto / 120 tabletas choca con esta presentación.
update public.productos p
set nombre = t.nombre,
    presentacion = t.presentacion,
    forma_farmaceutica = t.forma,
    categoria = t.categoria
from _fc_fm303033 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7501008409541'
  and (
    p.nombre ~* '^saridon$'
    or p.nombre ~* '120'
    or coalesce(p.presentacion, '') ~* '120'
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL_TICKET:.2f},
  'borrador',
  {sql_str("Ticket Farma Mayoreo 303033 · 05-sep-2026 · CEDA · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja")}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%farma mayoreo%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str("Ticket Farma Mayoreo 303033 · 05-sep-2026 · CEDA · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja")},
  updated_at = now()
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%farma mayoreo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
  t.nombre,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_fm303033 t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from _fc_fm303033 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
order by i.id;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 52) as nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
{chr(10).join("  " + e + ("," if i < len(eans) - 1 else "") for i, e in enumerate(eans))}
)
order by p.nombre;
"""
    path.write_text(body, encoding="utf-8")


if __name__ == "__main__":
    assert len(ROWS) == 27, len(ROWS)
    skus = [x["sku"] for x in ROWS]
    assert len(skus) == len(set(skus)), skus
    eans = [x["ean"] for x in ROWS]
    assert len(eans) == len(set(eans)), eans
    suma = sum(x["sub"] for x in ROWS)
    assert abs(suma - TOTAL_TICKET) < 0.02, (suma, TOTAL_TICKET)
    for x in ROWS:
        assert abs(x["pu"] * x["qty"] - x["sub"]) < 0.03, x
        assert not x["nombre"].isupper() or len(x["nombre"]) < 8, x["nombre"]
        assert "JBN" not in x["nombre"] and "BLOQ" not in x["nombre"]

    write_csv(OUT_TICKET, ROWS)
    write_sql(OUT_SQL)
    r = ticket_rows()
    print(f"csv  {OUT_TICKET}")
    print(f"sql  {OUT_SQL}")
    print(report(r, TOTAL_TICKET))
    print("altas", sum(1 for x in ROWS if not x["ya"]), "ya_catalogo", sum(1 for x in ROWS if x["ya"]))
    for x in [enrich(r) for r in ROWS]:
        foto_ok = "foto" if x["foto"] else "SIN FOTO"
        print(
            f"  {x['ean']}  {x['qty']}×{x['pu']:.2f}  "
            f"{'ya' if x['ya'] else 'ALTA'}  {foto_ok}  {x['nombre']}"
        )
