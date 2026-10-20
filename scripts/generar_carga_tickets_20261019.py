#!/usr/bin/env python3
"""Tickets 19-oct-2026 (fotos) → cola Recibir.

6 pedidos:
  Cityfarma S333074 · Sahuayo 428641 · Equilibrio 448644
  Farmalive 14814 · Nadro 6091278111 · Nadro 6091329944

Nombres de mostrador desde ficha (no el código del ticket).
Sin caducidad inventada (MMAA de la caja). Equilibrio sí trae lote de fábrica.
Farmalive: costo = P.U. neto después del descuento del renglón.
Cityfarma: P.U. como en ticket (nebulizador Omron incluye IVA 16% → total líneas $2,545.99).
Nadro 6091329944: Tena con IVA 16% en el costo unitario (Pants $117.47 · Predoblado $88.01)
para que la suma coincida con total factura $1,615.56.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import (  # noqa: E402
    ceil_pvp,
    foto_url,
    report,
    sku_de,
    sql_str,
    write_carga_sql,
)
from generar_recepcion_borrador import write_ticket_csv  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"


def p(
    ean: str,
    *,
    nombre: str,
    tipo: str = "generico",
    categoria: str = "Medicamentos",
    subcategoria: str | None = None,
    forma: str | None = None,
    marca: str | None = None,
    laboratorio: str | None = None,
    presentacion: str | None = None,
    principio: str | None = None,
    concentracion: str | None = None,
    receta: bool = False,
    ya: bool = False,
    sku: str | None = None,
    foto_file: str | None = None,
) -> dict:
    return {
        "sku": sku or sku_de(ean),
        "nombre": nombre,
        "tipo": tipo,
        "categoria": categoria,
        "subcategoria": subcategoria,
        "forma": forma,
        "marca": marca,
        "laboratorio": laboratorio,
        "presentacion": presentacion,
        "principio": principio,
        "concentracion": concentracion,
        "receta": receta,
        "ya": ya,
        "foto": foto_url(foto_file) if foto_file else None,
        "foto_file": f"catalogo-propia/{foto_file}" if foto_file else None,
    }


PRODUCTOS: dict[str, dict] = {
    # ── Cityfarma ──
    "7501089809490": p(
        "7501089809490",
        nombre="Eskapar nifuroxazida 200 mg",
        tipo="marca",
        categoria="Gastro",
        subcategoria="Antidiarreico",
        forma="Cápsula",
        marca="Eskapar",
        laboratorio="Armstrong",
        presentacion="Caja con 16 cápsulas",
        principio="Nifuroxazida",
        concentracion="200 mg",
        receta=False,
        ya=False,
    ),
    "7501089809445": p(
        "7501089809445",
        nombre="Eskapar Compuesto",
        tipo="marca",
        categoria="Gastro",
        subcategoria="Antidiarreico",
        forma="Cápsula",
        marca="Eskapar",
        laboratorio="Armstrong",
        presentacion="Caja con 20 cápsulas",
        principio="Nifuroxazida / atropina / homatropina",
        ya=False,
    ),
    "7502216805798": p(
        "7502216805798",
        nombre="Espironolactona 25 mg",
        tipo="generico",
        forma="Tableta",
        marca=None,
        laboratorio=None,
        presentacion="Caja con tabletas",
        principio="Espironolactona",
        concentracion="25 mg",
        receta=True,
        ya=False,
    ),
    "7501563381160": p(
        "7501563381160",
        nombre="Espironolactona 25 mg",
        tipo="generico",
        forma="Tableta",
        marca="Randall",
        laboratorio="Randall",
        presentacion="Caja con tabletas",
        principio="Espironolactona",
        concentracion="25 mg",
        receta=True,
        ya=False,
    ),
    "073796803216": p(
        "073796803216",
        sku="FC-96803216",
        nombre="Nebulizador de compresor Omron Elite NE-C803",
        tipo="marca",
        categoria="Dispositivo médico",
        subcategoria="Respiratorio",
        forma="Aparato",
        marca="Omron",
        laboratorio="Omron",
        presentacion="1 pieza",
        ya=True,
        foto_file="nebulizador-de-compresor-omron-elite-ne-c803-100-073796803216.jpg",
    ),
    "7501088505126": p(
        "7501088505126",
        sku="FC-8505126",
        nombre="Neuralin solución inyectable",
        tipo="marca",
        forma="Ampolleta",
        marca="Neuralin",
        laboratorio="Chinoin",
        presentacion="Caja con 1 ampolleta",
        principio="Tiamina / piridoxina / cianocobalamina",
        concentracion="200 mg/100 mg/5 mg",
        receta=True,
        ya=True,
    ),
    "7501258207010": p(
        "7501258207010",
        sku="FC-58207010",
        nombre="Oxital-C 2 g",
        tipo="marca",
        forma="Tableta efervescente",
        marca="Oxital-C",
        laboratorio="Serral",
        presentacion="Tubo con 10 tabletas",
        principio="Ácido ascórbico",
        concentracion="2 g",
        ya=True,
    ),
    "8020030091252": p(
        "8020030091252",
        sku="FC-30091252",
        nombre="Vessel Due-F sulodexida 250 LRU",
        tipo="generico",
        forma="Cápsula",
        marca="Vessel Due-F",
        laboratorio="AlfaSigma",
        presentacion="Caja con 50 cápsulas",
        principio="Sulodexida",
        concentracion="250 LRU",
        receta=True,
        ya=True,
    ),
    "7502223553477": p(
        "7502223553477",
        nombre="Zolufen fluoxetina 20 mg",
        tipo="generico",
        forma="Cápsula",
        marca="Zolufen",
        laboratorio=None,
        presentacion="Caja con 30 cápsulas",
        principio="Fluoxetina",
        concentracion="20 mg",
        receta=True,
        ya=False,
    ),
    # ── Sahuayo ──
    "7501082730258": p(
        "7501082730258",
        nombre="Nuvel Aclarado Ideal roll-on",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Desodorante",
        forma="Roll-on",
        marca="Nuvel",
        laboratorio="Nuvel",
        presentacion="Frasco 50 mL",
        ya=False,
    ),
    # ── Equilibrio ──
    "7502211780359": p(
        "7502211780359",
        sku="FC-11780359",
        nombre="Aflusil ibuprofeno suspensión",
        tipo="generico",
        forma="Suspensión",
        marca="Aflusil",
        laboratorio="Loeffler",
        presentacion="Frasco 120 mL",
        principio="Ibuprofeno",
        concentracion="2 g/120 mL",
        ya=True,
    ),
    "0780083141929": p(
        "0780083141929",
        sku="FC-83141929",
        nombre="Dolprin ibuprofeno suspensión",
        tipo="generico",
        forma="Suspensión",
        marca="Dolprin",
        laboratorio="Collins",
        presentacion="Frasco 120 mL",
        principio="Ibuprofeno",
        concentracion="100 mg/5 mL",
        ya=True,
    ),
    "7502009740206": p(
        "7502009740206",
        sku="FC-6519183A",
        nombre="Clamoxin amoxicilina/clavulanato suspensión",
        tipo="generico",
        forma="Suspensión",
        marca="Clamoxin",
        laboratorio="Maver",
        presentacion="Frasco 60 mL",
        principio="Amoxicilina / ácido clavulánico",
        concentracion="125/31.25 mg/5 mL",
        receta=True,
        ya=True,
    ),
    "7501258207010_eq": None,  # placeholder removed below
    "7501349025844": p(
        "7501349025844",
        sku="EQ-AMS237",
        nombre="Telmisartán 40 mg",
        tipo="generico",
        forma="Tableta",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 28 tabletas",
        principio="Telmisartán",
        concentracion="40 mg",
        receta=True,
        ya=True,
    ),
    "7501258206723": p(
        "7501258206723",
        sku="EQ-SER093",
        nombre="Oxital-C 1 g",
        tipo="generico",
        forma="Tableta efervescente",
        marca="Oxital-C",
        laboratorio="Serral",
        presentacion="Tubo con 10 tabletas",
        principio="Ácido ascórbico",
        concentracion="1 g",
        ya=True,
    ),
    "7501349022119": p(
        "7501349022119",
        sku="FC-49022119",
        nombre="Ácido ascórbico 1 g/10 mL",
        tipo="generico",
        forma="Solución inyectable",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 6 ampolletas",
        principio="Ácido ascórbico",
        concentracion="1 g/10 mL",
        ya=False,
    ),
    "7502216805446": p(
        "7502216805446",
        sku="EQ-AMS365",
        nombre="Zolmitriptano 2.5 mg",
        tipo="generico",
        forma="Tableta dispersable",
        marca="AMSA",
        laboratorio="Ultra / AMSA",
        presentacion="Caja con 2 tabletas",
        principio="Zolmitriptano",
        concentracion="2.5 mg",
        receta=True,
        ya=False,
    ),
    # ── Farmalive ──
    "7506306234062": p(
        "7506306234062",
        sku="FC-06234062",
        nombre="Sedal Anti Nudos crema para peinar",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Crema",
        marca="Sedal",
        laboratorio="Unilever",
        presentacion="Frasco 300 mL",
        ya=True,
    ),
    "7501008491003": p(
        "7501008491003",
        nombre="Desenfriol D tabletas 2-pack",
        tipo="marca",
        categoria="Respiratorio",
        forma="Tableta",
        marca="Desenfriol",
        laboratorio="Bayer",
        presentacion="2 cajas con 30 tabletas",
        principio="Clorfenamina / fenilefrina / paracetamol",
        ya=False,
    ),
    "7501001168889": p(
        "7501001168889",
        nombre="Vick Pyrena sobres 8+2",
        tipo="marca",
        categoria="Respiratorio",
        forma="Sobre",
        marca="Vick Pyrena",
        laboratorio="P&G",
        presentacion="Caja con 8+2 sobres",
        principio="Paracetamol / fenilefrina",
        ya=False,
    ),
    "7501022105207": p(
        "7501022105207",
        sku="FC-22105207",
        nombre="Jabón Grisi Neutro",
        tipo="marca",
        categoria="Higiene",
        forma="Jabón",
        marca="Grisi",
        laboratorio="Grisi",
        presentacion="Barra 150 g",
        ya=True,
    ),
    "650240053610": p(
        "650240053610",
        sku="FC-053610",
        nombre="Alli-Triple",
        tipo="marca",
        forma="Tableta",
        marca="Alli-Triple",
        laboratorio="Genomma Lab",
        presentacion="Caja con 10 tabletas",
        principio="Naproxeno sódico",
        ya=True,
    ),
    "7506339394719": p(
        "7506339394719",
        nombre="Naturella Nocturno con alas",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene femenina",
        forma="Toalla",
        marca="Naturella",
        laboratorio="P&G",
        presentacion="Paquete con 8 toallas",
        ya=False,
    ),
    "7590002046234": p(
        "7590002046234",
        nombre="Naturella pantiprotectores manzanilla",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene femenina",
        forma="Pantiprotector",
        marca="Naturella",
        laboratorio="P&G",
        presentacion="Paquete con 40",
        ya=False,
    ),
    "7506309895208": p(
        "7506309895208",
        nombre="Naturella manzanilla regular con alas",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene femenina",
        forma="Toalla",
        marca="Naturella",
        laboratorio="P&G",
        presentacion="Paquete con 8 toallas",
        ya=False,
    ),
    "7506552900322": p(
        "7506552900322",
        sku="FC-29003221",
        nombre="Vaso recolector Quirmex",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Vaso",
        marca="Quirmex",
        laboratorio="Quirmex",
        presentacion="1 pieza 120 mL",
        ya=True,
    ),
    "7501008499795": p(
        "7501008499795",
        sku="FC-08499795",
        nombre="Afrin No Drip Niños",
        tipo="marca",
        categoria="Respiratorio",
        forma="Spray nasal",
        marca="Afrin",
        laboratorio="Bayer",
        presentacion="Frasco 15 mL",
        principio="Oximetazolina",
        ya=True,
    ),
    "650240080159": p(
        "650240080159",
        nombre="Suerox Mineral mora azul",
        tipo="marca",
        categoria="Bebidas",
        subcategoria="Electrolitos",
        forma="Bebida",
        marca="Suerox",
        laboratorio="Genomma Lab",
        presentacion="Botella 355 mL",
        ya=False,
    ),
    "7503003406754": p(
        "7503003406754",
        nombre="Venda Quirmex 15 cm",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Venda",
        marca="Quirmex",
        laboratorio="Quirmex",
        presentacion="Rollo 15 cm",
        ya=False,
    ),
    "7501868902404": p(
        "7501868902404",
        nombre="Venda Dibar 20 cm",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Venda",
        marca="Dibar",
        laboratorio="Dibar",
        presentacion="Rollo 20 cm",
        ya=False,
    ),
    "7501019032424": p(
        "7501019032424",
        sku="FC-19032424",
        nombre="Tampones Saba Super",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene femenina",
        forma="Tampón",
        marca="Saba",
        laboratorio="Essity",
        presentacion="Caja con 10",
        ya=True,
    ),
    "7502214982811": p(
        "7502214982811",
        nombre="Condones Prudence surtido",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Salud sexual",
        forma="Condón",
        marca="Prudence",
        laboratorio="DKT México",
        presentacion="Caja con 5",
        ya=False,
    ),
    "6502400315191": p(
        "6502400315191",
        nombre="Tukol-D 0% azúcar jarabe adulto",
        tipo="marca",
        categoria="Respiratorio",
        forma="Jarabe",
        marca="Tukol-D",
        laboratorio="Genomma Lab",
        presentacion="Frasco 120 mL",
        principio="Guaifenesina / dextrometorfano",
        ya=False,
    ),
    "6502400107128": p(
        "6502400107128",
        sku="FC-40010712",
        nombre="Tukol-D jarabe adulto",
        tipo="marca",
        categoria="Respiratorio",
        forma="Jarabe",
        marca="Tukol-D",
        laboratorio="Genomma Lab",
        presentacion="Frasco 125 mL",
        principio="Guaifenesina / dextrometorfano",
        ya=True,
    ),
    # ── Nadro LGEN ──
    "7502009745352": p(
        "7502009745352",
        nombre="Dexal ceftibuteno 400 mg",
        tipo="generico",
        forma="Cápsula",
        marca="Dexal",
        laboratorio="Maver",
        presentacion="Caja con 5 cápsulas",
        principio="Ceftibuteno",
        concentracion="400 mg",
        receta=True,
        ya=False,
    ),
    "7503049078291": p(
        "7503049078291",
        nombre="Dexlansoprazol 60 mg",
        tipo="generico",
        forma="Cápsula",
        marca=None,
        laboratorio="Avivia",
        presentacion="Caja con 7 cápsulas",
        principio="Dexlansoprazol",
        concentracion="60 mg",
        receta=True,
        ya=False,
    ),
    "7502231321709": p(
        "7502231321709",
        nombre="Dorzolamida 20 mg/mL solución oftálmica",
        tipo="generico",
        forma="Solución oftálmica",
        marca=None,
        laboratorio="Microgrp",
        presentacion="Frasco gotero",
        principio="Dorzolamida",
        concentracion="20 mg/mL",
        receta=True,
        ya=False,
    ),
    "7506513601053": p(
        "7506513601053",
        nombre="Fosfomicina polvo para solución 3 g",
        tipo="generico",
        forma="Polvo",
        marca=None,
        laboratorio="Avivia",
        presentacion="Sobre 3 g",
        principio="Fosfomicina trometamol",
        concentracion="3 g",
        receta=True,
        ya=False,
    ),
    "7506513601039": p(
        "7506513601039",
        nombre="Fosfomicina suspensión 120 mL",
        tipo="generico",
        forma="Suspensión",
        marca=None,
        laboratorio="Avivia",
        presentacion="Frasco 120 mL",
        principio="Fosfomicina",
        receta=True,
        ya=False,
    ),
    "7501349025387": p(
        "7501349025387",
        nombre="Gentamicina 80 mg/2 mL",
        tipo="generico",
        forma="Solución inyectable",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 5 ampolletas",
        principio="Gentamicina",
        concentracion="80 mg/2 mL",
        receta=True,
        ya=False,
    ),
    "7506449300372": p(
        "7506449300372",
        nombre="Guaifenesina/oxeladina jarabe",
        tipo="generico",
        forma="Jarabe",
        marca=None,
        laboratorio="ADN Pharma",
        presentacion="Frasco 140 mL",
        principio="Guaifenesina / oxeladina",
        concentracion="2 g/1 g",
        ya=False,
    ),
    "7501075727159": p(
        "7501075727159",
        nombre="Moxifloxacino 400 mg",
        tipo="generico",
        forma="Tableta",
        marca=None,
        laboratorio="Novag",
        presentacion="Caja con 7 tabletas",
        principio="Moxifloxacino",
        concentracion="400 mg",
        receta=True,
        ya=False,
    ),
    "75049612": p(
        "75049612",
        nombre="Timolol 0.50% solución oftálmica",
        tipo="generico",
        forma="Solución oftálmica",
        marca="Exakta",
        laboratorio="Exakta",
        presentacion="Frasco gotero 5 mL",
        principio="Timolol",
        concentracion="0.50%",
        receta=True,
        ya=False,
    ),
    # ── Nadro 6091329944 ──
    "7501088509773": p(
        "7501088509773",
        sku="FC-8509773",
        nombre="Antiflu-Des",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Antigripal",
        forma="Cápsula",
        marca="Antiflu-Des",
        laboratorio="Chinoin",
        presentacion="Caja con 24 cápsulas",
        principio="Amantadina / clorfenamina / paracetamol",
        ya=True,
    ),
    "7501088509766": p(
        "7501088509766",
        sku="FC-8509766",
        nombre="Antiflu-Des Junior",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Antigripal",
        forma="Solución",
        marca="Antiflu-Des",
        laboratorio="Chinoin",
        presentacion="Frasco 60 mL",
        principio="Amantadina / clorfenamina / paracetamol",
        ya=False,
    ),
    "7501019064807": p(
        "7501019064807",
        sku="FC-19064807",
        nombre="Tena Pants Comfort grande",
        tipo="marca",
        categoria="Higiene",
        subcategoria="Incontinencia",
        forma="Pants",
        marca="Tena",
        laboratorio="Essity",
        presentacion="Bolsa con 13 pants talla grande",
        ya=False,
    ),
    "7501065060891": p(
        "7501065060891",
        sku="FC-65060891",
        nombre="Contac Ultra",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Antigripal",
        forma="Tableta",
        marca="Contac",
        laboratorio="Haleon",
        presentacion="Caja con 12 tabletas",
        principio="Paracetamol / fenilefrina / clorfenamina",
        ya=True,
    ),
    "7506442701039": p(
        "7506442701039",
        nombre="Lacosamida 100 mg",
        tipo="generico",
        forma="Tableta",
        marca=None,
        laboratorio=None,
        presentacion="Caja con 28 tabletas",
        principio="Lacosamida",
        concentracion="100 mg",
        receta=True,
        ya=False,
    ),
    "7501019051401": p(
        "7501019051401",
        sku="FC-19051401",
        nombre="Tena pañal predoblado unitario",
        tipo="marca",
        categoria="Higiene",
        subcategoria="Incontinencia",
        forma="Pañal",
        marca="Tena",
        laboratorio="Essity",
        presentacion="Bolsa con 10 piezas",
        ya=False,
    ),
}

def row(ean: str, snap: str, qty: int, pu: float, lote: str | None = None) -> dict:
    prod = PRODUCTOS[ean]
    sub = round(qty * pu, 2)
    return {
        "ean": ean,
        "sku": prod["sku"],
        "snap": snap,
        "nombre": prod["nombre"],
        "qty": qty,
        "pu": pu,
        "sub": sub,
        "lote": lote,
        **{
            k: prod[k]
            for k in (
                "tipo",
                "categoria",
                "subcategoria",
                "forma",
                "marca",
                "laboratorio",
                "presentacion",
                "principio",
                "concentracion",
                "receta",
                "ya",
                "foto",
                "foto_file",
            )
        },
        "precio": ceil_pvp(pu, prod["tipo"]),
        "match": "ya" if prod["ya"] else "alta",
    }


TICKETS = [
    {
        "key": "cityfarma_s333074",
        "folio": "S333074",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-10-19",
        "total": 2545.99,
        "notas": (
            "Ticket Cityfarma S333074 · 19-oct-2026 17:15 · foto térmica · "
            "surtido sin certificar · total líneas $2,545.99 (subtotal $2,465.99 + IVA 16% $80 "
            "del nebulizador Omron) · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_cf_s333074",
        "header": (
            "Cityfarma Iztapalapa · orden S333074 · 2026-10-19 17:15\n"
            "-- Ticket térmico. Subtotal $2,465.99 · IVA 16% $80 · total líneas $2,545.99.\n"
            "-- Nebulizador Omron EAN 073796803216 (ya en catálogo).\n"
            "-- Vessel Due-F / Neuralin / Oxital-C ya. Eskapar y Zolufen alta.\n"
            "-- Sin caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7501089809490", "ESKAPAR 200 MG C 16", 2, 114.61, "25070018"),
            row("7501089809445", "ESKAPAR COMP C 20 20", 2, 197.83, "26020038"),
            row("7502216805798", "ESPIRONOLACTONA 25 M", 1, 48.33, "6GM269A"),
            row("7501563381160", "ESPIRONOLACTONA 25MG", 5, 26.99, "30600"),
            row("073796803216", "NEBULIZADOR DE COMPR", 1, 580.00, "202402LF"),
            row("7501088505126", "NEURALIN C 1 AMP", 3, 146.31, "BFF042"),
            row("7501258207010", "OXITAL C 2G AC ASCOR", 1, 63.50, "260548"),
            row("8020030091252", "VESSEL DUE F 250 CAP", 1, 576.00, "31440"),
            row("7502223553477", "ZOLUFEN 20MG CAP C30", 5, 15.88, "Z26013A"),
        ],
    },
    {
        "key": "sahuayo_428641",
        "folio": "428641",
        "proveedor": "Sahuayo",
        "proveedor_ilike": "sahuayo",
        "fecha": "2026-10-19",
        "total": 43.30,
        "notas": (
            "Ticket Sahuayo 428641 · Central de Abastos · 19-oct-2026 04:35 · "
            "Nuvel Aclarado Ideal roll-on 50 mL ×2 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_sh_428641",
        "header": (
            "Sahuayo · ticket 428641 · 2026-10-19 04:35 · Central de Abastos Iztapalapa\n"
            "-- 2 pzas · total $43.30 (IVA incluido).\n"
            "-- PZA NUVEL D.A AC.IDEAL 50M → roll-on Aclarado Ideal 50 mL EAN 7501082730258.\n"
            "-- Sin lote ni caducidad. No inventar 0000."
        ),
        "rows": [
            row(
                "7501082730258",
                "PZA NUVEL D.A AC.IDEAL 50M 1/50",
                2,
                21.65,
            ),
        ],
    },
    {
        "key": "equilibrio_448644",
        "folio": "448644",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-10-19",
        "total": 1059.65,
        "notas": (
            "Ticket Equilibrio 448644 · pedido online Iztapalapa 2 · 19-oct-2026 · "
            "29 pzas · $1,059.65 · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_eq_448644",
        "header": (
            "Equilibrio · ticket 448644 · 2026-10-19 · sucursal Iztapalapa 2\n"
            "-- Pedido online. Total $1,059.65 · 8 renglones / 29 pzas.\n"
            "-- Claves EQF → EAN ficha/Levic. Lote de fábrica sí.\n"
            "-- Caducidad NO: MMAA de la caja. 0000 inválido.\n"
            "-- Renglón ácido ascórbico: nombre cortado en foto (Kaomycin/Eye-Mo); "
            "asignado AMSA 6 amp 1 g/10 mL EAN 7501349022119 · lote U0227. Confirmar en caja.\n"
            "-- AMS365 Zolmitriptano → EAN Ultra/AMSA 7502216805446 (2 tab 2.5 mg)."
        ),
        "rows": [
            row("7502211780359", "LOE001 AFLUSIL 1 SUSP 2G/120ML", 3, 19.20, "R2602932"),
            row("0780083141929", "COL039 DOLPRIN 1 SUSP 100MG/5/120 ML", 3, 27.33, "26141339"),
            row("7502009740206", "MAV011 CLAMOXIN 1 SUSP 125/31.25MG/5/60 ML", 3, 27.82, "262274"),
            row("7501258207010", "SER141 OXITAL C 10 COMP 2G", 5, 61.20, "260140"),
            row("7501349025844", "AMS237 TELMISARTAN 28 TAB 40 MG", 3, 34.06, "U26A262"),
            row("7501258206723", "SER093 OXITAL C 10 COMP 1G", 5, 45.11, "260400"),
            row("7501349022119", "ACIDO ASCORBICO 6 AMP 1G/10 ML", 5, 28.39, "U0227"),
            row("7502216805446", "AMS365 ZOLMITRIPTANO 2 TAB 2.5 MG", 2, 30.46, "U26A344"),
        ],
    },
    {
        "key": "farmalive_14814",
        "folio": "14814",
        "proveedor": "Farmalive",
        "proveedor_ilike": "farmalive",
        "fecha": "2026-10-19",
        "total": 1664.96,
        "notas": (
            "Ticket Farmalive 14814 · Club Iztapalapa 1 · 19-oct-2026 17:05 · "
            "cliente FARMACAPITAL · descuentos por renglón · "
            "papel TOTAL $1,664.99 / suma P.U. neto $1,664.96 · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_fl_14814",
        "header": (
            "Farmalive · ticket 14814 · 2026-10-19 17:05 · Club Iztapalapa 1\n"
            "-- 18 renglones / 42 unidades. Papel: subtotal $1,725.63 − desc. $60.64 = $1,664.99.\n"
            "-- Costo = P.U. neto del renglón a 2 decimales → suma SQL $1,664.96.\n"
            "-- Tukol-D / Prudence con renglón promo $0.01 (regalo). Genomma EAN como en ticket.\n"
            "-- Alli-Triple ticket 12 dígitos 650240053610 (canónico catálogo)."
        ),
        "rows": [
            row("7506306234062", "CRE PEINAR SEDAL ANTI NUDOS 300 ML | UNILEVER", 3, 37.53),
            row("7501008491003", "DESENFRIOL D TAB C/30 2PACK | BAYER OTC", 1, 103.68),
            row("7501001168889", "VICK PYRENA SOB 8+2 | PG OTC", 1, 162.68),
            row("7501022105207", "JABON GRISI NEUTRO 150 GR | GRISI HNOS", 3, 19.21),
            row("650240053610", "ALLI-TRIPLE TAB C/10 | GENOMMA LAB", 3, 58.80),
            row("7506339394719", "TOA SANIT NATURELLA NOCTURNO C/A C/8 | PG PERF", 2, 21.43),
            row("7590002046234", "PANTIPROTECTORES NATURELLA MANZ C/40 | PG PERF", 1, 38.54),
            row("7506309895208", "TOA SANIT NATURELLA MANZ REG C/ALAS C/8 | PG PERF", 1, 9.78),
            row("7506552900322", "VASO RECOLECTOR QUIRMEX | QUIRMEX", 8, 3.53),
            row("7501008499795", "AFRIN NO DRIP INF SPRAY 15 ML | BAYER OTC", 3, 103.20),
            row("650240080159", "SUEROX MINERAL MORA AZUL 355 ML | GENOMMA LAB", 2, 14.73),
            row("7503003406754", "VENDA QUIRMEX 15 CM | QUIRMEX", 2, 10.97),
            row("7501868902404", "VENDA DIBAR 20 CM | DIBAR", 2, 22.44),
            row("7501019032424", "TAMPONES SABA SUPER C/10 | ESSITY", 1, 47.43),
            row("7502214982811", "COND PRUDENCE SURTIDO C/5 | DKT MEXICO", 4, 44.10),
            row("7502214982811", "COND PRUDENCE SURTIDO C/5 | DKT MEXICO", 1, 0.01),
            row("6502400315191", "TUKOL-D 0% AZUCAR JBE ADTO 120 ML | GENOMMA LAB", 2, 151.41),
            row("6502400107128", "TUKOL-D JBE ADTO 125 ML | GENOMMA LAB", 2, 0.01),
        ],
    },
    {
        "key": "nadro_6091278111",
        "folio": "6091278111",
        "proveedor": "Nadro",
        "proveedor_ilike": "nadro",
        "fecha": "2026-10-18",
        "total": 1008.73,
        "notas": (
            "Factura Nadro 6091278111 · 18-oct-2026 · entrega FarmaCapital · "
            "9 renglones LGEN · $1,008.73 · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_nd_6091278111",
        "header": (
            "Nadro · folio 6091278111 · 2026-10-18 · NADRO MÉXICO SUR\n"
            "-- Entrega FARMACAPITAL. 13 pzas · total conceptos $1,008.73 (IVA 0%).\n"
            "-- DEXAL = ceftibuteno (Maver), no ceftriaxona. Timolol Exakta EAN corto 75049612.\n"
            "-- Fosfomicina susp EAN 7506513601039 (PVO 7506513601053).\n"
            "-- Sin caducidad en cola (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7502009745352", "DEXAL 400 MG 5 CAPS LGEN", 1, 210.45),
            row("7503049078291", "DEXLANSOPRAZOL 60 MG 7 CAPS LGEN", 1, 94.12),
            row("7502231321709", "DORZOLAMIDA 20MG/ML SOL OFT LGEN", 1, 66.08),
            row("7506513601053", "FOSFOMICINA PVO P/SOL 3 G LGEN", 1, 158.93),
            row("7506513601039", "FOSFOMICINA SUSP FCO 120 ML LGEN", 1, 174.24),
            row("7501349025387", "GENTAMICINA 80MG 5 INY 2ML LGEN", 3, 8.47),
            row("7506449300372", "GUAIFE/OXOLA 2/1G JBE 140ML LGEN", 1, 31.76),
            row("7501075727159", "MOXIFLOXACINO 400 MG 7 TAB LGEN", 2, 92.65),
            row("75049612", "TIMOL 0.50% FCO GOT 5ML SOL LGEN", 2, 31.22),
        ],
    },
    {
        "key": "nadro_6091329944",
        "folio": "6091329944",
        "proveedor": "Nadro",
        "proveedor_ilike": "nadro",
        "fecha": "2026-10-19",
        "total": 1615.56,
        "notas": (
            "Factura Nadro 6091329944 · 19-oct-2026 · entrega FarmaCapital · "
            "6 renglones / 13 pzas · $1,615.56 · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_nd_6091329944",
        "header": (
            "Nadro · folio 6091329944 · 2026-10-19 · NADRO MÉXICO SUR\n"
            "-- Entrega FARMACAPITAL (LA CAPI). 13 pzas · total $1,615.56 "
            "(subtotal $1,562.94 + IVA 16% $52.62).\n"
            "-- Tena Pants / Predoblado: costo = total concepto c/IVA "
            "($117.47 y $88.01) para cuadrar factura.\n"
            "-- LGEN Lacosamida 100 mg 28 tab. Sin caducidad en cola (MMAA caja)."
        ),
        "rows": [
            row("7501088509773", "ANTIFLU-DES 24 CAPS", 2, 146.59),
            row("7501088509766", "ANTIFLU-DES JR SOL 60 ML", 2, 111.86),
            row(
                "7501019064807",
                "CALZ TENA PANTS COMFORT GDE C/13",
                1,
                117.47,
            ),
            row("7501065060891", "CONTAC ULTRA 12 TAB", 3, 30.54),
            row("7506442701039", "LACOSAMIDA 100MG 28 TAB LGEN", 2, 312.77),
            row(
                "7501019051401",
                "PAÑAL TENA PREDOBLADO UNIT C/10",
                3,
                88.01,
            ),
        ],
    },
]


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    paths: list[Path] = []
    for t in TICKETS:
        for r in t["rows"]:
            r["sub"] = round(r["qty"] * r["pu"], 2)
            r["precio"] = ceil_pvp(r["pu"], r["tipo"])

        if t["key"] == "farmalive_14814":
            t["total"] = round(sum(r["sub"] for r in t["rows"]), 2)

        suma = round(sum(r["sub"] for r in t["rows"]), 2)
        pzas = sum(r["qty"] for r in t["rows"])
        if abs(suma - t["total"]) > 0.02:
            raise SystemExit(
                f"{t['folio']}: suma renglones {suma} ≠ total ticket {t['total']}"
            )
        csv_path = GEN_DIR / f"ticket_{t['key']}.csv"
        write_ticket_csv(
            csv_path,
            folio=t["folio"],
            fecha=t["fecha"],
            proveedor=t["proveedor"],
            total=t["total"],
            rows=[
                {
                    "ean": r["ean"],
                    "nombre": r["snap"],
                    "qty": r["qty"],
                    "pu": r["pu"],
                    "sub": r["sub"],
                    "sku": r["sku"],
                    "match": r["match"],
                }
                for r in t["rows"]
            ],
        )
        sql_path = write_carga_sql(t)
        paths.append(sql_path)
        print(f"{t['folio']}: {report(t['rows'], t['total'])}")
        print(f"  → {csv_path.relative_to(ROOT)}")
        print(f"  → {sql_path.name} · {pzas} pzas · ${t['total']:.2f}")

    todos = OUT_DIR / "patch_carga_tickets_20261019_TODOS.sql"
    parts = [
        "-- ═══════════════════════════════════════════════════════════════",
        "-- TICKETS 19-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)",
        "-- Ver LEERME_tickets_20261019.md",
        "-- ═══════════════════════════════════════════════════════════════",
        "",
    ]
    for path in paths:
        parts.append(
            "\n-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        )
        parts.append(f"-- INICIO: {path.name}")
        parts.append(
            "-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        )
        parts.append(path.read_text(encoding="utf-8").rstrip() + "\n")
    todos.write_text("\n".join(parts), encoding="utf-8")

    leerme = OUT_DIR / "LEERME_tickets_20261019.md"
    leerme.write_text(
        """# Tickets Recibir · 19-oct-2026

Fotos Cityfarma + Sahuayo + Equilibrio + Farmalive + Nadro. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Cityfarma S333074 | `patch_carga_cityfarma_s333074.sql` | 21 | $2,545.99 |
| Sahuayo 428641 | `patch_carga_sahuayo_428641.sql` | 2 | $43.30 |
| Equilibrio 448644 | `patch_carga_equilibrio_448644.sql` | 29 | $1,059.65 |
| Farmalive 14814 | `patch_carga_farmalive_14814.sql` | 42 | $1,664.96 |
| Nadro 6091278111 | `patch_carga_nadro_6091278111.sql` | 13 | $1,008.73 |
| Nadro 6091329944 | `patch_carga_nadro_6091329944.sql` | 13 | $1,615.56 |

## Todo-en-uno

`patch_carga_tickets_20261019_TODOS.sql`

## Notas

- Equilibrio trae **lote de fábrica**; caducidad = MMAA de la caja al escanear.
- Equilibrio: renglón ácido ascórbico cortado en la foto → AMSA 6 amp EAN `7501349022119` (confirmar caja). AMS365 Zolmitriptano → EAN Ultra/AMSA `7502216805446`.
- Farmalive: costo = neto del renglón. Papel $1,664.99; suma SQL $1,664.96.
- Cityfarma: total = suma de renglones $2,545.99 (nebulizador Omron lleva el IVA 16% $80).
- Nadro 6091278111: Timolol Exakta EAN corto `75049612` (mismo estilo que otros Exakta en Farmacity).
- Nadro 6091329944: Tena con IVA en costo (Pants $117.47 · Predoblado $88.01). Total factura $1,615.56.
- Sahuayo: Nuvel Aclarado Ideal roll-on 50 mL EAN `7501082730258`.
- Regenerar: `python3 scripts/generar_carga_tickets_20261019.py`
""",
        encoding="utf-8",
    )
    print(f"\n→ {todos.name}")
    print(f"→ {leerme.name}")


if __name__ == "__main__":
    main()
