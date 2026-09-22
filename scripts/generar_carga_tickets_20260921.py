#!/usr/bin/env python3
"""Tickets 21-sep-2026 (fotos Central de Abastos) → cola Recibir.

6 pedidos:
  Equilibrio 445246 · Cityfarma S324509 · Farmalive 14173
  Distribuidora Mas Farmacias 48165 · El Surtidor 132862 · 132821

Costo = P.U. neto del ticket (después de descuento).
Equilibrio trae lote de fábrica; caducidad NO (MMAA de la caja).
Farmalive/Suerox: EAN canónico con dígito verificador (650…2).
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


def sku_eq(codigo: str, ean: str) -> str:
    return f"EQ-{codigo}" if codigo else sku_de(ean)


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
        "foto": foto_url(foto_file),
        "foto_file": foto_file,
    }


PRODUCTOS: dict[str, dict] = {
    # ── Equilibrio ──
    "7502216806474": p(
        "7502216806474",
        sku="EQ-ULT230",
        nombre="Levonorgestrel 1.5 mg tableta",
        marca="Ultra",
        laboratorio="Ultra",
        forma="Tableta",
        presentacion="Caja con 1 tableta",
        principio="Levonorgestrel",
        concentracion="1.5 mg",
        ya=True,
    ),
    "785118754259": p(
        "785118754259",
        sku="FC-18754259",
        nombre="Supratex levodropropizina jarabe 120 mL",
        marca="Supratex",
        laboratorio="MAVI",
        forma="Jarabe",
        presentacion="Frasco 120 mL",
        principio="Levodropropizina",
        concentracion="600 mg/100 mL",
        ya=True,
    ),
    "7502213042325": p(
        "7502213042325",
        sku="EQ-HIS075",
        nombre="Terfhicid nitrofurantoína 100 mg C/40",
        marca="Terfhicid",
        laboratorio="Farmacéutica Hispanoamericana",
        forma="Cápsula",
        presentacion="Caja con 40 cápsulas",
        principio="Nitrofurantoína",
        concentracion="100 mg",
        receta=True,
        ya=True,
    ),
    "7501249605634": p(
        "7501249605634",
        nombre="Postday levonorgestrel 0.75 mg C/2",
        marca="Postday",
        laboratorio="IFA Celtics",
        forma="Tableta",
        presentacion="Caja con 2 tabletas",
        principio="Levonorgestrel",
        concentracion="0.75 mg",
        receta=True,
    ),
    "7501125100116": p(
        "7501125100116",
        sku="FC-25100116",
        nombre="Solución CS Pisa cloruro de sodio 0.9% 250 mL",
        marca="CS Pisa",
        laboratorio="Pisa",
        forma="Solución",
        presentacion="Frasco 250 mL",
        principio="Cloruro de sodio",
        concentracion="0.9%",
        ya=True,
    ),
    "7503003406327": p(
        "7503003406327",
        nombre="Algodón plisado Quirmex 50 g",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        marca="Quirmex",
        laboratorio="Quirmex",
        forma="Algodón",
        presentacion="Bolsa 50 g",
    ),
    "7502009740992": p(
        "7502009740992",
        sku="FC-5F30F9D4",
        nombre="Clamoxin amoxicilina/clavulánico 500/125 mg C/10",
        marca="Clamoxin",
        laboratorio="MAVI",
        forma="Tableta",
        presentacion="Caja con 10 tabletas",
        principio="Amoxicilina / ácido clavulánico",
        concentracion="500/125 mg",
        receta=True,
        ya=True,
    ),
    "7502226291857": p(
        "7502226291857",
        nombre="Doxiciclina Alpharma 100 mg C/10",
        marca="Alpharma",
        laboratorio="Alpharma",
        forma="Tableta",
        presentacion="Caja con 10 tabletas",
        principio="Doxiciclina",
        concentracion="100 mg",
        receta=True,
    ),
    "7502009745836": p(
        "7502009745836",
        sku="EQ-MAV266",
        nombre="Berniver mupirocina 2% ungüento 15 g",
        marca="Berniver",
        laboratorio="Maver",
        forma="Ungüento",
        presentacion="Tubo 15 g",
        principio="Mupirocina",
        concentracion="2%",
        ya=True,
    ),
    "7502004401454": p(
        "7502004401454",
        sku="EQ-OFF010",
        nombre="Dexne oftálmico dexametasona/neomicina gotas 5 mL",
        marca="Dexne",
        laboratorio="Offenbach",
        forma="Gotas oftálmicas",
        presentacion="Frasco gotero 5 mL",
        principio="Dexametasona / neomicina",
        concentracion="500/100 mg/5 mL",
        receta=True,
        ya=True,
    ),
    "7501342803807": p(
        "7501342803807",
        sku="EQ-BEA368",
        nombre="Nifedipino 30 mg C/30 LP",
        marca="Be Advance",
        laboratorio="Be Advance",
        forma="Tableta",
        presentacion="Caja con 30 comprimidos LP",
        principio="Nifedipino",
        concentracion="30 mg",
        receta=True,
        ya=True,
    ),
    # ── Cityfarma ──
    "4015630082988": p(
        "4015630082988",
        sku="FC-30082988",
        nombre="Accu-Chek Active glucómetro",
        tipo="marca",
        categoria="Dispositivo médico",
        subcategoria="Diagnóstico",
        forma="Aparato",
        marca="Accu-Chek",
        laboratorio="Roche",
        presentacion="1 pieza",
        ya=True,
        foto_file="medidor-accu-chek-active-4015630082988.jpg",
    ),
    "4015630018277": p(
        "4015630018277",
        sku="FC-30018277",
        nombre="Accu-Chek Softclix lancetas C/25",
        tipo="marca",
        categoria="Dispositivo médico",
        subcategoria="Lancetas",
        forma="Lancetas",
        marca="Accu-Chek",
        laboratorio="Roche",
        presentacion="Caja con 25 lancetas",
        ya=True,
        foto_file="lanceta-accu-chek-softclix-25pzas-4015630018277.jpg",
    ),
    "799192067426": p(
        "799192067426",
        sku="FC-92067426",
        nombre="Accu-Chek Instant kit 50 tiras + 25 lancetas",
        tipo="marca",
        categoria="Dispositivo médico",
        subcategoria="Diagnóstico",
        forma="Kit",
        marca="Accu-Chek",
        laboratorio="Roche",
        presentacion="Kit glucómetro",
        ya=True,
        foto_file="glucometro-accu-check-instant-kit-con-50-tiras-y-799192067426.jpg",
    ),
    "7502211783787": p(
        "7502211783787",
        nombre="Erbitrax-T terbinafina 250 mg C/28",
        marca="Erbitrax-T",
        laboratorio="Loeffler",
        forma="Tableta",
        presentacion="Caja con 28 tabletas",
        principio="Terbinafina",
        concentracion="250 mg",
        receta=True,
    ),
    "7501165009486": p(
        "7501165009486",
        nombre="Lactacyd Pro-Bio shampoo íntimo 200 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene íntima",
        forma="Shampoo",
        marca="Lactacyd",
        laboratorio="Sanofi",
        presentacion="Frasco 200 mL",
    ),
    "7501065008459": p(
        "7501065008459",
        sku="FL-5008459",
        nombre="Theraflu TD rojo resfriado severo C/10",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Resfriado",
        forma="Sobres",
        marca="Theraflu",
        laboratorio="Haleon",
        presentacion="Caja con 10 sobres",
        ya=True,
    ),
    "7501065008473": p(
        "7501065008473",
        sku="FC-5008473",
        nombre="Theraflu TD limón resfriado severo C/10",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Resfriado",
        forma="Sobres",
        marca="Theraflu",
        laboratorio="Haleon",
        presentacion="Caja con 10 sobres",
        ya=True,
    ),
    "8020030091252": p(
        "8020030091252",
        nombre="Vessel Due-F sulodexida 250 LRU C/50",
        marca="Vessel Due-F",
        laboratorio="AlfaSigma",
        forma="Cápsula",
        presentacion="Caja con 50 cápsulas",
        principio="Sulodexida",
        concentracion="250 LRU",
        receta=True,
    ),
    # ── Farmalive ──
    "7506306215689": p(
        "7506306215689",
        nombre="Ego Alfa Control caída gel 200 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Capilar",
        forma="Gel",
        marca="Ego",
        laboratorio="Unilever",
        presentacion="Frasco 200 mL",
    ),
    "7501033956331": p(
        "7501033956331",
        sku="FC-33950063",
        nombre="Pediasure Plus líquido fresa 237 mL",
        tipo="marca",
        categoria="Suplemento",
        forma="Líquido",
        marca="Pediasure",
        laboratorio="Abbott",
        presentacion="Frasco 237 mL",
        ya=True,
        foto_file="pediasure-plus-vainilla-237ml.jpg",
    ),
    "7501033956317": p(
        "7501033956317",
        sku="FC-33951008",
        nombre="Pediasure Plus líquido chocolate 237 mL",
        tipo="marca",
        categoria="Suplemento",
        forma="Líquido",
        marca="Pediasure",
        laboratorio="Abbott",
        presentacion="Frasco 237 mL",
        ya=True,
        foto_file="pediasure-plus-chocolate-237ml.jpg",
    ),
    "7501033956294": p(
        "7501033956294",
        sku="FC-33950209",
        nombre="Pediasure Plus líquido vainilla 237 mL",
        tipo="marca",
        categoria="Suplemento",
        forma="Líquido",
        marca="Pediasure",
        laboratorio="Abbott",
        presentacion="Frasco 237 mL",
        ya=True,
        foto_file="pediasure-plus-vainilla-237ml.jpg",
    ),
    "7501033954085": p(
        "7501033954085",
        sku="FC-33954085",
        nombre="Ensure líquido vainilla 237 mL",
        tipo="marca",
        categoria="Suplemento",
        forma="Líquido",
        marca="Ensure",
        laboratorio="Abbott",
        presentacion="Frasco 237 mL",
        ya=True,
        foto_file="ensure-singles-fresa-237ml.jpg",
    ),
    "7501033954061": p(
        "7501033954061",
        sku="FC-33954061",
        nombre="Ensure líquido chocolate 237 mL",
        tipo="marca",
        categoria="Suplemento",
        forma="Líquido",
        marca="Ensure",
        laboratorio="Abbott",
        presentacion="Frasco 237 mL",
        ya=True,
        foto_file="ensure-singles-chocolate-237ml.jpg",
    ),
    "7501019006647": p(
        "7501019006647",
        nombre="Saba buenas noches delgada C/10",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene femenina",
        forma="Toallas",
        marca="Saba",
        laboratorio="SCA",
        presentacion="Paquete 10 toallas",
    ),
    "6502400744552": p(
        "6502400744552",
        sku="FC-40074455",
        nombre="Suerox 8 iones uva mora azul 630 mL",
        categoria="Bebidas",
        subcategoria="Electrolitos",
        forma="Bebida",
        marca="Suerox",
        laboratorio="Genomma Lab",
        presentacion="Botella 630 mL",
        ya=True,
    ),
    "6502400322571": p(
        "6502400322571",
        sku="FC-00322571",
        nombre="Suerox 8 iones manzana 630 mL",
        categoria="Bebidas",
        subcategoria="Electrolitos",
        forma="Bebida",
        marca="Suerox",
        laboratorio="Genomma Lab",
        presentacion="Botella 630 mL",
        ya=True,
    ),
    "6502400721471": p(
        "6502400721471",
        sku="FC-00721471",
        nombre="Suerox Vitamins naranja-mango 630 mL",
        categoria="Bebidas",
        subcategoria="Electrolitos",
        forma="Bebida",
        marca="Suerox",
        laboratorio="Genomma Lab",
        presentacion="Botella 630 mL",
        ya=True,
    ),
    "6502400322712": p(
        "6502400322712",
        sku="FC-40032271",
        nombre="Suerox 8 iones uva 630 mL",
        categoria="Bebidas",
        subcategoria="Electrolitos",
        forma="Bebida",
        marca="Suerox",
        laboratorio="Genomma Lab",
        presentacion="Botella 630 mL",
        ya=True,
    ),
    "6502400721541": p(
        "6502400721541",
        sku="FC-00721541",
        nombre="Suerox Vitamins manzana y limón 630 mL",
        categoria="Bebidas",
        subcategoria="Electrolitos",
        forma="Bebida",
        marca="Suerox",
        laboratorio="Genomma Lab",
        presentacion="Botella 630 mL",
        ya=True,
    ),
    "7500435231237": p(
        "7500435231237",
        sku="FC-35231237",
        nombre="Head & Shoulders anti comezón shampoo 375 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Capilar",
        forma="Shampoo",
        marca="Head & Shoulders",
        laboratorio="P&G",
        presentacion="Frasco 375 mL",
        ya=True,
    ),
    "7500435162586": p(
        "7500435162586",
        nombre="Head & Shoulders protección caída shampoo 650 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Capilar",
        forma="Shampoo",
        marca="Head & Shoulders",
        laboratorio="P&G",
        presentacion="Frasco 650 mL",
    ),
    "7500435249348": p(
        "7500435249348",
        nombre="Head & Shoulders anti resequedad shampoo 375 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Capilar",
        forma="Shampoo",
        marca="Head & Shoulders",
        laboratorio="P&G",
        presentacion="Frasco 375 mL",
    ),
    "7891051037878": p(
        "7891051037878",
        sku="FC-51037878",
        nombre="Oral-B Complete enjuague bucal 250 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Enjuague",
        marca="Oral-B",
        laboratorio="P&G",
        presentacion="Botella 250 mL",
        ya=True,
        foto_file="oral-b-enjuague-complet-250ml.jpg",
    ),
    "7500435231244": p(
        "7500435231244",
        sku="FC-35231244",
        nombre="Head & Shoulders anti comezón shampoo 180 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Capilar",
        forma="Shampoo",
        marca="Head & Shoulders",
        laboratorio="P&G",
        presentacion="Frasco 180 mL",
        ya=True,
    ),
    "7503003406181": p(
        "7503003406181",
        nombre="Cinta micropore Quirmex blanca 2.5 cm × 10 m",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Cinta",
        marca="Quirmex",
        laboratorio="Quirmex",
        presentacion="Rollo 2.5 cm × 10 m",
    ),
    "7506022301789": p(
        "7506022301789",
        nombre="Jeringa Sensimedical 3 mL azul C/100",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material médico",
        forma="Jeringas",
        marca="Sensimedical",
        laboratorio="Jayor",
        presentacion="Caja 100 jeringas 3 mL",
    ),
    # ── Mas Farmacias ──
    "7502211783671": p(
        "7502211783671",
        nombre="Erbitrax-T terbinafina 250 mg C/40",
        marca="Erbitrax-T",
        laboratorio="Loeffler",
        forma="Tableta",
        presentacion="Caja con 40 tabletas",
        principio="Terbinafina",
        concentracion="250 mg",
        receta=True,
    ),
    # ── El Surtidor ──
    "7502004401409": p(
        "7502004401409",
        sku="EQ-OFF008",
        nombre="Dexne nasal fenilefrina/dexametasona/neomicina gotas 10 mL",
        marca="Dexne",
        laboratorio="Offenbach",
        forma="Gotas nasales",
        presentacion="Frasco gotero 10 mL",
        principio="Fenilefrina / dexametasona / neomicina",
        receta=True,
        ya=True,
    ),
    "7502004401508": p(
        "7502004401508",
        sku="EQ-OFF009",
        nombre="Dexne ótico dexametasona/neomicina/lidocaína gotas 10 mL",
        marca="Dexne",
        laboratorio="Offenbach",
        forma="Gotas óticas",
        presentacion="Frasco gotero 10 mL",
        principio="Dexametasona / neomicina / lidocaína",
        receta=True,
        ya=True,
    ),
    "7501409601018": p(
        "7501409601018",
        nombre="Lysol desinfectante Crisp Linen 354 g",
        tipo="marca",
        categoria="Higiene",
        subcategoria="Desinfectante",
        forma="Aerosol",
        marca="Lysol",
        laboratorio="Reckitt",
        presentacion="Aerosol 354 g",
        foto_file="lysol-crisp-linen-354g.jpg",
    ),
    "7501058796882": p(
        "7501058796882",
        sku="FC-58796882",
        nombre="Lysol desinfectante Crisp Linen 475 g",
        tipo="marca",
        categoria="Higiene",
        subcategoria="Desinfectante",
        forma="Aerosol",
        marca="Lysol",
        laboratorio="Reckitt",
        presentacion="Aerosol 475 g",
        ya=True,
        foto_file="lysol-crisp-linen-475g.jpg",
    ),
}


def row(
    ean: str,
    snap: str,
    qty: int,
    pu: float,
    lote: str | None = None,
) -> dict:
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


TICKETS = [
    {
        "key": "equilibrio_445246",
        "folio": "445246",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-09-21",
        "total": 1612.20,
        "notas": (
            "Ticket Equilibrio 445246 · Iztapalapa 2 · pedido online · "
            "cliente 307513 Palillero · 21-sep-2026 · lote de fábrica en papel · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_eq_445246",
        "header": (
            "Equilibrio · ticket 445246 · 2026-09-21 · sucursal Iztapalapa 2\n"
            "-- Pedido online. Total $1,612.20 · 12 renglones / 42 pzas.\n"
            "-- Claves EQF → EAN Levic/ficha. Postday 2 comp = 7501249605634.\n"
            "-- Lote de fábrica sí. Caducidad NO: MMAA de la caja. 0000 inválido."
        ),
        "rows": [
            row("7502216806474", "ULT230 LEVONORGESTREL 1 TAB 1.5 MG", 5, 15.61, "6EH152A"),
            row("785118754259", "MAI157 SUPRATEX 1 JBE 600 MG 120 ML", 3, 41.30, "6B0201"),
            row("7502213042325", "HIS075 TERFHICID 40 CAPS 100 MG", 3, 46.05, "6F719"),
            row("7501249605634", "IFA002 POSTDAY 2 COMP 0.75 MG", 9, 48.57, "2510245"),
            row("7501125100116", "PIS103 SOLUCION CLORURO DE SODIO 0.9%/250 ML", 3, 26.50, "P26E310"),
            row("7503003406327", "QIR002 ALGODON PLISADO 1 BOL 50 G", 3, 8.23, "A3361326"),
            row("7502009740992", "MAV111 CLAMOXIN 10 TAB 500/125 MG", 2, 48.51, "262922"),
            row("7502226291857", "ALP0559 DOXICICLINA 10 TAB 100 MG", 3, 29.08, "2511579"),
            row("7502009745836", "MAV266 BERNIVER 2% 1 UNG 15 G", 3, 76.79, "260074"),
            row("7502004401454", "OFF010 DEXNE OFTALMICO 1 GOT 500/100MG/5 ML", 2, 33.74, "265030"),
            row("7501342803807", "BEA368 NIFEDIPINO 30 COMP 30 MG", 5, 39.23, "6EN186A"),
            row("7501249605634", "IFA002 POSTDAY 2 COMP 0.75 MG", 1, 48.57, "2603328"),
        ],
    },
    {
        "key": "cityfarma_s324509",
        "folio": "S324509",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-09-21",
        "total": 2855.11,
        "notas": (
            "Ticket Cityfarma S324509 · 21-sep-2026 · foto térmica · "
            "Pendiente de pago $2,855.11 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_cf_s324509",
        "header": (
            "Cityfarma Iztapalapa · orden S324509 · 2026-09-21 16:52\n"
            "-- Ticket térmico. Subtotal $2,663.37 + IVA 16% $191.74 = $2,855.11.\n"
            "-- Erbitrax C/28 EAN 7502211783787 · Vessel Due-F 8020030091252 alta.\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("4015630082988", "ACCU CHEK EQ ACTIVE", 1, 499.99),
            row("4015630018277", "ACCU CHEK SOFTCLIX C", 2, 72.42),
            row("799192067426", "ACCU-CHEK EQ INSTANT", 1, 681.33),
            row("7502211783787", "ERBITRAX T 250MG C28", 2, 112.50),
            row("7501165009486", "LACTACYD PRO BIO SH", 1, 63.95),
            row("7501065008459", "THERAFLU TD ROJO C10", 2, 170.23),
            row("7501065008473", "THERAFLU VERDE C10 S", 2, 161.77),
            row("8020030091252", "VESSEL DUE F 250 CAP", 1, 576.00),
        ],
    },
    {
        "key": "farmalive_14173",
        "folio": "14173",
        "proveedor": "Farmalive",
        "proveedor_ilike": "farmalive",
        "fecha": "2026-09-21",
        "total": 1538.69,
        "notas": (
            "Ticket Farmalive 14173 · Club Iztapalapa 1 · 21-sep-2026 · "
            "precio neto (2–7% desc.) · Suerox EAN canónico 650…2 · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_fl_14173",
        "header": (
            "Farmalive · ticket 14173 · 2026-09-21 17:25 · Club Iztapalapa 1\n"
            "-- Total $1,538.69 · 19 artículos / 39 unidades.\n"
            "-- Ticket trunca Suerox a 12 dígitos; pistola = EAN 650…2 del catálogo.\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7506306215689", "GEL EGO ALFA CONT CAIDA 200 ML | UNILEVER", 3, 17.21),
            row("7501033956331", "PEDIASURE PLUS LIQ FRESA 237 ML | ABBOTT", 2, 46.08),
            row("7501033956317", "PEDIASURE PLUS LIQ CHOCOLATE 237 ML | ABBOTT", 2, 46.08),
            row("7501033956294", "PEDIASURE PLUS LIQ VAINILLA 237 ML | ABBOTT", 2, 46.08),
            row("7501033954085", "ENSURE LIQ VAINILLA 237 ML | ABBOTT", 4, 42.63),
            row("7501033954061", "ENSURE LIQ CHOCOLATE 237 ML | ABBOTT", 4, 42.63),
            row("7501019006647", "TOA SANIT SABA U DELGADA NOCT C/A 10 | SCA", 2, 29.83),
            row("6502400744552", "SUEROX 8 IONES UVA MORA AZUL 630 ML | GENOMMA LAB", 2, 14.73),
            row("6502400322571", "SUEROX 8 IONES MANZANA 630 ML | GENOMMA LAB", 2, 14.73),
            row("6502400721471", "SUEROX VITAMINS NARANJA-MANGO 630 ML | GENOMMA LAB", 2, 14.73),
            row("6502400322712", "SUEROX 8 IONES UVA 630 ML | GENOMMA LAB", 2, 14.73),
            row("6502400721541", "SUEROX VITAMINS MANZANA V-LIMON 630 ML | GENOMMA LAB", 2, 14.73),
            row("7500435231237", "SHAM HEAD & S ANTI-COMEZON 375 ML | PG PERF", 1, 86.07),
            row("7500435162586", "SHAM HEAD & S PROT CAIDA 650 ML | PG PERF", 1, 123.03),
            row("7500435249348", "SHAM HEAD & S ANTI RESEQUEDAD 375 ML | PG PERF", 1, 86.07),
            row("7891051037878", "ENJ BUCAL ORAL B COMPLET 250 ML | PG PERF", 2, 47.75),
            row("7500435231244", "SHAM HEAD & S ANTI-COMEZON 180 ML | PG PERF", 2, 39.43),
            row("7503003406181", "CINTA MICROPOR QUIRMEX BCO 2.5CMX10M | QUIRMEX", 2, 16.83),
            row("7506022301789", "JERINGA SENSIMEDICAL 3 ML AZUL C/100 | JAYOR", 1, 159.50),
        ],
    },
    {
        "key": "mas_farmacias_48165",
        "folio": "48165",
        "proveedor": "Distribuidora Mas Farmacias",
        "proveedor_ilike": "mas farmacias",
        "fecha": "2026-09-21",
        "total": 646.50,
        "notas": (
            "Ticket Distribuidora Mas Farmacias 48165 · Central de Abastos · "
            "21-sep-2026 · tarjeta $646.50 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_mf_48165",
        "header": (
            "Distribuidora Mas Farmacias · folio 48165 · 2026-09-21 17:17\n"
            "-- Ticket imprimió 007502211783671 → EAN 7502211783671 (Erbitrax C/40).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7502211783671", "ERBITRAX 250MG 40TAB", 4, 161.62),
        ],
    },
    {
        "key": "surtidor_132862",
        "folio": "132862",
        "proveedor": "El Surtidor de su Farmacia",
        "proveedor_ilike": "surtidor",
        "fecha": "2026-09-21",
        "total": 222.00,
        "notas": (
            "Ticket El Surtidor venta 132862 · Bodega F48 · 21-sep-2026 · "
            "75% desc. Dexne · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_sur132862",
        "header": (
            "El Surtidor de su Farmacia · venta 132862 · 2026-09-21 17:07\n"
            "-- Costo = total renglón / qty (después del 75% desc.).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7502004401409", "DEXNE GTS NASAL", 2, 41.25),
            row("7502004401508", "DEXNE GTS OT 10ML DEXAMETASONA+NEOM+LIDO", 3, 46.50),
        ],
    },
    {
        "key": "surtidor_132821",
        "folio": "132821",
        "proveedor": "El Surtidor de su Farmacia",
        "proveedor_ilike": "surtidor",
        "fecha": "2026-09-21",
        "total": 720.01,
        "notas": (
            "Ticket El Surtidor venta 132821 · Bodega F48 · 21-sep-2026 · "
            "Lysol 354 g / 475 g · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_sur132821",
        "header": (
            "El Surtidor de su Farmacia · venta 132821 · 2026-09-21\n"
            "-- Lysol chico 354 g EAN 7501409601018 · grande 475 g 7501058796882.\n"
            "-- Sin lote ni caducidad. No inventar 0000."
        ),
        "rows": [
            row("7501409601018", "SPRAY LYSOL CHICO 354GR", 2, 100.01),
            row("7501058796882", "SPRAY LYSOL GRANDE 475GR", 4, 130.00),
        ],
    },
]


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    for t in TICKETS:
        suma = sum(r["sub"] for r in t["rows"])
        piezas = sum(r["qty"] for r in t["rows"])
        diff = abs(suma - t["total"])
        # Equilibrio: IVA aparte en algodón. Farmalive: % por línea redondea ±centavos.
        ok_diff = (
            (t["proveedor_ilike"] == "equilibrio" and diff < 10)
            or (t["proveedor_ilike"] == "farmalive" and diff < 0.15)
        )
        if diff > 0.05 and not ok_diff:
            raise SystemExit(
                f"{t['folio']}: suma ${suma:.2f} != total ${t['total']:.2f} (piezas {piezas})"
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
        altas = sum(1 for r in t["rows"] if not r["ya"])
        print(f"{t['folio']}: {report(t['rows'], t['total'])} · {piezas} pzas · {altas} altas")
        print(f"  → {csv_path.relative_to(ROOT)}")
        print(f"  → {sql_path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
