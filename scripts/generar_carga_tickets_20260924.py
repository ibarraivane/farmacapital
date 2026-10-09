#!/usr/bin/env python3
"""Tickets 24-sep-2026 (fotos Central de Abastos) → cola Recibir.

8 pedidos:
  Cityfarma S325583 · El Surtidor 134730 · IFC 125448 · IFC 125445
  Equilibrio 445679 · Farma Mayoreo 306277 · Farmalive 13395 · Nadro 605425063

Farma Mayoreo viene en 3 fotos (inicio / medio / final con sobreimpresión).
Reconstruido por renglones: 30 arts / 55 pzas / total $2,978.43.
Kotex tampones (línea sobreimpresa): EAN 7506425625536 (Unika Regular C/12).

Costo = P.U. del ticket.
  Cityfarma/Equilibrio: P.U. neto; total_ticket incluye IVA del papel.
  Farma Mayoreo/Surtidor/IFC: suma renglones ≈ total (P.U. ya con IVA o sin desglose).
Equilibrio trae lote de fábrica; caducidad NO (MMAA de la caja).
Nombres de ficha, no del código del ticket. Sin caducidad inventada (0000 inválido).
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
from generar_recepcion_borrador import write_recepcion_sql

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


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
        "foto_file": f"catalogo-propia/{foto_file}" if foto_file else None,
    }


PRODUCTOS: dict[str, dict] = {
    # ── Cityfarma ──
    "4015630064076": p(
        "4015630064076",
        nombre="Accu-Chek Active tiras reactivas C/50",
        tipo="marca",
        categoria="Dispositivo médico",
        subcategoria="Diagnóstico",
        forma="Tiras",
        marca="Accu-Chek",
        laboratorio="Roche",
        presentacion="Caja con 50 tiras",
        ya=True,
        foto_file="tiras-reactivas-accu-chek-active-50pzas-4015630064076.jpg",
    ),
    "7501008494226": p(
        "7501008494226",
        sku="FC-08494226",
        nombre="Aspirina Junior ácido acetilsalicílico 100 mg C/60",
        tipo="marca",
        marca="Aspirina",
        laboratorio="Bayer",
        forma="Tableta masticable",
        presentacion="Caja con 60 tabletas",
        principio="Ácido acetilsalicílico",
        concentracion="100 mg",
        ya=True,
    ),
    "7502001166066": p(
        "7502001166066",
        sku="FC-01166066",
        nombre="Barmicil compuesto crema 40 g",
        tipo="marca",
        marca="Barmicil",
        laboratorio="Son's",
        forma="Crema",
        presentacion="Tubo 40 g",
        principio="Betametasona / Gentamicina / Clotrimazol",
        ya=True,
    ),
    "7502308871274": p(
        "7502308871274",
        nombre="Baumanómetro digital de muñeca HomeCare KF-75D Plus",
        tipo="marca",
        categoria="Dispositivo médico",
        subcategoria="Diagnóstico",
        forma="Aparato",
        marca="HomeCare",
        presentacion="1 pieza",
    ),
    "7501075710786": p(
        "7501075710786",
        sku="EQ-NOV004",
        nombre="Cirulan metoclopramida 10 mg C/20",
        marca="Cirulan",
        laboratorio="Novag",
        forma="Tableta",
        presentacion="Caja con 20 tabletas",
        principio="Metoclopramida",
        concentracion="10 mg",
        receta=True,
        ya=True,
    ),
    "7502225094275": p(
        "7502225094275",
        nombre="Hipebe tamsulosina 0.4 mg C/20",
        marca="Hipebe",
        laboratorio="Landsteiner",
        forma="Cápsula",
        presentacion="Caja con 20 cápsulas",
        principio="Tamsulosina",
        concentracion="0.4 mg",
        receta=True,
    ),
    "7501573902720": p(
        "7501573902720",
        nombre="Menazan miconazol 2% crema 20 g",
        marca="Menazan",
        laboratorio="Biomep",
        forma="Crema",
        presentacion="Tubo 20 g",
        principio="Nitrato de miconazol",
        concentracion="2%",
    ),
    # ── Surtidor ──
    "7501677620056": p(
        "7501677620056",
        sku="FC-77620056",
        nombre="Agua destilada La Flor 1 L",
        tipo="marca",
        categoria="Botiquín",
        marca="La Flor",
        forma="Agua destilada",
        presentacion="1 L",
        ya=True,
    ),
    # ── Equilibrio ──
    "7502214985805": p(
        "7502214985805",
        sku="FC-14985805",
        nombre="Prudence Chicle condones C/5",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        marca="Prudence",
        laboratorio="DKT",
        forma="Condón",
        presentacion="Caja con 5 piezas",
        ya=True,
    ),
    "7503004908738": p(
        "7503004908738",
        sku="FC-04908738",
        nombre="Lidocaína unguento 5% tubo 35 g",
        marca="Alpharma",
        laboratorio="Alpharma",
        forma="Ungüento",
        presentacion="Tubo 35 g",
        principio="Lidocaína",
        concentracion="5%",
        ya=True,
    ),
    "7501075723137": p(
        "7501075723137",
        sku="FC-75723137",
        nombre="Novakosid senósidos A-B 8.6 mg C/20",
        marca="Novakosid",
        laboratorio="Novag",
        forma="Tableta",
        presentacion="Caja con 20 tabletas",
        principio="Senósidos A-B",
        concentracion="8.6 mg",
        ya=True,
    ),
    "7502009748912": p(
        "7502009748912",
        sku="EQ-MAV380",
        nombre="Esomeprazol 40 mg C/14",
        marca="Maver",
        laboratorio="Maver",
        forma="Tableta",
        presentacion="Caja con 14 tabletas",
        principio="Esomeprazol",
        concentracion="40 mg",
        receta=True,
        ya=True,
    ),
    "0780083144302": p(
        "0780083144302",
        sku="FC-83144302",
        nombre="Collifrin Adulto oximetazolina 0.05% 20 mL",
        marca="Collifrin",
        laboratorio="Collins",
        forma="Solución nasal",
        presentacion="Frasco 20 mL",
        principio="Oximetazolina",
        concentracion="0.05%",
        ya=True,
    ),
    "7502214982491": p(
        "7502214982491",
        sku="FC-49824911",
        nombre="Prudence Uva condones C/3",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        marca="Prudence",
        laboratorio="DKT",
        forma="Condón",
        presentacion="Caja con 3 piezas",
        ya=True,
    ),
    "7502214980275": p(
        "7502214980275",
        sku="FC-4980275",
        nombre="Prudence Soda condones C/3",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        marca="Prudence",
        laboratorio="DKT",
        forma="Condón",
        presentacion="Caja con 3 piezas",
        ya=True,
    ),
    "7502214982514": p(
        "7502214982514",
        sku="FC-14982514",
        nombre="Prudence Chocolate condones C/3",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        marca="Prudence",
        laboratorio="DKT",
        forma="Condón",
        presentacion="Caja con 3 piezas",
        ya=True,
    ),
    "7502214983207": p(
        "7502214983207",
        sku="FC-14983207",
        nombre="Prudence lubricante uva 75 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        marca="Prudence",
        laboratorio="DKT",
        forma="Gel",
        presentacion="Frasco 75 mL",
        ya=True,
        foto_file="prudence-lub-uva-75ml.jpg",
    ),
    "7502009749292": p(
        "7502009749292",
        sku="EQ-MAV415",
        nombre="Esomeprazol 40 mg C/28",
        marca="Maver",
        laboratorio="Maver",
        forma="Tableta",
        presentacion="Caja con 28 tabletas",
        principio="Esomeprazol",
        concentracion="40 mg",
        receta=True,
        ya=True,
    ),
    # ── Farma Mayoreo ──
    "3014260279264": p(
        "3014260279264",
        nombre="Oral-B Stages cepillo dental infantil 3+ Disney/Pixar",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        marca="Oral-B",
        laboratorio="P&G",
        forma="Cepillo",
        presentacion="1 pieza",
    ),
    "3014260278922": p(
        "3014260278922",
        nombre="Oral-B Stages cepillo dental infantil 3+ Frozen",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        marca="Oral-B",
        laboratorio="P&G",
        forma="Cepillo",
        presentacion="1 pieza",
    ),
    "7501050623766": p(
        "7501050623766",
        sku="FC-05062376",
        nombre="Afrin No Drip solución nasal 15 mL",
        tipo="marca",
        marca="Afrin",
        laboratorio="Bayer",
        forma="Solución nasal",
        presentacion="Frasco 15 mL",
        principio="Oximetazolina",
        ya=True,
    ),
    "7501050624732": p(
        "7501050624732",
        sku="FC-06247327",
        nombre="Afrin No Drip spray nasal extra humectante 15 mL",
        tipo="marca",
        marca="Afrin",
        laboratorio="Bayer",
        forma="Spray nasal",
        presentacion="Frasco 15 mL",
        principio="Oximetazolina",
        ya=True,
    ),
    "7500435246309": p(
        "7500435246309",
        sku="FC-35246309",
        nombre="Vick Drops jengibre pastillas C/20",
        tipo="marca",
        categoria="Botiquín",
        marca="Vick",
        laboratorio="P&G",
        forma="Pastilla",
        presentacion="C/20",
        ya=True,
    ),
    "7509546072272": p(
        "7509546072272",
        nombre="Colgate Kids pasta dental",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        marca="Colgate",
        forma="Pasta dental",
        presentacion="Tubo",
    ),
    "7891024034095": p(
        "7891024034095",
        nombre="Colgate Kids pasta dental (import)",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        marca="Colgate",
        forma="Pasta dental",
        presentacion="Tubo",
    ),
    "7501054550150": p(
        "7501054550150",
        nombre="Curitas animales apósitos adhesivos",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        marca="Curitas",
        laboratorio="Johnson & Johnson",
        forma="Apósito",
        presentacion="Caja",
    ),
    "7501048623044": p(
        "7501048623044",
        nombre="Pads faciales Protec con glicerina",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        marca="Protec",
        forma="Pads",
        presentacion="Bolsa",
    ),
    "7501943490598": p(
        "7501943490598",
        sku="FC-43490598",
        nombre="Jabón líquido Escudo para manos",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        marca="Escudo",
        laboratorio="P&G",
        forma="Jabón líquido",
        ya=True,
        foto_file="escudo-jabon-liquido.jpg",
    ),
    "7590002037843": p(
        "7590002037843",
        nombre="Vick Pyrena miel jarabe",
        tipo="marca",
        marca="Vick",
        laboratorio="P&G",
        forma="Jarabe",
        presentacion="Frasco",
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
    "7501125115479": p(
        "7501125115479",
        nombre="Solución CS Pisa cloruro de sodio 0.9% 100 mL",
        marca="CS Pisa",
        laboratorio="Pisa",
        forma="Solución",
        presentacion="Frasco 100 mL",
        principio="Cloruro de sodio",
        concentracion="0.9%",
    ),
    "7503017500769": p(
        "7503017500769",
        nombre="Jabón líquido para manos (variante A)",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        forma="Jabón líquido",
        presentacion="Botella",
    ),
    "7503017500776": p(
        "7503017500776",
        nombre="Jabón líquido para manos (variante B)",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        forma="Jabón líquido",
        presentacion="Botella",
    ),
    "7503017500783": p(
        "7503017500783",
        nombre="Jabón líquido para manos (variante C)",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        forma="Jabón líquido",
        presentacion="Botella",
    ),
    "7501088509766": p(
        "7501088509766",
        sku="FC-85097661",
        nombre="Antiflu-Des Junior jarabe infantil 60 mL",
        tipo="marca",
        marca="Antiflu-Des",
        laboratorio="Chinoin",
        forma="Jarabe",
        presentacion="Frasco 60 mL",
        ya=True,
    ),
    "7501065085191": p(
        "7501065085191",
        nombre="Voltaren Emulgel diclofenaco 1% 50 g",
        tipo="marca",
        marca="Voltaren",
        laboratorio="GSK",
        forma="Gel",
        presentacion="Tubo 50 g",
        principio="Diclofenaco",
        concentracion="1%",
    ),
    "7501088509810": p(
        "7501088509810",
        sku="FL-8509810",
        nombre="Antiflu-Des pediátrico solución 30 mL",
        tipo="marca",
        marca="Antiflu-Des",
        laboratorio="Chinoin",
        forma="Solución",
        presentacion="Frasco 30 mL",
        ya=True,
        foto_file="antiflu-des-pediatrico-30ml.jpg",
    ),
    "7501065024688": p(
        "7501065024688",
        nombre="Voltaren Dolo 25 mg C/20",
        tipo="marca",
        marca="Voltaren",
        laboratorio="GSK",
        forma="Tableta",
        presentacion="Caja con 20 tabletas",
        principio="Diclofenaco",
        concentracion="25 mg",
    ),
    "7501065085528": p(
        "7501065085528",
        nombre="Voltaren Emulgel diclofenaco 1% 100 g",
        tipo="marca",
        marca="Voltaren",
        laboratorio="GSK",
        forma="Gel",
        presentacion="Tubo 100 g",
        principio="Diclofenaco",
        concentracion="1%",
    ),
    "7509546068558": p(
        "7509546068558",
        nombre="Colgate cepillo dental",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        marca="Colgate",
        forma="Cepillo",
        presentacion="1 pieza",
    ),
    "7509546079493": p(
        "7509546079493",
        nombre="Colgate cepillos dentales (pack)",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        marca="Colgate",
        forma="Cepillo",
        presentacion="Pack",
    ),
    "7509546066776": p(
        "7509546066776",
        nombre="Colgate crema dental",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        marca="Colgate",
        forma="Pasta dental",
        presentacion="Tubo",
    ),
    "7500435246293": p(
        "7500435246293",
        nombre="Vick Drops caramelo mentol pastillas",
        tipo="marca",
        categoria="Botiquín",
        marca="Vick",
        laboratorio="P&G",
        forma="Pastilla",
        presentacion="Caja",
    ),
    "7500435246286": p(
        "7500435246286",
        nombre="Vick Drops caramelo mentol pastillas (lote B)",
        tipo="marca",
        categoria="Botiquín",
        marca="Vick",
        laboratorio="P&G",
        forma="Pastilla",
        presentacion="Caja",
    ),
    "7501943493940": p(
        "7501943493940",
        nombre="Toallitas húmedas Escudo",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        marca="Escudo",
        laboratorio="P&G",
        forma="Toallitas",
        presentacion="Paquete",
    ),
    "7506425625536": p(
        "7506425625536",
        nombre="Kotex Unika tampones regular C/12",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene íntima",
        marca="Kotex",
        forma="Tampones",
        presentacion="Caja con 12",
    ),
    "7501417515956": p(
        "7501417515956",
        nombre="Bocasan Econopack polvo",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        marca="Bocasan",
        forma="Polvo",
        presentacion="Caja",
    ),
    "7506195102640": p(
        "7506195102640",
        nombre="Vick Pyrena manzana jarabe",
        tipo="marca",
        marca="Vick",
        laboratorio="P&G",
        forma="Jarabe",
        presentacion="Frasco",
    ),
    # IFC con EAN conocido (Protec Tensolastic)
    "7501048690909": p(
        "7501048690909",
        sku="FC-48690909",
        nombre="Venda elástica Protec Tensolastic Plus 7 cm × 5 m",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        marca="Protec",
        forma="Venda",
        presentacion="7 cm × 5 m",
        ya=True,
    ),
    # ── Farmalive 13395 ──
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
    "6502400663068": p(
        "6502400663068",
        sku="FC-40066306",
        nombre="Suerox 8 iones fresa 630 mL",
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
    "7501033956690": p(
        "7501033956690",
        sku="FC-33956690",
        nombre="Pedialyte SR45 fresa 500 mL",
        tipo="marca",
        categoria="Bebidas",
        subcategoria="Electrolitos",
        forma="Suero oral",
        marca="Pedialyte",
        laboratorio="Abbott",
        presentacion="Frasco 500 mL",
        ya=True,
    ),
    "7501033954740": p(
        "7501033954740",
        sku="FC-33954740",
        nombre="Pedialyte SR60 manzana 500 mL",
        tipo="marca",
        categoria="Bebidas",
        subcategoria="Electrolitos",
        forma="Suero oral",
        marca="Pedialyte",
        laboratorio="Abbott",
        presentacion="Frasco 500 mL",
        ya=True,
    ),
    "7501033956775": p(
        "7501033956775",
        sku="FC-33956775",
        nombre="Pedialyte SR60 uva 500 mL",
        tipo="marca",
        categoria="Bebidas",
        subcategoria="Electrolitos",
        forma="Suero oral",
        marca="Pedialyte",
        laboratorio="Abbott",
        presentacion="Frasco 500 mL",
        ya=True,
    ),
    "7509546058962": p(
        "7509546058962",
        nombre="Caprice Naturals sábila spray 316 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Capilar",
        forma="Spray",
        marca="Caprice",
        laboratorio="Colgate-Palmolive",
        presentacion="316 mL",
    ),
    "7509546058979": p(
        "7509546058979",
        nombre="Caprice algas spray 316 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Capilar",
        forma="Spray",
        marca="Caprice",
        laboratorio="Colgate-Palmolive",
        presentacion="316 mL",
    ),
    "7509546058986": p(
        "7509546058986",
        nombre="Caprice kiwi lavanda spray 316 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Capilar",
        forma="Spray",
        marca="Caprice",
        laboratorio="Colgate-Palmolive",
        presentacion="316 mL",
    ),
    "7509546059006": p(
        "7509546059006",
        nombre="Caprice granada spray 316 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Capilar",
        forma="Spray",
        marca="Caprice",
        laboratorio="Colgate-Palmolive",
        presentacion="316 mL",
    ),
    "7891024179925": p(
        "7891024179925",
        nombre="Colgate PerioGard enjuague bucal 250 mL",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        forma="Enjuague",
        marca="Colgate",
        laboratorio="Colgate-Palmolive",
        presentacion="250 mL",
    ),
    "7502275701659": p(
        "7502275701659",
        nombre="Cubrebocas Alfa Medical kids azul C/10",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Cubrebocas",
        marca="Alfa Medical",
        presentacion="C/10",
    ),
    "7501048780235": p(
        "7501048780235",
        nombre="Cubrebocas Protec plegado C/10",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Cubrebocas",
        marca="Protec",
        laboratorio="Degasa",
        presentacion="C/10",
    ),
    "7502275701642": p(
        "7502275701642",
        nombre="Cubrebocas Alfa Medical kids rosa C/10",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Cubrebocas",
        marca="Alfa Medical",
        presentacion="C/10",
    ),
    "7501868902008": p(
        "7501868902008",
        nombre="Venda Dibar 5 cm",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Venda",
        marca="Dibar",
        presentacion="5 cm",
    ),
    "7702018072439": p(
        "7702018072439",
        nombre="Gillette Simply Venus 3 mujer C/1",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Afeitado",
        forma="Rastrillo",
        marca="Gillette",
        laboratorio="P&G",
        presentacion="C/1",
    ),
    "7500435011303": p(
        "7500435011303",
        nombre="Gillette Prestobarba Ultra Grip3 C/1",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Afeitado",
        forma="Rastrillo",
        marca="Gillette",
        laboratorio="P&G",
        presentacion="C/1",
    ),
    "7702018874729": p(
        "7702018874729",
        sku="FC-18874729",
        nombre="Gillette Prestobarba3 hombre 2-pack",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Afeitado",
        forma="Rastrillo",
        marca="Gillette",
        laboratorio="P&G",
        presentacion="2-pack",
        ya=True,
    ),
    # ── Nadro 605425063 ──
    "7501059225411": p(
        "7501059225411",
        sku="FC-59225411",
        nombre="Nido Kinder 1+ leche en polvo 360 g",
        tipo="marca",
        categoria="Nutrición",
        subcategoria="Fórmula láctea",
        forma="Polvo",
        marca="Nido",
        laboratorio="Nestlé",
        presentacion="Bolsa 360 g",
        ya=True,
    ),
    "8470001541871": p(
        "8470001541871",
        sku="FC-01541871",
        nombre="Isdin Ureadin Ultra 20 crema anti-rugosidades 100 ml",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Dermatología",
        forma="Crema",
        marca="Ureadin",
        laboratorio="Isdin",
        presentacion="Tubo 100 ml",
        ya=True,
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


# ── IFC sin EAN GS1 ─────────────────────────────────────────────
IFC_125448 = [
    {
        "nombre": "Dibar venda cohesiva 7.5 cm colores C/24",
        "desc_ticket": "DIBAR VENDA 7.5 CM COLORES C/24 5C025C02 83733",
        "qty": 1,
        "pu": 318.00,
        "sub": 318.00,
        "ean": "",
        "sku": "FC-IFC-83733",
        "match": "sin_ean",
        "marca": "Dibar",
        "presentacion": "Paquete C/24",
        "forma": "Venda",
        "categoria": "Botiquín",
        "foto": None,
        "receta": False,
    },
    {
        "nombre": "Venda elástica Protec Tensolastic Plus 7 cm × 5 m",
        "desc_ticket": "PROTEC VENDA TENSOLASTIC PLUS 7CMX5M 2A301071 83217",
        "qty": 4,
        "pu": 21.50,
        "sub": 86.00,
        "ean": "7501048690909",
        "sku": "FC-48690909",
        "match": "ya",
        "marca": "Protec",
        "presentacion": "7 cm × 5 m",
        "forma": "Venda",
        "categoria": "Botiquín",
        "foto": None,
        "receta": False,
    },
]

IFC_125445 = [
    {
        "nombre": "Mercurio magnesia calcinada C/50",
        "desc_ticket": "MERCURIO MAGNESIA CALCINADA C/50 1570818 06AGO25",
        "qty": 1,
        "pu": 55.50,
        "sub": 55.50,
        "ean": "",
        "sku": "FC-IFC-1570818",
        "match": "sin_ean",
        "marca": "Mercurio",
        "presentacion": "C/50",
        "forma": "Polvo",
        "categoria": "Cuidado personal",
        "foto": None,
        "receta": False,
    },
    {
        "nombre": "Espejito redondo económico",
        "desc_ticket": "ESPEJITO REDONDO ECONOMICO",
        "qty": 5,
        "pu": 6.00,
        "sub": 30.00,
        "ean": "",
        "sku": "FC-IFC-ESPEJITO",
        "match": "sin_ean",
        "marca": "",
        "presentacion": "Pieza",
        "forma": "Accesorio",
        "categoria": "Cuidado personal",
        "foto": None,
        "receta": False,
    },
    {
        "nombre": "Parches para acné hidrocoloide",
        "desc_ticket": "PARCHES P/ACNE FIGS HIDROCOLOIDE",
        "qty": 6,
        "pu": 16.50,
        "sub": 99.00,
        "ean": "",
        "sku": "FC-IFC-PARCHE-ACNE",
        "match": "sin_ean",
        "marca": "",
        "presentacion": "Pieza",
        "forma": "Parche",
        "categoria": "Cuidado personal",
        "foto": None,
        "receta": False,
    },
    {
        "nombre": "Benzal Wash líquido 240 mL",
        "desc_ticket": "BENZAL WASH LIQUIDO 240ML R101100 82912",
        "qty": 1,
        "pu": 102.50,
        "sub": 102.50,
        "ean": "",
        "sku": "FC-IFC-82912",
        "match": "sin_ean",
        "marca": "Benzal",
        "presentacion": "240 mL",
        "forma": "Jabón líquido",
        "categoria": "Cuidado personal",
        "foto": None,
        "receta": False,
    },
    {
        "nombre": "Mercurio rosa de Castilla C/50",
        "desc_ticket": "MERCURIO ROSA DE CASTILLA C/50 1490724 83490",
        "qty": 1,
        "pu": 75.00,
        "sub": 75.00,
        "ean": "",
        "sku": "FC-IFC-1490724",
        "match": "sin_ean",
        "marca": "Mercurio",
        "presentacion": "C/50",
        "forma": "Polvo",
        "categoria": "Cuidado personal",
        "foto": None,
        "receta": False,
    },
    {
        "nombre": "Mercurio almidón cajita C/10",
        "desc_ticket": "MERCURIO ALMIDON CAJITA C/10 1330723 83125",
        "qty": 1,
        "pu": 91.50,
        "sub": 91.50,
        "ean": "",
        "sku": "FC-IFC-1330723",
        "match": "sin_ean",
        "marca": "Mercurio",
        "presentacion": "C/10",
        "forma": "Polvo",
        "categoria": "Cuidado personal",
        "foto": None,
        "receta": False,
    },
    {
        "nombre": "Mercurio anís estrella C/25",
        "desc_ticket": "MERCURIO ANIS ESTRELLA C/25 1660824 83521",
        "qty": 1,
        "pu": 131.00,
        "sub": 131.00,
        "ean": "",
        "sku": "FC-IFC-1660824",
        "match": "sin_ean",
        "marca": "Mercurio",
        "presentacion": "C/25",
        "forma": "Polvo",
        "categoria": "Cuidado personal",
        "foto": None,
        "receta": False,
    },
    {
        "nombre": "Mercurio bórax polvo C/50",
        "desc_ticket": "MERCURIO BORAX POLVO C/50 1400724",
        "qty": 1,
        "pu": 53.00,
        "sub": 53.00,
        "ean": "",
        "sku": "FC-IFC-1400724",
        "match": "sin_ean",
        "marca": "Mercurio",
        "presentacion": "C/50",
        "forma": "Polvo",
        "categoria": "Cuidado personal",
        "foto": None,
        "receta": False,
    },
    {
        "nombre": "Lima de uñas Pulefin C/100",
        "desc_ticket": "LIMA UNAS PULEFIN C/100",
        "qty": 1,
        "pu": 94.50,
        "sub": 94.50,
        "ean": "",
        "sku": "FC-IFC-PULEFIN100",
        "match": "sin_ean",
        "marca": "Pulefin",
        "presentacion": "C/100",
        "forma": "Lima",
        "categoria": "Cuidado personal",
        "foto": None,
        "receta": False,
    },
    {
        "nombre": "Mercurio pomada manzana C/25",
        "desc_ticket": "MERCURIO POMADA MANZANA C/25 2530123 82943",
        "qty": 4,
        "pu": 9.50,
        "sub": 38.00,
        "ean": "",
        "sku": "FC-IFC-82943",
        "match": "sin_ean",
        "marca": "Mercurio",
        "presentacion": "C/25",
        "forma": "Pomada",
        "categoria": "Cuidado personal",
        "foto": f"{FOTO_BASE}/mercurio-pomada-manzana-50g.jpg",
        "receta": False,
    },
]


TICKETS = [
    {
        "key": "cityfarma_s325583",
        "folio": "S325583",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-09-24",
        "total": 1051.12,
        "notas": (
            "Ticket Cityfarma S325583 · 24-sep-2026 17:14 · foto térmica · "
            "Pendiente de pago $1,051.12 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_cf_s325583",
        "header": (
            "Cityfarma Iztapalapa · orden S325583 · 2026-09-24 17:14\n"
            "-- Ticket térmico. Pendiente de pago $1,051.12 (= suma renglones; pie: sub $954.67 + IVA $96.45).\n"
            "-- Barmicil EAN 7502001166066 · Hipebe 0.4 mg (ticket dice 4MG) · Menazan 7501573902720.\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("4015630064076", "ACCU CHEK C50 TIRAS", 1, 261.09),
            row("7501008494226", "ASPIRINA JR 100MG 60", 1, 65.59),
            row("7502001166066", "BARMICIL 40G SONS BE", 5, 19.82),
            row("7502308871274", "BAUMA MUNECA KF 75DP", 1, 438.22),
            row("7501075710786", "CIRULAN 10MG C 20 TA", 4, 7.57),
            row("7502225094275", "HIPEBE O 4MG CAP C20", 4, 33.71),
            row("7501573902720", "MENAZAN CRA 20G MICO", 2, 11.00),
        ],
        "piezas": 18,
        "suma_ok": 1051.12,
    },
    {
        "key": "surtidor_134730",
        "folio": "134730",
        "proveedor": "El Surtidor de su Farmacia",
        "proveedor_ilike": "surtidor",
        "fecha": "2026-09-24",
        "total": 152.01,
        "notas": (
            "Ticket El Surtidor 134730 · 24-sep-2026 17:04 · foto térmica · "
            "8 pzas agua destilada · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_sur_134730",
        "header": (
            "El Surtidor de su Farmacia · venta 134730 · 2026-09-24 17:04\n"
            "-- Ticket térmico. Total $152.01 (8 × $19.00; centavo del POS).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7501677620056", "AGUA DESTILADA LA FLOR 1 LT", 8, 19.00),
        ],
        "piezas": 8,
        "suma_ok": 152.00,  # ticket imprime 152.01
        "suma_tol": 0.02,
    },
    {
        "key": "equilibrio_445679",
        "folio": "445679",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-09-24",
        "total": 875.52,
        "notas": (
            "Ticket Equilibrio 445679 · Iztapalapa 2 · 24-sep-2026 17:28 · "
            "pedido online · cliente 307513 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_eq_445679",
        "header": (
            "Equilibrio · ticket 445679 · 2026-09-24 17:28 · sucursal Iztapalapa 2\n"
            "-- Pedido online. Subtotal $832.78 + IVA $42.74 = $875.52 · 10 renglones / 22 pzas.\n"
            "-- Foto partida (inicio + continuación). P.U. = costo neto post-descuento.\n"
            "-- Lote de fábrica sí. Caducidad NO: Recibir pide MMAA de la caja. 0000 inválido."
        ),
        "rows": [
            row("7502214985805", "DKT040 PRUDENCE CHICLE 1 CAJA 5 PZAS", 2, 46.57, "PB563201"),
            row("7503004908738", "ALP0380 LIDOCAINA 1 UNG 5% 35 G", 4, 23.33, "2606516"),
            row("7501075723137", "NOV138 NOVAKOSID 20 TAB 8.6 MG", 5, 13.93, "540286"),
            row("7502009748912", "MAV380 ESOMEPRAZOL 14 TAB 40 MG", 2, 51.65, "263687"),
            row("0780083144302", "COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML", 3, 33.69, "26140881"),
            row("7502214982491", "DKT009 PRUDENCE UVA 1 CJA 3 PZAS", 1, 34.48, "PG577501"),
            row("7502214980275", "DKT063 PRUDENCE SODA 1 CJA 3 PZA", 1, 32.96, "BC503404"),
            row("7502214982514", "DKT008 PRUDENCE CHOCOLATE 1 CJA 3 PZAS", 1, 34.14, "BCH508001"),
            row("7502214983207", "DKT023 LUBRICANTE UVA 1 GEL 75 ML", 1, 72.42, "3P186057"),
            row("7502009749292", "MAV415 ESOMEPRAZOL 28 TAB 40 MG", 2, 99.15, "263551"),
        ],
        "piezas": 22,
        "suma_ok": 832.78,
    },
    {
        "key": "farmamayoreo_306277",
        "folio": "306277",
        "proveedor": "Farma Mayoreo",
        "proveedor_ilike": "farmamayoreo|farma mayoreo",
        "fecha": "2026-09-24",
        "total": 2978.43,
        "notas": (
            "Ticket Farma Mayoreo 306277 · Central · 24-sep-2026 16:35 · "
            "tarjeta · 30 arts / 55 pzas · foto en 3 partes (sobreimpresión en Colgate/Kotex) · "
            "cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_fm_306277",
        "header": (
            "Farma Mayoreo · ID VENTA 306277 · 2026-09-24 16:35 · Central de Abastos\n"
            "-- Ticket térmico partido (3 fotos). Subtotal $2,841.58 + impuestos $136.85 = $2,978.43.\n"
            "-- P.U. ya trae IVA (suma renglones = total). Kotex Unika EAN 7506425625536 (línea sobreimpresa).\n"
            "-- Oral-B Stages: Toy Story+Princesas comparten EAN 3014260279264 (×2); Frozen es 3014260278922 (×1).\n"
            "-- Lote de fábrica del papel cuando es legible. Caducidad NO: MMAA de la caja. 0000 inválido."
        ),
        "rows": [
            row("3014260279264", "ORAL B CEPILLO S", 2, 51.83, "6041833520"),
            row("3014260278922", "ORAL B CEPILLO F", 1, 50.97, "6037833520"),
            row("7501050623766", "AFRIN NODRIP CSE", 2, 107.90, "2601390"),
            row("7501050624732", "AFRIN NODRIP SPR", 2, 101.98, "251279EA"),
            row("7500435246309", "VICK DROPS SABOR", 1, 37.98, "516202"),
            row("7509546072272", "COLGATE CD KIDS", 1, 24.98, "516202"),
            row("7891024034095", "COLGATE CD KIDS", 1, 20.95, "4268"),
            row("7501054550150", "CURITAS ANIMALES", 1, 45.98, "4268"),
            row("7501048623044", "PADS FACIALES PR", 1, 28.50, "52647"),
            row("7501943490598", "JBN LIQ ESCUDO P", 4, 28.00),
            row("7590002037843", "VICK PYRENA MIEL", 2, 89.98, "60494354U0"),
            row("7501125100116", "SOLUCION CLORURO", 4, 26.90, "P26Y317"),
            row("7501125115479", "SOLUCION CLORURO", 3, 22.98, "V26J530"),
            row("7503017500769", "JABON LIQUIDO PA", 1, 16.91, "437032"),
            row("7503017500776", "JABON LIQUIDO PA", 1, 16.91, "439036"),
            row("7503017500783", "JABON LIQUIDO PA", 1, 16.91, "438033"),
            row("7501088509766", "ANTIFLUDES SOL J", 3, 124.98, "BFB081"),
            row("7501065085191", "VOLTAREN EMULGEL", 1, 76.98, "UC2L"),
            row("7501088509810", "ANTIFLUDES SOL P", 1, 138.98, "BEK114"),
            row("7501065024688", "VOLTAREN DOLO 25", 1, 195.98, "35826"),
            row("7501065085528", "VOLTAREN EMULGEL", 1, 111.98, "F19T"),
            row("7509546068558", "COLGATE CEPILLO", 2, 45.98),
            row("7509546079493", "COLGATE CEPILLOS", 2, 30.97),
            row("7509546066776", "COLGATE CREMA DE", 3, 45.98),
            row("7500435246293", "DROPS CARAMELO M", 2, 37.98, "505700"),
            row("7500435246286", "DROPS CARAMELO M", 2, 37.98, "514101"),
            row("7501943493940", "TAS HUMEDAS ESC", 3, 12.98),
            row("7506425625536", "KOTEX TAMPONES R", 2, 32.50),
            row("7501417515956", "BOCASAN ECONOPA", 2, 60.95, "25D03"),
            row("7506195102640", "VICK PYRENA MANZ", 2, 78.98, "008435400"),
        ],
        "piezas": 55,
        "suma_ok": 2978.43,
    },
    {
        "key": "farmalive_13395",
        "folio": "13395",
        "proveedor": "Farmalive",
        "proveedor_ilike": "farmalive",
        "fecha": "2026-09-24",
        "total": 1359.31,
        "notas": (
            "Ticket Farmalive 13395 · Club Iztapalapa 1 · 24-sep-2026 16:52 · "
            "precio neto (2–5% desc.) · Suerox EAN canónico 650… check digit · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_fl_13395",
        "header": (
            "Farmalive · ticket 13395 · 2026-09-24 16:52 · Club Iztapalapa 1\n"
            "-- Total $1,359.31 · 18 artículos / 46 unidades · tarjeta crédito.\n"
            "-- Foto partida (inicio + pie). Costo = P.U. neto post-descuento.\n"
            "-- Ticket trunca Suerox a 12 dígitos; pistola = EAN 650… del catálogo.\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("6502400721541", "SUEROX VITAMINS MANZANA V-LIMON 630 ML | GENOMMA LAB", 2, 14.73),
            row("6502400663068", "SUEROX 8 IONES FRESA 630 ML | GENOMMA LAB", 2, 14.73),
            row("6502400721471", "SUEROX VITAMINS NARANJA-MANGO 630 ML | GENOMMA LAB", 2, 14.73),
            row("7501033956690", "PEDIALYTE SR45 FRESA 500 ML | ABBOTT", 2, 23.81),
            row("7501033954740", "PEDIALYTE SR60 MANZANA 500 ML | ABBOTT", 2, 23.81),
            row("7501033956775", "PEDIALYTE SR60 UVA 500 ML | ABBOTT", 2, 23.81),
            row("7509546058962", "SPRAY CAPRICE NATURALS SABILA 316 ML | COLGATE PALMOLIVE", 1, 48.80),
            row("7509546058979", "SPRAY CAPRICE ALGAS 316 ML | COLGATE PALMOLIVE", 2, 48.80),
            row("7509546058986", "SPRAY CAPRICE KIWI LAVANDA 316 ML | COLGATE PALMOLIVE", 2, 48.80),
            row("7509546059006", "SPRAY CAPRICE GRANADA 316 ML | COLGATE PALMOLIVE", 2, 48.80),
            row("7891024179925", "ENJ BUCAL COLGATE PERIO GARD 250 ML | COLGATE PALMOLIVE", 1, 182.28),
            row("7502275701659", "CUBREBOCAS ALFA MEDICAL KIDS AZUL C/10 | ALFA MEDICAL", 2, 22.05),
            row("7501048780235", "CUBREBOCAS PROTEC PLEGADO C/10 | DEGASA", 1, 18.03),
            row("7502275701642", "CUBREBOCAS KIDS ROSA BOLSA C/10 | ALFA MEDICAL", 2, 22.05),
            row("7501868902008", "VENDA DIBAR 5 CM | DIBAR", 3, 7.15),
            row("7702018072439", "RASTRILLO GILLETTE SIMPLY VENUS 3 MUJ C/1 | PG PERF", 4, 18.23),
            row("7500435011303", "RASTRILLO PRESTOBARBA ULTRA GRIP3 C/1 | PG PERF", 12, 20.78),
            row("7702018874729", "RAST GILLETTE PRESTOBARBA3 HOMBRE 2PACK | PG PERF", 2, 77.13),
        ],
        "piezas": 46,
        "suma_ok": 1359.31,
        "suma_tol": 0.15,
    },
    {
        "key": "nadro_605425063",
        "folio": "605425063",
        "proveedor": "Nadro",
        "proveedor_ilike": "nadro",
        "fecha": "2026-09-24",
        "total": 383.42,
        "notas": (
            "Factura Nadro 605425063 · México Sur · 24-sep-2026 · "
            "entrega FarmaCapital · efectivo · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_nd_605425063",
        "header": (
            "Nadro · factura 605425063 · 2026-09-24 · sucursal México Sur\n"
            "-- CFDI · subtotal $341.45 + IVA 16% $41.97 = $383.42 · 2 renglones / 2 pzas.\n"
            "-- Costo = valor unitario (PR FAR). Ureadin lleva IVA; Nido IVA 0%.\n"
            "-- Ureadin lote fábrica L022029 (del CFDI). Caducidad NO: MMAA de la caja. 0000 inválido.\n"
            "-- Ficha: Nido Nestlé · Isdin Ureadin Ultra 20 (no el código del renglón)."
        ),
        "rows": [
            row("7501059225411", "NIDO KINDER 1+ LECHE 360 G", 1, 79.16),
            row("8470001541871", "UREADIN ULTRA 20CRA ANTI-RUG100ML", 1, 262.29, "L022029"),
        ],
        "piezas": 2,
        "suma_ok": 341.45,
    },
]


def write_ifc_carga(path: Path, folio: str, rows: list[dict], fecha: str) -> None:
    lines = [
        f"-- IFC F8 Tienda · folio {folio} · {fecha}",
        "-- Códigos IFC del ticket NO son EAN GS1 (salvo Tensolastic 7501048690909).",
        "-- Altas stock 0. Pegar en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
    ]
    for r in rows:
        pvp = ceil_pvp(r["pu"], "marca")
        ean_sql = sql_str(r["ean"]) if r.get("ean") else "null"
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
            f"  {ean_sql},",
            f"  {sql_str(r['categoria'])},",
            "  'marca',",
            f"  {sql_str('Ticket IFC ' + folio + ' · ' + r['desc_ticket'])},",
            f"  {r['pu']:.2f}, {pvp}, 0, 1, true, false,",
            f"  {marca_sql},",
            f"  {sql_str(r['presentacion'])},",
            f"  {sql_str(r['forma'])},",
            f"  {foto_sql}",
            "where public.fc_buscar_producto_escaneo(" + (ean_sql if r.get("ean") else sql_str(r["sku"])) + ") is null",
            f"  and not exists (select 1 from public.productos where sku = {sql_str(r['sku'])});",
            "",
            "update public.productos set",
            f"  costo = {r['pu']:.2f},",
            f"  precio = case when coalesce(precio, 0) <= 0 then {pvp} else precio end,",
            f"  marca = coalesce(nullif(btrim(marca), ''), {marca_sql}),",
            f"  presentacion = coalesce(nullif(btrim(presentacion), ''), {sql_str(r['presentacion'])}),",
            f"  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), {sql_str(r['forma'])}),",
            f"  imagen_url = coalesce(nullif(btrim(imagen_url), ''), {foto_sql})",
            f"where sku = {sql_str(r['sku'])}",
            (f"   or codigo_barras = {ean_sql}" if r.get("ean") else "") + ";",
            "",
        ]
    lines += ["commit;", ""]
    path.write_text("\n".join(lines), encoding="utf-8")


def rows_ifc_rx(rows: list[dict]) -> list[dict]:
    return [
        {
            "nombre": r["nombre"],
            "qty": r["qty"],
            "sub": r["sub"],
            "pu": r["pu"],
            "ean": r.get("ean") or "",
            "sku": r["sku"],
            "match": r["match"],
        }
        for r in rows
    ]


def write_todos(paths: list[Path]) -> Path:
    out = OUT_DIR / "patch_carga_tickets_20260924_TODOS.sql"
    parts = [
        "-- ═══════════════════════════════════════════════════════════════",
        "-- TICKETS 24-SEP-2026 · PEGAR EN SUPABASE (uno por uno o todo)",
        "-- Ver LEERME_tickets_20260924.md",
        "-- ═══════════════════════════════════════════════════════════════",
        "",
    ]
    for pth in paths:
        parts.append(f"\n-- ━━━ INICIO: {pth.name} ━━━\n")
        parts.append(pth.read_text(encoding="utf-8"))
        parts.append(f"\n-- ━━━ FIN: {pth.name} ━━━\n")
    out.write_text("\n".join(parts), encoding="utf-8")
    return out


def write_leerme(stats: list[tuple[str, str, int, float]]) -> Path:
    lines = [
        "# Tickets Recibir · 24-sep-2026",
        "",
        "Fotos Central de Abastos (Palillero). Pegar **cada** SQL en Supabase → SQL Editor → Run.",
        "",
        "| Pedido | Archivo | Piezas | Total |",
        "|--------|---------|--------|-------|",
    ]
    for nombre, arch, pzas, total in stats:
        lines.append(f"| {nombre} | `{arch}` | {pzas} | ${total:,.2f} |")
    lines += [
        "",
        "## Notas",
        "",
        "- **Farma Mayoreo 306277** viene en 3 fotos; el tramo Colgate/Kotex está sobreimpreso.",
        "  Kotex tampones = EAN `7506425625536` (Unika Regular C/12). Total verificado $2,978.43 / 55 pzas.",
        "  Oral-B: Toy Story+Princesas = mismo EAN `3014260279264` (×2); Frozen = `3014260278922`.",
        "  Si ya corriste la carga: `sql/patch_oralb_stages_ean_caja_20260924.sql`.",
        "- **Farmalive 13395**: foto partida. Costo = P.U. neto (2–5% desc.). Suerox EAN canónico 13 dígitos.",
        "- **Nadro 605425063**: CFDI 24-sep. Nido + Ureadin Ultra 20. Costo = PR FAR; total con IVA $383.42.",
        "- Equilibrio 445679: foto partida (inicio + pie). P.U. neto; total con IVA $875.52.",
        "- Cityfarma: pendiente de pago $1,051.12 (subtotal + IVA). Hipebe es **0.4 mg** (ticket dice 4MG).",
        "- IFC: sin EAN GS1 salvo Tensolastic `7501048690909`. Ligar EAN de caja al escanear.",
        "- Caducidad: nunca inventar. `0000` inválido. MMAA de la caja al pistolear.",
        "- Regenerar: `python3 scripts/generar_carga_tickets_20260924.py`",
        "",
    ]
    path = OUT_DIR / "LEERME_tickets_20260924.md"
    path.write_text("\n".join(lines), encoding="utf-8")
    return path


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    sql_paths: list[Path] = []
    stats: list[tuple[str, str, int, float]] = []

    for t in TICKETS:
        rows = t["rows"]
        # fix proveedor_ilike for farmamayoreo (write_carga expects simple ilike fragment)
        if "|" in t["proveedor_ilike"]:
            t = {**t, "proveedor_ilike": "farma mayoreo"}
        suma = sum(r["sub"] for r in rows)
        pzas = sum(r["qty"] for r in rows)
        tol = t.get("suma_tol", 0.02)
        esperado = t.get("suma_ok", t["total"])
        if abs(suma - esperado) > tol and abs(suma - t["total"]) > tol:
            raise SystemExit(
                f"{t['folio']}: suma ${suma:.2f} ≠ esperado ${esperado:.2f} / total ${t['total']:.2f}"
            )
        if pzas != t["piezas"]:
            raise SystemExit(f"{t['folio']}: piezas {pzas} ≠ {t['piezas']}")

        csv_path = GEN_DIR / f"ticket_{t['key']}.csv"
        # CSV: descripcion_ticket = snap
        csv_rows = [{**r, "nombre": r["snap"]} for r in rows]
        write_ticket_csv(
            csv_path,
            folio=t["folio"],
            fecha=t["fecha"],
            proveedor=t["proveedor"],
            total=t["total"],
            rows=csv_rows,
        )
        sql_path = write_carga_sql(t)
        # write_carga_sql writes to OUT_DIR with key-based name via ticket dict — check
        sql_paths.append(sql_path)
        stats.append((f"{t['proveedor'].split()[0]} {t['folio']}", sql_path.name, pzas, t["total"]))
        print(report(rows, t["total"]))
        print(f"  csv={csv_path.name} sql={sql_path.name} pzas={pzas} suma={suma:.2f}")

    # IFC tickets
    for folio, fecha, total, ifc_rows, hhmm in [
        ("125448", "2026-09-24", 404.00, IFC_125448, "16:47"),
        ("125445", "2026-09-24", 770.00, IFC_125445, "16:41"),
    ]:
        data = rows_ifc_rx(ifc_rows)
        suma = sum(r["sub"] for r in data)
        pzas = sum(r["qty"] for r in data)
        if abs(suma - total) >= 0.02:
            raise SystemExit(f"IFC {folio}: suma ${suma:.2f} ≠ ${total:.2f}")
        csv_path = GEN_DIR / f"ticket_ifc_{folio}.csv"
        write_ticket_csv(
            csv_path,
            folio=folio,
            fecha=fecha,
            proveedor="IFC F8 Tienda",
            total=total,
            rows=[{**r, "nombre": next(x["desc_ticket"] for x in ifc_rows if x["sku"] == r["sku"])} for r in data],
        )
        carga = OUT_DIR / f"patch_carga_ifc_{folio}.sql"
        write_ifc_carga(carga, folio, ifc_rows, fecha)
        rx = OUT_DIR / f"patch_recepcion_ifc_{folio}.sql"
        write_recepcion_sql(
            rx,
            folio=folio,
            proveedor="IFC F8 Tienda",
            proveedor_ilike="ifc",
            fecha=fecha,
            total=total,
            notas=(
                f"Farma Centre / IFC F8 Tienda · folio {folio} · {fecha} {hhmm} · "
                "MAYOREO/MENUDEO · cola Recibir; stock al confirmar pistola"
            ),
            rows=data,
        )
        sql_paths.extend([carga, rx])
        stats.append((f"IFC {folio}", carga.name, pzas, total))
        print(f"IFC {folio}: pzas={pzas} suma=${suma:.2f} csv={csv_path.name}")

    todos = write_todos(sql_paths)
    leerme = write_leerme(stats)
    print(f"todos={todos}")
    print(f"leerme={leerme}")


if __name__ == "__main__":
    main()
