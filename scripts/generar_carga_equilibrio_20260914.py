#!/usr/bin/env python3
"""Ticket Equilibrio POS 14-sep-2026 → catálogo + cola Recibir.

Cliente 307513 LUIS ANGEL PALILLERO VENTURA · Venta al Público en pantalla
Equilibrio (versión 466). Dos fotos = mismo ticket con scroll.
41 renglones / 112 pzas / SubTotal $3,498.95 (IVA $0).
Costo = PreEQF. Lote de fábrica del papel. Caducidad NO: MMAA de la caja.
Fichas desde EQF / DISA / Sufarmed / Farma City, no el recorte del POS.
Calaffler (lote R2503424) salía en rojo en el POS (cad. papel 2027-04-30).
"""
from __future__ import annotations

import csv
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_equilibrio_20260914.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_equilibrio_20260914.sql"

FOLIO = "20260914"
PROVEEDOR = "Equilibrio"
FECHA = "2026-09-14"
TOTAL_TICKET = 3498.95
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


def sku_fc(ean: str) -> str:
    return "FC-" + ean[-8:]


def sku_eq(codigo: str, ean: str) -> str:
    return f"EQ-{codigo}" if codigo else sku_fc(ean)


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


# Fichas de mostrador (no el código truncado del POS).
# ya=True solo si el EAN ya estaba en historial Farma City / cargas previas conocidas.
ROWS = [
    {
        "ean": "7501075711035", "codigo": "NOV006",
        "snap": "DEBISOR SUBLINGUAL 20 TAB 5 MG",
        "nombre": "Debisor sublingual 5 mg C/20 Novag",
        "qty": 2, "pu": 56.32, "lote": "140185",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Cardiovascular", "forma": "Tableta sublingual",
        "marca": "Debisor", "laboratorio": "Novag",
        "presentacion": "Caja con 20 tabletas sublinguales",
        "principio": "Dinitrato de isosorbida", "concentracion": "5 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501075711011", "codigo": "NOV007",
        "snap": "DEBISOR 20 TAB 10 MG",
        "nombre": "Debisor 10 mg C/20 Novag",
        "qty": 4, "pu": 8.87, "lote": "150066",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Cardiovascular", "forma": "Tableta",
        "marca": "Debisor", "laboratorio": "Novag",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Dinitrato de isosorbida", "concentracion": "10 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7502226291871", "codigo": "ALP0120",
        "snap": "HIDROPHARM 30 TAB 50 MG",
        "nombre": "Hidropharm clortalidona 50 mg C/30 Alpharma",
        "qty": 2, "pu": 16.35, "lote": "2603022",
        "tipo": "marca", "categoria": "Hipertensión",
        "subcategoria": "Cardiovascular", "forma": "Tableta",
        "marca": "Hidropharm", "laboratorio": "Alpharma",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Clortalidona", "concentracion": "50 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501125100123", "codigo": None,
        "snap": "SOLUCION CLORURO DE SODIO 0.9% 500 ML",
        "nombre": "Solución CS Pisa cloruro de sodio 0.9% 500 ml",
        "qty": 1, "pu": 52.84, "lote": "P26M713",
        "tipo": "generico", "categoria": "Medicamentos",
        "subcategoria": "Soluciones", "forma": "Solución parenteral",
        "marca": "CS Pisa", "laboratorio": "Pisa",
        "presentacion": "Frasco 500 ml",
        "principio": "Cloruro de sodio", "concentracion": "0.9%",
        "receta": False, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501349025929", "codigo": "AMS362",
        "snap": "DICLOFENACO 2 FA 75MG/3 ML",
        "nombre": "Diclofenaco 75 mg/3 ml C/2 ampolletas AMSA",
        "qty": 2, "pu": 16.24, "lote": "26E039",
        "tipo": "generico", "categoria": "Medicamentos",
        "subcategoria": "Dolor", "forma": "Solución inyectable",
        "marca": "AMSA", "laboratorio": "AMSA",
        "presentacion": "Caja con 2 ampolletas de 3 ml",
        "principio": "Diclofenaco sódico", "concentracion": "75 mg/3 ml",
        "receta": True, "ya": True, "foto_file": None,
    },
    {
        "ean": "7502226293776", "codigo": "ALP0628",
        "snap": "METAMIZOL SODICO 3 AMP 1G/2 ML",
        "nombre": "Metamizol sódico 1 g/2 ml C/3 ampolletas",
        "qty": 2, "pu": 19.25, "lote": "B25T515",
        "tipo": "generico", "categoria": "Medicamentos",
        "subcategoria": "Dolor", "forma": "Solución inyectable",
        "marca": "Alpharma", "laboratorio": "Alpharma",
        "presentacion": "Caja con 3 ampolletas de 2 ml",
        "principio": "Metamizol sódico", "concentracion": "1 g/2 ml",
        "receta": True, "ya": True, "foto_file": None,
    },
    {
        "ean": "7502009749100", "codigo": "MAV297",
        "snap": "ORFEOX 20 TAB 150 MG",
        "nombre": "Orfeox propafenona 150 mg C/20 Maver",
        "qty": 5, "pu": 36.05, "lote": "261633",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Cardiovascular", "forma": "Tableta",
        "marca": "Orfeox", "laboratorio": "Maver",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Propafenona", "concentracion": "150 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7506386100158", "codigo": "LOE173",
        "snap": "BENVIA 1 JBE 250 MG/100/120 ML",
        "nombre": "Benvia jarabe infantil dimenhidrinato 120 ml",
        "qty": 2, "pu": 33.99, "lote": "R2605431",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Gastro", "forma": "Jarabe",
        "marca": "Benvia", "laboratorio": "Loeffler",
        "presentacion": "Frasco 120 ml",
        "principio": "Dimenhidrinato", "concentracion": "250 mg/100 ml",
        "receta": False, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501836003140", "codigo": None,
        "snap": "CONTRAXEN 30 CAPS 200/250 MG",
        "nombre": "Contraxen carisoprodol/naproxeno 200/250 mg C/30",
        "qty": 3, "pu": 80.23, "lote": "26E039",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Dolor", "forma": "Cápsula",
        "marca": "Contraxen", "laboratorio": "Liferpal MD",
        "presentacion": "Caja con 30 cápsulas",
        "principio": "Carisoprodol / Naproxeno", "concentracion": "200/250 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "780083148928", "codigo": "COL252",
        "snap": "KENZOFLEX DUO 1 SOL",
        "nombre": "Kenzoflex Duo solución oftálmica 5 ml Collins",
        "qty": 2, "pu": 48.76, "lote": "26340627",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Oftalmología", "forma": "Solución oftálmica",
        "marca": "Kenzoflex Duo", "laboratorio": "Collins",
        "presentacion": "Frasco gotero 5 ml",
        "principio": "Ciprofloxacino / Dexametasona",
        "concentracion": "3.5 mg / 1 mg por ml",
        "receta": True, "ya": True, "foto_file": None,
    },
    {
        "ean": "7502009747328", "codigo": None,
        "snap": "ITOPRIDA 30 TAB 50 MG",
        "nombre": "Lapriver itoprida 50 mg C/30 Maver",
        "qty": 3, "pu": 60.51, "lote": "6FN231C",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Gastro", "forma": "Tableta",
        "marca": "Lapriver", "laboratorio": "Maver",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Itoprida", "concentracion": "50 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501825301752", "codigo": None,
        "snap": "BIOFILEN 28 TAB 100 MG",
        "nombre": "Biofilen atenolol 100 mg C/28 Degort's",
        "qty": 3, "pu": 49.67, "lote": "281AA",
        "tipo": "marca", "categoria": "Hipertensión",
        "subcategoria": "Cardiovascular", "forma": "Tableta",
        "marca": "Biofilen", "laboratorio": "Degort's",
        "presentacion": "Caja con 28 tabletas",
        "principio": "Atenolol", "concentracion": "100 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7502009744341", "codigo": None,
        "snap": "PRILVER 16 TAB 5 MG",
        "nombre": "Prilver ramipril 5 mg C/16 Maver",
        "qty": 3, "pu": 38.18, "lote": "256221",
        "tipo": "marca", "categoria": "Hipertensión",
        "subcategoria": "Cardiovascular", "forma": "Tableta",
        "marca": "Prilver", "laboratorio": "Maver",
        "presentacion": "Caja con 16 tabletas",
        "principio": "Ramipril", "concentracion": "5 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7502009744891", "codigo": None,
        "snap": "FRINVER 1 GOT 24 ML",
        "nombre": "Frinver norfenefrina gotas 24 ml Maver",
        "qty": 2, "pu": 62.56, "lote": "264353",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Respiratorio", "forma": "Gotas orales",
        "marca": "Frinver", "laboratorio": "Maver",
        "presentacion": "Frasco gotero 24 ml",
        "principio": "Norfenefrina", "concentracion": "10 mg/ml",
        "receta": False, "ya": False, "foto_file": None,
    },
    {
        "ean": "7503004908875", "codigo": "ALP0210",
        "snap": "ACARBOSA 30 TAB 50 MG",
        "nombre": "Acarbosa 50 mg C/30 Alpharma",
        "qty": 3, "pu": 43.74, "lote": "N2512248",
        "tipo": "generico", "categoria": "Medicamentos",
        "subcategoria": "Diabetes", "forma": "Tableta",
        "marca": "Alpharma", "laboratorio": "Alpharma",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Acarbosa", "concentracion": "50 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501075717860", "codigo": "NOV094",
        "snap": "OXIVAG 4 TAB 70 MG",
        "nombre": "Oxivag ácido alendrónico 70 mg C/4 Novag",
        "qty": 2, "pu": 31.94, "lote": "650136",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Osteoporosis", "forma": "Tableta",
        "marca": "Oxivag", "laboratorio": "Novag",
        "presentacion": "Caja con 4 tabletas",
        "principio": "Ácido alendrónico", "concentracion": "70 mg",
        "receta": True, "ya": True, "foto_file": None,
    },
    {
        "ean": "7502211780069", "codigo": "LOE020",
        "snap": "STOMFFLER PLUS 1 SUSP",
        "nombre": "Stomffler Plus suspensión 120 ml Loeffler",
        "qty": 2, "pu": 41.72, "lote": "R2604367",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Gastro", "forma": "Suspensión oral",
        "marca": "Stomffler Plus", "laboratorio": "Loeffler",
        "presentacion": "Frasco 120 ml",
        "principio": "Metronidazol / Diyodohidroxiquinoleína",
        "concentracion": "2.5 g / 2.0 g por 100 ml",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7502211784180", "codigo": None,
        "snap": "CALAFFLER 1 GOT 15 ML",
        "nombre": "Calaffler diclofenaco gotas 15 mg/ml Loeffler",
        "qty": 2, "pu": 32.22, "lote": "R2503424",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Dolor", "forma": "Gotas orales",
        "marca": "Calaffler", "laboratorio": "Loeffler",
        "presentacion": "Frasco gotero (ticket 15 ml; ficha retail 20 ml)",
        "principio": "Diclofenaco potásico", "concentracion": "15 mg/ml",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501349024267", "codigo": "AMS328",
        "snap": "KETOROLACO 3 AMP 30 MG",
        "nombre": "Ketorolaco 30 mg/1 ml C/3 ampolletas AMSA",
        "qty": 2, "pu": 11.34, "lote": "26F009",
        "tipo": "generico", "categoria": "Medicamentos",
        "subcategoria": "Dolor", "forma": "Solución inyectable",
        "marca": "AMSA", "laboratorio": "AMSA",
        "presentacion": "Caja con 3 ampolletas de 1 ml",
        "principio": "Ketorolaco trometamina", "concentracion": "30 mg/1 ml",
        "receta": True, "ya": True, "foto_file": None,
    },
    {
        "ean": "7502009744884", "codigo": "MAV211",
        "snap": "ODIVITOR 20 TAB 10 MG",
        "nombre": "Odivitor atorvastatina 10 mg C/20 Maver",
        "qty": 5, "pu": 22.12, "lote": "254489",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Cardiovascular", "forma": "Tableta",
        "marca": "Odivitor", "laboratorio": "Maver",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Atorvastatina", "concentracion": "10 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7502216796348", "codigo": None,
        "snap": "FELODIPINO 20 TAB 5 MG",
        "nombre": "Felodipino LP 5 mg C/20 Ultra",
        "qty": 4, "pu": 21.89, "lote": "6DN237A",
        "tipo": "generico", "categoria": "Hipertensión",
        "subcategoria": "Cardiovascular", "forma": "Tableta liberación prolongada",
        "marca": "Ultra", "laboratorio": "Ultra",
        "presentacion": "Caja con 20 tabletas LP",
        "principio": "Felodipino", "concentracion": "5 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501075713862", "codigo": "NOV034",
        "snap": "NOVAPRES 30 TAB 25 MG",
        "nombre": "Novapres captopril 25 mg C/30 Novag",
        "qty": 5, "pu": 9.87, "lote": "550016",
        "tipo": "marca", "categoria": "Hipertensión",
        "subcategoria": "Cardiovascular", "forma": "Tableta",
        "marca": "Novapres", "laboratorio": "Novag",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Captopril", "concentracion": "25 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7502216793439", "codigo": "ULT117",
        "snap": "SUCRALFATO 40 TAB 1 G",
        "nombre": "Sucralfato 1 g C/40 Ultra",
        "qty": 3, "pu": 47.07, "lote": "6H445",
        "tipo": "generico", "categoria": "Medicamentos",
        "subcategoria": "Gastro", "forma": "Tableta",
        "marca": "Ultra", "laboratorio": "Ultra",
        "presentacion": "Caja con 40 tabletas",
        "principio": "Sucralfato", "concentracion": "1 g",
        "receta": False, "ya": False, "foto_file": None,
    },
    {
        "ean": "785118754204", "codigo": "MAI150",
        "snap": "MAVIGLIN 60 TAB 500/5 MG",
        "nombre": "Maviglin metformina/glibenclamida 500/5 mg C/60",
        "qty": 3, "pu": 62.64, "lote": "6E0865",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Diabetes", "forma": "Tableta",
        "marca": "Maviglin", "laboratorio": "Mavi",
        "presentacion": "Caja con 60 tabletas",
        "principio": "Metformina / Glibenclamida", "concentracion": "500/5 mg",
        "receta": True, "ya": True, "foto_file": None,
    },
    {
        "ean": "7501825300366", "codigo": "DEG030",
        "snap": "ESPABION 1 SUSP 20MG/1ML 30 ML",
        "nombre": "Espabion gotas pediátricas trimebutina 30 ml",
        "qty": 1, "pu": 25.67, "lote": "527AA",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Gastro", "forma": "Suspensión gotas",
        "marca": "Espabion", "laboratorio": "Degort's",
        "presentacion": "Frasco 30 ml con gotero",
        "principio": "Trimebutina", "concentracion": "20 mg/ml",
        "receta": False, "ya": True, "foto_file": None,
    },
    {
        "ean": "7502001162525", "codigo": "SON091",
        "snap": "MECLISON 20 TAB 50/25 MG",
        "nombre": "Meclison meclizina/piridoxina 25/50 mg C/20 Son's",
        "qty": 2, "pu": 22.06, "lote": "26051277",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Gastro", "forma": "Tableta",
        "marca": "Meclison", "laboratorio": "Química Son's",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Meclizina / Piridoxina", "concentracion": "25/50 mg",
        "receta": False, "ya": True, "foto_file": None,
    },
    {
        "ean": "7502006922728", "codigo": "FAC0046",
        "snap": "MOTILAXIL 1 SOL 100MG/5/120 ML",
        "nombre": "Motilaxil picosulfato de sodio solución 120 ml",
        "qty": 2, "pu": 25.04, "lote": "ITE26L157",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Gastro", "forma": "Solución oral",
        "marca": "Motilaxil", "laboratorio": "Fármacos Continentales",
        "presentacion": "Frasco 120 ml",
        "principio": "Picosulfato de sodio", "concentracion": "5 mg/5 ml",
        "receta": False, "ya": True, "foto_file": None,
    },
    {
        "ean": "7501825301721", "codigo": None,
        "snap": "BIOFILEN 28 TAB 50 MG",
        "nombre": "Biofilen atenolol 50 mg C/28 Degort's",
        "qty": 2, "pu": 38.18, "lote": "512AA",
        "tipo": "marca", "categoria": "Hipertensión",
        "subcategoria": "Cardiovascular", "forma": "Tableta",
        "marca": "Biofilen", "laboratorio": "Degort's",
        "presentacion": "Caja con 28 tabletas",
        "principio": "Atenolol", "concentracion": "50 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501825300373", "codigo": "DEG029",
        "snap": "ESPABION 1 SUSP 100MG/5ML 100 ML",
        "nombre": "Espabion suspensión trimebutina 100 ml Degort's",
        "qty": 2, "pu": 44.45, "lote": "505AA",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Gastro", "forma": "Suspensión oral",
        "marca": "Espabion", "laboratorio": "Degort's",
        "presentacion": "Frasco 100 ml",
        "principio": "Trimebutina", "concentracion": "2 g/100 ml",
        "receta": False, "ya": True, "foto_file": None,
    },
    {
        "ean": "7501075715378", "codigo": None,
        "snap": "TOPARAL 30 TAB 250 MG",
        "nombre": "Toparal metildopa 250 mg C/30 Novag",
        "qty": 4, "pu": 40.36, "lote": "760175",
        "tipo": "marca", "categoria": "Hipertensión",
        "subcategoria": "Cardiovascular", "forma": "Tableta",
        "marca": "Toparal", "laboratorio": "Novag",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Metildopa", "concentracion": "250 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7502216803893", "codigo": "AVI026",
        "snap": "KETOROLACO 10 TAB 10 MG",
        "nombre": "Ketorolaco 10 mg C/10 Avivia",
        "qty": 4, "pu": 5.61, "lote": "530056",
        "tipo": "generico", "categoria": "Medicamentos",
        "subcategoria": "Dolor", "forma": "Tableta",
        "marca": "Avivia", "laboratorio": "Avivia",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Ketorolaco", "concentracion": "10 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7502216803893", "codigo": "AVI026",
        "snap": "KETOROLACO 10 TAB 10 MG",
        "nombre": "Ketorolaco 10 mg C/10 Avivia",
        "qty": 2, "pu": 5.61, "lote": "530175",
        "tipo": "generico", "categoria": "Medicamentos",
        "subcategoria": "Dolor", "forma": "Tableta",
        "marca": "Avivia", "laboratorio": "Avivia",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Ketorolaco", "concentracion": "10 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501471889352", "codigo": None,
        "snap": "VEPILTAX 20 TAB 80 MG",
        "nombre": "Vepiltax verapamilo 80 mg C/20 Tecnofarma",
        "qty": 3, "pu": 28.79, "lote": "441068",
        "tipo": "marca", "categoria": "Hipertensión",
        "subcategoria": "Cardiovascular", "forma": "Tableta",
        "marca": "Vepiltax", "laboratorio": "Tecnofarma",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Verapamilo", "concentracion": "80 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501573900245", "codigo": "BIO059",
        "snap": "WADIL 30 TAB 500/2.5 MG",
        "nombre": "Wadil metformina/glibenclamida 500/2.5 mg C/30",
        "qty": 2, "pu": 26.53, "lote": "SE2624",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Diabetes", "forma": "Tableta",
        "marca": "Wadil", "laboratorio": "Biomep",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Metformina / Glibenclamida", "concentracion": "500/2.5 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501349020979", "codigo": None,
        "snap": "KETOPROFENO 15 CAPS 100 MG",
        "nombre": "Ketoprofeno 100 mg C/15 cápsulas AMSA",
        "qty": 1, "pu": 35.50, "lote": "U26M109",
        "tipo": "generico", "categoria": "Medicamentos",
        "subcategoria": "Dolor", "forma": "Cápsula",
        "marca": "AMSA", "laboratorio": "AMSA",
        "presentacion": "Caja con 15 cápsulas",
        "principio": "Ketoprofeno", "concentracion": "100 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7502001162518", "codigo": "SON092",
        "snap": "MECLISON 1 GOT 16.66/8.33 MG/15 ML",
        "nombre": "Meclison gotas 15 ml Son's",
        "qty": 3, "pu": 21.01, "lote": "26051373",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Gastro", "forma": "Gotas orales",
        "marca": "Meclison", "laboratorio": "Química Son's",
        "presentacion": "Frasco gotero 15 ml",
        "principio": "Meclizina / Piridoxina",
        "concentracion": "8.33/16.66 mg por ml",
        "receta": False, "ya": True, "foto_file": None,
    },
    {
        "ean": "7502009740176", "codigo": "MAV028",
        "snap": "DOLXEN 20 TAB 250 MG",
        "nombre": "Dolxen naproxeno 250 mg C/20 Maver",
        "qty": 2, "pu": 17.14, "lote": "261858",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Dolor", "forma": "Tableta",
        "marca": "Dolxen", "laboratorio": "Maver",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Naproxeno", "concentracion": "250 mg",
        "receta": False, "ya": False, "foto_file": None,
    },
    {
        "ean": "7502227425039", "codigo": "GEP019",
        "snap": "NIFEDIPINO 20 CAPS 10 MG",
        "nombre": "Nifedipino / Gelprim 10 mg C/20 Gelpharma",
        "qty": 4, "pu": 21.80, "lote": "260717",
        "tipo": "generico", "categoria": "Hipertensión",
        "subcategoria": "Cardiovascular", "forma": "Cápsula",
        "marca": "Gelprim", "laboratorio": "Gelpharma",
        "presentacion": "Caja con 20 cápsulas",
        "principio": "Nifedipino", "concentracion": "10 mg",
        "receta": True, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501299309278", "codigo": "LIO148",
        "snap": "TUSIGEN NF 20 TAB 22.5/22.5 MG",
        "nombre": "Tusigen NF ambroxol/dextrometorfano C/20 Liomont",
        "qty": 3, "pu": 59.60, "lote": "005189",
        "tipo": "marca", "categoria": "Medicamentos",
        "subcategoria": "Respiratorio", "forma": "Tableta",
        "marca": "Tusigen NF", "laboratorio": "Liomont",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Ambroxol / Dextrometorfano",
        "concentracion": "22.5/22.5 mg",
        "receta": False, "ya": False, "foto_file": None,
    },
    {
        "ean": "7501349023369", "codigo": "AMS160",
        "snap": "KETOROLACO TROMETAMINA 6 TAB SL 30 MG",
        "nombre": "Ketorolaco sublingual 30 mg C/6 AMSA",
        "qty": 6, "pu": 5.81, "lote": "U26J016",
        "tipo": "generico", "categoria": "Medicamentos",
        "subcategoria": "Dolor", "forma": "Tableta sublingual",
        "marca": "AMSA", "laboratorio": "AMSA",
        "presentacion": "Caja con 6 tabletas sublinguales",
        "principio": "Ketorolaco trometamina", "concentracion": "30 mg",
        "receta": True, "ya": True, "foto_file": None,
    },
    {
        "ean": "7501349024151", "codigo": "AMS418",
        "snap": "METOCLOPRAMIDA 6 AMP 10MG/2 ML",
        "nombre": "Metoclopramida 10 mg/2 ml C/6 ampolletas AMSA",
        "qty": 2, "pu": 21.02, "lote": "26M507",
        "tipo": "generico", "categoria": "Medicamentos",
        "subcategoria": "Gastro", "forma": "Solución inyectable",
        "marca": "AMSA", "laboratorio": "AMSA",
        "presentacion": "Caja con 6 ampolletas de 2 ml",
        "principio": "Metoclopramida", "concentracion": "10 mg/2 ml",
        "receta": True, "ya": True, "foto_file": None,
    },
]


def finalize_rows() -> list[dict]:
    out = []
    for r in ROWS:
        row = dict(r)
        row["sku"] = sku_eq(row.get("codigo") or "", row["ean"])
        row["sub"] = round(row["pu"] * row["qty"], 2)
        row["precio"] = ceil_pvp(row["pu"], row["tipo"])
        url, rel = foto(row.get("foto_file"))
        row["imagen"] = url
        row["foto_rel"] = rel
        out.append(row)
    return out


def write_csv(path: Path, rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean",
            "descripcion_ticket", "nombre_mostrador", "cantidad",
            "precio_unitario", "subtotal", "lote", "caducidad",
            "sku_farmacapital", "total_ticket", "match",
        ])
        for i, r in enumerate(rows, start=1):
            w.writerow([
                i, FOLIO, FECHA, PROVEEDOR, r["ean"],
                r["snap"], r["nombre"], r["qty"],
                f"{r['pu']:.2f}", f"{r['sub']:.2f}",
                r.get("lote") or "", "",
                r["sku"], f"{TOTAL_TICKET:.2f}",
                "catalogo" if r["ya"] else "ficha",
            ])


def write_sql(path: Path, rows: list[dict]) -> None:
    vals = []
    for i, r in enumerate(rows, start=1):
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
                foto=sql_str(r["imagen"]),
                foto_file=sql_str(r["foto_rel"]),
                lote=sql_str(r.get("lote")),
            )
        )
    eans_unique = []
    seen = set()
    for r in rows:
        if r["ean"] not in seen:
            seen.add(r["ean"])
            eans_unique.append(r["ean"])
    altas = len({r["ean"] for r in rows if not r["ya"]})
    ya = len({r["ean"] for r in rows if r["ya"]})
    sin_foto = sorted({r["ean"] for r in rows if not r["imagen"]})
    notas = (
        "Ticket Equilibrio POS · cliente 307513 Palillero · foto 14-sep-2026 · "
        "cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; "
        "MMAA de la caja · Calaffler R2503424 salía en rojo en el POS"
    )
    body = f"""-- Equilibrio POS · foto 14-sep-2026 · cliente 307513 Palillero.
-- Folio no venía en el recorte: usamos {FOLIO}.
-- Subtotal ${TOTAL_TICKET:,.2f} · IVA $0.00 · 41 renglones / 112 pzas.
-- Dos capturas = mismo ticket con scroll (Venta al Público / PreEQF).
-- Costo = PreEQF. Lote de fábrica sí. Caducidad NO: Recibir pide MMAA.
-- Fichas desde EQF / DISA / Sufarmed / Farma City, no el código truncado del POS.
-- {altas} EANs a alta (stock 0). {ya} EANs ya en historial: solo costo, no PVP.
-- Foto TODO (packshot pendiente en catalogo-propia): {len(sin_foto)} EANs.
-- SIN bloques dollar-quote. Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq20260914 (
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

insert into _fc_eq20260914 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
{chr(10).join(v + ("," if i < len(vals) - 1 else ";") for i, v in enumerate(vals))}

-- Una fila por EAN para el catálogo (Ketorolaco 10 mg va dos lotes).
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
    ) then 'EQ-' || t.ean
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Equilibrio {FOLIO} · foto ticket · listo para pistola',
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
  select distinct on (ean) *
  from _fc_eq20260914
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existía: costo de este ticket. PVP solo si está en 0. No pisa foto buena.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_eq20260914
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select
  v.pid,
  t.imagen,
  t.foto_file,
  0,
  true,
  'distribuidor'
from (
  select distinct on (ean) *
  from _fc_eq20260914
  order by ean, linea
) t
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
where t.imagen is not null
  and v.pid is not null
  and not exists (
    select 1 from public.producto_imagenes x
    where x.producto_id = v.pid and x.url = t.imagen
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL_TICKET:.2f},
  'borrador',
  {sql_str(notas)}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str(notas)}
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
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
from _fc_eq20260914 t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

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
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%equilibrio%'
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
{chr(10).join("  " + sql_str(e) + ("," if i < len(eans_unique) - 1 else "") for i, e in enumerate(eans_unique))}
)
order by p.nombre;
"""
    path.write_text(body, encoding="utf-8")


if __name__ == "__main__":
    rows = finalize_rows()
    assert len(rows) == 41, len(rows)
    piezas = sum(r["qty"] for r in rows)
    assert piezas == 112, piezas
    suma = sum(r["sub"] for r in rows)
    assert abs(suma - TOTAL_TICKET) < 0.02, (suma, TOTAL_TICKET)
    for r in rows:
        assert abs(r["pu"] * r["qty"] - r["sub"]) < 0.03, r
        assert not r["nombre"].isupper(), r["nombre"]
        assert "BLOQ" not in r["nombre"]
        assert len(r["ean"]) >= 12, r["ean"]
        assert r["lote"], r

    write_csv(OUT_TICKET, rows)
    write_sql(OUT_SQL, rows)
    ticket = [
        {
            "ean": r["ean"],
            "sku": r["sku"],
            "nombre": r["snap"],
            "qty": r["qty"],
            "pu": r["pu"],
            "sub": r["sub"],
            "match": "catalogo" if r["ya"] else "ficha",
        }
        for r in rows
    ]
    print(f"csv  {OUT_TICKET}")
    print(f"sql  {OUT_SQL}")
    print(report(ticket, TOTAL_TICKET))
    print(
        "altas",
        len({r["ean"] for r in rows if not r["ya"]}),
        "ya_catalogo",
        len({r["ean"] for r in rows if r["ya"]}),
        "sin_foto",
        len({r["ean"] for r in rows if not r["imagen"]}),
    )
    for r in rows:
        print(
            f"  {r['ean']}  {r['qty']}×{r['pu']:.2f}  "
            f"{'ya' if r['ya'] else 'ALTA'}  {r['nombre']}"
        )
