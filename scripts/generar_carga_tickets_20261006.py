#!/usr/bin/env python3
"""Tickets 06-oct-2026 (fotos) → cola Recibir.

5 pedidos:
  IFC F8 127425 · Grupo Zorro T01696085 · Equilibrio 447156
  Farmalive 13999 · Cityfarma S329263

Nombres de mostrador desde ficha (no el código del ticket).
Sin caducidad inventada (MMAA de la caja). Equilibrio sí trae lote de fábrica.
Farmalive: costo = P.U. neto después del descuento del renglón (2% o 5%).
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
    # ── IFC ──
    "7506484500034": p(
        "7506484500034",
        sku="FC-84500034",
        nombre="Cintapore micropore piel",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Cinta",
        marca="Cintapore",
        laboratorio="Codifarma",
        presentacion="Caja con 12 rollos 2.5 cm × 9.1 m",
        ya=False,
        foto_file="cintapore-piel-2.5x5.jpg",
    ),
    # ── Zorro ──
    # Bolsa/display ×12. Empaque Edgewell también escanea 6937266702079 (alias).
    # No confundir con pieza suelta 7591066701015.
    "7502274881475": p(
        "7502274881475",
        sku="FC-274881475",
        nombre="Schick Xtreme 3 Piel Sensible",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Afeitado",
        forma="Rastrillo",
        marca="Schick",
        laboratorio="Edgewell",
        presentacion="Bolsa / display con 12 rastrillos",
        ya=False,
    ),
    # ── Equilibrio ──
    "7501537164638": p(
        "7501537164638",
        sku="EQ-BRU029",
        nombre="Butifeno ketotifeno solución",
        tipo="generico",
        forma="Solución",
        marca="Butifeno",
        laboratorio="Bruluart",
        presentacion="Frasco 120 mL",
        principio="Ketotifeno",
        concentracion="20 mg/5 mL",
        receta=False,
        ya=False,
    ),
    "7501573904403": p(
        "7501573904403",
        sku="EQ-BIO138",
        nombre="Lozamir-C clotrimazol crema 1%",
        tipo="generico",
        categoria="Dermocosmético",
        forma="Crema",
        marca="Lozamir-C",
        laboratorio="Biomep",
        presentacion="Tubo 30 g",
        principio="Clotrimazol",
        concentracion="1%",
        ya=True,
    ),
    "7502001166110": p(
        "7502001166110",
        sku="EQ-SON247",
        nombre="Femitab clindamicina/ketoconazol",
        tipo="generico",
        forma="Óvulo",
        marca="Femitab",
        laboratorio="Son's",
        presentacion="Caja con 7 óvulos",
        principio="Clindamicina / ketoconazol",
        concentracion="100/400 mg",
        receta=True,
        ya=False,
    ),
    "7501478316226": p(
        "7501478316226",
        sku="EQ-VIT061",
        nombre="Bocetix levocetirizina 5 mg",
        tipo="generico",
        forma="Tableta",
        marca="Bocetix",
        laboratorio="Vitae",
        presentacion="Caja con 10 tabletas",
        principio="Levocetirizina",
        concentracion="5 mg",
        ya=False,
    ),
    "7503004908714": p(
        "7503004908714",
        sku="EQ-ALP0520",
        nombre="Miconazol crema 2%",
        tipo="generico",
        categoria="Dermocosmético",
        forma="Crema",
        marca="Alpharma",
        laboratorio="Alpharma",
        presentacion="Tubo 20 g",
        principio="Miconazol",
        concentracion="2%",
        ya=True,
    ),
    "7501836006042": p(
        "7501836006042",
        sku="EQ-LIF160",
        nombre="Virindrez Adulto oximetazolina 0.050%",
        tipo="generico",
        forma="Atomizador",
        marca="Virindrez",
        laboratorio="Liferpal",
        presentacion="Frasco atomizador 20 mL",
        principio="Oximetazolina",
        concentracion="0.050%",
        ya=True,
    ),
    "7503001007120": p(
        "7503001007120",
        sku="FC-50587FA6",
        nombre="Mexapin amoxicilina suspensión 125 mg/5 mL",
        tipo="generico",
        forma="Suspensión",
        marca="Mexapin",
        laboratorio="Wandel",
        presentacion="Frasco 60 mL",
        principio="Amoxicilina",
        concentracion="125 mg/5 mL",
        receta=True,
        ya=True,
    ),
    "7501573902584": p(
        "7501573902584",
        sku="EQ-BIO067",
        nombre="Sarox omeprazol 20 mg",
        tipo="generico",
        forma="Cápsula",
        marca="Sarox",
        laboratorio="Biomep",
        presentacion="Caja con 14 cápsulas",
        principio="Omeprazol",
        concentracion="20 mg",
        ya=True,
    ),
    "7502009740213": p(
        "7502009740213",
        sku="FC-F48FF7EF",
        nombre="Clamoxin amoxicilina/clavulánico suspensión 250/62.5",
        tipo="generico",
        forma="Suspensión",
        marca="Clamoxin",
        laboratorio="Maver",
        presentacion="Frasco 60 mL",
        principio="Amoxicilina / ácido clavulánico",
        concentracion="250/62.5 mg/5 mL",
        receta=True,
        ya=True,
    ),
    "7501075727180": p(
        "7501075727180",
        sku="EQ-NOV175",
        nombre="Lia drospirenona/etinilestradiol",
        tipo="marca",
        forma="Comprimido",
        marca="Lia",
        laboratorio="Novag",
        presentacion="Caja con 28 comprimidos",
        principio="Drospirenona / etinilestradiol",
        concentracion="3/0.03 mg",
        receta=True,
        ya=False,
    ),
    "7502009744570": p(
        "7502009744570",
        sku="EQ-MAV201",
        nombre="Sinfonil oxcarbazepina 300 mg",
        tipo="generico",
        forma="Tableta",
        marca="Sinfonil",
        laboratorio="Maver",
        presentacion="Caja con 20 tabletas",
        principio="Oxcarbazepina",
        concentracion="300 mg",
        receta=True,
        ya=False,
    ),
    "7502213040871": p(
        "7502213040871",
        sku="EQ-HIS045",
        nombre="Cifhir bencidamina gel 5%",
        tipo="generico",
        categoria="Dermocosmético",
        forma="Gel",
        marca="Cifhir",
        laboratorio="Hispanoamericana",
        presentacion="Tubo 60 g",
        principio="Bencidamina",
        concentracion="5%",
        ya=True,
    ),
    "7502009744587": p(
        "7502009744587",
        sku="EQ-MAV202",
        nombre="Sinfonil oxcarbazepina 600 mg",
        tipo="generico",
        forma="Tableta",
        marca="Sinfonil",
        laboratorio="Maver",
        presentacion="Caja con 20 tabletas",
        principio="Oxcarbazepina",
        concentracion="600 mg",
        receta=True,
        ya=False,
    ),
    "7501075722604": p(
        "7501075722604",
        sku="EQ-NOV154",
        nombre="Belazix levocetirizina 5 mg",
        tipo="marca",
        forma="Tableta",
        marca="Belazix",
        laboratorio="Novag",
        presentacion="Caja con 20 tabletas",
        principio="Levocetirizina",
        concentracion="5 mg",
        ya=True,
    ),
    "7501573902928": p(
        "7501573902928",
        sku="EQ-BIO081",
        nombre="Ketoconazol crema 2%",
        tipo="generico",
        categoria="Dermocosmético",
        forma="Crema",
        marca="Biomep",
        laboratorio="Biomep",
        presentacion="Tubo 30 g",
        principio="Ketoconazol",
        concentracion="2%",
        ya=False,
    ),
    "7502227427408": p(
        "7502227427408",
        sku="EQ-GEP050",
        nombre="Esgaro levocetirizina 5 mg",
        tipo="generico",
        forma="Cápsula",
        marca="Esgaro",
        laboratorio="Gelpharma",
        presentacion="Caja con 10 cápsulas",
        principio="Levocetirizina",
        concentracion="5 mg",
        ya=False,
    ),
    "7502001165311": p(
        "7502001165311",
        sku="FC-830BF3FB",
        nombre="Diviltac 150/10 mg/mL",
        tipo="generico",
        forma="Frasco ámpula",
        marca="Diviltac",
        laboratorio="Son's",
        presentacion="Frasco ámpula 1 mL",
        principio=None,
        concentracion="150/10 mg/mL",
        receta=True,
        ya=True,
    ),
    "7501349014190": p(
        "7501349014190",
        sku="EQ-AMS147",
        nombre="Ácido alendrónico 10 mg",
        tipo="generico",
        forma="Tableta",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 30 tabletas",
        principio="Ácido alendrónico",
        concentracion="10 mg",
        receta=True,
        ya=True,
    ),
    "7503001007113": p(
        "7503001007113",
        sku="FC-D5AC44CA",
        nombre="Amifarin dicloxacilina 500 mg",
        tipo="generico",
        forma="Cápsula",
        marca="Amifarin",
        laboratorio="Wandel",
        presentacion="Caja con 20 cápsulas",
        principio="Dicloxacilina",
        concentracion="500 mg",
        receta=True,
        ya=True,
    ),
    "7501349020153": p(
        "7501349020153",
        sku="EQ-AMS326",
        nombre="Levotiroxina sódica 100 mcg",
        tipo="generico",
        forma="Tableta",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 100 tabletas",
        principio="Levotiroxina sódica",
        concentracion="100 mcg",
        receta=True,
        ya=False,
    ),
    "7502001165748": p(
        "7502001165748",
        sku="EQ-SON244",
        nombre="Exbenzol mebendazol 100 mg",
        tipo="generico",
        forma="Tableta",
        marca="Exbenzol",
        laboratorio="Son's",
        presentacion="Caja con 6 tabletas",
        principio="Mebendazol",
        concentracion="100 mg",
        ya=False,
    ),
    # ── Farmalive ──
    "7501008409534": p(
        "7501008409534",
        sku="FC-08409534",
        nombre="Saridon EXH",
        tipo="marca",
        forma="Tableta",
        marca="Saridon",
        laboratorio="Bayer OTC",
        presentacion="Caja con 100 tabletas",
        principio="Paracetamol / propyfenazona / cafeína",
        ya=False,
    ),
    "7502214980350": p(
        "7502214980350",
        sku="FC-14980350",
        nombre="Prudence Lub lubricante íntimo mora azul",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Íntimo",
        forma="Gel",
        marca="Prudence",
        laboratorio="DKT México",
        presentacion="Tubo 75 mL",
        ya=True,
    ),
    "6502400746914": p(
        "6502400746914",
        sku="FC-40074691",
        nombre="Asepxia jabón suavizante",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Piel",
        forma="Jabón",
        marca="Asepxia",
        laboratorio="Genomma Lab",
        presentacion="Paquete con 4 barras de 100 g",
        ya=False,
    ),
    "6502400046434": p(
        "6502400046434",
        sku="FC-40004643",
        nombre="Asepxia jabón exfoliante",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Piel",
        forma="Jabón",
        marca="Asepxia",
        laboratorio="Genomma Lab",
        presentacion="Barra 100 g",
        ya=True,
    ),
    "7501008409541": p(
        "7501008409541",
        sku="FC-84095411",
        nombre="Saridon",
        tipo="marca",
        forma="Tableta",
        marca="Saridon",
        laboratorio="Bayer OTC",
        presentacion="Caja con 20 tabletas",
        principio="Paracetamol / propyfenazona / cafeína",
        ya=True,
        foto_file="saridon-c20.jpg",
    ),
    "6502400322644": p(
        "6502400322644",
        sku="FC-40032264",
        nombre="Suerox 8 iones fresa kiwi",
        tipo="marca",
        categoria="Bebidas",
        subcategoria="Electrolitos",
        forma="Bebida",
        marca="Suerox",
        laboratorio="Genomma Lab",
        presentacion="Botella 630 mL",
        ya=True,
    ),
    "7503003406167": p(
        "7503003406167",
        sku="FC-03406167",
        nombre="Cinta micropore Quirmex piel",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Cinta",
        marca="Quirmex",
        laboratorio="Quirmex",
        presentacion="Rollo 2.5 cm × 10 m",
        ya=False,
    ),
    "7501868910034": p(
        "7501868910034",
        sku="FC-68910034",
        nombre="Dibar algodón",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Algodón",
        marca="Dibar",
        laboratorio="Dibar",
        presentacion="Bolsa 50 g",
        ya=True,
    ),
    # ── Cityfarma ──
    "7501318645080": p(
        "7501318645080",
        sku="FC-8645080",
        nombre="Canesten V crema",
        tipo="marca",
        categoria="Dermocosmético",
        forma="Crema",
        marca="Canesten",
        laboratorio="Bayer OTC",
        presentacion="Tubo 20 g con aplicadores",
        principio="Clotrimazol",
        concentracion="1%",
        ya=True,
    ),
    "7501563380026": p(
        "7501563380026",
        sku="FC-63380026",
        nombre="Doxiciclina 100 mg",
        tipo="generico",
        forma="Cápsula",
        marca="Randall",
        laboratorio="Randall",
        presentacion="Caja con 10 cápsulas",
        principio="Doxiciclina",
        concentracion="100 mg",
        receta=True,
        ya=False,
    ),
    "7501165000315": p(
        "7501165000315",
        sku="FC-50003151",
        nombre="Neo-Melubrina jarabe infantil",
        tipo="marca",
        forma="Jarabe",
        marca="Neo-Melubrina",
        laboratorio="Opella",
        presentacion="Frasco 100 mL",
        principio="Metamizol sódico",
        concentracion="250 mg/5 mL",
        ya=True,
        foto_file="neo-melubrina-jarabe-100ml.jpg",
    ),
    "7501384543983": p(
        "7501384543983",
        sku="FC-84543983",
        nombre="Risperidona 2 mg",
        tipo="generico",
        forma="Tableta",
        marca="Alpharma",
        laboratorio="Alpharma",
        presentacion="Caja con 40 tabletas",
        principio="Risperidona",
        concentracion="2 mg",
        receta=True,
        ya=False,
    ),
    "7501825300786": p(
        "7501825300786",
        sku="FC-25300786",
        nombre="Sediclon dicicloverina 10 mg",
        tipo="generico",
        forma="Tableta",
        marca="Sediclon",
        laboratorio="Degort's",
        presentacion="Caja con 30 tabletas",
        principio="Dicicloverina",
        concentracion="10 mg",
        receta=True,
        ya=False,
    ),
    # Caja Chinoín 7501088575495 (el tipógrafo del ticket metió 76495, checksum inválido).
    "7501088575495": p(
        "7501088575495",
        sku="FC-88576495",
        nombre="Troferit 30 mg",
        tipo="marca",
        forma="Tableta",
        marca="Troferit",
        laboratorio="Chinoin",
        presentacion="Caja con 15 tabletas",
        principio="Dropropizina",
        concentracion="30 mg",
        receta=True,
        ya=False,
    ),
    "7501300421821": p(
        "7501300421821",
        sku="FC-00421821",
        nombre="Zivata-Duo dutasterida/tamsulosina",
        tipo="marca",
        forma="Cápsula",
        marca="Zivata-Duo",
        laboratorio="Siegfried Rhein",
        presentacion="Caja con 30 cápsulas",
        principio="Dutasterida / tamsulosina",
        concentracion="0.5/0.4 mg",
        receta=True,
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
        "key": "ifc_127425",
        "folio": "127425",
        "proveedor": "IFC",
        "proveedor_ilike": "ifc",
        "fecha": "2026-10-06",
        "total": 238.00,
        "notas": (
            "Ticket IFC F8 127425 · 06-oct-2026 17:08 · foto térmica · "
            "Cintapore micropore piel grande C/12 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_ifc_127425",
        "header": (
            "IFC F8 · ticket 127425 · 2026-10-06 17:08 · cliente IVAN\n"
            "-- Mayoreo. 1 paquete · total $238.00.\n"
            "-- CINTAPORE MICROPORE PIEL GRANDE C/12 → EAN caja 7506484500034 "
            "(Codifarma 2.5 cm × 9.1 m × 12; código IFC 84129).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row(
                "7506484500034",
                "CINTAPORE MICROPORE PIEL GRANDE C/12 | 260402-4 84129",
                1,
                238.00,
            ),
        ],
    },
    {
        "key": "zorro_T01696085",
        "folio": "T01696085",
        "proveedor": "Grupo Zorro",
        "proveedor_ilike": "zorro",
        "fecha": "2026-10-06",
        "total": 161.67,
        "notas": (
            "Ticket Grupo Zorro ZE9 T01696085 · 06-oct-2026 17:20 · "
            "Schick Xtreme 3 bolsa 12 pzas · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_zorro_T01696085",
        "header": (
            "Grupo Zorro E-9 · ticket T01696085 · 2026-10-06 17:20:22\n"
            "-- Menudeo. 1 pza · total $161.67 (IVA incluido en ticket).\n"
            "-- RASTRILLOS SCHICK XTREME 3 12-12 PZ → EAN bolsa 7502274881475 "
            "(alias display Edgewell 6937266702079; no confundir con pieza suelta 7591066701015).\n"
            "-- Sin lote ni caducidad. No inventar 0000."
        ),
        "rows": [
            row(
                "7502274881475",
                "RASTRILLOS SCHICK XTREME 3 12-12 PZ",
                1,
                161.67,
            ),
        ],
    },
    {
        "key": "equilibrio_447156",
        "folio": "447156",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-10-06",
        "total": 2643.87,
        "notas": (
            "Ticket Equilibrio 447156 · 06-oct-2026 · pedido online Iztapalapa 2 · "
            "75 pzas · $2,643.87 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_eq_447156",
        "header": (
            "Equilibrio · ticket 447156 · 2026-10-06 · sucursal Iztapalapa 2\n"
            "-- Pedido online. Total $2,643.87 · 21 renglones / 75 pzas.\n"
            "-- Claves EQF → EAN ficha/Levic/mayoreo. Lote de fábrica sí.\n"
            "-- Caducidad NO: MMAA de la caja. 0000 inválido."
        ),
        "rows": [
            row("7501537164638", "BRU029 BUTIFENO 1 SOL 20MG/5/120 ML", 2, 19.80, "2511999"),
            row("7501573904403", "BIO138 LOZAMIR-C 1 CMA 1/30 G", 3, 14.31, "CE2604"),
            row("7502001166110", "SON247 FEMITAB 7 OVS 100/400 MG", 2, 63.63, "25123575"),
            row("7501478316226", "VIT061 BOCETIX 10 TAB 5 MG", 5, 43.63, "T2607355"),
            row("7503004908714", "ALP0520 MICONAZOL 1 CMA DE 20 G", 5, 10.67, "2601222"),
            row("7501836006042", "LIF160 VIRINDREZ ADULTO 1 ATOM 50 MG/20 ML", 5, 23.37, "26F031"),
            row("7503001007120", "WAN006 MEXAPIN 1 SUSP 125MG/5/60 ML", 6, 13.32, "56113"),
            row("7501573902584", "BIO067 SAROX 14 CAPS 20 MG", 5, 8.18, "5F2637"),
            row("7502009740213", "MAV012 CLAMOXIN 1 SUSP 250/62.5MG/5/60 ML", 3, 35.05, "260031"),
            row("7501075727180", "NOV175 LIA 28 COMP 3/.03 MG", 1, 156.43, "16737"),
            row("7502009744570", "MAV201 SINFONIL 20 TAB 300 MG", 2, 75.97, "262434"),
            row("7502213040871", "HIS045 CIFHIR 1 GEL 60G/5 %", 1, 44.77, "5M326"),
            row("7502009744587", "MAV202 SINFONIL 20 TAB 600 MG", 2, 138.11, "262430"),
            row("7501075722604", "NOV154 BELAZIX C/20 TAB 5MG", 4, 63.67, "880086"),
            row("7501573902928", "BIO081 KETOCONAZOL 1 CMA 2%/30 G", 5, 15.68, "CG2610"),
            row("7502227427408", "GEP050 ESGARO 10 CAPS 5 MG", 5, 53.48, "260910"),
            row("7502001165311", "SON189 DIVILTAC 1 FA 150/10MG/1 ML", 2, 37.48, "H26040037"),
            row("7501349014190", "AMS147 ACIDO ALENDRONICO 30 TAB 10 MG", 8, 25.65, "U26A275"),
            row("7503001007113", "WAN024 AMIFARIN 20 CAPS 500 MG", 5, 44.31, "C6227"),
            row("7501349020153", "AMS326 LEVOTIROXINA SODICA 100 TAB 100 MCG", 1, 43.21, "U25G450"),
            row("7502001165748", "SON244 EXBENZOL 6 TAB 100 MG", 3, 15.00, "26040942"),
        ],
    },
    {
        "key": "farmalive_13999",
        "folio": "13999",
        "proveedor": "Farmalive",
        "proveedor_ilike": "farmalive",
        "fecha": "2026-10-06",
        "total": 778.75,
        "notas": (
            "Ticket Farmalive 13999 · Club Iztapalapa 1 · 06-oct-2026 · "
            "cliente FARMACAPITAL · descuentos por renglón 2%/5% · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_fl_13999",
        "header": (
            "Farmalive · ticket 13999 · 2026-10-06 16:41 · Club Iztapalapa 1\n"
            "-- 8 renglones / 23 unidades. Papel: subtotal $798.10 − desc. ≈ $778.69/778.70.\n"
            "-- Costo = P.U. neto del renglón (2% o 5%) a 2 decimales → suma SQL $778.75.\n"
            "-- Ticket trunca Suerox/Asepxia a 12 dígitos; pistola = EAN canónico 650…4.\n"
            "-- Algodón Dibar 50 g: 12 pzas (cantidad marcada a mano en el ticket)."
        ),
        "rows": [
            row("7501008409534", "SARIDON EXH TAB C/100 | BAYER OTC", 1, 269.50),
            row("7502214980350", "LUBRICANTE PRUDENCE MORA AZUL 75 ML | DKT MEXICO", 1, 70.17),
            row("6502400746914", "ASEPXIA JABON SUAVIZANTE 100 GR 4PACK | GENOMMA LAB", 1, 49.98),
            row("6502400046434", "ASEPXIA JABON EXFOLIANTE 100 GR | GENOMMA LAB", 2, 39.81),
            row("7501008409541", "SARIDON TAB C/20 | BAYER OTC", 2, 63.46),
            row("6502400322644", "SUEROX 8IONES FRESA KIWI 630 ML | GENOMMA LAB", 2, 14.73),
            row("7503003406167", "CINTA MICROPOR QUIRMEX PIEL 2.5CMX10M | QUIRMEX", 2, 17.15),
            row("7501868910034", "ALGODON DIBAR 50 GR | DIBAR", 12, 9.90),
        ],
    },
    {
        "key": "cityfarma_s329263",
        "folio": "S329263",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-10-06",
        "total": 1425.01,
        "notas": (
            "Ticket Cityfarma S329263 · 06-oct-2026 · foto térmica · "
            "Pendiente de pago $1,425.01 · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_cf_s329263",
        "header": (
            "Cityfarma Iztapalapa · orden S329263 · 2026-10-06 17:33\n"
            "-- Ticket térmico. IVA 0%. Pendiente de pago = $1,425.01.\n"
            "-- DOXICICLINA 100MG C1 → Randall C/10 EAN 7501563380026.\n"
            "-- Zivata-Duo dutasterida/tamsulosina 0.5/0.4 mg (Siegfried).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7501318645080", "CANESTEN V CRA 20 GR", 2, 141.95),
            row("7501563380026", "DOXICICLINA 100MG C1", 2, 24.13),
            row("7501165000315", "NEO MELUBRINA JBE", 2, 118.48),
            row("7501384543983", "RISPERIDONA 2MG 40", 2, 62.40),
            row("7501825300786", "SEDICLON DICICLOVERI", 5, 21.24),
            row("7501088575495", "TROFERIT 30 MG C 15", 1, 150.79),
            row("7501300421821", "ZIVATA-DUO DUTASTERI", 1, 474.10),
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

        # Farmalive: ticket $778.69 / tarjeta $778.70; P.U.×qty a 2 decimales = $778.75
        if t["key"] == "farmalive_13999":
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

    todos = OUT_DIR / "patch_carga_tickets_20261006_TODOS.sql"
    parts = [
        "-- ═══════════════════════════════════════════════════════════════",
        "-- TICKETS 06-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)",
        "-- Ver LEERME_tickets_20261006.md",
        "-- ═══════════════════════════════════════════════════════════════",
        "",
    ]
    for path in paths:
        parts.append(f"\n-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(f"-- INICIO: {path.name}")
        parts.append(f"-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(path.read_text(encoding="utf-8").rstrip() + "\n")
    todos.write_text("\n".join(parts), encoding="utf-8")

    leerme = OUT_DIR / "LEERME_tickets_20261006.md"
    leerme.write_text(
        """# Tickets Recibir · 06-oct-2026

Fotos IFC + Zorro + Equilibrio + Farmalive + Cityfarma. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| IFC 127425 | `patch_carga_ifc_127425.sql` | 1 | $238.00 |
| Grupo Zorro T01696085 | `patch_carga_zorro_T01696085.sql` | 1 | $161.67 |
| Equilibrio 447156 | `patch_carga_equilibrio_447156.sql` | 75 | $2,643.87 |
| Farmalive 13999 | `patch_carga_farmalive_13999.sql` | 23 | $778.75 |
| Cityfarma S329263 | `patch_carga_cityfarma_s329263.sql` | 15 | $1,425.01 |

## Todo-en-uno

`patch_carga_tickets_20261006_TODOS.sql`

## Notas

- Equilibrio trae **lote de fábrica**; caducidad = MMAA de la caja al escanear.
- Schick bolsa 12 pzas EAN `7502274881475` (alias display `6937266702079`; no la pieza suelta `7591066701015`).
- Troferit caja EAN `7501088575495` (el tipógrafo del ticket metió `7501088576495`).
- Cintapore caja C/12 EAN `7506484500034` (código IFC 84129).
- Farmalive: costo = neto del renglón (2% o 5%). Suerox/Asepxia con EAN canónico 13 dígitos.
- Cityfarma: pendiente de pago $1,425.01.
- Regenerar: `python3 scripts/generar_carga_tickets_20261006.py`
""",
        encoding="utf-8",
    )
    print(f"\nTODOS → {todos.name} ({todos.stat().st_size} bytes)")
    print(f"LEERME → {leerme.name}")


if __name__ == "__main__":
    main()
