#!/usr/bin/env python3
"""Tickets 02-oct-2026 (fotos Central de Abastos + Nadro) → cola Recibir.

6 pedidos:
  Nadro 6090680530 (01-oct) · Equilibrio 446721 · Mayorista de Dulces T620721328
  Bodega F-42 83017 · Farmalive 1028 · Cityfarma S328174

Nombres de mostrador desde ficha (no el código del ticket).
Sin caducidad inventada (MMAA de la caja). Equilibrio sí trae lote de fábrica.
Farmalive: costo = P.U. neto después del 2%.
Fotos nuevas en public/catalogo-propia/ (tras deploy).
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import (
    ceil_pvp,
    foto_url,
    report,
    sku_de,
    sql_str,
    write_carga_sql,
    write_ticket_csv,
)

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
    # ── Nadro ──
    "7501008498798": p(
        "7501008498798",
        sku="FC-08498798",
        nombre="Bepanthen pomada regeneradora 5%",
        tipo="marca",
        categoria="Dermocosmético",
        subcategoria="Piel",
        forma="Pomada",
        marca="Bepanthen",
        laboratorio="Bayer OTC",
        presentacion="Tubo 30 g",
        principio="Dexpantenol",
        concentracion="5%",
        ya=True,
        foto_file="bepanthen-regeneradora-30g-7501008498798.jpg",
    ),
    "7502256040517": p(
        "7502256040517",
        nombre="Dankial-B budesonida 0.250 mg/2 mL C/5",
        tipo="generico",
        categoria="Respiratorio",
        forma="Suspensión para nebulizar",
        marca="Dankial-B",
        laboratorio="Dankel",
        presentacion="Caja con 5 ampolletas de 2 mL",
        principio="Budesonida",
        concentracion="0.250 mg/2 mL",
        receta=True,
        ya=False,
        foto_file="dankial-b-budesonida-0250-c5-7502256040517.jpg",
    ),
    "354312225010": p(
        "354312225010",
        nombre="Derman crema antimicótica",
        tipo="marca",
        categoria="Dermocosmético",
        subcategoria="Antimicótico",
        forma="Crema",
        marca="Derman",
        laboratorio="Int. Comercio",
        presentacion="Tubo 25 g",
        principio="Ácido undecilénico / undecilenato de zinc",
        ya=False,
        foto_file="derman-crema-25g-354312225010.jpg",
    ),
    "7501328979502": p(
        "7501328979502",
        sku="FC-28979502",
        nombre="Histiacil NF adulto jarabe",
        tipo="marca",
        categoria="Respiratorio",
        forma="Jarabe",
        marca="Histiacil",
        laboratorio="Sanofi / Opella",
        presentacion="Frasco 150 mL",
        principio="Dextrometorfano / ambroxol",
        concentracion="225 mg / 225 mg por 100 mL",
        ya=True,
        foto_file="histiacil-nf-adulto-150ml-7501328979502.jpg",
    ),
    # ── Equilibrio ──
    "785118754242": p(
        "785118754242",
        sku="FC-1FFBB505",
        nombre="Supratex DAC ambroxol/levodropropizina",
        tipo="generico",
        forma="Solución",
        marca="Supratex",
        laboratorio="MAVI",
        presentacion="Frasco 120 mL",
        principio="Ambroxol / levodropropizina",
        concentracion="300/600 mg",
        ya=True,
        foto_file="supratex-dac-120ml-785118754242.jpg",
    ),
    "7503000422498": p(
        "7503000422498",
        sku="FC-6074BB64",
        nombre="Redalip bezafibrato 200 mg",
        tipo="generico",
        forma="Tableta",
        marca="Redalip",
        laboratorio="MAVI",
        presentacion="Caja con 30 tabletas",
        principio="Bezafibrato",
        concentracion="200 mg",
        receta=True,
        ya=True,
    ),
    "7502009742392": p(
        "7502009742392",
        sku="EQ-MAV167",
        nombre="Doltrix clonixinato/hioscina 125/10 mg",
        tipo="generico",
        forma="Tableta",
        marca="Doltrix",
        laboratorio="Maver",
        presentacion="Caja con 20 tabletas",
        principio="Clonixinato de lisina / butilhioscina",
        concentracion="125/10 mg",
        receta=True,
        ya=True,
        foto_file="doltrix-125-10-c20-7502009742392.jpg",
    ),
    "7502009741487": p(
        "7502009741487",
        sku="EQ-MAV134",
        nombre="Doltrix clonixinato/hioscina 250/10 mg",
        tipo="generico",
        forma="Tableta",
        marca="Doltrix",
        laboratorio="Maver",
        presentacion="Caja con 10 tabletas",
        principio="Clonixinato de lisina / butilhioscina",
        concentracion="250/10 mg",
        receta=True,
        ya=True,
        foto_file="doltrix-250-10-c10-7502009741487.jpg",
    ),
    "7502009749421": p(
        "7502009749421",
        sku="FC-09749421",
        nombre="Dexpantenol crema 5%",
        tipo="generico",
        categoria="Dermocosmético",
        forma="Crema",
        marca="Maver",
        laboratorio="Maver",
        presentacion="Tubo 30 g",
        principio="Dexpantenol",
        concentracion="5%",
        ya=True,
        foto_file="dexpantenol-5-30g-7502009749421.jpg",
    ),
    # ── Farmalive ──
    "714706903182": p(
        "714706903182",
        nombre="Broncolin paletas vitrolero surtido",
        tipo="marca",
        categoria="Respiratorio",
        subcategoria="Garganta",
        forma="Paleta",
        marca="Broncolin",
        laboratorio="Broncolin",
        presentacion="Vitrolero con 100 paletas",
        ya=False,
        # TODO foto: Farmatodo tiene C/100 miel EAN 714706903038; ticket es surtido 714706903182.
    ),
    "714706918964": p(
        "714706918964",
        nombre="Broncolin Properlas propóleo y eucalipto",
        tipo="marca",
        categoria="Respiratorio",
        subcategoria="Garganta",
        forma="Perlas",
        marca="Broncolin",
        laboratorio="Broncolin",
        presentacion="Bolsa 50 g",
        ya=False,
        foto_file="properlas-eucalipto-50g-714706918964.jpg",
    ),
    "7502214985805": p(
        "7502214985805",
        sku="FC-14985805",
        nombre="Prudence Chicle condones",
        tipo="marca",
        categoria="Higiene",
        forma="Condón",
        marca="Prudence",
        laboratorio="DKT México",
        presentacion="Caja con 5",
        ya=True,
    ),
    "7502214980015": p(
        "7502214980015",
        sku="FC-49800151",
        nombre="Prudence Clásico condones",
        tipo="marca",
        categoria="Higiene",
        forma="Condón",
        marca="Prudence",
        laboratorio="DKT México",
        presentacion="Caja con 3",
        ya=True,
    ),
    "714706918940": p(
        "714706918940",
        nombre="Broncolin Properlas propóleo y jengibre",
        tipo="marca",
        categoria="Respiratorio",
        subcategoria="Garganta",
        forma="Perlas",
        marca="Broncolin",
        laboratorio="Broncolin",
        presentacion="Bolsa 50 g",
        ya=False,
        foto_file="properlas-jengibre-50g-714706918940.jpg",
    ),
    "650240019180": p(
        "650240019180",
        nombre="Pomada de la Campana Tepezcohuite",
        tipo="marca",
        categoria="Dermocosmético",
        forma="Pomada",
        marca="Pomada de la Campana",
        laboratorio="Genomma Lab",
        presentacion="Tarro 35 g",
        principio="Tepezcohuite",
        ya=False,
        foto_file="campana-tepezcohuite-35g-650240019180.jpg",
    ),
    "7501065628145": p(
        "7501065628145",
        sku="FC-65628145",
        nombre="Pomada de la Campana",
        tipo="marca",
        categoria="Dermocosmético",
        forma="Pomada",
        marca="Pomada de la Campana",
        laboratorio="Genomma Lab",
        presentacion="Tarro 35 g",
        ya=True,
    ),
    "7501065628121": p(
        "7501065628121",
        sku="FC-65628121",
        nombre="Pomada de la Campana",
        tipo="marca",
        categoria="Dermocosmético",
        forma="Pomada",
        marca="Pomada de la Campana",
        laboratorio="Genomma Lab",
        presentacion="Tarro 19 g",
        ya=True,
    ),
    # ── Bodega F-42 ──
    "0378360404500": p(
        "0378360404500",
        sku="FC-36040450",
        nombre="Grisi concha nácar crema para manos",
        tipo="marca",
        categoria="Cuidado personal",
        forma="Crema",
        marca="Grisi",
        laboratorio="Grisi",
        presentacion="Tubo 80 mL",
        ya=True,
    ),
    "8101205017656": p(
        "8101205017656",
        sku="FC-20501765",
        nombre="Grisi aloe vera crema para manos",
        tipo="marca",
        categoria="Cuidado personal",
        forma="Crema",
        marca="Grisi",
        laboratorio="Grisi",
        presentacion="Tubo 80 mL",
        ya=True,
    ),
    "0378360405354": p(
        "0378360405354",
        nombre="Ricitos de Oro crema corporal lavanda",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bebé",
        forma="Crema",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="Frasco 100 mL",
        ya=False,
        # TODO foto packshot 100 mL lavanda (EAN ticket 037836040535).
    ),
    "7501082722116": p(
        "7501082722116",
        nombre="Nuvel crema para manos suaves",
        tipo="marca",
        categoria="Cuidado personal",
        forma="Crema",
        marca="Nuvel",
        laboratorio="Nuvel",
        presentacion="Tubo 65 mL",
        ya=False,
        # TODO foto.
    ),
    "0378360415940": p(
        "0378360415940",
        nombre="Ricitos de Oro colonia avena y vainilla",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bebé",
        forma="Colonia",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="Frasco 100 mL",
        ya=False,
        # TODO foto.
    ),
    "7501082722123": p(
        "7501082722123",
        nombre="Nuvel crema para manos hidratada",
        tipo="marca",
        categoria="Cuidado personal",
        forma="Crema",
        marca="Nuvel",
        laboratorio="Nuvel",
        presentacion="Tubo 65 mL",
        ya=False,
        # TODO foto.
    ),
    "7501022104248": p(
        "7501022104248",
        sku="FC-21042481",
        nombre="Ricitos de Oro crema corporal",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bebé",
        forma="Crema",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="Frasco 100 mL",
        ya=True,
    ),
    # ── Dulces ──
    "076350614570": p(
        "076350614570",
        nombre="Chupa Chups Mini paleta",
        tipo="marca",
        categoria="Impulso",
        forma="Paleta",
        marca="Chupa Chups",
        laboratorio="Perfetti",
        presentacion="Bolsa 240 piezas",
        ya=False,
        # TODO foto packshot bolsa 240.
    ),
    # ── Cityfarma ──
    "7506331301173": p(
        "7506331301173",
        nombre="Autevazen levetiracetam 1 g",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Antiepiléptico",
        forma="Tableta",
        marca="Autevazen",
        laboratorio="Aurovida",
        presentacion="Caja con 30 tabletas",
        principio="Levetiracetam",
        concentracion="1 g",
        receta=True,
        ya=False,
        foto_file="autevazen-levetiracetam-1g-c30-7506331301173.jpg",
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
        **{k: prod[k] for k in (
            "tipo", "categoria", "subcategoria", "forma", "marca", "laboratorio",
            "presentacion", "principio", "concentracion", "receta", "ya", "foto", "foto_file",
        )},
        "precio": ceil_pvp(pu, prod["tipo"]),
        "match": "ya" if prod["ya"] else "alta",
    }


def neto(list_pu: float) -> float:
    """Farmalive 2% descuento → P.U. neto."""
    return round(list_pu * 0.98, 2)


TICKETS = [
    {
        "key": "nadro_6090680530",
        "folio": "6090680530",
        "proveedor": "Nadro",
        "proveedor_ilike": "nadro",
        "fecha": "2026-10-01",
        "total": 777.49,
        "notas": (
            "Factura Nadro 6090680530 · 01-oct-2026 · UUID 2FCABA… · "
            "sucursal México Sur · Palillero · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_nd_6090680530",
        "header": (
            "Nadro · factura 6090680530 · 2026-10-01 · 10 pzas · $777.49\n"
            "-- Bepanthen = pomada regeneradora 5% 30 g EAN 7501008498798 (ficha Farmatodo/Fahorro).\n"
            "-- Budesonida LGEN Dankel = Dankial-B 0.250 mg/2 mL C/5 EAN 7502256040517.\n"
            "-- Derman 25 g EAN 354312225010 (no es el de 50 g).\n"
            "-- Histiacil NF AD = EAN canónico 7501328979502 (OCR del papel confundía dígitos).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7501008498798", "BEPANTHEN 5% PIPEL REGENE 30G POM", 2, 63.25),
            row("7502256040517", "BUDESONIDA 250MG 5X2ML AMP LGEN", 3, 88.24),
            row("354312225010", "DERMAN 25 G CRA", 2, 27.46),
            row("7501328979502", "HISTIACIL-NF AD 150ML JBE", 3, 110.45),
        ],
    },
    {
        "key": "equilibrio_446721",
        "folio": "446721",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-10-02",
        "total": 970.74,
        "notas": (
            "Ticket Equilibrio 446721 · Iztapalapa 2 · pedido online · "
            "cliente 307513 Palillero · 02-oct-2026 · lote de fábrica en papel · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_eq_446721",
        "header": (
            "Equilibrio · ticket 446721 · 2026-10-02 · sucursal Iztapalapa 2\n"
            "-- Pedido online. Total $970.74 · 6 renglones / 22 pzas.\n"
            "-- Claves EQF → EAN Levic: MAI158→785118754242 · MAV073→7503000422498 ·\n"
            "-- MAV167→7502009742392 · MAV134→7502009741487 · MAV401→7502009749421.\n"
            "-- Redalip 2 lotes (260148×3 + 260149×1). Lote sí. Caducidad NO (MMAA caja)."
        ),
        "rows": [
            row("785118754242", "MAI158 SUPRATEX DAC 1 SOL 300/600 MG 120 ML", 3, 42.80, "5K2102"),
            row("7503000422498", "MAV073 REDALIP 30 TAB 200 MG", 3, 25.21, "260148"),
            row("7503000422498", "MAV073 REDALIP 30 TAB 200 MG", 1, 25.21, "260149"),
            row("7502009742392", "MAV167 DOLTRIX 20 TAB 125/10 MG", 5, 71.69, "263123"),
            row("7502009741487", "MAV134 DOLTRIX 10 TAB 250/10 MG", 5, 56.46, "263116"),
            row("7502009749421", "MAV401 DEXPANTENOL 1 CMA 5% 30 G", 5, 20.15, "264542"),
        ],
    },
    {
        "key": "bodega_f42_83017",
        "folio": "83017",
        "proveedor": "Bodega F-42",
        "proveedor_ilike": "bodega",
        "fecha": "2026-10-02",
        "total": 309.95,
        "notas": (
            "Ticket Bodega F-42 Caja 2/83017 · 02-oct-2026 · "
            "tarjeta $309.95 · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_bf42_83017",
        "header": (
            "Bodega F-42 Ejidos del Moral · Caja 2/83017 · 2026-10-02 17:13\n"
            "-- Ticket térmico. Subtotal $267.20 + impuestos $42.75 = $309.95.\n"
            "-- Costo = P.U. impreso. EAN Grisi con dígito verificador (037…0 / 810…6).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("0378360404500", "CRA GRISI CONCHNAC P/MANOS 80 ML", 2, 43.64),
            row("8101205017656", "CRA GRISI ALOE VERA P/MANOS 80 ML", 2, 45.15),
            row("0378360405354", "RICITOS DE ORO 100ML CRA CORP LAVANDA", 2, 17.58),
            row("7501082722116", "CRA NUVEL P/MANOS SUAVES 65ML", 1, 13.49),
            row("0378360415940", "RICITOS DE ORO 100ML COLONIA AVENA Y VNLLA", 2, 19.90),
            row("7501082722123", "CRA NUVEL P/MANOS HIDRATADA 65ML", 1, 13.49),
            row("7501022104248", "CRA RICITOS DE ORO 100ML", 1, 30.47),
        ],
    },
    {
        "key": "farmalive_1028",
        "folio": "1028",
        "proveedor": "Farmalive",
        "proveedor_ilike": "farmalive",
        "fecha": "2026-10-02",
        "total": 883.96,
        "notas": (
            "Ticket Farmalive 1028 · Club Iztapalapa 1 · 02-oct-2026 · "
            "cliente FARMACAPITAL · descuento 2% · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_fl_1028",
        "header": (
            "Farmalive · ticket 1028 · 2026-10-02 16:35 · Club Iztapalapa 1\n"
            "-- 8 renglones / 26 unidades. Subtotal $902.00 − 2% $18.04 = $883.96.\n"
            "-- Costo = P.U. neto (después del 2%). Sin lote ni MMAA.\n"
            "-- Broncolin vitrolero C/100 EAN ticket 714706903182 (distinto del C/50)."
        ),
        "rows": [
            row("714706903182", "BRONCOLIN PALETA VITROLERO SURTIDO C/100 | BRONCOLIN", 1, neto(205.40)),
            row("714706918964", "PROPERLAS PROPOLEO Y EUCALIPTO 50 G | BRONCOLIN", 1, neto(28.40)),
            row("7502214985805", "COND PRUDENCE CHICLE C/5 | DKT MEXICO", 3, neto(48.60)),
            row("7502214980015", "COND PRUDENCE CLASICO C/3 | DKT MEXICO", 5, neto(33.70)),
            row("714706918940", "PROPERLAS BRONCOLIN PROP Y JENGIBRE 50 G | BRONCOLIN", 1, neto(28.40)),
            row("650240019180", "POMADA DE LA CAMPANA TEPEZCOHUITE 35 GR | GENOMMA LAB", 5, neto(24.40)),
            row("7501065628145", "POMADA DE LA CAMPANA 35 GR | GENOMMA LAB", 5, neto(24.40)),
            row("7501065628121", "POMADA DE LA CAMPANA 19 GR | GENOMMA LAB", 5, neto(16.30)),
        ],
    },
    {
        "key": "cityfarma_s328174",
        "folio": "S328174",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-10-02",
        "total": 200.46,
        "notas": (
            "Ticket Cityfarma S328174 · 02-oct-2026 · foto térmica · "
            "Pendiente de pago $200.46 · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_cf_s328174",
        "header": (
            "Cityfarma Iztapalapa · orden S328174 · 2026-10-02 17:19\n"
            "-- Ticket térmico. IVA 0%. Pendiente de pago = $200.46.\n"
            "-- Autevazen levetiracetam 1 g C/30 EAN 7506331301173 (Aurovida).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7506331301173", "AUTEVAZEN 1G LEVETIR", 2, 100.23),
        ],
    },
]


def write_dulces_sql() -> tuple[Path, Path]:
    """Mayorista de Dulces: mayoreo → piezas; Vero Mix queda 1 bolsa."""
    folio = "T620721328"
    fecha = "2026-10-02"
    total = 335.20
    proveedor = "Mayorista de Dulces"
    rows = [
        {
            "linea": 1,
            "ean": "076350614570",
            "sku": "FC-50614570",
            "snap": "ch.MINI paleta Chupa Chups 6/240pzs",
            "nombre": "Chupa Chups Mini paleta",
            "marca": "Chupa Chups",
            "presentacion": "Bolsa 240 piezas",
            "categoria": "Impulso",
            "tipo": "marca",
            "qty": 240,
            "costo": round(186.70 / 240, 4),
            "precio": 2,
            "ya": False,
            "foto": None,
            "foto_file": None,
            "forma": "Paleta",
            "laboratorio": "Perfetti",
            "principio": None,
            "concentracion": None,
            "subcategoria": None,
            "receta": False,
            "lote": None,
        },
        {
            "linea": 2,
            "ean": "",
            "sku": "FC-HS-VEROMIX15",
            "snap": "vero MIX Clasico 6/1.5kg",
            "nombre": "Vero Mix Clásico surtido",
            "marca": "Vero",
            "presentacion": "Bolsa 1.5 kg",
            "categoria": "Impulso",
            "tipo": "marca",
            "qty": 1,
            "costo": 148.50,
            "precio": 186,
            "ya": False,
            "foto": None,
            "foto_file": None,
            "forma": "Surtido",
            "laboratorio": "Vero",
            "principio": None,
            "concentracion": None,
            "subcategoria": None,
            "receta": False,
            "lote": None,
        },
    ]

    csv_path = GEN_DIR / "ticket_dulces_T620721328.csv"
    write_ticket_csv(
        csv_path,
        folio=folio,
        fecha=fecha,
        proveedor=proveedor,
        total=total,
        rows=[
            {
                "ean": r["ean"],
                "nombre": r["snap"],
                "qty": r["qty"],
                "pu": r["costo"],
                "sub": round(r["qty"] * r["costo"], 2),
                "sku": r["sku"],
                "match": "alta",
            }
            for r in rows
        ],
    )

    # Adapt to write_carga_sql shape
    ticket = {
        "key": "dulces_T620721328",
        "folio": folio,
        "proveedor": proveedor,
        "proveedor_ilike": "dulces",
        "fecha": fecha,
        "total": total,
        "notas": (
            "Nota Mayorista de Dulces T620721328 · SUC Iztapalapa II · HS Comercial · "
            "02-oct-2026 · Chupa Chups Mini 240 pzas + Vero Mix 1.5 kg · "
            "cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_dulces_t620721328",
        "header": (
            "Mayorista de Dulces Iztapalapa · nota T620721328 · 2026-10-02 16:41\n"
            "-- HS Comercial (www.hscomercial.com.mx). Total tarjeta $335.20.\n"
            "-- Chupa Chups Mini 6/240: 1 bolsa → 240 pzas mostrador · EAN 076350614570.\n"
            "-- Vero Mix Clásico 6/1.5kg: 1 bolsa 1.5 kg · sin EAN en papel (no inventar).\n"
            "-- Sin lote ni caducidad. No inventar 0000."
        ),
        "rows": [
            {
                **r,
                "pu": r["costo"],
                "sub": round(r["qty"] * r["costo"], 2),
                "match": "alta",
            }
            for r in rows
        ],
    }
    # write_carga_sql requires ean not null — use placeholder empty carefully.
    # Patch: allow empty ean by using a space-safe sentinel in temp table.
    # Override: custom SQL for dulces with nullable ean.
    sql_path = OUT_DIR / "patch_carga_dulces_T620721328.sql"
    vals = []
    for r in rows:
        ean = r["ean"] or None
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo}, {precio}, "
            "{tipo}, {cat}, {subcat}, {forma}, {marca}, {lab}, {pres}, {pa}, {conc}, "
            "{receta}, {ya}, {foto}, {foto_file}, {lote})".format(
                linea=r["linea"],
                ean=sql_str(ean),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                qty=int(r["qty"]),
                costo=f"{r['costo']:.4f}",
                precio=int(r["precio"]),
                tipo=sql_str(r["tipo"]),
                cat=sql_str(r["categoria"]),
                subcat=sql_str(r["subcategoria"]),
                forma=sql_str(r["forma"]),
                marca=sql_str(r["marca"]),
                lab=sql_str(r["laboratorio"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"]),
                conc=sql_str(r["concentracion"]),
                receta="false",
                ya="false",
                foto="null",
                foto_file="null",
                lote="null",
            )
        )

    body = f"""-- {ticket['header']}
-- 2 alta(s) stock 0. 0 ya estaban.
-- Nombres de ficha, no del ticket. Vero Mix sin EAN hasta escanear la bolsa.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_dulces_t620721328 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,4) not null,
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

insert into _fc_dulces_t620721328 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
{",\n".join(vals)};

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
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(nullif(t.ean, ''), t.sku), 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Mayorista de Dulces {folio} · {fecha} · listo para pistola',
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
from (
  select distinct on (sku) *
  from _fc_dulces_t620721328
  order by sku, linea
) t
where public.fc_buscar_producto_escaneo(t.sku) is null
  and (
    nullif(t.ean, '') is null
    or public.fc_buscar_producto_escaneo(t.ean) is null
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (sku) *
  from _fc_dulces_t620721328
  order by sku, linea
) t
where p.id = coalesce(
  case when nullif(t.ean, '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), nullif(t.ean, ''))
from (
  select distinct on (sku) *
  from _fc_dulces_t620721328
  order by sku, linea
) t
where p.id = coalesce(
  case when nullif(t.ean, '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(proveedor)},
  {sql_str(folio)},
  {sql_str(fecha)},
  {total:.2f},
  'borrador',
  {sql_str(ticket["notas"])}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(folio)}
    and coalesce(proveedor, '') ilike '%dulces%'
);

update public.recepciones
set
  total_ticket = {total:.2f},
  fecha = {sql_str(fecha)},
  proveedor = {sql_str(proveedor)},
  notas = {sql_str(ticket["notas"])},
  updated_at = now()
where folio = {sql_str(folio)}
  and coalesce(proveedor, '') ilike '%dulces%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike '%dulces%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(t.ean, ''),
  t.nombre,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_dulces_t620721328 t
join public.recepciones r
  on r.folio = {sql_str(folio)}
 and coalesce(r.proveedor, '') ilike '%dulces%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(t.ean, '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

select
  r.folio, r.proveedor, r.estado, r.total_ticket,
  count(i.*) as renglones, sum(i.cantidad) as piezas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike '%dulces%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;
"""
    sql_path.write_text(body, encoding="utf-8")
    return csv_path, sql_path


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    sql_parts: list[str] = []

    for t in TICKETS:
        # Ajuste Bodega: P.U. con 3 decimales del ticket → 2 en costo
        if t["key"] == "bodega_f42_83017":
            # Importe ticket / qty (ya redondeado arriba a 2)
            for r in t["rows"]:
                r["sub"] = round(r["qty"] * r["pu"], 2)
                r["precio"] = ceil_pvp(r["pu"], r["tipo"])

        # Farmalive / Bodega: alinear suma de renglones al total (±2¢ de redondeo)
        if t["key"] in {"farmalive_1028", "bodega_f42_83017"}:
            suma = sum(r["sub"] for r in t["rows"])
            delta = round(t["total"] - suma, 2)
            if 0 < abs(delta) <= 0.05:
                t["rows"][-1]["sub"] = round(t["rows"][-1]["sub"] + delta, 2)
                t["rows"][-1]["pu"] = round(t["rows"][-1]["sub"] / t["rows"][-1]["qty"], 2)
                t["rows"][-1]["precio"] = ceil_pvp(t["rows"][-1]["pu"], t["rows"][-1]["tipo"])

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
        sql_parts.append(sql_path.read_text(encoding="utf-8"))
        print(f"{t['folio']}: {report(t['rows'], t['total'])}")
        print(f"  → {csv_path.relative_to(ROOT)}")
        print(f"  → {sql_path.relative_to(ROOT)}")

    dulces_csv, dulces_sql = write_dulces_sql()
    sql_parts.append(dulces_sql.read_text(encoding="utf-8"))
    print(f"T620721328: dulces")
    print(f"  → {dulces_csv.relative_to(ROOT)}")
    print(f"  → {dulces_sql.relative_to(ROOT)}")

    todos = OUT_DIR / "patch_carga_tickets_20261002_TODOS.sql"
    todos.write_text(
        "-- ═══════════════════════════════════════════════════════════════\n"
        "-- TICKETS 02-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)\n"
        "-- Ver LEERME_tickets_20261002.md\n"
        "-- ═══════════════════════════════════════════════════════════════\n\n"
        + "\n\n".join(sql_parts),
        encoding="utf-8",
    )
    print(f"TODOS → {todos.relative_to(ROOT)}")

    leerme = OUT_DIR / "LEERME_tickets_20261002.md"
    leerme.write_text(
        """# Tickets Recibir · 02-oct-2026

Fotos Central de Abastos + factura Nadro (Palillero). Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Nadro 6090680530 | `patch_carga_nadro_6090680530.sql` | 10 | $777.49 |
| Equilibrio 446721 | `patch_carga_equilibrio_446721.sql` | 22 | $970.74 |
| Mayorista de Dulces T620721328 | `patch_carga_dulces_T620721328.sql` | 241 | $335.20 |
| Bodega F-42 83017 | `patch_carga_bodega_f42_83017.sql` | 11 | $309.95 |
| Farmalive 1028 | `patch_carga_farmalive_1028.sql` | 26 | $883.96 |
| Cityfarma S328174 | `patch_carga_cityfarma_s328174.sql` | 2 | $200.46 |

## Altas nuevas (stock 0)

- Dankial-B budesonida 0.250 mg/2 mL C/5 (`7502256040517`) · Nadro
- Derman crema 25 g (`354312225010`) · Nadro (distinto del 50 g)
- Broncolin paletas vitrolero surtido C/100 (`714706903182`) · Farmalive · **TODO foto**
- Broncolin Properlas propóleo/eucalipto 50 g · Properlas jengibre 50 g
- Pomada de la Campana Tepezcohuite 35 g (`650240019180`)
- Ricitos de Oro crema lavanda 100 mL · colonia avena/vainilla · **TODO foto**
- Nuvel crema manos suaves / hidratada 65 mL · **TODO foto**
- Chupa Chups Mini bolsa 240 · Vero Mix Clásico 1.5 kg · **TODO foto**
- Autevazen levetiracetam 1 g C/30 (`7506331301173`) · Cityfarma

## Notas

- Nadro: Histiacil AD EAN canónico `7501328979502` (OCR del papel confundía dígitos).
- Equilibrio trae **lote de fábrica**; caducidad = MMAA de la caja al escanear.
- Farmalive: costo = P.U. después del 2%.
- Dulces: Chupa Chups 1 bolsa → 240 pzas; Vero Mix sin EAN hasta escanear la bolsa.
- Regenerar: `python3 scripts/generar_carga_tickets_20261002.py`
""",
        encoding="utf-8",
    )
    print(f"LEERME → {leerme.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
