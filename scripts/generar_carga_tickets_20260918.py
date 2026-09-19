#!/usr/bin/env python3
"""Tickets 18-sep-2026 → CSV + SQL cola Recibir (borrador, stock 0).

Cuatro fotos de Central de Abasto, mismo día:

  Equilibrio 444836     pedido online 10:27  total $1,303.20
  F-48 Abasto 550937    cuidado personal 11:02  total $1,466.50
                        (el voucher Banorte tapa el nombre; tel 55 7261-7572)
  Farmalive 12949       Club Iztapalapa 1 11:08  total $1,730.09
  Dulcería La Victoria  nota T270040861 12:17  total $445.34
                        (el papel dice DULCERIA LA FAMOSA)

Equilibrio: lote de fábrica sí. Caducidad NO (MMAA de la caja).
Farmalive / F-48 / Victoria: el papel no trae lote. No inventar 0000.
Nombres de ficha, no el recorte del térmico.
Costo = precio neto pagado (Equilibrio: P.U.; cánulas con IVA incluido).
"""
from __future__ import annotations

import csv
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report

ROOT = Path(__file__).resolve().parents[1]
GEN = ROOT / "sql" / "generated"
SQL = ROOT / "sql"


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(float(costo) * factor))


def sku_fc(ean: str) -> str:
    return "FC-" + ean[-8:]


def q(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


def b(v: bool) -> str:
    return "true" if v else "false"


# ── Equilibrio 444836 ───────────────────────────────────────────────
# Fichas: Levic / Sufarmed / DISA / ficha de marca. No el código COL009.
EQ_ROWS = [
    {
        "ean": "780083140922", "sku": "FC-2001A890", "codigo": "COL009",
        "snap": "COL009 AMPIGRIN AD 3 AMP 500/500/100/30MG/3 ML",
        "nombre": "Ampigrin AD ampicilina/dicloxacilina 3 amp",
        "qty": 2, "pu": 81.01, "lote": "26240110",
        "tipo": "marca", "categoria": "Antibiótico", "subcategoria": "Inyectable",
        "forma": "Solución inyectable", "marca": "Ampigrin", "laboratorio": "Collins",
        "presentacion": "Caja con 3 frascos ámpula + 3 diluyentes 3 ml",
        "principio": "Ampicilina + dicloxacilina", "concentracion": "500/500/100/30 mg",
        "receta": True, "ya": True,
    },
    {
        "ean": "7503001007069", "sku": "EQ-WAN013", "codigo": "WAN013",
        "snap": "WAN013 VANDIX 1 SUSP 250MG/5/75 ML",
        "nombre": "Vandix amoxicilina 250 mg/5 ml suspensión 75 ml",
        "qty": 2, "pu": 20.12, "lote": "S6253",
        "tipo": "marca", "categoria": "Antibiótico", "subcategoria": None,
        "forma": "Suspensión", "marca": "Vandix", "laboratorio": "Wandel",
        "presentacion": "Frasco 75 ml",
        "principio": "Amoxicilina", "concentracion": "250 mg/5 ml",
        "receta": True, "ya": True,
    },
    {
        "ean": "7502009747281", "sku": sku_fc("7502009747281"), "codigo": "MAV343",
        "snap": "MAV343 DOLVER 10 TAB 800 MG",
        "nombre": "Dolver ibuprofeno 800 mg C/10 Maver",
        "qty": 4, "pu": 20.79, "lote": "261654",
        "tipo": "marca", "categoria": "Analgésico", "subcategoria": "Dolor",
        "forma": "Tableta", "marca": "Dolver", "laboratorio": "Maver",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Ibuprofeno", "concentracion": "800 mg",
        "receta": False, "ya": False,
    },
    {
        "ean": "7503027446279", "sku": "FC-5C8C9C11", "codigo": "PGE057",
        "snap": "PGE057 GELUBRIN 10 CAPS 600 MG",
        "nombre": "Gelubrin ibuprofeno 600 mg C/10",
        "qty": 4, "pu": 21.91, "lote": "U0397",
        "tipo": "marca", "categoria": "Analgésico", "subcategoria": "Dolor",
        "forma": "Cápsula", "marca": "Gelubrin", "laboratorio": "Progela",
        "presentacion": "Caja con 10 cápsulas",
        "principio": "Ibuprofeno", "concentracion": "600 mg",
        "receta": False, "ya": True,
    },
    {
        "ean": "7502009740435", "sku": "EQ-MAV039", "codigo": "MAV039",
        "snap": "MAV039 LARITOL 10 TAB 10 MG",
        "nombre": "Laritol loratadina 10 mg C/10 Maver",
        "qty": 2, "pu": 7.01, "lote": "260197",
        "tipo": "marca", "categoria": "Alergia", "subcategoria": None,
        "forma": "Tableta", "marca": "Laritol", "laboratorio": "Maver",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Loratadina", "concentracion": "10 mg",
        "receta": False, "ya": True,
    },
    {
        "ean": "7503008344785", "sku": "EQ-PGE033", "codigo": "PGE033",
        "snap": "PGE033 GELUBRIN 10 CAPS 400 MG",
        "nombre": "Gelubrin ibuprofeno 400 mg C/10",
        "qty": 2, "pu": 15.11, "lote": "U0126",
        "tipo": "marca", "categoria": "Analgésico", "subcategoria": "Dolor",
        "forma": "Cápsula", "marca": "Gelubrin", "laboratorio": "Progela",
        "presentacion": "Caja con 10 cápsulas",
        "principio": "Ibuprofeno", "concentracion": "400 mg",
        "receta": False, "ya": True,
    },
    {
        "ean": "0780083144302", "sku": "FC-83144302", "codigo": "COL145",
        "snap": "COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML",
        "nombre": "Collifrin adulto oximetazolina 0.05% 20 ml",
        "qty": 2, "pu": 33.69, "lote": "26140881",
        "tipo": "marca", "categoria": "Respiratorio", "subcategoria": "Descongestionante",
        "forma": "Solución nasal", "marca": "Collifrin", "laboratorio": "Collins",
        "presentacion": "Frasco gotero 20 ml",
        "principio": "Oximetazolina", "concentracion": "0.05%",
        "receta": False, "ya": True,
    },
    {
        "ean": "7501125100116", "sku": "FC-25100116", "codigo": "PIS103",
        "snap": "PIS103 SOLUCION CLORURO DE SODIO 0.9%/250 ML",
        "nombre": "Solución CS Pisa cloruro de sodio 0.9% 250 ml",
        "qty": 2, "pu": 26.50, "lote": "P25D312",
        "tipo": "generico", "categoria": "Medicamentos", "subcategoria": "Soluciones",
        "forma": "Solución parenteral", "marca": "CS Pisa", "laboratorio": "Pisa",
        "presentacion": "Frasco 250 ml",
        "principio": "Cloruro de sodio", "concentracion": "0.9%",
        "receta": False, "ya": True,
    },
    {
        "ean": "7501482200016", "sku": "FC-82200016", "codigo": "SOF054",
        "snap": "SOF054 OMEPRAZOL (AKTYZAR) 120 CAPS 20MG",
        "nombre": "Aktyzar omeprazol 20 mg frasco C/120",
        "qty": 3, "pu": 46.90, "lote": "61422",
        "tipo": "marca", "categoria": "Gastro", "subcategoria": None,
        "forma": "Cápsula", "marca": "Aktyzar", "laboratorio": "Solfran",
        "presentacion": "Frasco con 120 cápsulas",
        "principio": "Omeprazol", "concentracion": "20 mg",
        "receta": False, "ya": True,
    },
    {
        # Ficha Sufarmed/iFarma confirma la caja de 14. El EAN de esa caja
        # no salió en la ficha (el de 120 es 7501482200016 y no se reutiliza).
        "ean": None, "sku": "EQ-SOF066", "codigo": "SOF066",
        "snap": "SOF066 OMEPRAZOL (AKTYZAR) 14 CAPS 20MG",
        "nombre": "Aktyzar omeprazol 20 mg C/14",
        "qty": 3, "pu": 8.00, "lote": "61167",
        "tipo": "marca", "categoria": "Gastro", "subcategoria": None,
        "forma": "Cápsula", "marca": "Aktyzar", "laboratorio": "Solfran",
        "presentacion": "Caja con 14 cápsulas",
        "principio": "Omeprazol", "concentracion": "20 mg",
        "receta": False, "ya": False,
    },
    {
        "ean": "7502211780359", "sku": "FC-11780359", "codigo": "LOE001",
        "snap": "LOE001 AFLUSIL 1 SUSP 2G/120ML",
        "nombre": "Aflusil ibuprofeno suspensión 2 g/100 ml 120 ml",
        "qty": 3, "pu": 19.37, "lote": "R2602932",
        "tipo": "marca", "categoria": "Analgésico", "subcategoria": "Dolor",
        "forma": "Suspensión", "marca": "Aflusil", "laboratorio": "Loeffler",
        "presentacion": "Frasco 120 ml",
        "principio": "Ibuprofeno", "concentracion": "2 g/100 ml",
        "receta": False, "ya": True,
    },
    {
        "ean": "7502211784241", "sku": sku_fc("7502211784241"), "codigo": "LOE079",
        "snap": "LOE079 DOFLATEM 1 SUSP 0.18G/100/120 ML",
        "nombre": "Doflatem diclofenaco suspensión 120 ml",
        "qty": 2, "pu": 80.29, "lote": "R2509187B",
        "tipo": "marca", "categoria": "Analgésico", "subcategoria": "Dolor",
        "forma": "Suspensión", "marca": "Doflatem", "laboratorio": "Loeffler",
        "presentacion": "Frasco 120 ml",
        "principio": "Diclofenaco", "concentracion": "0.18 g/100 ml",
        "receta": True, "ya": False,
    },
    {
        "ean": "7502009742828", "sku": sku_fc("7502009742828"), "codigo": "MAV258",
        "snap": "MAV258 LARITOL 20 TAB 10 MG",
        "nombre": "Laritol loratadina 10 mg C/20 Maver",
        "qty": 2, "pu": 8.26, "lote": "263132",
        "tipo": "marca", "categoria": "Alergia", "subcategoria": None,
        "forma": "Tableta", "marca": "Laritol", "laboratorio": "Maver",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Loratadina", "concentracion": "10 mg",
        "receta": False, "ya": False,
    },
    {
        "ean": "7501349029965", "sku": sku_fc("7501349029965"), "codigo": "AMS474",
        "snap": "AMS474 BETAHISTINA 30 TAB 24 MG",
        "nombre": "Betahistina 24 mg C/30 AMSA",
        "qty": 1, "pu": 62.04, "lote": "U26E251",
        "tipo": "generico", "categoria": "Medicamentos", "subcategoria": "Neurología",
        "forma": "Tableta", "marca": "AMSA", "laboratorio": "AMSA",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Betahistina", "concentracion": "24 mg",
        "receta": True, "ya": False,
    },
    {
        "ean": "7502009747373", "sku": "FC-58DB24C4", "codigo": "MAV350",
        "snap": "MAV350 BITENVER 30 TAB 24 MG",
        "nombre": "Bitenver betahistina 24 mg C/30 Maver",
        "qty": 2, "pu": 61.49, "lote": "261052",
        "tipo": "marca", "categoria": "Medicamentos", "subcategoria": "Neurología",
        "forma": "Tableta", "marca": "Bitenver", "laboratorio": "Maver",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Betahistina", "concentracion": "24 mg",
        "receta": True, "ya": True,
    },
    {
        "ean": "7501537102449", "sku": sku_fc("7501537102449"), "codigo": "BRU068",
        "snap": "BRU068 SOLTRIM 20 TAB 80/400 MG",
        "nombre": "Soltrim sulfametoxazol/trimetoprima 80/400 mg C/20",
        "qty": 2, "pu": 12.39, "lote": "606278",
        "tipo": "marca", "categoria": "Antibiótico", "subcategoria": None,
        "forma": "Tableta", "marca": "Soltrim", "laboratorio": "Bruluart",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Sulfametoxazol + trimetoprima", "concentracion": "400/80 mg",
        "receta": True, "ya": False,
    },
    {
        "ean": "7501349024328", "sku": sku_fc("7501349024328"), "codigo": "AMS496",
        "snap": "AMS496 KETOROLACO SL 4 TAB 30 MG",
        "nombre": "Ketorolaco sublingual 30 mg C/4 AMSA",
        "qty": 10, "pu": 5.73, "lote": "U26F370",
        "tipo": "generico", "categoria": "Analgésico", "subcategoria": "Dolor",
        "forma": "Tableta sublingual", "marca": "AMSA", "laboratorio": "AMSA",
        "presentacion": "Caja con 4 tabletas sublinguales",
        "principio": "Ketorolaco", "concentracion": "30 mg",
        "receta": True, "ya": False,
    },
    {
        "ean": "7501573909965", "sku": sku_fc("7501573909965"), "codigo": "BIO216",
        "snap": "BIO216 DOSELMIN 10 TAB 10 MG",
        "nombre": "Doselmin ketorolaco 10 mg C/10 Biomep",
        "qty": 5, "pu": 5.61, "lote": "SA2621",
        "tipo": "marca", "categoria": "Analgésico", "subcategoria": "Dolor",
        "forma": "Tableta", "marca": "Doselmin", "laboratorio": "Biomep",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Ketorolaco", "concentracion": "10 mg",
        "receta": True, "ya": False,
    },
    {
        "ean": None, "sku": "EQ-JAY253", "codigo": "JAY253",
        "snap": "JAY253 CANULA NASAL P/OXIGENO PED 1 PUNTAS",
        "nombre": "Cánula nasal para oxígeno pediátrica",
        "qty": 2, "pu": 17.54, "lote": "2505884701",
        "tipo": "generico", "categoria": "Dispositivos", "subcategoria": "Oxígeno",
        "forma": "Dispositivo", "marca": None, "laboratorio": None,
        "presentacion": "Pieza, puntas nasales pediátricas",
        "principio": None, "concentracion": None,
        "receta": False, "ya": False,
    },
    {
        "ean": None, "sku": "EQ-JAY267", "codigo": "JAY267",
        "snap": "JAY267 PUNTAS P/OXIGENO AD 1 PUNTAS NASALES",
        "nombre": "Puntas nasales para oxígeno adulto",
        "qty": 2, "pu": 17.69, "lote": "2507900301",
        "tipo": "generico", "categoria": "Dispositivos", "subcategoria": "Oxígeno",
        "forma": "Dispositivo", "marca": None, "laboratorio": None,
        "presentacion": "Pieza, puntas nasales adulto",
        "principio": None, "concentracion": None,
        "receta": False, "ya": False,
    },
]

# ── Farmalive 12949 ─────────────────────────────────────────────────
FL_ROWS = [
    {
        "ean": "7502234762417", "sku": "FC-47624171",
        "snap": "NAILEX DESENTERRADOR UÑAS 12 ML | LAB PISA",
        "nombre": "Nailex desenterrador de uñas 12 ml",
        "qty": 2, "pu": 54.49,
        "tipo": "marca", "categoria": "Cuidado personal", "subcategoria": "Uñas",
        "forma": "Solución", "marca": "Nailex", "laboratorio": "Pisa",
        "presentacion": "Frasco 12 ml", "principio": None, "concentracion": None,
        "receta": False, "ya": True,
    },
    {
        "ean": "7501943474895", "sku": sku_fc("7501943474895"),
        "snap": "PAÑAL DIAPRO PREDOBLADO C/10 | KIMBERLY CLARK",
        "nombre": "Pañal Diapro predoblado C/10",
        "qty": 2, "pu": 76.93,
        "tipo": "marca", "categoria": "Higiene", "subcategoria": "Pañales",
        "forma": "Pañal", "marca": "Diapro", "laboratorio": "Kimberly Clark",
        "presentacion": "Bolsa con 10 pañales predoblados",
        "principio": None, "concentracion": None,
        "receta": False, "ya": False,
    },
    {
        "ean": "7501095452178", "sku": sku_fc("7501095452178"),
        "snap": "TEMPRA INF 80 MG TAB C/30 | RB HEALTH",
        "nombre": "Tempra infantil paracetamol 80 mg C/30",
        "qty": 2, "pu": 97.41,
        "tipo": "marca", "categoria": "Analgésico", "subcategoria": "Infantil",
        "forma": "Tableta", "marca": "Tempra", "laboratorio": "RB Health",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Paracetamol", "concentracion": "80 mg",
        "receta": False, "ya": False,
    },
    {
        "ean": "7502240451015", "sku": sku_fc("7502240451015"),
        "snap": "ROSEL SOL PED 30 ML | WERMAR",
        "nombre": "Rosel solución pediátrica 30 ml",
        "qty": 2, "pu": 26.51,
        "tipo": "marca", "categoria": "Respiratorio", "subcategoria": "Infantil",
        "forma": "Solución", "marca": "Rosel", "laboratorio": "Wermar",
        "presentacion": "Frasco 30 ml",
        "principio": "Amantadina + clorfenamina + paracetamol",
        "concentracion": None,
        "receta": False, "ya": False,
    },
    {
        "ean": "7503003738879", "sku": "FC-03738879",
        "snap": "ROSEL-T TAB C/15 | WERMAR",
        "nombre": "Rosel-T tabletas C/15",
        "qty": 4, "pu": 19.81,
        "tipo": "marca", "categoria": "Respiratorio", "subcategoria": None,
        "forma": "Tableta", "marca": "Rosel-T", "laboratorio": "Wermar",
        "presentacion": "Caja con 15 tabletas",
        "principio": "Amantadina + clorfenamina + paracetamol",
        "concentracion": None,
        "receta": False, "ya": True,
    },
    {
        "ean": "7501537164713", "sku": "FC-37164713",
        "snap": "IV TRIBEDOCE COMPUESTO GRA C/30 | BRULUART",
        "nombre": "Tribedoce Compuesto grageas C/30",
        "qty": 4, "pu": 40.48,
        "tipo": "marca", "categoria": "Vitaminas", "subcategoria": None,
        "forma": "Gragea", "marca": "Tribedoce", "laboratorio": "Bruluart",
        "presentacion": "Caja con 30 grageas",
        "principio": "Complejo B + diclofenaco", "concentracion": None,
        "receta": False, "ya": True,
    },
    {
        "ean": "780083148676", "sku": sku_fc("780083148676"),
        "snap": "AMPIGRIN PFC CAPS C/24 | COLLINS",
        "nombre": "Ampigrin PFC cápsulas C/24",
        "qty": 2, "pu": 28.83,
        "tipo": "marca", "categoria": "Respiratorio", "subcategoria": None,
        "forma": "Cápsula", "marca": "Ampigrin", "laboratorio": "Collins",
        "presentacion": "Caja con 24 cápsulas",
        "principio": "Amantadina + clorfenamina + paracetamol",
        "concentracion": None,
        "receta": False, "ya": False,
    },
    {
        "ean": "650240072925", "sku": sku_fc("650240072925"),
        "snap": "LAKESIA SOLUCION 3 ML | GENOMMA LAB",
        "nombre": "Lakesia solución 3 ml",
        "qty": 2, "pu": 149.55,
        "tipo": "marca", "categoria": "Cuidado personal", "subcategoria": "Uñas",
        "forma": "Solución", "marca": "Lakesia", "laboratorio": "Genomma Lab",
        "presentacion": "Frasco 3 ml",
        "principio": None, "concentracion": None,
        "receta": False, "ya": False,
    },
    {
        "ean": "7502227870716", "sku": sku_fc("7502227870716"),
        "snap": "VYLKOR 8 MG TAB C/10 | RAAM",
        "nombre": "Vylkor ondansetrón 8 mg C/10",
        "qty": 3, "pu": 55.53,
        "tipo": "marca", "categoria": "Gastro", "subcategoria": "Antiemético",
        "forma": "Tableta", "marca": "Vylkor", "laboratorio": "Raam",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Ondansetrón", "concentracion": "8 mg",
        "receta": True, "ya": False,
    },
    {
        "ean": "7503003738404", "sku": "EQ-WER025",
        "snap": "ROSEL CAPS C/24 | WERMAR",
        "nombre": "Rosel cápsulas C/24",
        "qty": 3, "pu": 25.58,
        "tipo": "marca", "categoria": "Respiratorio", "subcategoria": None,
        "forma": "Cápsula", "marca": "Rosel", "laboratorio": "Wermar",
        "presentacion": "Caja con 24 cápsulas",
        "principio": "Amantadina + clorfenamina + paracetamol",
        "concentracion": None,
        "receta": False, "ya": True,
    },
    {
        "ean": "7502240450902", "sku": sku_fc("7502240450902"),
        "snap": "WERNICROS 75 MG C/10 CAP | WERMAR",
        "nombre": "Wernicros oseltamivir 75 mg C/10",
        "qty": 2, "pu": 116.25,
        "tipo": "marca", "categoria": "Antiviral", "subcategoria": None,
        "forma": "Cápsula", "marca": "Wernicros", "laboratorio": "Wermar",
        "presentacion": "Caja con 10 cápsulas",
        "principio": "Oseltamivir", "concentracion": "75 mg",
        "receta": True, "ya": False,
    },
    {
        "ean": "7502208891549", "sku": "FC-88915491",
        "snap": "TARMIN 2 MG C/12 TAB | BRULUAGSA",
        "nombre": "Tarmin 2 mg tabletas C/12",
        "qty": 8, "pu": 5.72,
        "tipo": "marca", "categoria": "Gastro", "subcategoria": None,
        "forma": "Tableta", "marca": "Tarmin", "laboratorio": "Bruluagsa",
        "presentacion": "Caja con 12 tabletas",
        "principio": "Loperamida", "concentracion": "2 mg",
        "receta": False, "ya": True,
    },
    {
        "ean": "7501019068911", "sku": "FC-19068911",
        "snap": "PROTECTORES SABA TRADICIONAL LARGO C/28 | SCA",
        "nombre": "Protectores Saba tradicional largo C/28",
        "qty": 4, "pu": 24.99,
        "tipo": "marca", "categoria": "Higiene", "subcategoria": None,
        "forma": "Protector", "marca": "Saba", "laboratorio": "Essity",
        "presentacion": "Bolsa con 28 protectores",
        "principio": None, "concentracion": None,
        "receta": False, "ya": True,
    },
]

# ── F-48 Abasto 550937 ──────────────────────────────────────────────
# Nombre comercial tapado por el voucher Banorte (#TuBancoTuTiempo).
# Encabezado visible: ABASTO, IZTAPALAPA · F48 A · CP 09040
# Tel 55 7261-7572 · WhatsApp 5534027357 · folio 550,937 · 11:02
# EAN solo donde ya estaba en un ticket anterior de la misma pieza.
F48_ROWS = [
    {
        "ean": None, "sku": "FC-F48-LUB750",
        "snap": "LUBRIDERM DORADA 750ML REP",
        "nombre": "Lubriderm Reparación Intensiva crema 750 ml",
        "qty": 2, "pu": 140.00,
        "tipo": "marca", "categoria": "Cuidado personal", "marca": "Lubriderm",
        "presentacion": "Botella 750 ml", "ya": False,
    },
    {
        "ean": None, "sku": "FC-F48-LUBA400",
        "snap": "LUBRIDERM AQUA 400ML HUMEC",
        "nombre": "Lubriderm Aqua crema humectante 400 ml",
        "qty": 2, "pu": 90.00,
        "tipo": "marca", "categoria": "Cuidado personal", "marca": "Lubriderm",
        "presentacion": "Botella 400 ml", "ya": False,
    },
    {
        "ean": None, "sku": "FC-F48-GRIAV450",
        "snap": "SH GRISI GEL AVENA 450ML",
        "nombre": "Grisi shampoo gel avena 450 ml",
        "qty": 1, "pu": 65.01,
        "tipo": "marca", "categoria": "Cuidado personal", "marca": "Grisi",
        "presentacion": "Botella 450 ml", "ya": False,
    },
    {
        "ean": None, "sku": "FC-F48-PIE180",
        "snap": "SPY PIE DE ATLETA 180ML AE",
        "nombre": "Spray pie de atleta 180 ml",
        "qty": 1, "pu": 82.00,
        "tipo": "marca", "categoria": "Cuidado personal", "marca": None,
        "presentacion": "Aerosol 180 ml", "ya": False,
    },
    {
        "ean": None, "sku": "FC-F48-GRINE450",
        "snap": "SH GRISI GEL NEUTRO 450ML",
        "nombre": "Grisi shampoo gel neutro 450 ml",
        "qty": 1, "pu": 65.01,
        "tipo": "marca", "categoria": "Cuidado personal", "marca": "Grisi",
        "presentacion": "Botella 450 ml", "ya": False,
    },
    {
        "ean": None, "sku": "FC-F48-MEX160",
        "snap": "MEXANA 160GR TALCO MEXSANA",
        "nombre": "Mexsana talco 160 g",
        "qty": 1, "pu": 90.00,
        "tipo": "marca", "categoria": "Cuidado personal", "marca": "Mexsana",
        "presentacion": "Bote 160 g", "ya": False,
    },
    {
        "ean": None, "sku": "FC-F48-LAC250",
        "snap": "LACTOVIT (250ML) CREMA",
        "nombre": "Lactovit crema corporal 250 ml",
        "qty": 1, "pu": 60.00,
        "tipo": "marca", "categoria": "Cuidado personal", "marca": "Lactovit",
        "presentacion": "Botella 250 ml", "ya": False,
    },
    {
        "ean": "037836041297", "sku": "FC-36041297",
        "snap": "HINDS INSPIRACION 90",
        "nombre": "Hinds Inspiración crema 90 ml",
        "qty": 2, "pu": 16.99,
        "tipo": "marca", "categoria": "Cuidado personal", "marca": "Hinds",
        "presentacion": "Tubo 90 ml", "ya": True,
    },
    {
        "ean": "7506306257597", "sku": "FC-06257597",
        "snap": "TCO EFFICIENT 100GR REXONA",
        "nombre": "Talco para pies Rexona Efficient 100 g",
        "qty": 2, "pu": 45.01,
        "tipo": "marca", "categoria": "Higiene", "marca": "Rexona",
        "presentacion": "Bote 100 g", "ya": True,
    },
    {
        "ean": None, "sku": "FC-F48-LAC400",
        "snap": "LACTOVIT (400ML) CREMA",
        "nombre": "Lactovit crema corporal 400 ml",
        "qty": 2, "pu": 80.01,
        "tipo": "marca", "categoria": "Cuidado personal", "marca": "Lactovit",
        "presentacion": "Botella 400 ml", "ya": False,
    },
    {
        "ean": None, "sku": "FC-F48-TAMPREG",
        "snap": "TAMPAX REGULAR AMARILLO",
        "nombre": "Tampax Regular",
        "qty": 1, "pu": 48.00,
        "tipo": "marca", "categoria": "Higiene", "marca": "Tampax",
        "presentacion": "Caja regular", "ya": False,
    },
    {
        "ean": None, "sku": "FC-F48-DOVEMEN",
        "snap": "DS DOVE MEN INVISIBLE BARR",
        "nombre": "Dove Men desodorante Invisible",
        "qty": 2, "pu": 53.00,
        "tipo": "marca", "categoria": "Higiene", "marca": "Dove",
        "presentacion": "Barra", "ya": False,
    },
    {
        "ean": None, "sku": "FC-F48-REXGEL",
        "snap": "DS REXONA XTRACOOL GEL 80G",
        "nombre": "Rexona Xtracool desodorante gel 80 g",
        "qty": 2, "pu": 65.01,
        "tipo": "marca", "categoria": "Higiene", "marca": "Rexona",
        "presentacion": "Gel 80 g", "ya": False,
    },
    {
        "ean": "037836041389", "sku": "FC-36041389",
        "snap": "HINDS ALMENDRA 90ML",
        "nombre": "Hinds almendras crema 90 ml",
        "qty": 2, "pu": 16.99,
        "tipo": "marca", "categoria": "Cuidado personal", "marca": "Hinds",
        "presentacion": "Tubo 90 ml", "ya": True,
    },
    {
        "ean": None, "sku": "FC-F48-OLO70",
        "snap": "OLOREX AEROSOL CLASICO 70M",
        "nombre": "Olorex aerosol clásico 70 ml",
        "qty": 1, "pu": 42.00,
        "tipo": "marca", "categoria": "Higiene", "marca": "Olorex",
        "presentacion": "Aerosol 70 ml", "ya": False,
    },
]

# ── Dulcería ────────────────────────────────────────────────────────
# 4/600GR = caja de 4 conejos de 600 g (se vende el conejo).
# 22/9PZ = exhibidor de 22 packs de 9 piezas (se vende el pack).
DV_ROWS = [
    {
        "sku": "FC-LV-TURIN600",
        "snap": "TURIN CONEJO FOCO VIT. 4/600GR",
        "nombre": "Turin Conejo foco chocolate 600 g",
        "marca": "Turin",
        "presentacion": "Conejo 600 g (caja mayoreo 4)",
        "cajas": 1,
        "pzas_por_caja": 4,
        "costo_caja": 304.59,
        "precio": 107,
    },
    {
        "sku": "FC-LV-KITKAT22",
        "snap": "NESTLE KITKAT EXTRA MILK & COCOA 22/9PZ",
        "nombre": "KitKat Extra Milk & Cocoa",
        "marca": "KitKat",
        "presentacion": "Pack 9 piezas (exhibidor 22)",
        "cajas": 1,
        "pzas_por_caja": 22,
        "costo_caja": 140.75,
        "precio": 9,
    },
]


def with_precio(rows: list[dict]) -> list[dict]:
    out = []
    for r in rows:
        out.append({**r, "precio": ceil_pvp(r["pu"], r["tipo"]), "sub": round(r["qty"] * r["pu"], 2)})
    return out


def write_csv_ean(path: Path, *, folio: str, fecha: str, proveedor: str, total: float, rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean", "descripcion_ticket",
            "cantidad", "precio_unitario", "subtotal", "lote", "caducidad",
            "sku_farmacapital", "total_ticket", "match",
        ])
        for i, r in enumerate(rows, start=1):
            w.writerow([
                i, folio, fecha, proveedor, r.get("ean") or "",
                r.get("snap") or r["nombre"], r["qty"], f"{r['pu']:.2f}",
                f"{r['sub']:.2f}", r.get("lote") or "", "",
                r["sku"], f"{total:.2f}", "ya" if r.get("ya") else "alta",
            ])


def write_sql_ean(
    path: Path,
    *,
    folio: str,
    proveedor: str,
    proveedor_ilike: str,
    fecha: str,
    total: float,
    notas: str,
    header: str,
    rows: list[dict],
    con_lote: bool,
    tmp: str,
) -> None:
    cols = [
        "linea", "ean", "sku", "nombre", "snap", "qty", "costo", "precio",
        "tipo", "categoria", "subcategoria", "forma", "marca", "laboratorio",
        "presentacion", "principio_activo", "concentracion", "receta", "ya",
    ]
    if con_lote:
        cols.append("lote")
    vals = []
    for i, r in enumerate(rows, start=1):
        bits = [
            str(i),
            q(r.get("ean")),
            q(r["sku"]),
            q(r["nombre"]),
            q(r.get("snap") or r["nombre"]),
            str(int(r["qty"])),
            f"{r['pu']:.2f}",
            str(int(r["precio"])),
            q(r["tipo"]),
            q(r["categoria"]),
            q(r.get("subcategoria")),
            q(r.get("forma")),
            q(r.get("marca")),
            q(r.get("laboratorio")),
            q(r.get("presentacion")),
            q(r.get("principio")),
            q(r.get("concentracion")),
            b(bool(r.get("receta"))),
            b(bool(r.get("ya"))),
        ]
        if con_lote:
            bits.append(q(r.get("lote")))
        vals.append("  (" + ", ".join(bits) + ")")

    lote_col = ",\n  lote text" if con_lote else ""
    lote_ins = ", lote" if con_lote else ""
    lote_sel = ",\n  t.lote" if con_lote else ",\n  null"
    folio_s = q(folio)
    prov_s = q(proveedor)
    ilike = q("%" + proveedor_ilike + "%")
    altas = sum(1 for r in rows if not r.get("ya"))
    body = f"""{header}
-- {altas} alta(s) con stock 0 si el EAN no está. El resto solo costo (PVP si estaba en 0).
-- TODO foto: las altas nuevas no traen packshot en este SQL. No usar placeholder de otra cadena.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table {tmp} (
  linea integer primary key,
  ean text,
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
  ya boolean not null{lote_col}
) on commit drop;

insert into {tmp} (
  {", ".join(cols)}
) values
{",".join(chr(10) + v for v in vals)};

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio
)
select
  t.nombre,
  case
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta {proveedor} {folio} · {fecha} · listo para pistola',
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
  t.laboratorio
from {tmp} t
where (
    t.ean is not null and public.fc_buscar_producto_escaneo(t.ean) is null
  ) or (
    t.ean is null and public.fc_buscar_producto_escaneo(t.sku) is null
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from {tmp} t
where p.id = coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) else null end,
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
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma)
from {tmp} t
where p.id = coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {prov_s},
  {folio_s},
  {q(fecha)},
  {total:.2f},
  'borrador',
  {q(notas)}
where not exists (
  select 1 from public.recepciones
  where folio = {folio_s}
    and coalesce(proveedor, '') ilike {ilike}
);

update public.recepciones
set
  total_ticket = {total:.2f},
  fecha = {q(fecha)},
  proveedor = {prov_s},
  notas = {q(notas)},
  updated_at = now()
where folio = {folio_s}
  and coalesce(proveedor, '') ilike {ilike}
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {folio_s}
  and coalesce(r.proveedor, '') ilike {ilike}
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(btrim(t.ean), ''),
  t.nombre,
  t.qty,
  null{lote_sel},
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
    )
  ),
  null
from {tmp} t
join public.recepciones r
  on r.folio = {folio_s}
 and coalesce(r.proveedor, '') ilike {ilike}
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = {folio_s}
  and coalesce(r.proveedor, '') ilike {ilike}
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;
"""
    path.write_text(body, encoding="utf-8")


def write_dulceria(rows: list[dict]) -> None:
    folio = "T270040861"
    proveedor = "Dulcería La Victoria"
    fecha = "2026-09-18"
    total = 445.34
    expanded = []
    for r in rows:
        qty = r["cajas"] * r["pzas_por_caja"]
        costo = round(r["costo_caja"] / r["pzas_por_caja"], 4)
        expanded.append({**r, "qty": qty, "costo": costo, "pu": costo, "sub": round(costo * qty, 2)})

    csv_path = GEN / "ticket_dulceria_victoria_T270040861.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean", "sku",
            "descripcion_ticket", "cantidad_mostrador", "costo_unitario",
            "subtotal", "total_ticket",
        ])
        for i, r in enumerate(expanded, start=1):
            w.writerow([
                i, folio, fecha, proveedor, "", r["sku"], r["snap"],
                r["qty"], f"{r['costo']:.4f}", f"{r['sub']:.2f}", f"{total:.2f}",
            ])

    vals = []
    for i, r in enumerate(expanded, start=1):
        vals.append(
            f"  ({i}, {q(r['sku'])}, {q(r['snap'])}, {q(r['nombre'])}, "
            f"{q(r['marca'])}, {q(r['presentacion'])}, 'Impulso', 'marca', "
            f"{r['qty']}, {r['costo']:.4f}, {r['precio']:.2f})"
        )
    notas = (
        "Nota T270040861 · ticket imprime La Famosa · negocio La Victoria F-20 · "
        "Turin Conejo 4 pzas + KitKat Extra 22 packs · "
        "EAN pendiente de caja · stock al confirmar pistola"
    )
    sql = f"""-- Dulcería La Victoria · nota {folio} · {fecha} 12:17
-- Ticket imprime «DULCERIA LA FAMOSA» (WinCaja, clave LAFAM21702) pero el negocio
-- es Dulcería La Victoria, Bodega F-20 Central de Abasto
-- (correo quejas_ysug@dulcerialavictoria.com).
-- Total tarjeta ${total:.2f}. Mayoreo → piezas de mostrador.
-- Turin 4/600GR ×1 → 4 conejos de 600 g. KitKat 22/9PZ ×1 → 22 packs.
--
-- SIN EAN en el ticket: no se inventan códigos. codigo_barras queda null
-- hasta escanear la caja. Stock al confirmar en Recibir + MMAA de la caja.
-- TODO foto: packshot del conejo y del pack KitKat. No usar placeholder de otra cadena.
-- No poner caducidad 0000.
--
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

insert into public.proveedores (nombre, activo)
select {q(proveedor)}, true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower({q(proveedor)})
);

create temp table _fc_lv_t270040861 (
  linea integer primary key,
  sku text not null,
  snap text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  categoria text not null,
  tipo text not null,
  qty integer not null,
  costo numeric(12,4) not null,
  precio numeric(12,2) not null
) on commit drop;

insert into _fc_lv_t270040861
  (linea, sku, snap, nombre, marca, presentacion, categoria, tipo, qty, costo, precio)
values
{",".join(chr(10) + v for v in vals)};

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  marca, presentacion, costo, precio, stock, stock_minimo,
  activo, requiere_receta
)
select
  t.nombre,
  t.sku,
  null,
  t.categoria,
  t.tipo,
  'Alta Dulcería La Victoria {folio} · {fecha} · EAN pendiente de caja · ticket decía La Famosa',
  t.marca,
  t.presentacion,
  t.costo,
  t.precio,
  0,
  greatest(2, least(t.qty / 4, 10)),
  true,
  false
from _fc_lv_t270040861 t
where not exists (
  select 1 from public.productos p where p.sku = t.sku
);

update public.productos p
set
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  categoria = t.categoria
from _fc_lv_t270040861 t
where p.sku = t.sku;

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {q(proveedor)},
  {q(folio)},
  {q(fecha)},
  {total:.2f},
  'borrador',
  {q(notas)}
where not exists (
  select 1 from public.recepciones
  where folio = {q(folio)}
    and coalesce(proveedor, '') ilike '%victoria%'
);

update public.recepciones
set
  total_ticket = {total:.2f},
  fecha = {q(fecha)},
  proveedor = {q(proveedor)},
  notas = {q(notas)},
  updated_at = now()
where folio = {q(folio)}
  and coalesce(proveedor, '') ilike '%victoria%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {q(folio)}
  and coalesce(r.proveedor, '') ilike '%victoria%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  p.id,
  null,
  t.nombre,
  t.qty,
  null,
  null,
  t.costo,
  (p.id is null),
  'pdf',
  false,
  false,
  null
from _fc_lv_t270040861 t
join public.recepciones r
  on r.folio = {q(folio)}
 and coalesce(r.proveedor, '') ilike '%victoria%'
 and r.estado = 'borrador'
left join public.productos p on p.sku = t.sku
order by t.linea;

select r.folio, r.estado, r.total_ticket, count(i.*) as renglones, sum(i.cantidad) as piezas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = {q(folio)} and coalesce(r.proveedor, '') ilike '%victoria%'
group by r.id, r.folio, r.estado, r.total_ticket;

commit;
"""
    (SQL / "patch_carga_dulceria_victoria_T270040861.sql").write_text(sql, encoding="utf-8")
    return expanded


def main() -> None:
    eq = with_precio(EQ_ROWS)
    fl = with_precio(FL_ROWS)
    f48 = with_precio(F48_ROWS)

    eq_sum = round(sum(r["sub"] for r in eq), 2)
    fl_sum = round(sum(r["qty"] * r["pu"] for r in fl), 2)
    f48_sum = round(sum(r["sub"] for r in f48), 2)
    if abs(eq_sum - 1303.20) > 0.02:
        raise SystemExit(f"Equilibrio no cuadra: {eq_sum} vs 1303.20")
    print("Equilibrio", report(
        [{"qty": r["qty"], "sub": r["sub"], "ean": r.get("ean")} for r in eq], 1303.20
    ))
    print(f"Farmalive suma renglones ${fl_sum:.2f} vs ticket $1730.09 (centavos de redondeo del P.U.)")
    print(f"F-48 suma renglones ${f48_sum:.2f} vs ticket $1466.50")
    if abs(f48_sum - 1466.50) > 1:
        raise SystemExit("F-48 se fue por más de $1")

    write_csv_ean(
        GEN / "ticket_equilibrio_444836.csv",
        folio="444836", fecha="2026-09-18", proveedor="Equilibrio",
        total=1303.20, rows=eq,
    )
    write_csv_ean(
        GEN / "ticket_farmalive_12949.csv",
        folio="12949", fecha="2026-09-18", proveedor="Farmalive",
        total=1730.09, rows=fl,
    )
    write_csv_ean(
        GEN / "ticket_abasto_f48_550937.csv",
        folio="550937", fecha="2026-09-18", proveedor="F-48 Abasto",
        total=1466.50, rows=f48,
    )

    write_sql_ean(
        SQL / "patch_carga_equilibrio_444836.sql",
        folio="444836", proveedor="Equilibrio", proveedor_ilike="equilibrio",
        fecha="2026-09-18", total=1303.20,
        notas=(
            "Ticket Equilibrio 444836 · Iztapalapa · 18-sep-2026 10:27 · pedido online · "
            "cliente 307513 · cola Recibir; stock al confirmar pistola · "
            "cánulas con IVA incluido en el costo"
        ),
        header=(
            "-- Equilibrio · ticket 444836 · 2026-09-18 10:27 · pedido online\n"
            "-- Cliente 307513 LUIS ANGEL PALILLERO VENTURA · Pasillo EF Loc E-43.\n"
            "-- Total $1,303.20 (subtotal $1,293.48 + IVA $9.72 de las cánulas).\n"
            "-- Lote de fábrica sí. Caducidad NO: Recibir pide MMAA de la caja.\n"
            "-- Costo = P.U. En JAY253/JAY267 el P.U. es sin IVA; el costo es el total/qty.\n"
            "-- SOF066, JAY253 y JAY267: sin EAN confirmado. Toca el renglón; no esperes el beep.\n"
            "-- Betahistina AMSA (7501349029965) no es Bitenver (7502009747373).\n"
            "-- Laritol C/20 (7502009742828) no es Laritol C/10 (7502009740435)."
        ),
        rows=eq, con_lote=True, tmp="_fc_eq_444836",
    )
    write_sql_ean(
        SQL / "patch_carga_farmalive_12949.sql",
        folio="12949", proveedor="Farmalive", proveedor_ilike="farmalive",
        fecha="2026-09-18", total=1730.09,
        notas=(
            "Ticket Farmalive 12949 · Club Iztapalapa 1 · 18-sep-2026 11:08 · "
            "tarjeta $1,730.09 · cliente FARMACAPITAL · 13 renglones / 40 pzas · "
            "costo = precio neto después del descuento · cola Recibir"
        ),
        header=(
            "-- Farmalive Club Iztapalapa 1 · ticket 12949 · 18-sep-2026 11:08\n"
            "-- Cliente 10000516 FARMACAPITAL · atendió Cesia Noemi Serrano Lopez.\n"
            "-- Subtotal $1,839.40 − descuento $109.31 = $1,730.09 tarjeta.\n"
            "-- 13 renglones / 40 piezas. Costo = P.U. ya con descuento.\n"
            "-- El papel no trae lote. No inventar MMAA ni 0000.\n"
            "-- Pañal Diapro predoblado 7501943474895 no es el Diapro Med 7501943474994.\n"
            "-- Ampigrin PFC cápsulas 780083148676 no es el jarabe 780083148577.\n"
            "-- Rosel sol ped 30 ml 7502240451015 no es el Rosel 60 ml 7502240450230.\n"
            "-- Los P.U. redondean 1 centavo en Rosel sol, Vylkor, Rosel caps y Saba;\n"
            "-- el total del ticket se queda en $1,730.09."
        ),
        rows=fl, con_lote=False, tmp="_fc_fl_12949",
    )
    write_sql_ean(
        SQL / "patch_carga_abasto_f48_550937.sql",
        folio="550937", proveedor="F-48 Abasto", proveedor_ilike="f-48",
        fecha="2026-09-18", total=1466.50,
        notas=(
            "Ticket folio 550937 · 18-sep-2026 11:02 · efectivo $1,466.50 · "
            "ABASTO IZTAPALAPA local F48 A · tel 55 7261-7572 · WhatsApp 5534027357 · "
            "el voucher Banorte tapa el nombre comercial · "
            "Hinds y Rexona Efficient sí tienen EAN; el resto se toca en el renglón"
        ),
        header=(
            "-- Cuidado personal · folio 550937 · 18-sep-2026 11:02 · efectivo $1,466.50\n"
            "-- El voucher Banorte (#TuBancoTuTiempo) tapa el nombre del local.\n"
            "-- Lo que sí se lee: ABASTO, IZTAPALAPA · código F48 A · CP 09040\n"
            "-- Tel 55 7261-7572 · WhatsApp 5534027357 · vendedor ADMIN · 23 piezas.\n"
            "-- Proveedor en Recibir: «F-48 Abasto» hasta que se vea el nombre.\n"
            "-- EAN solo en piezas que ya estaban (Hinds 90 ml, Rexona Efficient 100 g).\n"
            "-- El resto: alta por SKU FC-F48-* sin código inventado. Toca el renglón.\n"
            "-- TODO foto en las altas nuevas. No usar placeholder de otra cadena.\n"
            "-- La suma de renglones leídos es $1,466.04; el papel dice $1,466.50.\n"
            "-- Se respeta el total impreso. No se inventó un centavo en los P.U."
        ),
        rows=f48, con_lote=False, tmp="_fc_f48_550937",
    )
    dv = write_dulceria(DV_ROWS)
    dv_sum = round(sum(r["sub"] for r in dv), 2)
    if abs(dv_sum - 445.34) > 0.02:
        raise SystemExit(f"Victoria no cuadra: {dv_sum}")
    print(f"Victoria piezas {sum(r['qty'] for r in dv)} suma ${dv_sum:.2f}")
    print("ok")


if __name__ == "__main__":
    main()
